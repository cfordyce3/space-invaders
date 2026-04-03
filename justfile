alias b := build
alias r := run

# build into bin/game
@build:
  odin build game/ -out:bin/game
  echo "Game built successfully to bin/game"

# run bin/game
@run: build
  ./bin/game
