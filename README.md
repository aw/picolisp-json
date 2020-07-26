# JSON Encoder/Decoder for PicoLisp

[![GitHub release](https://img.shields.io/github/release/aw/picolisp-json.svg)](https://github.com/aw/picolisp-json) [![Dependency](https://img.shields.io/badge/[deps]&#32;picolisp--unit-v3.0.0-ff69b4.svg)](https://github.com/aw/picolisp-unit.git) ![Build status](https://github.com/aw/picolisp-json/workflows/CI/badge.svg?branch=master)

This library can be used to parse and serialize (encode/decode) JSON strings in pure [PicoLisp](http://picolisp.com/).

![picolisp-json](https://cloud.githubusercontent.com/assets/153401/6571543/56e31e44-c701-11e4-99f0-c2c51fd8061b.png)

**NEW:** Please read [EXPLAIN_v3.md](EXPLAIN_v3.md) to learn more about PicoLisp and this (`v3`) JSON library.

Please read [EXPLAIN.md](EXPLAIN.md) to learn more about PicoLisp and the older (`v2`) JSON library.

  1. [Requirements](#requirements)
  2. [Getting Started](#getting-started)
  3. [Usage](#usage)
  4. [Examples](#examples)
  5. [Testing](#testing)
  6. [Alternatives](#alternatives)
  7. [Contributing](#contributing)
  8. [Changelog](#changelog)
  9. [License](#license)

# Requirements

  * PicoLisp 32-bit `v3.1.11` to `v20.6` (tested)
  * PicoLisp 64-bit `v17.12` to `v20.6` (tested)

**BREAKING CHANGE since v4.0.0:** Namespaces have been completely removed, and all function names are now prefixed with _json-_ (see [Changelog](CHANGELOG.md)).

# Getting Started

This library has been rewritten in pure PicoLisp and contains **no external dependencies**.

~~These FFI bindings require the [Parson C library](https://github.com/kgabis/parson), compiled as a shared library~~

  1. Include `json.l` in your project
  2. Try the [examples](#examples) below

# Usage

Public functions:

  * `(json-decode arg1 arg2)` parses a JSON string or file
    - `arg1` _String_: the JSON string or filename you want to decode
    - `arg2` _Flag (optional)_: a flag (`T` or `NIL`) indicating to parse a file if set
  * `(json-encode arg1)` serializes a list into a JSON string
    - `arg1` _List_: a PicoLisp list which will be converted to a JSON string

### JSON-PicoLisp data type table

| JSON | PicoLisp | Example |
| ---- | -------- | ------- |
| Number | Number | `25 <-> 25` |
| String | String | `"hello" <-> "hello"` |
| Null | Transient _null_ Symbol | `null <-> 'null` |
| Boolean | Transient _true_ or _false_ Symbol | `true <-> 'true` |
| Array | List with T in cdar | `{"array":[1,2,3]} <-> '(("array" T 1 2 3))` |
| Object | Cons pair | `{"hello":"world"} <-> '(("hello" . "world"))` |

### Notes

  * To disallow duplicate Object keys: `(on *Json_prevent_duplicate_keys)`. Default allows duplicate Object keys.
  * A successful result will return a list.
  * Failures return `NIL`, store the error message in `*Msg`, and print the error message to `STDERR` (standard error).
  * Keys are in `car`, values are in `cdr`.
  * When the 2nd item in the list is `T`, the rest of the list represents a JSON array.
  * When the 2nd item in the list is a cons pair, it represents a JSON object.
  * Supports Unicode characters as `"\uNNNN"` where `N` is a hexadecimal digit.

### JSON Specification

This library conforms to the [ECMA-404 The JSON Data Interchange Standard](http://www.ecma-international.org/publications/files/ECMA-ST/ECMA-404.pdf), except for the following semantic exceptions:

  * [Numbers] Scientific (floating point, fractional, exponential) numbers (ex: `3.7e-5`) are not accepted. They must be provided as strings (ex: `"3.7e-5"`).

# Examples

### (json-decode String)

```picolisp
(load "json.l")

(json-decode "{\"Hello\":\"World\"}")

-> (("Hello" . "World"))
```

### (json-decode Filename T)

The same function is used for parsing JSON strings and files.
Simply append `T` as the last argument if you want to parse a file.

```picolisp
(load "json.l")

(json-decode "test.json" T)

-> (("first" . "John")
    ("last" . "Doe")
    ("age" . 25)
    ("registered" . true)
    ("interests" T "Reading" "Mountain Biking")
    ("favorites" ("color" . "blue") ("sport" . "running"))
    ("utf string" . "lorem ipsum")
    ("utf-8 string" . "あいうえお")
    ("surrogate string" . "lorem�ipsum�lorem") )
```

### (json-encode List)

```picolisp
(load "json.l")

(json-encode '(("Hello" . "World")))

-> "{\"Hello\":\"World\"}"
```

### (json-decode InvalidString)

```picolisp

(json-decode "{\"Hello\":invalid}")
"Invalid Object 'invalid', must be '[' OR '{' OR string OR number OR true OR false OR null"

-> NIL
```

# Testing

This library comes with full [unit tests](https://github.com/aw/picolisp-unit). To run the tests, type:

    make check

# Alternatives

The following are alternatives also written in pure PicoLisp. They are limited by pipe/read syscalls.

* [JSON reader/writer](http://rosettacode.org/wiki/JSON#PicoLisp) by Alexander Burger.
* [JSON reader/writer](https://bitbucket.org/hsarvell/ext/src/9d6e5a15c5ce7cb47033e0082ef70aee6c4c8dd7/json.l?at=default) by Henrik Sarvell.

# Contributing

If you find any bugs or issues, please [create an issue](https://github.com/aw/picolisp-json/issues/new).

If you want to improve this library, please make a pull-request.

# Changelog

* [Changelog](CHANGELOG.md)

# License

[MIT License](LICENSE)

Copyright (c) 2015-2020 Alexander Williams, Unscramble <license@unscramble.jp>
