;; title: stability-vpv-5

;; Stability Trait 
(impl-trait .stability-trait-vpv-5.stability-trait)

;; bsd protocol
(use-trait bsd-trait .bsd-trait-vpv-5.bsd-trait)

;; sip-010-trait
(use-trait sbtc-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

;; registry
(use-trait registry-trait .registry-trait-vpv-5.registry-trait)

;; sorted vaults
(use-trait sorted-vaults-trait .sorted-vaults-trait-vpv-5.sorted-vaults-trait)

(define-constant ERR_STABILITY_PROVIDER_NOT_FOUND (err u400))
(define-constant ERR_INSUFFICIENT_LIQUIDITY (err u401))
(define-constant ERR_INSUFFICIENT_REWARDS (err u402))
(define-constant ERR_PROTOCOL_STATE (err u403))
(define-constant ERR_NO_PROTOCOL_DATA (err u404))
(define-constant ERR_MIN_BALANCE (err u405))
(define-constant ERR_NOT_AUTH (err u406))
(define-constant ERR_NO_KEEPER (err u407))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; stability-trait BEGIN
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; add-liquidity
(define-public (add-liquidity-wrapper (amount uint) (bsd <bsd-trait>) (sbtc <sbtc-trait>) (registry <registry-trait>) (sorted-vaults <sorted-vaults-trait>))
    (let 
        (
            (valid-principal (try! (contract-call? .controller-vpv-5 verify-principal contract-caller)))
            (valid-registry (try! (contract-call? .controller-vpv-5 check-approved-contract "registry" (contract-of registry))))
            (valid-bsd (try! (contract-call? .controller-vpv-5 check-approved-contract "bsd" (contract-of bsd))))
            (valid-sorted-vaults (try! (contract-call? .controller-vpv-5 check-approved-contract "sorted-vaults" (contract-of sorted-vaults))))
            (current-provider (try! (contract-call? registry get-stability-pool-provider tx-sender)))
            (is-new-provider (is-eq current-provider none))
            (provider-balance (if is-new-provider u0 (unwrap! (get liquidity-staked current-provider) ERR_STABILITY_PROVIDER_NOT_FOUND)))
            (calculated-rewards (if is-new-provider u0 (try! (contract-call? registry calculate-provider-rewards tx-sender))))
            (protocol-attributes (unwrap-panic (contract-call? registry get-protocol-attributes sorted-vaults)))
            (min-stability-provider-balance (get min-stability-provider-balance protocol-attributes))
            (is-paused (unwrap-panic (contract-call? registry get-is-paused)))        
            (is-maintenance (unwrap-panic (contract-call? registry get-is-maintenance)))        
        )

        ;; check paused
        (asserts! (not is-paused) ERR_PROTOCOL_STATE)

        ;; check maintenance
        (asserts! (not is-maintenance) ERR_PROTOCOL_STATE)

        ;; assert deposit amount is greater than zero
        (asserts! (> amount u0) ERR_MIN_BALANCE)

        (asserts! (>= (+ provider-balance amount) min-stability-provider-balance) ERR_MIN_BALANCE)

        ;; transfer bsd to the stability pool
        (try! (contract-call? bsd protocol-transfer amount tx-sender (as-contract tx-sender)))

        (if (> calculated-rewards u0)
            ;; transfer rewards to the user
            (try! (contract-call? sbtc transfer calculated-rewards  (as-contract tx-sender) tx-sender none))
            true
        )

        ;; call registry to complete
        (try! (contract-call? registry add-liquidity amount tx-sender))
        
        (ok 
            (unwrap-panic (contract-call? registry get-stability-pool-provider tx-sender))
        )
    )
)

;; remove-liquidity
(define-public (remove-liquidity-wrapper (amount uint) (bsd <bsd-trait>) (sbtc <sbtc-trait>) (registry <registry-trait>) (sorted-vaults <sorted-vaults-trait>))
    (let
        (
            (valid-principal (try! (contract-call? .controller-vpv-5 verify-principal contract-caller)))
            (valid-registry (try! (contract-call? .controller-vpv-5 check-approved-contract "registry" (contract-of registry))))
            (valid-bsd (try! (contract-call? .controller-vpv-5 check-approved-contract "bsd" (contract-of bsd))))
            (valid-sbtc (try! (contract-call? .controller-vpv-5 check-approved-contract "sbtc" (contract-of sbtc))))
            (valid-sorted-vaults (try! (contract-call? .controller-vpv-5 check-approved-contract "sorted-vaults" (contract-of sorted-vaults))))
            (stability-pool (try! (contract-call? registry get-stability-pool-data)))
            (stability-pool-aggregate-balance (get aggregate-bsd stability-pool))
            (current-provider tx-sender)
            (current-entry (unwrap! (contract-call? registry get-stability-pool-provider tx-sender) ERR_STABILITY_PROVIDER_NOT_FOUND))
            (protocol-attributes (unwrap-panic (contract-call? registry get-protocol-attributes sorted-vaults)))
            (min-stability-provider-balance (get min-stability-provider-balance protocol-attributes))
            (current-liquidity-staked (unwrap! (get liquidity-staked current-entry) ERR_STABILITY_PROVIDER_NOT_FOUND))
            (calculated-rewards (try! (contract-call? registry calculate-provider-rewards tx-sender)))
            (is-paused (get is-paused protocol-attributes))
    )

        ;; check paused
        (asserts! (not is-paused) ERR_PROTOCOL_STATE)

        ;; assert deposit amount is greater than zero
        (asserts! (> amount u0) ERR_MIN_BALANCE)

        ;; check that amount being withdrawn is not greater than the aggregate staked
        (asserts! (<= amount stability-pool-aggregate-balance) ERR_INSUFFICIENT_LIQUIDITY)

        ;; check that amount to remove is less than or equal to the amount of liquidity the user has
        (asserts! (<= amount current-liquidity-staked) ERR_INSUFFICIENT_LIQUIDITY)

        (if (or (is-eq amount current-liquidity-staked) (>= (- current-liquidity-staked amount) min-stability-provider-balance))

            (begin
                ;; withdraw liquidity from the stability pool
                (try! (as-contract (contract-call? bsd protocol-transfer amount tx-sender current-provider)))

                (if (> calculated-rewards u0)
                    ;; transfer rewards to the user
                    (try! (contract-call? sbtc transfer calculated-rewards  (as-contract tx-sender) tx-sender none))
                    true
                )
                
                (try! (contract-call? registry remove-liquidity amount tx-sender))
                (ok 
                    (unwrap-panic (contract-call? registry get-stability-pool-provider tx-sender))
                )
            )

            ERR_MIN_BALANCE
        )
    )
)

;; claim-rewards
(define-public (claim-rewards (sbtc <sbtc-trait>) (registry <registry-trait>)) 
(let
        (
            (valid-principal (try! (contract-call? .controller-vpv-5 verify-principal contract-caller)))
            (valid-registry (try! (contract-call? .controller-vpv-5 check-approved-contract "registry" (contract-of registry))))
            (valid-sbtc (try! (contract-call? .controller-vpv-5 check-approved-contract "sbtc" (contract-of sbtc))))
            (current-provider tx-sender)
            (current-entry (try! (contract-call? registry get-stability-pool-provider tx-sender)))
            (provider-balance-bsd (unwrap-panic (get liquidity-staked current-entry)))
            (is-paused (unwrap-panic (contract-call? registry get-is-paused)))
            (calculated-rewards (try! (contract-call? registry calculate-provider-rewards tx-sender)))
    )

        ;; check paused
        (asserts! (not is-paused) ERR_PROTOCOL_STATE)

        ;; check that user has rewards to claim
        (asserts! (> calculated-rewards u0) ERR_INSUFFICIENT_REWARDS)

        (print {
            claim-rewards-event: {
                claim-amount: calculated-rewards,
            }
        })

        ;; transfer rewards to the user
        (try! (contract-call? sbtc transfer calculated-rewards  (as-contract tx-sender) tx-sender none))

        (ok (try! (contract-call? registry claim-rewards tx-sender)))
    )
)

(define-public (unwind-provider (provider principal) (sbtc <sbtc-trait>) (registry <registry-trait>))
    (let
        (
            (valid-registry (try! (contract-call? .controller-vpv-5 check-approved-contract "registry" (contract-of registry))))
            (valid-sbtc (try! (contract-call? .controller-vpv-5 check-approved-contract "sbtc" (contract-of sbtc))))
            (is-keeper (unwrap! (contract-call? .controller-vpv-5 is-keeper tx-sender) ERR_NO_KEEPER))            
            (balance (try! (contract-call? registry get-provider-calculated-balance provider)))
            (rewards (try! (contract-call? registry calculate-provider-rewards provider)))
        )

        ;; check that caller is the keeper
        (asserts! (is-eq true is-keeper) ERR_NOT_AUTH)

        ;; check that vault has no debt
        (asserts! (is-eq balance u0) ERR_MIN_BALANCE)

        ;; send rewards to borrower
        (try! (contract-call? sbtc transfer rewards (as-contract tx-sender) provider none))

        (ok (try! (contract-call? registry unwind-provider provider)))
    )

)

;; vault-manager-burn
(define-public (vault-manager-burn (amount uint) (bsd <bsd-trait>) (registry <registry-trait>))
    (let 
        (
            (valid-registry (try! (contract-call? .controller-vpv-5 check-approved-contract "registry" (contract-of registry))))
            (valid-bsd (try! (contract-call? .controller-vpv-5 check-approved-contract "bsd" (contract-of bsd))))
            (is-paused (unwrap-panic (contract-call? registry get-is-paused)))
        )

        ;; check paused
        (asserts! (not is-paused) ERR_PROTOCOL_STATE)

        ;; check that caller is protocol-caller
        (try! (contract-call? .controller-vpv-5 is-protocol-caller contract-caller))
        
        ;; burn liquidity
        (ok (try! (contract-call? bsd protocol-burn (as-contract tx-sender) amount)))
    )
)

;; protocol-transfer
(define-public (protocol-transfer (to principal) (amount uint) (bsd <bsd-trait>) (registry <registry-trait>))
     (let 
        (
            (valid-registry (try! (contract-call? .controller-vpv-5 check-approved-contract "registry" (contract-of registry))))
            (valid-bsd (try! (contract-call? .controller-vpv-5 check-approved-contract "bsd" (contract-of bsd))))
            (is-paused (unwrap-panic (contract-call? registry get-is-paused)))
        )

        ;; check paused
        (asserts! (not is-paused) ERR_PROTOCOL_STATE)

        ;; check that caller is a protocol contract
        (try! (contract-call? .controller-vpv-5 is-protocol-caller contract-caller))

        ;; finalize transfer of sbtc
        (as-contract (contract-call? bsd protocol-transfer amount tx-sender to))
    )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; stability-trait END
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

