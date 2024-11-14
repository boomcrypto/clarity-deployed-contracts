;; This trait is a subset of the functions of sip-009 trait for NFTs.
(define-trait tradables-trait
  (
     ;; Owner of a given token identifier
    (get-owner (uint) (response (optional principal) uint))
    ;; Transfer from the sender to a new principal
    (transfer (uint principal principal) (response bool uint))
  )
)

(define-data-var minimum-commission uint u50) ;; minimum commission 0.5% by default
(define-data-var minimum-listing-price uint u100000) ;; minimum listing price 0.1 STX

(define-data-var listings-frozen bool false) ;; turn off the ability to list additional NFTs
(define-data-var purchases-frozen bool false) ;; turn off the ability to purchase NFTs
(define-data-var unlistings-frozen bool false) ;; turn off the ability to unlist NFTs

(define-map on-sale
  {tradables: principal, tradable-id: uint}
  {price: uint, commission: uint, owner: principal, royalty-address: principal, royalty-percent: uint}
)

(define-map verified-contracts
  {tradables: principal}
  {royalty-address: principal, royalty-percent: uint}
)

(define-constant contract-owner tx-sender)
(define-constant err-payment-failed u1)
(define-constant err-transfer-failed u2)
(define-constant err-not-allowed u3)
(define-constant err-duplicate-entry u4)
(define-constant err-tradable-not-found u5)
(define-constant err-commission-or-price-too-low u6)
(define-constant err-listings-frozen u7)
(define-constant err-commission-payment-failed u8)
(define-constant err-royalty-payment-failed u9)
(define-constant err-contract-not-authorized u10)

(define-read-only (get-listing (tradables <tradables-trait>) (tradable-id uint))
  (match (map-get? on-sale {tradables: (contract-of tradables), tradable-id: tradable-id})
    nft-data 
    (ok nft-data)
    (err err-tradable-not-found)
  )
)

(define-read-only (get-royalty-amount (contract principal))
  (match (map-get? verified-contracts {tradables: contract})
    royalty-data
    (get royalty-percent royalty-data)
    u0)
)

(define-private (get-royalty (contract principal))
  (match (map-get? verified-contracts {tradables: contract})
    royalty-data
    royalty-data
    {royalty-address: contract-owner, royalty-percent: u0})
)
 
(define-private (get-owner (tradables <tradables-trait>) (tradable-id uint))
  (contract-call? tradables get-owner tradable-id)
)

(define-private (transfer-tradable-to-escrow (tradables <tradables-trait>) (tradable-id uint))
  (begin
    (contract-call? tradables transfer tradable-id tx-sender (as-contract tx-sender))
  )
)

(define-private (transfer-tradable-from-escrow (tradables <tradables-trait>) (tradable-id uint))
  (let ((owner tx-sender))
    (begin
      (as-contract (contract-call? tradables transfer tradable-id (as-contract tx-sender) owner))
    )
  )
)

(define-private (return-tradable-from-escrow (tradables <tradables-trait>) (tradable-id uint))
  (match (map-get? on-sale {tradables: (contract-of tradables), tradable-id: tradable-id})
    nft-data
    (let ((owner tx-sender))
      (begin
        (as-contract (contract-call? tradables transfer tradable-id (as-contract tx-sender) (get owner nft-data)))
      )
    )
    (err err-tradable-not-found)
  )
)

(define-public (list-asset (tradables <tradables-trait>) (tradable-id uint) (price uint) (commission uint))
  (begin
    (asserts! (is-eq false (var-get listings-frozen)) (err err-listings-frozen))
    (match (map-get? verified-contracts { tradables: (contract-of tradables) })
      contract-name
      (let ((tradable-owner (unwrap! (unwrap-panic (get-owner tradables tradable-id)) (err err-tradable-not-found)))
           (royalty (get-royalty (contract-of tradables))))
       (if (and (>= commission (var-get minimum-commission)) (>= price (var-get minimum-listing-price)))
        (if (is-eq tradable-owner tx-sender)
         (if (map-insert on-sale {tradables: (contract-of tradables), tradable-id: tradable-id}
              {price: price, commission: commission, owner: tradable-owner, royalty-address: (get royalty-address royalty), royalty-percent: (get royalty-percent royalty)})
          (begin
           (match (transfer-tradable-to-escrow tradables tradable-id)
            success (begin
                (print {op: "LIST_ASSET", tradables: (contract-of tradables), tradable-id: tradable-id, price: price, commission: commission})
                (ok true))
            error (begin (print error) (err err-transfer-failed))))
          (err err-duplicate-entry)
         )
         (err err-not-allowed)
        )
        (err err-commission-or-price-too-low)
       )
      )
      (err err-contract-not-authorized)
    )
  )
)

(define-public (unlist-asset (tradables <tradables-trait>) (tradable-id uint))
  (begin
    (asserts! (is-eq false (var-get unlistings-frozen)) (err err-listings-frozen))
    (match (map-get? on-sale {tradables: (contract-of tradables), tradable-id: tradable-id})
      nft-data 
      (if (is-eq (get owner nft-data) tx-sender)
          (match (transfer-tradable-from-escrow tradables tradable-id)
             success (begin
                       (map-delete on-sale {tradables: (contract-of tradables), tradable-id: tradable-id})
                       (print {op: "UNLIST_ASSET", tradables: (contract-of tradables), tradable-id: tradable-id})
                       (ok true))
             error (begin (print error) (err err-transfer-failed)))
          (err err-not-allowed)
      )
      (err err-tradable-not-found)
    )
  )
)

;; tx sender has to send the required amount
;; tx sender receives NFT
;; owner gets paid out the amount minus commission
;; stxnft address gets paid out commission
(define-public (purchase-asset (tradables <tradables-trait>) (tradable-id uint))
  (begin
    (asserts! (is-eq false (var-get purchases-frozen)) (err err-listings-frozen))
    (match (map-get? on-sale {tradables: (contract-of tradables), tradable-id: tradable-id})
      nft-data 
      (let ((price (get price nft-data)) 
            (commission-amount (/ (* price (get commission nft-data)) u10000)) 
            (royalty-amount (/ (* price (get royalty-percent nft-data)) u10000)) 
            (to-owner-amount (- (- price commission-amount) royalty-amount))) 
        ;; first send the amount to the owner
        (match (stx-transfer? to-owner-amount tx-sender (get owner nft-data))
          owner-success ;; sending money to owner succeeded
          (match (stx-transfer? commission-amount tx-sender contract-owner)
            commission-success ;; sending commission to contract owner succeeded
              (if (> royalty-amount u0)
                (match (stx-transfer? royalty-amount tx-sender (get royalty-address nft-data))
                  royalty-success ;; sending royalty to artist succeeded
                  (match (transfer-tradable-from-escrow tradables tradable-id)
                    transfer-success (begin 
                      (map-delete on-sale {tradables: (contract-of tradables), tradable-id: tradable-id})
                      (print {op: "PURCHASE_ASSET", tradables: (contract-of tradables), tradable-id: tradable-id, price: price, commission: (get commission nft-data), owner: (get owner nft-data), royalty-address: (get royalty-address nft-data), royalty-percent: (get royalty-percent nft-data)})
                      (ok true) ;; sending NFT to buyer succeeded
                    )
                    error (err err-transfer-failed)
                  )
                  error (err err-royalty-payment-failed)
                )
                (match (transfer-tradable-from-escrow tradables tradable-id)
                  transfer-success (begin 
                    (map-delete on-sale {tradables: (contract-of tradables), tradable-id: tradable-id})
                    (ok true) ;; sending NFT to buyer succeeded
                  )
                  error (err err-transfer-failed)
                )
             )
            error (err err-commission-payment-failed)
          )
          error (err err-payment-failed)
        )
      )
      (err err-tradable-not-found)
    )
  )
)

(define-public (admin-unlist-asset (tradables <tradables-trait>) (tradable-id uint))
  (match (map-get? on-sale {tradables: (contract-of tradables), tradable-id: tradable-id})
    nft-data 
    (if (is-eq contract-owner tx-sender)
        (match (return-tradable-from-escrow tradables tradable-id)
           success (begin
                     (map-delete on-sale {tradables: (contract-of tradables), tradable-id: tradable-id})
                     (print {op: "ADMIN_UNLIST_ASSET", tradables: (contract-of tradables), tradable-id: tradable-id})
                     (ok true))
           error (begin (print error) (err err-transfer-failed)))
        (err err-not-allowed)
    )
    (err err-tradable-not-found)
  )
)

(define-public (set-minimum-commission (commission uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) (err err-not-allowed))
    (print {op: "SET_MINIMUM_COMMISSION", commission: commission})
    (ok (var-set minimum-commission commission))
  )
)

(define-public (add-contract (contract principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) (err err-not-allowed))
    (print {op: "ADD_CONTRACT", contract: contract})
    (ok (map-set verified-contracts {tradables: contract} {royalty-address: contract-owner, royalty-percent: u0}))
  )
)

(define-public (remove-contract (contract principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) (err err-not-allowed))
    (print {op: "REMOVE_CONTRACT", contract: contract})
    (ok (map-delete verified-contracts {tradables: contract}))
  )
)

(define-public (set-royalty (contract principal) (address principal) (percent uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) (err err-not-allowed))
    (print {op: "SET_ROYALTY", contract: contract, address: address, percent: percent})
    (ok (map-set verified-contracts {tradables: contract} {royalty-address: address, royalty-percent: percent}))
  )
)

(define-public (set-minimum-listing-price (price uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) (err err-not-allowed))
    (print {op: "SET_MINIMUM_LISTING_PRICE", price: price})
    (ok (var-set minimum-listing-price price))
  )
)

(define-public (set-listings-frozen (frozen bool))
  (begin
    (asserts! (is-eq tx-sender contract-owner) (err err-not-allowed))
    (print {op: "SET_LISTINGS_FROZEN", frozen: frozen})
    (ok (var-set listings-frozen frozen))
  )
)

(define-public (set-unlistings-frozen (frozen bool))
  (begin
    (asserts! (is-eq tx-sender contract-owner) (err err-not-allowed))
    (print {op: "SET_UNLISTINGS_FROZEN", frozen: frozen})
    (ok (var-set unlistings-frozen frozen))
  )
)

(define-public (set-purchases-frozen (frozen bool))
  (begin
    (asserts! (is-eq tx-sender contract-owner) (err err-not-allowed))
    (print {op: "SET_PURCHASES_FROZEN", frozen: frozen})
    (ok (var-set purchases-frozen frozen))
  )
)