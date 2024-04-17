;; title: vault-manager

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Cons, Vars, & Maps ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;
;;;;;;;;;;;;;;
;;;; Cons ;;;;
;;;;;;;;;;;;;;
;;;;;;;;;;;;;;

;; Constant: min-collateral-individual-ratio
;; Description: Defines the minimum collateral ratio per vault to prevent liquidation (110%).
(define-constant min-collateral-individual-ratio u110)

;; Constant: min-collateral-global-ratio
;; Description: Defines the minimum total collateral ratio across all vaults to avoid Recovery Mode (150%).
(define-constant min-collateral-global-ratio u150)

;; Constant: borrowing-fee-rate
;; Description: Defines the fee percentage applied to borrowing operations (0.5%).
(define-constant redemption-fee-rate u5)

;; Constant: half-day
;; Description: Defines the longevity of half a day or 12 hours
(define-constant half-day u72)

;; Constant: full-day
;; Description: Defines the longevity of a day or 24 hours
(define-constant full-day u144)

(define-constant admin-address tx-sender)

;;;;;;;;;;;;;;
;;;;;;;;;;;;;;
;;;; Vars ;;;;
;;;;;;;;;;;;;;
;;;;;;;;;;;;;;

;; Var: active-vaults
;; Description: Tracks the total number of active users, created vaults, total collateral, and total debt.
;; - active-users: (list 1000 principal) - List of all active users.
;; - created-vaults: (uint) - Total number of vaults created.
;; - total-collateral: (uint) - Total collateral in sBTC.
;; - total-debt: (uint) - Total debt in USDB.
(define-data-var active-vaults 
    {
        active-users: (list 1000 principal),
        created-vaults: uint,
        total-collateral: uint, 
        total-debt: uint
    }
    {
        active-users: (list), 
        created-vaults: u0, 
        total-collateral: u0, 
        total-debt: u0
    }
)


;; Var: sBTC-to-USD-rate
;; Description: Stores the current sBTC to USD exchange rate.
(define-data-var sBTC-to-USD-rate uint u40000)

;; Testing variable modifier
(define-public (update-sBTC-to-USD-rate (new uint))
    (ok (var-set sBTC-to-USD-rate new))
)

;; Var: is-recovery-mode-active
;; Description: Indicates whether Recovery Mode is currently active.
(define-data-var is-recovery-mode-active bool false)

;; Var: oracle-address
;; Description: References the address of the oracle contract.
(define-data-var oracle-address principal tx-sender)

;; Var: redemption-fee
;; Description: Tracks the base rate for redemption fees and the last block height of redemption.
;; - base-rate: (uint) - The base rate for calculating redemption fees.
;; - last-redemption-height: (uint) - The last block height at which a redemption occurred.
(define-data-var redemption-fee {base-rate: uint, last-redemption-height: uint} {base-rate: u0, last-redemption-height: u0})

;; Var: is-system-shutdown
;; Description: Indicates whether the entire system has been shut down.
(define-data-var is-system-shutdown bool false)

;; @desc - (temporary) Principal that's used to temporarily hold a principal
(define-data-var helper-principal principal tx-sender)

(define-data-var collateral-from-liquidated-vault uint u0)

;;;;;;;;;;;;;;
;;;;;;;;;;;;;;
;;;; Maps ;;;;
;;;;;;;;;;;;;;
;;;;;;;;;;;;;;

;; Map: vault
;; Description: Records each vault's collateral, debt, and activity status by the owner's principal.
;; Key: user (principal)
;; Fields: 
;; - created-height: (uint) - Block height at which the vault was created.
;; - collateral: (uint) - Amount of collateral in sBTC.
;; - debt: (uint) - Amount of debt in USDB.
(define-map vault principal {created-height: uint, collateral: uint, debt: uint})


;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;
;;;; Public ;;;;
;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;
;; Function: create-vault
;; Description: Creates a new vault for the caller with specified collateral and debt.
;; Inputs:
;;   - collateral-amount (uint): The amount of collateral (sBTC) the user wants to deposit.
;;   - debt-amount (uint): The amount of debt (USDB) the user wants to take out against the collateral.
;; Operations:
;;   1. Validate the input amounts: Ensure that the collateral and debt amounts meet protocol requirements.
;;   2. Update the active vaults data: Increment the count of created vaults, 
;;      add the new collateral amount to the total collateral, and add the new debt amount to the total debt.
;;   3. Add the caller to the list of active users if not already present.
;;   4. Create and store the new vault entry in the vault map for the caller.
;;      This entry includes the block height at which the vault was created, 
;;      the collateral amount, debt amount, and the active status of the vault.
;;   5. Return a success response indicating the vault was created successfully.
(define-public (create-vault (collateral-amount uint) (debt-amount uint))
    (let 
        (
            ;; Store the user
            (user tx-sender)
            ;; Convert the vault's collateral into its USD equivalent using the sBTC to USD rate.
            (collateral-amount-in-usd (* collateral-amount (var-get sBTC-to-USD-rate)))
            ;; Calculate initial collateral ratio
            (collateral-ratio (if (> debt-amount u0) (/ (* collateral-amount-in-usd u100) debt-amount) u0))
            ;; Get the current active vaults
            (current-active-vaults (var-get active-vaults))
            ;; Get list of active users
            (current-active-users (get active-users current-active-vaults))
            ;; Get created vaults number
            (current-number-of-vaults (get created-vaults current-active-vaults))
            ;; Get the total collateral
            (current-global-collateral (get total-collateral current-active-vaults))
            ;; Get total debt
            (current-global-debt (get total-debt current-active-vaults))
            ;; New active users
            (new-active-users (unwrap! (as-max-len? (append current-active-users user) u1000) (err "err-unwrap")))
            ;; New vaults
            (new-vaults (+ current-number-of-vaults u1))
            ;; New total collateral
            (new-global-collateral (+ current-global-collateral collateral-amount))
            ;; New total debt
            (new-global-debt (+ current-global-debt debt-amount))
            ;; Total new collateral in usd
            (global-new-collateral-amount-in-usd (* new-global-collateral (var-get sBTC-to-USD-rate)))
            ;; Calculate global collateral ratio
            (new-global-collateral-ratio (if (> debt-amount u0) (/ (* global-new-collateral-amount-in-usd u100) new-global-debt) u0))
        )
        ;; Assert that collateral amount is higher than 0
        (asserts! (> collateral-amount-in-usd u0) (err "err-min-collateral"))
        ;; Assert that some debt is being minted
        (asserts! (> debt-amount u0) (err "err-mint-debt"))
        ;; Assert that the collateral ratio is met
        (asserts! (>= collateral-ratio min-collateral-individual-ratio) (err "err-min-individual-collateral-ratio"))
        ;; Assert that the global collateral ratio is met
        (asserts! (>= new-global-collateral-ratio min-collateral-global-ratio) (err "err-min-global-collateral-ratio"))
        ;; Check if there is no previous vault by the tx-sender
        (asserts! (is-none (map-get? vault user)) (err "err-vault"))
        
        ;; Set the new map for the user
        (map-set vault user {created-height: block-height, collateral: collateral-amount, debt: debt-amount}) 
        ;; Add the data to the active vaults var
        (var-set active-vaults {active-users: new-active-users, created-vaults: new-vaults, total-collateral: new-global-collateral, total-debt: new-global-debt})
        ;; Transfer the sbtc to the contract
        (unwrap! (contract-call? .s-testing transfer collateral-amount user .v-testing none) (err "err-transfer"))
        ;; Mint USDB to the user
        (unwrap! (as-contract (contract-call? .u-testing mint-usdb user debt-amount)) (err "err-mint"))
 
        (ok true)
    )
)

;; Function: mint-usdb-loan
;; Description: Mints a specific amount of USDB as a loan against the caller's vault's collateral.
;; Inputs: amount (uint) - Amount of USDB to mint.
;; Operations: Verify vault conditions, mint USDB, add debt to the vault, update total debt in active-vaults.
(define-public (mint-usdb-loan (debt-amount uint))
    (let 
        (
            (user tx-sender)
            ;; Retrieve the user's vault information
            (vault-information (unwrap! (map-get? vault user) (err "err-no-vault")))
            ;; Extract current vault's collateral
            (current-collateral (get collateral vault-information))
            ;; Extract current vault's debt
            (current-debt (get debt vault-information))
            ;; Calculate new debt for the vault
            (new-debt (+ current-debt debt-amount))
            ;; Convert the vault's collateral into its USD equivalent using the sBTC to USD rate.
            (collateral-amount-in-usd (* current-collateral (var-get sBTC-to-USD-rate)))
            ;; Calculate collateral ratio
            (collateral-ratio (if (> new-debt u0) (/ (* collateral-amount-in-usd u100) new-debt) u0))
            ;; Get the current active vaults
            (current-active-vaults (var-get active-vaults))
            ;; Get list of active users
            (current-active-users (get active-users current-active-vaults))
            ;; Get created vaults number
            (current-number-of-vaults (get created-vaults current-active-vaults))
            ;; Get the total collateral
            (current-global-collateral (get total-collateral current-active-vaults))
            ;; Get total debt
            (current-global-debt (get total-debt current-active-vaults))
            ;; New total debt
            (new-global-debt (+ current-global-debt debt-amount))
            ;; Total new collateral in usd
            (total-collateral-amount-in-usd (* current-global-collateral (var-get sBTC-to-USD-rate)))
            ;; Calculate global collateral ratio
            (new-global-collateral-ratio (/ (* total-collateral-amount-in-usd u100) new-global-debt))
        )
        ;; Assert that the individual vault's collateral ratio is met
        (asserts! (> collateral-ratio min-collateral-individual-ratio) (err "err-min-individual-collateral-ratio"))
        ;; Assert that the global collateral ratio is met
        (asserts! (>= new-global-collateral-ratio min-collateral-global-ratio) (err "err-min-global-collateral-ratio"))
        ;; Update the user's vault information with new debt
        (map-set vault user {created-height: (get created-height vault-information), collateral: current-collateral, debt: new-debt})
        ;; Update the active vaults' total debt
        (var-set active-vaults {active-users: (get active-users current-active-vaults), created-vaults: (get created-vaults current-active-vaults), total-collateral: current-global-collateral, total-debt: new-global-debt})
        ;; Mint USDB to the user
        (unwrap! (contract-call? .u-testing mint-usdb user debt-amount) (err "err-mint"))
        (ok true)
    )
)


;; Function: add-collateral
;; Description: Allows users to add more collateral to their vault.
;; Inputs: amount (uint) - Amount of sBTC to add.
;; Operations: Increase vault's collateral, update total collateral in active-vaults, ensure collateral ratio.
(define-public (add-collateral (collateral-amount uint))
    (let 
        (
            (user tx-sender)
            ;; Retrieve the user's vault information
            (vault-information (unwrap! (map-get? vault user) (err "err-no-vault")))
            ;; Extract current vault's collateral
            (current-collateral (get collateral vault-information))
            ;; Extract current vault's debt
            (current-debt (get debt vault-information))
            ;; Calculate new collateral amount
            (new-collateral (+ current-collateral collateral-amount))
            ;; Get the current active vaults
            (current-active-vaults (var-get active-vaults))
            ;; Get list of active users
            (current-active-users (get active-users current-active-vaults))
            ;; Get created vaults number
            (current-number-of-vaults (get created-vaults current-active-vaults))
            ;; Get the total collateral
            (current-global-collateral (get total-collateral current-active-vaults))
            ;; Get total debt
            (current-global-debt (get total-debt current-active-vaults))
            ;; Calculate new total collateral
            (new-global-collateral (+ current-global-collateral collateral-amount))
        )
        ;; Assert that the collateral amount is positive
        (asserts! (> collateral-amount u0) (err "err-invalid-amount"))
        ;; Update the user's vault information with new collateral
        (map-set vault user {created-height: (get created-height vault-information), collateral: new-collateral, debt: current-debt})
        ;; Update the active vaults' total collateral
        (var-set active-vaults {active-users: (get active-users current-active-vaults), created-vaults: (get created-vaults current-active-vaults), total-collateral: new-global-collateral, total-debt: current-global-debt})
        ;; Transfer the sBTC to the contract
        (unwrap! (contract-call? .s-testing transfer collateral-amount user .v-testing none) (err "err-transfer"))
        (ok true)
    )
)

;; Function: withdraw-collateral
;; Description: Withdraws collateral from the user's vault.
;; Inputs: amount (uint) - Amount of sBTC to withdraw.
;; Operations: Decrease vault's collateral, update total collateral in active-vaults, check collateral ratio.
(define-public (withdraw-collateral (collateral-amount uint))
    (let 
        (
            (user tx-sender)
            ;; Retrieve the user's vault information
            (vault-information (unwrap! (map-get? vault user) (err "err-no-vault")))
            ;; Extract current vault's collateral
            (current-collateral (get collateral vault-information))
            ;; Extract current vault's debt
            (current-debt (get debt vault-information))
            ;; Calculate new collateral amount
            (new-collateral (if (> collateral-amount current-collateral) u0 (- current-collateral collateral-amount)))
            ;; Convert the new collateral into its USD equivalent using the sBTC to USD rate
            (new-collateral-in-usd (if (> collateral-amount current-collateral) u0 (* new-collateral (var-get sBTC-to-USD-rate))))
            ;; Calculate collateral ratio
            (collateral-ratio (if (> current-debt u0) (/ (* new-collateral-in-usd u100) current-debt) u0))
            ;; Get the current active vaults
            (current-active-vaults (var-get active-vaults))
            ;; Get list of active users
            (current-active-users (get active-users current-active-vaults))
            ;; Get created vaults number
            (current-number-of-vaults (get created-vaults current-active-vaults))
            ;; Get the total collateral
            (current-global-collateral (get total-collateral current-active-vaults))
            ;; Get total debt
            (current-global-debt (get total-debt current-active-vaults))
            ;; Calculate new total collateral
            (new-global-collateral (if (> collateral-amount current-collateral) u0 (- current-global-collateral collateral-amount)))
            ;; Convert the new total collateral into USD
            (new-global-collateral-in-usd (* new-global-collateral (var-get sBTC-to-USD-rate)))
            ;; Calculate global collateral ratio
            (new-global-collateral-ratio (/ (* new-global-collateral-in-usd u100) current-global-debt))
        )
        ;; Assert that the withdrawal amount is positive and does not exceed the user's current collateral
        (asserts! (and (> collateral-amount u0) (<= collateral-amount current-collateral)) (err "err-invalid-amount"))
        ;; Assert that the individual vault's collateral ratio is met
        (asserts! (>= collateral-ratio min-collateral-individual-ratio) (err "err-min-individual-collateral-ratio"))
        ;; Assert that the global collateral ratio is met
        (asserts! (>= new-global-collateral-ratio min-collateral-global-ratio) (err "err-min-global-collateral-ratio"))
        ;; Update the user's vault information with new collateral
        (map-set vault user {created-height: (get created-height vault-information), collateral: new-collateral, debt: current-debt})
        ;; Update the active vaults' total collateral
        (var-set active-vaults {active-users: (get active-users current-active-vaults), created-vaults: (get created-vaults current-active-vaults), total-collateral: new-global-collateral, total-debt: current-global-debt})
        ;; Transfer the sBTC from the contract back to the user
        (unwrap! (contract-call? .s-testing transfer collateral-amount .v-testing user none) (err "err-transfer"))
        (ok true)
    )
)

;; Function: repay-usdb-loan
;; Description: Repays a portion or all of the USDB loan in the user's vault.
;; Inputs: amount (uint) - Amount of USDB to repay.
;; Operations: Reduce vault's debt, update total debt in active-vaults, release collateral if paid in full.
(define-public (repay-usdb-loan (repay-amount uint))
    (let 
        (
            (user tx-sender)
            ;; Retrieve the user's vault information
            (vault-information (unwrap! (map-get? vault user) (err "err-no-vault")))
            ;; Extract current vault's collateral
            (current-collateral (get collateral vault-information))
            ;; Extract current vault's debt
            (current-debt (get debt vault-information))
            ;; Determine if the whole debt is being repaid
            (is-full-repayment (is-eq repay-amount current-debt))
            ;; Calculate new debt amount
            (new-debt (if is-full-repayment u0 (if (> repay-amount current-debt) u0 (- current-debt repay-amount))))
            ;; Retrieve the current active vaults
            (current-active-vaults (var-get active-vaults))
            ;; Get list of active users
            (current-active-users (get active-users current-active-vaults))
            ;; Get created vaults number
            (current-number-of-vaults (get created-vaults current-active-vaults))
            ;; Get the total collateral
            (current-global-collateral (get total-collateral current-active-vaults))
            ;; Get total debt
            (current-global-debt (get total-debt current-active-vaults))
            ;; Calculate new total debt
            (new-global-debt (if (> repay-amount current-debt) u0 (- current-global-debt repay-amount)))
        )
        ;; Assert that the repayment amount is positive and does not exceed the user's current debt
        (asserts! (and (> repay-amount u0) (<= repay-amount current-debt)) (err "err-invalid-amount"))

        ;; Burn the repaid USDB
        (unwrap! (contract-call? .u-testing burn-usdb user repay-amount) (err "err-burn"))

        (var-set helper-principal user)

        ;; Handle full repayment and partial repayment separately
        (if is-full-repayment
            (begin
                ;; Return the collateral to the user and delete the vault entry for full repayment
                (unwrap! (contract-call? .s-testing transfer current-collateral .v-testing user none) (err "err-transfer"))
                (map-delete vault user)
                ;; Remove the user from the active-users list
                (var-set active-vaults {active-users: (filter is-not-removeable current-active-users), created-vaults: (- (get created-vaults current-active-vaults) u1), total-collateral: (- current-global-collateral current-collateral), total-debt: new-global-debt})
            )
            ;; Update the user's vault information with new debt for partial repayment and the global state
            (begin 
                (map-set vault user {created-height: (get created-height vault-information), collateral: current-collateral, debt: new-debt})
                (var-set active-vaults {active-users: current-active-users, created-vaults: (get created-vaults current-active-vaults), total-collateral: current-global-collateral, total-debt: new-global-debt})
            )
        )
        (ok true)
    )
)

(define-read-only (get-collateral-test-liquidate)
(var-get collateral-from-liquidated-vault)
)
;; Function: liquidate-vault
;; Description: Liquidates a vault that's below the minimum collateral ratio.
;; Inputs: vault-id (principal) - Identifier of the vault to be liquidated.
;; Operations: Check vault's health, transfer collateral to Stability Pool Providers, update vault and pool status.
(define-public (liquidate-vault (vault-id principal))
    (let
        (
            ;; Retrieve the user's vault information.
            (vault-information (unwrap! (map-get? vault vault-id) (err "err-no-vault")))
            ;; Extract the current collateral and debt from the vault.
            (current-collateral (get collateral vault-information))
            (current-debt (get debt vault-information))
            ;; Convert the vault's collateral into its USD equivalent using the current sBTC to USD rate.
            (collateral-amount-in-usd (* current-collateral (var-get sBTC-to-USD-rate)))
            ;; Calculate the individual collateral ratio of the vault.
            (individual-collateral-ratio (/ (* collateral-amount-in-usd u100) current-debt))
            ;; Check if the system is in recovery mode.
            (recovery-mode (var-get is-recovery-mode-active))
            ;; Retrieve the current state of active vaults.
            (current-active-vaults (var-get active-vaults))
            ;; Extract the list of active users and the number of created vaults.
            (current-active-users (get active-users current-active-vaults))
            (current-number-of-vaults (get created-vaults current-active-vaults))
            ;; Get the total value of collateral and debt in the system.
            (current-global-collateral (get total-collateral current-active-vaults))
            (current-global-debt (get total-debt current-active-vaults))
            ;; Calculate total global collateral in USD
            (current-global-collateral-in-usd (* current-global-collateral (var-get sBTC-to-USD-rate)))
            ;; Compute the global collateral ratio for the system.
            (global-collateral-ratio (/ (* current-global-collateral-in-usd u100) current-global-debt))
        )
        
        ;; Ensure the vault is eligible for liquidation based on its collateral ratio and system state.
        (asserts!
            (or 
                ;; If in recovery mode, check if the vault's collateral ratio is below the global ratio.
                (and recovery-mode (< individual-collateral-ratio min-collateral-global-ratio))
                ;; Otherwise, check if the collateral ratio is below the minimum individual threshold.
                (< individual-collateral-ratio min-collateral-individual-ratio)
            )
            (err "err-not-eligible-for-liquidation")
        )

        ;; Burn the equivalent amount of USDB to the vault's debt from the Stability Pool.
        (unwrap! (contract-call? .sp-testing burn-usdb current-debt) (err "err-burn-usdb"))

        (var-set collateral-from-liquidated-vault current-collateral)
        ;; Distribute the vault's collateral among Stability Pool providers based on their share.
        (map distribute-collateral (contract-call? .sp-testing get-all-current-users-share))
        ;; Delete the liquidated vault from the vault map.
        (map-delete vault vault-id)
        ;; Set a helper variable for further processing.
        (var-set helper-principal vault-id)
        ;; Update the active vaults by removing the liquidated vault and adjusting the totals.
        (var-set active-vaults 
            {
                ;; Update the list of active users.
                active-users: (filter is-not-removeable current-active-users),
                ;; Decrease the count of created vaults.  
                created-vaults: (- current-number-of-vaults u1),
                ;; Adjust the total collateral.               
                total-collateral: (- current-global-collateral current-collateral), 
                ;; Adjust the total debt.
                total-debt: (- current-global-debt current-debt)                  
            }
        )
        ;; Return success after successful execution of the function.
        (ok true) 
    )
)

;; Helper function for distributing collateral to Stability Pool providers
(define-private (distribute-collateral (user-share {user: principal, share: uint}))
    (let 
        (
            (user (get user user-share))
            (share (get share user-share))
            (total-collateral (var-get collateral-from-liquidated-vault))
            ;; Calculate the amount of collateral to distribute to the user
            (collateral-to-distribute (/ (* total-collateral share) u100))
        )

        (unwrap! (contract-call? .sp-testing update-users-map collateral-to-distribute user) (err "err-update-maps"))

        ;; Transfer collateral to the user
        (ok (unwrap! (contract-call? .s-testing transfer collateral-to-distribute .v-testing user none) (err "err-transfer-collateral")))
        
    )
)

;; @desc - Helper function for removing a specific principal from the providers
(define-private (is-not-removeable (principal principal))
  (not (is-eq principal (var-get helper-principal)))
)


;; Function: start-redemption
;; Description: Initiates the redemption process for USDB into sBTC.
;; Inputs: amount (uint) - Amount of USDB to redeem, vault (principal) - Vault beeing redeemed.
;; Operations: Calculate sBTC equivalent, update vaults' collateral and debt, charge redemption fee.
;; Will the user be able to redeem the whole vault? And if he does, will he get all the vaults collateral or only the 100% and the other % where does it go to?
(define-public (start-redemption (usdb-amount uint) (vault-owner principal))
    (let 
        (
            ;; Calculate sBTC equivalent for the USDB amount
            (sBTC-equivalent (/ usdb-amount (var-get sBTC-to-USD-rate)))
            ;; Calculate the redemption fee
            (new-redemption-fee (unwrap! (calculate-redemption-fee sBTC-equivalent) (err "err-calculate-fee")))
            ;; Net sBTC amount after fee deduction
            (net-sBTC-amount (- sBTC-equivalent new-redemption-fee))
            ;; Retrieve the user's vault information
            (vault-information (unwrap! (map-get? vault vault-owner) (err "err-no-vault")))
            ;; Extract current vault's collateral
            (current-collateral (get collateral vault-information))
            ;; Extract current vault's debt
            (current-debt (get debt vault-information))
            ;; Calculate new debt amount
            (new-debt (if (< usdb-amount current-debt) (- current-debt usdb-amount) u1))
            ;; New collateral after redemption
            (new-collateral (- current-collateral sBTC-equivalent))
            ;; Convert the vault's collateral into its USD equivalent using the sBTC to USD rate
            (collateral-amount-in-usd (* current-collateral (var-get sBTC-to-USD-rate)))
            ;; Calculate new collateral ratio
            (collateral-ratio (/ (* collateral-amount-in-usd u100) new-debt))
            ;; Retrieve the current active vaults
            (current-active-vaults (var-get active-vaults))
            ;; Get list of active users
            (current-active-users (get active-users current-active-vaults))
            ;; Get created vaults number
            (current-number-of-vaults (get created-vaults current-active-vaults))
            ;; Get the total collateral
            (current-global-collateral (get total-collateral current-active-vaults))
            ;; Get total debt
            (current-global-debt (get total-debt current-active-vaults))
            ;; Calculate new total debt
            (new-global-debt (if (< usdb-amount current-debt) (- current-global-debt usdb-amount) u1))
            ;; New global collateral after redemption
            (new-global-collateral (- current-global-collateral sBTC-equivalent))
        )

        ;; Check if the USDB amount is smaller than the current debt
        (asserts! (< usdb-amount current-debt) (err "err-invalid-amount"))

        ;; Check if the USDB amount is greater than zero
        (asserts! (> usdb-amount u0) (err "err-usdb-amount-zero"))

        ;; Check if the USDB amount does not exceed the current debt
        (asserts! (<= usdb-amount current-debt) (err "err-usdb-amount-exceeds-debt"))

        ;; Check if the net sBTC amount is greater than zero
        (asserts! (> net-sBTC-amount u0) (err "err-net-sbtc-amount-zero"))

        ;; Check if the net sBTC amount does not exceed the current collateral
        (asserts! (<= net-sBTC-amount current-collateral) (err "err-net-sbtc-amount-exceeds-collateral"))

        ;; Update the vault with new collateral and debt values
        (map-set vault vault-owner {created-height: (get created-height vault-information), collateral: new-collateral, debt: new-debt})

        ;; Update global state of total collateral and debt
        (var-set active-vaults {active-users: (get active-users current-active-vaults), created-vaults: (get created-vaults current-active-vaults), total-collateral: new-global-collateral, total-debt: new-global-debt})

        ;; Burn the redeemed USDB
        (unwrap! (contract-call? .u-testing burn-usdb tx-sender usdb-amount) (err "err-burn"))

        ;; Transfer the net sBTC amount to the user initiating the redemption
        (unwrap! (contract-call? .s-testing transfer net-sBTC-amount .v-testing tx-sender none) (err "err-transfer"))

        ;; To whom are we sending the redemption fee?
        (unwrap! (contract-call? .s-testing transfer new-redemption-fee .v-testing 'STNHKEPYEPJ8ET55ZZ0M5A34J0R3N5FM2CMMMAZ6 none) (err "err-transfer"))

        (ok true)
    )
)

;; Function: activate-recovery-mode
;; Description: Activates the recovery mode for the system.
;; Inputs: None.
;; Operations: Change the state of the 'is-recovery-mode-active' variable to 'true' and be able to flip it back. This function should be restricted to authorized users
(define-public (activate-recovery-mode)
    (begin
        (asserts! (is-eq tx-sender admin-address) (err "err-not-authorized"))
        (let 
            ((current-state (var-get is-recovery-mode-active)))
            (var-set is-recovery-mode-active (not current-state))
            (ok (not current-state))
        )
    )
)

;;;;;;;;;;;;;;
;;;;;;;;;;;;;;
;;;; Read ;;;;
;;;;;;;;;;;;;;
;;;;;;;;;;;;;;

;; Function: get-usdb-loan-available
;; Description: Retrieves the maximum USDB loan amount available for a given vault based on its collateral.
;; Inputs: vault-id (principal) - Identifier of the vault.
;; Operations: Calculate and return the max loan amount considering the collateral and current rates.
(define-read-only (get-usdb-loan-available (vault-owner principal))
    (let 
        (
            ;; Retrieve the vault information from the 'vault' map using the given vault-owner.
            (vault-information (map-get? vault vault-owner))
            
            ;; Extract the total collateral from the vault information. If not found, return an error.
            (vault-total-collateral (unwrap! (get collateral vault-information) (err "err-unwrap")))
            
            ;; Extract the total debt from the vault information. If not found, return an error.
            (vault-total-debt (unwrap! (get debt vault-information) (err "err-unwrap")))
            
            ;; Calculate the USD value of the vault's collateral using the latest sBTC to USD rate from the oracle.
            (vault-collateral-in-usd (* vault-total-collateral (var-get sBTC-to-USD-rate)))
            
            ;; Calculate the maximum debt allowed by dividing the collateral value in USD by the minimum collateral ratio.
            (max-debt-allowed (/ (* vault-collateral-in-usd u100) min-collateral-individual-ratio))
        ) 
        ;; Check if current debt is greater than max allowed debt
        (if (>= vault-total-debt max-debt-allowed)
            ;; If current debt exceeds or equals max allowed debt, no loan is available
            (ok u0)
            ;; Else, determine the available loan amount
            (ok (- max-debt-allowed vault-total-debt))
        )
    )
)

;; Function: get-recovery-mode-status
;; Description: Returns recovery mode
;; Inputs: None.
;; Operations: Fetch and return recovery mode status
(define-read-only (get-recovery-mode-status)
    (var-get is-recovery-mode-active)
)


;; Function: get-vaults
;; Description: Returns a list of all active vaults.
;; Inputs: None.
;; Operations: Fetch and return all vaults from the vault map that are marked active.
(define-read-only (get-vaults)
    (var-get active-vaults)
)

;; Function: get-vault
;; Description: Retrieves details of a specific vault.
;; Inputs: vault-id (principal) - Identifier of the vault.
;; Operations: Fetch and return details of the specified vault from the vault map.
(define-read-only (get-vault (vault-owner principal))
    (map-get? vault vault-owner)
)

;; Function: get-current-redemption-fee
;; Description: Retrieves details of the current fee
;; Operations: Fetch and return details of the redemption fee
(define-read-only (get-redemption-fee)
    (var-get redemption-fee)
)

;; Function: calculate-collateral-ratio
;; Description: Calculates the current collateral ratio of a specific vault.
;; Inputs: vault-id (principal) - Identifier of the vault.
;; Operations: Retrieve vault's collateral and debt, use current sBTC to USD rate, compute and return the collateral ratio as a percentage.
(define-read-only (calculate-collateral-ratio (vault-id principal))
    (let 
        (
            ;; Retrieve the vault's information from the 'vault' map using the vault-id.
            (vault-information (map-get? vault vault-id))
            
            ;; Extract the total amount of collateral from the vault information.
            ;; If the vault information is not found, return an error.
            (vault-total-collateral (unwrap! (get collateral vault-information) (err "Vault not found")))
            
            ;; Extract the total amount of debt from the vault information.
            ;; If the vault information is not found, return an error.
            (vault-total-debt (unwrap! (get debt vault-information) (err "Vault not found")))
            
            ;; Convert the vault's collateral into its USD equivalent using the sBTC to USD rate.
            (vault-collateral-in-usd (* vault-total-collateral (var-get sBTC-to-USD-rate)))
        ) 
        ;; Calculate the collateral ratio by dividing the collateral in USD by the total debt.
        ;; Multiply by 100 to get the percentage representation of the ratio.
        (ok 
            (if 
                (> vault-total-debt u0) ;; Ensure that the debt is not zero to avoid division by zero.
                (/ (* vault-collateral-in-usd u100) vault-total-debt)
                u0
            )
        )
    )
)

;; Function: calculate-global-collateral-ratio
;; Description: Computes the overall collateral ratio for all active vaults in the system.
;; Inputs: None.
;; Operations: Summarize total collateral and total debt from all active vaults, use current sBTC to USD rate, calculate and return the global collateral ratio as a percentage.
(define-read-only (calculate-global-collateral-ratio)
    (let 
        (
            ;; Retrieve the active vaults information.
            (active-vaults-info (var-get active-vaults))
            
            ;; Extract the total collateral and total debt from the active vaults information.
            (total-collateral (get total-collateral active-vaults-info))
            (total-debt (get total-debt active-vaults-info))
            
            ;; Convert the total collateral into its USD equivalent using the sBTC to USD rate.
            (total-collateral-in-usd (* total-collateral (var-get sBTC-to-USD-rate)))
        ) 
        ;; Calculate the global collateral ratio.
        (ok 
            (if 
                (> total-debt u0) ;; Ensure that the total debt is not zero to avoid division by zero.
                (/ (* total-collateral-in-usd u100) total-debt)
                u0 ;; Return zero if total debt is zero.
            )
        )
    )
)

;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;
;;;; Private ;;;;
;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;


;; Function: calculate-redemption-fee
(define-private (calculate-redemption-fee (sBTC-drawn uint))
    (let 
        (
            ;; Retrieve the current redemption fee info
            (redemption-info (var-get redemption-fee))
            ;; Extract the base rate and the last redemption height
            (current-base-rate (get base-rate redemption-info))
            (last-redemption-height (get last-redemption-height redemption-info))
            ;; Calculate the number of blocks passed since the last redemption
            (blocks-passed (- block-height last-redemption-height))
            ;; .5% of fixed fee
            (additional-fee-rate redemption-fee-rate)
            ;; Calculate the new base rate
            (new-base-rate (+ current-base-rate additional-fee-rate))
            ;; Calculate the Fee in sBTC
            (fee (* (+ current-base-rate additional-fee-rate) sBTC-drawn))
            (final-fee (/ fee u100))
        )

        ;; Check if more than half-day has passed
        (if (>= blocks-passed half-day)
            (begin
                ;; Check if a full day (144 blocks) has passed
                (if (>= blocks-passed full-day)
                    (begin
                        ;; Update the base rate and last redemption height for decay, divide by 4
                        (var-set redemption-fee {base-rate: (/ current-base-rate u4), last-redemption-height: (+ last-redemption-height full-day)})
                    )
                    (begin
                        ;; Update the base rate and last redemption height for decay, divide by 2
                        (var-set redemption-fee {base-rate: (/ current-base-rate u2), last-redemption-height: (+ last-redemption-height half-day)})
                    )
                )
                ;; Recursively call calculate-redemption-fee again
                (calculate-redemption-fee-2 sBTC-drawn)
            )
            (begin
                ;; Update the base rate and last redemption height variables
                (var-set redemption-fee {base-rate: new-base-rate, last-redemption-height: block-height})
                ;; Return the calculated fee
                (ok final-fee)
            )
        )
    )
)


;; Function: calculate-redemption-fee
(define-private (calculate-redemption-fee-2 (sBTC-drawn uint))
    (let 
        (
            ;; Retrieve the current redemption fee info
            (redemption-info (var-get redemption-fee))
            ;; Extract the base rate and the last redemption height
            (current-base-rate (get base-rate redemption-info))
            (last-redemption-height (get last-redemption-height redemption-info))
            ;; Calculate the number of blocks passed since the last redemption
            (blocks-passed (- block-height last-redemption-height))
            ;; .5% of fixed fee
            (additional-fee-rate redemption-fee-rate)
            ;; Calculate the new base rate
            (new-base-rate (+ current-base-rate additional-fee-rate))
            ;; Calculate the Fee in sBTC
            (fee (* (+ current-base-rate additional-fee-rate) sBTC-drawn))
            (final-fee (/ fee u100))
        )

        ;; Check if more than half-day has passed
        (if (>= blocks-passed half-day)
            (begin
                ;; Check if a full day (144 blocks) has passed
                (if (>= blocks-passed full-day)
                    (begin
                        ;; Update the base rate and last redemption height for decay, divide by 4
                        (var-set redemption-fee {base-rate: (/ current-base-rate u4), last-redemption-height: (+ last-redemption-height full-day)})
                    )
                    (begin
                        ;; Update the base rate and last redemption height for decay, divide by 2
                        (var-set redemption-fee {base-rate: (/ current-base-rate u2), last-redemption-height: (+ last-redemption-height half-day)})
                    )
                )
                ;; Recursively call calculate-redemption-fee again
                (calculate-redemption-fee-3 sBTC-drawn)
            )
            (begin
                ;; Update the base rate and last redemption height variables
                (var-set redemption-fee {base-rate: new-base-rate, last-redemption-height: block-height})
                ;; Return the calculated fee
                (ok final-fee)
            )
        )
    )
)

;; Function: calculate-redemption-fee
(define-private (calculate-redemption-fee-3 (sBTC-drawn uint))
    (let 
        (
            ;; Retrieve the current redemption fee info
            (redemption-info (var-get redemption-fee))
            ;; Extract the base rate and the last redemption height
            (current-base-rate (get base-rate redemption-info))
            (last-redemption-height (get last-redemption-height redemption-info))
            ;; Calculate the number of blocks passed since the last redemption
            (blocks-passed (- block-height last-redemption-height))
            ;; .5% of fixed fee
            (additional-fee-rate redemption-fee-rate)
            ;; Calculate the new base rate
            (new-base-rate (+ current-base-rate additional-fee-rate))
            ;; Calculate the Fee in sBTC
            (fee (* (+ current-base-rate additional-fee-rate) sBTC-drawn))
            (final-fee (/ fee u100))
        )

        ;; Check if more than half-day has passed
        (if (>= blocks-passed half-day)
            (begin
                ;; Check if a full day (144 blocks) has passed
                (if (>= blocks-passed full-day)
                    (begin
                        ;; Update the base rate and last redemption height for decay, divide by 4
                        (var-set redemption-fee {base-rate: (/ current-base-rate u4), last-redemption-height: (+ last-redemption-height full-day)})
                    )
                    (begin
                        ;; Update the base rate and last redemption height for decay, divide by 2
                        (var-set redemption-fee {base-rate: (/ current-base-rate u2), last-redemption-height: (+ last-redemption-height half-day)})
                    )
                )
                ;; Recursively call calculate-redemption-fee again
                (calculate-redemption-fee-4 sBTC-drawn)
            )
            (begin
                ;; Update the base rate and last redemption height variables
                (var-set redemption-fee {base-rate: new-base-rate, last-redemption-height: block-height})
                ;; Return the calculated fee
                (ok final-fee)
            )
        )
    )
)

;; Function: calculate-redemption-fee
(define-private (calculate-redemption-fee-4 (sBTC-drawn uint))
    (let 
        (
            ;; Retrieve the current redemption fee info
            (redemption-info (var-get redemption-fee))
            ;; Extract the base rate and the last redemption height
            (current-base-rate (get base-rate redemption-info))
            (last-redemption-height (get last-redemption-height redemption-info))
            ;; Calculate the number of blocks passed since the last redemption
            (blocks-passed (- block-height last-redemption-height))
            ;; .5% of fixed fee
            (additional-fee-rate redemption-fee-rate)
            ;; Calculate the new base rate
            (new-base-rate (+ current-base-rate additional-fee-rate))
            ;; Calculate the Fee in sBTC
            (fee (* (+ current-base-rate additional-fee-rate) sBTC-drawn))
            (final-fee (/ fee u100))
        )

        ;; Check if more than half-day has passed
        (if (>= blocks-passed half-day)
            (begin
                ;; Check if a full day (144 blocks) has passed
                (if (>= blocks-passed full-day)
                    (begin
                        ;; Update the base rate and last redemption height for decay, divide by 4
                        (var-set redemption-fee {base-rate: (/ current-base-rate u4), last-redemption-height: (+ last-redemption-height full-day)})
                    )
                    (begin
                        ;; Update the base rate and last redemption height for decay, divide by 2
                        (var-set redemption-fee {base-rate: (/ current-base-rate u2), last-redemption-height: (+ last-redemption-height half-day)})
                    )
                )
                ;; Recursively call calculate-redemption-fee again
                (calculate-redemption-fee-5 sBTC-drawn)
            )
            (begin
                ;; Update the base rate and last redemption height variables
                (var-set redemption-fee {base-rate: new-base-rate, last-redemption-height: block-height})
                ;; Return the calculated fee
                (ok final-fee)
            )
        )
    )
)

;; Function: calculate-redemption-fee
(define-private (calculate-redemption-fee-5 (sBTC-drawn uint))
    (let 
        (
            ;; Retrieve the current redemption fee info
            (redemption-info (var-get redemption-fee))
            ;; Extract the base rate and the last redemption height
            (current-base-rate (get base-rate redemption-info))
            (last-redemption-height (get last-redemption-height redemption-info))
            ;; Calculate the number of blocks passed since the last redemption
            (blocks-passed (- block-height last-redemption-height))
            ;; .5% of fixed fee
            (additional-fee-rate redemption-fee-rate)
            ;; Calculate the new base rate
            (new-base-rate (+ current-base-rate additional-fee-rate))
            ;; Calculate the Fee in sBTC
            (fee (* (+ current-base-rate additional-fee-rate) sBTC-drawn))
            (final-fee (/ fee u100))
        )
        (var-set redemption-fee {base-rate: new-base-rate, last-redemption-height: block-height})
        (ok final-fee)
    )
)




