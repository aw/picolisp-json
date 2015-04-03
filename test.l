#!/usr/bin/env pil

(load ".modules/picolisp-unit/unit.l")

(chdir "test/"
  (mapcar load (filter '((N) (sub? "test_" N)) (dir "."))) )

(unit~report)
