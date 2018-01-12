# json.l
#
# The MIT License (MIT)
#
# Copyright (c) 2017-2018 Alexander Williams, Unscramble <license@unscramble.jp>

(unless (= "false" (sys "PIL_NAMESPACES"))
  (symbols 'json 'pico)

  (local MODULE_INFO *Msg err-throw)
  (local json-parse-file json-parse-string json-parse-unicode json-count-brackets)
  (local json-array-check json-object-check json-object-check-separator)
  (local link-generic link-array link-object link-object-value)
  (local iterate-object iterate-list make-null make-boolean make-json-number)
  (local make-json-string make-json-array make-generic make-object make-array) )

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
  (let Json_stack NIL
    (mapc '((N)
            (if (or (= "{" N) (= "[" N))
                (push 'Json_stack N)
                (case N
                  ("]" (let R (pop 'Json_stack) (unless (= "[" R) (err-throw "Unmatched JSON brackets '['"))))
                  ("}" (let R (pop 'Json_stack) (unless (= "{" R) (err-throw "Unmatched JSON brackets '{'")))) ) ) )
            Str )
    (when Json_stack (err-throw (text "Unmatched JSON brackets '@1'", (pop Json_stack) ]

[de json-array-check (Value)
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

[de json-object-check (Name)
  (or
    (lst? Name)
    (= "}" Name)
    (err-throw (text "Invalid Object name '@1', must be '}' OR string", Name) ]

[de json-object-check-separator (Separator)
  (unless (= ":" Separator)
          (err-throw (text "Invalid Object separator '@1', must be ':'", Separator) ]

# internal
[de link-generic (Type Bracket Iterator)
  (let Name (car *Json)
    (when Name
          ((any (pack "json-" Type "-check")) Name)
          (unless (= Bracket Name) (eval Iterator)) )

    (if (= Bracket (car *Json))
        (pop '*Json)
        (when (= "," (car *Json))
              (pop '*Json)
              ((any (pack "link-" Type))) ]

[de link-array (Make)
  (when Make (link T))
  (link-generic "array"
                "]"
                '(link (iterate-object)) ]

[de link-object ()
  (link-generic "object"
                "}"
                '(link-object-value Name) ]

[de link-object-value (Name)
  (pop '*Json)
  (json-object-check-separator (pop '*Json))
  (link (cons (pack Name) (iterate-object))) ]

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
  (when (== 'null Value) 'null) ]

[de make-boolean (Value)
  (cond ((== 'true Value)  'true)
        ((== 'false Value) 'false) ]

[de make-json-number (Value)
  (when (num? Value) Value) ]

[de make-json-string (Value)
  (when (str? Value) (sym Value) ]

[de make-json-array (Value)
  (when (=T (car Value)) (make-array (cdr Value))) ]

[de make-generic (Bracket_open Bracket_close Iterator)
  (pack Bracket_open
        (glue "," (mapcar '((N) (eval Iterator)) Value))
        Bracket_close ]

[de make-object (Value)
  (make-generic "{"
                "}"
                '(pack "\"" (car N) "\":" (iterate-list N)) ]

[de make-array (Value)
  (make-generic "["
                "]"
                '(iterate-list (cons NIL N)) ]

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
