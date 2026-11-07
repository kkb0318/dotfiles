const { test } = require('node:test');
const assert = require('node:assert/strict');
const { check, retry } = require('../.github/scripts/nix-cooldown.cjs');

const start = Date.parse('2026-11-01T00:00:00Z');
const day = 86400000;
function fixture() {
  const state = {
    pr: { number: 1, head: { sha: 'current' }, changed_files: 1 },
    files: [{ filename: 'home-manager/flake.lock' }],
    run: { id: 10, created_at: new Date(start).toISOString(), status: 'completed',
      conclusion: 'failure', pull_requests: [{ number: 1 }] },
    jobs: [{ name: 'Nix cooldown', id: 20, conclusion: 'failure' }],
    failures: [], retries: [], warnings: [],
  };
  const pulls = { get: async () => ({ data: state.pr }), listFiles() {}, list() {} };
  const actions = {
    getWorkflowRun: async () => ({ data: state.run }),
    listWorkflowRuns: async args => {
      assert.equal(args.head_sha, state.pr.head.sha);
      assert.equal(args.workflow_id, 'nix-check.yml');
      return { data: { workflow_runs: [state.run] } };
    },
    listJobsForWorkflowRun() {},
    reRunJobForWorkflowRun: async args => state.retries.push(args.job_id),
  };
  const github = {
    rest: { pulls, actions },
    paginate: async method => {
      if (method === pulls.listFiles) return state.files;
      if (method === pulls.list) return [state.pr];
      if (method === actions.listJobsForWorkflowRun) return state.jobs;
      throw Error('Unexpected API');
    },
  };
  const summary = { addHeading() { return this; }, addRaw() { return this; }, async write() {} };
  return { state, github,
    context: { eventName: 'pull_request', repo: { owner: 'test', repo: 'test' },
      payload: { pull_request: { number: 1, head: { sha: 'current' } } }, runId: 10 },
    core: { info() {}, summary, setFailed: x => state.failures.push(x),
      warning: x => state.warnings.push(x) }, now: start + 3 * day,
  };
}

test('holds a recent revision and accepts exactly 72 hours on rerun', async () => {
  const f = fixture();
  await check({ ...f, now: f.now - 1 });
  assert.equal(f.state.failures.length, 1);
  f.state.failures = [];
  await check(f);
  assert.equal(f.state.failures.length, 0);
});

test('new revision resets wait even if old PR has existed for months', async () => {
  const f = fixture();
  f.state.run.created_at = new Date(f.now).toISOString();
  await check(f);
  assert.equal(f.state.failures.length, 1);
});

test('stale head and unknown observation time fail closed', async () => {
  const f = fixture();
  f.state.pr.head.sha = 'new-head';
  await assert.rejects(check(f), /Stale/);
  f.state.pr.head.sha = 'current';
  f.state.run.created_at = undefined;
  await assert.rejects(check(f), /invalid CI observation/);
});

test('other dependencies have no added cooldown; renamed flakes are covered', async () => {
  const f = fixture();
  f.state.files = [{ filename: 'package-lock.json' }];
  await check({ ...f, now: start });
  assert.equal(f.state.failures.length, 0);
  f.state.files[0].previous_filename = 'home-manager/flake.nix';
  await check({ ...f, now: start });
  assert.equal(f.state.failures.length, 1);
});

test('oversized PR cannot bypass file detection', async () => {
  const f = fixture();
  f.state.pr.changed_files = 3001;
  await assert.rejects(check(f), /too large/);
});

test('scheduled retry waits for maturity and reruns gate with dependent builds', async () => {
  const f = fixture();
  await retry({ ...f, now: f.now - 1 });
  assert.deepEqual(f.state.retries, []);
  await retry(f);
  assert.deepEqual(f.state.retries, [20]);
});

test('scheduler does not retry build failures, running jobs, or another PR', async () => {
  const f = fixture();
  f.state.jobs[0].conclusion = 'success';
  await retry(f);
  f.state.jobs[0].conclusion = 'failure';
  f.state.run.status = 'in_progress';
  await retry(f);
  f.state.run.status = 'completed';
  f.state.run.pull_requests = [{ number: 2 }];
  await retry(f);
  assert.deepEqual(f.state.retries, []);
});

test('expired runs warn instead of attempting unsupported reruns', async () => {
  const f = fixture();
  await retry({ ...f, now: start + 31 * day });
  assert.equal(f.state.warnings.length, 1);
  assert.deepEqual(f.state.retries, []);
});

test('GitHub API failure propagates instead of approving a revision', async () => {
  const f = fixture();
  f.github.rest.actions.getWorkflowRun = async () => { throw Error('API unavailable'); };
  await assert.rejects(check(f), /API unavailable/);
});
