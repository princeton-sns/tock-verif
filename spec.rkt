#lang rosette/safe

(require
  serval/llvm
  serval/lib/core
  serval/lib/unittest
  serval/spec/refinement
  (only-in racket/base parameterize struct-copy)
)

(provide (all-defined-out))

(struct linklist (len) #:mutable #:transparent)
;(struct nonprimtype (val) #:mutable #:transparent)
(struct staticref (nonprimtype) #:mutable #:transparent)

(struct state (retval linklist staticref) #:mutable #:transparent)

(define (fresh-state)

  (define-symbolic* retval (bitvector 64))

  (define-symbolic* len (bitvector 64))
  (define linklisk len)

  ;(define-symbolic* cell (bitvector 64)) ;boolean?)

  ;(define-symbolic* val (bitvector 64))
  (define nonprimtype (bitvector 64));val)
  (define staticref nonprimtype)

  (state retval linklist staticref))

(define (push-head s len)

  (define linklist (state-linklist))
  (define old-len (linklist-len))
  (define new-len (bvadd old-len (bv 1 64)))

  (linklist new-len)

  (define retval (state-retval))
  (define staticref (state-staticref))

  (state retval linklist staticref))

;(define (take)
;
;  (define retval (state-retval))
;
;  (define cell (state-cell))
;
;  (state retval cell))

(define (deref)

  (define staticref (state-staticref))
  (define nonprimtype (staticref-nonprimtype))
  (nonprimtype))
