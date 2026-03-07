# lib/types/monorepo.sh – Multi-package workspace
# ─────────────────────────────────────────────────
# Requires: $NAME, $PACKAGES_SPEC, version vars, and common.sh functions.

scaffold_monorepo() {
  local workspace_name="$NAME"

  # ── Parse package specs ──────────────────────────────────────────────
  local pkg_names=()
  local pkg_types=()
  local pkg_ws_flags=()

  IFS=',' read -ra SPECS <<< "$PACKAGES_SPEC"
  for spec in "${SPECS[@]}"; do
    IFS=':' read -ra PARTS <<< "$spec"
    local pname="${PARTS[0]}"
    local ptype="${PARTS[1]:-}"
    local pws="${PARTS[2]:-}"

    [[ -z "$pname" || -z "$ptype" ]] && die "Invalid package spec: $spec (expected name:type)"
    [[ "$pname" =~ ^[a-z0-9_-]+$ ]]       || die "Package name '$pname' must be lowercase alphanumeric (- or _ allowed)"
    [[ "$ptype" =~ ^(package|spa|cli|server)$ ]] || die "Invalid type '$ptype' in package spec: $spec"

    if [[ "$pws" == "ws" ]]; then
      pws=true
    else
      pws=false
    fi

    [[ "$pws" == true && "$ptype" != "server" ]] && die "ws modifier in '$spec' is only valid with server type"

    pkg_names+=("$pname")
    pkg_types+=("$ptype")
    pkg_ws_flags+=("$pws")
  done

  # ── Root package.json ────────────────────────────────────────────────
  local npm_version
  npm_version=$(npm -v 2>/dev/null || echo "10.0.0")

  cat > package.json << JSON
{
  "name": "$workspace_name",
  "version": "0.0.0",
  "private": true,
  "type": "module",
  "packageManager": "npm@${npm_version}",
  "workspaces": ["packages/*"],
  "scripts": {
    "build": "turbo build",
    "dev": "turbo dev",
    "test": "turbo test",
    "typecheck": "turbo typecheck",
    "lint": "turbo lint",
    "format": "prettier --write 'packages/*/src/**/*.{ts,tsx}' 'packages/*/test/**/*.{ts,tsx}'",
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
    "turbo": "$TURBO"
  },
  "lint-staged": {
    "*.{ts,tsx}": ["eslint --fix", "prettier --write"],
    "*.json": ["prettier --write"]
  }
}
JSON

  # ── Root configs ─────────────────────────────────────────────────────
  write_tsconfig_base
  write_turbo_json
  write_eslint_node
  write_prettierrc
  write_gitignore

  # Extend gitignore for turbo
  echo ".turbo/" >> .gitignore

  # Root README listing all packages
  local pkg_table=""
  for i in "${!pkg_names[@]}"; do
    pkg_table="${pkg_table}| \`${pkg_names[$i]}\` | ${pkg_types[$i]} |"$'\n'
  done

  cat > README.md << MD
# $workspace_name

> A TypeScript monorepo

## Packages

| Package | Type |
|---|---|
${pkg_table}
## Getting started

\`\`\`sh
npm install
npm run build
npm run dev
npm test
\`\`\`

## Scripts

| Command | Description |
|---|---|
| \`npm run build\` | Build all packages |
| \`npm run dev\` | Start all packages in dev mode |
| \`npm test\` | Run all tests |
| \`npm run lint\` | Lint all packages |
| \`npm run format\` | Format all code |
MD

  # ── Scaffold each package ────────────────────────────────────────────
  mkdir -p packages

  SCAFFOLD_MODE="workspace"

  for i in "${!pkg_names[@]}"; do
    local pname="${pkg_names[$i]}"
    local ptype="${pkg_types[$i]}"
    local pws="${pkg_ws_flags[$i]}"

    info "Creating package: $pname ($ptype)"

    mkdir -p "packages/$pname"
    pushd "packages/$pname" > /dev/null

    # Override globals for the type script
    local saved_name="$NAME"
    local saved_ws="$WS_FLAG"
    NAME="$pname"
    PKG_JSON_NAME="@${SCOPE:-${workspace_name}}/${pname}"
    WS_FLAG="$pws"

    "scaffold_${ptype}"

    # Restore globals
    NAME="$saved_name"
    WS_FLAG="$saved_ws"
    PKG_JSON_NAME=""

    popd > /dev/null
  done

  SCAFFOLD_MODE="standalone"
}
