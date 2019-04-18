#!/usr/bin/env pil

(load (pack (car (file)) ".modules/picolisp-unit/HEAD/unit.l"))

(chdir "test/"
  (mapcar load (filter '((N) (sub? "test_" N)) (dir "."))) )

(report)
