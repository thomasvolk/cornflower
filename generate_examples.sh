#!/bin/bash

function check_if_available {
  if ! command -v $1 &> /dev/null
  then
      echo "ERROR: $1 could not be found"
      exit 1
  fi
}

function generate {
  name=$1
  shift
  echo "generate '$name'"
  (cd example && ruby -I ../lib ../bin/cornflower $@ $name.cf -o $name.puml && plantuml $name.puml)
}

check_if_available plantuml
generate simple $@
generate webapp $@
generate composite $@


