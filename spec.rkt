#lang rosette/safe

(require
  serval/llvm
  serval/lib/core
  serval/lib/unittest
  serval/spec/refinement
  (only-in racket/base parameterize struct-copy)
)

(provide (all-defined-out))

(struct state (retval) #:mutable #:transparent)

(define (init s)
  (set-state-retval! s (bv 0 32)))

(define (init-head s)
  (set-state-retval! s (bv 1 32)))

(define (init-tail s)
  (set-state-retval! s (bv 1 32)))
