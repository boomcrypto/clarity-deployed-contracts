;; Commission for MiamiCoin ($MIA)

(impl-trait 'SP2BSV94A650WGZ2YZ5Y8HM93W01NGT4GY0W2BN3P.commission-trait.commission-trait)

;; errors
(define-constant err-failed-to-transfer-ft u400)
(define-constant err-not-authorized u401)

;; constants
(define-constant contract-owner tx-sender)
(define-constant artist-address 'SP34ZEET21QZMHC7HEKSCEP3B0S53S1GDGZT12M3A)
(define-constant stackerdao-treasury 'SP2BSV94A650WGZ2YZ5Y8HM93W01NGT4GY0W2BN3P.stackerdao-treasury)
(define-constant treasury .citycoins-bulls-treasury)

;; variables
(define-data-var price uint u3000)

(define-public (send-funds)
  (begin
    (unwrap! (contract-call? 'SP466FNC0P7JWTNM2R9T199QRZN1MYEDTAR0KP27.miamicoin-token transfer (/ (* (var-get price) u2) u100) tx-sender stackerdao-treasury (some 0x11)) (err err-failed-to-transfer-ft))
    (unwrap! (contract-call? 'SP466FNC0P7JWTNM2R9T199QRZN1MYEDTAR0KP27.miamicoin-token transfer (/ (* (var-get price) u30) u100) tx-sender treasury (some 0x11)) (err err-failed-to-transfer-ft))
    (if (not (is-eq tx-sender artist-address))
      (unwrap! (contract-call? 'SP466FNC0P7JWTNM2R9T199QRZN1MYEDTAR0KP27.miamicoin-token transfer (/ (* (var-get price) u68) u100) tx-sender artist-address (some 0x11)) (err err-failed-to-transfer-ft))
      false
    )
    (ok true)
  )
)

(define-public (pay (sale-price uint) (owner principal))
  (begin
    (unwrap! (stx-transfer? (/ (* sale-price u1) u100) tx-sender stackerdao-treasury) (err err-failed-to-transfer-ft)) ;; 1% royalty fee to StackerDAOs treasury
    (unwrap! (stx-transfer? (/ (* sale-price u5) u100) tx-sender artist-address) (err err-failed-to-transfer-ft)) ;; 5% royalty fee to project artist
    (ok true)
  )
)

(define-public (set-price (new-price uint))
  (if (is-eq tx-sender contract-owner)
    (begin 
      (var-set price new-price)
      (ok true)
    )
    (err err-not-authorized)
  )
)