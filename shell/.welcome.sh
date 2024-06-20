echo "Phoenix Devcontainer version: $PHOENIX_IMAGE_VERSION\n"
echo `mix hex.info` | awk '{ print "Elixir:   " $4 "\nOTP:      " $6}'
echo `mix phx.new --version` | awk '{ print "Phoenix:  " $3 "\n"}' | sed 's/v//g'
echo "Terminal Docker tools aliases:"
echo " * alpine: launch an interactive alpine 3.20 container"
eval "$(starship init zsh)"
