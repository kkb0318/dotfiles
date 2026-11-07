"""Exercise update without touching installed packages or using the network."""
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]
FISH = shutil.which("fish")
NVIM = shutil.which("nvim")
PIN = "owner/plugin@" + "a" * 40


@unittest.skipUnless(FISH, "fish is required")
class UpdateTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="update test ")
        self.addCleanup(self.temp.cleanup)
        self.base = Path(self.temp.name).resolve()
        self.repo = self.base / "dotfiles"
        self.script = self.repo / "fish/conf.d/custom/update.fish"
        self.script.parent.mkdir(parents=True)
        shutil.copyfile(ROOT / "fish/conf.d/custom/update.fish", self.script)
        (self.repo / "nvim/lua/plugins").mkdir(parents=True)
        (self.repo / "nvim/lua/plugins/lazy-lock.json").write_text("{}\n")
        self.manifest = self.repo / "fish/fish_plugins"
        self.manifest.write_text(PIN + "\n")
        config = self.base / "config"
        config.mkdir()
        (config / "fish").symlink_to(self.repo / "fish", target_is_directory=True)
        self.bin = self.base / "bin"
        self.bin.mkdir()
        self.log = self.base / "calls.jsonl"
        for name in ["aqua", "nvim", "brew", "kubectl", "rustup", "cargo", "go", "volta", "pyenv", "bash"]:
            executable = self.bin / name
            executable.write_text(f"#!{sys.executable}\n" + '''import json, os, sys
from pathlib import Path
name = Path(sys.argv[0]).name
with open(os.environ["UPDATE_TEST_LOG"], "a") as log:
    log.write(json.dumps({"name": name, "args": sys.argv[1:],
        "checksum": os.environ.get("AQUA_ENFORCE_CHECKSUM"),
        "require_checksum": os.environ.get("AQUA_ENFORCE_REQUIRE_CHECKSUM"),
        "root": os.environ.get("DOTFILES_UPDATE_ROOT")}) + "\\n")
sys.exit(1 if name in os.environ.get("UPDATE_TEST_FAIL", "").split(",") else 0)
''')
            executable.chmod(0o755)
        self.env = dict(os.environ, PATH=str(self.bin), XDG_CONFIG_HOME=str(config),
                        XDG_DATA_HOME=str(self.base / "data"), XDG_CACHE_HOME=str(self.base / "cache"),
                        UPDATE_TEST_LOG=str(self.log))

    def run_update(self, args=(), mode="success", prelude="", script=None):
        self.env["UPDATE_TEST_MODE"] = mode
        code = '''
function fisher
    printf 'fisher\\n' >> "$UPDATE_TEST_LOG.fisher"
    switch $UPDATE_TEST_MODE
        case failure
            return 1
        case partial
            printf '' > "$__fish_config_dir/fish_plugins"
            return 0
        case '*'
            set -g _fisher_plugins
            while read -l plugin
                set -ga _fisher_plugins "$plugin"
            end < "$__fish_config_dir/fish_plugins"
            return 0
    end
end
source "$argv[1]"
''' + prelude + '\nupdate $argv[2..-1]\n'
        return subprocess.run([FISH, "--no-config", "-c", code, str(script or self.script), *args],
                              env=self.env, cwd=self.base, text=True, capture_output=True, timeout=20)

    def calls(self):
        return [json.loads(line) for line in self.log.read_text().splitlines()] if self.log.exists() else []

    def test_apply_uses_explicit_pins_and_never_calls_held_managers(self):
        result = self.run_update()
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        nvim, = self.calls()
        self.assertEqual(nvim["name"], "nvim")
        self.assertEqual(nvim["root"], str(self.repo))
        self.assertIn("NONE", nvim["args"])
        self.assertIn("Held:", result.stdout)

    def test_dry_run_does_not_call_any_updater(self):
        result = self.run_update(["--dry-run"])
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.calls(), [])
        self.assertFalse(Path(str(self.log) + ".fisher").exists())

    def test_all_failures_are_reported_and_remaining_managers_run(self):
        self.env["UPDATE_TEST_FAIL"] = "nvim"
        result = self.run_update(mode="failure")
        self.assertEqual(result.returncode, 1, result.stdout + result.stderr)
        for name in ["Fisher", "Neovim"]:
            self.assertIn("Failed: " + name, result.stdout)
        self.assertEqual(len(self.calls()), 1)

    def test_fisher_false_success_preserves_manifest_and_fails(self):
        result = self.run_update(mode="partial")
        self.assertEqual(result.returncode, 1, result.stdout + result.stderr)
        self.assertEqual(self.manifest.read_text(), PIN + "\n")
        self.assertIn("Failed: Fisher", result.stdout)

    def test_fisher_rejects_unpinned_tags_and_empty_files(self):
        for value in ["owner/plugin", "owner/plugin@v1.0.0", "owner/plugin@main", ""]:
            with self.subTest(value=value):
                self.manifest.write_text(value + "\n")
                result = self.run_update()
                self.assertEqual(result.returncode, 1, result.stdout + result.stderr)
                self.assertFalse(Path(str(self.log) + ".fisher").exists())

    def test_existing_fisher_pins_are_not_downloaded_again(self):
        result = self.run_update(prelude="set -g _fisher_plugins " + PIN)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertFalse(Path(str(self.log) + ".fisher").exists())

    def test_missing_managers_are_explicitly_skipped(self):
        for name in ["nvim"]:
            (self.bin / name).unlink()
        result = self.run_update(prelude="functions -e fisher")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout.count("not installed"), 2)
        self.assertEqual(self.calls(), [])

    def test_source_symlink_and_unrelated_cwd_resolve_repository(self):
        link = self.base / "update.fish"
        link.symlink_to(self.script)
        result = self.run_update(script=link)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertEqual(self.calls()[0]["root"], str(self.repo))

    def test_relative_source_survives_a_later_directory_change(self):
        result = self.run_update(script=self.script.relative_to(self.base), prelude="cd /")
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertEqual(self.calls()[0]["root"], str(self.repo))

    def test_fisher_refuses_an_unrelated_active_manifest(self):
        active = self.base / "config/fish"
        active.unlink()
        active.mkdir()
        (active / "fish_plugins").write_text(PIN + "\n")
        result = self.run_update()
        self.assertEqual(result.returncode, 1, result.stdout + result.stderr)
        self.assertFalse(Path(str(self.log) + ".fisher").exists())

    def test_invalid_arguments_do_not_run_updaters(self):
        for args in [["--latest"], ["anything"]]:
            with self.subTest(args=args):
                self.assertEqual(self.run_update(args).returncode, 2)
                self.assertEqual(self.calls(), [])


@unittest.skipUnless(NVIM, "Neovim is required")
class RestoreLockedTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="lazy restore test ")
        self.addCleanup(self.temp.cleanup)
        self.base = Path(self.temp.name).resolve()
        self.repo = self.base / "repo"
        self.lockfile = self.repo / "nvim/lua/plugins/lazy-lock.json"
        self.lockfile.parent.mkdir(parents=True)
        self.lock = {"lazy.nvim": {"commit": "a" * 40}, "example": {"commit": "b" * 40}}
        self.env = dict(os.environ, DOTFILES_UPDATE_ROOT=str(self.repo),
                        XDG_DATA_HOME=str(self.base / "data"), XDG_CONFIG_HOME=str(self.base / "config"),
                        XDG_STATE_HOME=str(self.base / "state"), XDG_CACHE_HOME=str(self.base / "cache"))
        self.env.pop("NVIM_APPNAME", None)
        self.harness = self.base / "harness.lua"
        self.harness.write_text('''
local fail = vim.env.UPDATE_TEST_FAIL
local root = vim.fn.stdpath("data") .. "/lazy"
for _, name in ipairs({ "lazy.nvim", "example" }) do vim.fn.mkdir(root .. "/" .. name .. "/.git", "p") end
local config = { plugins = {} }
package.loaded["lazy.core.config"] = config
package.loaded["lazy"] = {
  setup = function(specs, opts)
    assert(not opts.install.missing and not opts.pkg.enabled and not opts.rocks.enabled)
    assert(opts.lockfile ~= vim.env.DOTFILES_UPDATE_ROOT .. "/nvim/lua/plugins/lazy-lock.json")
    for _, spec in ipairs(specs) do
      assert(spec.lazy and spec.build == false and spec.init == nil and spec.config == nil)
      config.plugins[spec.name] = { _ = { tasks = {{ has_errors = function() return fail == "task" end }} } }
    end
  end,
  restore = function(opts) assert(opts.wait and opts.show == false) end,
}
vim.fn.system = function(args)
  if args[4] == "remote" then return "https://example.invalid/plugin.git\\n" end
  if fail == "head" then return string.rep("c", 40) end
  return string.rep(args[3]:match("lazy.nvim$") and "a" or "b", 40)
end
dofile(vim.env.UPDATE_TEST_SCRIPT)
''')
        self.env["UPDATE_TEST_SCRIPT"] = str(ROOT / "nvim/scripts/restore-locked.lua")

    def run_restore(self, failure=""):
        self.lockfile.write_text(json.dumps(self.lock) + "\n")
        before = self.lockfile.read_bytes()
        result = subprocess.run([NVIM, "--headless", "-u", "NONE", "-i", "NONE", "-n", "-l", str(self.harness)],
                                env=dict(self.env, UPDATE_TEST_FAIL=failure), text=True, capture_output=True, timeout=20)
        self.assertEqual(self.lockfile.read_bytes(), before)
        return result

    def test_success_preserves_lock_and_disables_implicit_installers(self):
        result = self.run_restore()
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)

    def test_lazy_task_failure_and_commit_mismatch_exit_nonzero(self):
        for failure in ["task", "head"]:
            with self.subTest(failure=failure):
                self.assertNotEqual(self.run_restore(failure).returncode, 0)

    def test_missing_lazy_pin_and_malformed_commits_fail(self):
        for lock in [{"example": {"commit": "b" * 40}}, {"lazy.nvim": {"commit": "main"}}, {}]:
            with self.subTest(lock=lock):
                self.lock = lock
                self.assertNotEqual(self.run_restore().returncode, 0)


LAZY_SOURCE = Path(os.environ.get("XDG_DATA_HOME", str(Path.home() / ".local/share"))) / "nvim/lazy/lazy.nvim"


@unittest.skipUnless(NVIM and shutil.which("git") and (LAZY_SOURCE / ".git").is_dir(), "installed Lazy source required")
class RealLazyTest(unittest.TestCase):
    def test_restore_local_git_repo_without_running_plugin_or_build_hooks(self):
        self.exercise_restore(bootstrap=False)

    def test_bootstrap_missing_plugin_from_lock_without_hooks(self):
        self.exercise_restore(bootstrap=True)

    def exercise_restore(self, bootstrap):
        with tempfile.TemporaryDirectory(prefix="lazy integration ") as tmp:
            base = Path(tmp).resolve()
            repo = base / "repo"
            plugins = base / "data/nvim/lazy"
            plugins.mkdir(parents=True)
            env = dict(os.environ, XDG_CONFIG_HOME=str(base / "config"), XDG_DATA_HOME=str(base / "data"),
                       XDG_STATE_HOME=str(base / "state"), XDG_CACHE_HOME=str(base / "cache"),
                       DOTFILES_UPDATE_ROOT=str(repo), GIT_CONFIG_GLOBAL=os.devnull, GIT_CONFIG_NOSYSTEM="1")
            env.pop("NVIM_APPNAME", None)

            def git(*args):
                return subprocess.run(["git", *map(str, args)], env=env, capture_output=True, text=True,
                                      check=True, timeout=20).stdout.strip()

            git("clone", "--quiet", "--no-hardlinks", LAZY_SOURCE, plugins / "lazy.nvim")
            lazy_commit = git("-C", plugins / "lazy.nvim", "rev-parse", "HEAD")
            origin = base / "origin"
            git("init", "--quiet", origin)

            def commit():
                git("-C", origin, "add", ".")
                git("-C", origin, "-c", "user.name=Update Test", "-c", "user.email=update@example.invalid",
                    "commit", "--quiet", "-m", "fixture")
                return git("-C", origin, "rev-parse", "HEAD")

            canary = base / "UNEXPECTED_HOOK"
            hook = 'vim.fn.writefile({"executed"}, ' + json.dumps(str(canary)) + ')'
            (origin / "plugin").mkdir()
            (origin / "plugin/unsafe.lua").write_text(hook)
            (origin / "build.lua").write_text(hook)
            config_plugin = base / "config/nvim/plugin"
            config_plugin.mkdir(parents=True)
            (config_plugin / "unsafe.lua").write_text(hook)
            first = commit()
            (origin / "new.txt").write_text("new")
            commit()
            if not bootstrap:
                git("clone", "--quiet", origin, plugins / "example")
            else:
                # Redirect a reviewed GitHub source to the offline fixture.
                env.update(DOTFILES_BOOTSTRAP_PLUGINS="1", GIT_CONFIG_COUNT="1",
                           GIT_CONFIG_KEY_0="url." + str(origin) + ".insteadOf",
                           GIT_CONFIG_VALUE_0="https://github.com/fixture/example.git")
            lockfile = repo / "nvim/lua/plugins/lazy-lock.json"
            lockfile.parent.mkdir(parents=True)
            lockfile.write_text(json.dumps({"lazy.nvim": {"commit": lazy_commit}, "example": {"commit": first}}) + "\n")
            (repo / "nvim/plugin-sources.json").write_text(json.dumps({
                "lazy.nvim": "folke/lazy.nvim", "example": "fixture/example"}))
            before = lockfile.read_bytes()
            result = subprocess.run([NVIM, "--headless", "-u", "NONE", "-i", "NONE", "-n", "-l",
                                     str(ROOT / "nvim/scripts/restore-locked.lua")], env=env,
                                    capture_output=True, text=True, timeout=45)
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            self.assertEqual(git("-C", plugins / "example", "rev-parse", "HEAD"), first)
            self.assertEqual(lockfile.read_bytes(), before)
            self.assertFalse(canary.exists(), "plugin, config or build hook was executed")


if __name__ == "__main__":
    unittest.main()
