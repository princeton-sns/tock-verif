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

(provide refinement-tests)

; The abstraction function is just the identity function because we're
; currently using the LLVM `machine` type as the state type for the spec as
; well as the implementation
(define (abs-function m)

  ; Get list of implementation memory regions
  (define mreg (machine-mregions m))
  (define mret (machine-retval m))

  ; Find block containing global var LINKLIST
  (define linklist-block (find-block-by-name mreg 'LINKLIST))
  (define linklist (mblock-iload linklist-block (list)))

  ; Find block containing global var TAKECELL
  (define cell-block (find-block-by-name mreg 'TAKECELL))
  (define cell (mblock-iload cell-block (list)))

  ; Find block containing global var STATICREF
  (define staticref-block (find-block-by-name mreg '_ZN9tockverif9STATICREF17h1c694fd28c190db1E))
  (define staticref (mblock-iload staticref-block (list)))

  ; Construct specification state
  ;(spec:state mret linklist)
  ;(spec:state mret cell)
  (spec:state mret linklist staticref)
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
      ; Store the result of the function as the machine's retval field
      (set-machine-retval! m result))))

; Representation invariant:
; "foobar" is always positive. Why? Idk... just to have _some_ invariant
(define (rep-invariant m)
  #t
)

; Refine for an LLVM machine
(define (verify-llvm-refinement spec-func impl-func [args null])
  (define implmachine (make-machine program:symbols program:globals)) ; `machine` state used for impl

  (verify-refinement
    #:implstate implmachine
    #:impl (make-machine-func impl-func) ; go from LLVM function to machine function
    #:specstate (spec:fresh-state) ;specstate
    #:spec spec-func
    #:abs abs-function ; abstraction function
    #:ri rep-invariant
    args))

; Unit tests to run the refinement
(define refinement-tests
  ;(test-suite+ "Linked list LLVM tests"
  ;      (test-case+ "push_head() -> increments size by 1"
  ;      	(verify-llvm-refinement spec:push-head program:@push_head (list)))
  ;)
  (test-suite+ "TakeCell LLVM tests"
        (test-case+ "take() on empty cell -> None"
        	(verify-llvm-refinement spec:take program:@take (list)))
  )
  ;(test-suite+ "StaticRef LLVM tests"
  ;      (test-case+ "deref() -> 0"
  ;      	(verify-llvm-refinement spec:deref program:@deref (list)))
  ;)
)

(module+ test
 (time (run-tests refinement-tests)))

