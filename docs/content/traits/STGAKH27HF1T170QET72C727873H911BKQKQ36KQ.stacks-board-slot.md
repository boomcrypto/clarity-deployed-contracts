---
title: "Trait stacks-board-slot"
draft: true
---
```
;; ;; https://explorer.stacks.co/txid/0x80eb693e5e2a9928094792080b7f6d69d66ea9cc881bc465e8d9c5c621bd4d07?chain=mainnet
;; (impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

;; use the SIP090 interface (testnet)
;; (impl-trait 'ST1HTBVD3JG9C05J7HBJTHGR0GGW7KXW28M5JS8QE.nft-trait.nft-trait)

;; (impl-trait .nft-trait.nft-trait)
;; (impl-trait .nft-approvable-trait.nft-approvable-trait)
;; testnet
(impl-trait 'STGAKH27HF1T170QET72C727873H911BKQKQ36KQ.nft-trait.nft-trait)
(impl-trait 'STGAKH27HF1T170QET72C727873H911BKQKQ36KQ.nft-approvable-trait.nft-approvable-trait)

(define-non-fungible-token stacks-board-slot uint)

;; constants
(define-constant ERR-NOT-AUTHORIZED u401)
(define-constant ERR-ALL-MINTED u101)
(define-constant ERR-ALREADY-MINTED u102)
(define-constant ERR-UNKNOWN-TIER u103)
(define-constant ERR-UNKNOWN-ID u104)
(define-constant ERR-NOT-FOR-SALE u105)
(define-constant ERR-UNKNOWN-OWNER u106)
(define-constant ERR-FAILED-SET-APPROVAL-FOR u107)
(define-constant ERR-METADATA-FROZEN u108)

(define-constant CONTRACT-OWNER contract-caller)
(define-constant MAX-SUPPLY u353) 
(define-constant ID-TO-TIER (list u6 u6 u6 u6 u6 u6 u6 u6 u6 u6 u6 u6 u5 u5 u5 u5 u6 u6 u6 u6 u6 u6 u6 u6 u6 u6 u6 u6 u4 u4 u4 u4 u4 u4 u4 u4 u6 u6 u6 u6 u6 u6 u6 u6 u6 u6 u6 u6 u3 u3 u3 u3 u3 u3 u3 u3 u3 u2 u2 u2 u2 u2 u2 u2 u2 u2 u2 u2 u2 u2 u2 u2 u2 u2 u2 u2 u2 u2 u2 u2 u2 u2 u2 u2 u2 u2 u2 u2 u2 u1 u1 u1 u1 u1 u1 u1 u1 u1 u1 u1 u1 u1 u1 u1 u1 u1 u1 u1 u1 u1 u1 u1 u1 u1 u1 u1 u1 u1 u1 u1 u1 u1 u1 u1 u1 u1 u1 u1 u1 u1 u1 u1 u1 u1 u1 u1 u1 u1 u1 u1 u1 u1 u1 u1 u1 u1 u1 u1 u1 u1 u1 u1 u1 u1 u1 u1 u1 u1 u1 u1 u1 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0))
(define-constant TIER-TO-MINT-COST (list u50 u190 u270 u600 u675 u1080 u600)) ;; in STX
(define-constant uSTX-TO-STX u1000000)

;; variables 
(define-data-var slot-counter uint u0)
(define-data-var token-uri (string-ascii 256) "https://www.stacks.co/")
(define-data-var royalty-percentage uint u500)
(define-data-var metadata-frozen bool false)

;; map of slot id -> info about slot
(define-map slots-map 
    uint
    { 
        for-sale: bool,
        price: uint,
        minted: bool,
        data-hash: (buff 40),
        approval: principal ;; default will be nft owner
    }
)

;; public functions
(define-public (mint 
    (id uint)
    (for-sale bool)
    (price uint)
    (data-hash (buff 40))
    )
    (let (
        (count (var-get slot-counter))
        (slot-tier (unwrap! (element-at ID-TO-TIER id) (err ERR-UNKNOWN-ID)))
        (cost-per-mint (* (unwrap! (element-at TIER-TO-MINT-COST slot-tier) (err ERR-UNKNOWN-TIER)) uSTX-TO-STX))
        )

        ;; assert we didn't mint more than limit
        (asserts! (< count MAX-SUPPLY) (err ERR-ALL-MINTED)) 
        
        ;; assert we didn't already mint the slot at this tier and index
        (asserts! (is-eq none (get-slot-info id)) (err ERR-ALREADY-MINTED))
        
        (if (is-eq contract-caller CONTRACT-OWNER)
            true
            (try! (stx-transfer? cost-per-mint contract-caller CONTRACT-OWNER))
        )

        (try! (nft-mint? stacks-board-slot id contract-caller))
        (var-set slot-counter (+ u1 count))
        (map-set slots-map id {for-sale: for-sale, price: price, minted: true, data-hash: data-hash, approval: contract-caller})
        (ok id)
    )
)

;; SIP-009
(define-public (transfer (id uint) (owner principal) (recipient principal))
    (begin
        (asserts! (and (is-owner-or-approval id owner) (is-owner-or-approval id contract-caller)) (err ERR-NOT-AUTHORIZED))
        (try! (internal-set-approval-for id recipient)) ;; when transfering to new owner, reset approval to next owner (recipient)
        (nft-transfer? stacks-board-slot id owner recipient)
    )
)

(define-public (update-slot 
    (id uint) 
    (for-sale bool)
    (price uint)
    (data-hash (buff 40))
    )
    (let (
        (slot-info (unwrap! (get-slot-info id) (err ERR-UNKNOWN-ID)))
        )

        ;; asserts the owner is the contract-caller
        (asserts! (is-owner id contract-caller) (err ERR-NOT-AUTHORIZED))
        (ok (map-set slots-map 
            id
            (merge slot-info 
                {
                    for-sale: for-sale,
                    price: price,
                    data-hash: data-hash
                }
            )
        )
        )
    )
)

(define-public (purchase (id uint))
    (let ( 
        (slot-info (unwrap! (get-slot-info id) (err ERR-UNKNOWN-ID)))
        (is-for-sale (get for-sale slot-info))
        (price (get price slot-info))
        (owner (unwrap! (unwrap! (get-owner id) (err ERR-UNKNOWN-OWNER)) (err ERR-UNKNOWN-OWNER)))
        (buyer contract-caller)
        )
        (asserts! is-for-sale (err ERR-NOT-FOR-SALE))
        (try! (pay-owner buyer price owner)) 
        (try! (pay-royalty buyer price CONTRACT-OWNER))
        (try! (internal-set-approval-for id buyer)) ;; when transfering to new owner, reset approval to next owner (buyer)
        (try! (nft-transfer? stacks-board-slot id owner buyer))
        (ok true)
    )
)

(define-public (purchase-and-update-slot
    (id uint)
    (for-sale bool)
    (price uint)
    (data-hash (buff 40))
    )
    (begin 
        (try! (purchase id))
        (try! (update-slot id for-sale price data-hash))
        (ok true)
    )
)

(define-public (set-royalty (percentage uint))
    (begin
        (asserts! (is-eq contract-caller CONTRACT-OWNER) (err ERR-NOT-AUTHORIZED))
        (ok (var-set royalty-percentage percentage))
    )
)

;; approvable trait
(define-public (set-approval-for (id uint) (approval principal))
    (begin 
        (asserts! (is-owner id contract-caller) (err ERR-NOT-AUTHORIZED))
        (internal-set-approval-for id approval)
    )
)

(define-public (burn (id uint))
    (begin
        (asserts! (is-owner id contract-caller) (err ERR-NOT-AUTHORIZED))
        (map-set slots-map id {for-sale: false, price: u0, minted: true, data-hash: 0x00000000000000000000000000000000000000000000000000000000000000000000000000000000, approval: 'SP000000000000000000002Q6VF78})
        (nft-burn? stacks-board-slot id contract-caller)
    )
)

;; read only functions
;; SIP-009
(define-read-only (get-last-token-id)
    (ok (var-get slot-counter)) 
)

;; SIP-009
(define-read-only (get-token-uri (id uint))
    (ok (some (var-get token-uri)))
)

;; SIP-009
(define-read-only (get-owner (id uint))
    (ok (nft-get-owner? stacks-board-slot id))
)

;; approvable trait
(define-read-only (get-approval (id uint))
    (ok 
        (some 
            (unwrap! (get approval (map-get? slots-map id)) (err ERR-UNKNOWN-ID))
        )
    )
)

(define-read-only (get-slot-info (id uint))
    (map-get? slots-map id)
)

(define-read-only (get-royalty)
    (ok (var-get royalty-percentage))
)

;; Set token uri
(define-public (set-token-uri (new-token-uri (string-ascii 80)))
    (begin
        (asserts! (is-eq contract-caller CONTRACT-OWNER) (err ERR-NOT-AUTHORIZED))
        (asserts! (not (var-get metadata-frozen)) (err ERR-METADATA-FROZEN))
        (var-set token-uri new-token-uri)
        (ok true)
    )
)

;; Freeze metadata
(define-public (freeze-metadata)
    (begin
        (asserts! (is-eq contract-caller CONTRACT-OWNER) (err ERR-NOT-AUTHORIZED))
        (var-set metadata-frozen true)
        (ok true)
    )
)


;; private functions

(define-private (is-owner (id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? stacks-board-slot id) false))
)

(define-private (is-approval (id uint) (user principal))
    (is-eq user (unwrap! (unwrap! (get-approval id) false) false))
)

(define-private (is-owner-or-approval (id uint) (user principal))
    (if (or (is-owner id user) (is-approval id user))
        true
        false
    )
)

(define-private (pay-owner (payer principal) (sale-amount uint) (recipient principal))
    (let (
        (percentage (var-get royalty-percentage))
        (split (- sale-amount (/ (* sale-amount percentage) u10000)))
    )
        (stx-transfer? split payer recipient) 
    )
)

(define-private (pay-royalty (payer principal) (sale-amount uint) (recipient principal))
    (let (
        (percentage (var-get royalty-percentage))
        (split (/ (* sale-amount percentage) u10000))
    )
        (stx-transfer? split payer recipient) 
    )
)

;; used when transfering nft to a new owner, set approval to the new owner
(define-private (internal-set-approval-for (id uint) (approval principal))
    (let (
        (slot-info (unwrap! (get-slot-info id) (err ERR-UNKNOWN-ID)))
        )
        (ok (map-set slots-map 
            id 
            (merge slot-info {approval: approval})
            )
        )
    )
)
```
