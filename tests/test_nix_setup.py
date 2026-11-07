"""Offline tests for fixed bootstrap, collision handling and the Nix entry point."""
import importlib.util
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location("bootstrap", ROOT / "scripts/bootstrap-plugins.py")
bootstrap = importlib.util.module_from_spec(spec)
spec.loader.exec_module(bootstrap)
FISH = shutil.which("fish")


class BootstrapTests(unittest.TestCase):
    @unittest.skipUnless(FISH, "fish required")
    def test_fisher_state_survives_restart_and_partial_failure_preserves_manifest(self):
        with tempfile.TemporaryDirectory(prefix="fisher state ") as temp:
            base = Path(temp)
            config = base / "config/fish"
            config.mkdir(parents=True)
            manifest = config / "fish_plugins"
            reviewed = "owner/plugin@" + "a" * 40 + "\n"
            manifest.write_text(reviewed)
            source = base / "fisher.fish"
            source.write_text('''function fisher
    if test -e "$FISH_TEST_MARKER"; and not set -q _fisher_plugins[1]
        return 1
    end
    if set -q FISH_TEST_PARTIAL
        set -eU _fisher_plugins
        printf '' > "$__fish_config_dir/fish_plugins"
        return 0
    end
    set -U _fisher_plugins (cat "$__fish_config_dir/fish_plugins")
    touch "$FISH_TEST_MARKER"
end
''')
            env = dict(HOME=str(base), XDG_CONFIG_HOME=str(base / "config"),
                       XDG_DATA_HOME=str(base / "data"), XDG_STATE_HOME=str(base / "state"),
                       XDG_CACHE_HOME=str(base / "cache"), FISH_TEST_MARKER=str(base / "installed"))
            with patch.dict(os.environ, env):
                bootstrap.restore_fisher(source, manifest)
                bootstrap.restore_fisher(source, manifest)
                self.assertIn("_fisher_plugins", (config / "fish_variables").read_text())
                with patch.dict(os.environ, FISH_TEST_PARTIAL="1"):
                    with self.assertRaises(subprocess.CalledProcessError):
                        bootstrap.restore_fisher(source, manifest)
            self.assertEqual(manifest.read_text(), reviewed)

    def test_current_manifests_are_complete_and_pinned(self):
        manager, lock = bootstrap.read_pins(ROOT)
        self.assertEqual(len(manager), 40)
        self.assertIn("lazy.nvim", lock)
        self.assertNotIn("denops.vim", lock)

    def test_unpinned_or_unmapped_plugins_fail_before_any_download(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            (root / "fish").mkdir()
            (root / "nvim/lua/plugins").mkdir(parents=True)
            (root / "fish/fish_plugins").write_text("jorgebucaran/fisher@" + "a" * 40 + "\n")
            (root / "nvim/lua/plugins/lazy-lock.json").write_text(json.dumps({"lazy.nvim": {"commit": "b" * 40}}))
            sources = root / "nvim/plugin-sources.json"
            sources.write_text("{}")
            with self.assertRaisesRegex(ValueError, "match every"):
                bootstrap.read_pins(root)
            sources.write_text('{"lazy.nvim":"folke/lazy.nvim"}')
            (root / "fish/fish_plugins").write_text("jorgebucaran/fisher@main\n")
            with self.assertRaisesRegex(ValueError, "Invalid Fisher"):
                bootstrap.read_pins(root)

    def test_collision_preflight_leaves_all_destinations_untouched(self):
        with tempfile.TemporaryDirectory() as temp:
            config = Path(temp)
            (config / "nvim").mkdir()
            sentinel = config / "nvim/init.lua"
            sentinel.write_text("keep")
            with self.assertRaisesRegex(ValueError, "Existing config"):
                bootstrap.config_links(ROOT, config)
            self.assertFalse((config / "fish").exists())
            self.assertEqual(sentinel.read_text(), "keep")

    def test_checkout_uses_exact_commit_and_preserves_local_changes(self):
        with tempfile.TemporaryDirectory(prefix="pin checkout ") as temp:
            base = Path(temp)
            origin = base / "origin"
            bootstrap.run("git", "init", "--quiet", origin)
            def commit(content):
                (origin / "version").write_text(content)
                bootstrap.git(origin, "add", ".")
                bootstrap.git(origin, "-c", "user.name=Test", "-c", "user.email=test@example.invalid",
                              "commit", "--quiet", "-m", content)
                return bootstrap.git(origin, "rev-parse", "HEAD")
            first = commit("first")
            commit("latest")
            dest = base / "checkout"
            bootstrap.checkout_pin(dest, str(origin), first)
            self.assertEqual((dest / "version").read_text(), "first")
            bootstrap.checkout_pin(dest, str(origin), first)  # idempotent
            (dest / "version").write_text("local changes")
            with self.assertRaisesRegex(ValueError, "Local changes"):
                bootstrap.checkout_pin(dest, str(origin), first)
            self.assertEqual((dest / "version").read_text(), "local changes")


class SetupEntryTests(unittest.TestCase):
    @unittest.skipUnless(FISH, "fish required")
    def test_nix_profile_wins_over_legacy_paths(self):
        with tempfile.TemporaryDirectory(prefix="nix path ") as temp:
            base = Path(temp)
            binary = base / ".nix-profile/bin"
            binary.mkdir(parents=True)
            names = ["go", "python3", "fish", "tmux", "nvim"]
            for name in names:
                executable = binary / name
                executable.write_text("#!/bin/sh\nexit 0\n")
                executable.chmod(0o755)
            result = subprocess.run([FISH, "--no-config", "-c",
                                     'source "$argv[1]"; command -s go python3 fish tmux nvim',
                                     str(ROOT / "fish/config.fish")],
                                    env=dict(os.environ, HOME=str(base), XDG_CONFIG_HOME=str(base / ".config"),
                                             XDG_DATA_HOME=str(base / ".local/share")),
                                    capture_output=True, text=True)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(result.stdout.splitlines(), [str(binary / name) for name in names])

    def test_build_only_never_activates_or_updates_lock(self):
        with tempfile.TemporaryDirectory(prefix="nix entry ") as temp:
            base = Path(temp)
            binary = base / "bin"
            binary.mkdir()
            log = base / "calls"
            nix = binary / "nix"
            nix.write_text('''#!/usr/bin/env bash
printf '%s\\n' "$*" >> "$NIX_TEST_LOG"
if [[ $1 != build ]]; then exit 90; fi
for ((i=1; i<=$#; i++)); do
  if [[ ${!i} == --out-link ]]; then
    ((i+=1)); ln -s /nix/store/test-generation "${!i}"; break
  fi
done
''')
            nix.chmod(0o755)
            result = subprocess.run(["bash", str(ROOT / "scripts/setup-nix.sh"), "work-mac", "--build-only"],
                                    env=dict(os.environ, PATH=str(binary) + os.pathsep + os.environ["PATH"],
                                             NIX_TEST_LOG=str(log)), capture_output=True, text=True)
            self.assertEqual(result.returncode, 0, result.stderr)
            calls = log.read_text().splitlines()
            self.assertEqual(len(calls), 1)
            self.assertIn("--no-update-lock-file", calls[0])
            self.assertIn("--no-write-lock-file", calls[0])
            self.assertIn("#homeConfigurations.work-mac.activationPackage", calls[0])

    @unittest.skipUnless(FISH, "fish required")
    def test_update_nix_remembers_host_and_propagates_failures(self):
        with tempfile.TemporaryDirectory(prefix="nix fish ") as temp:
            base = Path(temp)
            repo = base / "repo"
            source = repo / "fish/conf.d/custom/update-nix.fish"
            source.parent.mkdir(parents=True)
            shutil.copyfile(ROOT / "fish/conf.d/custom/update-nix.fish", source)
            scripts = repo / "scripts"
            scripts.mkdir()
            (scripts / "setup-nix.sh").write_text('printf "%s\\n" "$*"; exit 7\n')
            state = base / "state/dotfiles"
            state.mkdir(parents=True)
            (state / "nix-host").write_text("work-wsl\n")
            env = dict(os.environ, XDG_STATE_HOME=str(base / "state"))
            result = subprocess.run([FISH, "--no-config", "-c", 'source "$argv[1]"; update-nix', str(source)],
                                    env=env, capture_output=True, text=True)
            self.assertEqual(result.returncode, 7, result.stderr)
            self.assertIn("work-wsl --packages-only", result.stdout)
            invalid = subprocess.run([FISH, "--no-config", "-c",
                                      'source "$argv[1]"; update-nix wrong-host', str(source)],
                                     env=env, capture_output=True, text=True)
            self.assertEqual(invalid.returncode, 2)


if __name__ == "__main__":
    unittest.main()
