(use-trait tradables-trait .tradables-trait.tradables-trait)

(define-data-var minimum-listing-stx-price uint u1000000) ;; minimum listing price 1 STX
(define-data-var minimum-listing-sto-price uint u1000000) ;; minimum listing price 1 STX
(define-data-var minimum-listing-citycoin-price uint u1) ;; minimum listing price CityCoin
(define-data-var primary-commission uint u250)
(define-data-var listings-frozen bool false) ;; turn off the ability to list additional NFTs
(define-data-var purchases-frozen bool false) ;; turn off the ability to purchase NFTs
(define-data-var unlistings-frozen bool false) ;; turn off the ability to unlist NFTs
 
(define-map on-sale
  {tradables: principal, tradable-id: uint}
  {price: uint, currency: uint, commission: uint, owner: principal, royalty-address: principal, royalty-percent: uint}
)

(define-constant contract-owner tx-sender)
(define-constant err-payment-failed u100)
(define-constant err-transfer-failed u200)
(define-constant err-not-allowed u300)
(define-constant err-duplicate-entry u400)
(define-constant err-tradable-not-found u500)
(define-constant err-commission-or-price-too-low u600)
(define-constant err-listings-frozen u700)
(define-constant err-commission-payment-failed u800)
(define-constant err-royalty-payment-failed u900)
(define-constant err-contract-not-authorized u1000)
(define-constant err-wrong-currency u1100)

(define-read-only (get-listing (tradables <tradables-trait>) (tradable-id uint))
  (match (map-get? on-sale {tradables: (contract-of tradables), tradable-id: tradable-id})
    nft-data 
    (ok nft-data)
    (err err-tradable-not-found)
  )
)

(define-private (get-royalty (contract principal) (tradable-id uint))
  (match (map-get? on-sale {tradables: contract, tradable-id: tradable-id})
    nft-data 
    (ok nft-data)
    (err err-tradable-not-found)
  )
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

(define-public (list-asset (tradables <tradables-trait>) (tradable-id uint) (price uint) (currency uint) )
  (begin
    (asserts! (is-eq false (var-get listings-frozen)) (err err-listings-frozen))
      (let ((tradable-owner (unwrap! (unwrap-panic (get-owner tradables tradable-id)) (err err-tradable-not-found)))
           (royalty (get-royalty (contract-of tradables) tradable-id))
           (commission (var-get primary-commission))
          )
       (if (or (is-eq currency u1) (is-eq currency u2) (is-eq currency u3) )
          (if (>= price (var-get minimum-listing-sto-price))
              (if (is-eq tradable-owner tx-sender)
                  (if (map-insert on-sale {tradables: (contract-of tradables), tradable-id: tradable-id}
                      {price: price, currency: currency, commission: commission, owner: tradable-owner, royalty-address: contract-owner, royalty-percent: u0})
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
          (if (or (is-eq currency u4) (is-eq currency u5))
            (if (>= price (var-get minimum-listing-citycoin-price))
                (if (is-eq tradable-owner tx-sender)
                    (if (map-insert on-sale {tradables: (contract-of tradables), tradable-id: tradable-id}
                        {price: price, currency: currency, commission: commission, owner: tradable-owner, royalty-address: contract-owner, royalty-percent: u0})
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
            (err err-wrong-currency)
          )
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
;; stacksocean address gets paid out commission
(define-public (purchase-asset (tradables <tradables-trait>) (tradable-id uint))
  (begin
    (asserts! (is-eq false (var-get purchases-frozen)) (err err-listings-frozen))
    (match (map-get? on-sale {tradables: (contract-of tradables), tradable-id: tradable-id})
      nft-data 
        (let ((price (get price nft-data)) 
            (commission-amount (/ (* price (get commission nft-data)) u10000)) 
            (royalty-amount (/ (* price (get royalty-percent nft-data)) u10000)) 
            (to-owner-amount (- (- price commission-amount) royalty-amount))
             (currency (get currency nft-data))
            ) 
            ;; first send the amount to the owner
            (if (is-eq currency u1)
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
              (if (is-eq currency u2) ;;Send the second currency (STO)
                (match (contract-call? .sto-token transfer to-owner-amount tx-sender (get owner nft-data) none)
                    owner-success ;; sending money to owner succeeded
                    (match (contract-call? .sto-token transfer commission-amount tx-sender contract-owner none)
                        commission-success ;; sending commission to contract owner succeeded
                        (if (> royalty-amount u0)
                          (match (contract-call? .sto-token transfer royalty-amount tx-sender (get royalty-address nft-data) none)
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
                (if (is-eq currency u3) ;;Send the third currency (FARI)
                  (match (contract-call? 'SP213KNHB5QD308TEESY1ZMX1BP8EZDPG4JWD0MEA.fari-token-mn transfer to-owner-amount tx-sender (get owner nft-data) none)
                      owner-success ;; sending money to owner succeeded
                      (match (contract-call? 'SP213KNHB5QD308TEESY1ZMX1BP8EZDPG4JWD0MEA.fari-token-mn transfer commission-amount tx-sender contract-owner none)
                          commission-success ;; sending commission to contract owner succeeded
                          (if (> royalty-amount u0)
                            (match (contract-call? 'SP213KNHB5QD308TEESY1ZMX1BP8EZDPG4JWD0MEA.fari-token-mn transfer royalty-amount tx-sender (get royalty-address nft-data) none)
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
                  (if (is-eq currency u4) ;;Send the FORTH currency (MIA)
                    (match (contract-call? 'SP466FNC0P7JWTNM2R9T199QRZN1MYEDTAR0KP27.miamicoin-token transfer to-owner-amount tx-sender (get owner nft-data) none)
                        owner-success ;; sending money to owner succeeded
                        (match (contract-call? 'SP466FNC0P7JWTNM2R9T199QRZN1MYEDTAR0KP27.miamicoin-token transfer commission-amount tx-sender contract-owner none)
                            commission-success ;; sending commission to contract owner succeeded
                            (if (> royalty-amount u0)
                              (match (contract-call? 'SP466FNC0P7JWTNM2R9T199QRZN1MYEDTAR0KP27.miamicoin-token transfer royalty-amount tx-sender (get royalty-address nft-data) none)
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
                    (if (is-eq currency u5) ;;Send the FIFTH currency (NYC)
                      (match (contract-call? 'SP2H8PY27SEZ03MWRKS5XABZYQN17ETGQS3527SA5.newyorkcitycoin-token transfer to-owner-amount tx-sender (get owner nft-data) none)
                          owner-success ;; sending money to owner succeeded
                          (match (contract-call? 'SP2H8PY27SEZ03MWRKS5XABZYQN17ETGQS3527SA5.newyorkcitycoin-token transfer commission-amount tx-sender contract-owner none)
                              commission-success ;; sending commission to contract owner succeeded
                              (if (> royalty-amount u0)
                                (match (contract-call? 'SP2H8PY27SEZ03MWRKS5XABZYQN17ETGQS3527SA5.newyorkcitycoin-token transfer royalty-amount tx-sender (get royalty-address nft-data) none)
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
                      (err err-payment-failed)
                    )
                  )
                )
              )
            )
        )
        (err err-tradable-not-found))
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

(define-public (set-primary-commission (commission uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) (err err-not-allowed))
    (ok (var-set primary-commission commission))
  )
)


(define-public (set-minimum-listing-citycoin-price (price uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) (err err-not-allowed))
    (ok (var-set minimum-listing-citycoin-price price))
  )
)
(define-public (set-minimum-listing-sto-price (price uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) (err err-not-allowed))
    (ok (var-set minimum-listing-sto-price price))
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