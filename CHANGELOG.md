# Changelog

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
