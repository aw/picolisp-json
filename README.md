# JSON (Parson) Encoder/Decoder FFI Bindings

[JSON](https://github.com/kgabis/parson) (Parson) FFI bindings for [PicoLisp](http://picolisp.com/).

This library can be used to parse and serialize (encode/decode) JSON strings.

# Version

**v0.1.0** (uses Parson _master branch_)

# Requirements

  * PicoLisp 64-bit v3.1.9+
  * Git
  * UNIX/Linux development/build tools (gcc, make/gmake, etc..)

# Getting started

This binding relies on the _Parson C library._, compiled as a shared library. It is included here as a [git submodule](http://git-scm.com/book/en/v2/Git-Tools-Submodules).

  1. Type `./build.sh` to pull and compile the _Parson C Library_.
  2. Include `json.l` in your project
  3. Try the example below

## Linking and Paths

Once compiled, the shared library is symlinked in `lib/libparson.so` pointing to `vendor/parson/libparson.so`.

The `json.l` file searches for `lib/libparson.so`, relative to its current directory.

# Usage

All functions are publicly accessible and namespaced with `(symbols 'json)` (or the prefix: `json~`), but only the following are necessary:

  * `decode`: parses a JSON string or file
  * `encode`: serializes a list into a JSON string

A successful result will return a list. Failures return `NIL`. Keys are in `car`, values are in `cdr`. Values might also be lists.

# Example (decode String)

```lisp
pil +

(load "json.l")

(symbols 'json)

(decode "{\"Hello\":\"World\"}")
-> (("Hello" . "World"))
```

# Example (decode Filename T)

The same function is used for parsing JSON strings and files.
Simply append `T` as the last argument if you want to parse a file.

```lisp
pil +

(load "json.l")

(symbols 'json)

(decode "test.json" T)

-> (("first" . "John") ("last" . "Doe") ("age" . 25) ("registered" . true) ("interests" T "Reading" "Mountain Biking") ("favorites" ("color" . "blue") ("sport" . "running")) ("utf string" . "lorem ipsum") ("utf-8 string" . "あいうえお") ("surrogate string" . "lorem�ipsum�lorem"))
```

# Example (encode String)

```lisp

pil +

(load "json.l")

(symbols 'json)

(encode '(("Hello" . "World")))

-> "{\"Hello\":\"World\"}"
```

# Contributing

If you find any bugs or issues, please [create an issue](https://github.com/aw/picolisp-json/issues/new).

If you want to improve this library, please make a pull-request.

# License

[MIT License](LICENSE)
Copyright (c) 2015 Alexander Williams, Unscramble <license@unscramble.jp>
