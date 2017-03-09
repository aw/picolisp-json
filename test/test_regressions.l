(load (pack (car (file)) "../json.l"))

# Regression tests

# Invalid result from double-quoted strings - https://github.com/aw/picolisp-json/issues/4
[de test-gh-issue-4 ()
  (assert-equal   "{\"etag\":\"\\\"12345\\\"\"}"
                  (encode '(("etag" . "\"12345\"")))
                  "Regression test GH issue #4 - Invalid result from double-quoted strings" ]

# Null and False values are not encoded correctly - https://github.com/aw/picolisp-json/issues/5
[de test-gh-issue-5 ()
  (assert-equal   "{\"anullvalue\":null}"
                  (encode (list (cons "anullvalue" 'null)))
                  "Regression test GH issue #5 - Null values are not encoded correctly" )
  (assert-equal   "{\"afalsevalue\":false}"
                  (encode (list (cons "afalsevalue" 'false)))
                  "Regression test GH issue #5 - False values are not encoded correctly" ]

[execute
  '(test-gh-issue-4)
  '(test-gh-issue-5) ]
