(load (pack (car (file)) "../json.l"))

# Regression tests

# Invalid result from double-quoted strings - https://github.com/aw/picolisp-json/issues/4
[de test-gh-issue-4 ()
  (assert-equal   "{\"etag\":\"\\\"12345\\\"\"}"
                  (encode '(("etag" . "\"12345\"")))
                  "Regression test GH issue #4 - Invalid result from double-quoted strings" ]

[execute
  '(test-gh-issue-4) ]
