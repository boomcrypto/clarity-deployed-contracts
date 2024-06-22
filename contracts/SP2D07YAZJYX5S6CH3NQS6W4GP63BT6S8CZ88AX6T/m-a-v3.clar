(define-constant ERR-NOT-AUTH (err u200))

(define-map authorized-caller principal bool)

(map-set authorized-caller .n-n-v3 true)

(define-public (mng-airdrop (id (buff 48)) (idspace (buff 20)) (send-to principal))
    (begin
        (asserts! (is-some (map-get? authorized-caller contract-caller)) ERR-NOT-AUTH)
        (contract-call? .t-a-v3 mng-airdrop-id id idspace send-to)
    )
)
    



