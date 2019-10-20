# json.l
#
# The MIT License (MIT)
#
# Copyright (c) 2015-2019 Alexander Williams, Unscramble <license@unscramble.jp>

(setq *Json_control_characters (extract '((N) (unless (member N '("^H" "^L" "^J" "^M" "^I")) N)) (mapcar char (range 1 31))))

# send error message to STDERR
[de json-err-throw (Error)
  (msg Error)
  (setq *Msg Error)
  (throw 'invalid-json NIL) ]

# json
[de json-parse-file (File)
  (json-parse-string (in File (till NIL T) ]

[de json-parse-string (Value)
  (let Str (str (json-parse-unicode (chop Value)) "_")
    (json-count-brackets Str)
    Str ]

[de json-parse-unicode-special (Value)
  (case (lowc Value)
    ("0022"   "\\\"")
    ("005c"   "\\\\")
    ("005e"   "\\\^")
    (T (char (hex Value) ]

[de json-parse-unicode (Value)
  (pack
    (make
      (while Value
        (let R (pop 'Value)
          (cond
            [(= "\^" R) (link "\\\^") ] # ^ becomes \^
            [(and (= "\\" R) (= "u" (car Value))) (let U (cut 5 'Value) (link (json-parse-unicode-special (pack (tail 4 U) ] # \uNNNN hex
            [(and (= "\\" R) (= "b" (car Value))) (pop 'Value) (link (char (hex "08") ] # \b backspace
            [(and (= "\\" R) (= "f" (car Value))) (pop 'Value) (link (char (hex "0C") ] # \f formfeed
            (T (link R)) ]

[de json-count-brackets (Str)
  (let Json_stack NIL
    (mapc '((N)
            (if (or (= "{" N) (= "[" N))
                (push 'Json_stack N)
                (case N
                  ("]" (let R (pop 'Json_stack) (unless (= "[" R) (json-err-throw "Unmatched JSON brackets '['"))))
                  ("}" (let R (pop 'Json_stack) (unless (= "{" R) (json-err-throw "Unmatched JSON brackets '{'")))) ) ) )
            Str )
    (when Json_stack (json-err-throw (text "Unmatched JSON brackets '@1'", (pop Json_stack) ]

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
    (json-err-throw (text "Invalid Array value '@1', must be {' OR '[' OR ']' OR string OR number OR true OR false OR null", Value) ]

[de json-object-check (Name)
  (when (and *Json_prevent_duplicate_keys (assoc (pack Name) (made)))
        (json-err-throw (text "Duplicate Object key '@1'", Name)) )
  (or
    (lst? Name)
    (= "}" Name)
    (json-err-throw (text "Invalid Object name '@1', must be '}' OR string", Name) ]

[de json-object-check-separator (Separator)
  (unless (= ":" Separator)
          (json-err-throw (text "Invalid Object separator '@1', must be ':'", Separator) ]

# internal
[de json-link-generic (Checker Linker Bracket Iterator)
  (let Name (car *Json)
    (when Name
          (eval Checker)
          (unless (= Bracket Name) (eval Iterator)) )

    (if (= Bracket (car *Json))
        (pop '*Json)
        (when (= "," (car *Json))
              (pop '*Json)
              (eval Linker) )
        (unless (car *Json)
              (cut 2 '*Json) ]

[de json-link-array ()
  (json-link-generic '(json-array-check Name)
                '(json-link-array)
                "]"
                '(link (json-iterate-object)) ]

[de json-link-object ()
  (json-link-generic '(json-object-check Name)
                '(json-link-object)
                "}"
                '(json-link-object-value Name) ]

[de json-link-object-value (Name)
  (pop '*Json)
  (json-object-check-separator (pop '*Json))
  (link (cons (pack Name) (json-iterate-object))) ]

[de json-iterate-object ()
  (let Type (pop '*Json)
    (cond
      ((= "[" Type)     (make (link T) (json-link-array)))
      ((= "{" Type)     (make (json-link-object)))
      ((lst? Type)      (pack Type))
      ((num? Type)      Type)
      ((= "-" Type)     (if (num? (car *Json)) (format (pack "-" (pop '*Json))) (json-iterate-object)))
      ((= 'true Type)   'true)
      ((= 'false Type)  'false)
      ((= 'null Type)   'null)
      (T                (json-err-throw (text "Invalid Object '@1', must be '[' OR '{' OR string OR number OR true OR false OR null", Type) ]

[de json-iterate-list (Item)
  (let Value (cdr Item)
    (or
      (json-make-null Value)
      (json-make-boolean Value)
      (json-make-json-number Value)
      (json-make-json-string Value)
      (json-make-json-array Value)
      (json-make-object Value) ]

[de json-make-null (Value)
  (when (== 'null Value) 'null) ]

[de json-make-boolean (Value)
  (cond ((== 'true Value)  'true)
        ((== 'false Value) 'false) ]

[de json-make-json-number (Value)
  (when (num? Value) Value) ]

[de json-make-json-string (Value)
  (when (str? Value)
        (pack
          "\""
          (extract '((N)
                      (if (member N *Json_control_characters)
                          (pack "\\u" (pad 4 (hex (char N))))
                          (case N
                            ("\"" "\\\"")
                            ("\\" "\\\\")
                            ("^H" "\\b")
                            ("^L" "\\f")
                            ("^J" "\\n")
                            ("^M" "\\r")
                            ("^I" "\\t")
                            ("\\\^" "\^")
                            (T N) ) ) )
                    (chop Value) )
          "\"" ]

[de json-make-json-array (Value)
  (when (=T (car Value)) (json-make-array (cdr Value))) ]

[de json-make-generic (Bracket_open Bracket_close Iterator)
  (pack Bracket_open
        (glue "," (mapcar '((N) (eval Iterator)) Value))
        Bracket_close ]

[de json-make-object (Value)
  (json-make-generic "{"
                "}"
                '(pack "\"" (car N) "\":" (json-iterate-list N)) ]

[de json-make-array (Value)
  (json-make-generic "["
                "]"
                '(json-iterate-list (cons NIL N)) ]

# public
[de json-decode (Value Type)
  (catch 'invalid-json
    (use *Json
      (setq *Json
        (if Type
            (json-parse-file Value)
            (json-parse-string Value) ) )
      (when *Json
            (json-iterate-object) ) ]

[de json-encode (Value)
  (if (=T (car Value))
      (json-make-array (cdr Value))
      (json-make-object Value) ]
