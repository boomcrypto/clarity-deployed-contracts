;; scarcity-token
;; Mints NFT by burning specified number of fungible tokens

;;traits
(use-trait citycoin-token 'SPSCWDV3RKV5ZRN1FQD84YE1NQFEDJ9R1F4DYQ11.citycoin-token-v2-trait.citycoin-token-v2)

;; errors
(define-constant err-unauthorized (err u1000))
(define-constant err-not-enough-burn-tokens (err u1001))
(define-constant err-not-token-owner (err u1002))
(define-constant err-token-not-found (err u1003))
(define-constant err-asset-not-whitelisted (err u1004))
(define-constant err-whitelist-list-full (err u1005))

;; constants
(define-constant contract-owner tx-sender)

;; tokens
(define-non-fungible-token scarcity-token uint)

;; maps
(define-map whitelisted-assets principal bool)

;; data maps and vars
(define-data-var min-burn-amount uint u1)
(define-data-var last-token-id uint u0)
(define-data-var whitelist (list 10 principal) (list))
(define-data-var tokenUri (optional (string-utf8 256)) (some u""))


;; read-only functions
(define-read-only (is-whitelisted (asset-contract principal))
  (default-to false (map-get? whitelisted-assets asset-contract)) 
)
 
(define-read-only (get-whitelist)
  (ok (var-get whitelist))
)

(define-read-only (get-token-uri)
  (ok (var-get tokenUri))
)

(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? scarcity-token token-id))
)

(define-read-only (get-last-token-id)
  (ok (var-get last-token-id))
)

;; public functions
;; set token URI to new value, only accessible by Auth
(define-public (set-token-uri (newUri (optional (string-utf8 256))))
  (begin
    (asserts! (is-eq contract-caller contract-owner) err-unauthorized)
    (ok (var-set tokenUri newUri))
  )
)
(define-public (set-whitelisted (asset-contract principal) (whitelisted bool))
  (begin
    (asserts! (is-eq contract-caller contract-owner) err-unauthorized)
    (map-set whitelisted-assets asset-contract whitelisted)
    (ok 
      (var-set whitelist 
        (unwrap! 
          (as-max-len? (append (var-get whitelist) asset-contract) u10) 
        err-whitelist-list-full)
      )
    )
  )
)

;; no min amount currently set
(define-public (set-burn-amount (amount uint))
  (begin
    (asserts! (is-eq contract-caller contract-owner) err-unauthorized)
    (ok (var-set min-burn-amount amount))
  )
)

(define-public (mint (burn-amount uint) (recipient principal) (citycoin-contract <citycoin-token>))
  (let
    (
      (token-id (+ (var-get last-token-id) u1))
    )
    (asserts! (is-whitelisted (contract-of citycoin-contract)) err-asset-not-whitelisted)  
    (asserts! (>= burn-amount (var-get min-burn-amount)) err-not-enough-burn-tokens)
    (var-set last-token-id token-id)
    (try! (nft-mint? scarcity-token token-id tx-sender))
    (contract-call? citycoin-contract burn burn-amount tx-sender)
  )  
)

(define-public (burn (id uint) (owner principal))
  (begin
    (asserts! (is-eq owner (unwrap! (nft-get-owner? scarcity-token id) err-token-not-found)) err-not-token-owner)
    (nft-burn? scarcity-token id owner)
  )
)