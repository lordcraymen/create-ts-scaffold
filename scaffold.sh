#!/usr/bin/env bash
#
# scaffold.sh – Quick project scaffolding for TypeScript projects
# ---------------------------------------------------------------
# Creates a ready-to-go TypeScript project with:
#   Vitest · ESLint (flat config) · Prettier · Husky + lint-staged
#
# Types:
#   package   Publishable npm package (tsup, dual ESM/CJS)
#   spa       Single Page Application (React + Vite)
#   cli       Command-line tool (tsup + commander)
#   server    REST API server (Express), --ws for WebSocket support
#   monorepo  Multi-package workspace (Turborepo + npm workspaces)
#
# Usage:
#   ./scaffold.sh <type> <name> [--ws] [--packages name:type,...]
#
# Requires Node.js >= 20. Runs in bash >= 4 / Git Bash on Windows.
set -euo pipefail

# ── Resolve script directory (works with symlinks too) ──────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── Load modules ────────────────────────────────────────────────────────
source "$SCRIPT_DIR/lib/versions.sh"
source "$SCRIPT_DIR/lib/helpers.sh"
source "$SCRIPT_DIR/lib/common.sh"

# ── Parse arguments ─────────────────────────────────────────────────────
[[ "${1:-}" == "-h" || "${1:-}" == "--help" ]] && usage

TYPE="${1:-}"
NAME="${2:-}"
WS_FLAG=false
PACKAGES_SPEC=""

[[ -z "$TYPE" || -z "$NAME" ]] && usage
shift 2

while [[ $# -gt 0 ]]; do
  case "$1" in
    --ws)          WS_FLAG=true; shift ;;
    --packages)    PACKAGES_SPEC="${2:-}"; [[ -z "$PACKAGES_SPEC" ]] && die "--packages requires a value"; shift 2 ;;
    --packages=*)  PACKAGES_SPEC="${1#--packages=}"; shift ;;
    -h|--help)     usage ;;
    *)             die "Unknown option: $1" ;;
  esac
done

# ── Validate ────────────────────────────────────────────────────────────
[[ "$NAME" =~ ^[a-z0-9_-]+$ ]]                      || die "Name must be lowercase alphanumeric (- or _ allowed)"
[[ "$TYPE" =~ ^(package|spa|cli|server|monorepo)$ ]] || die "Unknown type '$TYPE' – use: package, spa, cli, server, monorepo"
[[ "$WS_FLAG" == true && "$TYPE" != "server" ]]      && die "--ws is only valid with the 'server' type"
[[ "$TYPE" == "monorepo" && -z "$PACKAGES_SPEC" ]]   && die "Monorepo requires --packages flag (e.g. --packages api:server,ui:spa)"
[[ "$TYPE" != "monorepo" && -n "$PACKAGES_SPEC" ]]   && die "--packages is only valid with the 'monorepo' type"

NODE_V=$(node -v 2>/dev/null | sed 's/v\([0-9]*\).*/\1/')
[[ -n "$NODE_V" ]] || die "Node.js not found"
(( NODE_V >= NODE_MIN )) || die "Node >= $NODE_MIN required (found v$NODE_V)"
[[ -e "$NAME" ]] && die "Directory '$NAME' already exists"

# ── Load type-specific scaffold function ────────────────────────────────
if [[ "$TYPE" == "monorepo" ]]; then
  for t in package spa cli server; do
    source "$SCRIPT_DIR/lib/types/${t}.sh"
  done
  source "$SCRIPT_DIR/lib/types/monorepo.sh"
else
  source "$SCRIPT_DIR/lib/types/${TYPE}.sh"
fi

# ── Scaffold ────────────────────────────────────────────────────────────
info "Scaffolding $TYPE project: $NAME"
mkdir -p "$NAME"
cd "$NAME"

"scaffold_${TYPE}"
finish_scaffold

# ── Done ────────────────────────────────────────────────────────────────
echo ""
info "✓ $NAME is ready!"
echo ""
echo "  cd $NAME"

case "$TYPE" in
  package)
    echo "  npm run dev        # build in watch mode"
    echo "  npm run build      # build for production (ESM + CJS)"
    echo "  npm test           # run tests"
    ;;
  spa)
    echo "  npm run dev        # start dev server on :5173"
    echo "  npm run build      # build for production"
    echo "  npm run preview    # preview production build"
    echo "  npm test           # run tests"
    ;;
  cli)
    echo "  npm run dev        # run in dev mode"
    echo "  npm run build      # build for production"
    echo "  npx $NAME          # run the CLI"
    echo "  npm test           # run tests"
    ;;
  server)
    echo "  npm run dev        # start with hot reload"
    echo "  npm run build      # compile TypeScript"
    echo "  npm start          # run production build"
    echo "  npm test           # run tests"
    [[ "$WS_FLAG" == true ]] && echo "  WebSocket endpoint: ws://localhost:3000/ws"
    ;;
  monorepo)
    echo "  npm run build      # build all packages"
    echo "  npm run dev        # start all in dev mode"
    echo "  npm test           # run all tests"
    echo "  npm run lint       # lint all packages"
    echo "  npm run format     # format all code"
    ;;
esac

echo ""
echo "  npm run lint       # eslint"
echo "  npm run format     # prettier"
echo ""
