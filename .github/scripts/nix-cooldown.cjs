'use strict';

const WAIT_MS = 3 * 24 * 60 * 60 * 1000;
const isFlake = name => /(^|\/)flake\.(nix|lock)$/.test(name || '');

function deadline(createdAt) {
  const started = Date.parse(createdAt);
  if (!Number.isFinite(started)) throw new Error('Missing or invalid CI observation time');
  return started + WAIT_MS;
}

async function check({ github, context, core, now = Date.now() }) {
  // Push builds validate the merged tree; only PRs have an adoption cooldown.
  if (context.eventName !== 'pull_request') return;
  const repo = context.repo;
  const number = context.payload.pull_request.number;
  const { data: pr } = await github.rest.pulls.get({ ...repo, pull_number: number });
  if (pr.head.sha !== context.payload.pull_request.head.sha) {
    throw new Error('Stale PR revision; use the latest CI run');
  }
  // GitHub limits the files endpoint to 3,000 entries; never silently truncate.
  if (pr.changed_files > 3000) throw new Error('PR too large to inspect safely');
  const files = await github.paginate(github.rest.pulls.listFiles, {
    ...repo, pull_number: number, per_page: 100,
  });
  if (!files.some(file => isFlake(file.filename) || isFlake(file.previous_filename))) {
    core.info('No Flake changes: no Nix cooldown required');
    return;
  }
  const { data: run } = await github.rest.actions.getWorkflowRun({
    ...repo, run_id: context.runId,
  });
  // GitHub's run creation time survives reruns. Git commit dates and lock
  // lastModified are deliberately not used as publication evidence.
  const due = deadline(run.created_at);
  if (now < due) {
    const message = `Nix cooldown: waiting until ${new Date(due).toISOString()}. Daily recheck is automatic; new commits restart the wait.`;
    await core.summary.addHeading('Nix cooldown').addRaw(message).write();
    core.setFailed(message);
    return;
  }
  core.info('Nix cooldown complete; platform builds may proceed');
}

async function retry({ github, context, core, now = Date.now() }) {
  const repo = context.repo;
  const prs = await github.paginate(github.rest.pulls.list, {
    ...repo, state: 'open', per_page: 100,
  });
  for (const pr of prs) {
    const { data } = await github.rest.actions.listWorkflowRuns({
      ...repo, workflow_id: 'nix-check.yml', event: 'pull_request',
      head_sha: pr.head.sha, per_page: 100,
    });
    // Only the newest run for the current PR revision can be retried.
    const run = data.workflow_runs
      .filter(run => run.pull_requests.some(item => item.number === pr.number))
      .sort((a, b) => b.id - a.id)[0];
    if (!run || run.status !== 'completed' || run.conclusion !== 'failure') continue;
    const age = now - Date.parse(run.created_at);
    if (!Number.isFinite(age)) throw new Error(`Invalid run time: ${run.id}`);
    // GitHub permits reruns for 30 days. Report older runs for manual recovery.
    if (age >= 30 * 24 * 60 * 60 * 1000) {
      core.warning(`PR #${pr.number}: CI run expired; push a new revision to restart CI`);
      continue;
    }
    if (now < deadline(run.created_at)) continue;
    const jobs = await github.paginate(github.rest.actions.listJobsForWorkflowRun, {
      ...repo, run_id: run.id, filter: 'latest', per_page: 100,
    });
    const gate = jobs.find(job => job.name === 'Nix cooldown');
    // Build failures are not endlessly retried. Rerunning this job also runs
    // dependent build/aggregate jobs; successful unrelated jobs are untouched.
    if (gate?.conclusion !== 'failure') continue;
    await github.rest.actions.reRunJobForWorkflowRun({ ...repo, job_id: gate.id });
    core.info(`Rechecking Nix cooldown for PR #${pr.number}`);
  }
}

module.exports = { check, retry };
