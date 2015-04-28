#!/bin/sh
#
# Copyright (c) 2015 Alexander Williams, Unscramble <license@unscramble.jp>
# MIT License
#
# For backwards compatibility

set -u
set -e

# cleanup artifacts
rm -rf lib vendor

# rebuild
make
