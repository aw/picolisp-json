# json.l
#
# The MIT License (MIT)
#
# Copyright (c) 2015 Alexander Williams, Unscramble <license@unscramble.jp>

(symbols 'json 'pico)

(local MODULE_INFO *Json *JSONError *JSONNull *JSONString *JSONNumber *JSONObject *JSONArray *JSONBoolean *JSONSuccess *JSONFailure)
(local link-json-array link-json-object iterate-object iterate-list get-null get-boolean get-json-number get-json-string get-json-array)
(local make-object make-array)

(load (pack (car (file)) "module.l"))

(setq
  *Json         (pack (car (file)) "lib/libparson.so")

  *JSONError    -1
  *JSONNull     1
  *JSONString   2
  *JSONNumber   3
  *JSONObject   4
  *JSONArray    5
  *JSONBoolean  6
  *JSONSuccess  0
  *JSONFailure  -1 )


# ffi-bindings
[de json-ffi-table
  (json-parse-file          . 'N)
  (json-parse-string        . 'N)
  (json-value-init-object   . 'N)
  (json-type                . 'I)
  (json-array               . 'N)
  (json-object              . 'N)
  (json-string              . 'S)
  (json-boolean             . 'I)
  (json-number              . '+1.0)
  (json-array-get-count     . 'I)
  (json-object-get-count    . 'I)
  (json-array-get-value     . 'N)
  (json-object-get-value    . 'N)
  (json-object-get-name     . 'S)
  (json-value-free          . NIL) ]

[de chop-ffi (Name)
  (glue "_" (split (chop Name) "-") ]

[de json-ffi (Function . @)
  (let Rule (assoc Function json-ffi-table)
    (pass native `*Json (chop-ffi (car Rule)) (cdr Rule) ]


# internal
[de link-json-array (Value)
  (let Arr (json-ffi 'json-array Value)
    (link T)
    (for N (json-ffi 'json-array-get-count Arr)
      (let Val (json-ffi 'json-array-get-value Arr (dec N))
        (link (iterate-object Val)) ]

[de link-json-object (Value)
  (let Obj (json-ffi 'json-object Value)
    (for N (json-ffi 'json-object-get-count Obj)
      (let (Name (json-ffi 'json-object-get-name Obj (dec N))
            Val  (json-ffi 'json-object-get-value Obj Name) )
        (link (cons Name (iterate-object Val))) ]

[de iterate-object (Value)
  (make
    (let Type (json-ffi 'json-type Value)
      (case Type  (`*JSONArray    (link-json-array  Value))
                  (`*JSONObject   (link-json-object Value))
                  (`*JSONString   (chain (json-ffi 'json-string  Value)))
                  [`*JSONBoolean  (chain (cond
                                            ((= 1 (json-ffi 'json-boolean Value)) 'true)
                                            ((= 0 (json-ffi 'json-boolean Value)) 'false) ]
                  (`*JSONNumber   (chain (json-ffi 'json-number  Value)))
                  (`*JSONNull     (chain 'null)) ]

[de iterate-list (Item)
  (let Value (cdr Item)
    (or
      (get-null Value)
      (get-boolean Value)
      (get-json-number Value)
      (get-json-string Value)
      (get-json-array Value)
      (make-object Value) ]

[de get-null (Value)
  (when (== 'null Value) "null") ]

[de get-boolean (Value)
  (cond ((== 'true Value)  "true")
        ((== 'false Value) "false") ]

[de get-json-number (Value)
  (when (num? Value) Value) ]

[de get-json-string (Value)
  (when (str? Value) (pack "\"" Value "\"")) ]

[de get-json-array (Value)
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
  (let Root_value
    [if Type
        (json-ffi 'json-parse-file Value)
        (json-ffi 'json-parse-string Value) ]
    (when Root_value (let Result (iterate-object Root_value) (json-ffi 'json-value-free Root_value) Result)) ]

[de encode (Value)
  (if (=T (car Value))
      (make-array (cdr Value))
      (make-object Value) ]
