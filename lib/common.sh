# lib/common.sh – Shared file writers
# ────────────────────────────────────
# Functions that generate config files reused across project types.
# Requires: $NAME (project name) and version variables from versions.sh.

# ── Workspace mode helpers ──────────────────────────────────────────
SCAFFOLD_MODE="${SCAFFOLD_MODE:-standalone}"
PKG_JSON_NAME="${PKG_JSON_NAME:-}"

_pkg_name() { echo "${PKG_JSON_NAME:-$NAME}"; }
_is_workspace() { [[ "$SCAFFOLD_MODE" == "workspace" ]]; }

write_prettierrc() {
  cat > .prettierrc << 'JSON'
{
  "singleQuote": true,
  "trailingComma": "all",
  "printWidth": 100,
  "semi": true
}
JSON
}

write_gitignore() {
  cat > .gitignore << 'TXT'
node_modules/
dist/
*.tsbuildinfo
.env
.env.local
coverage/
TXT
}

write_readme() {
  local desc="$1"
  cat > README.md << MD
# $NAME

> $desc

## Getting started

\`\`\`sh
npm install
npm run dev
npm test
\`\`\`
MD
}

write_eslint_node() {
  cat > eslint.config.js << 'JS'
import js from '@eslint/js';
import tsPlugin from '@typescript-eslint/eslint-plugin';
import tsParser from '@typescript-eslint/parser';
import globals from 'globals';

/** @type {import('eslint').Linter.Config[]} */
export default [
  js.configs.recommended,
  { ignores: ['dist/**', 'node_modules/**'] },
  {
    files: ['src/**/*.ts', 'test/**/*.ts'],
    languageOptions: {
      parser: tsParser,
      parserOptions: { ecmaVersion: 'latest', sourceType: 'module' },
      globals: { ...globals.node },
    },
    plugins: { '@typescript-eslint': tsPlugin },
    rules: {
      ...tsPlugin.configs.recommended.rules,
      '@typescript-eslint/no-unused-vars': ['warn', { argsIgnorePattern: '^_' }],
      'no-unused-vars': 'off',
    },
  },
];
JS
}

write_eslint_react() {
  cat > eslint.config.js << 'JS'
import js from '@eslint/js';
import tsPlugin from '@typescript-eslint/eslint-plugin';
import tsParser from '@typescript-eslint/parser';
import reactHooks from 'eslint-plugin-react-hooks';
import reactRefresh from 'eslint-plugin-react-refresh';
import globals from 'globals';

/** @type {import('eslint').Linter.Config[]} */
export default [
  js.configs.recommended,
  { ignores: ['dist/**', 'node_modules/**'] },
  {
    files: ['src/**/*.{ts,tsx}', 'test/**/*.{ts,tsx}'],
    languageOptions: {
      parser: tsParser,
      parserOptions: {
        ecmaVersion: 'latest',
        sourceType: 'module',
        ecmaFeatures: { jsx: true },
      },
      globals: { ...globals.browser },
    },
    plugins: {
      '@typescript-eslint': tsPlugin,
      'react-hooks': reactHooks,
      'react-refresh': reactRefresh,
    },
    rules: {
      ...tsPlugin.configs.recommended.rules,
      ...reactHooks.configs.recommended.rules,
      'react-refresh/only-export-components': ['warn', { allowConstantExport: true }],
      '@typescript-eslint/no-unused-vars': ['warn', { argsIgnorePattern: '^_' }],
      'no-unused-vars': 'off',
    },
  },
];
JS
}

write_vitest_node() {
  cat > vitest.config.ts << 'TS'
import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    globals: true,
    environment: 'node',
    include: ['test/**/*.test.ts'],
    coverage: { provider: 'v8', include: ['src/**'] },
  },
});
TS
}

write_tsconfig_node() {
  if _is_workspace; then
    cat > tsconfig.json << 'JSON'
{
  "extends": "../../tsconfig.base.json",
  "compilerOptions": {
    "module": "Node16",
    "moduleResolution": "Node16",
    "lib": ["ES2022"],
    "outDir": "./dist",
    "rootDir": "./src"
  },
  "include": ["src/**/*.ts"]
}
JSON
  else
    cat > tsconfig.json << 'JSON'
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "Node16",
    "moduleResolution": "Node16",
    "lib": ["ES2022"],
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true,
    "isolatedModules": true,
    "outDir": "./dist",
    "rootDir": "./src"
  },
  "include": ["src/**/*.ts"]
}
JSON
  fi
}

write_tsconfig_base() {
  cat > tsconfig.base.json << 'JSON'
{
  "compilerOptions": {
    "target": "ES2022",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "isolatedModules": true,
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true
  }
}
JSON
}

write_turbo_json() {
  cat > turbo.json << 'JSON'
{
  "$schema": "https://turbo.build/schema.json",
  "tasks": {
    "build": {
      "dependsOn": ["^build"],
      "outputs": ["dist/**"]
    },
    "dev": {
      "cache": false,
      "persistent": true
    },
    "test": {
      "dependsOn": ["build"]
    },
    "lint": {}
  }
}
JSON
}

write_eslint_reexport() {
  cat > eslint.config.js << 'JS'
export { default } from '../../eslint.config.js';
JS
}

# Shared post-scaffold steps: npm install, git init, husky
finish_scaffold() {
  info "Installing dependencies …"
  npm install

  info "Initialising git …"
  git init -q
  npx husky init

  cat > .husky/pre-commit << 'SH'
npx lint-staged
SH
}
