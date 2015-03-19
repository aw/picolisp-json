(symbols 'json 'pico)

[de MODULE_INFO
  ("name"       "json")
  ("version"    "0.2.5")
  ("summary"    "JSON encoder/decoder ffi-bindings for PicoLisp")
  ("source"     "https://github.com/aw/picolisp-json.git")
  ("author"     "Alexander Williams")
  ("license"    "MIT")
  ("copyright"  "(c) 2015 Alexander Williams, Unscramble <license@unscramble.jp>")
  ("install"    "build.sh")
  ("update"     "update.sh") ]

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
(de json-parse-file (Filename)
  (native `*Json "json_parse_file" 'N Filename) )

(de json-parse-string (String)
  (native `*Json "json_parse_string" 'N String) )

(de json-value-init-object ()
  (native `*Json "json_value_init_object" 'N) )

(de json-type (Value)
  (native `*Json "json_type" 'I Value) )

(de json-array (Value)
  (native `*Json "json_array" 'N Value) )

(de json-object (Value)
  (native `*Json "json_object" 'N Value) )

(de json-string (Value)
  (native `*Json "json_string" 'S Value) )

(de json-boolean (Value)
  (native `*Json "json_boolean" 'I Value) )

(de json-number (Value)
  (native `*Json "json_number" '+1.0 Value) )

(de json-array-get-count (Array)
  (native `*Json "json_array_get_count" 'I Array) )

(de json-object-get-count (Object)
  (native `*Json "json_object_get_count" 'I Object) )

(de json-array-get-value (Array Index)
  (native `*Json "json_array_get_value" 'N Array Index) )

(de json-object-get-value (Object Index)
  (native `*Json "json_object_get_value" 'N Object Index) )

(de json-object-get-name (Object Index)
  (native `*Json "json_object_get_name" 'S Object Index) )

(de json-value-free (Value)
  (native `*Json "json_value_free" NIL Value) )


# internal
[de link-json-array (Value)
  (let Arr (json-array Value)
    (link T)
    (for N (json-array-get-count Arr)
      (let Val (json-array-get-value Arr (dec N))
        (link (iterate-object Val)) ]

[de link-json-object (Value)
  (let Obj (json-object Value)
    (for N (json-object-get-count Obj)
      (let (Name (json-object-get-name Obj (dec N))
            Val  (json-object-get-value Obj Name) )
        (link (cons Name (iterate-object Val))) ]

[de iterate-object (Value)
  (make
    (let Type (json-type Value)
      (case Type  (`*JSONArray    (link-json-array  Value))
                  (`*JSONObject   (link-json-object Value))
                  (`*JSONString   (chain (json-string  Value)))
                  [`*JSONBoolean  (chain (cond
                                            ((= 1 (json-boolean Value)) 'true)
                                            ((= 0 (json-boolean Value)) 'false) ]
                  (`*JSONNumber   (chain (json-number  Value)))
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
        (json-parse-file Value)
        (json-parse-string Value) ]
    (when Root_value (let Result (iterate-object Root_value) (json-value-free Root_value) Result)) ]

[de encode (Value)
  (if (=T (car Value))
      (make-array (cdr Value))
      (make-object Value) ]
