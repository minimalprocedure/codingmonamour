#!/bin/bash

################################################################################
## Initial developer: Massimo Maria Ghisalberti <massimo.ghisalberti@gmail.org>
## Date: 2016-12-18
## Company: Pragmas <contact.info@pragmas.org>
## Licence: Apache License Version 2.0, http://www.apache.org/licenses/
################################################################################
export PATH=$RUBY23:$PATH

bundle exec rackup --port 3000 --host 0.0.0.0
