(use-trait market-trait .marketplace-trait.marketplace)
(use-trait byz-market-trait .custodials-trait.byz-marketplace)
(use-trait sn-market-trait .custodials-trait.sn-marketplace)
(use-trait sa-market-trait .custodials-trait.sa-marketplace)
(use-trait commission-trait .commission-trait.commission)
(use-trait nft-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
(use-trait tradables-trait 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.tradable-trait.tradables-trait)

(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u401))

(define-data-var commission-one uint u50)
(define-data-var commission-two uint u50)
(define-data-var commission-address-one principal 'SP1PHVM3NZYRGJWANWY7G61YMQFATS2B6ZM09NKM2)
(define-data-var commission-address-two principal 'SP1PHVM3NZYRGJWANWY7G61YMQFATS2B6ZM09NKM2)
(define-data-var shutoff-valve bool false)


(define-public (buy-custodial-sp-one (market <byz-market-trait>) (collection <nft-trait>) (collection-id (string-ascii 256)) (item-id uint) (price uint)) 
        (begin 
            (asserts! (is-eq (var-get shutoff-valve) false) ERR-NOT-AUTHORIZED)
            (try! (stx-transfer? (/ (* price (var-get commission-one)) u10000) tx-sender (var-get commission-address-two)))
            (try! (contract-call? market buy-item collection collection-id item-id))
            (ok true)
        )
)

(define-public (buy-custodial-sn-one (market <sn-market-trait>) (collection <tradables-trait>) (item-id uint) (price uint))
        (begin 
            (asserts! (is-eq (var-get shutoff-valve) false) ERR-NOT-AUTHORIZED)
            (try! (stx-transfer? (/ (* price (var-get commission-one)) u10000) tx-sender (var-get commission-address-one)))
            (try! (contract-call? market purchase-asset collection item-id))
            (ok true)
        )
)

(define-public (buy-custodial-sn-two (market <sn-market-trait>) (collection <tradables-trait>) (item-id uint) (price uint))
        (begin 
            (asserts! (is-eq (var-get shutoff-valve) false) ERR-NOT-AUTHORIZED)
            (try! (stx-transfer? (/ (* price (var-get commission-two)) u10000) tx-sender (var-get commission-address-two)))
            (try! (contract-call? market purchase-asset collection item-id))
            (ok true)
        )
)

(define-public (buy-custodial-sa-one (market <sa-market-trait>) (collection <nft-trait>) (collection-id uint) (item-id uint) (price uint))
        (begin 
            (asserts! (is-eq (var-get shutoff-valve) false) ERR-NOT-AUTHORIZED)
            (try! (stx-transfer? (/ (* price (var-get commission-one)) u10000) tx-sender (var-get commission-address-one)))
            (try! (contract-call? market buy-item collection collection-id item-id))
            (ok true)
        )
)

(define-public (buy-custodial-sa-two (market <sa-market-trait>) (collection <nft-trait>) (collection-id uint) (item-id uint) (price uint))
        (begin 
            (asserts! (is-eq (var-get shutoff-valve) false) ERR-NOT-AUTHORIZED)
            (try! (stx-transfer? (/ (* price (var-get commission-two)) u10000) tx-sender (var-get commission-address-two)))
            (try! (contract-call? market buy-item collection collection-id item-id))
            (ok true)
        )
)

(define-public (buy-non-custodial-one (collection <market-trait>) (item-id uint) (comm <commission-trait>) (price uint))
    (begin 
        (asserts! (is-eq (var-get shutoff-valve) false) ERR-NOT-AUTHORIZED)
        (try! (stx-transfer? (/ (* price (var-get commission-one)) u10000) tx-sender (var-get commission-address-one)))
        (try! (contract-call? collection buy-in-ustx item-id comm))
        (ok true)
    )
)

(define-public (buy-non-custodial-two (collection <market-trait>) (item-id uint) (comm <commission-trait>) (price uint))
    (begin 
        (asserts! (is-eq (var-get shutoff-valve) false) ERR-NOT-AUTHORIZED)
        (try! (stx-transfer? (/ (* price (var-get commission-one)) u10000) tx-sender (var-get commission-address-two)))
        (try! (contract-call? collection buy-in-ustx item-id comm))
        (ok true)
    )
)

(define-public (change-commission-one (amount uint))
    (begin
        (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
        (var-set commission-one amount)
        (ok true)
    )
)

(define-public (change-commission-two (amount uint))
    (begin
        (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
        (var-set commission-two amount)
        (ok true)
    )
)

(define-public (change-commission-address-one (address principal))
    (begin
        (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
        (var-set commission-address-one address)
        (ok true)
    )
)

(define-public (change-commission-address-two (address principal))
    (begin
        (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
        (var-set commission-address-two address)
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