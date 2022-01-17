(impl-trait 'SPX9XMC02T56N9PRXV4AM9TS88MMQ6A1Z3375MHD.nft-trait.nft-trait)

;; non fungible token, using sip-009
(define-non-fungible-token CityCoins-Bulls uint)

;; errors
(define-constant err-no-more-nfts u300)
(define-constant err-sale-is-not-active u301)
(define-constant err-not-authorized u401)
(define-constant err-invalid-user u500)
(define-constant err-failed-to-transfer-ft u601)

;; constants
(define-constant contract-owner tx-sender)
(define-constant total-supply u100)
(define-constant artist-address 'SP34ZEET21QZMHC7HEKSCEP3B0S53S1GDGZT12M3A)
(define-constant stackerdao-treasury 'SP2BSV94A650WGZ2YZ5Y8HM93W01NGT4GY0W2BN3P.stackerdao-treasury)
(define-constant treasury .citybulls-treasury-v1)

;; variables
(define-data-var price uint u3000)
(define-data-var last-id uint u0)
(define-data-var sale-active bool false)
(define-data-var base-token-uri (string-ascii 210) "ipfs://")

;; utils
(define-constant FOLDS_TWO (list true true))
(define-constant NUM_TO_CHAR (list "0" "1" "2" "3" "4" "5" "6" "7" "8" "9"))

;; PUBLIC FUNCTIONS

(define-public (claim)
  (let
    (
      (next-id (+ u1 (var-get last-id)))
    )

    (asserts! (var-get sale-active) (err err-sale-is-not-active))
    (asserts! (< (var-get last-id) total-supply) (err err-no-more-nfts))
    
    (begin
      (unwrap! (contract-call? 'SP466FNC0P7JWTNM2R9T199QRZN1MYEDTAR0KP27.miamicoin-token transfer (/ (* (var-get price) u2) u100) tx-sender stackerdao-treasury (some 0x11)) (err err-failed-to-transfer-ft)) ;; 2% StackerDAOs commission fee
      (unwrap! (contract-call? 'SP466FNC0P7JWTNM2R9T199QRZN1MYEDTAR0KP27.miamicoin-token transfer (/ (* (var-get price) u30) u100) tx-sender treasury (some 0x11)) (err err-failed-to-transfer-ft)) ;; send 30% to DAO Treasury
      (if (not (is-eq tx-sender artist-address))
        (unwrap! (contract-call? 'SP466FNC0P7JWTNM2R9T199QRZN1MYEDTAR0KP27.miamicoin-token transfer (/ (* (var-get price) u68) u100) tx-sender artist-address (some 0x11)) (err err-failed-to-transfer-ft)) ;; send 68% to artist
        false
      )
      (try! (nft-mint? CityCoins-Bulls next-id tx-sender))
      (var-set last-id next-id)
      (ok next-id)
    )
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

(define-public (set-base-token-uri (new-base-token-uri (string-ascii 210)))
  (begin
    (asserts! (is-eq tx-sender contract-owner) (err err-not-authorized))
    (ok (var-set base-token-uri new-base-token-uri))
  )
)

(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (begin
    (if (and (is-eq tx-sender sender))
      (match (nft-transfer? CityCoins-Bulls token-id sender recipient)
        success (ok success)
        error (err error)
      )
      (err err-invalid-user)
    )
  )
)

;; set public sale flag
(define-public (flip-sale)
  (begin
    (asserts! (is-eq tx-sender contract-owner) (err err-not-authorized))
    (var-set sale-active (not (var-get sale-active)))
    (ok (var-get sale-active))
  )
)

;; start utils to convert uint to string
(define-private (concat-uint (ignore bool) (input { dec: uint, data: (string-ascii 3) }))
  (let 
    (
      (last-val (get dec input))
    )
    (if (is-eq last-val u0)
      {
          dec: last-val,
          data: (get data input)
      }
      (if (< last-val u10)
        {
            dec: u0,
            data: (concat-num-to-string last-val (get data input))
        }
        {
            dec: (/ last-val u10),
            data: (concat-num-to-string (mod last-val u10) (get data input))
        }
      )
    )
  )
)

(define-private (concat-num-to-string (num uint) (right (string-ascii 3)))
    (unwrap-panic (as-max-len? (concat (unwrap-panic (element-at NUM_TO_CHAR num)) right) u3))
)

(define-private (uint-to-string (num uint))
  (if (is-eq num u0)
    (unwrap-panic (as-max-len? "0" u3))
    (get data (fold concat-uint FOLDS_TWO { dec: num, data: ""}))
  )
)
;; end utils to convert uint to string

;; READ-ONLY FUNCTIONS

(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? CityCoins-Bulls token-id))
)

(define-read-only (get-last-token-id)
  (ok (var-get last-id))
)

(define-read-only (get-token-uri (token-id uint))
  (ok (as-max-len? (concat (concat (var-get base-token-uri) (uint-to-string token-id)) ".json") u256))
)