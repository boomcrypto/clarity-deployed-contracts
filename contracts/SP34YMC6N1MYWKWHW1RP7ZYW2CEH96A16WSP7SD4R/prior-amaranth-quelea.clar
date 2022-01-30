(define-constant err-caller-must-be-self (err u666))
(define-constant err-caller-must-be-owner (err u200))

(define-data-var self principal (as-contract tx-sender))
(define-data-var owner principal tx-sender)


(define-public (hello)
    (begin
        (print "hello")
        (ok u"world!")
    )
)