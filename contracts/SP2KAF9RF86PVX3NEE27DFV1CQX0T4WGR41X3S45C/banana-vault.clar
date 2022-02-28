(define-constant ERR-NOT-AUTHORIZED u401)
(define-constant ERR-INVALID-STAKE u104)
(define-constant ERR-NO-MORE-BANANAS u400)
(define-constant CONTRACT-OWNER tx-sender)

(define-data-var shutoff-valve bool false)
(define-data-var contract principal 'SP3B6T2P3C0XEH4RRFP9A4N1RAEWFNNVYFDHE538Y)
(define-data-var admin principal 'SP3B6T2P3C0XEH4RRFP9A4N1RAEWFNNVYFDHE538Y)


(define-public (burn (burn-amount uint))
    (begin
        (asserts! (is-eq tx-sender CONTRACT-OWNER) (err ERR-NOT-AUTHORIZED))
        (try! (contract-call? .btc-monkeys-bananas burn burn-amount))
        (ok true)
    )
)

(define-public (admin-send (address principal) (amount uint))
        (begin
            (asserts! (or (is-eq tx-sender CONTRACT-OWNER) (is-eq tx-sender (var-get admin))) (err ERR-NOT-AUTHORIZED))
            (try! (as-contract (contract-call? .btc-monkeys-bananas transfer amount (as-contract tx-sender) address none)))
            (ok true)
        )
)

(define-public (contract-send (address principal) (amount uint))
        (begin
            (asserts! (is-eq tx-sender (var-get contract)) (err ERR-NOT-AUTHORIZED))
            (try! (as-contract (contract-call? .btc-monkeys-bananas transfer amount (as-contract tx-sender) address none)))
            (ok true)
        )
)

(define-public (contract-change (address principal))
  (if (is-eq tx-sender CONTRACT-OWNER)
    (ok (var-set contract address))
    (err ERR-NOT-AUTHORIZED)
  )
)

(define-public (admin-change (address principal))
  (if (is-eq tx-sender CONTRACT-OWNER)
    (ok (var-set admin address))
    (err ERR-NOT-AUTHORIZED)
  )
)