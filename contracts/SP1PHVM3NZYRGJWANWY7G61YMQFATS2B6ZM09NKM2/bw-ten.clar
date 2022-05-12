(use-trait market-trait .marketplace-alt-trait.marketplace)
(use-trait byz-market-trait .custodials-trait.byz-marketplace)
(use-trait sn-market-trait .custodials-trait.sn-marketplace)
(use-trait sa-market-trait .custodials-trait.sa-marketplace)
(use-trait megapont-commission-trait 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.commission-trait.commission)
(use-trait byzantion-commission-trait 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.commission-trait.commission)
(use-trait satoshibles-commission-trait 'SP6P4EJF0VG8V0RB3TQQKJBHDQKEF6NVRD1KZE3C.commission-trait.commission)
;; (use-trait tiger-force-commission-trait 'SP2P6KSAJ4JVV8PFSNKJ9BNG5PEPR4RT71VXZHWBK.tiger-force.commission)
(use-trait project-indigo-commission-trait 'SP176ZMV706NZGDDX8VSQRGMB7QN33BBDVZ6BMNHD.commission-trait.commission)
;; (use-trait crashpunks-commission-trait 'SP176ZMV706NZGDDX8VSQRGMB7QN33BBDVZ6BMNHD.commission-trait.commission)
;; (use-trait stacks-mfers-commission-trait 'SP2N3BAG4GBF8NHRPH6AY4YYH1SP6NK5TGCY7RDFA.stacks-mfers.commission)
;; (use-trait sol-townsfolk-commission-trait 'SPVVASJ83H223TCEP8Z8SHZDFDBFXSM4EGSWCVR2.commission-trait.commission)
;; (use-trait stacks-art-commission-trait 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.commission-trait.commission)
(use-trait nft-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
(use-trait tradables-trait 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.tradable-trait.tradables-trait)

(define-trait megapont-marketplace
    (
        (list-in-ustx (uint uint <megapont-commission-trait>) (response bool uint))

        (unlist-in-ustx (uint) (response bool uint))

        (buy-in-ustx (uint  <megapont-commission-trait>) (response bool uint))
    )
)

(define-trait byzantion-marketplace
    (
        (list-in-ustx (uint uint <byzantion-commission-trait>) (response bool uint))

        (unlist-in-ustx (uint) (response bool uint))

        (buy-in-ustx (uint  <byzantion-commission-trait>) (response bool uint))
    )
)

(define-trait satoshibles-marketplace
    (
        (list-in-ustx (uint uint <satoshibles-commission-trait>) (response bool uint))

        (unlist-in-ustx (uint) (response bool uint))

        (buy-in-ustx (uint  <satoshibles-commission-trait>) (response bool uint))
    )
)

;; (define-trait tiger-force-marketplace
;;     (
;;         (list-in-ustx (uint uint <tiger-force-commission-trait>) (response bool uint))

;;         (unlist-in-ustx (uint) (response bool uint))

;;         (buy-in-ustx (uint  <tiger-force-commission-trait>) (response bool uint))
;;     )
;; )

(define-trait project-indigo-marketplace
    (
        (list-in-ustx (uint uint <project-indigo-commission-trait>) (response bool uint))

        (unlist-in-ustx (uint) (response bool uint))

        (buy-in-ustx (uint  <project-indigo-commission-trait>) (response bool uint))
    )
)

;; (define-trait crashpunks-marketplace
;;     (
;;         (list-in-ustx (uint uint <crashpunks-commission-trait>) (response bool uint))

;;         (unlist-in-ustx (uint) (response bool uint))

;;         (buy-in-ustx (uint  <crashpunks-commission-trait>) (response bool uint))
;;     )
;; )

;; (define-trait stacks-mfers-marketplace
;;     (
;;         (list-in-ustx (uint uint <stacks-mfers-commission-trait>) (response bool uint))

;;         (unlist-in-ustx (uint) (response bool uint))

;;         (buy-in-ustx (uint  <stacks-mfers-commission-trait>) (response bool uint))
;;     )
;; )

;; (define-trait sol-townsfolk-marketplace
;;     (
;;         (list-in-ustx (uint uint <sol-townsfolk-commission-trait>) (response bool uint))

;;         (unlist-in-ustx (uint) (response bool uint))

;;         (buy-in-ustx (uint  <sol-townsfolk-commission-trait>) (response bool uint))
;;     )
;; )

;; (define-trait stacks-art-marketplace
;;     (
;;         (list-in-ustx (uint uint <stacks-art-commission-trait>) (response bool uint))

;;         (unlist-in-ustx (uint) (response bool uint))

;;         (buy-in-ustx (uint  <stacks-art-commission-trait>) (response bool uint))
;;     )
;; )

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

(define-public (buy-megapont-one (collection <megapont-marketplace>) (item-id uint) (comm <megapont-commission-trait>) (price uint))
    (begin 
        (asserts! (is-eq (var-get shutoff-valve) false) ERR-NOT-AUTHORIZED)
        (try! (stx-transfer? (/ (* price (var-get commission-one)) u10000) tx-sender (var-get commission-address-one)))
        (try! (contract-call? collection buy-in-ustx item-id comm))
        (ok true)
    )
)

(define-public (buy-megapont-two (collection <megapont-marketplace>) (item-id uint) (comm <megapont-commission-trait>) (price uint))
    (begin 
        (asserts! (is-eq (var-get shutoff-valve) false) ERR-NOT-AUTHORIZED)
        (try! (stx-transfer? (/ (* price (var-get commission-one)) u10000) tx-sender (var-get commission-address-two)))
        (try! (contract-call? collection buy-in-ustx item-id comm))
        (ok true)
    )
)

(define-public (buy-byzantion-one (collection <byzantion-marketplace>) (item-id uint) (comm <byzantion-commission-trait>) (price uint))
    (begin 
        (asserts! (is-eq (var-get shutoff-valve) false) ERR-NOT-AUTHORIZED)
        (try! (stx-transfer? (/ (* price (var-get commission-one)) u10000) tx-sender (var-get commission-address-one)))
        (try! (contract-call? collection buy-in-ustx item-id comm))
        (ok true)
    )
)

(define-public (buy-byzantion-two (collection <byzantion-marketplace>) (item-id uint) (comm <byzantion-commission-trait>) (price uint))
    (begin 
        (asserts! (is-eq (var-get shutoff-valve) false) ERR-NOT-AUTHORIZED)
        (try! (stx-transfer? (/ (* price (var-get commission-one)) u10000) tx-sender (var-get commission-address-two)))
        (try! (contract-call? collection buy-in-ustx item-id comm))
        (ok true)
    )
)

(define-public (buy-satoshibles-one (collection <satoshibles-marketplace>) (item-id uint) (comm <satoshibles-commission-trait>) (price uint))
    (begin 
        (asserts! (is-eq (var-get shutoff-valve) false) ERR-NOT-AUTHORIZED)
        (try! (stx-transfer? (/ (* price (var-get commission-one)) u10000) tx-sender (var-get commission-address-one)))
        (try! (contract-call? collection buy-in-ustx item-id comm))
        (ok true)
    )
)

;; (define-public (buy-satoshibles-two (collection <satoshibles-marketplace>) (item-id uint) (comm <satoshibles-commission-trait>) (price uint))
;;     (begin 
;;         (asserts! (is-eq (var-get shutoff-valve) false) ERR-NOT-AUTHORIZED)
;;         (try! (stx-transfer? (/ (* price (var-get commission-one)) u10000) tx-sender (var-get commission-address-two)))
;;         (try! (contract-call? collection buy-in-ustx item-id comm))
;;         (ok true)
;;     )
;; )

;; (define-public (buy-tiger-force-one (collection <tiger-force-marketplace>) (item-id uint) (comm <tiger-force-commission-trait>) (price uint))
;;     (begin 
;;         (asserts! (is-eq (var-get shutoff-valve) false) ERR-NOT-AUTHORIZED)
;;         (try! (stx-transfer? (/ (* price (var-get commission-one)) u10000) tx-sender (var-get commission-address-one)))
;;         (try! (contract-call? collection buy-in-ustx item-id comm))
;;         (ok true)
;;     )
;; )

;; (define-public (buy-tiger-force-two (collection <tiger-force-marketplace>) (item-id uint) (comm <tiger-force-commission-trait>) (price uint))
;;     (begin 
;;         (asserts! (is-eq (var-get shutoff-valve) false) ERR-NOT-AUTHORIZED)
;;         (try! (stx-transfer? (/ (* price (var-get commission-one)) u10000) tx-sender (var-get commission-address-two)))
;;         (try! (contract-call? collection buy-in-ustx item-id comm))
;;         (ok true)
;;     )
;; )

(define-public (buy-project-indigo-act1-one (collection <project-indigo-marketplace>) (item-id uint) (comm <project-indigo-commission-trait>) (price uint))
    (begin 
        (asserts! (is-eq (var-get shutoff-valve) false) ERR-NOT-AUTHORIZED)
        (try! (stx-transfer? (/ (* price (var-get commission-one)) u10000) tx-sender (var-get commission-address-one)))
        (try! (contract-call? collection buy-in-ustx item-id comm))
        (ok true)
    )
)

(define-public (buy-project-indigo-act1-two (collection <project-indigo-marketplace>) (item-id uint) (comm <project-indigo-commission-trait>) (price uint))
    (begin 
        (asserts! (is-eq (var-get shutoff-valve) false) ERR-NOT-AUTHORIZED)
        (try! (stx-transfer? (/ (* price (var-get commission-one)) u10000) tx-sender (var-get commission-address-two)))
        (try! (contract-call? collection buy-in-ustx item-id comm))
        (ok true)
    )
)

;; (define-public (buy-crashpunks-v2-one (collection <crashpunks-marketplace>) (item-id uint) (comm <crashpunks-commission-trait>) (price uint))
;;     (begin 
;;         (asserts! (is-eq (var-get shutoff-valve) false) ERR-NOT-AUTHORIZED)
;;         (try! (stx-transfer? (/ (* price (var-get commission-one)) u10000) tx-sender (var-get commission-address-one)))
;;         (try! (contract-call? collection buy-in-ustx item-id comm))
;;         (ok true)
;;     )
;; )

;; (define-public (buy-crashpunks-v2-two (collection <crashpunks-marketplace>) (item-id uint) (comm <crashpunks-commission-trait>) (price uint))
;;     (begin 
;;         (asserts! (is-eq (var-get shutoff-valve) false) ERR-NOT-AUTHORIZED)
;;         (try! (stx-transfer? (/ (* price (var-get commission-one)) u10000) tx-sender (var-get commission-address-two)))
;;         (try! (contract-call? collection buy-in-ustx item-id comm))
;;         (ok true)
;;     )
;; )

;; (define-public (buy-stacks-mfers-one (collection <stacks-mfers-marketplace>) (item-id uint) (comm <stacks-mfers-commission-trait>) (price uint))
;;     (begin 
;;         (asserts! (is-eq (var-get shutoff-valve) false) ERR-NOT-AUTHORIZED)
;;         (try! (stx-transfer? (/ (* price (var-get commission-one)) u10000) tx-sender (var-get commission-address-one)))
;;         (try! (contract-call? collection buy-in-ustx item-id comm))
;;         (ok true)
;;     )
;; )

;; (define-public (buy-stacks-mfers-two (collection <stacks-mfers-marketplace>) (item-id uint) (comm <stacks-mfers-commission-trait>) (price uint))
;;     (begin 
;;         (asserts! (is-eq (var-get shutoff-valve) false) ERR-NOT-AUTHORIZED)
;;         (try! (stx-transfer? (/ (* price (var-get commission-one)) u10000) tx-sender (var-get commission-address-two)))
;;         (try! (contract-call? collection buy-in-ustx item-id comm))
;;         (ok true)
;;     )
;; )

;; (define-public (buy-sol-townsfolk-nft-one (collection <sol-townsfolk-marketplace>) (item-id uint) (comm <sol-townsfolk-commission-trait>) (price uint))
;;     (begin 
;;         (asserts! (is-eq (var-get shutoff-valve) false) ERR-NOT-AUTHORIZED)
;;         (try! (stx-transfer? (/ (* price (var-get commission-one)) u10000) tx-sender (var-get commission-address-one)))
;;         (try! (contract-call? collection buy-in-ustx item-id comm))
;;         (ok true)
;;     )
;; )

;; (define-public (buy-sol-townsfolk-nft-two (collection <sol-townsfolk-marketplace>) (item-id uint) (comm <sol-townsfolk-commission-trait>) (price uint))
;;     (begin 
;;         (asserts! (is-eq (var-get shutoff-valve) false) ERR-NOT-AUTHORIZED)
;;         (try! (stx-transfer? (/ (* price (var-get commission-one)) u10000) tx-sender (var-get commission-address-two)))
;;         (try! (contract-call? collection buy-in-ustx item-id comm))
;;         (ok true)
;;     )
;; )

;; (define-public (buy-stacks-art-one (collection <stacks-art-marketplace>) (item-id uint) (comm <stacks-art-commission-trait>) (price uint))
;;     (begin 
;;         (asserts! (is-eq (var-get shutoff-valve) false) ERR-NOT-AUTHORIZED)
;;         (try! (stx-transfer? (/ (* price (var-get commission-one)) u10000) tx-sender (var-get commission-address-one)))
;;         (try! (contract-call? collection buy-in-ustx item-id comm))
;;         (ok true)
;;     )
;; )

;; (define-public (buy-stacks-art-two (collection <stacks-art-marketplace>) (item-id uint) (comm <stacks-art-commission-trait>) (price uint))
;;     (begin 
;;         (asserts! (is-eq (var-get shutoff-valve) false) ERR-NOT-AUTHORIZED)
;;         (try! (stx-transfer? (/ (* price (var-get commission-one)) u10000) tx-sender (var-get commission-address-two)))
;;         (try! (contract-call? collection buy-in-ustx item-id comm))
;;         (ok true)
;;     )
;; )

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