;; Buy and Sell Stacks Art
(use-trait nft-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-constant ERR-NOT-AUTHORIZED u401)
(define-constant ERR-BID-NOT-HIGH-ENOUGH u100)
(define-constant ERR-ITEM-NOT-FOR-SALE u101)
(define-constant ERR-ITEM-PRICE-TOO-LOW u102)
(define-constant CONTRACT-OWNER tx-sender)

(define-map collections { id: uint } {
  name: (string-ascii 256),
  artist: principal,
  address: (optional principal),
  commission: uint,
  royalty: uint,
  royalty-address: (optional principal)
})
(define-map item-for-sale { collection-id: uint, item-id: uint } { seller: (optional principal), price: uint })
(define-map item-bids { collection-id: uint, item-id: uint } { buyer: principal, offer: uint })

(define-data-var last-collection-id uint u0)

(define-read-only (get-item-for-sale (collection-id uint) (item-id uint))
  (default-to
    { seller: none, price: u99000000000000 }
    (map-get? item-for-sale { collection-id: collection-id, item-id: item-id })
  )
)

(define-read-only (get-collection-by-id (collection-id uint))
  (default-to
    { name: "null", artist: CONTRACT-OWNER, address: none, commission: u0, royalty: u0, royalty-address: none }
    (map-get? collections { id: collection-id })
  )
)

(define-read-only (get-item-bid (collection-id uint) (item-id uint))
  (default-to
    { buyer: CONTRACT-OWNER, offer: u0 }
    (map-get? item-bids { collection-id: collection-id, item-id: item-id })
  )
)

;;;;;;;;;;;;;;;;;;;;;;
;; public functions ;;
;;;;;;;;;;;;;;;;;;;;;;

(define-public (add-collection
  (name (string-ascii 256))
  (address principal)
  (commission uint)
  (royalty uint)
  (royalty-address principal)
)
  (begin
    (asserts!
      (or
        (is-eq tx-sender CONTRACT-OWNER)
        (is-eq (contract-call? .stacks-art-artists is-verified-artist tx-sender) true)
      )
      (err ERR-NOT-AUTHORIZED)
    )
    (map-set collections { id: (var-get last-collection-id)} {
      name: name,
      artist: tx-sender,
      address: (some address),
      commission: (if (is-eq tx-sender CONTRACT-OWNER)
        commission
        u250
      ),
      royalty: royalty,
      royalty-address: (some royalty-address)
    })
    (var-set last-collection-id (+ u1 (var-get last-collection-id)))
    (ok true)
  )
)

(define-public (list-item (collection <nft-trait>) (collection-id uint) (item-id uint) (price uint))
  (let (
    (collection-entry (get-collection-by-id collection-id))
    (item-owner (unwrap-panic (contract-call? collection get-owner item-id)))
  )
    (asserts! (is-eq tx-sender (unwrap-panic item-owner)) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-eq (contract-of collection) (unwrap-panic (get address collection-entry))) (err ERR-NOT-AUTHORIZED))
    (asserts! (> price u0) (err ERR-ITEM-PRICE-TOO-LOW))

    (map-set item-for-sale { collection-id: collection-id, item-id: item-id } { seller: (some tx-sender), price: price })
    (map-delete item-bids { collection-id: collection-id, item-id: item-id })

    (print {
      type: "marketplace",
      action: "list-item",
      data: { collection-id: collection-id, item-id: item-id, seller: tx-sender, price: price }
    })
    (contract-call? collection transfer item-id tx-sender (as-contract tx-sender))
  )
)

(define-public (change-price (collection <nft-trait>) (collection-id uint) (item-id uint) (price uint))
  (let (
    (collection-entry (get-collection-by-id collection-id))
    (item (get-item-for-sale collection-id item-id))
    (sender tx-sender)
  )
    (asserts! (is-some (get seller item)) (err ERR-ITEM-NOT-FOR-SALE))
    (asserts! (is-eq sender (unwrap-panic (get seller item))) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-eq (contract-of collection) (unwrap-panic (get address collection-entry))) (err ERR-NOT-AUTHORIZED))
    (asserts! (> price u0) (err ERR-ITEM-PRICE-TOO-LOW))

    (map-set item-for-sale { collection-id: collection-id, item-id: item-id } { seller: (some tx-sender), price: price })
    (print {
      type: "marketplace",
      action: "change-price",
      data: { collection-id: collection-id, item-id: item-id, seller: sender, price: price }
    })
    (ok true)
  )
)

(define-public (unlist-item (collection <nft-trait>) (collection-id uint) (item-id uint))
  (let (
    (collection-entry (get-collection-by-id collection-id))
    (item (get-item-for-sale collection-id item-id))
    (sender tx-sender)
    (bid (get-item-bid collection-id item-id))
  )
    (asserts! (is-some (get seller item)) (err ERR-ITEM-NOT-FOR-SALE))
    (asserts! (is-eq sender (unwrap-panic (get seller item))) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-eq (contract-of collection) (unwrap-panic (get address collection-entry))) (err ERR-NOT-AUTHORIZED))

    (map-delete item-for-sale { collection-id: collection-id, item-id: item-id })

    (if (> (get offer bid) u0)
      (begin
        (try! (as-contract (stx-transfer? (get offer bid) tx-sender (get buyer bid))))
        (map-delete item-bids { collection-id: collection-id, item-id: item-id })
      )
      true
    )

    (print {
      type: "marketplace",
      action: "unlist-item",
      data: { collection-id: collection-id, item-id: item-id }
    })
    (as-contract (contract-call? collection transfer item-id tx-sender sender))
  )
)

(define-public (bid-item (collection-id uint) (item-id uint) (amount uint))
  (let (
    (item (get-item-for-sale collection-id item-id))
    (bid (get-item-bid collection-id item-id))
  )
    (asserts! (is-some (get seller item)) (err ERR-ITEM-NOT-FOR-SALE))
    (asserts! (> amount (get offer bid)) (err ERR-BID-NOT-HIGH-ENOUGH))

    (match (stx-transfer? amount tx-sender (as-contract tx-sender))
      success (begin
        (if (> (get offer bid) u0)
          (begin
            (try! (as-contract (stx-transfer? (get offer bid) tx-sender (get buyer bid))))
            (map-delete item-bids { collection-id: collection-id, item-id: item-id })
          )
          true
        )
        (map-set item-bids { collection-id: collection-id, item-id: item-id } { buyer: tx-sender, offer: amount })
        (print {
          type: "marketplace",
          action: "bid-item",
          data: { collection-id: collection-id, item-id: item-id, buyer: tx-sender, offer: amount }
        })
        (ok amount)
      )
      error (err error)
    )
  )
)

(define-public (withdraw-bid (collection-id uint) (item-id uint))
  (let (
    (item (get-item-for-sale collection-id item-id))
    (bid (get-item-bid collection-id item-id))
    (sender tx-sender)
  )
    (asserts! (is-some (get seller item)) (err ERR-ITEM-NOT-FOR-SALE))
    (asserts! (is-eq tx-sender (get buyer bid)) (err ERR-NOT-AUTHORIZED))

    (match (as-contract (stx-transfer? (get offer bid) tx-sender sender))
      success (begin
        (map-delete item-bids { collection-id: collection-id, item-id: item-id })
        (print {
          type: "marketplace",
          action: "withdraw-bid",
          data: { collection-id: collection-id, item-id: item-id, buyer: tx-sender }
        })
        (ok (get offer bid))
      )
      error (err error)
    )
  )
)

(define-public (accept-bid (collection <nft-trait>) (collection-id uint) (item-id uint))
  (let (
    (collection-entry (get-collection-by-id collection-id))
    (item (get-item-for-sale collection-id item-id))
    (bid (get-item-bid collection-id item-id))
    (commission (/ (* (get offer bid) (get commission collection-entry)) u10000))
    (royalty (/ (* (get offer bid) (get royalty collection-entry)) u10000))    
  )
    (asserts! (is-some (get seller item)) (err ERR-ITEM-NOT-FOR-SALE))
    (asserts! (is-eq tx-sender (unwrap-panic (get seller item))) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-eq (contract-of collection) (unwrap-panic (get address collection-entry))) (err ERR-NOT-AUTHORIZED))

    (try! (as-contract (stx-transfer? commission tx-sender CONTRACT-OWNER)))
    (if (is-some (get royalty-address collection-entry))
      (try! (as-contract (stx-transfer? royalty tx-sender (unwrap-panic (get royalty-address collection-entry)))))
      true
    )
    (try! (as-contract (stx-transfer? (- (- (get offer bid) commission) royalty) tx-sender (unwrap-panic (get seller item)))))
    (map-delete item-for-sale { collection-id: collection-id, item-id: item-id })
    (map-delete item-bids { collection-id: collection-id, item-id: item-id })

    (try! (as-contract (contract-call? collection transfer item-id tx-sender (get buyer bid))))

    (print {
      type: "marketplace",
      action: "accept-bid",
      data: { collection-id: collection-id, item-id: item-id }
    })
    (ok true)
  )
)

(define-public (buy-item (collection <nft-trait>) (collection-id uint) (item-id uint))
  (let (
    (collection-entry (get-collection-by-id collection-id))
    (item-owner (unwrap-panic (contract-call? collection get-owner item-id)))
    (item (get-item-for-sale collection-id item-id))
    (sender tx-sender)
    (commission (/ (* (get price item) (get commission collection-entry)) u10000))
    (royalty (/ (* (get price item) (get royalty collection-entry)) u10000))
    (bid (get-item-bid collection-id item-id))
  )
    (asserts! (not (is-eq tx-sender (unwrap-panic item-owner))) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-some (get seller item)) (err ERR-ITEM-NOT-FOR-SALE))
    (asserts! (is-eq (contract-of collection) (unwrap-panic (get address collection-entry))) (err ERR-NOT-AUTHORIZED))

    (try! (stx-transfer? commission sender CONTRACT-OWNER))
    (if (not (is-eq sender (unwrap-panic (get seller item))))
      (try! (stx-transfer? (- (- (get price item) commission) royalty) sender (unwrap-panic (get seller item))))
      true
    )
    (if (> (get offer bid) u0)
      (begin
        (try! (as-contract (stx-transfer? (get offer bid) tx-sender (get buyer bid))))
        (map-delete item-bids { collection-id: collection-id, item-id: item-id })
      )
      true
    )
    (if (and (is-some (get royalty-address collection-entry)) (> royalty u0))
      (try! (stx-transfer? royalty sender (unwrap-panic (get royalty-address collection-entry))))
      true
    )

    (map-delete item-for-sale { collection-id: collection-id, item-id: item-id })
    (try! (as-contract (contract-call? collection transfer item-id tx-sender sender)))

    (print {
      type: "marketplace",
      action: "buy-item",
      data: { collection-id: collection-id, item-id: item-id }
    })
    (ok true)
  )
)

(define-public (admin-unlist (collection <nft-trait>) (collection-id uint) (item-id uint))
  (let (
    (collection-entry (get-collection-by-id collection-id))
    (item (get-item-for-sale collection-id item-id))
    (bid (get-item-bid collection-id item-id))
  )
    (asserts! (is-eq tx-sender CONTRACT-OWNER) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-some (get seller item)) (err ERR-ITEM-NOT-FOR-SALE))
    (asserts! (is-eq (contract-of collection) (unwrap-panic (get address collection-entry))) (err ERR-NOT-AUTHORIZED))

    (map-delete item-for-sale { collection-id: collection-id, item-id: item-id })
    (if (> (get offer bid) u0)
      (begin
        (try! (as-contract (stx-transfer? (get offer bid) tx-sender (get buyer bid))))
        (map-delete item-bids { collection-id: collection-id, item-id: item-id })
      )
      true
    )

    (print {
      type: "marketplace",
      action: "admin-unlist",
      data: { collection-id: collection-id, item-id: item-id }
    })
    (as-contract (contract-call? collection transfer item-id tx-sender (unwrap-panic (get seller item))))
  )
)

(define-public (admin-remove-bid (collection-id uint) (item-id uint))
  (let (
    (item (get-item-for-sale collection-id item-id))
    (bid (get-item-bid collection-id item-id))
  )
    (asserts! (is-some (get seller item)) (err ERR-ITEM-NOT-FOR-SALE))
    (asserts! (is-eq tx-sender CONTRACT-OWNER) (err ERR-NOT-AUTHORIZED))

    (match (as-contract (stx-transfer? (get offer bid) tx-sender (get buyer bid)))
      success (begin
        (map-delete item-bids { collection-id: collection-id, item-id: item-id })
        (print {
          type: "marketplace",
          action: "admin-remove-bid",
          data: { collection-id: collection-id, item-id: item-id, buyer: (get buyer bid) }
        })
        (ok (get offer bid))
      )
      error (err error)
    )
  )
)

(define-public (set-sale-commission (collection-id uint) (commission uint))
  (let (
    (collection-entry (get-collection-by-id collection-id))
  )
    (asserts! (is-eq tx-sender CONTRACT-OWNER) (err ERR-NOT-AUTHORIZED))
    (map-set collections { id: collection-id } (merge collection-entry { commission: commission }))
    (ok true)
  )
)


(define-public (set-royalty (collection-id uint) (royalty uint) (royalty-address principal))
  (let (
    (collection-entry (get-collection-by-id collection-id))
  )
    (asserts! (is-eq tx-sender CONTRACT-OWNER) (err ERR-NOT-AUTHORIZED))
    (map-set collections { id: collection-id } (merge collection-entry { royalty: royalty, royalty-address: (some royalty-address) }))
    (ok true)
  )
)

(begin
  (try! (add-collection "Phases of Satoshi" 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.phases-of-satoshi u250 u500 'SPBFZ5MRGDMEKWNQTJ57W2PA2GC0765ZFC5BY0KP))
  (try! (add-collection "Blue Ridge Biker" 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.blue-ridge-biker u250 u500 'SPTQQE9SEV82CZ3DWCV5AY8ZSX3HK3GK7FTAZNV8))
  (try! (add-collection "Stacks Pops" 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.stacks-pops u250 u500 'SP1WGVYWSZJM1EKH1TYB2BH3W4ZPEJBMW1N2B9FG0))
  (try! (add-collection "Stacks Pops" 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.stacks-pops u250 u500 'SP1WGVYWSZJM1EKH1TYB2BH3W4ZPEJBMW1N2B9FG0))
  (try! (add-collection "Bitcoin Birds" 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.bitcoin-birds u250 u500 'SP2K9XEKEG7BE5BTYWZDAXJ8QAZBJ2TQZJJY3MV90))
  (try! (add-collection "Belle's Witches" 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.belles-witches u250 u500 'SP2S7AE08KCDQQ7S7JF4W6FH0GZ9920ENC3ET9ATP))
  (try! (add-collection "Byte Fighters" 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.byte-fighters u250 u500 'SP228WEAEMYX21RW0TT5T38THPNDYPPGGVW2RP570))
  (try! (add-collection "Blocks" 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.blocks u250 u500 'SP3ZMEFW7VH796ZQAH1JMAJT4WC4VPEZZFB6W5CAD))
)
