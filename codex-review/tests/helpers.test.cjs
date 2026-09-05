const { test } = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');
const { spawnSync } = require('node:child_process');

const codexHelper = path.resolve(__dirname, '../scripts/codex-review');
const dualHelper = path.resolve(__dirname, '../../llm-review/scripts/llm-review.sh');

function fixture(t) {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), 'review-contract-'));
  t.after(() => fs.rmSync(root, { recursive: true, force: true }));
  const bin = path.join(root, 'bin');
  const repo = path.join(root, 'repo');
  fs.mkdirSync(bin);
  fs.mkdirSync(repo);
  for (const name of ['codex', 'claude']) {
    fs.writeFileSync(path.join(bin, name), `#!/usr/bin/env bash
[[ "$AGENT_REVIEW_ACTIVE" == 1 ]] || exit 91
if [[ -n "\${NEST_HELPER:-}" ]]; then exec bash "$NEST_HELPER" --mode local; fi
if [[ "${name}" == claude ]]; then cat >/dev/null; fi
printf '%s' "\${${name.toUpperCase()}_TEXT:-}"
exit "\${${name.toUpperCase()}_RC:-0}"
`, { mode: 0o755 });
  }
  fs.writeFileSync(path.join(bin, 'gh'), '#!/bin/sh\nexit 1\n', { mode: 0o755 });
  function git(...args) {
    const r = spawnSync('git', args, { cwd: repo, encoding: 'utf8' });
    assert.equal(r.status, 0, r.stderr);
    return r.stdout.trim();
  }
  git('init', '-q');
  fs.writeFileSync(path.join(repo, 'file.txt'), 'before\n');
  git('add', 'file.txt');
  git('-c', 'user.name=Test', '-c', 'user.email=test@example.invalid',
    '-c', 'commit.gpgsign=false', '-c', 'core.hooksPath=/dev/null',
    'commit', '-qm', 'test: seed isolated review fixture');
  fs.writeFileSync(path.join(repo, 'file.txt'), 'after\n');
  function run(helper, args = [], extra = {}) {
    const env = { ...process.env, PATH: `${bin}:${process.env.PATH}`,
      AGENT_REVIEW_ACTIVE: '', CODEX_REVIEW_OUTPUT: '', CODEX_BIN: path.join(bin, 'codex'),
      CODEX_TEXT: 'No actionable findings after reviewing the patch.\n',
      CLAUDE_TEXT: 'Verdict: ship\n', CODEX_RC: '0', CLAUDE_RC: '0', NEST_HELPER: '', ...extra };
    const r = spawnSync('bash', [helper, ...args], { cwd: repo, env, encoding: 'utf8', timeout: 10000 });
    assert.ifError(r.error);
    return { ...r, text: r.stdout + r.stderr };
  }
  return { run, root, git };
}

test('diagnostic-only output is never automatically clean', t => {
  const { run } = fixture(t);
  const r = run(codexHelper, ['--mode', 'local'], {
    CODEX_TEXT: 'Review could not complete because the service was unavailable.\n' });
  assert.equal(r.status, 0); // process success only; semantic triage remains explicit
  assert.match(r.text, /verdict: untriaged/);
  assert.doesNotMatch(r.text, /codex-review clean:/);
});
test('reported markers are not labeled accepted findings', t => {
  const { run } = fixture(t);
  const r = run(codexHelper, ['--mode', 'local'], { CODEX_TEXT: '[P1] Race in cleanup\n' });
  assert.equal(r.status, 1);
  assert.match(r.text, /severity markers reported/);
  assert.doesNotMatch(r.text, /accepted\/actionable findings reported/);
});
test('empty output and process failure are incomplete', t => {
  const { run } = fixture(t);
  for (const extra of [{ CODEX_TEXT: ' \n' }, { CODEX_RC: '47' }]) {
    const r = run(codexHelper, ['--mode', 'local'], extra);
    assert.equal(r.status, 2);
    assert.match(r.text, /incomplete/);
  }
});
test('both helpers reject inherited nesting; child inherits the guard', t => {
  const { run } = fixture(t);
  for (const helper of [codexHelper, dualHelper]) {
    const r = run(helper, [], { AGENT_REVIEW_ACTIVE: '1' });
    assert.equal(r.status, 2);
    assert.match(r.text, /nested review helper invocation refused/);
  }
  const nested = run(codexHelper, ['--mode', 'local'], { NEST_HELPER: codexHelper });
  assert.equal(nested.status, 2);
  assert.match(nested.text, /nested review helper invocation refused/);
});
test('parallel validation failure is not review success', t => {
  const { run } = fixture(t);
  const r = run(codexHelper, ['--mode', 'local', '--parallel-tests', 'exit 7']);
  assert.equal(r.status, 1);
  assert.match(r.text, /tests exit: 7/);
  assert.match(r.text, /validation failed/);
});
test('invalid invocation terminates and output capture is preserved', t => {
  const { run, root } = fixture(t);
  assert.equal(run(codexHelper, ['--base']).status, 2);
  const out = path.join(root, 'evidence.txt');
  const r = run(codexHelper, ['--mode', 'local', '--output', out]);
  assert.equal(r.status, 0);
  assert.match(fs.readFileSync(out, 'utf8'), /No actionable findings/);
});
test('forced committed target is not replaced by dirty work', t => {
  const { run } = fixture(t);
  const r = run(codexHelper, ['--mode', 'branch', '--base', 'HEAD', '--dry-run']);
  assert.equal(r.status, 0);
  assert.match(r.text, /review --base HEAD/);
  assert.doesNotMatch(r.text, /review --uncommitted/);
});
test('dual review preserves partial output and exact failure exit code', t => {
  const { run } = fixture(t);
  for (const provider of ['CODEX', 'CLAUDE']) {
    const r = run(dualHelper, [], { [`${provider}_RC`]: '23', [`${provider}_TEXT`]: 'Partial finding\n' });
    assert.equal(r.status, 2);
    assert.match(r.text, /process exit: 23/);
    assert.match(r.text, /Partial finding/);
    assert.match(r.text, /review incomplete/);
  }
});
test('dual review treats empty output as incomplete and success as untriaged', t => {
  const { run } = fixture(t);
  assert.equal(run(dualHelper, [], { CLAUDE_TEXT: ' \n' }).status, 2);
  const r = run(dualHelper);
  assert.equal(r.status, 0);
  assert.match(r.text, /review verdict: untriaged/);
});
