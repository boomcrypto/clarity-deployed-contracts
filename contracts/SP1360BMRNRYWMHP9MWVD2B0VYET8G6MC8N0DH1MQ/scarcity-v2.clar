;; Scarcity Token V2 Contract
;; Mints NFT by burning specified number of fungible tokens

;;traits
(use-trait citycoin-token 'SPSCWDV3RKV5ZRN1FQD84YE1NQFEDJ9R1F4DYQ11.citycoin-token-v2-trait.citycoin-token-v2)

;; errors
(define-constant err-unauthorized (err u1000))
(define-constant err-not-enough-burn-tokens (err u1001))
(define-constant err-not-token-owner (err u1002))
(define-constant err-token-not-found (err u1003))
(define-constant err-asset-not-whitelisted (err u1004))
(define-constant err-whitelist-limit-reached (err u1005))
(define-constant err-not-map-user (err u1006))
(define-constant err-no-mapping-exists (err u1007))
(define-constant err-not-scarcity-user (err u1008))
(define-constant err-asset-already-whitelisted (err u1009))
(define-constant err-user-map-already-exists (err u1010))
(define-constant err-no-user-map (err u1011))
(define-constant err-map-not-created (err u1012))


;; constants
(define-constant contract-owner tx-sender)

;; tokens
(define-non-fungible-token scarcity-token uint)

;; data maps and vars
(define-data-var min-burn-amount uint u1)
(define-data-var last-token-id uint u0)
(define-data-var whitelist (list 50 principal) (list))
(define-data-var lastRemovedWhitelistedAsset (optional principal) none)

;; maps
(define-map Whitelisted-assets principal bool)
(define-map User-info principal {burnt-amount: uint, nft-id: uint})

;; read-only functions
(define-read-only (is-whitelisted (asset-contract principal))
  (default-to false (map-get? Whitelisted-assets asset-contract)) 
)
 
(define-read-only (get-whitelist)
  (ok (var-get whitelist))
)

(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? scarcity-token token-id))
)

(define-read-only (get-last-token-id)
  (ok (var-get last-token-id))
)

(define-read-only (get-user-info (user principal))
  (ok (map-get? User-info user))
)

(define-read-only (get-min-burn-amount)
  (ok (var-get min-burn-amount))
)

;; public functions
(define-public (set-whitelisted (asset-contract principal) (whitelisted bool))
  (begin
    (asserts! (is-eq contract-caller contract-owner) err-unauthorized)
    (asserts! (is-none (map-get? Whitelisted-assets asset-contract)) err-asset-already-whitelisted)
    (map-set Whitelisted-assets asset-contract whitelisted)
    (ok 
      (var-set whitelist 
        (unwrap! 
          (as-max-len? (append (var-get whitelist) asset-contract) u50) 
        err-whitelist-limit-reached)
      )
    )
  )
)

(define-public (remove-whitelisted (asset-contract principal))
  (begin
    (asserts! (is-eq contract-caller contract-owner) err-unauthorized)
    (asserts! (map-delete Whitelisted-assets asset-contract) err-asset-not-whitelisted)
    (var-set lastRemovedWhitelistedAsset (some asset-contract))
    (var-set whitelist (unwrap-panic (as-max-len? (filter remove-whitelisted-asset-filter (var-get whitelist)) u10)))
    (ok (print (var-get whitelist)))
  )
)

(define-public (set-burn-amount (amount uint))
  (begin
    (asserts! (is-eq contract-caller contract-owner) err-unauthorized)
    (ok (var-set min-burn-amount amount))
  )
)

(define-public (initial-mint-scarcity (burn-amount uint) (user principal) (citycoin-contract <citycoin-token>))
  (let
    (
      (token-id (+ (var-get last-token-id) u1))
      (user-info (map-get? User-info user))
    )
    (asserts! (is-eq tx-sender user) err-unauthorized)
    (asserts! (is-whitelisted (contract-of citycoin-contract)) err-asset-not-whitelisted) 
    (asserts! (>= burn-amount (var-get min-burn-amount)) err-not-enough-burn-tokens)
    (asserts! (is-none user-info) err-user-map-already-exists)
    (try! (nft-mint? scarcity-token token-id user))
    (asserts! (map-insert User-info user {burnt-amount: burn-amount, nft-id: token-id}) err-map-not-created)
    (try! (contract-call? citycoin-contract burn burn-amount user))
    (var-set last-token-id token-id)
    (ok "new scarcity minted")
  )
)

(define-public (mint-burn-scarcity (burn-amount uint) (nft-id uint) (user principal) (citycoin-contract <citycoin-token>))
  (let
    (
      (token-id (+ (var-get last-token-id) u1))
      (user-info (unwrap! (map-get? User-info user) err-no-user-map))
    )
    (asserts! (is-eq tx-sender user) err-unauthorized)
    (asserts! (is-whitelisted (contract-of citycoin-contract)) err-asset-not-whitelisted) 
    (asserts! (>= burn-amount (var-get min-burn-amount)) err-not-enough-burn-tokens)
    (asserts! (is-eq nft-id (get nft-id user-info)) err-not-token-owner)
    (try! (burn-on-mint (get nft-id user-info) user))
    (try! (nft-mint? scarcity-token token-id user))
    (try! (contract-call? citycoin-contract burn burn-amount user))
    (asserts! (map-set User-info user {burnt-amount: (+ burn-amount (get burnt-amount user-info)), nft-id: token-id}) err-map-not-created)
    (var-set last-token-id token-id)
    (ok "keepin' things scarce")
  )
)

;; Burns NFT and map
(define-public (burn-scarcity-nft (id uint))
  (begin
    (asserts! (is-eq tx-sender (unwrap! (nft-get-owner? scarcity-token id) err-token-not-found)) err-not-token-owner)
    (asserts! (is-some (map-get? User-info tx-sender)) err-no-mapping-exists)
    (try! (nft-burn? scarcity-token id tx-sender))
    (ok (map-delete User-info tx-sender))
  )
)

;;private functions
(define-private (burn-on-mint (id uint) (owner principal)) 
  (begin 
    (asserts! (is-eq owner (unwrap! (nft-get-owner? scarcity-token id) err-token-not-found)) err-not-token-owner)
    (nft-burn? scarcity-token id owner)
  )
)

(define-private (remove-whitelisted-asset-filter (asset principal))
  (not (is-eq asset (unwrap-panic (var-get lastRemovedWhitelistedAsset))))
)