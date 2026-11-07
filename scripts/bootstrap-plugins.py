#!/usr/bin/env python3
"""Restore reviewed plugin pins after Nix supplies Git, Python, Fish and Neovim.

No version selection happens here. Use --check for a read-only preflight.
"""
import argparse
import json
import os
from pathlib import Path
import re
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[1]
SHA = re.compile(r"[0-9a-f]{40}")
REPO = re.compile(r"[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+")


def run(*args, **kwargs):
    return subprocess.run([str(arg) for arg in args], check=True, **kwargs)


def git(directory, *args):
    return run("git", "-C", directory, *args, text=True, capture_output=True).stdout.strip()


def read_pins(root):
    manifest = root / "fish/fish_plugins"
    pins = manifest.read_text().splitlines()
    if not pins or len(set(pins)) != len(pins):
        raise ValueError("fish_plugins must contain unique pinned entries")
    for pin in pins:
        repo, separator, commit = pin.partition("@")
        if not separator or not REPO.fullmatch(repo) or not SHA.fullmatch(commit):
            raise ValueError(f"Invalid Fisher pin: {pin}")
    managers = [p.split("@", 1)[1] for p in pins if p.startswith("jorgebucaran/fisher@")]
    if len(managers) != 1:
        raise ValueError("Fisher itself must be pinned exactly once")
    lock = json.loads((root / "nvim/lua/plugins/lazy-lock.json").read_text())
    sources = json.loads((root / "nvim/plugin-sources.json").read_text())
    if not isinstance(lock, dict) or "lazy.nvim" not in lock or set(lock) != set(sources):
        raise ValueError("plugin-sources.json must match every lazy-lock.json entry")
    for name, pin in lock.items():
        if (not re.fullmatch(r"[A-Za-z0-9_.-]+", name) or name in (".", "..")
                or not isinstance(pin, dict) or not isinstance(pin.get("commit"), str)
                or not SHA.fullmatch(pin["commit"])
                or not isinstance(sources[name], str) or not REPO.fullmatch(sources[name])):
            raise ValueError(f"Invalid Lazy pin/source: {name}")
    if sources["lazy.nvim"] != "folke/lazy.nvim":
        raise ValueError("Unexpected lazy.nvim source")
    return managers[0], lock


def config_links(root, config_home):
    links = [(root / name, config_home / name) for name in ("fish", "nvim", "tmux")]
    # Validate all destinations before creating any links.
    for source, target in links:
        if (target.exists() or target.is_symlink()) and target.resolve() != source.resolve():
            raise ValueError(f"Existing config is not this checkout: {target}. Move it aside explicitly first.")
    return links


def checkout_pin(directory, url, commit):
    """Check out a verified commit without resetting local edits or executing it."""
    if not SHA.fullmatch(commit):
        raise ValueError("Expected a full commit SHA")
    if directory.exists():
        if not (directory / ".git").is_dir():
            raise ValueError(f"Not a Git checkout: {directory}")
        if git(directory, "status", "--porcelain"):
            raise ValueError(f"Local changes in {directory}; refusing to overwrite them")
        # Accept the usual SSH spelling of the same GitHub repository.
        origin = git(directory, "remote", "get-url", "origin")
        normalized = origin.replace("git@github.com:", "https://github.com/").removesuffix(".git")
        if normalized != url.removesuffix(".git"):
            raise ValueError(f"Unexpected origin for {directory}: {origin}")
    else:
        directory.parent.mkdir(parents=True, exist_ok=True)
        run("git", "init", "--quiet", directory)
        git(directory, "remote", "add", "origin", url)
    exists = subprocess.run(["git", "-C", str(directory), "cat-file", "-e", commit + "^{commit}"],
                            stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL).returncode == 0
    if not exists:
        git(directory, "fetch", "--depth=1", "origin", commit)
    git(directory, "-c", "core.hooksPath=/dev/null", "checkout", "--quiet", "--detach", commit)
    if git(directory, "rev-parse", "HEAD") != commit:
        raise ValueError(f"Commit verification failed: {directory}")


def restore_fisher(source, manifest):
    reviewed = manifest.read_bytes()
    try:
        run("fish", "-c", '''
source "$argv[1]"; or exit 1
set -g fisher_path "$__fish_config_dir"
set -l expected (cat "$argv[2]")
fisher update
set -l result $status
for plugin in $expected
    contains -- "$plugin" $_fisher_plugins; or set result 1
end
test (count $expected) -eq (count $_fisher_plugins); or set result 1
exit $result
''', source, manifest)
    finally:
        if not manifest.exists() or manifest.read_bytes() != reviewed:
            manifest.write_bytes(reviewed)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    if os.environ.get("NVIM_APPNAME", "nvim") != "nvim":
        raise ValueError("This bootstrap manages the default nvim application only")
    fisher_commit, lock = read_pins(ROOT)
    config_home = Path(os.environ.get("XDG_CONFIG_HOME", str(Path.home() / ".config")))
    data_home = Path(os.environ.get("XDG_DATA_HOME", str(Path.home() / ".local/share")))
    links = config_links(ROOT, config_home)
    if args.check:
        print("Pinned manifests and configuration destinations are valid.")
        return
    for source, target in links:
        target.parent.mkdir(parents=True, exist_ok=True)
        if not target.is_symlink() and not target.exists():
            target.symlink_to(source, target_is_directory=True)
    lazy_path = data_home / "nvim/lazy/lazy.nvim"
    checkout_pin(lazy_path, "https://github.com/folke/lazy.nvim.git", lock["lazy.nvim"]["commit"])
    # Source the verified Fisher before invoking it. Use a normal Fish session:
    # --no-config disables persistent universal variables on Fish 4, losing
    # Fisher's ownership records and causing file conflicts on the next run.
    # Existing shell startup code and pinned Fisher install hooks may run.
    with tempfile.TemporaryDirectory(prefix="dotfiles-fisher-") as temp:
        fisher = Path(temp) / "fisher"
        checkout_pin(fisher, "https://github.com/jorgebucaran/fisher.git", fisher_commit)
        restore_fisher(fisher / "functions/fisher.fish", ROOT / "fish/fish_plugins")
    env = dict(os.environ, DOTFILES_UPDATE_ROOT=str(ROOT), DOTFILES_BOOTSTRAP_PLUGINS="1")
    run("nvim", "--headless", "-u", "NONE", "-i", "NONE", "-n", "-l",
        ROOT / "nvim/scripts/restore-locked.lua", env=env)
    print("Fixed plugin sources restored. Neovim build hooks were not run; see home-manager/README.md.")


if __name__ == "__main__":
    try:
        main()
    except (ValueError, OSError, subprocess.CalledProcessError) as error:
        raise SystemExit(f"bootstrap: {error}")
