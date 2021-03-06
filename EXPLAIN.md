# Explanation: JSON Encoder/Decoder for PicoLisp

This document provides a short walkthrough of the source code for the [PicoLisp-JSON](https://github.com/aw/picolisp-json.git) encoder/decoder.

**Note:** This document covers the older `v2` of the JSON library. To view the newer (pure PicoLisp) version [click here](https://github.com/aw/picolisp-json/blob/master/EXPLAIN.md).

It's split into a few sections for easier reading:

1. [Global variables](#global-variables): Important variables used throughout the library.
2. [Native calls (ffi-bindings)](#native-calls-ffi-bindings): The `Parson` native C library, and how it's used.
  * [A rule-based solution](#a-rule--based-solution)
3. [Internal functions](#internal-functions): Recursion and datatype-checking.
  * [decoding JSON](#decoding-json)
  * [encoding JSON](#encoding-json)

Make sure you read the [README](README.md) to get an idea of what this library does.

Also, I recommend you read my [Nanomsg Explanation](https://github.com/aw/picolisp-nanomsg/blob/master/EXPLAIN.md) for additional PicoLisp tips and ideas.

# Global variables

PicoLisp does not prevent variables from leaking into the global namespace. In order to prevent that, you must use [local](http://software-lab.de/doc/refL.html#local) and define exactly what should _not_ affect the global namespace. This is important to avoid un-intended side-effects.

```lisp
(local MODULE_INFO *Json *JSONError *JSONNull)
```

This will ensure the variables will not affect anything outside their current scope (namespace). It's similar to `var Myvar;` in JavaScript.

A few global variables have been defined at the top of the file.

```lisp
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
```

You'll notice I'm following the [PicoLisp Naming Conventions](http://software-lab.de/doc/ref.html#conv) this time.

The variables prefixed with `*JSON` were copied directly from [Parson's source code](https://github.com/kgabis/parson/blob/81c2fd0186cafb43c6b4c190b50bb3a4fef1827e/parson.h#L39-L54):

```C
..
enum json_value_type {
    JSONError   = -1,
    JSONNull    = 1,
    JSONString  = 2,
..
```

When working with a native C library in PicoLisp, it's important to use the same (or very similar) symbol names to avoid confusion.

# Native calls (ffi-bindings)

[Parson](https://github.com/kgabis/parson/) is a very simple C library, with functions accepting zero to three arguments, and returning simple validated values and structures.

Example:

```lisp
(ffi 'json-type (ffi 'json-parse-string "{\"Hello\":\"World\"}"))
-> 4
```

This returns `4` which is `*JSONObject` based on our variables defined earlier.

As we'll see later, our `picolisp-json` library can make decisions on how to parse data based on these types of results.

### A rule-based solution

Inspired by the amazing ["Paradigms of Artificial Intelligence"](http://norvig.com/paip/README.html) book (Chapter 2), I wrote the ffi functions using a rule-based approach.

First we create a simple list which declares all the ffi functions and their result type:

```lisp
[de ffi-table
  (json-parse-file          'N)
  (json-parse-string        'N)
  (json-value-init-object   'N)
  (json-type                'I)
  (json-array               'N) ]
# snipped for brevity
```

We then use a function which maps the first argument `Function` to a name in the list:

```lisp
[de ffi (Function . @)
  (let Rule (assoc Function ffi-table)
    (pass native `*Json (chop-ffi (car Rule)) (eval (cadr Rule) ]
```

The `(ffi)` function calls `(native)` using [pass](http://software-lab.de/doc/refP.html#pass), to append the rest of the variable-length arguments in `@` at the end of the function.

You'll notice `(chop-ffi)` actually converts the `-` characters to `_`. This is necessary because the C function names have underscores instead of dashes, but in general I think the LISP world prefers dashes for function names.

```lisp
[de chop-ffi (Name)
  (glue "_" (split (chop Name) "-") ]
```

I think this is a very lispy approach. It allows us to easily add new native functions by simply adding to the `ffi-table`. No other code modifications are necessary.

# Internal functions

The meat of this library is in the internal functions. The `'json-parse-string` and `'json-parse-file` functions validate the JSON string. If those calls are successful, then we can safely iterate over the result and generate our own list.

## decoding JSON

We'll begin by looking at how JSON is decoded in this library.

### (iterate-object)

We'll first look at the `(iterate-object)` function. This is a recursive function which loops and iterates through the results of each native C call, and quickly builds a sexy PicoLisp list.

```lisp
[de iterate-object (Value)
  (make
    (let Type (ffi 'json-type Value)
      (case Type  (`*JSONArray    (link-array  Value))
                  (`*JSONObject   (link-object Value))
                  (`*JSONString   (chain (ffi 'json-string  Value)))
                  [`*JSONBoolean  (chain (case (ffi 'json-boolean Value) (1 'true) (0 'false) ]
                  (`*JSONNumber   (chain (ffi 'json-number  Value)))
                  (`*JSONNull     (chain 'null)) ]
```

Lots of meat there.

### (make)

We've seen [make](http://software-lab.de/doc/refM.html#make) before, but I didn't fully explain it.

The `(make)` function is the instigator for building a list. You put it at the top or start of your function, and watch it build lists using [link](http://software-lab.de/doc/refL.html#link) and [chain](http://software-lab.de/doc/refC.html#chain).

We use [case](http://software-lab.de/doc/refC.html#case) here as our switch statement. This concept is similar in other programming language. This `(case)` call compares the `Type` value with those defined as global variables. If a match is found, it runs the following expression. Otherwise it returns `NIL` (aka: stop looping, i'm done damnit!).

JSON Arrays and Objects are a bit more tricky to parse, so we'll get to those later. In the case of `String, Boolean, Number or Null`, we add them to the list using `(chain)`.

### (link-array)

When the value is an Array (`Type = 5 = *JSONArray`), we loop through it to build a list (arrays are mapped as lists).

```lisp
[de link-array (Value)
  (let Arr (ffi 'json-array Value)
    (link T)
    (for N (ffi 'json-array-get-count Arr)
      (let Val (ffi 'json-array-get-value Arr (dec N))
        (link (iterate-object Val)) ]
```

You'll notice we added `(link T)` before the [for loop](http://software-lab.de/doc/refF.html#f). After long discussions with Alexander Burger, it was made clear that a marker is required to differentiate Objects from Arrays (in PicoLisp). We do that by appending `T` as the first element in the list.

The `(for)` loop is rather simple, but in each case we're obtaining new values by performing native C calls, and then adding to the list using `(link)`.

If you've had your coffee today, you would notice the [dec](http://software-lab.de/doc/refD.html#dec) call. As it turns out, `(for)` starts with 1 and counts to the total number of items in the Array. We use `(dec N)` to start at 0.

Example:

```
for N 5
  N = 1
  (ffi 'json-array-get-value Arr 0)
  ..
  N = 2
  (ffi 'json-array-get-value Arr 1)
  ..
```

Finally, the `(link)` function makes a call to `(iterate-object)`. Remember earlier? when `(link-array)` was called within `(iterate-object)`?

**Note:** This is called recursion, where a function calls itself (in our case, with a different value). You can [ask Google](https://encrypted.google.com/search?hl=en&q=recursion) about it.

The reason we perform this recursion is in case the value in the array is itself an array or an object. The `(iterate-object)` function will simply return a string, boolean, number or null otherwise.

### (link-object)

The `(link-object)` is similar to `(link-array)` except, you guessed it, it loops over objects.

```lisp
..
(link (cons Name (iterate-object Val)))
..
```

The other difference is during the `(link)` call, it appends a [cons](http://software-lab.de/doc/refC.html#cons) pair instead of a single value. We do this because a JSON Object is represented as a `(cons)` pair in PicoLisp.

```lisp
{"hello":"world"} <-> '(("hello" . "world"))
```

Of course, this function also recursively calls `(iterate-object)`.

## encoding JSON

Decoding was fun, because `Parson` did most of the work for us. Encoding is ugly, so I tried to make it as simple and intuitive as possible (less chance for bugs).

### (iterate-list)

Since we now have a friendly JSON string represented as a PicoLisp list, we'll iterate over it and turn it back into a JSON string.

```lisp
[de iterate-list (Item)
  (let Value (cdr Item)
    (or
      (make-null Value)
      (make-boolean Value)
      (make-json-number Value)
      (make-json-string Value)
      (make-json-array Value)
      (make-object Value) ]
```

This is a bit sneaky, but I :heart: it. I'm not sure how efficient it is either, but it works well, and I'd rather have _slow, but valid data_ than _fast, but invalid data_

> It's not slow, in fact it's incredibly fast based on my opinion of what fast looks like.

This function uses [or](http://software-lab.de/doc/refO.html#or) as a conditional statement. The `Value` passes through each function to determine the type of value it is, as well as to convert it to a string, number, boolean, null, or whatever.

### (make-null)

This function does nothing special, but I wanted to show something interesting.

```lisp
[de make-null (Value)
  (when (== 'null Value) "null") ]
```

You'll notice we check if `Value` is `==` to `'null`. What's going on here? Using double equal signs checks for [**Pointer equality**](http://software-lab.de/doc/ref.html#cmp). This is really important, make sure you understand the difference for a happy PicoLisp life.

This checks if the things we're comparing are not just equal, but also _identical_. In other words: Is `null` the exact same thing as `null` (`Value`). Not `"null"` or `NULL` or any other variation, but `null`. Yes. Got it?

### (make-json-array)

You should remember earlier we discussed appending `T` as the first element in the list, in the case of an Array.

```lisp
[de make-json-array (Value)
  (when (=T (car Value)) (make-array (cdr Value))) ]
```

What we're doing here is checking if the [car](http://software-lab.de/doc/refC.html#car) of the `Value` is `T`. If yes, then call the `(make-array)` function.

### (make-array)

This function builds an Array suitable for JSON.

```lisp
[de make-array (Value)
  (pack "["
        (glue ","
              (mapcar
                '((N) (iterate-list (cons NIL N)))
                Value ) )
        "]" ]
```

We've seen what [pack](http://software-lab.de/doc/refP.html#pack) does. We use it to build our Array with opening and closing `[]` brackets.

The cool thing I discovered recently is [glue](http://software-lab.de/doc/refG.html#glue). It is similar to `Array.join()` in Ruby and JavaScript, by concatenating a list with the supplied argument. In our case, it's a comma `,`.

Here we're doing something a little different.

If you remember `(mapcar)`, you'll know the first argument is a function, but in this code we have this:

```lisp
'((N) (iterate-list (cons NIL N)))
```

Above is an **anonymous function**. If you're familiar with Ruby, it looks something like this:

```ruby
->(N) { iterate-list [nil, N] }
```

In the case of PicoLisp, our function that we defined on the fly will be applied to the `Value`, but will first make a recursive call to `(iterate-list)` with a `(cons)` pair as its argument.

### (make-object)

This function is almost identical to `(make-array)`, except it generates a JSON Object using opening and closing `{}` braces, of course iterating recursively with `(iterate-list)`.

# The end

That's pretty much all I have to explain about the JSON encoder/decoder FFI binding. I'm very open to providing more details about functionality I've skipped, so just file an [issue](https://github.com/aw/picolisp-json/issues/new) and I'll do my best.

# License

This work is licensed under a [Creative Commons Attribution-ShareAlike 4.0 International License](http://creativecommons.org/licenses/by-sa/4.0/).

Copyright (c) 2015 Alexander Williams, Unscramble <license@unscramble.jp>
