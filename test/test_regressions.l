# Regression tests

# Invalid result from double-quoted strings - https://github.com/aw/picolisp-json/issues/4
[de test-gh-issue-4 ()
  (unit~assert-equal  "{\"etag\":\"\\\"12345\\\"\"}"
                      (json~encode '(("etag" . "\"12345\"")))
                      "Regression test GH issue #4 - Invalid result from double-quoted strings" ]

[unit~execute
  '(test-gh-issue-4) ]
