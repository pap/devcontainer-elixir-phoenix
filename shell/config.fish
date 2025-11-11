# Fish shell configuration for devcontainer
# Fish has better defaults than bash/zsh, so minimal config needed

# Disable default fish greeting (we have custom one in elixir.fish)
set -g fish_greeting ""

# Add ~/.local/bin to PATH for local installations (compatible with all Fish versions)
set -gx PATH ~/.local/bin $PATH

# Useful abbreviations (fish's improvement over aliases)
abbr -a -- g git
abbr -a -- gs 'git status'
abbr -a -- gp 'git pull'
abbr -a -- gc 'git commit'
abbr -a -- gco 'git checkout'

# Docker/Podman abbreviations
abbr -a -- d docker
abbr -a -- dc 'docker compose'
abbr -a -- p podman
abbr -a -- pc 'podman-compose'
