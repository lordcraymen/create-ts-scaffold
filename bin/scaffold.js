#!/usr/bin/env node
// bin/scaffold.js – Thin Node wrapper that invokes scaffold.sh via bash.
// This exists because npm on Windows can't directly execute .sh files as bin entries.

import { execFileSync } from 'node:child_process';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const script = resolve(__dirname, '..', 'scaffold.sh');
const args = process.argv.slice(2);

// Find bash: Git Bash on Windows, regular bash elsewhere
function findBash() {
  if (process.platform !== 'win32') return 'bash';

  const candidates = [
    resolve(process.env.ProgramFiles || 'C:\\Program Files', 'Git', 'bin', 'bash.exe'),
    resolve(
      process.env['ProgramFiles(x86)'] || 'C:\\Program Files (x86)',
      'Git',
      'bin',
      'bash.exe',
    ),
    'bash', // fallback: hope it's on PATH (WSL, MSYS2, etc.)
  ];

  for (const candidate of candidates) {
    try {
      execFileSync(candidate, ['--version'], { stdio: 'ignore' });
      return candidate;
    } catch {
      // try next
    }
  }

  console.error('✗ bash not found. Please install Git for Windows: https://git-scm.com');
  process.exit(1);
}

try {
  execFileSync(findBash(), [script, ...args], {
    stdio: 'inherit',
    cwd: process.cwd(),
  });
} catch (err) {
  process.exit(err.status ?? 1);
}
