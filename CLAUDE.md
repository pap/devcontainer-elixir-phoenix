# CLAUDE.md - AI Assistant Guide

> **Last Updated:** 2025-11-14
> **Repository:** devcontainer-elixir-phoenix
> **Purpose:** Multi-architecture Docker devcontainer template for Phoenix Framework development

---

## Table of Contents

1. [Repository Overview](#repository-overview)
2. [Codebase Structure](#codebase-structure)
3. [Key Files Reference](#key-files-reference)
4. [Development Workflows](#development-workflows)
5. [Conventions and Patterns](#conventions-and-patterns)
6. [Common Tasks](#common-tasks)
7. [Git Workflow](#git-workflow)
8. [Build and Release Process](#build-and-release-process)
9. [Testing Strategy](#testing-strategy)
10. [Troubleshooting](#troubleshooting)

---

## Repository Overview

### What This Is

This is a **devcontainer template repository**, NOT a Phoenix application. It provides a containerized development environment for Elixir/Phoenix projects with:

- **Multi-architecture support**: Native arm64 (Apple Silicon) and amd64 (Intel/AMD)
- **Modern tooling**: Fish shell, Starship prompt, VS Code integration
- **Pre-configured**: Elixir 1.19.2, Erlang 28.1.1, Phoenix 1.8.1
- **Developer-friendly**: Non-root user, persistent volumes, shell abbreviations

### What This Is Not

- This is NOT a Phoenix application to be modified
- This is NOT meant to contain application code
- This is a template for creating NEW Phoenix projects

### Key Characteristics

- Base OS: Debian Bullseye Slim
- Shell: Fish (with 55+ abbreviations)
- Container Tools: Docker and Podman support
- Editors: VS Code Dev Containers, Zed Editor support
- License: MIT

---

## Codebase Structure

```
/home/user/devcontainer-elixir-phoenix/
├── .devcontainer/           # VS Code Dev Container configuration
│   └── devcontainer.json   # Container settings, extensions, port forwarding
├── .zed/                   # Zed editor configuration
│   └── tasks.json         # Build, run, test tasks for Zed
├── shell/                  # Fish shell configuration
│   ├── config.fish        # Main Fish config with abbreviations
│   ├── conf.d/            # Configuration directory
│   │   ├── elixir.fish   # 55+ Elixir/Phoenix/Ecto/Ash abbreviations
│   │   └── starship.fish # Starship prompt initialization
│   └── functions/         # Custom Fish functions
│       └── fish_greeting.fish  # Welcome message with version info
├── archive/               # Historical versions (Alpine+Zsh)
│   └── alpine-zsh/       # Previous implementation (deprecated)
├── Dockerfile             # Container image definition (113 lines)
├── docker-compose.yml    # Local dev environment orchestration
├── build.sh              # Multi-arch build script (276 lines)
├── .dockerignore         # Docker build exclusions
├── .gitignore            # Git exclusions (minimal)
├── README.md             # Comprehensive user documentation
└── LICENSE               # MIT License
```

### Directory Purposes

- **`.devcontainer/`**: VS Code Remote Containers integration with extension recommendations
- **`.zed/`**: Zed editor tasks (requires Dev Container CLI)
- **`shell/`**: Fish shell configuration copied into the container at build time
- **`archive/`**: Deprecated Alpine+Zsh implementation for historical reference

---

## Key Files Reference

### Critical Files

| File | Lines | Purpose | Key Details |
|------|-------|---------|-------------|
| `Dockerfile` | 113 | Container definition | Base: `hexpm/elixir`, installs tools, creates non-root user |
| `build.sh` | 276 | Build automation | Multi-arch support, Docker/Podman, version tagging |
| `docker-compose.yml` | 48 | Dev orchestration | Ports 4000/4001, persistent volumes, healthcheck |
| `devcontainer.json` | - | VS Code config | Extensions, post-create commands, settings |
| `shell/conf.d/elixir.fish` | - | Abbreviations | 55+ shortcuts for Mix/Phoenix/Ecto/Ash |

### Dockerfile: Key Sections

**Location:** `/home/user/devcontainer-elixir-phoenix/Dockerfile`

```dockerfile
# Build Arguments (customizable versions)
ARG ELIXIR_VERSION=1.19.2
ARG ERLANG_VERSION=28.1.1
ARG PHOENIX_VERSION=1.8.1
ARG DEBIAN_VERSION=bullseye
ARG USERNAME=dev
ARG USER_UID=1000
ARG USER_GID=1000

# Base image from official Hex.pm
FROM hexpm/elixir:${ELIXIR_VERSION}-erlang-${ERLANG_VERSION}-debian-${DEBIAN_VERSION}-${IMAGE_DATE}-slim

# Installs: git, curl, build tools, Node.js, Fish shell, Starship
# Creates non-root user with sudo access
# Copies Fish shell configuration from shell/ directory
# Installs Hex, Rebar, Phoenix generator
# Enables IEx persistent history
```

**Architecture Handling (Lines 67-73):**
- Detects platform: `linux/amd64` or `linux/arm64`
- Downloads appropriate Starship binary
- Handles both x86_64 and aarch64 architectures

**User Setup (Lines 29-37):**
- Creates group and user with specified UID/GID
- Sets Fish as default shell
- Configures sudo without password

### build.sh: Build Script

**Location:** `/home/user/devcontainer-elixir-phoenix/build.sh:1`

**Usage:**
```bash
./build.sh [OPTIONS] [PLATFORM]

# Platform shortcuts:
./build.sh local       # Current architecture only
./build.sh amd64       # x86_64 only
./build.sh arm64       # ARM64 only
./build.sh all         # Both architectures (default)

# Options:
-v, --version VERSION   # Set version tag
-p, --platforms PLAT    # Comma-separated platforms
-t, --tool TOOL        # docker or podman
-r, --registry URL     # Container registry
--push                 # Push after build
```

**Key Functions:**
- `detect_arch()`: Identifies current platform (lines 51-62)
- `validate_buildx()`: Checks Docker buildx availability (lines 64-73)
- `setup_buildx()`: Creates/uses buildx builder (lines 75-96)
- `build_docker()`: Executes Docker buildx build (lines 98-129)
- `build_podman()`: Executes Podman manifest build (lines 131-199)

**Version Generation:**
- Format: `YYYYMMDD-HHMMSS-<git-hash>`
- Example: `20251114-143022-a1b2c3d`

### docker-compose.yml: Development Environment

**Location:** `/home/user/devcontainer-elixir-phoenix/docker-compose.yml:1`

**Configuration:**
```yaml
services:
  elixir-phoenix:
    build: .
    volumes:
      - .:/workspace              # Project files
      - mix-deps:/home/dev/.mix/deps
      - mix-build:/workspace/_build
      - hex-packages:/home/dev/.hex/packages
      - iex-history:/home/dev/.local/share/iex
    ports:
      - "4000:4000"  # Phoenix server
      - "4001:4001"  # LiveReload
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:4000"]
```

**Why These Volumes?**
- Persistent dependencies across container restarts
- Faster rebuilds (no need to re-fetch)
- Preserves IEx command history

### shell/conf.d/elixir.fish: Abbreviations

**Location:** `/home/user/devcontainer-elixir-phoenix/shell/conf.d/elixir.fish:1`

**Categories (55+ total):**

**Mix Commands:**
```fish
m    → mix
mt   → mix test
mc   → mix compile
mf   → mix format
mdg  → mix deps.get
```

**Phoenix Commands:**
```fish
mps  → mix phx.server
mpn  → mix phx.new
mpr  → mix phx.routes
ix   → iex -S mix
```

**Phoenix Generators:**
```fish
mpgc → mix phx.gen.context
mpgh → mix phx.gen.html
mpgj → mix phx.gen.json
mpgl → mix phx.gen.live
mpgs → mix phx.gen.schema
mpga → mix phx.gen.auth
```

**Ecto Database:**
```fish
mer  → mix ecto.reset
mec  → mix ecto.create
mem  → mix ecto.migrate
merb → mix ecto.rollback
megm → mix ecto.gen.migration
```

**Ash Framework (18 commands):**
- Resource management: `ar`, `ara`, `arapi`, etc.
- Migrations: `ami`, `amg`, `amr`, etc.
- Code generation: `acc`, `acj`, etc.

**Development Tools:**
```fish
mdd  → mix dialyzer
mcr  → mix credo
mcs  → mix coveralls
mtw  → mix test.watch
```

---

## Development Workflows

### For AI Assistants Working on This Repository

#### 1. Modifying the Container Image

**When to do this:**
- Adding new system packages
- Updating Elixir/Erlang/Phoenix versions
- Changing user configuration
- Adding new development tools

**Files to modify:**
- `Dockerfile` - Main image definition
- `shell/conf.d/elixir.fish` - Add new abbreviations
- `shell/config.fish` - General shell configuration

**Testing changes:**
```bash
# Build locally
./build.sh local

# Test with docker-compose
docker compose up -d
docker compose exec elixir-phoenix fish
```

#### 2. Adding New Shell Abbreviations

**File:** `shell/conf.d/elixir.fish`

**Pattern to follow:**
```fish
# Guard to prevent duplicates
if not abbr --query my_abbr
    abbr -a my_abbr 'full command here'
end
```

**Categories:**
- Mix commands → `m*` prefix
- Phoenix commands → `mp*` prefix
- Ecto commands → `me*` prefix
- Ash commands → `a*` prefix

#### 3. Updating Dependencies

**Elixir/Erlang/Phoenix versions:**

Edit `Dockerfile`:
```dockerfile
ARG ELIXIR_VERSION=1.19.2    # Update here
ARG ERLANG_VERSION=28.1.1    # Update here
ARG PHOENIX_VERSION=1.8.1    # Update here
```

**System packages:**

Edit `Dockerfile` around line 39:
```dockerfile
RUN apt-get update && apt-get install -y \
    git \
    curl \
    # Add new packages here
```

#### 4. Adding VS Code Extensions

**File:** `.devcontainer/devcontainer.json`

```json
{
  "customizations": {
    "vscode": {
      "extensions": [
        "jakebecker.elixir-ls",
        "your.new-extension"  // Add here
      ]
    }
  }
}
```

#### 5. Adding Zed Editor Tasks

**File:** `.zed/tasks.json`

```json
{
  "label": "Task Name",
  "command": "command to run",
  "args": [],
  "tags": ["devcontainer"]
}
```

---

## Conventions and Patterns

### Code Style

#### 1. Dockerfile Conventions

**Section ordering:**
1. ARG declarations (build-time variables)
2. FROM statement (base image)
3. System package installation
4. User creation
5. Tool installation (language-specific)
6. Configuration copying
7. LABEL metadata
8. USER switch
9. WORKDIR and final setup

**Best practices observed:**
- Use `apt-get` with `-y` flag for non-interactive
- Clean up with `rm -rf /var/lib/apt/lists/*` after installs
- Create non-root user for security
- Use build args for customization

#### 2. Shell Configuration Conventions

**Abbreviation naming:**
- Start with category prefix (m, mp, me, a)
- Use lowercase
- Keep short but memorable
- Include command in comment

**File organization:**
- `config.fish` - General abbreviations and PATH
- `conf.d/*.fish` - Specific tool configurations
- `functions/*.fish` - Custom functions

**Idempotency pattern:**
```fish
if not abbr --query abbr_name
    abbr -a abbr_name 'command'
end
```

#### 3. Docker Compose Conventions

**Service naming:**
- Use descriptive names: `elixir-phoenix`
- Match the repository purpose

**Volume naming:**
- Descriptive purpose-based names
- Pattern: `<tool>-<purpose>` (e.g., `mix-deps`)

**Port mapping:**
- Always document what each port is for
- Phoenix: 4000 (server), 4001 (LiveReload)

#### 4. Build Script Conventions

**Platform detection:**
- Normalize architecture names (amd64/arm64)
- Provide shortcuts (local, native, all)
- Default to multi-arch builds

**Output formatting:**
- Use colors (GREEN, YELLOW, CYAN)
- Clear section headers
- Display next steps after build

#### 5. Documentation Conventions

**README.md sections:**
1. Overview with badges
2. Quick start (get running ASAP)
3. Detailed usage
4. Customization options
5. Troubleshooting
6. Contributing
7. License

**Code comments:**
- Explain WHY, not WHAT
- Document architecture-specific handling
- Note rationale for design decisions

### Design Patterns

#### 1. Single-Image Architecture

**Pattern:** Build directly on official Hex.pm base image
- No external base image dependencies
- Full control over environment
- Easier to maintain

#### 2. Non-Root User Pattern

**Why:** Security and editor compatibility
```dockerfile
# Create user with specified UID/GID
RUN groupadd -g ${USER_GID} ${USERNAME}
RUN useradd -u ${USER_UID} -g ${USER_GID} -s /usr/bin/fish ${USERNAME}
```

#### 3. Volume Persistence Pattern

**Why:** Speed and preservation
```yaml
volumes:
  - mix-deps:/home/dev/.mix/deps      # Dependencies
  - mix-build:/workspace/_build       # Build artifacts
  - hex-packages:/home/dev/.hex       # Package cache
  - iex-history:/home/dev/.local/share/iex  # Command history
```

#### 4. Multi-Architecture Support Pattern

**Approach:**
- Use Docker buildx for Docker
- Use manifest lists for Podman
- Download architecture-specific binaries at build time

```dockerfile
case "$ARCH" in
    amd64) STARSHIP_ARCH="x86_64" ;;
    arm64) STARSHIP_ARCH="aarch64" ;;
esac
```

#### 5. Configuration Externalization Pattern

**Why:** Easier to modify without rebuilding
- Shell config in `shell/` directory
- Copied during build: `COPY shell/ /home/${USERNAME}/.config/fish/`
- Can be volume-mounted for development

---

## Common Tasks

### For AI Assistants: Task Checklist

#### Task: Add a New System Package

**Files to modify:**
1. `Dockerfile` (around line 39)

**Steps:**
```dockerfile
RUN apt-get update && apt-get install -y \
    existing-package \
    new-package \           # Add here
    && rm -rf /var/lib/apt/lists/*
```

**Validation:**
```bash
./build.sh local
docker run --rm devcontainer-elixir-phoenix:latest which new-package
```

#### Task: Add a New Shell Abbreviation

**Files to modify:**
1. `shell/conf.d/elixir.fish` (or appropriate conf.d file)

**Steps:**
```fish
# Add to appropriate section
if not abbr --query new_abbr
    abbr -a new_abbr 'full command'
end
```

**Validation:**
```bash
docker compose up -d
docker compose exec elixir-phoenix fish -c "abbr --show | grep new_abbr"
```

#### Task: Update Elixir/Erlang Version

**Files to modify:**
1. `Dockerfile` (lines 1-3)
2. `README.md` (update version table)

**Steps:**
```dockerfile
ARG ELIXIR_VERSION=1.20.0    # Update
ARG ERLANG_VERSION=28.2.0    # Update
```

**Validation:**
```bash
./build.sh local
docker run --rm devcontainer-elixir-phoenix:latest elixir --version
```

#### Task: Add a VS Code Extension

**Files to modify:**
1. `.devcontainer/devcontainer.json`

**Steps:**
```json
"extensions": [
  "jakebecker.elixir-ls",
  "publisher.extension-id"  // Add
]
```

**Validation:**
- Rebuild container in VS Code
- Check Extensions panel

#### Task: Modify Port Mappings

**Files to modify:**
1. `docker-compose.yml` (ports section)
2. `.devcontainer/devcontainer.json` (forwardPorts)

**Steps:**
```yaml
# docker-compose.yml
ports:
  - "4000:4000"
  - "9999:9999"  # Add new mapping
```

```json
// devcontainer.json
"forwardPorts": [4000, 4001, 9999]
```

#### Task: Update Build Script

**File:** `build.sh`

**Common modifications:**
- Change default platforms (line 16)
- Modify version format (lines 202-211)
- Add new command-line options (lines 213-277)

**Testing:**
```bash
./build.sh --help  # Verify help text
./build.sh -v test-version local  # Test version arg
```

---

## Git Workflow

### Branch Strategy

**Current branch:** `claude/claude-md-mhyrttsgs6d5qn24-01PBhreSWif2CFSH1TYD3Lb8`

**Branch naming:**
- Feature branches: Descriptive names
- Claude branches: Must start with `claude/` and include session ID

### Commit Message Style

Based on recent commits:
```
<type>: <description>

# Types observed:
Update   - Dependency or version updates
Migrate  - Architecture/system changes
Merge    - Pull request merges

# Examples:
Update phoenix to 1.7.14
Migrate to Debian multi-architecture with Fish shell
```

### Commit Guidelines for AI Assistants

**Good commits:**
```
Update Elixir to 1.19.2 and Erlang to 28.1.1
Add Fish abbreviations for Ash framework
Improve build script multi-arch detection
```

**Avoid:**
- Generic messages ("Update files")
- Implementation details in title
- Multiple unrelated changes in one commit

### Push Requirements

**CRITICAL:**
- Always use: `git push -u origin <branch-name>`
- Branch MUST start with `claude/` and end with session ID
- Retry up to 4 times with exponential backoff on network errors
- Delays: 2s, 4s, 8s, 16s

**Example:**
```bash
git push -u origin claude/claude-md-mhyrttsgs6d5qn24-01PBhreSWif2CFSH1TYD3Lb8
```

### Before Committing

**Checklist:**
1. Run build locally: `./build.sh local`
2. Test with docker-compose: `docker compose up`
3. Verify shell abbreviations work
4. Check for syntax errors in shell scripts
5. Update README.md if needed
6. Ensure .dockerignore is correct

---

## Build and Release Process

### Local Development Build

**Quick build for testing:**
```bash
# Current architecture only
./build.sh local

# Specific architecture
./build.sh amd64
./build.sh arm64
```

### Multi-Architecture Build

**Full build (both platforms):**
```bash
# Default: both arm64 and amd64
./build.sh all

# With version tag
./build.sh --version v1.2.3 all

# With custom platforms
./build.sh --platforms linux/amd64,linux/arm64
```

### Build with Push

**To container registry:**
```bash
# Set environment variables
export REGISTRY=ghcr.io/username/repo
export VERSION=v1.2.3

# Build and push
./build.sh --push all

# Or inline:
./build.sh --registry ghcr.io/username/repo --version v1.2.3 --push all
```

### Podman Builds

**Using Podman instead of Docker:**
```bash
# Specify tool
./build.sh --tool podman local

# With environment variable
CONTAINER_TOOL=podman ./build.sh all
```

### Version Tagging Strategy

**Automatic versioning:**
- Format: `YYYYMMDD-HHMMSS-<git-hash>`
- Generated at build time
- Includes date, time, and git commit

**Manual versioning:**
```bash
./build.sh --version v1.19.2-phoenix-1.8.1 all
```

### Build Artifacts

**What gets created:**
- Container image: `devcontainer-elixir-phoenix:latest`
- Container image: `devcontainer-elixir-phoenix:<version>`
- Multi-arch manifest (if building for multiple platforms)

**Where to find:**
```bash
# Docker
docker images | grep devcontainer-elixir-phoenix

# Podman
podman images | grep devcontainer-elixir-phoenix
```

---

## Testing Strategy

### No Automated Tests

**Important:** This is a template repository with no application code, so there are no automated tests.

### Manual Testing Checklist

#### 1. Container Builds Successfully

```bash
./build.sh local
# Should complete without errors
```

#### 2. Container Runs

```bash
docker compose up -d
docker compose ps
# Should show "running" status
```

#### 3. Shell Works

```bash
docker compose exec elixir-phoenix fish
# Should get Fish shell prompt
```

#### 4. Versions Correct

```bash
docker compose exec elixir-phoenix elixir --version
docker compose exec elixir-phoenix erl -eval '{ok, Version} = file:read_file(filename:join([code:root_dir(), "releases", erlang:system_info(otp_release), "OTP_VERSION"])), io:fwrite(Version), halt().' -noshell
docker compose exec elixir-phoenix mix phx.new --version
```

#### 5. Abbreviations Work

```bash
docker compose exec elixir-phoenix fish -c "abbr --show | grep -E '^(m|mp|me|a)'"
# Should list all abbreviations
```

#### 6. User Permissions Correct

```bash
docker compose exec elixir-phoenix id
# Should show uid=1000(dev) gid=1000(dev)

docker compose exec elixir-phoenix touch /workspace/test.txt
# Should succeed without permission errors
```

#### 7. Volumes Persist

```bash
# Create file
docker compose exec elixir-phoenix sh -c "echo 'test' > /home/dev/.mix/test.txt"

# Restart
docker compose down
docker compose up -d

# Check file exists
docker compose exec elixir-phoenix test -f /home/dev/.mix/test.txt && echo "Volume persists"
```

#### 8. Phoenix Server Starts

```bash
# Inside container
docker compose exec elixir-phoenix sh -c "cd /workspace && mix phx.new demo --no-install && cd demo && mix deps.get && mix phx.server"

# From host
curl http://localhost:4000
# Should get Phoenix welcome page
```

#### 9. Multi-Architecture Build

```bash
# Build for both platforms
./build.sh all

# Inspect manifest
docker buildx imagetools inspect devcontainer-elixir-phoenix:latest
# Should list both linux/amd64 and linux/arm64
```

#### 10. VS Code Integration

```bash
# Open in VS Code with Dev Containers extension
code .

# In VS Code Command Palette:
# "Dev Containers: Reopen in Container"

# Check:
# - Extensions installed
# - Terminal uses Fish shell
# - Ports forwarded (4000, 4001)
```

### Testing After Modifications

**Dockerfile changes:**
1. Build local
2. Run container
3. Verify new changes work
4. Test on both architectures (if possible)

**Shell configuration changes:**
1. Build local
2. Run container
3. Execute `fish` shell
4. Test new abbreviations
5. Check `abbr --show`

**Build script changes:**
1. Test with `--help`
2. Test with different platforms
3. Test version tagging
4. Test with Docker and Podman (if available)

---

## Troubleshooting

### Common Issues and Solutions

#### Issue: "buildx: command not found"

**Cause:** Docker buildx not installed or enabled

**Solution:**
```bash
# Enable buildx
docker buildx install

# Create builder
docker buildx create --use --name multiarch-builder
```

#### Issue: Build fails with "no match for platform"

**Cause:** Trying to build for unsupported architecture

**Solution:**
```bash
# Check available platforms
docker buildx ls

# Build only for current platform
./build.sh local
```

#### Issue: Permission denied in container

**Cause:** UID/GID mismatch with host user

**Solution:**
```bash
# Rebuild with matching UID/GID
docker build --build-arg USER_UID=$(id -u) --build-arg USER_GID=$(id -g) .
```

#### Issue: Volumes not persisting

**Cause:** Named volumes removed or not created

**Solution:**
```bash
# Check volumes exist
docker volume ls | grep mix

# Recreate if missing
docker compose down -v  # Removes volumes
docker compose up -d    # Creates fresh volumes
```

#### Issue: Port already in use

**Cause:** Another service using port 4000 or 4001

**Solution:**
```bash
# Find process using port
lsof -i :4000

# Kill process or change port in docker-compose.yml
ports:
  - "4002:4000"  # Map to different host port
```

#### Issue: Starship prompt not showing

**Cause:** Starship binary not installed or wrong architecture

**Solution:**
Check Dockerfile lines 67-88 for architecture detection:
```dockerfile
case "$ARCH" in
    amd64) STARSHIP_ARCH="x86_64" ;;
    arm64) STARSHIP_ARCH="aarch64" ;;
    *) echo "Unknown architecture: $ARCH" && exit 1 ;;
esac
```

#### Issue: Fish abbreviations not loading

**Cause:** Configuration not copied or syntax error

**Solution:**
```bash
# Check if files copied
docker compose exec elixir-phoenix ls -la ~/.config/fish/conf.d/

# Test Fish syntax
docker compose exec elixir-phoenix fish -c "source ~/.config/fish/conf.d/elixir.fish"
```

#### Issue: VS Code extensions not installing

**Cause:** Extension ID incorrect or network issues

**Solution:**
1. Check extension ID in `.devcontainer/devcontainer.json`
2. Rebuild container: `Dev Containers: Rebuild Container`
3. Check VS Code logs: `View > Output > Dev Containers`

#### Issue: "exec user process caused: no such file or directory"

**Cause:** Line ending issues (CRLF vs LF) in shell scripts

**Solution:**
```bash
# Convert line endings
dos2unix build.sh
# Or with sed
sed -i 's/\r$//' build.sh
```

### Debugging Commands

**Check container logs:**
```bash
docker compose logs -f elixir-phoenix
```

**Inspect container:**
```bash
docker compose exec elixir-phoenix bash
# Or with fish
docker compose exec elixir-phoenix fish
```

**Check build arguments used:**
```bash
docker inspect devcontainer-elixir-phoenix:latest | grep -A 20 Labels
```

**Verify multi-arch manifest:**
```bash
docker buildx imagetools inspect devcontainer-elixir-phoenix:latest
```

**Test shell configuration:**
```bash
docker compose exec elixir-phoenix fish -c "set"  # Show all variables
docker compose exec elixir-phoenix fish -c "abbr --show"  # Show abbreviations
```

---

## AI Assistant Guidelines

### When Working on This Repository

#### DO:
- ✅ Modify Dockerfile for system-level changes
- ✅ Add shell abbreviations following naming conventions
- ✅ Update README.md with significant changes
- ✅ Test builds locally before committing
- ✅ Use `./build.sh local` for quick validation
- ✅ Follow existing patterns and conventions
- ✅ Update version numbers when dependencies change
- ✅ Add comments explaining WHY, not WHAT
- ✅ Use Fish abbreviation guards to prevent duplicates
- ✅ Document breaking changes clearly

#### DON'T:
- ❌ Create application code (this is a template)
- ❌ Add unnecessary packages
- ❌ Change architecture without good reason
- ❌ Break multi-architecture support
- ❌ Remove existing abbreviations without discussion
- ❌ Push directly to main branch
- ❌ Skip testing multi-arch builds
- ❌ Add secrets or credentials
- ❌ Change base image without reason

### Communication Style

When explaining changes:
- Be specific about file paths and line numbers
- Reference conventions from this document
- Explain rationale for decisions
- Highlight breaking changes
- Suggest testing steps

### Before Marking Work Complete

**Checklist:**
1. ✅ Local build succeeds
2. ✅ Container runs without errors
3. ✅ Changes tested in container
4. ✅ Documentation updated
5. ✅ Commit message follows style
6. ✅ Branch name correct
7. ✅ Push succeeds

---

## Quick Reference

### File Locations

```
Dockerfile                              - Container definition
build.sh                                - Build automation
docker-compose.yml                      - Dev environment
.devcontainer/devcontainer.json        - VS Code config
.zed/tasks.json                        - Zed tasks
shell/config.fish                      - General shell config
shell/conf.d/elixir.fish              - Elixir abbreviations
shell/conf.d/starship.fish            - Prompt config
shell/functions/fish_greeting.fish    - Welcome message
README.md                              - User documentation
LICENSE                                - MIT license
```

### Common Commands

```bash
# Build
./build.sh local                        # Current arch
./build.sh all                          # Multi-arch
./build.sh --version v1.2.3 all        # With version

# Run
docker compose up -d                    # Start detached
docker compose down                     # Stop
docker compose exec elixir-phoenix fish # Shell access

# Test
docker compose ps                       # Check status
docker compose logs -f                  # View logs
curl http://localhost:4000              # Test Phoenix
```

### Version Information

| Component | Version | Location |
|-----------|---------|----------|
| Elixir | 1.19.2 | Dockerfile:1 |
| Erlang | 28.1.1 | Dockerfile:2 |
| Phoenix | 1.8.1 | Dockerfile:3 |
| Debian | Bullseye Slim | Dockerfile:7 |
| Node.js | Latest LTS | Dockerfile:45 |

---

## Additional Resources

### Documentation
- **Main README:** Comprehensive user guide at README.md
- **Archive:** Historical Alpine+Zsh docs at archive/alpine-zsh/README.md
- **License:** MIT license at LICENSE

### External Links
- Elixir: https://elixir-lang.org/
- Phoenix: https://phoenixframework.org/
- Fish Shell: https://fishshell.com/
- Starship: https://starship.rs/
- Docker Buildx: https://docs.docker.com/buildx/

### Repository Information
- **Author:** Paulo Alves Pereira
- **License:** MIT
- **Last Major Update:** 2025-11-11 (Debian + Fish migration)
- **Current Branch:** claude/claude-md-mhyrttsgs6d5qn24-01PBhreSWif2CFSH1TYD3Lb8

---

**End of CLAUDE.md**
