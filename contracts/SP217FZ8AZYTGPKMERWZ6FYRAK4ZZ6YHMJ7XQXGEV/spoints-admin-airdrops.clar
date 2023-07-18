;; spoints-admin-airdrops
(define-constant ERR-NOT-AUTHORIZED u404)

(define-public (spoints-airdrop (item-admin uint) (item-receiver uint) (amount uint)) 
    (let (
        (admins (unwrap-panic (contract-call? .spoints get-approved-principals )))
    )
    (asserts! (is-some (index-of admins tx-sender)) (err ERR-NOT-AUTHORIZED))    
    (unwrap-panic (contract-call? .spoints collect item-admin amount))
    (unwrap-panic (contract-call? .spoints send item-admin item-receiver amount))
    (ok amount)))

(contract-call? .spoints principal-approve (as-contract tx-sender))