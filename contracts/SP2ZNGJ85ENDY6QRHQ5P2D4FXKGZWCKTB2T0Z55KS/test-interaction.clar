;; Test Interaction Contract
;;
;; Purpose:
;; This contract serves as a simple test implementation of the interaction-trait
;; for the Charisma protocol. It provides a basic action that can be triggered
;; through the Charisma Interaction Client.

;; Constants
(define-constant ERR_INVALID_ACTION (err u100))
(define-constant ERR_UNAUTHORIZED (err u101))
(define-constant contract-owner tx-sender)

;; Data Variables
(define-data-var contract-uri (optional (string-utf8 256)) (some u"https://charisma.rocks/white-paper.pdf"))

;; Public functions

;; Implement get-interaction-uri from interaction-trait
(define-read-only (get-interaction-uri)
  (ok (var-get contract-uri))
)

;; Implement take-action from interaction-trait
(define-public (take-action (action (string-ascii 32)))
  (if (is-eq action "TEST")
      (begin
        (print "Test action executed successfully!")
        (ok true)
      )
      (err ERR_INVALID_ACTION)
  )
)

;; Admin function to update the contract URI
(define-public (set-contract-uri (new-uri (optional (string-utf8 256))))
  (begin
    (asserts! (is-eq tx-sender contract-owner) ERR_UNAUTHORIZED)
    (ok (var-set contract-uri new-uri))
  )
)