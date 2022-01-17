(define-map commission { name: (string-ascii 10) } { addresses: (list 10 principal), commissions: (list 10 uint) })

(map-set commission {name: "commission"} { addresses: (list 'SP3TDJVGM30N4Q448704NY304Q1R5A868THEHD8D1 'SPQZF23W7SEYBFG5JQ496NMY0G7379SRYEDREMSV), commissions: (list u300 u700)})

(define-public (total-commission)
    (let (
        (commission-one (unwrap-panic (element-at (unwrap-panic (get commissions (map-get? commission {name: "commission"}))) u0)))
        (commission-two (unwrap-panic (element-at (unwrap-panic (get commissions (map-get? commission {name: "commission"}))) u1)))
    )
    (ok (+ commission-one commission-two))
    )
)

(define-public (pay (id uint) (price uint))
    (let (
        (commission-address-one (unwrap-panic (element-at (unwrap-panic (get addresses (map-get? commission {name: "commission"}))) u0)))
        (commission-one (unwrap-panic (element-at (unwrap-panic (get commissions (map-get? commission {name: "commission"}))) u0)))
        (commission-address-two (unwrap-panic (element-at (unwrap-panic (get addresses (map-get? commission {name: "commission"}))) u1)))
        (commission-two (unwrap-panic (element-at (unwrap-panic (get commissions (map-get? commission {name: "commission"}))) u1)))
    )
    (begin
        (try! (stx-transfer? (/ (* price commission-one) u10000) tx-sender commission-address-one))
        (try! (stx-transfer? (/ (* price commission-two) u10000) tx-sender commission-address-two))
        (ok true)))
)