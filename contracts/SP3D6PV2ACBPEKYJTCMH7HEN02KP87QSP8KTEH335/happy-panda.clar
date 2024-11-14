(define-constant ERR-NOT-NFT-HOLDER (err u401))
(define-constant ERR-NO-BALANCE (err u402))

(define-public (noodles)
    (let
        (
            (caller-balance (contract-call? .nakapack-nft get-balance tx-sender))
            (contract-balance (stx-get-balance (as-contract tx-sender)))
            (receiver tx-sender)
        )

        (asserts! (> caller-balance u0) ERR-NOT-NFT-HOLDER)
        (asserts! (> contract-balance u0) ERR-NO-BALANCE)

        (as-contract (stx-transfer? contract-balance tx-sender receiver))))
