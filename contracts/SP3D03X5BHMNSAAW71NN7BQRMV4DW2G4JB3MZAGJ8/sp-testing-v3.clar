;; title: stability-pool
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

;;;;;;;;;;;;;;
;;;;;;;;;;;;;;
;;;; Vars ;;;;
;;;;;;;;;;;;;;
;;;;;;;;;;;;;;

;; Var: pool
;; Description: Acts as a state keeper for the total Stability Pool's current status.
;; - pool-total-USDB: (uint) - Total amount of USDB staked in the pool.
;; - pool-total-providers: (list 1000 principal) - List of all users who have provided to the pool.

(define-data-var pool {pool-total-USDB: uint, pool-total-providers: (list 1000 principal)}
  {pool-total-USDB: u0, pool-total-providers: (list)}
)

;; @desc - (temporary) Principal that's used to temporarily hold a principal
(define-data-var helper-principal principal tx-sender)

;; @desc - (temporary) Uint that's used to temporarily hold a amount-to-burn
(define-data-var amount-to-burn-helper uint u0)

;;;;;;;;;;;;;;
;;;;;;;;;;;;;;
;;;; Maps ;;;;
;;;;;;;;;;;;;;
;;;;;;;;;;;;;;

;; Map: provider
;; Description: Associates a principal with their current USDB deposits in the Stability Pool.
;; Key: user (principal)
;; Fields: 
;; - created: (uint) - Block height at which the provider's first contribution was recorded.
;; - usdb-staked: (uint) - Amount of USDB the provider has staked.
(define-map provider principal {usdb-staked: uint})

;; Map: provider-rewards
;; Description: Tracks all the rewards a provider has received from providing stability.
;; Keys: user (principal)
;; Fields: 
;; - list 10000 {reward-height: uint, reward-amount: uint}
(define-map provider-rewards principal {rewards: (list 10000 { reward-height: uint, reward-amount: uint })})

;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;
;;;; Public ;;;;
;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;

;; Function: deposit-usdb
;; Description: Allows users to deposit USDB into the Stability Pool.
;; Inputs: usdb-amount (uint) - The amount of USDB to deposit.
;; Operations:
;;   1. Validate the deposit amount: Ensure that the user has sufficient balance.
;;   2. Transfer USDB from the user's account to the Stability Pool's contract.
;;   3. Update the pool's total USDB and provider's staked USDB in the pool map.
;;   4. Return a success response indicating the deposit was successful.
(define-public (deposit-usdb (usdb-amount uint))
    (let 
        (
            ;; The principal of the user making the deposit
            (user tx-sender)
            ;; Retrieve the current pool information
            (current-pool (var-get pool))
            ;; Retrieve the user's current staked amount in the pool
            (provider-info (default-to { usdb-staked: u0} (map-get? provider user)))
        )
    
        ;; Check if the user has enough USDB to deposit
        (asserts! (>= (unwrap! (contract-call? .u-testing-v3 get-balance user) (err "err-insufficient-balance")) usdb-amount) (err "err-insufficient-balance"))

        ;; Transfer USDB from the user's account to the Stability Pool's contract
        (unwrap! (contract-call? .u-testing-v3 transfer usdb-amount user (as-contract tx-sender) none) (err "err-transfer"))

        ;; Update the pool's total USDB
        (var-set pool 
            {
                pool-total-USDB: (+ usdb-amount (get pool-total-USDB current-pool)), 
                pool-total-providers: 
                    (if (is-none (map-get? provider user))
                        ;; Add the user to the pool-total-providers list if not already present
                        (unwrap! (as-max-len? (append (get pool-total-providers current-pool) user) u1000) (err "err-unwrap"))
                        ;; If already present, no change
                        (get pool-total-providers current-pool)
                )
            }
        )

        ;; Update the provider's staked USDB in the provider map
        (map-set provider 
            user
            {usdb-staked: (+ usdb-amount (get usdb-staked provider-info))}
        )

        ;; Return a success response indicating the deposit was successful
        (ok usdb-amount)
    )
)

;; Function: withdraw-usdb
;; Description: Allows users to withdraw USDB from the Stability Pool.
;; Inputs: usdb-amount (uint) - The amount of USDB to withdraw.
;; Operations:
;;   1. Validate the withdrawal amount: Ensure that the USDB amount does not exceed the user's staked amount.
;;   2. Transfer USDB from the Stability Pool's contract to the user's account.
;;   3. Update the pool's total USDB and provider's staked USDB in the pool map.
;;   4. Return a success response indicating the withdrawal was successful.

(define-public (withdraw-usdb (usdb-amount uint))
    (let 
        (
            (user tx-sender)
            (current-pool (var-get pool))
            (provider-info (default-to {usdb-staked: u0} (map-get? provider user)))
            (new-staked-amount 
                (if (> (get usdb-staked provider-info) usdb-amount) 
                    (- (get usdb-staked provider-info) usdb-amount) u0
                )
            )
        )
        
        (asserts! (>= (get usdb-staked provider-info) usdb-amount) (err "err-insufficient-balance"))
        (unwrap! (contract-call? .u-testing-v3 transfer usdb-amount (as-contract tx-sender) user none) (err "err-transfer"))

        ;; Update the provider map based on the new staked amount
        (if (is-eq new-staked-amount u0)
            ;; If new staked amount is zero, remove user from the provider list
            (map-delete provider user)
            ;; Otherwise, update the provider map
            (map-set provider user {usdb-staked: new-staked-amount})
        )

        ;; temporary var set to help remove param principal
        (var-set helper-principal user)

        ;; Update the pool's total USDB and possibly the pool-total-providers list
        (var-set pool 
            {
                pool-total-USDB: (- (get pool-total-USDB current-pool) usdb-amount), 
                pool-total-providers: 
                    (if (is-eq new-staked-amount u0)
                        ;; Remove the user from the pool-total-providers list if their new staked amount is zero
                        (filter is-not-removeable (get pool-total-providers current-pool))
                        ;; If user still has some staked amount, keep the list as is
                        (get pool-total-providers current-pool)
                    )
            }    
        )
        (ok usdb-amount)
    )
)


;; Function: burn-usdb
;; Description: Helper call to execute the burning of the usdb by the Stability Pool
;; Inputs: amount-to-burn (uint) - The amount of USDB to burn.
;; Operations:
;;   1. Update the map for each provider, proportionally by their share.
;;   2. Update the global pool state.
;;   3. Burn the USDB
(define-public (burn-usdb (amount-to-burn uint))
    (let 
        (
            ;; Retrieve the current state of the Stability Pool.
            (current-pool-info (var-get pool))
            ;; Extract the total amount of USDB currently in the pool.
            (current-usdb (get pool-total-USDB current-pool-info))
            ;; Get the list of providers currently participating in the pool.
            (current-providers (get pool-total-providers current-pool-info))
            ;; Calculate the share of each user in the Stability Pool.
            (current-user-share (get-all-current-users-share))
        )

        (asserts! (> current-usdb amount-to-burn) (err "err-can-not-liquidate-vault"))

        ;; Temporarily store the amount to burn for use in the substract-USDB function.
        (var-set amount-to-burn-helper amount-to-burn)
        ;; Reduce the USDB staked by each provider, proportionally based on their share in the pool.
        (map substract-USDB current-user-share)
        ;; Update the pool's total USDB by subtracting the amount burned.
        (var-set pool {pool-total-USDB: (- current-usdb amount-to-burn), pool-total-providers: current-providers})
        ;; Execute the burning of USDB from the Stability Pool's contract, equivalent to the specified amount.
        (ok (unwrap! (contract-call? .u-testing-v3 burn-usdb .sp-testing-v3 amount-to-burn) (err "err-burn-usdb-stability")))
    )
)

;; Function: update-users-map 
;; Description: Helper call to execute the map updates
;; Inputs: collateral-to-distribute (uint) - The amount of Collateral to transfer. user (principal) - The user to send collateral to
;; Operations:
;;   1. Update the map for the rewards per user.
(define-public (update-users-map (collateral-to-distribute uint) (user principal))
    (let 
        (
            ;; Retrieve the existing list of rewards for the given user.
            ;; If the user does not have any previous rewards, initialize with an empty list.
            (list-of-rewards-by-user (default-to (list) (get rewards (map-get? provider-rewards user))))
            
        ) 

        (asserts! (is-eq contract-caller .v-testing-v3) (err "err-not-authorized"))

        ;; Update the provider-rewards map for the user.
        (ok (map-set provider-rewards user {rewards: (unwrap! (as-max-len? (append list-of-rewards-by-user {reward-height: block-height, reward-amount: collateral-to-distribute}) u10000) (err "err-unwrap-list"))}))
    )
)

;; Helper function for subtracting USDB from Stability Pool providers
(define-private (substract-USDB (user-share {user: principal, share: uint}))
    (let 
        (
            ;; Extract the 'user' and 'share' from the input tuple 'user-share'
            (user (get user user-share))
            (share (get share user-share))
            ;; Calculate the amount of USDB to subtract from the user based on their share
            ;; The amount to be burned (stored in a helper variable) is distributed proportionally to the user's share
            (usdb-to-substract (/ (* (var-get amount-to-burn-helper) share) u100))
            ;; Retrieve the current user's information from the 'provider' map
            (current-user-info (map-get? provider user))
            ;; Unwrap the current user's staked USDB amount; if not found, raise an error
            (current-user-USDB (unwrap! (get usdb-staked current-user-info) (err "err-unwrap-current-usdb")))
            ;; Calculate the user's final USDB balance after subtraction
            (final-USDB (- current-user-USDB usdb-to-substract))
        )
        ;; Update the user's USDB balance in the 'provider' map
        ;; If the final USDB balance is zero, delete the user's entry from the map
        ;; Otherwise, update the user's staked USDB amount
        (ok (if (is-eq final-USDB u0) 
                (map-delete provider user) 
                (map-set provider user {usdb-staked: final-USDB})
            )
        )   
    )
)

;;;;;;;;;;;;;;
;;;;;;;;;;;;;;
;;;; Read ;;;;
;;;;;;;;;;;;;;
;;;;;;;;;;;;;;

;; Function: get-pool-info
;; Description: Fetches the current status of the Stability Pool.
;; Inputs: None.
(define-read-only (get-pool-info) 
    (var-get pool)
)

;; Function: get-provider-info
;; Description: Fetches a provider's current status and contributions to the Stability Pool.
;; Inputs: user (principal) - The provider whose information is being requested.
(define-read-only (get-provider-info (provider-id principal))
    (map-get? provider provider-id)
)

;; Function: get-provider-rewards
;; Description: Fetches a running list of all the rewards a provider has received for contributing to the Stability Pool.
;; Inputs: user (principal) - The provider whose reward history is being requested.
(define-read-only (get-provider-rewards (provider-id principal))
    (map-get? provider-rewards provider-id)
)

;; Function: get-user-current-share
;; Description: Calculates a user's current share
;; Inputs: user (principal)
(define-read-only (get-user-current-share (user principal))
    (calculate-user-share user)
)

;; Function: get-all-current-users-share
;; Description: Calculates a user's current share
;; Inputs: user (principal)
(define-read-only (get-all-current-users-share)
    (calculate-all-users-shares)
)

;;;;;;;;;;;;;;;;;
;;;;;;;;;;;::;;;;
;;;; Private ;;;;
;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;

;; Function: calculate-user-share
;; Description: Calculates the share of the USDB staked by a user against the total USDB in the pool.
;; Inputs: user (principal) - The user whose share is being calculated.
(define-private (calculate-user-share (user principal))
    (let 
        (
            ;; Retrieve the user's current staked amount in the pool
            (provider-info (default-to {usdb-staked: u0} (map-get? provider user)))
            ;; Retrieve the current pool information
            (current-pool (var-get pool))
            ;; Total USDB staked in the pool
            (total-staked-usdb (get pool-total-USDB current-pool))
            ;; User's staked USDB amount
            (user-staked-usdb (get usdb-staked provider-info))
        )
        ;; Calculate the user's share as a percentage
        (if (and (> total-staked-usdb u0) (> user-staked-usdb u0))
            ;; If total staked USDB is greater than zero, calculate the share
            {user: user, share:(/ (* user-staked-usdb u100) total-staked-usdb)}
            ;; If total staked USDB is zero, return 0 (to avoid division by zero)
            {user: user, share:u0}
        )        
    )
)

;; Function: calculate-all-users-shares
;; Description: Iterates over the list of providers and calculates each user's share of USDB staked in the pool.
(define-private (calculate-all-users-shares)
    (let
        (
            ;; Retrieve the current pool information
            (current-pool (var-get pool))
            ;; List of all providers
            (all-providers (get pool-total-providers current-pool))
        )
        ;; Using map to iterate over the list of providers and calculate each user's share
        (map calculate-user-share all-providers)
    )
)

;; @desc - Helper function for removing a specific principal from the providers
(define-private (is-not-removeable (principal principal))
  (not (is-eq principal (var-get helper-principal)))
)