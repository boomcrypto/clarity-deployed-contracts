(define-constant NAME "SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-bitcoin-tulips::bitcoin-tulips")

(define-public (bid (item-id uint) (price uint))
    (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-market-v5 bid-item NAME item-id price))
)

(define-public (reset (item-id uint))
    (let (
            (sender tx-sender)
    )

        (try! (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-market-v5 withdraw-bid NAME item-id)))
        (try! (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-bitcoin-tulips transfer item-id tx-sender sender)))
        (try! (stx-transfer? (stx-get-balance sender) sender (as-contract tx-sender)))
        (ok true)
    )
)

(define-public (withdraw)
    (let (
            (sender tx-sender)
    )

        (as-contract (stx-transfer? (stx-get-balance tx-sender) tx-sender sender))
    )
)