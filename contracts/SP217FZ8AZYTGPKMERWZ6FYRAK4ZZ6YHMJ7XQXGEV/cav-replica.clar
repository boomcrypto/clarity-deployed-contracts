(define-constant ERR-NOT-FOUND (err u801))
(define-constant ERR-NOT-AUTHORIZED (err u804))
(define-constant admin tx-sender)
(define-map address-checked principal bool)
(define-map id-checked uint bool)

(define-read-only (get-address-checked (address principal)) (default-to false (map-get? address-checked address)))
(define-read-only (get-id-checked (id uint)) (default-to false (map-get? id-checked id)))

(define-public (subscriptions-transfer (ids (list 1500 uint)))
    (ok (map subscription-transfer ids))
)

(define-private (subscription-transfer (id uint)) 
    (let (
        (subscriber (unwrap-panic (contract-call? 'SP1N057R0S5BBAQKTW0GF2J7BXKFHY2GQV9MP2BEN.the-cavalry-spoints-subscriber get-item-subscriber id)))
    )
    (asserts! (is-eq tx-sender admin) ERR-NOT-AUTHORIZED)
    (if (not (or (is-none subscriber) (get-id-checked id))) 
        (begin
            (try! (contract-call? .the-cavalry-spoints-subscriber admin-subscribe 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.the-cavalry-multipliers id (unwrap-panic subscriber))) 
            (map-set id-checked id true)
            (if (not (get-address-checked (unwrap-panic subscriber)))
                (begin  
                    (try! (contract-call? .the-cavalry-spoints-subscriber allocate-balance (unwrap-panic (contract-call? 'SP1N057R0S5BBAQKTW0GF2J7BXKFHY2GQV9MP2BEN.the-cavalry-spoints-subscriber get-collect (unwrap-panic subscriber))) (unwrap-panic subscriber)))
                    (map-set address-checked (unwrap-panic subscriber) true)
                    (ok true))
                (ok true)
            )
        ) 
        (ok true))))