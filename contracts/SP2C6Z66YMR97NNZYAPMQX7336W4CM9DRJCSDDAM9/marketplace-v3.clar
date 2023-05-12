(use-trait tradables-trait 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.tradable-trait.tradables-trait)

(define-data-var minimum-commission uint u100) ;; minimum commission 1% by default
(define-data-var minimum-listing-price uint u1000000) ;; minimum listing price 1 STX

(define-data-var listings-frozen bool false) ;; turn off the ability to list additional NFTs
(define-data-var purchases-frozen bool false) ;; turn off the ability to purchase NFTs
(define-data-var unlistings-frozen bool false) ;; turn off the ability to unlist NFTs

(define-map on-sale
  {tradables: principal, tradable-id: uint}
  {price: uint, commission: uint, owner: principal, royalty-address: principal, royalty-percent: uint}
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

(define-private (get-royalty (contract principal))
    {
        royalty-address: (unwrap-panic (from-consensus-buff? principal (get hash-bytes (unwrap-panic (principal-destruct? contract))))),
        royalty-percent: (contract-call? 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.marketplace-v4 get-royalty-amount contract)
    }
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
      (let ((tradable-owner (unwrap! (unwrap-panic (get-owner tradables tradable-id)) (err err-tradable-not-found)))
           (royalty (get-royalty (contract-of tradables))))
       (if (and (>= commission (var-get minimum-commission)) (>= price (var-get minimum-listing-price)))
        (if (is-eq tradable-owner tx-sender)
         (if (map-insert on-sale {tradables: (contract-of tradables), tradable-id: tradable-id}
              {price: price, commission: commission, owner: tradable-owner, royalty-address: (get royalty-address royalty), royalty-percent: (get royalty-percent royalty)})
          (begin
           (match (transfer-tradable-to-escrow tradables tradable-id)
            success (begin
                (ok true))
            error (begin (print error) (err err-transfer-failed))))
          (err err-duplicate-entry)
         )
         (err err-not-allowed)
        )
        (err err-commission-or-price-too-low)
       )
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
    (ok (var-set minimum-commission commission))
  )
)

(define-public (set-minimum-listing-price (price uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) (err err-not-allowed))
    (ok (var-set minimum-listing-price price))
  )
)

(define-public (set-listings-frozen (frozen bool))
  (begin
    (asserts! (is-eq tx-sender contract-owner) (err err-not-allowed))
    (ok (var-set listings-frozen frozen))
  )
)

(define-public (set-unlistings-frozen (frozen bool))
  (begin
    (asserts! (is-eq tx-sender contract-owner) (err err-not-allowed))
    (ok (var-set unlistings-frozen frozen))
  )
)

(define-public (set-purchases-frozen (frozen bool))
  (begin
    (asserts! (is-eq tx-sender contract-owner) (err err-not-allowed))
    (ok (var-set purchases-frozen frozen))
  )
)
