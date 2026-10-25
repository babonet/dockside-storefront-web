'use strict';

// Runs the checks in smoke.checks.json against a running instance and writes smoke-report.md.
const fs = require('node:fs');
const path = require('node:path');

const baseUrl = process.argv[2] || 'http://localhost:8080';
const checks = JSON.parse(fs.readFileSync(path.join(__dirname, '..', 'smoke.checks.json'), 'utf8'));

async function runCheck(check) {
  const method = check.method || 'GET';
  const expected = check.expectStatus || 200;
  const started = Date.now();
  let status = 0;
  let body = '';
  try {
    const res = await fetch(baseUrl + check.path, {
      method,
      headers: { 'content-type': 'application/json' },
      body: check.body ? JSON.stringify(check.body) : undefined,
    });
    status = res.status;
    body = (await res.text()).slice(0, 200);
  } catch (err) {
    body = err.message;
  }
  return { ...check, method, expected, status, body, ok: status === expected, ms: Date.now() - started };
}

async function main() {
  const results = [];
  for (const check of checks) {
    const result = await runCheck(check);
    results.push(result);
    const verdict = result.ok ? 'PASS' : 'FAIL';
    console.log(`${verdict} ${result.method} ${result.path} -> ${result.status} (expected ${result.expected}, ${result.ms}ms) ${result.ok ? '' : result.body}`);
  }

  const lines = [
    '| Result | Check | Request | Expected | Actual |',
    '|---|---|---|---|---|',
    ...results.map((r) => `| ${r.ok ? 'PASS' : '**FAIL**'} | ${r.name} | \`${r.method} ${r.path}\` | ${r.expected} | ${r.status} |`),
  ];
  fs.writeFileSync('smoke-report.md', `${lines.join('\n')}\n`);

  if (results.some((r) => !r.ok)) process.exit(1);
}

main();
