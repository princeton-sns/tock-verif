#!/usr/bin/env racket
#lang racket/base

(require pkg/lib)
(printf "~a" (path->string (pkg-directory "serval")))

