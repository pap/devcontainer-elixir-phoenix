#!/usr/bin/env fish
# Initialize Starship prompt

# Initialize starship prompt if available
if type -q starship
    starship init fish | source
end
