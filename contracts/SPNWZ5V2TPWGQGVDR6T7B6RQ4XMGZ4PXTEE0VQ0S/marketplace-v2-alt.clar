(define-data-var minimum-commission uint u100) ;; minimum commission 1% by default
(define-data-var minimum-listing-price uint u1000000) ;; minimum listing price 1 STX
(define-data-var listings-frozen bool false) ;; turn off the ability to list additional NFTs

(define-map on-sale
  {tradables: principal, tradable-id: uint}
  {price: uint, commission: uint, owner: principal}
)

(define-constant contract-owner tx-sender)
(define-constant err-payment-failed u1)
(define-constant err-transfer-failed u2)
(define-constant err-not-allowed u3)
(define-constant err-duplicate-entry u4)
(define-constant err-tradable-not-found u5)
(define-constant err-commission-or-price-too-low u6)
(define-constant err-listings-frozen u7)

(define-read-only (get-listing (tradables principal) (tradable-id uint))
  (match (map-get? on-sale {tradables: tradables, tradable-id: tradable-id})
    nft-data 
    (ok nft-data)
    (err err-tradable-not-found)
  )
)

(define-private (get-owner (tradables principal) (tradable-id uint))
  (contract-call? 'SP497E7RX3233ATBS2AB9G4WTHB63X5PBSP5VGAQ.boom-nfts get-owner tradable-id)
)

(define-private (transfer-tradable-to-escrow (tradables principal) (tradable-id uint))
  (begin
    (contract-call? 'SP497E7RX3233ATBS2AB9G4WTHB63X5PBSP5VGAQ.boom-nfts transfer tradable-id tx-sender (as-contract tx-sender))
  )
)

(define-private (transfer-tradable-from-escrow (tradables principal) (tradable-id uint))
  (let ((owner tx-sender))
    (begin
      (as-contract (contract-call? 'SP497E7RX3233ATBS2AB9G4WTHB63X5PBSP5VGAQ.boom-nfts transfer tradable-id (as-contract tx-sender) owner))
    )
  )
)

(define-private (return-tradable-from-escrow (tradables principal) (tradable-id uint))
  (match (map-get? on-sale {tradables: tradables, tradable-id: tradable-id})
    nft-data
    (let ((owner tx-sender))
      (match (as-contract (contract-call? 'SP497E7RX3233ATBS2AB9G4WTHB63X5PBSP5VGAQ.boom-nfts transfer tradable-id (as-contract tx-sender) (get owner nft-data)))
        success (ok true)
        error (err err-transfer-failed)
      )
    )
    (err err-tradable-not-found)
  )
)

(define-public (list-asset (tradables principal) (tradable-id uint) (price uint) (commission uint))
 (begin
  (asserts! (is-eq false (var-get listings-frozen)) (err err-listings-frozen))
  (let ((tradable-owner (unwrap! (unwrap-panic (get-owner tradables tradable-id)) (err err-tradable-not-found))))
   (if (and (>= commission (var-get minimum-commission)) (>= price (var-get minimum-listing-price)))
    (if (is-eq tradable-owner tx-sender)
     (if (map-insert on-sale {tradables: tradables, tradable-id: tradable-id}
          {price: price, commission: commission, owner: tradable-owner})
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

(define-public (unlist-asset (tradables principal) (tradable-id uint))
  (match (map-get? on-sale {tradables: tradables, tradable-id: tradable-id})
    nft-data 
    (if (is-eq (get owner nft-data) tx-sender)
        (match (transfer-tradable-from-escrow tradables tradable-id)
           success (begin
                     (map-delete on-sale {tradables: tradables, tradable-id: tradable-id})
                     (ok true))
           error (begin (print error) (err err-transfer-failed)))
        (err err-not-allowed)
    )
    (err err-tradable-not-found)
  )
)

;; tx sender has to send the required amount
;; tx sender receives NFT
;; owner gets paid out the amount minus commission
;; stxnft address gets paid out commission
(define-public (purchase-asset (tradables principal) (tradable-id uint))
  (match (map-get? on-sale {tradables: tradables, tradable-id: tradable-id})
    nft-data 
    (let ((price (get price nft-data)) (commission-amount (/ (* price (get commission nft-data)) u10000)) (to-owner-amount (- price commission-amount))) 
      ;; first send the amount to the owner
      (match (stx-transfer? to-owner-amount tx-sender (get owner nft-data))
        owner-success ;; sending money to owner succeeded
        (match (stx-transfer? commission-amount tx-sender contract-owner)
          commission-success ;; sending commission to contract owner succeeded
          (match (transfer-tradable-from-escrow tradables tradable-id)
            transfer-success (begin 
              (map-delete on-sale {tradables: tradables, tradable-id: tradable-id})
              (ok true) ;; sending NFT to buyer succeeded
            )
            error (err err-transfer-failed)
          )
          error (err err-payment-failed)
        )
        error (err err-payment-failed)
      )
    )
    (err err-tradable-not-found)
  )
)

(define-public (admin-unlist-asset (tradables principal) (tradable-id uint))
  (match (map-get? on-sale {tradables: tradables, tradable-id: tradable-id})
    nft-data 
    (if (is-eq contract-owner tx-sender)
        (match (return-tradable-from-escrow tradables tradable-id)
           success (begin
                     (map-delete on-sale {tradables: tradables, tradable-id: tradable-id})
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


