(use-trait commission-trait 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.commission-trait.commission)

(define-trait marketplace
    (
        (list-in-ustx (uint uint <commission-trait>) (response bool uint))

        (unlist-in-ustx (uint) (response bool uint))

        (buy-in-ustx (uint  <commission-trait>) (response bool uint))
    )
)

(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u401))

(define-data-var commissions (list 1000 uint) (list u50 u50))
(define-data-var commission-addresses (list 1000 principal) (list 'SP1MZSSBD2JHN6HN4JZYEH9T14ZJYK5ZECSM8WYWB 'SPGM79Z1DZ85P0JRTS4VY8BP12G2RKPVH9YV0FHP))
(define-data-var shutoff-valve bool false)

(define-public (buy-item (collection <marketplace>) (item-id uint) (comm <commission-trait>) (referer uint))
    (let (
        (item (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.hback-whales-nft get-listing-in-ustx item-id))
        (price (unwrap-panic (get price item)))
    )
        (begin 
            (asserts! (is-eq (var-get shutoff-valve) false) ERR-NOT-AUTHORIZED)
            (try! (stx-transfer? (/ (* price (unwrap-panic (element-at (var-get commissions) referer))) u10000) tx-sender (unwrap-panic (element-at (var-get commission-addresses) referer))))
            (try! (contract-call? collection buy-in-ustx item-id comm))
            (ok true)
        )
    )
)

(define-public (change-commissions (amounts (list 1000 uint)))
    (begin
        (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
        (var-set commissions amounts)
        (ok true)
    )
)

(define-public (change-commission-addresses (addresses (list 1000 principal)))
    (begin
        (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
        (var-set commission-addresses addresses)
        (ok true)
    )
)

(define-public (shutoff (switch bool))
    (begin
        (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
        (var-set shutoff-valve switch)
        (ok true)
    )
)