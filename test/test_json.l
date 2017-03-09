(load (pack (car (file)) "../json.l"))

(prinl "^J  Testing JSON encoder/decoder for PicoLisp^J")

(unless (sys "PIL_NO_NAMESPACES")
  (symbols 'json) )

(setq
      *My_tests_are_order_dependent NIL
      *Json_output '(("first" . "John")
                    ("last" . "Doe")
                    ("age" . 25)
                    ("registered" . true)
                    ("interests" T "Reading" "Mountain Biking")
                    ("favorites" ("color" . "blue") ("sport" . "running"))
                    ("utf string" . "lorem ipsum")
                    ("utf-8 string" . "あいうえお")
                    ("surrogate string" . "lorem ipsum lorem") ) )

[de test-decode-string ()
  (assert-equal   '(("Hello" . "World"))
                  (decode "{\"Hello\":\"World\"}")
                  "Decode JSON string into a list" ]

[de test-decode-file ()
  (assert-equal *Json_output
                (decode "../test.json" T)
                "Decode JSON file into a list" ]

[de test-decode-invalid ()
  (assert-nil   (decode "{\"I am not JASON\"}")
                "Fail to decode an invalid JSON string" ]

[de test-encode-string ()
  (assert-equal   "{\"Hello\":\"World\"}"
                  (encode '(("Hello" . "World")))
                  "Encode list into JSON string" ]

[execute
  '(test-decode-string)
  '(test-decode-file)
  '(test-decode-invalid)
  '(test-encode-string) ]
