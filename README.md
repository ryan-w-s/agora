# Agora

A modern forum service built with Elixir Phoenix 1.17.

## Overview

Agora is a modern forum application designed to support nested topics, rich threads, threaded comments, and user profiles.

## Features

- **Topics**: Organize threads like folders with support for nested topics and automatic sorting by recent activity.
- **Threads**: Create and view main posts with full Markdown support and  \[TODO] embedded content (images, videos, links).
- **Comments**: Post comments in chronological order, reply to specific comments, and react with emojis.
- **Users**: Authenticate via Phoenix's built-in auth, maintain public usernames, profile pages (bio, avatar, signature), and assign moderator roles.
- \[TODO] **Notifications**: Receive updates for mentions, replies, and thread activity in real time.

## Tech Stack

- **Elixir & Phoenix**: Phoenix 1.17 with LiveView for interactive UIs.
- **Database**: Ecto with SQLite via `ecto_sqlite3`.
- **Frontend**: Tailwind CSS (dark mode enabled) and Heroicons, bundled with Esbuild.
- **Testing & Quality**: ExUnit for tests, Credo for linting, and Mix tasks for formatting.

## Prerequisites

- Elixir ~> 1.14
- Erlang/OTP 24+
- Node.js & npm (for asset compilation)
- Git

## Setup

Clone the repository and install dependencies:

```bash
git clone <repository_url>
cd agora
mix setup
```

`mix setup` runs:
- `deps.get` (Elixir dependencies)
- `ecto.setup` (create, migrate, seed the database)
- `assets.setup` (npm install, install Tailwind & Esbuild)
- `assets.build` (compile CSS & JS assets)

## Available Mix Commands

### Administration
- `mix agora.set_moderator` # Make the user a moderator

### Setup & Database Management
- `mix setup`         # Install deps, setup DB, build assets
- `mix seed`          # Seed the database (`priv/repo/seeds.exs`)
- `mix ecto.setup`    # Create DB, run migrations, seed
- `mix ecto.reset`    # Drop DB and re-run `ecto.setup`
- `mix cleanup`       # Drop DB and clean compiled artifacts

### Assets
- `mix assets.setup`  # npm install, install Tailwind & Esbuild if missing
- `mix assets.build`  # Compile Tailwind CSS and JS via Esbuild
- `mix assets.deploy` # Compile & minify assets, generate digests

### Development
- `mix phx.server`        # Start Phoenix server on http://localhost:4000
- `iex -S mix phx.server` # Start server with interactive console

### Testing & Quality Assurance
- `mix test`          # Setup test DB and run test suite
- `mix format`        # Format code
- `mix credo`         # Static code analysis
- `mix check`         # Run format, Credo, and compile

## Running the Application

Start the Phoenix server:

```bash
mix phx.server
```

Open your browser and navigate to [http://localhost:4000](http://localhost:4000) to explore Agora.

## Running Tests

```bash
mix test
```

## Assets Management

- During development, assets auto-rebuild on save.
- For production builds:
  ```bash
  mix assets.deploy
  ```

## Deploying to Production

1. Set `MIX_ENV=prod`.
2. Build & minify assets:
   ```bash
   mix assets.deploy
   ```
3. Start the server or build a release.
4. Consult the Phoenix deployment guide: https://hexdocs.pm/phoenix/deployment.html

## Contributing

Contributions, issues, and feature requests are welcome! Please open an issue or submit a pull request on the repository.

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
