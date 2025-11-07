# devcontainer-elixir-phoenix

Multi-architecture Debian Bullseye Slim development containers for Phoenix Framework with Elixir, Erlang, and Fish shell.

**Optimized for Apple Silicon and x86_64 machines.**

## Features

- ✅ **Multi-Architecture:** Native support for arm64 (Apple Silicon) and amd64 (Intel/AMD)
- ✅ **Latest Versions:** Elixir 1.19.2, Erlang 28.1.1, Phoenix 1.8.1
- ✅ **Debian Base:** Bullseye (11) Slim
- ✅ **Fish Shell:** Modern shell with great defaults
- ✅ **Podman Compatible:** Works with both Docker and Podman
- ✅ **VS Code Ready:** Perfect for Remote Containers development
- ✅ **Self-Contained:** Base image included, no external dependencies

## Quick Start

### Using the Build Script

```bash
# Docker (default)
./build.sh

# Podman
CONTAINER_TOOL=podman ./build.sh
```

### Running the Container

```bash
# Docker
docker run -it --rm -v $(pwd):/workspace -p 4000:4000 devcontainer-elixir-phoenix:latest

# Podman
podman run -it --rm -v $(pwd):/workspace -p 4000:4000 devcontainer-elixir-phoenix:latest
```

### Creating a Phoenix Project

```bash
# Inside the container (both Docker and Podman)
mix phx.new my_app --live
```

### Using Docker Compose

```bash
# Start the development environment
docker compose up -d elixir-phoenix

# Attach to the container
docker compose exec elixir-phoenix fish

# Create your Phoenix project
mix phx.new my_app
```

## Customizing the Username

The default non-root username is **`dev`**. This is IDE/editor agnostic and works with any development environment.

**For VSCode Remote Containers compatibility**, you may want to use `vscode` as the username:

```bash
# Docker
docker buildx build \
  --build-arg USERNAME=vscode \
  -t devcontainer-elixir-phoenix:latest \
  .

# Podman
podman build \
  --build-arg USERNAME=vscode \
  -t devcontainer-elixir-phoenix:latest \
  .

# Docker Compose
USERNAME=vscode docker compose up
```

The username is fully configurable via the `USERNAME` build argument. All volume paths and configurations automatically adapt to the chosen username.

## Architecture

This repository uses a single-image architecture built directly on the official [hexpm/elixir](https://hub.docker.com/r/hexpm/elixir) images. This provides:

- **Elixir 1.19.2** (exact version)
- **Erlang 28.1.1** (exact version)
- **Debian Bullseye Slim** base OS
- **Fish shell** with sensible configuration
- **Phoenix 1.8.1** generator
- **Node.js and npm** for asset compilation
- **Build tools** (gcc, make, inotify-tools)
- **Development utilities** (git, curl, wget, starship)
- **Non-root user** (`dev`) with sudo access
- **Multi-arch support** (arm64, amd64)
- **Hex, Rebar3** and Phoenix generators pre-installed
- **IEx** with persistent history enabled

The single-image design eliminates unnecessary complexity while maintaining full control over the development environment.

## Building

### Recommended: Use the Build Script

The `build.sh` script handles multi-architecture builds for both Docker and Podman with convenient shortcuts:

```bash
# Build for all architectures (amd64 + arm64) - DEFAULT
./build.sh

# Build for current platform only (FASTEST - recommended for local development)
./build.sh --platforms local
PLATFORMS=local ./build.sh

# Build for specific architecture
./build.sh --platforms arm64    # Apple Silicon only
./build.sh --platforms amd64    # Intel/AMD only

# Build with custom version
VERSION=1.0.0 ./build.sh

# Build with Podman for local platform
CONTAINER_TOOL=podman PLATFORMS=local ./build.sh

# Build and push to registry (all platforms)
PUSH=true REGISTRY=ghcr.io/username ./build.sh
```

**Platform Shortcuts:**
- `local`, `native`, `current` - Build for your current architecture only (fastest!)
- `amd64`, `x86_64` - Build for Intel/AMD 64-bit
- `arm64`, `aarch64` - Build for ARM 64-bit (Apple Silicon)
- `all`, `both`, `multi` - Build for both architectures (default)

Run `./build.sh --help` for all options.

### Manual Build (Docker)

```bash
# Build for all architectures
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  --build-arg VERSION=$(date -u +"%Y%m%d")-$(git rev-parse --short HEAD) \
  -t devcontainer-elixir-phoenix:latest \
  .

# Build for current platform only (faster for local development)
docker build \
  --build-arg VERSION=$(date -u +"%Y%m%d")-$(git rev-parse --short HEAD) \
  -t devcontainer-elixir-phoenix:latest \
  .
```

### Manual Build (Podman)

```bash
# Build for current platform (recommended for local development)
podman build \
  --build-arg VERSION=$(date -u +"%Y%m%d")-$(git rev-parse --short HEAD) \
  -t devcontainer-elixir-phoenix:latest \
  .

# Build for specific platform
podman build \
  --platform linux/arm64 \
  --build-arg VERSION=$(date -u +"%Y%m%d")-$(git rev-parse --short HEAD) \
  -t devcontainer-elixir-phoenix:latest \
  .
```

## Customization

### Build Arguments

The image supports these build arguments:

| Argument | Default | Description |
|----------|---------|-------------|
| `VERSION` | - | Image version tag |
| `USERNAME` | `dev` | Non-root user name |
| `USER_UID` | `1000` | User ID |
| `USER_GID` | `1000` | Group ID |
| `ELIXIR_VERSION` | `1.19.2` | Elixir version (exact) |
| `ERLANG_VERSION` | `28.1.1` | Erlang version (exact) |
| `PHOENIX_VERSION` | `1.8.1` | Phoenix version (exact) |
| `DEBIAN_VERSION` | `bullseye` | Debian base version (Debian 11) |
| `IMAGE_DATE` | `20251103` | hexpm/elixir image date stamp |

### Custom Versions Example

```bash
# Docker
docker buildx build \
  --build-arg ELIXIR_VERSION=1.18.0 \
  --build-arg ERLANG_VERSION=27.3 \
  --build-arg PHOENIX_VERSION=1.7.14 \
  -t my-custom-phoenix:latest \
  .

# Podman
podman build \
  --build-arg ELIXIR_VERSION=1.18.0 \
  --build-arg ERLANG_VERSION=27.3 \
  --build-arg PHOENIX_VERSION=1.7.14 \
  -t my-custom-phoenix:latest \
  .
```

**Note:** Check [hexpm/elixir tags](https://hub.docker.com/r/hexpm/elixir/tags) for available Elixir/Erlang combinations and update `IMAGE_DATE` accordingly.

## Editor Integration

### VS Code Dev Container (Native Support)

This repository includes a complete VS Code devcontainer configuration in `.devcontainer/devcontainer.json`.

**Quick Start:**
1. Install the [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)
2. Open this repository in VS Code
3. Click "Reopen in Container" when prompted (or use Command Palette: "Dev Containers: Reopen in Container")

**Features:**
- Automatic port forwarding (4000, 4001)
- Pre-configured Elixir and Phoenix extensions
- Fish shell as default terminal
- SSH key mounting for git operations
- Automatic `mix deps.get` on container creation

**Manual Configuration (for other projects):**

Create `.devcontainer/devcontainer.json`:

```json
{
  "name": "Phoenix Development",
  "image": "devcontainer-elixir-phoenix:latest",
  "workspaceFolder": "/workspace",
  "workspaceMount": "source=${localWorkspaceFolder},target=/workspace,type=bind",
  "forwardPorts": [4000, 4001],
  "remoteUser": "dev",
  "postCreateCommand": "mix deps.get",
  "customizations": {
    "vscode": {
      "extensions": [
        "jakebecker.elixir-ls",
        "bradlc.vscode-tailwindcss",
        "phoenixframework.phoenix"
      ],
      "settings": {
        "terminal.integrated.defaultProfile.linux": "fish"
      }
    }
  }
}
```

### Zed Editor (Limited Support)

Zed does not have native devcontainer support as of November 2024. There are workarounds available:

#### Option 1: Dev Container CLI + Zed Tasks (Recommended)

This repository includes Zed task configurations in `.zed/tasks.json`.

**Setup:**
```bash
# Install Dev Container CLI
npm install -g @devcontainers/cli

# Build and start the container
devcontainer up --workspace-folder .

# Execute commands in the container
devcontainer exec --workspace-folder . fish
```

**Available Zed Tasks:**
- `DevContainer: Build` - Build the container
- `DevContainer: Up` - Start the container
- `DevContainer: Exec Shell` - Open a Fish shell
- `Phoenix: Start Server` - Run `mix phx.server`
- `Mix: Get Dependencies` - Run `mix deps.get`
- `Mix: Test` - Run tests
- `Mix: Format` - Format code
- `IEx: Interactive Shell` - Start IEx

**Limitations:**
- Language server runs locally, not in the container
- No automatic port forwarding
- Manual task execution required

#### Option 2: SSH Remote Development

Zed supports SSH remote development. You can modify the Dockerfile to add SSH server support:

**Add to Dockerfile:**
```dockerfile
# In the apt-get install section (line ~32)
openssh-server \

# After user creation (line ~71)
RUN mkdir /var/run/sshd && \
    echo 'dev:dev' | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config

EXPOSE 22
```

**Update docker-compose.yml:**
```yaml
ports:
  - "4000:4000"
  - "4001:4001"
  - "2222:22"
command: ["/bin/sh", "-c", "sudo service ssh start && fish"]
```

**Connect via Zed:**
```
zed ssh://dev@localhost:2222/workspace
```

**Note:** Native devcontainer support for Zed is tracked in [issue #11473](https://github.com/zed-industries/zed/issues/11473).

## Running Containers

### Basic Development

```bash
# Docker
docker run -it --rm \
  -v $(pwd):/workspace \
  -w /workspace \
  -p 4000:4000 \
  -p 4001:4001 \
  devcontainer-elixir-phoenix:latest

# Podman
podman run -it --rm \
  -v $(pwd):/workspace \
  -w /workspace \
  -p 4000:4000 \
  -p 4001:4001 \
  devcontainer-elixir-phoenix:latest
```

### With Timezone

```bash
# Docker
docker run -it --rm \
  -v $(pwd):/workspace \
  -e TZ=America/New_York \
  -p 4000:4000 \
  devcontainer-elixir-phoenix:latest

# Podman
podman run -it --rm \
  -v $(pwd):/workspace \
  -e TZ=America/New_York \
  -p 4000:4000 \
  devcontainer-elixir-phoenix:latest
```

### With Socket Mounting (for Container-in-Container)

```bash
# Docker
docker run -it --rm \
  -v $(pwd):/workspace \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -p 4000:4000 \
  devcontainer-elixir-phoenix:latest

# Podman
podman run -it --rm \
  -v $(pwd):/workspace \
  -v /run/podman/podman.sock:/var/run/docker.sock \
  -p 4000:4000 \
  devcontainer-elixir-phoenix:latest
```

## Multi-Architecture Support

These images are built for:

- **linux/amd64** - Intel/AMD x86_64 processors
- **linux/arm64** - Apple Silicon, AWS Graviton, etc.

On Apple Silicon Macs, native arm64 builds are **significantly faster** than emulated x86_64.

### Verifying Architecture

```bash
# Docker - check what architecture the image supports
docker buildx imagetools inspect devcontainer-elixir-phoenix:latest

# Podman - check image architecture
podman image inspect devcontainer-elixir-phoenix:latest | grep Architecture

# Inside the container (both Docker and Podman)
uname -m  # arm64 or x86_64
```

## Versions

Current versions:

| Component | Version |
|-----------|---------|
| **Elixir** | 1.19.2 |
| **Erlang** | 28.1.1 |
| **Phoenix** | 1.8.1 |
| **Debian** | Bullseye (11) Slim |
| **Node.js** | Latest LTS from Debian |

## Troubleshooting

### Permission Issues

If you get permission errors with mounted volumes:

```bash
# Docker - build with your host UID/GID
docker buildx build \
  --build-arg USER_UID=$(id -u) \
  --build-arg USER_GID=$(id -g) \
  -t devcontainer-elixir-phoenix:latest \
  .

# Podman - build with your host UID/GID
podman build \
  --build-arg USER_UID=$(id -u) \
  --build-arg USER_GID=$(id -g) \
  -t devcontainer-elixir-phoenix:latest \
  .
```

### Podman on macOS

Podman on macOS runs in a VM, so socket mounting works differently:

```bash
# Check Podman machine
podman machine info

# Socket is at:
# /var/run/podman/podman.sock (inside VM)
```

### Build Fails on Apple Silicon

Ensure you're building for the correct platform:

```bash
# Build for native architecture only (both Docker and Podman)
PLATFORMS=local ./build.sh

# Docker - specify platform explicitly
docker buildx build --platform linux/arm64 -t devcontainer-elixir-phoenix:latest .

# Podman - specify platform explicitly
podman build --platform linux/arm64 -t devcontainer-elixir-phoenix:latest .
```

## Contributing

Issues and pull requests welcome! Please ensure:

- Multi-arch builds work (test on both amd64 and arm64)
- Both Docker and Podman compatibility
- Documentation is updated

## License

This repository is under an [MIT license](LICENSE) unless indicated otherwise.
