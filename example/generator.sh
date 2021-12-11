#!/bin/bash

function check_if_available {
  if ! command -v $1 &> /dev/null
  then
      echo "ERROR: $1 could not be found"
      exit 1
  fi
}

function generate {
  check_if_available plantuml
  source="$1.cf"
  shift
  target="$1.puml"
  shift
  echo "generate $source => $target"
  (cd $CORNFLOWER_EXAMPLE_DIR &&
   mkdir -p results &&
   ruby -I ../lib ../bin/cornflower $@ $source -o "results/$target" &&
   plantuml "results/$target")
}

CORNFLOWER_EXAMPLE_DIR=$(dirname "${BASH_SOURCE[0]}")
