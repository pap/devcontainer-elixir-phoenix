ARG ELIXIR_VERSION=1.19.2
ARG ERLANG_VERSION=28.1.1
ARG PHOENIX_VERSION=1.8.1
ARG DEBIAN_VERSION=bullseye
ARG IMAGE_DATE=20251103

# Build directly on hexpm/elixir image
FROM hexpm/elixir:${ELIXIR_VERSION}-erlang-${ERLANG_VERSION}-debian-${DEBIAN_VERSION}-${IMAGE_DATE}-slim

ARG USERNAME=dev
ARG USER_UID=1000
ARG USER_GID=1000
ARG PHOENIX_VERSION=1.8.1
ARG ELIXIR_VERSION=1.19.2
ARG ERLANG_VERSION=28.1.1

LABEL \
    org.opencontainers.image.authors="pauloalvespereira@live.com" \
    org.opencontainers.image.version=$VERSION \
    org.opencontainers.image.url="https://github.com/pap/devcontainer-elixir-phoenix" \
    org.opencontainers.image.documentation="https://github.com/pap/devcontainer-elixir-phoenix" \
    org.opencontainers.image.source="https://github.com/pap/devcontainer-elixir-phoenix" \
    org.opencontainers.image.title="Elixir Phoenix Dev Container" \
    org.opencontainers.image.description="Phoenix Framework development container with Elixir ${ELIXIR_VERSION} Erlang ${ERLANG_VERSION}"

USER root

# Install development tools, Fish shell, and Node.js
RUN --mount=type=cache,target=/var/cache/apt \
    --mount=type=cache,target=/var/lib/apt \
    rm -f /etc/apt/apt.conf.d/docker-clean && \
    apt-get update && apt-get install -y --no-install-recommends \
    # Base dev tools
    git \
    curl \
    wget \
    ca-certificates \
    sudo \
    # Fish shell
    fish \
    # Build tools for native extensions
    build-essential \
    # File watching for Phoenix live reload
    inotify-tools \
    # Node.js for asset compilation
    nodejs \
    npm \
    # Utilities
    openssh-client \
    less \
    procps \
    htop \
    && npm install -g npm@11.6.2 \
    && rm -rf /var/lib/apt/lists/*

# Install Starship prompt - always get latest version
# Note: This is a Debian (glibc) base image; using Starship's musl builds because they are
# statically linked and portable to glibc systems. Musl builds are available for both aarch64
# and x86_64, while glibc builds are only available for x86_64
RUN ARCH="$(dpkg --print-architecture)" && \
    case "$ARCH" in \
    amd64) STARSHIP_ARCH="x86_64" ;; \
    arm64) STARSHIP_ARCH="aarch64" ;; \
    *) echo "Unsupported architecture: $ARCH" && exit 1 ;; \
    esac && \
    curl -sLf "https://github.com/starship/starship/releases/latest/download/starship-${STARSHIP_ARCH}-unknown-linux-musl.tar.gz" | \
    tar xzf - -C /usr/local/bin

# Create non-root user with sudo access
RUN groupadd --gid ${USER_GID} ${USERNAME} \
    && useradd --uid ${USER_UID} --gid ${USER_GID} -m -s /usr/bin/fish ${USERNAME} \
    && echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USERNAME} \
    && chmod 0440 /etc/sudoers.d/${USERNAME}

# Create fish config directories
RUN mkdir -p /home/${USERNAME}/.config/fish/conf.d /home/${USERNAME}/.config/fish/functions \
    /root/.config/fish/conf.d /root/.config/fish/functions

# Copy fish shell configurations
COPY shell/config.fish /home/${USERNAME}/.config/fish/
COPY shell/conf.d/ /home/${USERNAME}/.config/fish/conf.d/
COPY shell/functions/ /home/${USERNAME}/.config/fish/functions/
RUN chown -R ${USER_UID}:${USER_GID} /home/${USERNAME}/.config

# Also copy to root for convenience
COPY shell/config.fish /root/.config/fish/
COPY shell/conf.d/ /root/.config/fish/conf.d/
COPY shell/functions/ /root/.config/fish/functions/

USER ${USERNAME}

# Add local node module binaries to PATH
ENV PATH=./node_modules/.bin:$PATH

# Enable iex history
ENV ERL_AFLAGS="-kernel shell_history enabled shell_history_path '\"/home/${USERNAME}/.erlang-history\"'"

# Install latest Hex and Rebar
RUN mix local.hex --force && mix local.rebar --force

# Install Phoenix project generator
RUN mix archive.install hex phx_new ${PHOENIX_VERSION} --force

WORKDIR /workspace

# Set version environment variables (at end to avoid cache invalidation)
ARG VERSION=
ENV PHOENIX_IMAGE_VERSION="${VERSION}"
ENV ELIXIR_VERSION="${ELIXIR_VERSION}"
ENV ERLANG_VERSION="${ERLANG_VERSION}"

# Start Fish shell by default
CMD ["/usr/bin/fish"]
