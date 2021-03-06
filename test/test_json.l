(load (pack (car (file)) "../json.l"))

(prinl "^J  Testing JSON encoder/decoder for PicoLisp^J")

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

(setq
  *Json_output2 '(("string" . "lorem ipsum") ("utf string" . "lorem ipsum") ("utf-8 string" . "あいうえお") ("surrogate string" . "lorem𝄞ipsum𝍧lorem") ("positive one" . 1) ("negative one" . -1) ("pi" . 3) ("hard to parse number" . 0) ("big int" . 2147483647) ("big uint" . 4294967295) ("boolean true" . true) ("boolean false" . false) ("null" . null) ("string array" T "lorem" "ipsum") ("x\^2 array" T 0 1 4 9 16 25 36 49 64 81 100) ("/*" . null) ("object" ("nested string" . "str") ("nested true" . true) ("nested false" . false) ("nested null" . null) ("nested number" . 123) ("nested array" T "lorem" "ipsum")) ("*/" . null) ("/**/" . "comment") ("//" . "comment") ("url" . "https://www.example.com/search?q=12345") ("escaped chars" . "\" \\ /") ("empty object") ("empty array" T))
  *Json_output3 '(T "JSON Test Pattern pass1" (("object with 1 member" T "array with 1 element")) NIL (T) -42 true false null (("integer" . 1234567890) ("real" . -9877) (" " . "t") ("zero" . 0) ("one" . 1) ("space" . " ") ("quote" . "\"") ("backslash" . "\\") ("controls" . "^H^L^J^M^I") ("slash" . "/ & /") ("alpha" . "abcdefghijklmnopqrstuvwyz") ("ALPHA" . "ABCDEFGHIJKLMNOPQRSTUVWYZ") ("digit" . "0123456789") ("0123456789" . "digit") ("special" . "`1~!@#$%\^&*()_+-={:[,]}|;.</>?") ("hex" . "ģ䕧覫췯ꯍ") ("true" . true) ("false" . false) ("null" . null) ("array" T) ("object") ("address" . "50 St. James Street") ("url" . "http://www.JSON.org/") ("comment" . "// /* <!-- --") ("# -- --> */" . " "))) )

[de test-decode-string ()
  (assert-equal   '(("Hello" . "World"))
                  (json-decode "{\"Hello\":\"World\"}")
                  "Decode JSON string into a list" ]

[de test-decode-file ()
  (assert-equal *Json_output
                (json-decode "../test.json" T)
                "Decode JSON file into a list" ]

[de test-decode-file2 ()
  (assert-equal *Json_output2
                (json-decode "../test2.json" T)
                "Decode JSON file2 into a list" ]

[de test-decode-file3 ()
  (assert-equal *Json_output3
                (json-decode "../test3.json" T)
                "Decode JSON file3 into a list" ]

[de test-decode-invalid ()
  (assert-nil   (json-decode "{\"I am not JASON\"}")
                "Fail to decode an invalid JSON string" ]

[de test-encode-string ()
  (assert-equal   "{\"Hello\":\"World\"}"
                  (json-encode '(("Hello" . "World")))
                  "Encode list into JSON string" ]

[de test-decode-unicode ()
  (assert-equal   '(("name" . "^H")) (json-decode "{\"name\":\"\\b\"}") "Ensure '\\b' backspace is decoded")
  (assert-equal   '(("name" . "^L")) (json-decode "{\"name\":\"\\f\"}") "Ensure '\\f' formfeed is decoded")
  (assert-equal   '(("name" . "^J")) (json-decode "{\"name\":\"\\n\"}") "Ensure '\\n' newline is decoded")
  (assert-equal   '(("name" . "^M")) (json-decode "{\"name\":\"\\r\"}") "Ensure '\\r' carriage return is decoded")
  (assert-equal   '(("name" . "^I")) (json-decode "{\"name\":\"\\t\"}") "Ensure '\\t' horizontal tab is decoded") ]

[de test-decode-002f ()
  (assert-equal   '(("name" . "/")) (json-decode "{\"name\":\"\\u002F\"}") "Ensure '\\u002F' produces the same result: /")
  (assert-equal   '(("name" . "/")) (json-decode "{\"name\":\"\\u002f\"}") "Ensure '\\u002f' produces the same result: /")
  (assert-equal   '(("name" . "/")) (json-decode "{\"name\":\"\\/\"}") "Ensure '\\/' produces the same result: /")
  (assert-equal   '(("name" . "/")) (json-decode "{\"name\":\"/\"}") "Ensure '/' produces the same result: /") ]

[de test-duplicate-keys ()
  (on *Json_prevent_duplicate_keys)
  (assert-nil      (json-decode "{\"test\":true,\"test\":false}") "Duplicate keys are not allowed")
  (off *Json_prevent_duplicate_keys)
  (assert-equal   '(("test" . true) ("test" . false)) (json-decode "{\"test\":true,\"test\":false}") "Duplicate keys are allowed") ]

[execute
  '(test-decode-string)
  '(test-decode-file)
  '(test-decode-file2)
  '(test-decode-file3)
  '(test-decode-invalid)
  '(test-encode-string)

  # validations since v3.0
  '(assert-nil     (json-decode "{\"Name\":invalid}") "Invalid value returns NIL")
  '(assert-nil     (json-decode "{invalid:\"Value\"}") "Invalid name returns NIL")
  '(assert-nil     (json-decode "{\"Name\":[invalid]}") "Invalid array value returns NIL")
  '(assert-nil     (json-decode "{\"Name\":[1,]") "Invalid array separator returns NIL")
  '(assert-nil     (json-decode "{\"Name\":[1]") "Unmatched JSON brackets returns NIL")
  '(assert-nil     (json-decode "{\"Name\":[1,2,[]}") "Unmatched JSON brackets returns NIL")
  '(assert-nil     (json-decode "{\"Name\":[1}") "Unmatched JSON brackets returns NIL")
  '(assert-nil     (json-decode "{\"Name\":[1,[}") "Unmatched JSON brackets returns NIL")
  '(assert-nil     (json-decode "{}") "Empty object returns NIL")
  '(assert-equal   '(T)  (json-decode "[]") "Empty array returns T list")
  '(assert-equal   '(("name")) (json-decode "{\"name\":{}}") "Empty object value returns object only")
  '(assert-equal   '(("name" T 1 2)) (json-decode "{\"name\":[1,2]}") "Object and array")
  '(assert-equal   '(("name" . -23)) (json-decode "{\"name\":-23}") "Negative numbers are valid")
  '(assert-nil     (json-decode "{\"name\":-garbage}") "Negative garbage returns NIL")
  '(assert-nil     (json-decode "{\"name\"::23}") "Double colons returns NIL")
  '(assert-nil     (json-decode "{\"name\":[1,2,,3]}") "Double commas in Array returns NIL")
  '(assert-nil     (json-decode "{\"name\":true,,\"name2\":false}") "Double commas in Object returns NIL")
  '(assert-equal   '(("name" T 1 2 -3)) (json-decode "{\"name\":[1,2,-3]}") "Array values can be negative numbers")
  '(assert-equal   "{\"name\":[1,2,-23]}" (json-encode (json-decode (json-encode (json-decode "{\"name\":[1,2,-23]}")))) "Yo Dawg, (json-encode (json-decode (json-encode (json-decode...")
  '(test-decode-unicode)
  '(test-decode-002f)
  '(assert-equal   (or (json-decode "{\"name\":invalid}") *Msg) "Invalid Object 'invalid', must be '[' OR '{' OR string OR number OR true OR false OR null" "Error message is stored in *Msg")
  '(test-duplicate-keys) ]
