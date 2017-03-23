#!/usr/bin/env pil

(unless (= "false" (sys "PIL_NAMESPACES"))
  (when symbols (symbols 'unit 'pico)) )

(load (pack (car (file)) ".modules/picolisp-unit/HEAD/unit.l"))

(chdir "test/"
  (mapcar load (filter '((N) (sub? "test_" N)) (dir "."))) )

(report)
