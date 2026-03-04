# lib/types/spa.sh – React single-page application
# ──────────────────────────────────────────────────
# Requires: $NAME, version vars, and common.sh functions.

scaffold_spa() {
  mkdir -p src test

  cat > package.json << JSON
{
  "name": "$NAME",
  "version": "0.1.0",
  "private": true,
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "tsc -b && vite build",
    "preview": "vite preview",
    "test": "vitest run",
    "test:watch": "vitest",
    "lint": "eslint src/ test/",
    "format": "prettier --write 'src/**/*.{ts,tsx}' 'test/**/*.{ts,tsx}'",
    "prepare": "husky"
  },
  "dependencies": {
    "react": "$REACT",
    "react-dom": "$REACT_DOM"
  },
  "devDependencies": {
    "@eslint/js": "$ESLINT_JS",
    "@testing-library/jest-dom": "$TESTING_LIB_JEST_DOM",
    "@testing-library/react": "$TESTING_LIB_REACT",
    "@types/react": "$REACT",
    "@types/react-dom": "$REACT_DOM",
    "@typescript-eslint/eslint-plugin": "$TS_ESLINT_PLUGIN",
    "@typescript-eslint/parser": "$TS_ESLINT_PARSER",
    "@vitejs/plugin-react": "$VITE_REACT",
    "eslint": "$ESLINT",
    "eslint-plugin-react-hooks": "$ESLINT_REACT_HOOKS",
    "eslint-plugin-react-refresh": "$ESLINT_REACT_REFRESH",
    "globals": "$GLOBALS",
    "husky": "$HUSKY",
    "jsdom": "$JSDOM",
    "lint-staged": "$LINT_STAGED",
    "prettier": "$PRETTIER",
    "typescript": "$TS",
    "vite": "$VITE",
    "vitest": "$VITEST"
  },
  "lint-staged": {
    "*.{ts,tsx}": ["eslint --fix", "prettier --write"],
    "*.json": ["prettier --write"]
  }
}
JSON

  cat > tsconfig.json << 'JSON'
{
  "compilerOptions": {
    "target": "ES2022",
    "lib": ["ES2022", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "moduleResolution": "bundler",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": true,
    "jsx": "react-jsx",
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true
  },
  "include": ["src"],
  "references": [{ "path": "./tsconfig.node.json" }]
}
JSON

  cat > tsconfig.node.json << 'JSON'
{
  "compilerOptions": {
    "target": "ES2022",
    "lib": ["ES2022"],
    "module": "ESNext",
    "moduleResolution": "bundler",
    "strict": true,
    "skipLibCheck": true,
    "composite": true,
    "isolatedModules": true,
    "outDir": "./dist-node",
    "declaration": true
  },
  "include": ["vite.config.ts", "vitest.config.ts"]
}
JSON

  cat > vite.config.ts << 'TS'
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  server: { port: 5173 },
});
TS

  cat > vitest.config.ts << 'TS'
import { defineConfig } from 'vitest/config';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  test: {
    globals: true,
    environment: 'jsdom',
    include: ['test/**/*.test.{ts,tsx}'],
    setupFiles: ['./test/setup.ts'],
    coverage: {
      provider: 'v8',
      include: ['src/**'],
      exclude: ['src/vite-env.d.ts'],
    },
  },
});
TS

  write_eslint_react
  write_prettierrc
  write_gitignore
  write_readme "A React single-page application"

  cat > index.html << HTML
<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>${NAME}</title>
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.tsx"></script>
  </body>
</html>
HTML

  cat > src/main.tsx << 'TSX'
import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';
import { App } from './App';
import './index.css';

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <App />
  </StrictMode>,
);
TSX

  cat > src/App.tsx << 'TSX'
export function App() {
  return <h1>Hello</h1>;
}
TSX

  cat > src/index.css << 'CSS'
*,
*::before,
*::after {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  font-family: system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
  min-height: 100vh;
}

#root {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
}
CSS

  cat > src/vite-env.d.ts << 'TS'
/// <reference types="vite/client" />
TS

  cat > test/setup.ts << 'TS'
import '@testing-library/jest-dom/vitest';
TS

  cat > test/App.test.tsx << 'TSX'
import { render, screen } from '@testing-library/react';
import { describe, it, expect } from 'vitest';
import { App } from '../src/App';

describe('App', () => {
  it('renders', () => {
    render(<App />);
    expect(screen.getByText(/hello/i)).toBeInTheDocument();
  });
});
TSX
}
