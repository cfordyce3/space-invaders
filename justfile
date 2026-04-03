alias b := build
alias r := run
alias br := build-run

# build into bin/game
@build:
  odin build game/ -out:bin/game
  echo "Game built successfully to bin/game"

# run existing bin/game
@run:
  ./bin/game

@build-run:
  odin build game/ -out:bin/game
  ./bin/game
