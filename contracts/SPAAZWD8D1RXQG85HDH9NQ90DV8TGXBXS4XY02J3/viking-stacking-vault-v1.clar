(use-trait ft-trait 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.trait-sip-010.sip-010-trait)

(use-trait sft-trait 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.trait-semi-fungible.semi-fungible-trait)

(define-constant ONE_6 u100000000) ;; 6 decimal places

(define-constant ERR-NOT-AUTHORIZED (err u1000))
(define-constant ERR-PAUSED (err u1001))
(define-constant ERR-INVALID-BALANCE (err u1002))
(define-constant ERR-INVALID-TOKEN (err u2026))

(define-data-var contract-owner principal tx-sender)

(define-map approved-contracts principal bool)
(define-map approved-tokens principal bool)

(define-data-var paused bool false)

;; read-only calls

(define-read-only (is-paused)
  (var-get paused)
)

(define-read-only (get-contract-owner)
  (ok (var-get contract-owner))
)

(define-public (get-balance (the-token <ft-trait>))
  (begin 
    (try! (check-is-approved-token (contract-of the-token))) 
    (contract-call? the-token get-balance (as-contract tx-sender))
  )
)

(define-public (stx-balance)
  (begin 
    (ok (stx-get-balance (as-contract tx-sender)))
  )
)

;; governance calls

(define-public (set-contract-owner (owner principal))
  (begin
    (try! (check-is-owner)) 
    (ok (var-set contract-owner owner))
  )
)

(define-public (set-approved-contract (the-contract principal) (approved bool))
  (begin 
    (try! (check-is-owner)) 
    (ok (map-set approved-contracts the-contract approved))
  )
)

(define-public (set-approved-token (the-token principal) (approved bool))
  (begin 
    (try! (check-is-owner)) 
    (ok (map-set approved-tokens the-token approved))
  )
)

(define-public (pause (new-paused bool))
    (begin 
        (try! (check-is-owner))
        (ok (var-set paused new-paused))
    )
)


(define-public (transfer-ft (the-token <ft-trait>) (amount uint) (recipient principal))
  (begin     
    (asserts! (not (is-paused)) ERR-PAUSED)
    (asserts! (and (or (is-ok (check-is-approved)) (is-ok (check-is-owner))) (is-ok (check-is-approved-token (contract-of the-token)))) ERR-NOT-AUTHORIZED)
    (as-contract (contract-call? the-token transfer amount tx-sender recipient none))
  )
)

(define-public (transfer-sft (the-token <sft-trait>) (token-id uint) (amount uint) (recipient principal))
  (begin     
    (asserts! (not (is-paused)) ERR-PAUSED)
    (asserts! (and (or (is-ok (check-is-approved)) (is-ok (check-is-owner))) (is-ok (check-is-approved-token (contract-of the-token)))) ERR-NOT-AUTHORIZED) 
    (as-contract (contract-call? the-token transfer token-id amount tx-sender recipient))
  )
)

(define-public (transfer-stx (amount uint) (recipient principal))
  (begin     
    (asserts! (not (is-paused)) ERR-PAUSED)
    (asserts! (or (is-ok (check-is-approved)) (is-ok (check-is-owner))) ERR-NOT-AUTHORIZED)
    (as-contract (stx-transfer? amount tx-sender recipient))
  )
)

;; private calls

(define-private (check-is-approved)
  (ok (asserts! (default-to false (map-get? approved-contracts tx-sender)) ERR-NOT-AUTHORIZED))
)

(define-private (check-is-owner)
  (ok (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED))
)

(define-private (check-is-approved-token (flash-loan-token principal))
  (ok (asserts! (default-to false (map-get? approved-tokens flash-loan-token)) ERR-NOT-AUTHORIZED))
)