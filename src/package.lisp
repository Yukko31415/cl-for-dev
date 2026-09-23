;;; package.lisp
;;;
;;; SPDX-License-Identifier: MIT
;;;
;;; Copyright (C) 2026 Yukko31415


(uiop:define-package #:cl-for-dev/main
  (:use #:cl-sls)
  (:local-nicknames (#:cli #:clingon))
  (:documentation "The cl-for-dev package.")
  (:export #:main #:shutdown))


