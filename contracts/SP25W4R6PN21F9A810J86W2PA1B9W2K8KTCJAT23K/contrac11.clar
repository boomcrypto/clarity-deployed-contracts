;; HELLO STACKS

;; Clarity has a simple syntax, with expressions being lists of symbols,
;; literal values or nested expressions, enclosed in parens.

;; Defines a function 'hello' returning a greeting:

(define-read-only (hello)
  "Hello Stacks")

;; Functions return the value of the expression in their body,
;; without requiring an explicit 'return' statement.
;;
;; Call the defined function by placing its name in parens:

(hello)

;; The result of the call is shown in the sidebar.
