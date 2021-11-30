#!/bin/bash

set -e

. example/generator.sh

generate simple simple $@
generate webapp webapp $@

generate cluster cluster $@
generate cluster cluster-component-level -t component $@
generate cluster cluster-infrastructure-level -t component -e $@

generate cluster-defaults cluster-defaults $@

generate tagging tagging $@
generate tagging tagging-no-network -t network -e  $@
generate tagging tagging-cms -t cms $@
generate tagging tagging-shop -t shop $@
generate tagging tagging-shop-cms -t shop,cms $@
