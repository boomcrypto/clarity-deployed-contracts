(use-trait tradables-trait 'SP39EMTZG4P7D55FMEQXEB8ZEQEK0ECBHB1GD8GMT.nft-trait.nft-trait)

(define-data-var commission-percentage uint u5) 
(define-data-var minimum-listing-price uint u1000000) ;; minimum listing price 1 STX

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

(define-data-var wallet-one principal 'SP1KMJR4X9BHS7830AA64316SGKZGQY354JRP2TQ7)
(define-data-var wallet-two principal 'SP28KZ784B7AA6FGANSCPHV9V5CW4J43XT79DFKHG)

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
(define-constant error-could-not-pay-wallet-one u11)
(define-constant error-could-not-pay-wallet-two u12)

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

(define-public (list-asset (tradables <tradables-trait>) (tradable-id uint) (price uint))
  (begin
    (asserts! (is-eq false (var-get listings-frozen)) (err err-listings-frozen))
    (match (map-get? verified-contracts { tradables: (contract-of tradables) })
      contract-name
      (let ((tradable-owner (unwrap! (unwrap-panic (get-owner tradables tradable-id)) (err err-tradable-not-found)))
           (royalty (get-royalty (contract-of tradables)))
           (commission (/ (* price (var-get  commission-percentage)) u100))
        )
       (if (>= price (var-get minimum-listing-price))
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
(define-private (pay-commission (commission uint)) 
  (let (
    (half (/ commission u2))
  ) 
    (match (stx-transfer? half tx-sender (var-get wallet-one)) 
      success
      (match (stx-transfer? half tx-sender (var-get wallet-two)) 
        success2
        (ok success2)
        error
        (err error-could-not-pay-wallet-two)
      )
      error
      (err error-could-not-pay-wallet-one)
    )
  )
)

(define-public (purchase-asset (tradables <tradables-trait>) (tradable-id uint))
  (begin
    (asserts! (is-eq false (var-get purchases-frozen)) (err err-listings-frozen))
    (match (map-get? on-sale {tradables: (contract-of tradables), tradable-id: tradable-id})
      nft-data 
      (let ((price (get price nft-data)) 
            (commission-amount (get commission nft-data)) 
            (royalty-amount (/ (* price (get royalty-percent nft-data)) u100)) 
            (to-owner-amount (- (- price commission-amount) royalty-amount))) 
        ;; first send the amount to the owner
        (match (stx-transfer? to-owner-amount tx-sender (get owner nft-data))
          owner-success ;; sending money to owner succeeded
          (match (pay-commission commission-amount)
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

(define-public (set-commission-percentage (commission uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) (err err-not-allowed))
    (ok (var-set commission-percentage commission))
  )
)

(define-public (add-contract (contract principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) (err err-not-allowed))
    (ok (map-set verified-contracts {tradables: contract} {royalty-address: contract-owner, royalty-percent: u0}))
  )
)

(define-public (remove-contract (contract principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) (err err-not-allowed))
    (ok (map-delete verified-contracts {tradables: contract}))
  )
)

(define-public (set-royalty (contract principal) (address principal) (percent uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) (err err-not-allowed))
    (ok (map-set verified-contracts {tradables: contract} {royalty-address: address, royalty-percent: percent}))
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