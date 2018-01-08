# json.l
#
# The MIT License (MIT)
#
# Copyright (c) 2017-2018 Alexander Williams, Unscramble <license@unscramble.jp>

(unless (= "false" (sys "PIL_NAMESPACES"))
  (symbols 'json 'pico)

  (local MODULE_INFO *Msg)
  (local json-parse-file json-parse-string json-count-brackets)
  (local json-check-value json-object-get-name json-object-get-value)
  (local link-array link-object)
  (local iterate-object iterate-list make-null make-boolean make-json-number)
  (local make-json-string make-json-array make-object make-array) )

(load (pack (car (file)) "module.l"))

# send error message to STDERR
[de err-throw (Error)
  (msg Error)
  (throw 'invalid-json NIL) ]

# json
[de json-parse-file (File)
  (json-parse-string (in File (till NIL T) ]

[de json-parse-string (Value)
  (let Str (str (json-parse-unicode (chop Value)) "_")
    (json-count-brackets Str)
    Str ]

[de json-parse-unicode (Value)
  (pack
    (make
      (while Value
        (let R (pop 'Value)
          (cond
            [(and (= "\\" R) (= "u" (car Value))) (let U (cut 5 'Value) (link (char (hex (pack (tail 4 U) ] # \uNNNN hex
            [(and (= "\\" R) (= "b" (car Value))) (pop 'Value) (link (char (hex "08") ] # \b backspace
            [(and (= "\\" R) (= "f" (car Value))) (pop 'Value) (link (char (hex "0C") ] # \f formfeed
            (T (link R)) ]

[de json-count-brackets (Str)
  (use *Json_stack
    (off *Json_stack)
    (mapc '((N)
            (if (or (= "{" N) (= "[" N))
                (push '*Json_stack N)
                (case N
                  ("]" (let R (pop '*Json_stack) (unless (= "[" R) (err-throw "Unmatched JSON brackets '['"))))
                  ("}" (let R (pop '*Json_stack) (unless (= "{" R) (err-throw "Unmatched JSON brackets '{'")))) ) ) )
            Str )
    (when *Json_stack (err-throw (text "Unmatched JSON brackets '@1'", (pop *Json_stack) ]

[de json-check-value (Value)
  (or
    (= "," Value)
    (= "{" Value)
    (= "[" Value)
    (= "]" Value)
    (lst? Value)
    (num? Value)
    (= "-" Value)
    (= 'true Value)
    (= 'false Value)
    (= 'null Value)
    (err-throw (text "Invalid Array value '@1', must be ',' OR '{' OR '[' OR ']' OR string OR number OR true OR false OR null", Value) ]

[de json-object-get-name (Obj)
  (cond
    ((lst? Obj)   (pack Obj))
    ((= "}" Obj)  NIL)
    (T (err-throw (text "Invalid Object name '@1', must be '}' OR string", Obj) ]

[de json-object-get-value (Obj Value)
  (cond
    ((= ":" Obj) Value)
    ((= "]" Obj) NIL)
    (T (err-throw (text "Invalid Object value '@1', must be ':' OR ']'", Obj) ]

# internal
[de link-array ()
  (link (iterate-object))
  (let Res (pop '*Json)
    (case Res
      ("," (json-check-value (car *Json)) (link-array)) ]

[de link-object ()
  (let (Name (json-object-get-name (pop '*Json))
        Val  (json-object-get-value (pop '*Json) *Json) )
    (when Name (link (cons Name (iterate-object))))
    (when (= "," (pop '*Json))
          (link-object) ]

[de iterate-object ()
  (make
    (let Type (pop '*Json)
      (cond
        ((= "[" Type)     (link T) (unless (= "]" (car *Json)) (link-array)))
        ((= "{" Type)     (unless (= "}" (car *Json)) (link-object)))
        ((lst? Type)      (chain (pack Type)))
        ((num? Type)      (chain Type))
        ((= "-" Type)     (if (num? (car *Json)) (chain (format (pack "-" (pop '*Json)))) (iterate-object)))
        ((= 'true Type)   (chain 'true))
        ((= 'false Type)  (chain 'false))
        ((= 'null Type)   (chain 'null))
        (T                (err-throw (text "Invalid Object '@1', must be '[' OR '{' OR string OR number OR true OR false OR null", Type) ]

[de iterate-list (Item)
  (let Value (cdr Item)
    (or
      (make-null Value)
      (make-boolean Value)
      (make-json-number Value)
      (make-json-string Value)
      (make-json-array Value)
      (make-object Value) ]

[de make-null (Value)
  (when (= 'null Value) "null") ]

[de make-boolean (Value)
  (cond ((= 'true Value)  "true")
        ((= 'false Value) "false") ]

[de make-json-number (Value)
  (when (num? Value) Value) ]

[de make-json-string (Value)
  (when (str? Value) (sym Value) ]

[de make-json-array (Value)
  (when (=T (car Value)) (make-array (cdr Value))) ]

[de make-object (Value)
  (pack "{"
        (glue ","
              (mapcar
                '((N) (pack "\"" (car N) "\":" (iterate-list N)))
                Value ) )
        "}" ]

[de make-array (Value)
  (pack "["
        (glue ","
              (mapcar
                '((N) (iterate-list (cons NIL N)))
                Value ) )
        "]" ]


# public
[de decode (Value Type)
  (catch 'invalid-json
    (use *Json
      (setq *Json
        (if Type
            (json-parse-file Value)
            (json-parse-string Value) ) )
      (when *Json
            (iterate-object) ) ]

[de encode (Value)
  (if (=T (car Value))
      (make-array (cdr Value))
      (make-object Value) ]
