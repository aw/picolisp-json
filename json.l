# json.l
#
# The MIT License (MIT)
#
# Copyright (c) 2017-2018 Alexander Williams, Unscramble <license@unscramble.jp>

(unless (= "false" (sys "PIL_NAMESPACES"))
  (symbols 'json 'pico)

  (local MODULE_INFO *Msg)
  (local json-parse-file json-parse-string json-count-brackets)
  (local json-array-check-value json-object-check-name json-object-check-separator)
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

[de json-array-check-value (Value)
  (or
    (= "{" Value)
    (= "[" Value)
    (= "]" Value)
    (lst? Value)
    (num? Value)
    (= "-" Value)
    (= 'true Value)
    (= 'false Value)
    (= 'null Value)
    (err-throw (text "Invalid Array value '@1', must be {' OR '[' OR ']' OR string OR number OR true OR false OR null", Value) ]

[de json-object-check-name (Name)
  (or
    (lst? Name)
    (= "}" Name)
    (err-throw (text "Invalid Object name '@1', must be '}' OR string", Name) ]

[de json-object-check-separator (Separator)
  (unless (= ":" Separator)
          (err-throw (text "Invalid Object separator '@1', must be ':'", Separator) ]

# internal
[de link-array (Make)
  (when Make (link T))

  (let Res (car *Json)
    (if Res
        (prog
          (json-array-check-value Res)
          (unless (= "]" Res) (link (iterate-object))) ) )

    (if (= "]" (car *Json))
        (pop '*Json)
        (when (= "," (car *Json))
              (pop '*Json)
              (link-array) ]

[de link-object-value (Name)
  (json-object-check-separator (pop '*Json))
  (link (cons (pack Name) (iterate-object))) ]

[de link-object ()
  (let Name (car *Json)
    (if Name
        (prog
          (json-object-check-name Name)
          (unless (= "}" Name) (pop '*Json) (link-object-value Name)) ) )

    (if (= "}" (car *Json))
        (pop '*Json)
        (when (= "," (car *Json))
              (pop '*Json)
              (link-object) ]

[de iterate-object ()
  (let Type (pop '*Json)
    (cond
      ((= "[" Type)     (make (link-array T)))
      ((= "{" Type)     (make (link-object)))
      ((lst? Type)      (pack Type))
      ((num? Type)      Type)
      ((= "-" Type)     (if (num? (car *Json)) (format (pack "-" (pop '*Json))) (iterate-object)))
      ((= 'true Type)   'true)
      ((= 'false Type)  'false)
      ((= 'null Type)   'null)
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
