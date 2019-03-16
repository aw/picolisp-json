# Explanation: JSON Encoder/Decoder in pure PicoLisp

This document provides a short walkthrough of the source code for the [PicoLisp-JSON](https://github.com/aw/picolisp-json.git) encoder/decoder.

**Note:** This document covers `v3` of the JSON library. To view the older (C/ffi bindings) version [click here](https://github.com/aw/picolisp-json/blob/v2.2.0/EXPLAIN.md).

It's split into a few sections for easier reading:

1. [Global variables](#global-variables): Important variables used throughout the library.
2. [Pure PicoLisp JSON decoding](#pure-picolisp-json-decoding): Decoding JSON in PicoLisp, without external libraries.
  * [Handling Unicode characters](#handling-unicode-characters)
  * [Stack-based bracket matching](#stack--based-bracket-matching)
  * [Object and array validation](#object-and-array-validation)
3. [Internal functions](#internal-functions): Recursion and datatype-checking.
  * [decoding JSON](#decoding-json)
  * [encoding JSON](#encoding-json)

Make sure you read the [README](README.md) to get an idea of what this library does.

Also, I recommend you visit my [PicoLisp Libraries Page](https://picolisp.a1w.ca/) for additional PicoLisp tips and ideas.

# Global variables

Prior to `version 17.3.4`, PicoLisp provided the [local](https://software-lab.de/doc/refL.html#local) function to prevent variables from leaking into the global namespace, however it was removed in the `32-bit` version, and its semantics were changed, thus introducing a breaking change for anyone using `(local)` in their code.

To work around this issue, I modified the library to _disable_ namespaces by specifying the environment variable `PIL_NAMESPACES=false`.

```picolisp
(unless (= "false" (sys "PIL_NAMESPACES"))
  (symbols 'json 'pico)

  (local MODULE_INFO *Msg err-throw)
```

This change allows the JSON library to be loaded correctly on all 32/64-bit systems using PicoLisp higher than `version 3.1.9` (for backwards compatibility), however if namespaces aren't required, it's probably best to _disable_ namespaces as mentioned above.

# Pure PicoLisp JSON decoding

In `v2`, an external [C library](https://github.com/kgabis/parson) was used to perform JSON string decoding. This version gets rid of that dependency and performs all parsing directly in PicoLisp.

### Handling Unicode characters

The JSON spec requires proper handling of Unicode characters written as: `\uNNNN`, where `N` is a hexadecimal digit, as well formfeed `\f` and backspace `\b`, which are not handled by PicoLisp. However it does handle newline `\n -> ^J`, carriage return `\r -> ^M`, tab `\t -> ^I`.

Similar to the `@lib/json.l` included with PicoLisp, this library calls [str](https://software-lab.de/doc/refS.html#str) to tokenize the JSON string.

Unforunately, the tokenization removes the single `\` from Unicode characters, turning `\u006C` into `u006c`, rendering it impossible to safely differentiate it from a random string containg the `u006c` character sequence.

In that case, it's necessary to parse the Unicode characters _before_ tokenizing the string:

```picolisp
(str (json-parse-unicode (chop Value)) "_")
```

The `(json-parse-unicode)` function receives a [chop(ped)](https://software-lab.de/doc/refC.html#chop) list of characters representing the full JSON string, and returns a [pack(ed)](https://software-lab.de/doc/refP.html#pack) string with all `\uNNNN` values converted to their UTF-8 symbol:

```picolisp
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
```

Let's see what's going on here:

1. [make](https://software-lab.de/doc/refM.html#make) is used to initiate a new list
2. [while](https://software-lab.de/doc/refW.html#while) loops over the list stored in `Value`, until the list is empty
3. [pop](https://software-lab.de/doc/refP.html#pop) removes the first element from the list stored in `Value`
4. A conditional check since we're searching for a `\b` (backspace), `\f` (formfeed), or `\uNNNN` (Unicode) character
5. If the character following `\\` (it's escaped `\`) is `u`, then we pop the next 5 items from the list (i.e: `uNNNN`) using [cut](https://software-lab.de/doc/refC.html#cut)
6. [link](https://software-lab.de/doc/refL.html#link) is used to add a new list to the list created with `(make)`
7. Finally, we pack the last 4 items from the previously cut items (i.e: `NNNN`), and use [hex](https://software-lab.de/doc/refH.html#hex) and [char](https://software-lab.de/doc/refC.html#char) to convert `NNNN`.

For Unicode characters, it ends up like this: `"\\u0065" -> "e"`. Yay!

### Stack-based bracket matching

There's no point in decoding a JSON file that isn't valid, so an early detection method is to determine whether all the curly braces (`{}`) and square brackets (`[]`) are matched.

We'll use a stack-based algorithm to count brackets, and only consider it a success if the stack is empty at the end.

First, we provide the tokenized string to the `(json-count-brackets)` function, and map over each character. For each character, we perform the following:

```picolisp
(if (or (= "{" N) (= "[" N))
    (push 'Json_stack N)
    (case N
      ("]" (let R (pop 'Json_stack) (unless (= "[" R) (err-throw "Unmatched JSON brackets '['"))))
      ("}" (let R (pop 'Json_stack) (unless (= "{" R) (err-throw "Unmatched JSON brackets '{'")))) ) ) )
```

1. If the character is an opening `{` or `[`, [push](https://software-lab.de/doc/refP.html#push) it to the stack
2. If the character is a closing `}` or `]`, [pop](https://software-lab.de/doc/refP.html#pop) the next value from the stack, and if that character isn't the matching bracket (i.e: `{` for `}`, or `[` for `]`), then we have unmatched JSON brackets. Easy.

Those who are paying attention will notice the `(err-throw)` function. It does two things:

```picolisp
(msg Error)
(throw 'invalid-json NIL)
```

The [msg](https://software-lab.de/doc/refM.html#msg) function will output a message to STDERR, because the [UNIX Philosophy](https://en.wikipedia.org/wiki/Unix_philosophy#Mike_Gancarz:_The_UNIX_Philosophy).

The [throw](https://software-lab.de/doc/refT.html#throw) function will raise an error in the program, with the `'invalid-json` label and a `NIL` return value.

The decoder will [catch](https://software-lab.de/doc/refC.html#catch) the raised error, as it should, but more importantly, the `NIL` return value will indicate that decoding failed. This is important for programs which embed this library, as it won't break a running program, and will behave exactly as expected when _something goes wrong_.

### Object and array validation

We'll briefly cover the validation for objects, arrays, and the separator.

Essentially, `(json-array-check)`, `(json-object-check)` simply validate whether the value following the `{` or `[` brackets are allowed.

The `(json-object-check-separator)` is used to ensure a `:` separates the string from the value (ex: `{"string" : value}`).

```picolisp
[de json-object-check (Name)
  (or
    (lst? Name)
    (= "}" Name)
    (err-throw (text "Invalid Object name '@1', must be '}' OR string", Name) ]
```

As you can see, it's quite simple, and if there's no match, `(err-throw)` will be called.

# Internal functions

This part of the code was completely rewritten from scratch, so we'll go through it together.

## decoding JSON

We'll begin by looking at how JSON is decoded in this library.

### (iterate-object)

A fully tokenized JSON string might look like this:

```picolisp
("{" ("t" "e" "s" "t") ":" "[" 1 "," 2 "," 3 "]" "}")
```

Now, look at the `(iterate-object)` function. This is a recursive function which loops and iterates through the global `*Json` variable, a list which contains the tokenized JSON string, and then quickly builds a sexy PicoLisp list.

```picolisp
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
```

We treat the `*Json` list as a stack, and iterate through it after popping one or more elements, until there's nothing left but tears of joy.

The condition for `[` will start a new list with [make](https://software-lab.de/doc/refM.html#make), and call `(link-array)` with the argument `T`. We'll see why later.

The rest is quite easy to understand, but I'll focus on the case of `(= "-" Type)`. The tokenization doesn't recognize negative numbers, so `-32` would be tokenized to `'("-" 32)`. To solve this, we check for a single `"-"`, and if the next item in the list is a number, then we [pop](https://software-lab.de/doc/refP.html#pop) the `"-"`, [pack](https://software-lab.de/doc/refP.html#pack) it with the number (`(pack)` creates a string), then use [format](https://software-lab.de/doc/refF.html#format) to convert it to a number.
In other words, our tokenized `'("-" 23) -> -23`. Please note, since `-23` is not a string, this could not have been done in the Unicode parsing stage. It must occur after tokenization with `(str)`.

### (link-array) and (link-object)

Both the `(link-array)` and `(link-object)` function make a call to the more generic `(link-generic)` function. It accepts three arguments: the type of item, the closing bracket, and an unevaluated [quote(ed)](https://software-lab.de/doc/refQ.html#quote) function.

```picolisp
(link-generic "array"
                "]"
                '(link (iterate-object))
(link-generic "object"
                "}"
                '(link-object-value Name) ]
```

They're quite similar. In both cases, the function will iterate once more over the object, depending on various conditions described in `(link-generic)`.

Let's look at some of the magic going on in `(link-generic)`:

```picolisp
# 1. ((any (pack "json-" Type "-check")) Name)
# 2. (unless (= Bracket Name) (eval Iterator))
```

The first looks a bit weird, but it essentially uses [any](https://software-lab.de/doc/refA.html#any) and [pack](https://software-lab.de/doc/refP.html#pack) to dynamically generate a function name, and then calls it with the `Name` argument.

This gives something like: `(json-array-check "[")` - dynamically generate Lisp functions ftw!

The second is a bit easier to grok, where it simply [eval(uates)](https://software-lab.de/doc/refE.html#eval) the given function passed as through the variable `Iterator`.

### T

Earlier, we saw `(link-array T)` was called, but sometimes, only `(link-array)` is called, without the `T` argument. Why?

To differentiate an `Array` from an `Object` in PicoLisp, we append `T` to the start of the list. When recursing, unless it's a new array, we don't provide the `T` argument:

```picolisp
(when Make (link T))
```

The previously tokenized JSON string would end up like this:

```picolisp
(("test" T 1 2 3))
```

## encoding JSON

The code for encoding JSON strings hasn't changed, so feel free to [read about it here](https://github.com/aw/picolisp-json/blob/master/EXPLAIN.md#encoding-json).

# The end

That's pretty much all I have to explain about the new and improved `v3` pure PicoLisp JSONencoder/decoder. I'm very open to providing more details about functionality I've skipped, so just file an [issue](https://github.com/aw/picolisp-json/issues/new) and I'll look into amending this document.

# License

This work is licensed under a [Creative Commons Attribution-ShareAlike 4.0 International License](http://creativecommons.org/licenses/by-sa/4.0/).

Copyright (c) 2018 Alexander Williams, Unscramble <license@unscramble.jp>
