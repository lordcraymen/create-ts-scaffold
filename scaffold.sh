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
#
# Usage:
#   ./scaffold.sh <type> <name> [--ws]
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

[[ -z "$TYPE" || -z "$NAME" ]] && usage
shift 2

for arg in "$@"; do
  case "$arg" in
    --ws)      WS_FLAG=true ;;
    -h|--help) usage ;;
    *)         die "Unknown option: $arg" ;;
  esac
done

# ── Validate ────────────────────────────────────────────────────────────
[[ "$NAME" =~ ^[a-z0-9_-]+$ ]]             || die "Name must be lowercase alphanumeric (- or _ allowed)"
[[ "$TYPE" =~ ^(package|spa|cli|server)$ ]] || die "Unknown type '$TYPE' – use: package, spa, cli, server"
[[ "$WS_FLAG" == true && "$TYPE" != "server" ]] && die "--ws is only valid with the 'server' type"

NODE_V=$(node -v 2>/dev/null | sed 's/v\([0-9]*\).*/\1/')
[[ -n "$NODE_V" ]] || die "Node.js not found"
(( NODE_V >= NODE_MIN )) || die "Node >= $NODE_MIN required (found v$NODE_V)"
[[ -e "$NAME" ]] && die "Directory '$NAME' already exists"

# ── Load type-specific scaffold function ────────────────────────────────
source "$SCRIPT_DIR/lib/types/${TYPE}.sh"

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
esac

echo ""
echo "  npm run lint       # eslint"
echo "  npm run format     # prettier"
echo ""
