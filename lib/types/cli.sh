# lib/types/cli.sh – Command-line tool
# ──────────────────────────────────────
# Requires: $NAME, version vars, and common.sh functions.

scaffold_cli() {
  mkdir -p src test

  cat > package.json << JSON
{
  "name": "$NAME",
  "version": "0.1.0",
  "type": "module",
  "bin": { "$NAME": "./dist/index.js" },
  "files": ["dist"],
  "scripts": {
    "build": "tsup",
    "dev": "tsx src/index.ts",
    "test": "vitest run",
    "test:watch": "vitest",
    "lint": "eslint src/ test/",
    "format": "prettier --write 'src/**/*.ts' 'test/**/*.ts'",
    "prepublishOnly": "npm run build",
    "prepare": "husky"
  },
  "dependencies": {
    "commander": "$COMMANDER"
  },
  "devDependencies": {
    "@eslint/js": "$ESLINT_JS",
    "@types/node": "$TYPES_NODE",
    "@typescript-eslint/eslint-plugin": "$TS_ESLINT_PLUGIN",
    "@typescript-eslint/parser": "$TS_ESLINT_PARSER",
    "eslint": "$ESLINT",
    "globals": "$GLOBALS",
    "husky": "$HUSKY",
    "lint-staged": "$LINT_STAGED",
    "prettier": "$PRETTIER",
    "tsup": "$TSUP",
    "tsx": "$TSX",
    "typescript": "$TS",
    "vitest": "$VITEST"
  },
  "lint-staged": {
    "*.ts": ["eslint --fix", "prettier --write"],
    "*.json": ["prettier --write"]
  }
}
JSON

  write_tsconfig_node

  cat > tsup.config.ts << 'TS'
import { defineConfig } from 'tsup';

export default defineConfig({
  entry: ['src/index.ts'],
  format: ['esm'],
  clean: true,
  banner: { js: '#!/usr/bin/env node' },
});
TS

  write_vitest_node
  write_eslint_node
  write_prettierrc
  write_gitignore
  write_readme "A TypeScript CLI tool"

  # src/cli.ts needs $NAME interpolation → unquoted heredoc
  cat > src/cli.ts << TS
import { Command } from 'commander';

export const program = new Command()
  .name('$NAME')
  .description('A CLI tool')
  .version('0.1.0');

program
  .argument('[input]', 'input value')
  .option('-v, --verbose', 'verbose output')
  .action((input: string | undefined, opts: { verbose?: boolean }) => {
    if (opts.verbose) console.log('verbose mode');
    console.log('input:', input ?? '(none)');
  });
TS

  cat > src/index.ts << 'TS'
import { program } from './cli.js';

program.parse();
TS

  # test needs $NAME interpolation → unquoted heredoc
  cat > test/cli.test.ts << TS
import { describe, it, expect } from 'vitest';
import { program } from '../src/cli.js';

describe('cli', () => {
  it('has correct name', () => {
    expect(program.name()).toBe('$NAME');
  });
});
TS
}
