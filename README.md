# create-ts-scaffold

> Quickly scaffold TypeScript projects: npm package, SPA, CLI tool, or REST API server.

One command gives you a fully configured project with **TypeScript**, **Vitest**, **ESLint** (flat config), **Prettier**, and **Husky + lint-staged** — ready to develop, test, and ship.

## Project types

| Type | Stack | Description |
|---|---|---|
| `package` | TypeScript + tsup | Publishable npm package with dual ESM/CJS output |
| `spa` | React + Vite | Single Page Application with HMR |
| `cli` | TypeScript + tsup + Commander | Command-line tool |
| `server` | Express + TypeScript | REST API server (optional WebSocket support via `--ws`) |

## Requirements

- **Node.js >= 20**
- **Bash >= 4** (Linux/macOS) or **Git Bash** (Windows)

## Installation

### Via npx (recommended)

```sh
npx create-ts-scaffold <type> <name> [--ws]
```

### From source

```sh
git clone https://github.com/lordcraymen/scaffold.git
cd scaffold
./scaffold.sh <type> <name> [--ws]
```

## Usage

```sh
scaffold <type> <name> [options]
```

### Types

- **package** — Publishable npm package (TypeScript + tsup)
- **spa** — Single Page Application (React + Vite)
- **cli** — Command-line tool (TypeScript + tsup + Commander)
- **server** — REST API server (Express + TypeScript)

### Options

| Option | Description |
|---|---|
| `--ws` | Add WebSocket support (server type only) |
| `-h`, `--help` | Show help |

### Examples

```sh
# Create an npm package
scaffold package my-lib

# Create a React SPA
scaffold spa my-app

# Create a CLI tool
scaffold cli my-tool

# Create an Express server with WebSocket support
scaffold server my-api --ws
```

## What you get

Every generated project includes:

- **TypeScript** — Strict mode, modern target
- **Vitest** — Fast unit testing
- **ESLint 9** — Flat config with TypeScript support
- **Prettier** — Consistent code formatting
- **Husky + lint-staged** — Pre-commit hooks for linting and formatting
- **Git** — Initialized repository with `.gitignore`

### Commands available in every project

```sh
npm run dev        # Start development (type-specific)
npm run build      # Build for production
npm test           # Run tests
npm run lint       # Run ESLint
npm run format     # Run Prettier
```

## Pinned versions

Dependencies are pinned to known-good versions for reproducible scaffolding. Key versions include:

| Dependency | Version |
|---|---|
| TypeScript | 5.7.3 |
| Vite | 7.0.0 |
| Vitest | 4.0.18 |
| React | 19.0.0 |
| Express | 4.21.2 |
| ESLint | 9.18.0 |
| Prettier | 3.4.0 |

See [lib/versions.sh](lib/versions.sh) for the full list.

## Project structure

```
scaffold.sh          # Main entry point
bin/scaffold.js      # Node wrapper (enables npx / Windows support)
lib/
  common.sh          # Shared config file writers
  helpers.sh         # Shell utilities (logging, usage)
  versions.sh        # Pinned dependency versions
  types/
    package.sh       # npm package scaffolding
    spa.sh           # React SPA scaffolding
    cli.sh           # CLI tool scaffolding
    server.sh        # Express server scaffolding
```

## License

[MIT](LICENSE) © Florian 'lordcraymen' Patzke
