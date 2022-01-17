(impl-trait .trait-ownable.ownable-trait)
(impl-trait .trait-vault.vault-trait)
(use-trait ft-trait .trait-sip-010.sip-010-trait)
(use-trait sft-trait .trait-semi-fungible.semi-fungible-trait)
(use-trait flash-loan-user-trait .trait-flash-loan-user.flash-loan-user-trait)

(define-constant ONE_8 (pow u10 u8)) ;; 8 decimal places

(define-constant ERR-NOT-AUTHORIZED (err u1000))
(define-constant ERR-INVALID-BALANCE (err u1001))
(define-constant ERR-TRANSFER-FAILED (err u3000))
(define-constant ERR-INVALID-TOKEN (err u2026))

(define-data-var contract-owner principal tx-sender)

(define-map approved-contracts principal bool)
(define-map approved-tokens principal bool)
(define-map approved-flash-loan-users principal bool)

;; flash loan fee rate
(define-data-var flash-loan-fee-rate uint u0)

;; @desc get-contract-owner
;; @returns (response principal)
(define-read-only (get-contract-owner)
  (ok (var-get contract-owner))
)

;; @desc set-contract-owner
;; @restricted Contract-Owner
;; @returns (response boolean)
(define-public (set-contract-owner (owner principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED)
    (ok (var-set contract-owner owner))
  )
)

;; @desc get-flash-loan-free-rate
;; @returns (response boolean)
(define-read-only (get-flash-loan-fee-rate)
  (ok (var-get flash-loan-fee-rate))
)

;; @desc check-is-approved
;; @restricted Approved-Contracts
;; @params sender
;; @returns (response boolean)
(define-private (check-is-approved (sender principal))
  (ok (asserts! (or (default-to false (map-get? approved-contracts sender)) (is-eq sender (var-get contract-owner))) ERR-NOT-AUTHORIZED))
)

(define-private (check-is-approved-flash-loan-user (flash-loan-user principal))
  (ok (asserts! (default-to false (map-get? approved-flash-loan-users flash-loan-user)) ERR-NOT-AUTHORIZED))
)

(define-private (check-is-approved-token (flash-loan-token principal))
  (ok (asserts! (default-to false (map-get? approved-tokens flash-loan-token)) ERR-NOT-AUTHORIZED))
)

(define-public (add-approved-contract (new-approved-contract principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED)
    (map-set approved-contracts new-approved-contract true)
    (ok true)
  )
)

(define-public (add-approved-flash-loan-user (new-approved-flash-loan-user principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED)
    (map-set approved-flash-loan-users new-approved-flash-loan-user true)
    (ok true)
  )
)

(define-public (add-approved-token (new-approved-token principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED)
    (map-set approved-tokens new-approved-token true)
    (ok true)
  )
)

;; @desc set-flash-loan-fee-rate
;; @restricted Contract-Owner
;; @params fee
;; @returns (response boolean)
(define-public (set-flash-loan-fee-rate (fee uint))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED)
    (ok (var-set flash-loan-fee-rate fee))
  )
)

;; return token balance held by vault
;; @desc get-balance
;; @params token; ft-trait
;; @returns (response uint)
(define-public (get-balance (token <ft-trait>))
  (begin
    (try! (check-is-approved-token (contract-of token)))  
    (contract-call? token get-balance-fixed (as-contract tx-sender))
  )
)

;; if sender is an approved contract, then transfer requested amount :qfrom vault to recipient
;; @desc transfer-ft
;; @params token; ft-trait
;; @params amount
;; @params recipient
;; @restricted Contrac-Owner
;; @returns (response boolean)
(define-public (transfer-ft (token <ft-trait>) (amount uint) (recipient principal))
  (begin     
    (try! (check-is-approved tx-sender))
    (try! (check-is-approved-token (contract-of token)))
    (as-contract (unwrap! (contract-call? token transfer-fixed amount tx-sender recipient none) ERR-TRANSFER-FAILED))
    (ok true)
  )
)

;; @desc transfer-sft
;; @restricted Contract-Owner
;; @params token ; sft-trait
;; @params token-id
;; @params amount
;; @params recipient
;; @returns (response boolean)
(define-public (transfer-sft (token <sft-trait>) (token-id uint) (amount uint) (recipient principal))
  (begin     
    (try! (check-is-approved tx-sender))
    (try! (check-is-approved-token (contract-of token)))
    (as-contract (unwrap! (contract-call? token transfer-fixed token-id amount tx-sender recipient) ERR-TRANSFER-FAILED))
    (ok true)
  )
)

;; perform flash loan
;; @desc flash-loan
;; @params flash-loan-user; flash-loan-user-trait
;; @params token; ft-trait
;; @params amount
;; @params memo; expiry
;; @returns (response uint)
(define-public (flash-loan (flash-loan-user <flash-loan-user-trait>) (token <ft-trait>) (amount uint) (memo (optional (buff 16))))
  (begin
    (try! (check-is-approved-flash-loan-user (contract-of flash-loan-user)))
    (try! (check-is-approved-token (contract-of token)))
    (let 
      (
        (pre-bal (unwrap! (get-balance token) ERR-INVALID-BALANCE))
        (fee-with-principal (+ ONE_8 (var-get flash-loan-fee-rate)))
        (amount-with-fee (mul-up amount fee-with-principal))
        (recipient tx-sender)
      )
    
      ;; make sure current balance > loan amount
      (asserts! (> pre-bal amount) ERR-INVALID-BALANCE)

      ;; transfer loan to flash-loan-user
      (as-contract (unwrap! (contract-call? token transfer-fixed amount tx-sender recipient none) ERR-TRANSFER-FAILED))

      ;; flash-loan-user executes with loan received
      (try! (contract-call? flash-loan-user execute token amount memo))

      ;; return the loan + fee
      (unwrap! (contract-call? token transfer-fixed amount-with-fee tx-sender (as-contract tx-sender) none) ERR-TRANSFER-FAILED)
      (ok amount-with-fee)
    )
  )
)

;; @desc mul-down
;; @params a
;; @params b
;; @returns uint
(define-read-only (mul-down (a uint) (b uint))
    (/ (* a b) ONE_8)
)

;; @desc mul-up
;; @params a
;; @params b
;; @returns uint
(define-read-only (mul-up (a uint) (b uint))
    (let
        (
            (product (* a b))
       )
        (if (is-eq product u0)
            u0
            (+ u1 (/ (- product u1) ONE_8))
       )
   )
)

;; contract initialisation
(map-set approved-contracts .alex-reserve-pool true)
(map-set approved-contracts .collateral-rebalancing-pool true)  
(map-set approved-contracts .fixed-weight-pool true)  
(map-set approved-contracts .liquidity-bootstrapping-pool true)  
(map-set approved-contracts .yield-token-pool true)  
(map-set approved-contracts .yield-collateral-rebalancing-pool true)

(map-set approved-flash-loan-users .flash-loan-user-margin-usda-wbtc true)
(map-set approved-flash-loan-users .flash-loan-user-margin-wbtc-usda true)
(map-set approved-flash-loan-users .flash-loan-user-margin-wstx-usda true)

(map-set approved-tokens .age000-governance-token true)
