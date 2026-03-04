# lib/helpers.sh – Shared shell helpers
# ──────────────────────────────────────

die()  { echo "✗ $*" >&2; exit 1; }
info() { echo "· $*"; }

usage() {
  cat << 'EOF'
Usage: scaffold.sh <type> <name> [options]

Types:
  package   Publishable npm package (TypeScript + tsup)
  spa       Single Page Application (React + Vite)
  cli       Command-line tool (TypeScript + tsup + commander)
  server    REST API server (Express + TypeScript)

Options:
  --ws      Add WebSocket support (server only)
  -h        Show this help

Examples:
  ./scaffold.sh package my-lib
  ./scaffold.sh spa my-app
  ./scaffold.sh cli my-tool
  ./scaffold.sh server my-api --ws
EOF
  exit 0
}
