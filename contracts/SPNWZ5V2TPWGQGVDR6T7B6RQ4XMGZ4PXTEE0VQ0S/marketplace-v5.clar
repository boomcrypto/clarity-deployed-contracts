(use-trait nft-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-data-var minimum-commission uint u200) ;; minimum commission 2% by default
(define-data-var minimum-listing-price uint u1000000) ;; minimum listing price 1 STX

(define-data-var listings-frozen bool false) ;; turn off the ability to list additional NFTs
(define-data-var purchases-frozen bool false) ;; turn off the ability to purchase NFTs
(define-data-var unlistings-frozen bool false) ;; turn off the ability to unlist NFTs

(define-map on-sale
  { nft: principal, nft-id: uint }
  { price: uint, commission: uint, owner: principal, 
    royalty-address: principal, royalty-percent: uint }
)

(define-constant contract-owner tx-sender)
(define-constant contract-address (as-contract tx-sender))
(define-constant err-payment-failed u1)
(define-constant err-transfer-failed u2)
(define-constant err-not-allowed u3)
(define-constant err-duplicate-entry u4)
(define-constant err-nft-not-found u5)
(define-constant err-commission-or-price-too-low u6)
(define-constant err-listings-frozen u7)
(define-constant err-commission-payment-failed u8)
(define-constant err-royalty-payment-failed u9)
(define-constant err-contract-not-authorized u10)

(define-read-only (get-listing (nft <nft-trait>) (nft-id uint))
  (match (map-get? on-sale {nft: (contract-of nft), nft-id: nft-id})
    nft-data
    (ok nft-data)
    (err err-nft-not-found)
  )
)

(define-private (get-owner (nft <nft-trait>) (nft-id uint))
  (contract-call? nft get-owner nft-id)
)

(define-private (transfer-nft-to-escrow (nft <nft-trait>) (nft-id uint))
  (contract-call? nft transfer nft-id tx-sender contract-address)
)

(define-private (transfer-nft-from-escrow (nft <nft-trait>) (nft-id uint))
  (let ((owner tx-sender))
    (as-contract (contract-call? nft transfer nft-id contract-address owner))
  )
)

(define-private (return-nft-from-escrow (nft <nft-trait>) (nft-id uint))
  (let ((nft-data (unwrap! (map-get? on-sale {nft: (contract-of nft), nft-id: nft-id}) (err err-nft-not-found))))
    (as-contract (contract-call? nft transfer nft-id contract-address (get owner nft-data)))
  )
)

(define-public (list-asset (nft <nft-trait>) (nft-id uint) (price uint) (commission uint))
  (let
    (
      (nft-owner (unwrap! (unwrap-panic (get-owner nft nft-id)) (err err-nft-not-found)))
      (royalty-data (get-royalty (contract-of nft)))
      (royalty (unwrap! royalty-data (err err-contract-not-authorized)))
    )
    (asserts! (not (var-get listings-frozen)) (err err-listings-frozen))
    (asserts! (and (>= commission (var-get minimum-commission)) (>= price (var-get minimum-listing-price))) (err err-commission-or-price-too-low))
    (asserts! (is-eq nft-owner tx-sender) (err err-not-allowed))
    (asserts!
      (map-insert on-sale
        {nft: (contract-of nft), nft-id: nft-id}
        {price: price, commission: commission, owner: nft-owner, royalty-address: (get address royalty), royalty-percent: (get percent royalty)}
      )
      (err err-duplicate-entry)
    )
    (ok (unwrap! (transfer-nft-to-escrow nft nft-id) (err err-transfer-failed)))
  )
)

(define-public (unlist-asset (nft <nft-trait>) (nft-id uint))
  (let
    ((nft-data (unwrap! (map-get? on-sale {nft: (contract-of nft), nft-id: nft-id}) (err err-nft-not-found))))

    (asserts! (is-eq false (var-get unlistings-frozen)) (err err-listings-frozen))
    (asserts! (is-eq (get owner nft-data) tx-sender) (err err-not-allowed) )

    (map-delete on-sale {nft: (contract-of nft), nft-id: nft-id})
    (ok (unwrap! (transfer-nft-from-escrow nft nft-id) (err err-transfer-failed)))
  )
)

(define-public (change-price (nft <nft-trait>) (nft-id uint) (price uint))
  (let
    ((nft-data (unwrap! (map-get? on-sale {nft: (contract-of nft), nft-id: nft-id}) (err err-nft-not-found))))
    (asserts! (is-eq (get owner nft-data) tx-sender) (err err-not-allowed))

    (ok (map-set on-sale {nft: (contract-of nft), nft-id: nft-id}
                         {price: price, 
                          commission: (get commission nft-data), 
                          owner: (get owner nft-data), 
                          royalty-address: (get royalty-address nft-data), 
                          royalty-percent: (get royalty-percent nft-data)}))
  )
)

;; tx sender has to send the required amount
;; tx sender receives NFT
;; owner gets paid out the amount minus commission
;; stxnft address gets paid out commission
(define-public (purchase-asset (nft <nft-trait>) (nft-id uint))
  (let
    (
      (nft-data (unwrap! (map-get? on-sale {nft: (contract-of nft), nft-id: nft-id}) (err err-nft-not-found)))
      (price (get price nft-data))
      (commission-amount (/ (* price (get commission nft-data)) u10000))
      (royalty-amount (/ (* price (get royalty-percent nft-data)) u10000))
      (to-owner-amount (- (- price commission-amount) royalty-amount))
    )
    (asserts! (is-eq false (var-get purchases-frozen)) (err err-listings-frozen))
    ;; first send the amount to the owner
    (unwrap! (stx-transfer? to-owner-amount tx-sender (get owner nft-data)) (err err-payment-failed))
    ;; send commission
    (unwrap! (stx-transfer? commission-amount tx-sender contract-owner) (err err-commission-payment-failed))

    (if (> royalty-amount u0)
      ;; send royalties
      (unwrap! (stx-transfer? royalty-amount tx-sender (get royalty-address nft-data)) (err err-royalty-payment-failed))
      ;; else do noting
      true
    )

    (unwrap! (transfer-nft-from-escrow nft nft-id) (err err-transfer-failed))
    (map-delete on-sale {nft: (contract-of nft), nft-id: nft-id})
    (ok true)
  )
)

(define-public (admin-unlist-asset (nft <nft-trait>) (nft-id uint))
  (match (map-get? on-sale {nft: (contract-of nft), nft-id: nft-id})
    nft-data
    (begin
      ;; here we intentionally use tx-sender instead of contract-caller because this one can be protected by post-conditions as it transfers assets
      (asserts! (is-eq tx-sender contract-owner) (err err-not-allowed))
        (unwrap! (return-nft-from-escrow nft nft-id) (err err-transfer-failed))
        (map-delete on-sale {nft: (contract-of nft), nft-id: nft-id})
        (ok true)
    )
    (err err-nft-not-found)
  )
)

(define-public (set-minimum-commission (commission uint))
  (begin
    (asserts! (is-eq contract-caller contract-owner) (err err-not-allowed))
    (ok (var-set minimum-commission commission))
  )
)

(define-public (set-minimum-listing-price (price uint))
  (begin
    (asserts! (is-eq contract-caller contract-owner) (err err-not-allowed))
    (ok (var-set minimum-listing-price price))
  )
)

(define-public (set-listings-frozen (frozen bool))
  (begin
    (asserts! (is-eq contract-caller contract-owner) (err err-not-allowed))
    (ok (var-set listings-frozen frozen))
  )
)

(define-public (set-unlistings-frozen (frozen bool))
  (begin
    (asserts! (is-eq contract-caller contract-owner) (err err-not-allowed))
    (ok (var-set unlistings-frozen frozen))
  )
)

(define-public (set-purchases-frozen (frozen bool))
  (begin
    (asserts! (is-eq contract-caller contract-owner) (err err-not-allowed))
    (ok (var-set purchases-frozen frozen))
  )
)

(define-private (get-royalty (collection principal))
  (contract-call? .nft-oracle get-royalty-amount collection)
)