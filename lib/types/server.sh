# lib/types/server.sh – Express REST API (optionally with WebSocket)
# ───────────────────────────────────────────────────────────────────
# Requires: $NAME, $WS_FLAG, version vars, and common.sh functions.

scaffold_server() {
  mkdir -p src test

  # ── package.json (varies by --ws flag and workspace mode) ───────────
  if _is_workspace; then
    if [[ "$WS_FLAG" == true ]]; then
      cat > package.json << JSON
{
  "name": "$(_pkg_name)",
  "version": "0.1.0",
  "private": true,
  "type": "module",
  "scripts": {
    "build": "tsc",
    "dev": "tsx watch src/index.ts",
    "start": "node dist/index.js",
    "test": "vitest run",
    "test:watch": "vitest",
    "typecheck": "tsc --noEmit",
    "lint": "eslint src/ test/",
    "format": "prettier --write 'src/**/*.ts' 'test/**/*.ts'"
  },
  "dependencies": {
    "express": "$EXPRESS",
    "ws": "$WS_PKG"
  },
  "devDependencies": {
    "@types/express": "$TYPES_EXPRESS",
    "@types/node": "$TYPES_NODE",
    "@types/ws": "$TYPES_WS",
    "tsx": "$TSX",
    "typescript": "$TS",
    "vitest": "$VITEST"
  }
}
JSON
    else
      cat > package.json << JSON
{
  "name": "$(_pkg_name)",
  "version": "0.1.0",
  "private": true,
  "type": "module",
  "scripts": {
    "build": "tsc",
    "dev": "tsx watch src/index.ts",
    "start": "node dist/index.js",
    "test": "vitest run",
    "test:watch": "vitest",
    "typecheck": "tsc --noEmit",
    "lint": "eslint src/ test/",
    "format": "prettier --write 'src/**/*.ts' 'test/**/*.ts'"
  },
  "dependencies": {
    "express": "$EXPRESS"
  },
  "devDependencies": {
    "@types/express": "$TYPES_EXPRESS",
    "@types/node": "$TYPES_NODE",
    "tsx": "$TSX",
    "typescript": "$TS",
    "vitest": "$VITEST"
  }
}
JSON
    fi
  else
    if [[ "$WS_FLAG" == true ]]; then
      cat > package.json << JSON
{
  "name": "$(_pkg_name)",
  "version": "0.1.0",
  "private": true,
  "type": "module",
  "scripts": {
    "build": "tsc",
    "dev": "tsx watch src/index.ts",
    "start": "node dist/index.js",
    "test": "vitest run",
    "test:watch": "vitest",
    "typecheck": "tsc --noEmit",
    "lint": "eslint src/ test/",
    "format": "prettier --write 'src/**/*.ts' 'test/**/*.ts'",
    "prepare": "husky"
  },
  "dependencies": {
    "express": "$EXPRESS",
    "ws": "$WS_PKG"
  },
  "devDependencies": {
    "@eslint/js": "$ESLINT_JS",
    "@types/express": "$TYPES_EXPRESS",
    "@types/node": "$TYPES_NODE",
    "@types/ws": "$TYPES_WS",
    "@typescript-eslint/eslint-plugin": "$TS_ESLINT_PLUGIN",
    "@typescript-eslint/parser": "$TS_ESLINT_PARSER",
    "eslint": "$ESLINT",
    "globals": "$GLOBALS",
    "husky": "$HUSKY",
    "lint-staged": "$LINT_STAGED",
    "prettier": "$PRETTIER",
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
    else
      cat > package.json << JSON
{
  "name": "$(_pkg_name)",
  "version": "0.1.0",
  "private": true,
  "type": "module",
  "scripts": {
    "build": "tsc",
    "dev": "tsx watch src/index.ts",
    "start": "node dist/index.js",
    "test": "vitest run",
    "test:watch": "vitest",
    "typecheck": "tsc --noEmit",
    "lint": "eslint src/ test/",
    "format": "prettier --write 'src/**/*.ts' 'test/**/*.ts'",
    "prepare": "husky"
  },
  "dependencies": {
    "express": "$EXPRESS"
  },
  "devDependencies": {
    "@eslint/js": "$ESLINT_JS",
    "@types/express": "$TYPES_EXPRESS",
    "@types/node": "$TYPES_NODE",
    "@typescript-eslint/eslint-plugin": "$TS_ESLINT_PLUGIN",
    "@typescript-eslint/parser": "$TS_ESLINT_PARSER",
    "eslint": "$ESLINT",
    "globals": "$GLOBALS",
    "husky": "$HUSKY",
    "lint-staged": "$LINT_STAGED",
    "prettier": "$PRETTIER",
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
    fi
  fi

  # ── tsconfig.json ───────────────────────────────────────────────────
  write_tsconfig_node

  # ── src/app.ts ──────────────────────────────────────────────────────
  cat > src/app.ts << 'TS'
import express from 'express';

const app = express();

app.use(express.json());

app.get('/api/health', (_req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

export { app };
TS

  # ── src/index.ts (varies by --ws flag) ──────────────────────────────
  if [[ "$WS_FLAG" == true ]]; then
    cat > src/index.ts << 'TS'
import { createServer } from 'node:http';
import { app } from './app.js';
import { createWebSocketServer } from './ws.js';

const PORT = Number(process.env.PORT) || 3000;
const server = createServer(app);

createWebSocketServer(server);

server.listen(PORT, () => {
  console.log(`Server listening on http://localhost:${PORT}`);
  console.log(`WebSocket available at ws://localhost:${PORT}/ws`);
});
TS

    cat > src/ws.ts << 'TS'
import { WebSocketServer } from 'ws';
import type { Server } from 'node:http';

export function createWebSocketServer(server: Server) {
  const wss = new WebSocketServer({ server, path: '/ws' });

  wss.on('connection', (ws) => {
    console.log('Client connected');

    ws.on('message', (data) => {
      const message = data.toString();
      console.log('Received:', message);
      ws.send(JSON.stringify({ echo: message }));
    });

    ws.on('close', () => {
      console.log('Client disconnected');
    });
  });

  return wss;
}
TS
  else
    cat > src/index.ts << 'TS'
import { app } from './app.js';

const PORT = Number(process.env.PORT) || 3000;

app.listen(PORT, () => {
  console.log(`Server listening on http://localhost:${PORT}`);
});
TS
  fi

  # ── Shared configs ──────────────────────────────────────────────────
  write_vitest_node

  if _is_workspace; then
    write_eslint_reexport
  else
    write_eslint_node
    write_prettierrc
    write_gitignore
  fi

  if [[ "$WS_FLAG" == true ]]; then
    write_readme "A TypeScript REST API server with WebSocket support"
  else
    write_readme "A TypeScript REST API server"
  fi

  # ── Test ────────────────────────────────────────────────────────────
  cat > test/health.test.ts << 'TS'
import { describe, it, expect, beforeAll, afterAll } from 'vitest';
import type { AddressInfo } from 'node:net';
import type { Server } from 'node:http';
import { app } from '../src/app.js';

let server: Server;
let baseUrl: string;

beforeAll(
  () =>
    new Promise<void>((resolve) => {
      server = app.listen(0, () => {
        const { port } = server.address() as AddressInfo;
        baseUrl = `http://localhost:${port}`;
        resolve();
      });
    }),
);

afterAll(
  () =>
    new Promise<void>((resolve) => {
      server.close(() => resolve());
    }),
);

describe('GET /api/health', () => {
  it('returns status ok', async () => {
    const res = await fetch(`${baseUrl}/api/health`);
    expect(res.status).toBe(200);
    const body = await res.json();
    expect(body.status).toBe('ok');
  });
});
TS
}
