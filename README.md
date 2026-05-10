# nix-lefthook-database-consistency-check

[![CI](https://github.com/pr0d1r2/nix-lefthook-database-consistency-check/actions/workflows/ci.yml/badge.svg)](https://github.com/pr0d1r2/nix-lefthook-database-consistency-check/actions/workflows/ci.yml)

> This code is LLM-generated and validated through an automated integration process using [lefthook](https://github.com/evilmartians/lefthook) git hooks, [bats](https://github.com/bats-core/bats-core) unit tests, and GitHub Actions CI.

Lefthook-compatible [database_consistency](https://github.com/djezzzl/database_consistency) gem wrapper, packaged as a Nix flake.

Runs `bundle exec database_consistency` and fails on any "fail" lines. Exits 0 when no failures are found.

## Usage

### Option A: Lefthook remote (recommended)

Add to your `lefthook.yml` — no flake input needed, just the wrapper binary in your devShell:

```yaml
remotes:
  - git_url: https://github.com/pr0d1r2/nix-lefthook-database-consistency-check
    ref: main
    configs:
      - lefthook-remote.yml
```

### Option B: Flake input

Add as a flake input:

```nix
inputs.nix-lefthook-database-consistency-check = {
  url = "github:pr0d1r2/nix-lefthook-database-consistency-check";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

Add to your devShell:

```nix
nix-lefthook-database-consistency-check.packages.${pkgs.stdenv.hostPlatform.system}.default
```

Add to `lefthook.yml`:

```yaml
pre-push:
  commands:
    database-consistency-check:
      glob: "{app/models/**/*.rb,engines/*/app/models/**/*.rb,db/migrate/**}"
      run: timeout ${LEFTHOOK_DATABASE_CONSISTENCY_CHECK_TIMEOUT:-60} lefthook-database-consistency-check
```

### Configuration

The config file defaults to `.database_consistency.todo.yml`. Override per-repo via environment variable:

```bash
export LEFTHOOK_DATABASE_CONSISTENCY_CONFIG=.database_consistency.yml
```

### Configuring timeout

The default timeout is 60 seconds. Override per-repo via environment variable:

```bash
export LEFTHOOK_DATABASE_CONSISTENCY_CHECK_TIMEOUT=120
```

## Development

The repo includes an `.envrc` for [direnv](https://direnv.net/) — entering the directory automatically loads the devShell with all dependencies:

```bash
cd nix-lefthook-database-consistency-check  # direnv loads the flake
bats tests/unit/
```

If not using direnv, enter the shell manually:

```bash
nix develop
bats tests/unit/
```

## License

MIT
