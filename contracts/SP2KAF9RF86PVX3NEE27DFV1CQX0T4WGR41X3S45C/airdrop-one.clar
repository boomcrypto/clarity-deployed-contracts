(define-private (mint (id uint))
    (contract-call? .rehab-resort claim)
)

(define-public (mint-many (count uint))
    (let (
        (lists (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.uint-lists lookup count (- count u1)))
    )
        (try! (contract-call? .rehab-resort set-stx-cost u10000))
        (map mint lists)
        (try! (contract-call? .rehab-resort set-stx-cost u45000000))
        (ok true)
    )
)

(define-private (transfer (id uint) (sender principal) (receiver principal))
    (contract-call? .rehab-resort transfer id sender receiver)
)

(define-public (transfer-many (address principal) (ids (list 100 uint)))
    (let (
        (count (len ids))
        (senders (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.principal-lists lookup tx-sender (- count u1)))
        (receivers (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.principal-lists lookup address (- count u1)))
    )
        (map transfer ids senders receivers)
        (ok true)
    )
)