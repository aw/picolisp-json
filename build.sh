#!/bin/sh
#
# Copyright (c) 2015 Alexander Williams, Unscramble <license@unscramble.jp>
# MIT License

set -u
set -e

git submodule init
git submodule update

cd vendor/parson
  rm -f libparson.so
  gcc -O0 -g -Wall -Wextra -std=c89 -pedantic-errors -fPIC -shared -Wl,-soname,libparson.so -o libparson.so parson.c
cd -

cd lib
  rm -f libparson.so
  ln -s ../vendor/parson/libparson.so libparson.so
cd -
