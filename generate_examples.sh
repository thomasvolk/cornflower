#!/bin/bash

set -e

SOURCE_DIR=$(dirname "${BASH_SOURCE[0]}")
EXAMPLE_DIR="$SOURCE_DIR/example"

. $EXAMPLE_DIR/generator.sh

generate simple simple $@
generate webapp webapp $@

generate cluster cluster $@
generate cluster cluster-components-only -t component $@
generate cluster cluster-components-excluded -e component $@

generate cluster-defaults cluster-defaults $@

generate tagging tagging $@
generate tagging tagging-network-excluded -e network $@
generate tagging tagging-cms-only -t cms $@
generate tagging tagging-shop-only -t shop $@
generate tagging tagging-shop-cms -t shop,cms $@
