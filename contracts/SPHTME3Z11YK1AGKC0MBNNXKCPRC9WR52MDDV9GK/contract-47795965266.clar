;; CLARITY DEMO

;; Expressions are instantly evaluated in the side panel:

(print "HelloWorld!")

;; Change any of the numbers for a different sum:

(+ 2 3 5)

;; Evaluate with your account as principal (after signing in):

(print tx-sender)

(stx-get-balance tx-sender)

;; Constant values can be defined and used in expressions:

(define-constant answer 42)

(- 100 answer)

;; Definitions are analyzed instantly to determine their result type:

(define-data-var counter int 0)

(define-read-only (get-counter)
  (var-get counter))
  
  
;;
