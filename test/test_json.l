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
  *Json_output2 '(("string" . "lorem ipsum") ("utf string" . "lorem ipsum") ("utf-8 string" . "あいうえお") ("surrogate string" . "lorem݄ީpsumݍ笯rem") ("positive one" . 1) ("negative one" . -1) ("pi" . 3) ("hard to parse number" . 0) ("big int" . 2147483647) ("big uint" . 4294967295) ("boolean true" . true) ("boolean false" . false) ("null" . null) ("string array" T "lorem" "ipsum") ("x\^2 array" T 0 1 4 9 16 25 36 49 64 81 100) ("/*" . null) ("object" ("nested string" . "str") ("nested true" . true) ("nested false" . false) ("nested null" . null) ("nested number" . 123) ("nested array" T "lorem" "ipsum")) ("*/" . null) ("/**/" . "comment") ("//" . "comment") ("url" . "https://www.example.com/search?q=12345") ("escaped chars" . "\" \\ /") ("empty object") ("empty array" T))
  *Json_output3 '(T "JSON Test Pattern pass1" (("object with 1 member" T "array with 1 element")) NIL (T) -42 true false null (("integer" . 1234567890) ("real" . -9877) (" " . "t") ("zero" . 0) ("one" . 1) ("space" . " ") ("quote" . "\"") ("backslash" . "\\") ("controls" . "^H^L^J^M^I") ("slash" . "/ & /") ("alpha" . "abcdefghijklmnopqrstuvwyz") ("ALPHA" . "ABCDEFGHIJKLMNOPQRSTUVWYZ") ("digit" . "0123456789") ("0123456789" . "digit") ("special" . "`1~!@#$%\^&*()_+-={:[,]}|;.</>?") ("hex" . "ģ䕧覫췯ꯍ") ("true" . true) ("false" . false) ("null" . null) ("array" T) ("object") ("address" . "50 St. James Street") ("url" . "http://www.JSON.org/") ("comment" . "// /* <!-- --") ("# -- --> */" . " "))) )

[de test-decode-string ()
  (assert-equal   '(("Hello" . "World"))
                  (decode "{\"Hello\":\"World\"}")
                  "Decode JSON string into a list" ]

[de test-decode-file ()
  (assert-equal *Json_output
                (decode "../test.json" T)
                "Decode JSON file into a list" ]

[de test-decode-file2 ()
  (assert-equal *Json_output2
                (decode "../test2.json" T)
                "Decode JSON file2 into a list" ]

[de test-decode-file3 ()
  (assert-equal *Json_output3
                (decode "../test3.json" T)
                "Decode JSON file3 into a list" ]

[de test-decode-invalid ()
  (assert-nil   (decode "{\"I am not JASON\"}")
                "Fail to decode an invalid JSON string" ]

[de test-encode-string ()
  (assert-equal   "{\"Hello\":\"World\"}"
                  (encode '(("Hello" . "World")))
                  "Encode list into JSON string" ]

[de test-decode-unicode ()
  (assert-equal   '(("name" . "^H")) (decode "{\"name\":\"\\b\"}") "(unicode) Ensure '\\b' backspace is decoded")
  (assert-equal   '(("name" . "^L")) (decode "{\"name\":\"\\f\"}") "(unicode) Ensure '\\f' formfeed is decoded")
  (assert-equal   '(("name" . "^J")) (decode "{\"name\":\"\\n\"}") "(unicode) Ensure '\\n' newline is decoded")
  (assert-equal   '(("name" . "^M")) (decode "{\"name\":\"\\r\"}") "(unicode) Ensure '\\r' carriage return is decoded")
  (assert-equal   '(("name" . "^I")) (decode "{\"name\":\"\\t\"}") "(unicode) Ensure '\\t' horizontal tab is decoded") ]

[de test-decode-002f ()
  (assert-equal   '(("name" . "/")) (decode "{\"name\":\"\\u002F\"}") "(\\u002f) Ensure '\\u002F' produces the same result: /")
  (assert-equal   '(("name" . "/")) (decode "{\"name\":\"\\u002f\"}") "(\\u002f) Ensure '\\u002f' produces the same result: /")
  (assert-equal   '(("name" . "/")) (decode "{\"name\":\"\\/\"}") "(\\u002f) Ensure '\\/' produces the same result: /")
  (assert-equal   '(("name" . "/")) (decode "{\"name\":\"/\"}") "(\\u002f) Ensure '/' produces the same result: /") ]

[de test-decode-scientific ()
  (assert-equal   (quote ("name" . `(intern (pack "1." 234)))) (decode "{\"name\":1.234}") "(scientific) Ensure '1.234' is decoded")
  (assert-equal   '(("name" . 1.234e32)) (decode "{\"name\":1.234e32}") "(scientific) Ensure '1.234e32' is decoded")
  (assert-equal   '(("name" . 1.234E32)) (decode "{\"name\":1.234E32}") "(scientific) Ensure '1.234E32' is decoded")
  (assert-equal   '(("name" . 1.234e+32)) (decode "{\"name\":1.234e+32}") "(scientific) Ensure '1.234e+32' is decoded")
  (assert-equal   '(("name" . 1.234e-32)) (decode "{\"name\":1.234e-32}") "(scientific) Ensure '1.234e-32' is decoded")
  (assert-equal   '(("name" . 156.234e+32)) (decode "{\"name\":156.234e+32}") "(scientific) Ensure '156.234e+32' is decoded")
  (assert-equal   '(("name" . "156.234")) (decode "{\"name\":156.234}") "(scientific) Ensure '156.234' is decoded")
  (assert-equal   '(("name" . "-9876.543210")) (decode "{\"name\":-9876.543210}") "(scientific) Ensure '-9876.543210' is decoded")
  (assert-equal   '(("name" . -9876.543210e+32)) (decode "{\"name\":-9876.543210e+32}") "(scientific) Ensure '-9876.543210e+32' is decoded")
  (assert-nil     (decode "{\"name\":-1.23e}") "(scientific) Ensure '-1.23e' returns NIL")
  (assert-nil     (decode "{\"name\":1.234e}") "(scientific) Ensure '1.234e' returns NIL")
  (assert-nil     (decode "{\"name\":12234e}") "(scientific) Ensure '12234e' returns NIL")
  (assert-nil     (decode "{\"name\":1.234-}") "(scientific) Ensure '1.234-' returns NIL")
  (assert-nil     (decode "{\"name\":1.234+}") "(scientific) Ensure '1.234+' returns NIL") ]

[execute
  '(test-decode-string)
  '(test-decode-file)
  '(test-decode-file2)
  '(test-decode-file3)
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
  '(assert-equal   '(("name" T 1 2 -3)) (decode "{\"name\":[1,2,-3]}") "Array values can be negative numbers")
  '(assert-equal   "{\"name\":[1,2,-23]}" (encode (decode (encode (decode "{\"name\":[1,2,-23]}")))) "Yo Dawg, (encode (decode (encode (decode...")
  '(test-decode-unicode)
  '(test-decode-002f)
  '(test-decode-scientific) ]
