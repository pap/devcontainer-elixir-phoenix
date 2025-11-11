#!/usr/bin/env bash
set -e

# Detect current architecture
detect_platform() {
    local arch=$(uname -m)
    case $arch in
        x86_64)
            echo "linux/amd64"
            ;;
        aarch64|arm64)
            echo "linux/arm64"
            ;;
        *)
            echo_error "Unsupported architecture: $arch"
            exit 1
            ;;
    esac
}

# Configuration
VERSION="${VERSION:-$(date -u +"%Y%m%d-%H%M%S")-$(git rev-parse --short HEAD)}"
PLATFORMS="${PLATFORMS:-linux/amd64,linux/arm64}"
CONTAINER_TOOL="${CONTAINER_TOOL:-docker}"
PUSH="${PUSH:-false}"
REGISTRY="${REGISTRY:-}"
IMAGE_NAME="devcontainer-elixir-phoenix"

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo_info() {
    echo -e "${GREEN}==>${NC} $1"
}

echo_warn() {
    echo -e "${YELLOW}WARNING:${NC} $1"
}

echo_error() {
    echo -e "${RED}ERROR:${NC} $1"
}

# Check if buildx is available for Docker
check_buildx() {
    if [ "$CONTAINER_TOOL" = "docker" ]; then
        if ! docker buildx version &> /dev/null; then
            echo_error "Docker Buildx is required for multi-platform builds"
            echo "Install it from: https://docs.docker.com/buildx/working-with-buildx/"
            exit 1
        fi

        # Create and use a new builder instance if needed
        if ! docker buildx inspect multiarch-builder &> /dev/null; then
            echo_info "Creating multiarch-builder..."
            docker buildx create --name multiarch-builder --use
        else
            docker buildx use multiarch-builder
        fi
    fi
}

# Main build process
main() {
    echo ""
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║  Devcontainer Elixir Phoenix - Multi-Arch Build Script     ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo ""
    echo "Configuration:"
    echo "  Version:    ${VERSION}"
    echo "  Platforms:  ${PLATFORMS}"
    echo "  Tool:       ${CONTAINER_TOOL}"
    echo "  Registry:   ${REGISTRY:-<none>}"
    echo "  Push:       ${PUSH}"
    echo ""

    # Check prerequisites
    if [ "$CONTAINER_TOOL" = "docker" ]; then
        check_buildx

        echo_info "Building ${IMAGE_NAME}:${VERSION}"

        local build_cmd="docker buildx build"
        build_cmd="$build_cmd --platform ${PLATFORMS}"
        build_cmd="$build_cmd --build-arg VERSION=${VERSION}"
        build_cmd="$build_cmd -t ${IMAGE_NAME}:latest"
        build_cmd="$build_cmd -t ${IMAGE_NAME}:${VERSION}"

        if [ -n "$REGISTRY" ]; then
            build_cmd="$build_cmd -t ${REGISTRY}/${IMAGE_NAME}:latest"
            build_cmd="$build_cmd -t ${REGISTRY}/${IMAGE_NAME}:${VERSION}"
        fi

        if [ "$PUSH" = "true" ]; then
            build_cmd="$build_cmd --push"
        else
            build_cmd="$build_cmd --load"
        fi

        build_cmd="$build_cmd ."

        echo "  Command: ${build_cmd}"
        eval $build_cmd

    elif [ "$CONTAINER_TOOL" = "podman" ]; then
        echo_warn "Podman multi-arch builds require creating manifests"

        # Build for each platform separately
        IFS=',' read -ra PLATFORM_ARRAY <<< "$PLATFORMS"
        for platform in "${PLATFORM_ARRAY[@]}"; do
            echo_info "Building for ${platform}..."
            podman build \
                --platform "$platform" \
                --build-arg VERSION="${VERSION}" \
                -t "${IMAGE_NAME}:${VERSION}-${platform//\//-}" \
                .
        done

        # Create manifest
        echo_info "Creating manifest ${IMAGE_NAME}:${VERSION}..."
        podman manifest create "${IMAGE_NAME}:${VERSION}"

        for platform in "${PLATFORM_ARRAY[@]}"; do
            podman manifest add "${IMAGE_NAME}:${VERSION}" \
                "${IMAGE_NAME}:${VERSION}-${platform//\//-}"
        done

        # Tag as latest
        podman tag "${IMAGE_NAME}:${VERSION}" "${IMAGE_NAME}:latest"

        if [ "$PUSH" = "true" ] && [ -n "$REGISTRY" ]; then
            echo_info "Pushing manifest to registry..."
            podman manifest push "${IMAGE_NAME}:${VERSION}" \
                "docker://${REGISTRY}/${IMAGE_NAME}:${VERSION}"
            podman manifest push "${IMAGE_NAME}:${VERSION}" \
                "docker://${REGISTRY}/${IMAGE_NAME}:latest"
        fi
    else
        echo_error "Unsupported container tool: ${CONTAINER_TOOL}"
        echo "Supported tools: docker, podman"
        exit 1
    fi

    echo ""
    echo_info "╔════════════════════════════════════════════════════════════╗"
    echo_info "║                  Build Complete! 🎉                        ║"
    echo_info "╚════════════════════════════════════════════════════════════╝"
    echo ""
    echo "Image created: ${IMAGE_NAME}:${VERSION}"
    echo ""
    echo "To run the container:"
    echo "  ${CONTAINER_TOOL} run -it --rm -p 4000:4000 ${IMAGE_NAME}:${VERSION}"
    echo ""
    if [ "$PUSH" = "false" ]; then
        echo "To push to registry:"
        echo "  PUSH=true REGISTRY=<your-registry> ./build.sh"
        echo ""
    fi
}

# Show usage
usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Build multi-architecture devcontainer image for Elixir/Phoenix development.

OPTIONS:
    -h, --help          Show this help message
    -v, --version       Set version tag (default: YYYYMMDD-<git-hash>)
    -p, --platforms     Platforms to build for (default: all)
                        Use shortcuts: local, amd64, arm64, all
                        Or specify: linux/amd64, linux/arm64, linux/amd64,linux/arm64
    -t, --tool          Container tool: docker or podman (default: docker)
    -r, --registry      Registry to push to (e.g., ghcr.io/username)
    --push              Push image to registry after build

ENVIRONMENT VARIABLES:
    VERSION             Image version tag
    PLATFORMS           Comma-separated list of platforms
    CONTAINER_TOOL      docker or podman
    REGISTRY            Container registry URL
    PUSH                true to push image

PLATFORM SHORTCUTS:
    local, native, current    Build for current architecture only (fast!)
    amd64, x86_64             Build for AMD64/Intel only
    arm64, aarch64            Build for ARM64 only (Apple Silicon, etc.)
    all, both, multi          Build for both amd64 and arm64 (default)

EXAMPLES:
    # Build for current platform only (fastest - great for local dev)
    ./build.sh --platforms local
    PLATFORMS=local ./build.sh

    # Build for specific architecture
    ./build.sh --platforms amd64
    ./build.sh --platforms arm64

    # Build for all architectures (default)
    ./build.sh --platforms all
    ./build.sh

    # Build with full platform specification
    ./build.sh --platforms linux/amd64,linux/arm64

    # Build and push to registry
    PUSH=true REGISTRY=ghcr.io/myuser ./build.sh

    # Build with Podman for local platform only
    CONTAINER_TOOL=podman PLATFORMS=local ./build.sh

    # Build specific version for all platforms
    VERSION=1.0.0 ./build.sh

EOF
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            usage
            exit 0
            ;;
        -v|--version)
            VERSION="$2"
            shift 2
            ;;
        -p|--platforms)
            PLATFORMS="$2"
            shift 2
            ;;
        -t|--tool)
            CONTAINER_TOOL="$2"
            shift 2
            ;;
        -r|--registry)
            REGISTRY="$2"
            shift 2
            ;;
        --push)
            PUSH=true
            shift
            ;;
        *)
            echo_error "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

# Process platform shortcuts
case $PLATFORMS in
    local|native|current)
        PLATFORMS=$(detect_platform)
        echo_info "Building for current platform: $PLATFORMS"
        ;;
    amd64|x86_64)
        PLATFORMS="linux/amd64"
        ;;
    arm64|aarch64)
        PLATFORMS="linux/arm64"
        ;;
    all|both|multi)
        PLATFORMS="linux/amd64,linux/arm64"
        ;;
esac

# Run main build
main
