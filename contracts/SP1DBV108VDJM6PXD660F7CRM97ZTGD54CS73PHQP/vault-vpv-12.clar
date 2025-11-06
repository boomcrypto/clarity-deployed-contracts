;; title: vault-vpv-12

;; Vault Trait 
(impl-trait .vault-trait-vpv-12.vault-trait)

;; bsd protocol
(use-trait bsd-trait .bsd-trait-vpv-12.bsd-trait)

;; sip-010-trait
(use-trait sbtc-trait .sip-010-trait-ft-standard-vpv-12.sip-010-trait)

;; oracle
(use-trait oracle-trait .oracle-trait-vpv-12.oracle-trait)

;; registry
(use-trait registry-trait .registry-trait-vpv-12.registry-trait)

;; stability
(use-trait stability-trait .stability-trait-vpv-12.stability-trait)

;; sorted vaults
(use-trait sorted-vaults-trait .sorted-vaults-trait-vpv-12.sorted-vaults-trait)

(define-constant ERR_COLLATERAL_TOO_LOW (err u300))
(define-constant ERR_DEBT_TOO_LOW (err u301))
(define-constant ERR_INTEREST_TOO_LOW (err u302))
(define-constant ERR_INTEREST_TOO_HIGH (err u303))
(define-constant ERR_VAULT_RATIO_THRESHOLD (err u304))
(define-constant ERR_GLOBAL_RATIO_THRESHOLD (err u305))
(define-constant ERR_VAULT_NOT_FOUND (err u306))
(define-constant ERR_NOT_AUTH (err u307))
(define-constant ERR_REPAY_TOO_HIGH (err u308))
(define-constant ERR_VAULT_DEBT (err u309))
(define-constant ERR_NO_INTEREST (err u310))
(define-constant ERR_NO_ORACLE_PRICE (err u311))
(define-constant ERR_NO_PROTOCOL_DATA (err u312))
(define-constant ERR_PROTOCOL_STATE (err u313))
(define-constant ERR_PROTOCOL_RECOVERY_MODE (err u314))
(define-constant ERR_CALCULATE_FEE (err u315))
(define-constant ERR_GLOBAL_COLLATERAL_CAP (err u316))
(define-constant ERR_LIST_OVERFLOW (err u317))
(define-constant ERR_NO_KEEPER (err u318))
(define-constant ERR_INVALID_INPUT (err u319))
(define-constant ERR_PROTOCOL_VAULT (err u320))

;; sBTC precision
(define-constant one-sbtc u100000000)
;; BSD precision
(define-constant one-bsd u100000000)
;; RATE precision
(define-constant one-percent u1000000)
;; precision
(define-constant PRECISION u8)

;; one full unit of precision u8 - ie. 100%, one bsd, one sbtc
(define-constant ONE_FULL_UNIT u100000000)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; vault-trait BEGIN
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; create vault / deposit collateral (sbtc) / mint loan (bsd)
(define-public (new-vault-wrapper (collateral-sbtc uint) (loan-bsd uint) (interest uint) (hint (optional uint)) (price-data (optional (buff 8192))) (bsd <bsd-trait>) (sbtc <sbtc-trait>) (oracle <oracle-trait>) (registry <registry-trait>) (stability <stability-trait>) (sorted-vaults <sorted-vaults-trait>))
    (let 
        (
            ;; validations
            (non-zero-collateral (asserts! (> collateral-sbtc u0) ERR_COLLATERAL_TOO_LOW))
            (non-zero-debt (asserts! (> loan-bsd u0) ERR_DEBT_TOO_LOW))
            (valid-principal (try! (contract-call? .controller-vpv-12 verify-principal contract-caller)))
            (valid-stability (try! (contract-call? .controller-vpv-12 check-approved-contract "stability" (contract-of stability))))
            (valid-registry (try! (contract-call? .controller-vpv-12 check-approved-contract "registry" (contract-of registry))))
            (valid-oracle (try! (contract-call? .controller-vpv-12 check-approved-contract "oracle" (contract-of oracle))))
            (valid-bsd (try! (contract-call? .controller-vpv-12 check-approved-contract "bsd" (contract-of bsd))))
            (valid-sbtc (try! (contract-call? .controller-vpv-12 check-approved-contract "sbtc" (contract-of sbtc))))
            (valid-sorted-vaults (try! (contract-call? .controller-vpv-12 check-approved-contract "sorted-vaults" (contract-of sorted-vaults))))

			;; get price
            (sbtc-price (try! (contract-call? oracle get-price price-data registry)))
            
            ;; protocol data
            (protocol-data (try! (contract-call? registry get-vault-protocol-info sbtc-price)))
            (recovery-mode (get recovery-mode protocol-data))
            (vault-loan-minimum (get vault-loan-minimum protocol-data))
            (vault-interest-minimum (get vault-interest-minimum protocol-data))
            (vault-interest-maximum (get vault-interest-maximum protocol-data))
            (current-sbtc-price (get current-oracle-price-sbtc protocol-data))
            (current-aggregate-collateral-in-usd (get total-collateral-in-bsd protocol-data))
            (global-collateral-cap (get global-collateral-cap protocol-data))
            (recovery-threshold (get recovery-threshold protocol-data))
            (vault-id (get latest-vault-id protocol-data))
            (protocol-fee-destination (get protocol-fee-destination protocol-data))
            (is-paused (get is-paused protocol-data))
            (is-maintenance (get is-maintenance protocol-data))
            (vault-threshold (if recovery-mode recovery-threshold (get vault-threshold protocol-data)))
            
            ;; derived values
            (collateral-in-usd (mul-to-fixed-precision collateral-sbtc PRECISION current-sbtc-price))
            (future-aggregate-collateral-in-usd (+ collateral-in-usd current-aggregate-collateral-in-usd))
            (loan-fees (unwrap! (calculate-loan-fee loan-bsd recovery-mode registry) ERR_CALCULATE_FEE))
            (final-loan-bsd (+ loan-bsd loan-fees))
            (current-ratio (div-to-fixed-precision collateral-in-usd PRECISION final-loan-bsd))
            
        )

        ;; check paused
        (asserts! (not is-paused) ERR_PROTOCOL_STATE)

        ;; check maintenance
        (asserts! (not is-maintenance) ERR_PROTOCOL_STATE)

        ;; check if is first vault - only allow admin to create first vault
        (if (is-eq vault-id u0)
            (try! (contract-call? .controller-vpv-12 is-admin tx-sender))
            true
        )

        ;; check that loan is above minimum
        (asserts! (>= final-loan-bsd vault-loan-minimum) ERR_DEBT_TOO_LOW)

        ;; Assert that new vault is below vault collateral ratio threshold
        (asserts! (>= current-ratio vault-threshold) ERR_VAULT_RATIO_THRESHOLD)

        ;; check that interest is greater than minimum
        (asserts! (>= interest vault-interest-minimum) ERR_INTEREST_TOO_LOW)

        ;; check that interest is less than maximum
        (asserts! (<= interest vault-interest-maximum) ERR_INTEREST_TOO_HIGH)

        ;; Assert that newly added collateral will not cause protocol to exceed global collateral cap
        (asserts! (>= global-collateral-cap future-aggregate-collateral-in-usd) ERR_GLOBAL_COLLATERAL_CAP)

        ;; deposit collateral
        (try! (contract-call? sbtc transfer collateral-sbtc tx-sender (as-contract tx-sender) none))

        ;; mint loan
        (try! (contract-call? bsd protocol-mint tx-sender loan-bsd))

        ;; mint fee if not in recovery mode
        (if (is-eq u0 loan-fees)
            
            ;; finalize vault creation in registry
            (try! (contract-call? registry new-vault tx-sender collateral-sbtc final-loan-bsd interest hint sorted-vaults))

            (begin 
                (try! (contract-call? bsd protocol-mint protocol-fee-destination loan-fees))
                ;; finalize vault creation in registry
                (try! (contract-call? registry new-vault tx-sender collateral-sbtc final-loan-bsd interest hint sorted-vaults))
            )
        )
        
        (ok 
            {
                vault-id: vault-id,
                information: (unwrap-panic (contract-call? registry get-vault vault-id)),
                compounded-information: (unwrap-panic (contract-call? registry get-vault-compounded-info vault-id current-sbtc-price))
            }
        )
    )
)

;; mint loan
(define-public (mint-loan-wrapper (vault-id uint) (borrow-bsd uint) (price-data (optional (buff 8192))) (bsd <bsd-trait>) (sbtc <sbtc-trait>) (oracle <oracle-trait>) (registry <registry-trait>) (stability <stability-trait>))
    (let 
        (
            ;; checks
            (valid-principal (try! (contract-call? .controller-vpv-12 verify-principal contract-caller)))
            (valid-stability (try! (contract-call? .controller-vpv-12 check-approved-contract "stability" (contract-of stability))))
            (valid-registry (try! (contract-call? .controller-vpv-12 check-approved-contract "registry" (contract-of registry))))
            (valid-oracle (try! (contract-call? .controller-vpv-12 check-approved-contract "oracle" (contract-of oracle))))
            (valid-bsd (try! (contract-call? .controller-vpv-12 check-approved-contract "bsd" (contract-of bsd))))
            (valid-sbtc (try! (contract-call? .controller-vpv-12 check-approved-contract "sbtc" (contract-of sbtc))))
            
			;; get price
            (sbtc-price (try! (contract-call? oracle get-price price-data registry)))

            ;; vault data
            (vault-data (unwrap-panic (contract-call? registry get-vault vault-id)))
            (borrower (unwrap-panic (get borrower vault-data)))

            ;; protocol data
            (protocol-data (unwrap! (contract-call? registry get-vault-protocol-info sbtc-price) ERR_NO_PROTOCOL_DATA))
            (recovery-mode (get recovery-mode protocol-data))
            (recovery-threshold (get recovery-threshold protocol-data))
            (is-maintenance (get is-maintenance protocol-data))
            (vault-threshold (if recovery-mode recovery-threshold (get vault-threshold protocol-data)))
            (vault-loan-minimum (get vault-loan-minimum protocol-data))
            (current-sbtc-price (get current-oracle-price-sbtc protocol-data))
            (protocol-fee-destination (get protocol-fee-destination protocol-data))
            (is-paused (get is-paused protocol-data))
            (current-aggregate-bsd-loans (get total-bsd-loans protocol-data))
            (global-collateral-cap (get global-collateral-cap protocol-data))

            ;; action
			;; accrual is added to vault borrowed bsd here and retrieved intrinsically below
            (accrued (try! (accrue-vault vault-id bsd registry)))

            ;; compounded balances
            (vault-compounded-info (unwrap-panic (contract-call? registry get-vault-compounded-info vault-id sbtc-price)))
            (vault-total-debt (get vault-total-debt vault-compounded-info))
            (vault-total-collateral (get vault-total-collateral vault-compounded-info))

            ;; derived values
            (loan-fees (unwrap! (calculate-loan-fee borrow-bsd recovery-mode registry) ERR_CALCULATE_FEE))
            (final-loan-bsd (+ borrow-bsd loan-fees))
            (increased-vault-loan (+ vault-total-debt final-loan-bsd))
			(current-ratio (try! (contract-call? registry calculate-collateral-ratio (+ vault-total-debt borrow-bsd loan-fees) vault-total-collateral sbtc-price)))
        )

        ;; check paused
        (asserts! (not is-paused) ERR_PROTOCOL_STATE)

        ;; check maintenance
        (asserts! (not is-maintenance) ERR_PROTOCOL_STATE)
        
        ;; check that tx-sender is the owner of the vault
        (asserts! (is-eq tx-sender borrower) ERR_NOT_AUTH)

        ;; check that vault debt is above minimum
        (asserts! (>= increased-vault-loan vault-loan-minimum) ERR_DEBT_TOO_LOW)

        ;; Assert that new vault is below vault collateral ratio threshold
        (asserts! (>= current-ratio vault-threshold) ERR_VAULT_RATIO_THRESHOLD)

        ;; mint loan (post-fee)
        (try! (contract-call? bsd protocol-mint tx-sender borrow-bsd))

        ;; mint fee if not in recovery mode
        (if (is-eq u0 loan-fees)
            
            ;; finalize loan minting in registry
            (try! (contract-call? registry mint-loan vault-id final-loan-bsd sbtc-price))

            (begin 
                (try! (contract-call? bsd protocol-mint protocol-fee-destination loan-fees))
                ;; finalize loan minting in registry
                (try! (contract-call? registry mint-loan vault-id final-loan-bsd sbtc-price))
            )
        )

        (ok 
            {
                vault-id: vault-id,
                information: (unwrap-panic (contract-call? registry get-vault vault-id)),
                compounded-information: vault-compounded-info
            }
        )
    )
)

;; repay-loan
(define-public (repay-loan-wrapper (vault-id uint) (repay-bsd uint) (price-data (optional (buff 8192))) (bsd <bsd-trait>) (sbtc <sbtc-trait>) (oracle <oracle-trait>) (registry <registry-trait>) (stability <stability-trait>) (sorted-vaults <sorted-vaults-trait>))
    (let 
        (
            ;; validations
            (valid-principal (try! (contract-call? .controller-vpv-12 verify-principal contract-caller)))
            (valid-stability (try! (contract-call? .controller-vpv-12 check-approved-contract "stability" (contract-of stability))))
            (valid-registry (try! (contract-call? .controller-vpv-12 check-approved-contract "registry" (contract-of registry))))
            (valid-oracle (try! (contract-call? .controller-vpv-12 check-approved-contract "oracle" (contract-of oracle))))
            (valid-bsd (try! (contract-call? .controller-vpv-12 check-approved-contract "bsd" (contract-of bsd))))
            (valid-sbtc (try! (contract-call? .controller-vpv-12 check-approved-contract "sbtc" (contract-of sbtc))))
            (valid-sorted-vaults (try! (contract-call? .controller-vpv-12 check-approved-contract "sorted-vaults" (contract-of sorted-vaults))))

            ;; get price
            (sbtc-price (try! (contract-call? oracle get-price price-data registry)))

            ;; protocol data
            (protocol-data (unwrap! (contract-call? registry get-vault-protocol-info sbtc-price) ERR_NO_PROTOCOL_DATA))
            (is-paused (get is-paused protocol-data))

            ;; vault data
            (vault (unwrap-panic (contract-call? registry get-vault vault-id)))
            (borrower (unwrap-panic (get borrower vault)))

            ;; compounded balances
            (vault-compounded-info (unwrap-panic (contract-call? registry get-vault-compounded-info vault-id sbtc-price)))
            (vault-total-debt (get vault-total-debt vault-compounded-info))
            (vault-total-collateral (get vault-total-collateral vault-compounded-info))

            ;; derived values
            (adjusted-total-repay-amount (if (>= repay-bsd vault-total-debt) vault-total-debt repay-bsd))
            (future-total-debt-amount (- vault-total-debt adjusted-total-repay-amount))
        )

        ;; check paused
        (asserts! (not is-paused) ERR_PROTOCOL_STATE)

        ;; check that tx-sender is the owner of the vault
        (asserts! (is-eq tx-sender borrower) ERR_NOT_AUTH)

        ;; check that future vault loan is above minimum threshold
        (asserts! (or (>= future-total-debt-amount (get vault-loan-minimum protocol-data)) (is-eq future-total-debt-amount u0)) ERR_DEBT_TOO_LOW)


        (print {
                repay-event: {
                    vault: vault,
                    borrower: borrower,
                    vault-compounded-info: vault-compounded-info,
                    vault-total-debt: vault-total-debt,
                    vault-total-collateral: vault-total-collateral,
                    adjusted-total-repay-amount: adjusted-total-repay-amount,
                    future-total-debt-amount: future-total-debt-amount,
                    sbtc-price: sbtc-price
                }
            }
        )

        ;; close out vault if loan is fully repaid or reduce debt if partial repayment
        (if (is-eq future-total-debt-amount u0)
            
            (begin

                ;; burn the bsd
                (try! (contract-call? bsd burn adjusted-total-repay-amount tx-sender))

                ;; mint bsd to protocol fee destination
                (try! (accrue-vault vault-id bsd registry))

                ;; finalize loan repayment in registry
                (try! (contract-call? registry repay-loan vault-id adjusted-total-repay-amount sbtc-price))

                ;; withdraw collateral
                (try! (contract-call? sbtc transfer vault-total-collateral (as-contract tx-sender) tx-sender none))

                ;; finalize collateral withdrawal in registry
                (try! (contract-call? registry remove-collateral vault-id vault-total-collateral sbtc-price))

                (try! (contract-call? registry close-vault vault-id sorted-vaults))
            )

            (begin
                ;; burn the bsd
                (try! (contract-call? bsd burn repay-bsd tx-sender))

                ;; mint bsd to protocol fee destination
                (try! (accrue-vault vault-id bsd registry))

                ;; finalize loan repayment in registry
                (try! (contract-call? registry repay-loan vault-id repay-bsd sbtc-price))
            )
        ) 

        (ok 
            {
                vault-id: vault-id,
                information: (unwrap-panic (contract-call? registry get-vault vault-id)),
                compounded-information: vault-compounded-info
            }
        ) 
    )
)

;; add-collateral
(define-public (add-collateral-wrapper (vault-id uint) (collateral-sbtc uint) (price-data (optional (buff 8192))) (bsd <bsd-trait>) (sbtc <sbtc-trait>) (oracle <oracle-trait>) (registry <registry-trait>) (stability <stability-trait>))
    (let 
        (
            ;; checks
            (valid-principal (try! (contract-call? .controller-vpv-12 verify-principal contract-caller)))
            (valid-stability (try! (contract-call? .controller-vpv-12 check-approved-contract "stability" (contract-of stability))))
            (valid-registry (try! (contract-call? .controller-vpv-12 check-approved-contract "registry" (contract-of registry))))
            (valid-oracle (try! (contract-call? .controller-vpv-12 check-approved-contract "oracle" (contract-of oracle))))
            (valid-bsd (try! (contract-call? .controller-vpv-12 check-approved-contract "bsd" (contract-of bsd))))
            (valid-sbtc (try! (contract-call? .controller-vpv-12 check-approved-contract "sbtc" (contract-of sbtc))))

            ;; get price
            (sbtc-price (try! (contract-call? oracle get-price price-data registry)))
            
            ;; action
            (accrued-interest (try! (accrue-vault vault-id bsd registry)))

            ;; vault data
            (vault-data (try! (contract-call? registry get-vault vault-id)))
            (borrower (unwrap-panic (get borrower vault-data)))
            (current-vault-collateral (unwrap-panic (get collateral-sbtc vault-data)))

            ;; protocol data
            (protocol-data (try! (contract-call? registry get-vault-protocol-info sbtc-price)))
            (global-collateral-cap (get global-collateral-cap protocol-data))
            (is-paused (get is-paused protocol-data))
            (is-maintenance (get is-maintenance protocol-data))
            (current-aggregate-sbtc-collateral (get total-sbtc-collateral protocol-data))
            (current-aggregate-collateral-in-usd (get total-collateral-in-bsd protocol-data))
            
            ;; derived values
            (collateral-in-usd (mul-to-fixed-precision collateral-sbtc PRECISION sbtc-price))
            (future-aggregate-collateral-in-usd (+ collateral-in-usd current-aggregate-collateral-in-usd))  
        )

        ;; check paused
        (asserts! (not is-paused) ERR_PROTOCOL_STATE)

        ;; check maintenance
        (asserts! (not is-maintenance) ERR_PROTOCOL_STATE)

        ;; check that tx-sender is the owner of the vault
        (asserts! (is-eq tx-sender borrower) ERR_NOT_AUTH)

        ;; Assert that newly added collateral will not cause protocol to exceed global collateral cap
        (asserts! (>= global-collateral-cap future-aggregate-collateral-in-usd) ERR_GLOBAL_COLLATERAL_CAP)

        ;; deposit collateral
        (try! (contract-call? sbtc transfer collateral-sbtc tx-sender (as-contract tx-sender) none))

        ;; finalize collateral addition in registry
        (try! (contract-call? registry add-collateral vault-id collateral-sbtc sbtc-price))
        (ok 
            {
                vault-id: vault-id,
                information: (unwrap-panic (contract-call? registry get-vault vault-id)),
                compounded-information: (unwrap-panic (contract-call? registry get-vault-compounded-info vault-id sbtc-price))
            }
        )   
    )
)

;; withdraw-collateral
(define-public (withdraw-collateral-wrapper (vault-id uint) (remove-amount uint) (price-data (optional (buff 8192))) (bsd <bsd-trait>) (sbtc <sbtc-trait>) (oracle <oracle-trait>) (registry <registry-trait>) (stability <stability-trait>) (sorted-vaults <sorted-vaults-trait>))
    (let 
        (
            ;; checks
            (valid-principal (try! (contract-call? .controller-vpv-12 verify-principal contract-caller)))
            (valid-stability (try! (contract-call? .controller-vpv-12 check-approved-contract "stability" (contract-of stability))))
            (valid-registry (try! (contract-call? .controller-vpv-12 check-approved-contract "registry" (contract-of registry))))
            (valid-oracle (try! (contract-call? .controller-vpv-12 check-approved-contract "oracle" (contract-of oracle))))
            (valid-bsd (try! (contract-call? .controller-vpv-12 check-approved-contract "bsd" (contract-of bsd))))
            (valid-sbtc (try! (contract-call? .controller-vpv-12 check-approved-contract "sbtc" (contract-of sbtc))))
            (valid-sorted-vaults (try! (contract-call? .controller-vpv-12 check-approved-contract "sorted-vaults" (contract-of sorted-vaults))))
            
            ;; get price
            (sbtc-price (try! (contract-call? oracle get-price price-data registry)))

            ;; actions 
            (accrued-interest (try! (accrue-vault vault-id bsd registry)))
            
            ;; protocol data
            (protocol-data (try! (contract-call? registry get-vault-protocol-info sbtc-price)))
            (recovery-mode (get recovery-mode protocol-data))
            (recovery-threshold (get recovery-threshold protocol-data))
            (vault-threshold (if recovery-mode recovery-threshold (get vault-threshold protocol-data)))
            (is-paused (get is-paused protocol-data))

            ;; vault data
            (vault-data (try! (contract-call? registry get-vault vault-id)))
            (borrower (unwrap-panic (get borrower vault-data)))

            (vault-tranches (try! (contract-call? registry get-vault-compounded-info vault-id sbtc-price)))
            (vault-total-debt (get vault-total-debt vault-tranches))
            (vault-total-collateral (get vault-total-collateral vault-tranches))
            (vault-collateral (get vault-collateral vault-tranches))
            (vault-protocol-collateral (get vault-protocol-collateral vault-tranches))

            ;; assertion
            (valid-removal-amount (asserts! (and (> remove-amount u0) ( >= vault-total-collateral remove-amount)) ERR_INVALID_INPUT))
            
            ;; derived values
            (new-vault-collateral (- vault-total-collateral remove-amount))
            (new-vault-collateral-in-usd (mul-to-fixed-precision new-vault-collateral PRECISION sbtc-price))
            (current-ratio (div-to-fixed-precision new-vault-collateral-in-usd PRECISION (if (is-eq vault-total-debt u0) u1 vault-total-debt)))
        )

        ;; check paused
        (asserts! (not is-paused) ERR_PROTOCOL_STATE)

        ;; check that tx-sender is the owner of the vault
        (asserts! (is-eq tx-sender borrower) ERR_NOT_AUTH)

        ;; check that new vault is below ratio threshold
        (asserts! (or (>= current-ratio vault-threshold) (is-eq vault-total-debt u0)) ERR_VAULT_RATIO_THRESHOLD)

        ;; withdraw collateral
        (try! (contract-call? sbtc transfer remove-amount (as-contract tx-sender) tx-sender none))

        ;; finalize collateral withdrawal in registry
        (try! (contract-call? registry remove-collateral vault-id remove-amount sbtc-price))


        ;; close vault if collateral is zero
        (if (is-eq remove-amount vault-total-collateral)
            (try! (contract-call? registry close-vault vault-id sorted-vaults))
            true
        )

        (ok 
            {
                vault-id: vault-id,
                information: (unwrap-panic (contract-call? registry get-vault vault-id)),
                compounded-information: vault-tranches
            }
        )
    )
)

;; update interest rate
(define-public (update-interest-rate-wrapper (vault-id uint) (interest uint) (price-data (optional (buff 8192))) (bsd <bsd-trait>) (sbtc <sbtc-trait>) (oracle <oracle-trait>) (registry <registry-trait>) (stability <stability-trait>))
    (let 
        (
            ;; checks
            (valid-principal (try! (contract-call? .controller-vpv-12 verify-principal contract-caller)))
            (valid-stability (try! (contract-call? .controller-vpv-12 check-approved-contract "stability" (contract-of stability))))
            (valid-registry (try! (contract-call? .controller-vpv-12 check-approved-contract "registry" (contract-of registry))))
            (valid-oracle (try! (contract-call? .controller-vpv-12 check-approved-contract "oracle" (contract-of oracle))))
            (valid-bsd (try! (contract-call? .controller-vpv-12 check-approved-contract "bsd" (contract-of bsd))))
            (valid-sbtc (try! (contract-call? .controller-vpv-12 check-approved-contract "sbtc" (contract-of sbtc))))
            
            ;; get price
            (sbtc-price (try! (contract-call? oracle get-price price-data registry)))

            ;; protocol data
            (protocol-data (try! (contract-call? registry get-vault-protocol-info sbtc-price)))
            (vault-interest-minimum (get vault-interest-minimum protocol-data))
            (vault-interest-maximum (get vault-interest-maximum protocol-data))
            (is-maintenance (get is-maintenance protocol-data))
            (is-paused (get is-paused protocol-data))
            
            ;; vault data
            (vault-data (unwrap! (contract-call? registry get-vault vault-id) ERR_VAULT_NOT_FOUND))
            (borrower (unwrap-panic (get borrower vault-data)))
            (delegate (unwrap-panic (get interest-rate-delegate vault-data)))
            (is-delegate (is-eq delegate tx-sender))
        )

        ;; check paused
        (asserts! (not is-paused) ERR_PROTOCOL_STATE)

        ;; check maintenance
        (asserts! (not is-maintenance) ERR_PROTOCOL_STATE)

        ;; check that tx-sender is the owner of the vault
        (asserts! (or (is-eq tx-sender borrower) (is-eq tx-sender delegate)) ERR_NOT_AUTH)
        
        ;; check that interest is greater than minimum
        (asserts! (>= interest vault-interest-minimum) ERR_INTEREST_TOO_LOW)

        ;; check that interest is less than maximum
        (asserts! (<= interest vault-interest-maximum) ERR_INTEREST_TOO_HIGH)

        ;; finalize interest rate update in registry
        (try! (contract-call? registry update-interest-rate vault-id interest))


        (ok 
            {
                vault-id: vault-id,
                information: (unwrap-panic (contract-call? registry get-vault vault-id)),
                compounded-information: (unwrap-panic (contract-call? registry get-vault-compounded-info vault-id sbtc-price))
            }
                
        )    
    )
)

;; delegate-rate
(define-public (update-rate-delegate (vault-id uint) (delegate principal) (registry <registry-trait>))
    (let 
        (
            (valid-principal (try! (contract-call? .controller-vpv-12 verify-principal contract-caller)))
            (valid-registry (try! (contract-call? .controller-vpv-12 check-approved-contract "registry" (contract-of registry))))
        
            ;; vault data
            (vault-data (unwrap! (contract-call? registry get-vault vault-id) ERR_VAULT_NOT_FOUND))
            (borrower (unwrap-panic (get borrower vault-data)))
        )

        ;; check that tx-sender is the owner of the vault
        (asserts! (is-eq tx-sender borrower) ERR_NOT_AUTH)
        
        ;; finalize rate delegate in registry
        (ok (try! (contract-call? registry update-delegate vault-id delegate)))
    )
)

;; protocol-transfer-sbtc
(define-public (protocol-transfer-sbtc (to principal) (amount uint) (sbtc <sbtc-trait>))
     (let 
        (
            (valid-sbtc (try! (contract-call? .controller-vpv-12 check-approved-contract "sbtc" (contract-of sbtc))))
        )

        ;; check that caller is a protocol contract
        (try! (contract-call? .controller-vpv-12 is-protocol-caller contract-caller))

        ;; finalize transfer of sbtc
        (as-contract (contract-call? sbtc transfer amount (as-contract tx-sender) to none))
    )
)

;; calculate loan fee
(define-public (calculate-loan-fee (loan-bsd uint) (recovery-mode bool) (registry <registry-trait>))
    (let (
            (valid-registry (try! (contract-call? .controller-vpv-12 check-approved-contract "registry" (contract-of registry))))
            (final-base-rate (unwrap! (contract-call? registry get-borrow-fee-rate recovery-mode) ERR_CALCULATE_FEE))
            (loan-fees (mul-perc final-base-rate u8 loan-bsd))
        )
        (ok loan-fees)
    )
)

(define-public (process-epoch-rates (vaults (list 100 uint)) (hints (list 100 (optional uint))) (registry <registry-trait>) (sorted-vaults <sorted-vaults-trait>))
    (let
        (
            (valid-registry (try! (contract-call? .controller-vpv-12 check-approved-contract "registry" (contract-of registry))))
            (valid-sorted-vaults (try! (contract-call? .controller-vpv-12 check-approved-contract "sorted-vaults" (contract-of sorted-vaults))))
            (is-keeper (unwrap! (contract-call? .controller-vpv-12 is-keeper tx-sender) ERR_NO_KEEPER))
        )

        ;; check that caller is the keeper
        (asserts! (is-eq true is-keeper) ERR_NOT_AUTH)

        (ok (try! (fold attempt-update-epoch-rate vaults (ok { index: u0, updated: (list ), hints: hints, registry: registry, sorted-vaults: sorted-vaults }))))
    )
)

(define-public (process-epoch-accrual (vaults (list 100 uint)) (bsd <bsd-trait>) (registry <registry-trait>))
    (let
        (
            (valid-registry (try! (contract-call? .controller-vpv-12 check-approved-contract "registry" (contract-of registry))))
            (valid-bsd (try! (contract-call? .controller-vpv-12 check-approved-contract "bsd" (contract-of bsd))))
            (is-keeper (unwrap! (contract-call? .controller-vpv-12 is-keeper tx-sender) ERR_NO_KEEPER))
        )

        ;; check that caller is the keeper
        (asserts! (is-eq true is-keeper) ERR_NOT_AUTH)

        (print { 
                epoch-accrual-event: {
                    batch-vaults: vaults,
                }
            }
        )

        (ok (try! (fold process-epoch-accrual-batch vaults (ok {accrued: (list ), bsd: bsd, registry: registry}))))
    )
)

(define-public (process-liquidations (vaults (list 10 uint)) (price-data (optional (buff 8192))) (bsd <bsd-trait>) (sbtc <sbtc-trait>) (oracle <oracle-trait>) (registry <registry-trait>) (stability <stability-trait>) (sorted-vaults <sorted-vaults-trait>))
    (let
        (
            (valid-stability (try! (contract-call? .controller-vpv-12 check-approved-contract "stability" (contract-of stability))))
            (valid-registry (try! (contract-call? .controller-vpv-12 check-approved-contract "registry" (contract-of registry))))
            (valid-oracle (try! (contract-call? .controller-vpv-12 check-approved-contract "oracle" (contract-of oracle))))
            (valid-bsd (try! (contract-call? .controller-vpv-12 check-approved-contract "bsd" (contract-of bsd))))
            (valid-sbtc (try! (contract-call? .controller-vpv-12 check-approved-contract "sbtc" (contract-of sbtc))))
            (valid-sorted-vaults (try! (contract-call? .controller-vpv-12 check-approved-contract "sorted-vaults" (contract-of sorted-vaults))))
			(is-keeper (unwrap! (contract-call? .controller-vpv-12 is-keeper tx-sender) ERR_NO_KEEPER))
            
			;; get price
			(sbtc-price (try! (contract-call? oracle get-price price-data registry)))

            (aggregate-amount (try! (contract-call? registry get-aggregate-debt-and-collateral)))
            (aggregate-bsd (get debt-bsd aggregate-amount))
            (aggregate-sbtc (get collateral-sbtc aggregate-amount))

            (cleared-dust (try! (contract-call? registry clear-stability-dust)))
        )

        (print  { 
                batch-liquidation-event: {
                    batch-vaults: vaults,
                    aggregate-bsd: aggregate-bsd,
                    aggregate-sbtc: aggregate-sbtc,
                    sbtc-price: sbtc-price
                }
            }
        )

        ;; check that caller is the keeper
        (asserts! (is-eq true is-keeper) ERR_NOT_AUTH)

        (ok (try! (fold process-vault-liquidation vaults (ok {liquidated: (list ), sbtc-price: sbtc-price, bsd: bsd, sbtc: sbtc, registry: registry, stability: stability, sorted-vaults: sorted-vaults}))))
    )
)

(define-public (unwind-vault (vault-id uint) (price-data (optional (buff 8192))) (sbtc <sbtc-trait>) (registry <registry-trait>) (oracle <oracle-trait>) (sorted-vaults <sorted-vaults-trait>))
    (let
        (
            (valid-registry (try! (contract-call? .controller-vpv-12 check-approved-contract "registry" (contract-of registry))))
            (valid-sbtc (try! (contract-call? .controller-vpv-12 check-approved-contract "sbtc" (contract-of sbtc))))
            (valid-oracle (try! (contract-call? .controller-vpv-12 check-approved-contract "oracle" (contract-of oracle))))
            (valid-sorted-vaults (try! (contract-call? .controller-vpv-12 check-approved-contract "sorted-vaults" (contract-of sorted-vaults))))
            (is-keeper (unwrap! (contract-call? .controller-vpv-12 is-keeper tx-sender) ERR_NO_KEEPER))

			;; get price
            (sbtc-price (try! (contract-call? oracle get-price price-data registry)))

            (current-vault (try! (contract-call? registry get-vault vault-id)))
            (borrower (unwrap-panic (get borrower current-vault)))
            (compounded-balance (try! (contract-call? registry get-vault-compounded-info vault-id sbtc-price)))
            (vault-total-debt (get vault-total-debt compounded-balance))
            (vault-total-collateral (get vault-total-collateral compounded-balance))
        )

        ;; check that caller is the keeper
        (asserts! (is-eq true is-keeper) ERR_NOT_AUTH)

        ;; check that vault has no debt
        (asserts! (is-eq vault-total-debt u0) ERR_VAULT_DEBT)

        ;; send rewards to borrower
        (try! (contract-call? sbtc transfer vault-total-collateral (as-contract tx-sender) borrower none))

        (ok (try! (contract-call? registry unwind-vault vault-id sbtc-price sorted-vaults)))
    )

)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; vault-trait END
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; liquidate fold function
(define-private (process-vault-liquidation (vault-id uint) (batch-response (response {liquidated: (list 10 uint), sbtc-price: uint, bsd: <bsd-trait>, sbtc: <sbtc-trait>, registry: <registry-trait>, stability: <stability-trait>, sorted-vaults: <sorted-vaults-trait>} uint)))
    (match batch-response
        helper-tuple
            (let 
                (
                    (sbtc-price (get sbtc-price helper-tuple))
                    (liquidated (get liquidated helper-tuple))
                    (bsd (get bsd helper-tuple))
                    (sbtc (get sbtc helper-tuple))
                    (registry (get registry helper-tuple))
                    (stability (get stability helper-tuple))
                    (sorted-vaults (get sorted-vaults helper-tuple))
                    (vault-accrued (try! (accrue-vault vault-id bsd registry)))
                    (vault-info (unwrap! (contract-call? registry get-vault vault-id) (err vault-id)))
                    (vault-liquidated (try! (attempt-liquidate-vault vault-id sbtc-price bsd sbtc registry stability sorted-vaults)))
                )

                (if (is-eq vault-liquidated true)
                    (begin
                        (ok {liquidated: (unwrap! (as-max-len? (append liquidated vault-id) u10) ERR_LIST_OVERFLOW), sbtc-price: sbtc-price, bsd: bsd, sbtc: sbtc, registry: registry, stability: stability, sorted-vaults: sorted-vaults})
                    )
                    (begin    
                        (ok {liquidated: liquidated, sbtc-price: sbtc-price, bsd: bsd, sbtc: sbtc, registry: registry, stability: stability, sorted-vaults: sorted-vaults})
                    )
                )
        )
        err-resp
        (err err-resp)
    )
)

;; liquidate fold function
(define-private (attempt-update-epoch-rate (vault-id uint) (update-response (response { index: uint, updated: (list 100 uint), hints: (list 100 (optional uint)), registry: <registry-trait>, sorted-vaults: <sorted-vaults-trait>} uint)))
    (match update-response
        helper-tuple
            (let 
                (
                    (updated (get updated helper-tuple))
                    (registry (get registry helper-tuple))
                    (sorted-vaults (get sorted-vaults helper-tuple))
                    (index (get index helper-tuple))
                    (hints (get hints helper-tuple))
                    (hint (unwrap-panic (element-at? hints index)))
                    (update (try! (contract-call? registry update-epoch-rate vault-id hint sorted-vaults)))
                )

                (ok {index: (+ index u1), updated: (unwrap! (as-max-len? (append updated vault-id) u100) ERR_LIST_OVERFLOW), hints: hints, registry: registry, sorted-vaults: sorted-vaults})    
            )
        err-resp
        (err err-resp)
    )
)

;; accrual fold function target
(define-private (process-epoch-accrual-batch (vault-id uint) (batch-response (response {accrued: (list 100 uint), bsd: <bsd-trait>, registry: <registry-trait>} uint)))
    (match batch-response
        helper-tuple
            (let 
                (
                    (accrued (get accrued helper-tuple))
                    (bsd (get bsd helper-tuple))
                    (registry (get registry helper-tuple))
                    (accrued-interest (try! (accrue-vault vault-id bsd registry)))
                )

                (ok {accrued: (unwrap! (as-max-len? (append accrued vault-id) u100) ERR_LIST_OVERFLOW), bsd: bsd, registry: registry})
            )
        err-resp
        (err err-resp)
    )
)

;; vault owner/keeper accrue method
(define-private (accrue-vault (vault-id uint) (bsd <bsd-trait>) (registry <registry-trait>))
    (let 
        (
            (is-paused (try! (contract-call? registry get-is-paused)))
            (protocol-fee-destination (try! (contract-call? registry get-protocol-fee-destination)))
            (vault-data (try! (contract-call? registry get-vault vault-id)))
            (vault-balances (unwrap-panic (contract-call? registry get-vault-protocol-shares vault-id)))
            (vault-debt (unwrap-panic (get borrowed-bsd vault-data)))
            (vault-protocol-debt (get attributed-protocol-debt vault-balances))
            (vault-protocol-debt-calculated (get calculated-protocol-debt vault-balances))
            (vault-total-debt-minus-accrual (+ vault-debt vault-protocol-debt vault-protocol-debt-calculated))
            (vault-accrued-bsd (unwrap-panic (contract-call? registry get-vault-accrued-interest vault-id vault-total-debt-minus-accrual)))
            (current-epoch-rate (get interest-rate vault-data))
            (last-interest-accrued (unwrap-panic (get last-interest-accrued vault-data)))
            (is-keeper (unwrap-panic (contract-call? .controller-vpv-12 is-keeper tx-sender)))
        )

        ;; check paused
        (asserts! (not is-paused) ERR_PROTOCOL_STATE)

        ;; check that tx-sender is the owner of the vault or the keeper
        (asserts! (or is-keeper (is-eq tx-sender (unwrap-panic (get borrower vault-data)))) ERR_NOT_AUTH)
            
        (print { 
                accrue-event: {
                    vault-id: vault-id,
                    accrual: vault-accrued-bsd,
                    current-epoch-rate: current-epoch-rate,
                    last-interest-accrued: last-interest-accrued,
                    burn-block-height: burn-block-height,
                }
            }
        )

        (if (> vault-accrued-bsd u0)
            
            (begin
                (try! (contract-call? bsd protocol-mint protocol-fee-destination vault-accrued-bsd))
                (try! (contract-call? registry accrue-interest vault-id))
                (ok vault-accrued-bsd)
            )
           (ok u0)
        )
    )
)

;; keeper liquidate method
(define-private (attempt-liquidate-vault (vault-id uint) (sbtc-price uint) (bsd <bsd-trait>) (sbtc <sbtc-trait>) (registry <registry-trait>) (stability <stability-trait>) (sorted-vaults <sorted-vaults-trait>))
    (let 
        (
            (protocol-data (try! (contract-call? registry get-protocol-data sbtc-price sorted-vaults)))
            (current-sbtc-price (get current-oracle-price-sbtc protocol-data))
            (stability-pool-data (unwrap-panic (contract-call? registry get-stability-pool-data)))
            (stability-pool-aggregate-bsd (get aggregate-bsd stability-pool-data))
            
            (compounded-balance (try! (contract-call? registry get-vault-compounded-info vault-id sbtc-price)))
            (vault-total-debt (get vault-total-debt compounded-balance))
            (vault-total-collateral (get vault-total-collateral compounded-balance))
            
            (vault-collateral-in-usd (mul-to-fixed-precision vault-total-collateral PRECISION current-sbtc-price))
            (vault-collateral-ratio (div-to-fixed-precision vault-collateral-in-usd PRECISION (if (is-eq u0 vault-total-debt) u1 vault-total-debt)))
            (vault-eligible-for-liquidation (< vault-collateral-ratio (get vault-threshold protocol-data)))
            (is-keeper (unwrap! (contract-call? .controller-vpv-12 is-keeper tx-sender) ERR_NO_KEEPER))
            (is-paused (get is-paused protocol-data))
        )

        ;; check paused
        (asserts! (not is-paused) ERR_PROTOCOL_STATE)

        ;; check that tx-sender is the owner of the vault or the keeper
        (asserts! is-keeper ERR_NOT_AUTH)

        ;; check that vault-id is not 0
        (asserts! (not (is-eq vault-id u0)) ERR_PROTOCOL_VAULT)

        ;; check that vault w/ interest is below threshold (below 110%)
        (if vault-eligible-for-liquidation
             ;; Call liquidate-vault
            (ok (try! (liquidate-vault vault-id vault-total-debt vault-total-collateral stability-pool-aggregate-bsd bsd sbtc registry stability sorted-vaults)))
            (ok false)
        )
    )
)

;; shared keeper and vault action
(define-private (liquidate-vault (vault-id uint) (accrued-vault-loan-bsd uint) (vault-collateral-sbtc uint) (stability-pool-aggregate-bsd uint) (bsd <bsd-trait>) (sbtc <sbtc-trait>) (registry <registry-trait>) (stability <stability-trait>) (sorted-vaults <sorted-vaults-trait>))

    (begin    
        ;; check whether we need to liquidate or partially liquidate + redistribute
        (if (> accrued-vault-loan-bsd stability-pool-aggregate-bsd)
            ;; more borrowed than in stability pool, partial liquidation + redistribution
            (let
                (
                    ;; calculate ratio of sbtc to go to stability pool
                    (stability-share (div stability-pool-aggregate-bsd accrued-vault-loan-bsd))
                    ;; calculate ratio of sbtc to go to vault 
                    (vault-share (- ONE_FULL_UNIT stability-share))
                    ;; calculate amount of vault collateral to go to stability pool
                    (stability-sbtc (mul-perc stability-share PRECISION vault-collateral-sbtc))
                    ;; calculate amount of bsd to be burned from stability pool - it is all of it since the vault debt is greater than the pool balance
                    (stability-bsd stability-pool-aggregate-bsd)
                    ;; calculate amount of sbtc to go to vault
                    (vault-sbtc (mul-perc vault-share PRECISION vault-collateral-sbtc))
                    ;; calculate amount of bsd to go to vault
                    (vault-bsd (- accrued-vault-loan-bsd stability-pool-aggregate-bsd))
                )

                (if (is-eq stability-pool-aggregate-bsd u0)
                    (try! (contract-call? registry liquidation-update-vault-redistribution vault-id vault-bsd vault-sbtc true sorted-vaults))
                    (begin
                        ;; burn partial debt amount from stability pool
                        (try! (contract-call? stability protocol-burn-bsd stability-pool-aggregate-bsd bsd registry))

                        ;; transfer partial collateral to stability pool
                        (try! (as-contract (contract-call? sbtc transfer stability-sbtc tx-sender (contract-of stability) none)))

                        ;; don't delete vault here
                        (try! (contract-call? registry liquidation-update-provider-distribution vault-id stability-bsd stability-sbtc false sorted-vaults))
                        ;; delete vault
                        (try! (contract-call? registry liquidation-update-vault-redistribution vault-id vault-bsd vault-sbtc true sorted-vaults))
                    )
                )
                (print {
                        liquidation-event: {
                            vault-id: vault-id,
                            accrued-vault-loan-bsd: accrued-vault-loan-bsd,
                            vault-collateral-sbtc: vault-collateral-sbtc,
                            stability-pool-aggregate-bsd: stability-pool-aggregate-bsd,
                            redistribution-amount-bsd: vault-bsd,
                            redistribution-amount-sbtc: vault-sbtc,
                            stability-amount-bsd: stability-bsd,
                            stability-amount-sbtc: stability-sbtc
                        }
                    }
                )
                (ok true)
            )
            ;; stability pool covers the debt, proceed with liquidation
            (begin 
                ;; burn debt amount from stability pool
                (try!  (contract-call? stability protocol-burn-bsd accrued-vault-loan-bsd bsd registry))

                ;; transfer collateral to stability pool
                (try! (as-contract (contract-call? sbtc transfer vault-collateral-sbtc tx-sender (contract-of stability) none)))

                (print {
                    liquidation-event: {
                        vault-id: vault-id,
                        accrued-vault-loan-bsd: accrued-vault-loan-bsd,
                        vault-collateral-sbtc: vault-collateral-sbtc,
                        stability-pool-aggregate-bsd: stability-pool-aggregate-bsd,
                        redistribution-amount-bsd: u0,
                        redistribution-amount-sbtc: u0,
                        stability-amount-bsd: accrued-vault-loan-bsd,
                        stability-amount-sbtc: vault-collateral-sbtc
                    }
                })

                ;; complete in registry
                (ok (try! (contract-call? registry liquidation-update-provider-distribution vault-id  accrued-vault-loan-bsd vault-collateral-sbtc true sorted-vaults)))
            )
        )
    )
)



;; Math functions
(define-read-only (div (x uint) (y uint))
  (/ (+ (* x ONE_FULL_UNIT) (/ y u2)) y))

(define-read-only (div-round-down (x uint) (y uint))
  (/ (* x ONE_FULL_UNIT) y)
)

(define-read-only (mul (x uint) (y uint))
  (/ (+ (* x y) (/ ONE_FULL_UNIT u2)) ONE_FULL_UNIT))

(define-read-only (div-to-fixed-precision (a uint) (decimals-a uint) (b-fixed uint))
  (if (> decimals-a PRECISION)
    (div (/ a (pow u10 (- decimals-a PRECISION))) b-fixed)
    (div (* a (pow u10 (- PRECISION decimals-a))) b-fixed)
  )
)

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