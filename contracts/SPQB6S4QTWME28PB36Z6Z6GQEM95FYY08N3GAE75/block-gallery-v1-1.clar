;; Block Gallery Marketplace v1
(use-trait nft-trait .sip009-nft-trait.sip009-nft-trait)

;; Errors
(define-constant ERR-UNAUTHORIZED u101)
(define-constant ERR-NOT-FOR-SALE u102)
(define-constant ERR-PRICE-TOO-LOW u103)
(define-constant ERR-NOT-WHITELISTED u104)
(define-constant ERR-HAS-LISTED-ITEMS u105)
(define-constant ERR-MARKET-FROZEN u106)
(define-constant ERR-CONTRACT-FROZEN u107)

;; Constants
(define-constant CONTRACT-OWNER tx-sender)

;; Variables
(define-data-var last-item-id uint u0)
(define-data-var market-frozen bool false) ;; Prevent buy-item, list-item, and update-item from being called
(define-data-var commission-address principal tx-sender)

;; Admins
(define-map market-admins principal bool) ;; Value is permission to set/remove other admins

;; Whitelisted contracts
(define-map market-contracts principal
  {
    frozen: bool,
    royalty: uint,
    commission: uint,
    creator: principal,
    listed-items: uint,
    minimum-price: uint
  }
)

;; Items listed on the market
(define-map market-items { item-id: uint, nft: principal }
  {
    price: uint,
    token-id: uint,
    seller: principal
  }
)

;; Read-only functions
(define-read-only (get-admin (admin principal))
  (map-get? market-admins admin)
)

(define-read-only (get-contract (nft principal))
  (map-get? market-contracts nft)
)

(define-read-only (get-item (item-id uint) (nft principal))
  (map-get? market-items { item-id: item-id, nft: nft })
)

(define-read-only (get-market-frozen)
  (var-get market-frozen)
)

(define-read-only (get-commission-address)
  (var-get commission-address)
)

;; Public functions
(define-public (set-admin (admin principal) (permission bool))
  (begin
    ;; Ensure tx-sender has permission
    (asserts! (is-admin tx-sender true) (err ERR-UNAUTHORIZED))

    ;; Print event
    (print {
      action: (if (is-some (get-admin admin)) "update-admin" "new-admin"),
      data: {
        admin: admin,
        permission: permission
      }
    })

    ;; Create or update admin
    (map-set market-admins admin permission)

    (ok true)
  )
)

(define-public (remove-admin (admin principal))
  (begin
    ;; Ensure tx-sender has permission
    (asserts! (is-admin tx-sender true) (err ERR-UNAUTHORIZED))

    ;; Remove admin
    (map-delete market-admins admin)

    ;; Print event
    (print {
      action: "remove-admin",
      data: {
        admin: admin
      }
    })

    (ok true)
  )
)

(define-public (set-contract (nft principal) (creator principal) (royalty uint) (commission uint) (minimum-price uint) (frozen bool))
  (let (
    (listed-items (default-to u0 (get listed-items (get-contract nft))))
  )
    ;; Ensure tx-sender is an admin
    (asserts! (is-admin tx-sender false) (err ERR-UNAUTHORIZED))

    ;; Print event
    (print {
      action: (if (is-some (get-contract nft)) "update-contract" "new-contract"),
      data: {
        nft: nft,
        frozen: frozen,
        royalty: royalty,
        commission: commission,
        creator: creator,
        listed-items: listed-items,
        minimum-price: minimum-price
      }
    })

    ;; Create or update collection
    (map-set market-contracts nft
      {
        frozen: frozen,
        royalty: royalty,
        commission: commission,
        creator: creator,
        listed-items: listed-items,
        minimum-price: minimum-price
      }
    )

    (ok true)
  )
)

(define-public (remove-contract (nft principal))
  (begin
    ;; Ensure tx-sender is an admin
    (asserts! (is-admin tx-sender false) (err ERR-UNAUTHORIZED))

    ;; Ensure nft is whitelisted
    (unwrap! (get-contract nft) (err ERR-NOT-WHITELISTED))

    ;; Ensure the whitelisted contract has no items listed
    (asserts!
      (is-eq u0 (unwrap-panic (get listed-items (get-contract nft))))
      (err ERR-HAS-LISTED-ITEMS)
    )

    ;; Remove contract
    (map-delete market-contracts nft)

    ;; Print event
    (print {
      action: "remove-contract",
      data: {
        nft: nft
      }
    })

    (ok true)
  )
)

(define-public (list-item (nft <nft-trait>) (token-id uint) (price uint))
  (let (
    (item-id (var-get last-item-id))
    (contract (unwrap! (get-contract (contract-of nft)) (err ERR-NOT-WHITELISTED)))
  )
    ;; Ensure market is not frozen
    (asserts! (not (var-get market-frozen)) (err ERR-MARKET-FROZEN))

    ;; Ensure contract is not frozen
    (asserts! (not (get frozen contract)) (err ERR-CONTRACT-FROZEN))

    ;; Ensure price is greater than or equal to the minimum price
    (asserts! (>= price (get minimum-price contract)) (err ERR-PRICE-TOO-LOW))

    ;; Add item to market
    (map-insert market-items { item-id: item-id, nft: (contract-of nft) }
      {
        price: price,
        token-id: token-id,
        seller: tx-sender
      }
    )

    ;; Increment listed-items on the whitelisted contract by 1
    (map-set market-contracts (contract-of nft)
      (merge contract {
        listed-items: (+ u1 (get listed-items contract))
      })
    )

    ;; Increment last-item-id by 1
    (var-set last-item-id (+ u1 item-id))

    ;; Transfer token from the seller to the contract
    (try!
      (contract-call? nft transfer token-id tx-sender (as-contract tx-sender))
    )

    ;; Print event
    (print {
      action: "list-item",
      data: {
        nft: nft,
        price: price,
        seller: tx-sender,
        item-id: item-id,
        token-id: token-id
      }
    })

    (ok true)
  )
)

(define-public (update-item (nft <nft-trait>) (item-id uint) (price uint))
  (let (
    (item (unwrap!
      (get-item item-id (contract-of nft))
      (err ERR-NOT-FOR-SALE)
    ))
  )
    ;; Ensure market is not frozen
    (asserts! (not (var-get market-frozen)) (err ERR-MARKET-FROZEN))

    ;; Ensure contract is not frozen
    (asserts!
      (not (get frozen (unwrap! (get-contract (contract-of nft)) (err ERR-NOT-WHITELISTED))))
      (err ERR-CONTRACT-FROZEN)
    )

    ;; Ensure tx-sender is the seller of the token
    (asserts! (is-eq tx-sender (get seller item)) (err ERR-UNAUTHORIZED))

    ;; Ensure price is greater than or equal to the minimum price
    (asserts!
      (>= price (unwrap-panic (get minimum-price (get-contract (contract-of nft)))))
      (err ERR-PRICE-TOO-LOW)
    )

    ;; Update item
    (map-set market-items { item-id: item-id, nft: (contract-of nft) }
      (merge item { price: price })
    )

    ;; Print event
    (print {
      action: "update-item",
      data: {
        nft: nft,
        price: price,
        seller: (get seller item),
        item-id: item-id,
        token-id: (get token-id item)
      }
    })

    (ok true)
  )
)

(define-public (unlist-item (nft <nft-trait>) (item-id uint))
  (let (
    (item (unwrap! (get-item item-id (contract-of nft)) (err ERR-NOT-FOR-SALE)))
    (contract (unwrap-panic (get-contract (contract-of nft))))
    (is-seller (is-eq tx-sender (get seller item)))
  )
    ;; Ensure tx-sender is the seller or an admin
    (asserts! (or is-seller (is-admin tx-sender false)) (err ERR-UNAUTHORIZED))

    ;; Remove item
    (map-delete market-items { item-id: item-id, nft: (contract-of nft) })

    ;; Decrement listed-items on the whitelisted contract by 1
    (map-set market-contracts (contract-of nft)
      (merge contract {
        listed-items: (- (get listed-items contract) u1)
      })
    )

    ;; Transfer item from the contract to the seller
    (try!
      ;; Switch contract-call? context to the contract instead of the tx-sender
      (as-contract
        (contract-call? nft transfer (get token-id item) tx-sender (get seller item))
      )
    )

    ;; Print event
    (print {
      action: (if is-seller "seller-unlist-item" "admin-unlist-item"),
      data: {
        nft: nft,
        price: u0,
        seller: (get seller item),
        item-id: item-id,
        token-id: (get token-id item)
      }
    })

    (ok true)
  )
)

(define-public (buy-item (nft <nft-trait>) (item-id uint))
  (let (
    (buyer tx-sender)
    (item (unwrap! (get-item item-id (contract-of nft)) (err ERR-NOT-FOR-SALE)))
    (contract (unwrap-panic (get-contract (contract-of nft))))
    (creator-royalty (calc-fee (get price item) (get royalty contract)))
    (market-commission (calc-fee (get price item) (get commission contract)))
    (total-fees (+ market-commission creator-royalty))
    (profit (- (get price item) (+ market-commission creator-royalty)))
  )
    ;; Ensure market is not frozen
    (asserts! (not (var-get market-frozen)) (err ERR-MARKET-FROZEN))

    ;; Ensure contract is not frozen
    (asserts! (not (get frozen contract)) (err ERR-CONTRACT-FROZEN))

    ;; Transfer market commission if the buyer is not the commission-address
    (and
      (not (is-eq buyer (var-get commission-address)))
      (> market-commission u0)
      (try! (stx-transfer? market-commission buyer (var-get commission-address)))
    )

    ;; Transfer creator royalty if the buyer is not the creator
    (and
      (not (is-eq buyer (get creator contract)))
      (> creator-royalty u0)
      (try! (stx-transfer? creator-royalty buyer (get creator contract)))
    )

    ;; Transfer sale profit if the buyer is not the seller
    (and
      (not (is-eq buyer (get seller item)))
      (> profit u0)
      (try! (stx-transfer? profit buyer (get seller item)))
    )

    ;; Transfer item from the contract to the buyer
    (try!
      ;; Switch contract-call? context to the contract instead of the tx-sender
      (as-contract
        (contract-call? nft transfer (get token-id item) tx-sender buyer)
      )
    )

    ;; Remove item
    (map-delete market-items { item-id: item-id, nft: (contract-of nft) })

    ;; Decrement listed-items on the whitelisted contract by 1
    (map-set market-contracts (contract-of nft)
      (merge contract {
        listed-items: (- (get listed-items contract) u1)
      })
    )

    ;; Print event
    (print {
      action: "buy-item",
      data: {
        nft: nft,
        price: (get price item),
        buyer: buyer,
        seller: (get seller item),
        item-id: item-id,
        token-id: (get token-id item)
      }
    })

    (ok true)
  )
)

(define-public (set-market-frozen (frozen bool))
  (begin
    ;; Ensure tx-sender has permission
    (asserts! (is-admin tx-sender false) (err ERR-UNAUTHORIZED))

    ;; Update market-frozen
    (var-set market-frozen frozen)

    ;; Print event
    (print {
      action: "set-market-frozen",
      data: {
        market-frozen: frozen
      }
    })

    (ok true)
  )
)

(define-public (set-commission-address (address principal))
  (begin
    ;; Ensure tx-sender has permission
    (asserts! (is-admin tx-sender false) (err ERR-UNAUTHORIZED))

    ;; Update commission-address
    (var-set commission-address address)

    ;; Print event
    (print {
      action: "set-commission-address",
      data: {
        address: address
      }
    })

    (ok true)
  )
)

;; Private functions
(define-private (is-admin (address principal) (permission bool))
  (or
    (is-eq address CONTRACT-OWNER)
    ;; Ensure admin has permission to set/remove other admins
    (match (get-admin address) has-permission
      (or (not permission) has-permission)
      false
    )
  )
)

(define-private (calc-fee (price uint) (fee uint))
  ;; Calculate fee for a given price
  ;; (price * fee) / (1 million micro STX)
  (/ (* price fee) u1000000)
)
