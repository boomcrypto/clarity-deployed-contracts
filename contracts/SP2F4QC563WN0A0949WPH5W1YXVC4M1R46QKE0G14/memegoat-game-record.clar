;; MEMEGOAT TICKET PRICE INITIALIZER

(define-constant ERR-NOT-AUTHORIZED (err u1000))
(define-constant ERR-ZERO-VALUE (err u1001))

(define-data-var game-ticket-price uint u0)

(define-read-only (is-dao-or-extension)
	(ok (asserts! (or (is-eq tx-sender .memegoat-community-dao) (contract-call? .memegoat-community-dao is-extension contract-caller)) ERR-NOT-AUTHORIZED))
)

(define-read-only (get-ticket-price)
    (ok (var-get game-ticket-price))
)

(define-public (set-ticket-price (price uint))
    (begin
        (try! (is-dao-or-extension))
        (asserts! (> price u0) ERR-ZERO-VALUE)
        (ok (var-set game-ticket-price price))
    )
)