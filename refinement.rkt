#lang rosette/safe

(require
  serval/llvm
  serval/lib/core
  serval/lib/unittest
  serval/spec/refinement
  (only-in racket/base parameterize struct-copy)
  (prefix-in spec: "./spec.rkt")
  (prefix-in program: "./tockverif.ll.rkt")
  (prefix-in program: "./tockverif.map.rkt")
  (prefix-in program: "./tockverif.globals.rkt")
)

(provide (all-defined-out))

; The abstraction function is just the identity function because we're
; currently using the LLVM `machine` type as the state type for the spec as
; well as the implementation
(define (abs-function m)
  (spec:state (machine-retval m))
)

; This is basically copied from the certikos LLVM verifier, so I'm not 100%
; sure what it does.
(define (make-machine-func func)
  ; our `func` takes some number of arguments, we want to output a function
  ; that takes a `machine` struct and a `list` of arguments
  (lambda (m . args)
    ; I don't know what `parameterize` does exactly
    (parameterize ([current-machine m])
      ; OK, call `func` by passing in each of the elements in `args` as a
      ; separate argument
      (define result (apply func args))
      ; Store the result of the function as the machine's retvalv field
      (set-machine-retval! m result))))

; Representation invariant:
; "foobar" is always positive. Why? Idk... just to have _some_ invariant
(define (rep-invariant m)
  #t
)

; Refine for an LLVM machine
(define (verify-llvm-refinement spec-func impl-func [args null])
  (define implmachine (make-machine program:symbols program:globals)) ; `machine` state used for impl
  (define specstate (spec:state (make-bv64))) ; specification state
  (verify-refinement
    #:implstate implmachine
    #:impl (make-machine-func impl-func) ; go from LLVM function to machine function
    #:specstate specstate
    #:spec spec-func
    #:abs abs-function ; abstraction function
    #:ri rep-invariant
    args))

; Unit tests to run the refinement
(define test-tests
  (test-suite+ "Test LLVM tests"
	(test-case+ "init"
		(verify-llvm-refinement spec:init program:@init (list)))
	(test-case+ "init_head"
		(verify-llvm-refinement spec:init-head program:@init_head (list)))
	(test-case+ "init_tail"
		(verify-llvm-refinement spec:init-tail program:@init_tail (list)))
))

(module+ test
 (time (run-tests test-tests)))

