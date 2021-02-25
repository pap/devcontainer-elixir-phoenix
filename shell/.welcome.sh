echo "Phoenix Devcontainer version: $PHOENIX_IMAGE_VERSION\n"
echo `mix hex.info` | awk '{ print "Elixir:   " $4 "\nOTP:      " $6}'
echo `mix phx.new --version` | awk '{ print "Phoenix:  " $2 "\n"}' | sed 's/v//g'
echo "Terminal Docker tools aliases:"
echo " * alpine: launch an interactive alpine 3.11 container"
echo " * dive: inspect the layers of a Docker image"
echo " * ld: run lazydocker in a container"
eval "$(starship init zsh)"
