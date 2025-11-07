#!/usr/bin/env fish
# Welcome message for Phoenix devcontainer

function fish_greeting
    echo ""
    echo "🧪 Phoenix Devcontainer version: $PHOENIX_IMAGE_VERSION"
    echo ""
    echo "  Elixir:   $ELIXIR_VERSION"
    echo "  Erlang:   $ERLANG_VERSION"

    # Show Phoenix version
    if type -q mix
        echo "  Phoenix:  "(mix phx.new --version 2>/dev/null | awk '{print $3}' | sed 's/v//g')
    end

    echo ""
end
