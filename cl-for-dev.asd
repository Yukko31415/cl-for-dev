;;; cl-for-dev.asd
;;;
;;; SPDX-License-Identifier: MIT
;;;
;;; Copyright (C) 2026 Yukko31415


(asdf:defsystem #:cl-for-dev
  :description "A basic application."
  :author      "Yukko31415"
  :license     "MIT"
  :version     "0.1.0"
  :build-operation "program-op"
  :entry-point "cl-for-dev/main:main"
  :build-pathname "cl"
  :depends-on  (:cl-scheme-like-syntax :clingon :bordeaux-threads :slynk)
  :serial t
  :components ((:file "src/package")
               (:file "src/main")))
 

#+sb-core-compression
(defmethod asdf:perform ((o asdf:image-op) (c asdf:system))
  (uiop:dump-image (asdf:output-file o c) :executable t :compression t))

(defmethod asdf:perform :around ((o asdf:load-op) (c (cl:eql (asdf:find-system :slynk))))
  (with-output-to-string (*debug-io*)
    (call-next-method)))


