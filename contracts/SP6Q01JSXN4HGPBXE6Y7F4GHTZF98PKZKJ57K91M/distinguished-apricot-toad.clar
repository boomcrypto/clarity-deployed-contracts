

;; define errors
(define-constant err-owner-only (err u100))
(define-constant err-no-rights (err u101))

(define-constant err-bns-convert (err u200))
(define-constant err-bnsx-convert (err u201))
(define-constant err-bns-size (err u202))

(define-constant err-mint-disabled (err u300))
(define-constant err-whitelist-only (err u301))
(define-constant err-full-mint-reached (err u302))


;; define variables
;; Store the last issues token ID
(define-data-var last-id uint u0)
(define-data-var contract-owner principal tx-sender)
(define-data-var mint-enabled bool true)
(define-data-var only-whitelisted bool false)
(define-data-var uri-root (string-ascii 80) "https://asd/")


;; whitelist system
;; every address has a number of whitelist spots
(define-map whitelist-spots principal uint)

;; whitelist functions
;; set the whitelist addresses and number of whitelists directly in the smart contract

(define-read-only (is-mint-enabled) 
  (var-get mint-enabled))

(define-read-only (is-whitelist-enabled) 
  (var-get only-whitelisted))

(define-public (set-mint-enabler (bool-value bool))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) err-owner-only)
    (ok (var-set mint-enabled bool-value))))

(define-read-only (is-whitelisted (address principal)) 
  (let ((spots (map-get? whitelist-spots address))) 
    (if (and (is-some spots) (> (unwrap-panic spots) u0))  true false )))

(define-private (can-mint-and-update-spots (address principal)) 
  (if (is-eq false (var-get only-whitelisted)) 
    (ok true)
    (if (is-eq true (is-whitelisted address)) 
      (begin
        (map-set whitelist-spots address (- (unwrap-panic (map-get? whitelist-spots address)) u1))
        (ok true))
      (ok false))))

;; if address does not have map-get or is 0 => no whitelist spot allocated
(define-read-only (get-whitelist-spots (address principal)) 
  (map-get? whitelist-spots address))

;; only contract owner can set whitelist
(define-public (set-whitelist-spots (address principal) (spots uint))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) err-owner-only)
    (ok (map-set whitelist-spots address spots))))

(define-read-only (get-contract-owner) 
  (var-get contract-owner))

(define-public (set-contract-owner (new-contract-owner principal)) 
  (begin 
    (asserts! (is-eq tx-sender (var-get contract-owner)) err-owner-only)
    (ok (var-set contract-owner new-contract-owner))))

(define-public (set-only-whitelisted (value bool)) 
  (begin 
    (asserts! (is-eq tx-sender (var-get contract-owner))  err-owner-only)
    (var-set only-whitelisted value)
    (ok value)))
