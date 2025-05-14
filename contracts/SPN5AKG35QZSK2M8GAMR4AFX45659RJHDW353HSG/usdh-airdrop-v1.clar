;; @contract USDh airdrop
;; @version 1

(use-trait sip-010-trait .sip-010-trait.sip-010-trait)

;;-------------------------------------
;; Constants
;;-------------------------------------

(define-constant ERR_NOT_WHITELISTED (err u8001))
(define-constant ERR_NOT_STANDARD_PRINCIPAL (err u8002))
(define-constant ERR_AMOUNT_BELOW_MIN (err u8003))
(define-constant ERR_TOTAL_AMOUNT_MISMATCH (err u8004))

(define-constant this-contract (as-contract tx-sender))

;;-------------------------------------
;; Variables
;;-------------------------------------

(define-data-var next-airdrop-id uint u0)

;;-------------------------------------
;; Maps
;;-------------------------------------

(define-map whitelist
  {
    address: principal
  }
  {
    active: bool
  }
)

;;-------------------------------------
;; Getters
;;-------------------------------------

(define-read-only (get-whitelist (address principal))
  (default-to
    { active: false }
    (map-get? whitelist { address: address })
  )
)

(define-read-only (get-next-airdrop-id)
  (var-get next-airdrop-id)
)

;;-------------------------------------
;; Helpers
;;-------------------------------------

(define-private (airdrop-processor (entry { recipient: principal, amount: uint, memo: (optional (buff 34)) }))
  (let (
    (recipient (get recipient entry))
    (amount (get amount entry)))

    (asserts! (> amount u0) ERR_AMOUNT_BELOW_MIN)
    (asserts! (is-standard recipient) ERR_NOT_STANDARD_PRINCIPAL)
    (try! (contract-call? .usdh-token-v1 transfer amount this-contract recipient (get memo entry)))
    (ok true)
  )
)

(define-private (check-err (result (response bool uint)) (prior (response bool uint)))
  (match prior ok-value
    result
    err-value (err err-value)
  )
)

(define-private (add-amounts (entry { recipient: principal, amount: uint, memo: (optional (buff 34)) }) (total uint) )
  (+ total (get amount entry))
)

;;-------------------------------------
;; Airdrop
;;-------------------------------------

(define-public (airdrop
  (entries (list 200 { recipient: principal, amount: uint, memo: (optional (buff 34)) }))
  (purpose (optional (string-ascii 40)))
  (total-amount uint))
  (let (
    (current-airdrop-id (var-get next-airdrop-id)))

    (asserts! (get active (get-whitelist contract-caller)) ERR_NOT_WHITELISTED)
    (asserts! (is-eq total-amount (fold add-amounts entries u0)) ERR_TOTAL_AMOUNT_MISMATCH)
    (var-set next-airdrop-id (+ current-airdrop-id u1))
    (print { airdrop-id: current-airdrop-id, purpose: purpose, total-amount: total-amount })
    (fold check-err (map airdrop-processor entries) (ok true))
  )
)

;;-------------------------------------
;; Admin
;;-------------------------------------

(define-public (set-whitelist (address principal) (active bool))
  (begin
    (try! (contract-call? .hq-v1 check-is-protocol contract-caller))
    (asserts! (is-standard address) ERR_NOT_STANDARD_PRINCIPAL)
    (print { address: address, old-value: (get active (get-whitelist address)),  new-value: active })
    (ok (map-set whitelist { address: address } { active: active }))
  )
)

(define-public (transfer (amount uint) (recipient principal) (asset <sip-010-trait>) (memo (optional (buff 34))))
  (begin 
    (try! (contract-call? .hq-v1 check-is-protocol contract-caller))
    (ok (try! (contract-call? asset transfer amount this-contract recipient memo)))
  )
)