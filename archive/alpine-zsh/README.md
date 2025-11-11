# Archived: Alpine + Zsh Version

This marks the location of the original Alpine Linux-based implementation.

## Why Replaced?

The Alpine version was replaced with Debian Bullseye Slim + Fish shell for:

1. **External Dependency** - Relied on archived `papereira/devcontainer-base:0.2.2` (unmaintained, no arm64 support)
2. **musl vs glibc** - Alpine's musl caused issues with VS Code extensions, Elixir NIFs, and npm packages
3. **No multi-arch support** - No native arm64 for Apple Silicon
4. **Heavy framework** - Required zsh + Oh-My-Zsh setup

## New Version

The modernized implementation in `images/` provides:
- Debian Bullseye Slim (glibc compatibility)
- Self-contained base (no external dependencies)
- Multi-arch support (arm64 + amd64)
- Fish shell (better defaults, no framework needed)
- Latest versions: Elixir 1.19.2, OTP 28, Phoenix 1.8.1

## Old Version Details

| Component | Version |
|-----------|---------|
| Elixir | 1.17.0 |
| Erlang/OTP | 27 |
| Phoenix | 1.7.14 |
| Alpine | 3.20 |
| Shell | zsh + Oh-My-Zsh |
| Base | `papereira/devcontainer-base:0.2.2` |

See [main README](../../README.md) for the new implementation.
