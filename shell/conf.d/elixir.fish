#!/usr/bin/env fish
# Elixir/Phoenix specific configuration

# Only add abbreviations if they don't already exist (idempotent)
if not abbr --query m 2>/dev/null
    # Mix abbreviations
    abbr --add --universal m mix
    abbr --add --universal mt 'mix test'
    abbr --add --universal mc 'mix compile'
    abbr --add --universal mf 'mix format'
    abbr --add --universal mdg 'mix deps.get'
    abbr --add --universal mdc 'mix deps.compile'
    abbr --add --universal mdga 'mix do deps.get, deps.compile'

    # Phoenix abbreviations
    abbr --add --universal mps 'mix phx.server'
    abbr --add --universal mpn 'mix phx.new'
    abbr --add --universal mpr 'mix phx.routes'
    abbr --add --universal ix 'iex -S mix'

    # Phoenix Generators
    abbr --add --universal mpgc 'mix phx.gen.context'
    abbr --add --universal mpgh 'mix phx.gen.html'
    abbr --add --universal mpgj 'mix phx.gen.json'
    abbr --add --universal mpgl 'mix phx.gen.live'
    abbr --add --universal mpgs 'mix phx.gen.schema'
    abbr --add --universal mpga 'mix phx.gen.auth'

    # Ecto Database Commands
    abbr --add --universal mer 'mix ecto.reset'
    abbr --add --universal mec 'mix ecto.create'
    abbr --add --universal med 'mix ecto.drop'
    abbr --add --universal mem 'mix ecto.migrate'
    abbr --add --universal merb 'mix ecto.rollback'
    abbr --add --universal megm 'mix ecto.gen.migration'
    abbr --add --universal mes 'mix ecto.setup'

    # Ash Framework
    abbr --add --universal mai 'mix ash.install'
    abbr --add --universal maga 'mix ash.gen.resource'
    abbr --add --universal magd 'mix ash.gen.domain'
    abbr --add --universal magm 'mix ash.gen.migration'
    abbr --add --universal mage 'mix ash.gen.enum'

    # Ash Database
    abbr --add --universal mam 'mix ash.migrate'
    abbr --add --universal mamcr 'mix ash.migrate --revert'
    abbr --add --universal mams 'mix ash.setup'
    abbr --add --universal mamr 'mix ash.reset'
    abbr --add --universal mamd 'mix ash.drop'

    # Ash Code Generation
    abbr --add --universal macg 'mix ash.codegen'
    abbr --add --universal maf 'mix ash.format'

    # Ash Phoenix Generators
    abbr --add --universal mapgl 'mix ash_phoenix.gen.live'
    abbr --add --universal mapgh 'mix ash_phoenix.gen.html'

    # Development Tools (optional - if using these packages)
    abbr --add --universal mdd 'mix dialyzer'
    abbr --add --universal mcr 'mix credo'
    abbr --add --universal mcs 'mix coveralls'
    abbr --add --universal mtw 'mix test.watch'
end
