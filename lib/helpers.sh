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
  monorepo  Multi-package workspace (Turborepo + npm workspaces)

Options:
  --ws              Add WebSocket support (server only)
  --packages LIST   Comma-separated packages as name:type (monorepo only)
                    Supported types: package, spa, cli, server
                    Append :ws to server for WebSocket support
  -h                Show this help

Examples:
  ./scaffold.sh package my-lib
  ./scaffold.sh spa my-app
  ./scaffold.sh cli my-tool
  ./scaffold.sh server my-api --ws
  ./scaffold.sh monorepo my-workspace --packages api:server,ui:spa,shared:package
  ./scaffold.sh monorepo my-workspace --packages api:server:ws,web:spa,utils:package,tools:cli
EOF
  exit 0
}
