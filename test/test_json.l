(load (pack (car (file)) "../json.l"))

(prinl "^J  Testing JSON encoder/decoder for PicoLisp^J")

(unless (= "false" (sys "PIL_NAMESPACES"))
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

[de test-decode-unicode ()
  (assert-equal   '(("name" . "^H")) (decode "{\"name\":\"\\b\"}") "Ensure '\\b' backspace is decoded")
  (assert-equal   '(("name" . "^L")) (decode "{\"name\":\"\\f\"}") "Ensure '\\f' formfeed is decoded")
  (assert-equal   '(("name" . "^J")) (decode "{\"name\":\"\\n\"}") "Ensure '\\n' newline is decoded")
  (assert-equal   '(("name" . "^M")) (decode "{\"name\":\"\\r\"}") "Ensure '\\r' carriage return is decoded")
  (assert-equal   '(("name" . "^I")) (decode "{\"name\":\"\\t\"}") "Ensure '\\t' horizontal tab is decoded") ]

[de test-decode-002f ()
  (assert-equal   '(("name" . "/")) (decode "{\"name\":\"\\u002F\"}") "Ensure '\\u002F' produces the same result: /")
  (assert-equal   '(("name" . "/")) (decode "{\"name\":\"\\u002f\"}") "Ensure '\\u002f' produces the same result: /")
  (assert-equal   '(("name" . "/")) (decode "{\"name\":\"\\/\"}") "Ensure '\\/' produces the same result: /")
  (assert-equal   '(("name" . "/")) (decode "{\"name\":\"/\"}") "Ensure '/' produces the same result: /") ]

[execute
  '(test-decode-string)
  '(test-decode-file)
  '(test-decode-invalid)
  '(test-encode-string)

  # validations since v3.0
  '(assert-nil     (decode "{\"Name\":invalid}") "Invalid value returns NIL")
  '(assert-nil     (decode "{invalid:\"Value\"}") "Invalid name returns NIL")
  '(assert-nil     (decode "{\"Name\":[invalid]}") "Invalid array value returns NIL")
  '(assert-nil     (decode "{\"Name\":[1,]") "Invalid array separator returns NIL")
  '(assert-nil     (decode "{\"Name\":[1]") "Unmatched JSON brackets returns NIL")
  '(assert-nil     (decode "{\"Name\":[1,2,[]}") "Unmatched JSON brackets returns NIL")
  '(assert-nil     (decode "{\"Name\":[1}") "Unmatched JSON brackets returns NIL")
  '(assert-nil     (decode "{\"Name\":[1,[}") "Unmatched JSON brackets returns NIL")
  '(assert-nil     (decode "{}") "Empty object returns NIL")
  '(assert-equal   '(T)  (decode "[]") "Empty array returns T list")
  '(assert-equal   '(("name")) (decode "{\"name\":{}}") "Empty object value returns object only")
  '(assert-equal   '(("name" T 1 2)) (decode "{\"name\":[1,2]}") "Object and array")
  '(assert-equal   '(("name" . -23)) (decode "{\"name\":-23}") "Negative numbers are valid")
  '(assert-nil     (decode "{\"name\":-garbage}") "Negative garbage returns NIL")
  '(assert-nil     (decode "{\"name\"::23}") "Double colons returns NIL")
  '(assert-nil     (decode "{\"name\":[1,2,,3]}") "Double commas in Array returns NIL")
  '(assert-nil     (decode "{\"name\":true,,\"name2\":false}") "Double commas in Object returns NIL")
  '(test-decode-unicode)
  '(test-decode-002f) ]
