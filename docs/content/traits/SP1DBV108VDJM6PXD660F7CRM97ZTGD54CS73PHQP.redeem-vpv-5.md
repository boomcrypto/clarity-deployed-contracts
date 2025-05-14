---
title: "Trait redeem-vpv-5"
draft: true
---
```
;; title: redeem-vpv-5

;; Redeem Trait 
(impl-trait .redeem-trait-vpv-5.redeem-trait)

;; bsd protocol
(use-trait bsd-trait .bsd-trait-vpv-5.bsd-trait)

;; sip-010-trait
(use-trait sbtc-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

;; oracle
(use-trait oracle-trait .oracle-trait-vpv-5.oracle-trait)

;; registry
(use-trait registry-trait .registry-trait-vpv-5.registry-trait)

;; vault
(use-trait vault-trait .vault-trait-vpv-5.vault-trait)

;; sorted vaults
(use-trait sorted-vaults-trait .sorted-vaults-trait-vpv-5.sorted-vaults-trait)

(define-constant ERR_REDEEM_TOO_HIGH (err u500))
(define-constant ERR_NO_ORACLE_PRICE (err u501))
(define-constant ERR_NO_PROTOCOL_DATA (err u502))
(define-constant ERR_PROTOCOL_RECOVERY_MODE (err u503))
(define-constant ERR_PROTOCOL_STATE (err u504))
(define-constant ERR_REDEEM_TOO_SMALL (err u505))
(define-constant ERR_NOT_AUTH (err u506))
(define-constant ERR_NO_VAULT_DEBT (err u507))
(define-constant ERR_INVALID_INPUT (err u508))

(define-constant PRECISION u8)

;; one full unit of precision u8 - ie. 100%, one bsd, one sbtc
(define-constant ONE_FULL_UNIT u100000000)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; redeem-trait BEGIN
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; redeem bsd
(define-public (redeem-wrapper (bsd-amount uint) (bsd <bsd-trait>) (sbtc <sbtc-trait>) (oracle <oracle-trait>) (registry <registry-trait>) (vault <vault-trait>) (sorted-vaults <sorted-vaults-trait>))
    (let 
        (
            ;; checks
            (valid-principal (try! (contract-call? .controller-vpv-5 verify-principal contract-caller)))
            (valid-vault (try! (contract-call? .controller-vpv-5 check-approved-contract "vault" (contract-of vault))))
            (valid-registry (try! (contract-call? .controller-vpv-5 check-approved-contract "registry" (contract-of registry))))
            (valid-oracle (try! (contract-call? .controller-vpv-5 check-approved-contract "oracle" (contract-of oracle))))
            (valid-bsd (try! (contract-call? .controller-vpv-5 check-approved-contract "bsd" (contract-of bsd))))
            (valid-sbtc (try! (contract-call? .controller-vpv-5 check-approved-contract "sbtc" (contract-of sbtc))))
            (valid-sorted-vaults (try! (contract-call? .controller-vpv-5 check-approved-contract "sorted-vaults" (contract-of sorted-vaults))))
            (sbtc-price (try! (contract-call? oracle get-price registry)))
            
            ;; protocol variables
            (protocol-data (unwrap! (contract-call? registry get-protocol-data sbtc-price sorted-vaults) ERR_NO_PROTOCOL_DATA))
            (is-paused (get is-paused protocol-data))
            (protocol-fee-destination (get protocol-fee-destination protocol-data))
            (min-redeem-amount (get min-redeem-amount protocol-data))
            (current-aggregate-bsd-debt (get total-bsd-loans protocol-data))

            ;; redeem info
            (redeem-info (unwrap! (calculate-redeem-info bsd-amount sbtc-price registry) ERR_INVALID_INPUT))
            (redeem-fee (get redeem-fee redeem-info))
            (redeem-to-user (get redeem-to-user redeem-info))
            (new-base-rate (get base-rate redeem-info))

            ;; redeem batch info
            (redemption-batch-info (try! (contract-call? registry get-redemption-batch-info sbtc-price sorted-vaults)))
            (vaults-sorted-by-interest (get vaults redemption-batch-info))
            (max-redeem-bsd (get total-redeem-value redemption-batch-info))
            (vaults-to-redeem-calc (try! (fold vaults-to-redeem vaults-sorted-by-interest (ok {index: u0, price: sbtc-price, target-loan: bsd-amount, redeemed-loan: u0, partial-redemption: u0, registry: registry}))))
        )   

        ;; Check that the protocol is not paused
        (asserts! (not is-paused) ERR_PROTOCOL_STATE)

        ;; Check that the redeem to user amount is greater than 0
        (asserts! (> redeem-to-user u0) ERR_REDEEM_TOO_SMALL)
        
        ;; Check that redeem amount is greater than the min redeem amount
        (asserts! (> bsd-amount min-redeem-amount) ERR_REDEEM_TOO_SMALL)

        ;; Check that redeem amount is less than the aggregate bsd balance
        (asserts! (<= bsd-amount max-redeem-bsd) ERR_REDEEM_TOO_HIGH)

        (print 
            {
                redeem-event: {
                    redeem-info: redeem-info, 
                    vaults: vaults-sorted-by-interest, 
                    vaults-to-redeem-calc: vaults-to-redeem-calc, 
                    current-aggregate-bsd-debt: current-aggregate-bsd-debt, 
                    bsd-amount: bsd-amount, 
                    redeem-fee: redeem-fee, 
                    redeem-to-user: redeem-to-user, 
                    new-base-rate: new-base-rate,
                    sbtc-price: sbtc-price
                }
            }
        )

        ;; Call 'protocol-burn-bsd' from the token contract to burn the bsd
        (try! (contract-call? bsd protocol-burn tx-sender bsd-amount))

        ;; Transfer the sbtc to the user
        (try! (contract-call? vault protocol-transfer tx-sender redeem-to-user sbtc registry))

        ;; the registry contract is called to update the fully redeemed & one partially redeemed vaults
        (ok (try! (contract-call? registry update-redemptions
            (if (< (get index vaults-to-redeem-calc) u1)
                (list (unwrap-panic (element-at? vaults-sorted-by-interest u0)))
                (unwrap-panic (slice? vaults-sorted-by-interest u0 (+ (get index vaults-to-redeem-calc) u1)))
            ) 
            bsd-amount
            redeem-to-user
            (get partial-redemption vaults-to-redeem-calc)
            new-base-rate
            redeem-fee
            sbtc-price
        )))
    )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; redeem-trait END
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; vaults-to-redeem
(define-private (vaults-to-redeem (vault-id uint) (helper-tuple (response { index: uint, price: uint, target-loan: uint, redeemed-loan:uint, partial-redemption: uint, registry: <registry-trait> } uint)))
    (match  helper-tuple
        ok-tuple
        (let
            (
                ;; The error message below is meant to clarify exactly which vault is out of order
                ;; If an error is thrown, the error message will include the vault-id of the vault that is out of order
                (registry (get registry ok-tuple))
                (current-vault (unwrap-panic (contract-call? registry get-vault vault-id)))
                (current-vault-info (unwrap-panic (contract-call? .registry-vpv-5 get-vault-compounded-info vault-id (get price ok-tuple))))
                (current-vault-loan-bsd (get vault-total-debt current-vault-info))
                (current-index (get index ok-tuple))
                (increased-index (+ current-index u1))
                (current-redeemed-loan (get redeemed-loan ok-tuple))
                (increased-redeemed-loan (+ current-redeemed-loan current-vault-loan-bsd))
                (target-loan (get target-loan ok-tuple))
                (current-price (get price ok-tuple))
            )
            
            ;; Assert that redeemed loan is less than the target loan, which means we still have more to redeem
            (asserts! (< (+ current-redeemed-loan (get partial-redemption ok-tuple)) target-loan) (ok ok-tuple))

            ;; Check if increasing redeemed-loan by current-vault-loan-bsd is greater than target-loan
            (if (> (get target-loan ok-tuple) increased-redeemed-loan)
                ;; Will not reach target-loan, vault is fully redeemable, need to update index & redeemed-loan
                (ok {index: increased-index, price: current-price, target-loan: target-loan, redeemed-loan: increased-redeemed-loan, partial-redemption: u0, registry: registry})
                ;; Vault is partially redeemable, capture how much is partially redeemed (current vault loan - (target loan - redeemed loan))
                (ok {index: current-index, price: current-price, target-loan: target-loan, redeemed-loan: current-redeemed-loan, partial-redemption: (- target-loan current-redeemed-loan), registry: registry})
            )
        )
        err-resp
            (err err-resp)
    )
)

;; calculate-redeem-info
(define-private (calculate-redeem-info (redeem-bsd uint) (sbtc-price-in-bsd uint) (registry <registry-trait>))
    (let (
            (valid-registry (try! (contract-call? .controller-vpv-5 check-approved-contract "registry" (contract-of registry))))
            (elapsed-blocks (contract-call? registry get-height-since-last-redeem))
            (calc-base-rate (try! (contract-call? registry calculate-redeem-fee-rate redeem-bsd)))
            (sbtc-collateral-pre-fee (div-to-fixed-precision redeem-bsd PRECISION sbtc-price-in-bsd))
            (redeem-fee (mul-perc calc-base-rate u8 sbtc-collateral-pre-fee))
            (redeem-to-user (- sbtc-collateral-pre-fee redeem-fee))
        )
        (ok { 
                redeem-fee: redeem-fee,
                redeem-to-user: redeem-to-user,
                base-rate: calc-base-rate
            })
    )
)

;; math functions
(define-read-only (div (x uint) (y uint))
  (/ (+ (* x ONE_FULL_UNIT) (/ y u2)) y))

(define-read-only (div-round-down (x uint) (y uint))
  (- (/ (+ (* x ONE_FULL_UNIT) (/ y u2)) y) u1)  
)

(define-read-only (div-to-fixed-precision (a uint) (decimals-a uint) (b-fixed uint))
  (if (> decimals-a PRECISION)
    (div (/ a (pow u10 (- decimals-a PRECISION))) b-fixed)
    (div (* a (pow u10 (- PRECISION decimals-a))) b-fixed)
  )
)

(define-read-only (mul (x uint) (y uint))
  (/ (+ (* x y) (/ ONE_FULL_UNIT u2)) ONE_FULL_UNIT))

(define-read-only (mul-to-fixed-precision (a uint) (decimals-a uint) (b-fixed uint))
  (if (> decimals-a PRECISION)
    (mul (/ a (pow u10 (- decimals-a PRECISION))) b-fixed)
    (mul (* a (pow u10 (- PRECISION decimals-a))) b-fixed)
  )
)

;; multiply a number of arbitrary precision with a 8-decimals fixed number
;; convert back to unit of arbitrary precision
(define-read-only (mul-perc (a uint) (decimals-a uint) (b-fixed uint))
  (if (> decimals-a PRECISION)
    (begin
      (*
        (mul (/ a (pow u10 (- decimals-a PRECISION))) b-fixed)
        (pow u10 (- decimals-a PRECISION))
      )
    )
    (begin
      (/
        (mul (* a (pow u10 (- PRECISION decimals-a))) b-fixed)
        (pow u10 (- PRECISION decimals-a))
      )
    )
  )
)
    
```
