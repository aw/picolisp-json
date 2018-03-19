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

# Invalid parsing of empty arrays and empty objects - https://github.com/aw/picolisp-json/issues/6
[de test-gh-issue-6 ()
  (assert-equal   '(("test" T 1 2 NIL 4 NIL NIL (T) (T)) ("empty") ("true" . true))
                  (decode "{\"test\":[1,2,{},4,{},{},[],[]],\"empty\":{},\"true\":true}")
                  "Regression test GH issue #6 - Invalid parsing of empty arrays and empty objects" ]

# Invalid encoding of true,false,null - https://github.com/aw/picolisp-json/issues/8
[de test-gh-issue-8 ()
  (assert-equal   "{\"test\":\"true\"}"
                  (encode '(("test" . "true")))
                  "Regression test GH issue #8 - Invalid encoding of true" )
  (assert-equal   "{\"test\":\"false\"}"
                  (encode '(("test" . "false")))
                  "Regression test GH issue #8 - Invalid encoding of false" )
  (assert-equal   "{\"test\":\"null\"}"
                  (encode '(("test" . "null")))
                  "Regression test GH issue #8 - Invalid encoding of null" )
  (assert-equal   "{\"test\":true}"
                  (encode '(("test" . true)))
                  "Regression test GH issue #8 - Invalid encoding of true" )
  (assert-equal   "{\"test\":false}"
                  (encode '(("test" . false)))
                  "Regression test GH issue #8 - Invalid encoding of false" )
  (assert-equal   "{\"test\":null}"
                  (encode '(("test" . null)))
                  "Regression test GH issue #8 - Invalid encoding of null" ) ]

(unless symbols (from "######"))
  [de test-gh-issue-9 ()
    (assert-equal   '(("Hello" . "World"))
                    (json~decode "{\"Hello\":\"World\"}")
                    "Regression test GH issue #9 - json~decode broken outside of 'json' namespace" ) ]

# Invalid parsing of caret (^) characters - https://github.com/aw/picolisp-json/issues/10
[de test-gh-issue-10 ()
  (assert-equal   '(("test" . "x\^2"))
                  (decode "../test4.json" T)
                  "Regression test GH issue #10 - Invalid parsing of caret (\^) characters" ]

######

[execute
  '(test-gh-issue-4)
  '(test-gh-issue-5)
  '(test-gh-issue-6)
  '(test-gh-issue-8)
  (when symbols '(test-gh-issue-9))
  '(test-gh-issue-10) ]
