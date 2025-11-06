;; sbtc-token-contract

(define-fungible-token flash-sbtc)

(define-data-var claimed bool false)

(define-public (claim)
(begin
;; allowed only once
(asserts! (is-eq (var-get claimed) false) (err u1000))

;; mark claim as done
(var-set claimed true)

;; credit to tx-sender address
(try! (ft-mint? flash-sbtc u100000000 tx-sender))

(ok true)
)
) 