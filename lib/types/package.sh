# lib/types/package.sh – Publishable npm package
# ────────────────────────────────────────────────
# Requires: $NAME, version vars, and common.sh functions.

scaffold_package() {
  mkdir -p src test

  cat > package.json << JSON
{
  "name": "$NAME",
  "version": "0.1.0",
  "type": "module",
  "exports": {
    ".": {
      "import": { "types": "./dist/index.d.ts", "default": "./dist/index.js" },
      "require": { "types": "./dist/index.d.cts", "default": "./dist/index.cjs" }
    }
  },
  "main": "./dist/index.cjs",
  "module": "./dist/index.js",
  "types": "./dist/index.d.ts",
  "files": ["dist"],
  "scripts": {
    "build": "tsup",
    "dev": "tsup --watch",
    "test": "vitest run",
    "test:watch": "vitest",
    "lint": "eslint src/ test/",
    "format": "prettier --write 'src/**/*.ts' 'test/**/*.ts'",
    "prepublishOnly": "npm run build",
    "prepare": "husky"
  },
  "devDependencies": {
    "@eslint/js": "$ESLINT_JS",
    "@typescript-eslint/eslint-plugin": "$TS_ESLINT_PLUGIN",
    "@typescript-eslint/parser": "$TS_ESLINT_PARSER",
    "eslint": "$ESLINT",
    "globals": "$GLOBALS",
    "husky": "$HUSKY",
    "lint-staged": "$LINT_STAGED",
    "prettier": "$PRETTIER",
    "tsup": "$TSUP",
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
  format: ['esm', 'cjs'],
  dts: true,
  clean: true,
  sourcemap: true,
});
TS

  write_vitest_node
  write_eslint_node
  write_prettierrc
  write_gitignore
  write_readme "A TypeScript npm package"

  cat > src/index.ts << 'TS'
/** Add two numbers. */
export function add(a: number, b: number): number {
  return a + b;
}
TS

  cat > test/index.test.ts << 'TS'
import { describe, it, expect } from 'vitest';
import { add } from '../src/index.js';

describe('add', () => {
  it('adds two numbers', () => {
    expect(add(1, 2)).toBe(3);
  });
});
TS
}
