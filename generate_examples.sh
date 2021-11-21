#!/bin/bash

function check_if_available {
  if ! command -v $1 &> /dev/null
  then
      echo "ERROR: $1 could not be found"
      exit 1
  fi
}

function generate {
  echo "generate '$1'"
  (cd example && ruby -I ../lib ../bin/cornflower $1.cf -o $1.puml && plantuml $1.puml)
}

check_if_available plantuml
generate simple
generate webapp
generate composite


