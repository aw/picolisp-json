# Changelog

## 4.0.0 TBD

  * Fix typo in EXPLAIN document
  * Stop testing on broken Travis-CI environment
  * **Breaking changes**
    * Remove all support for PicoLisp namespaces
    * Prefix all internal function names with _json-_
  * Adjust tests to use new function names
  * Remove tests for namespace issue #9
  * Update "picolisp-unit" testing dependency to `v3.0.0`

## 3.10.0 (2018-06-29)

  * Optionally prevent duplicate keys from being accepted with '*Json_prevent_duplicate_keys'
  * Remove optional 'Make' parameter for '(link-array)'

## 3.9.0 (2018-06-19)

  * Store JSON parsing error message in *Msg

## 3.8.0 (2018-03-29)

  * Fix issue #15 -  Invalid parsing of certain characters with \uNNNN
  * Add regression tests for this issue

## 3.7.0 (2018-03-21)

  * Fix issue #13 - Invalid encoding of control characters 0x01-0x1F
  * Add regression tests for this issue

## 3.6.0 (2018-03-21)

  * Fix issue #12 - Invalid encoding of quote and solidus (\\ and \") characters
  * Add regression tests for this issue
  * Fix existing regression tests which provided incorrect results

## 3.5.0 (2018-03-20)

  * Fix issue #11 - Invalid encoding of special control characters (^J, ^M, ^I)
  * Ensure ^H (\b) and ^L (\f) are also encoded correctly
  * Add regression tests for this issue

## 3.4.0 (2018-03-19)

  * Fix issue #10 - Invalid parsing of strings with caret (^)
  * Add regression tests for this issue

## 3.3.0 (2018-02-15)

  * Fix issue #9 - Bug in namespaces functionality
  * Add regression tests for this issue
  * Add notice about namespaces in PicoLisp >= 17.3.4
  * Don't load module.l in json.l

## 3.2.0 (2018-01-10)

  * Fix issue #8 - Invalid encoding of true,false,null
  * Add regression tests for this issue
  * Refactor encoder

## 3.1.0 (2018-01-10)

  * Fix issue #6 - Invalid parsing of empty arrays and empty objects
  * Add regression test, and tests for additional JSON structures
  * Refactor, simplify, and optimize decoder

## 3.0.0 (2018-01-08)

  * Re-implement JSON decoding in pure PicoLisp
  * Remove ffi-bindings (C parson) library
  * [breaking] Errors are sent to STDERR instead of being suppressed

## 2.2.0 (2017-03-23)

  * Restore PicoLisp namespaces for backwards compatibility. Disable with PIL_NAMESPACES=false

## 2.1.0 (2017-03-14)

  * Update 'parson' dependency version

## 2.0.0 (2017-03-09)

  * Remove the use of PicoLisp namespaces (functionally equivalent to 1.1.0)
  * Update 'parson' dependency version

## 1.1.0 (2015-07-08)

  * Update install paths in Makefile
  * Update 'parson' dependency version

## 1.0.0 (2015-06-09)

  * Production release

## 0.6.3 (2015-05-26)

  * Update picolisp-unit to v0.6.2

## 0.6.2 (2015-05-08)

  * Specify explicit git ref for 'parson' library

## 0.6.1 (2015-04-28)

  * Fix bug in make-json-string.

## 0.6.0 (2015-04-28)

  * Remove the need for git submodules
  * Add Makefile for fetching and building dependencies
  * Change default path for dependencies and shared module (.modules and .lib)
  * Adjust README.md, tests and travis-ci unit testing config

## 0.5.2 (2015-04-10)

  * Run travis-ci tests in docker container
  * Update picolisp-unit to v0.6.1

## 0.5.1 (2015-04-08)

  * Ensure module.l requires the correct versions

## 0.5.0 (2015-04-05)

  * Rename some internal functions

## 0.4.2 (2015-04-05)

  * Update picolisp-unit to v0.6.0

## 0.4.1 (2015-04-05)

  * Refactor 'json-boolean call

## 0.4.0 (2015-04-04)

  * Add requires to module.l
  * Update README.md and EXPLAIN.md
  * Replace ffi-bindings with a table, to be more lispy
  * Rename some internal functions

## 0.3.1 (2015-03-30)

  * Update picolisp-unit to v0.5.2

## 0.3.0 (2015-03-24)

  * Prevent leaky globals
  * Update picolisp-unit to v0.4.0
  * Update EXPLAIN.md and README.md
  * Improve travis-ci build and test times

## 0.2.7 (2015-03-19)

  * Add license information to json.l

## 0.2.6 (2015-03-19)

  * Move MODULE_INFO into module.l

## 0.2.5 (2015-03-19)

  * Add unit tests using picolisp-unit
  * Stylistic changes to MODULE_INFO
  * Add update.sh
  * Add note about Updating and Testing
  * Add .travis.yml for automated testing
