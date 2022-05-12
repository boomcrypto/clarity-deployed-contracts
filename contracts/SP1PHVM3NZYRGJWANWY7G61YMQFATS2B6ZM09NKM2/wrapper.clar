(use-trait market-trait .marketplace-alt-trait.marketplace)
(use-trait byz-market-trait .custodials-trait.byz-marketplace)
(use-trait sn-market-trait .custodials-trait.sn-marketplace)
(use-trait sa-market-trait .custodials-trait.sa-marketplace)
(use-trait nft-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
(use-trait tradables-trait 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.tradable-trait.tradables-trait)

(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u401))

(define-data-var commissions (list 1000 uint) (list u50 u50))
(define-data-var commission-addresses (list 1000 principal) (list 'SP1PHVM3NZYRGJWANWY7G61YMQFATS2B6ZM09NKM2 'SP1PHVM3NZYRGJWANWY7G61YMQFATS2B6ZM09NKM2))
(define-data-var shutoff-valve bool false)


(define-public (buy-custodial-sp-one (market <byz-market-trait>) (collection <nft-trait>) (collection-id (string-ascii 256)) (item-id uint) (price uint) (referer uint)) 
        (begin 
            (asserts! (is-eq (var-get shutoff-valve) false) ERR-NOT-AUTHORIZED)
            (try! (stx-transfer? (/ (* price (unwrap-panic (element-at (var-get commissions) referer))) u10000) tx-sender (unwrap-panic (element-at (var-get commission-addresses) referer))))
            (try! (contract-call? market buy-item collection collection-id item-id))
            (ok true)
        )
)

(define-public (buy-custodial-sn (market <sn-market-trait>) (collection <tradables-trait>) (item-id uint) (price uint) (referer uint))
        (begin 
            (asserts! (is-eq (var-get shutoff-valve) false) ERR-NOT-AUTHORIZED)
            (try! (stx-transfer? (/ (* price (unwrap-panic (element-at (var-get commissions) referer))) u10000) tx-sender (unwrap-panic (element-at (var-get commission-addresses) referer))))
            (try! (contract-call? market purchase-asset collection item-id))
            (ok true)
        )
)

(define-public (buy-custodial-sa (market <sa-market-trait>) (collection <nft-trait>) (collection-id uint) (item-id uint) (price uint) (referer uint))
        (begin 
            (asserts! (is-eq (var-get shutoff-valve) false) ERR-NOT-AUTHORIZED)
            (try! (stx-transfer? (/ (* price (unwrap-panic (element-at (var-get commissions) referer))) u10000) tx-sender (unwrap-panic (element-at (var-get commission-addresses) referer))))
            (try! (contract-call? market buy-item collection collection-id item-id))
            (ok true)
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