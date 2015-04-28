#!/usr/bin/env pil

(load ".modules/picolisp-unit/HEAD/unit.l")

(chdir "test/"
  (mapcar load (filter '((N) (sub? "test_" N)) (dir "."))) )

(unit~report)
