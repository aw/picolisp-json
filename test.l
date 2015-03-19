#!/usr/bin/env pil

(load "vendor/picolisp-unit/unit.l")

(chdir "test/"
  (mapcar load (filter '((N) (sub? "test_" N)) (dir "."))) )

(unit~report)
