(load (pack (car (file)) "../json.l"))

# Regression tests

# Invalid result from double-quoted strings - https://github.com/aw/picolisp-json/issues/4
[de test-gh-issue-4 ()
  (assert-equal   "{\"etag\":\"\\\"12345\\\"\"}"
                  (json-encode '(("etag" . "\"12345\"")))
                  "Regression test GH issue #4 - Invalid result from double-quoted strings" ]

# Null and False values are not encoded correctly - https://github.com/aw/picolisp-json/issues/5
[de test-gh-issue-5 ()
  (assert-equal   "{\"anullvalue\":null}"
                  (json-encode (list (cons "anullvalue" 'null)))
                  "Regression test GH issue #5 - Null values are not encoded correctly" )
  (assert-equal   "{\"afalsevalue\":false}"
                  (json-encode (list (cons "afalsevalue" 'false)))
                  "Regression test GH issue #5 - False values are not encoded correctly" ]

# Invalid parsing of empty arrays and empty objects - https://github.com/aw/picolisp-json/issues/6
[de test-gh-issue-6 ()
  (assert-equal   '(("test" T 1 2 NIL 4 NIL NIL (T) (T)) ("empty") ("true" . true))
                  (json-decode "{\"test\":[1,2,{},4,{},{},[],[]],\"empty\":{},\"true\":true}")
                  "Regression test GH issue #6 - Invalid parsing of empty arrays and empty objects" ]

# Invalid encoding of true,false,null - https://github.com/aw/picolisp-json/issues/8
[de test-gh-issue-8 ()
  (assert-equal   "{\"test\":\"true\"}"
                  (json-encode '(("test" . "true")))
                  "Regression test GH issue #8 - Invalid encoding of true" )
  (assert-equal   "{\"test\":\"false\"}"
                  (json-encode '(("test" . "false")))
                  "Regression test GH issue #8 - Invalid encoding of false" )
  (assert-equal   "{\"test\":\"null\"}"
                  (json-encode '(("test" . "null")))
                  "Regression test GH issue #8 - Invalid encoding of null" )
  (assert-equal   "{\"test\":true}"
                  (json-encode '(("test" . true)))
                  "Regression test GH issue #8 - Invalid encoding of true" )
  (assert-equal   "{\"test\":false}"
                  (json-encode '(("test" . false)))
                  "Regression test GH issue #8 - Invalid encoding of false" )
  (assert-equal   "{\"test\":null}"
                  (json-encode '(("test" . null)))
                  "Regression test GH issue #8 - Invalid encoding of null" ) ]

######

# Invalid parsing of caret (^) characters - https://github.com/aw/picolisp-json/issues/10
[de test-gh-issue-10 ()
  (assert-equal   '(("test" . "x\^2"))
                  (json-decode "../test4.json" T)
                  "Regression test GH issue #10 - Invalid parsing of caret (\^) characters (1)" )
  (assert-equal   "{\"test\":\"x\^2\"}"
                  (json-encode (json-decode "../test4.json" T))
                  "Regression test GH issue #10 - Invalid parsing of caret (\^) characters (2)" )
  (assert-equal   '(("test" . "x\^2"))
                  (json-decode (json-encode (json-decode "../test4.json" T)))
                  "Regression test GH issue #10 - Invalid parsing of caret (\^) characters (3)" )
  (assert-equal   "{\"test\":\"x\^2\\\\u1234\"}"
                  (json-encode '(("test" . "x\^2\\u1234")))
                  "Regression test GH issue #10 - Invalid parsing of caret (\^) characters (4)" ]

# Invalid encoding of special control (^J^M^I) characters - https://github.com/aw/picolisp-json/issues/11
[de test-gh-issue-11 ()
  (assert-equal   "{\"test\":\"\\n\\r\\t\\b\\f\"}"
                  (json-encode (json-decode "../test5.json" T))
                  "Regression test GH issue #11 - Invalid encoding of special control (\^J\^M\^I) characters (1)" )
  (assert-equal   "{\"test\":\"Hello\\n\\r\\t\\b\\fWorld\"}"
                  (json-encode (list (cons "test" "Hello^J^M^I^H^LWorld")))
                  "Regression test GH issue #11 - Invalid encoding of special control (\^J\^M\^I) characters (2)" ) ]

# Invalid encoding of quote and solidus (\ and ") characters - https://github.com/aw/picolisp-json/issues/12
[de test-gh-issue-12 ()
  (assert-equal   "{\"test\":\"hello\\\"\\\\\"}"
                  (json-encode (json-decode "../test6.json" T))
                  "Regression test GH issue #12 - Invalid encoding of quote and solidus (\\ and \") characters (1)" )
  (assert-equal   "{\"test\":\"Hello\\\\\\\"\\\\\\\\World\"}"
                  (json-encode (list (cons "test" "Hello\\\"\\\\World")))
                  "Regression test GH issue #12 - Invalid encoding of quote and solidus (\\ and \") characters (2)" )
  (assert-equal   "{\"test\":\"/\"}"
                  (json-encode (list (cons "test" "/")))
                  "Regression test GH issue #12 - Invalid encoding of quote and solidus (\\ and \") characters (3)" )
  (assert-equal   "{\"test\":\"/\"}"
                  (json-encode (list (cons "test" "\/")))
                  "Regression test GH issue #12 - Invalid encoding of quote and solidus (\\ and \") characters (4)" )
  (assert-equal   '(("test" . "\/"))
                  (json-decode "{\"test\":\"/\"}")
                  "Regression test GH issue #12 - Invalid encoding of quote and solidus (\\ and \") characters (5)" )
  (assert-equal   '(("test" . "/"))
                  (json-decode "{\"test\":\"/\"}")
                  "Regression test GH issue #12 - Invalid encoding of quote and solidus (\\ and \") characters (6)" ) ]

# Invalid encoding of control characters 01-0x1F - https://github.com/aw/picolisp-json/issues/13
[de test-gh-issue-13 ()
  (assert-equal   "{\"test\":\"\\u0001\\u001E\\u001F \"}"
                  (json-encode (json-decode "../test7.json" T))
                  "Regression test GH issue #13 - Invalid encoding of control characters 0x01-0x1F (1)" )
  (assert-equal   "{\"test\":\"\\u0001\\u001E\\u001F \"}"
                  (json-encode (list (cons "test" (pack "^A^^^_" (char 32)))))
                  "Regression test GH issue #13 - Invalid encoding of control characters 0x01-0x1F (2)" ) ]

}# Invalid parsing of certain characters with \uNNNN - https://github.com/aw/picolisp-json/issues/15
[de test-gh-issue-15 ()
  (assert-equal   '(("test" . "\""))
                  (json-decode "{\"test\":\"\\u0022\"}")
                  "Regression test GH issue #15 - Invalid parsing of certain characters with \uNNNN (1)" )
  (assert-equal   '(("test" . "\\"))
                  (json-decode "{\"test\":\"\\u005c\"}")
                  "Regression test GH issue #15 - Invalid parsing of certain characters with \uNNNN (2)" )
  (assert-equal   '(("test" . "\^"))
                  (json-decode "{\"test\":\"\\u005e\"}")
                  "Regression test GH issue #15 - Invalid parsing of certain characters with \uNNNN (3)" ) ]

#  Unable to parse empty arrays with quotes https://github.com/aw/picolisp-json/issues/19
[de test-gh-issue-19 ()
  (assert-equal   '(("myarray" T) ("test" . 12345))
                  (json-decode "{\"myarray\":[\"\"],\"test\":12345}")
                  "Regression test GH issue #19 - Unable to parse empty arrays with quotes" ) ]

[execute
  '(test-gh-issue-4)
  '(test-gh-issue-5)
  '(test-gh-issue-6)
  '(test-gh-issue-8)
  '(test-gh-issue-10)
  '(test-gh-issue-11)
  '(test-gh-issue-12)
  '(test-gh-issue-13)
  '(test-gh-issue-15)
  '(test-gh-issue-19) ]
