#!/bin/bash

. example/generator.sh

gen simple $@
gen webapp $@
gen composite $@
generate composite composite-component-level -t component $@
generate composite composite-infrastructure-level -t component -e $@


