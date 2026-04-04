alias b := build
alias r := run
alias br := build-run

# build into bin/game
@build:
  odin build src/ -out:bin/game
  echo "Game built successfully to bin/game"

# run existing bin/game
@run:
  ./bin/game

# build game to bin/game then run it
@build-run:
  odin build src/ -out:bin/game
  ./bin/game
