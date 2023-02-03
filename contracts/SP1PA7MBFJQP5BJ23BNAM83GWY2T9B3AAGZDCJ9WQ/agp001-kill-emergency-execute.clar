;; Title: AGP001 Kill Emergency Execute
;; Author: Marvin Janssen / ALEX Dev Team
;; Synopsis:
;; This proposal disables extension "age003 Emergency Execute".
;; Description:
;; If this proposal passes, extension "age003 Emergency Execute" is immediately
;; disabled.

(impl-trait .proposal-trait.proposal-trait)

(define-public (execute (sender principal))
	(contract-call? .executor-dao set-extension .age003-emergency-execute false)
)