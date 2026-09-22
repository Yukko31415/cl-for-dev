;;; main.lisp
;;;
;;; SPDX-License-Identifier: MIT
;;;
;;; Copyright (C) 2026 Yukko31415



(in-package #:cl-for-dev/main)


;;;; ----
;; make

(defun make/handler (cmd &aux (system (cli:getopt cmd :system)))
  (and-let* ((source (asdf:system-source-directory system)))
    (uiop:chdir source)
    (format t (with-output-to-string (stream)
		(uiop:run-program
		 (format nil "~A ~A ~A ~A ~A" "sbcl" "--noinform" "--non-interactive" "--eval \'(terpri)\'"
			 (format nil "--eval \"(handler-case (asdf:make \\\"~A\\\" :verbose t)
                                                    (error (c) (format t \\\"~%ERROR: ~~A~%~%\\\" c) (uiop:quit)))\""
				 system))
		 :output stream
		 :error-output stream)))))



(defun make/command ()
  (cli:make-command
   :name "make"
   :handler #'make/handler
   :arguments (list
	       (cli:make-argument :name "system" :key :system :required t
				  :description "system"))))


;;;; ----
;; exec


(defparameter *lock* (bt:make-lock))
(defparameter *cv*   (bt:make-condition-variable))
(defparameter *running* t)


(defun exec/handler (cmd &aux
		       (system (cli:getopt cmd :system))
		       (port   (cli:getopt cmd :port)))
  (let ((source (asdf:system-source-directory system))
	(port   (or (when port (string->number port)) 4005)))

    (let ((init-file (merge-pathnames #P".config/cl-for-dev/init.lisp"
				      (user-homedir-pathname))))
      (when (probe-file init-file) (load init-file)))
    
    (uiop:chdir source)
    (asdf:load-system system)
    (slynk:create-server :port port :dont-close t)

    (bt:with-lock-held (*lock*)
      (loop :while *running*
	    :do (bt:condition-wait *cv* *lock*)))))


(defun shutdown ()
  (bt:with-lock-held (*lock*)
    (set@ *running* nil)
    (bt:condition-notify *cv*)))


(defun exec/command ()
  (cli:make-command
   :name "exec"
   :handler #'exec/handler
   :arguments (list
	       (cli:make-argument :name "system" :key :system :required t
				  :description "system")
	       (cli:make-argument :name "port"   :key :port
				  :description "port"))))


;;;; ---------
;; top-level


(defun top-level/command ()
  (cli:make-command
   :name "cl"
   :sub-commands (list (exec/command) (make/command))))

(defun main (&aux (cmd (top-level/command)))
  "Entry point for the application."
  (cli:run cmd))


