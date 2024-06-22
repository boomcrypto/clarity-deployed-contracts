(define-constant ERR-NOT-AUTH (err u200))

(define-map authorized-caller principal bool)

(map-set authorized-caller 'SP2D07YAZJYX5S6CH3NQS6W4GP63BT6S8CZ88AX6T.n-n-a-v2 true)

(define-public (mng-airdrop (id (buff 48)) (idspace (buff 20)) (send-to principal))
    (begin
        (asserts! (is-some (map-get? authorized-caller contract-caller)) ERR-NOT-AUTH)
        (contract-call? .t-a-v2 mng-airdrop-id id idspace send-to)
    )
)