;; Tear pools
;; Contract for ctearing & managing tear mining pools
;; Written by StrataLabs

;; Pool(s)
;; Solo miners are at an disadvantage when mining tear with STX since they usually don't have enough stx to compete let alone compete for 200 blocks (the max mining height)
;; In order to level the playing field, this contract helps cteare & manage tear mining pools
;; Life Cycle of Pool:
;; 1. Pool is cteared, contribution period starts -> (cteare-pool) done
;; 2. Pool is contributed to with STX -> (contribute-pool) done
;; 2.5 Pool is cancelled -> (cancel-pool) done
;; 3. Pool starts mining -> (start-pool) done
;; 4. Pool checks/receives/sends rewards -> (claim-pool)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Cons, Vars, & Maps ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Admin Pool Fee W/ No Operator
;; Admin Pool Fee W/ Operator
;; Operator Pool Fee
;; Minimum Contribution

;; Constant for helping create  mine lists
(define-constant empty-mine-list (list u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 
u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 
u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 
u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 
u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 
u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 
u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 
u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 
u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0
u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0))

;; Constant that represents the max independent operator fee
(define-constant max-independent-operator-fee u5)

;; Constant that represents the minimal STX contribution (20 stx)
(define-constant min-stx-mining-contribution u20000000)

;; Var list of all admin principals
(define-data-var admins (list 10 principal) (list tx-sender))

;; Var index of all pools
(define-data-var pool-index uint u1)

;; Var helper principal
(define-data-var helper-principal principal tx-sender)

;; Var helper uint pool
(define-data-var helper-uint-pool uint u0)

;; Var helper uint total contributions
(define-data-var helper-uint-total-contributions uint u0)

;; Pools - Map that defines all pools
(define-map pools uint { 
    name: (optional (string-ascii 96)),
    contributionStartHeight: uint,
    contributionEndHeight: uint,
    startedMineHeight: (optional uint),
    poolOwner: principal,
    ownerFee: uint,
    poolMembers: (list 100 principal),
    poolMinMembers: (optional uint),
    claimHeights: (list 200 uint),
    totalContributions: uint,
    totalCoinsWon: (optional uint),
})

;; Contributions - Map that defines all contributions by contributor & pool
(define-map contributions { contributor: principal, pool: uint } {
     amountSTXContributed: uint,
     amountRelativeContributed: (optional uint),
     amounttearWon: (optional uint)
})



;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;; Read Functions ;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Get specific pool
(define-read-only (get-specific-pool (pool uint)) 
    (map-get? pools pool)
)

;; Get latest pool
(define-read-only (get-latest-pool) 
    {
        pool: (map-get? pools (var-get pool-index)),
        poolIndex: (var-get pool-index)
    }
)

;; Get pool name
(define-read-only (get-pool-name (pool uint)) 
    (ok (get name (unwrap! (map-get? pools pool) (err "ERR-UNWRAP-POOL"))))
)

;; Get contribution start/end heights
(define-read-only (get-pool-contribution-heights (pool uint)) 
    (let 
        (
            (current-pool (unwrap! (map-get? pools pool) (err "ERR-UNWRAP-POOL")))
            (current-contribution-start-height (get contributionStartHeight current-pool))
            (current-contribution-end-height (get contributionEndHeight current-pool))
        )
        (ok {contribution-start-height: current-contribution-start-height,
        contribution-end-height: current-contribution-end-height})
    )
)

;; Get start / end mine heights
(define-read-only (get-pool-mining-heights (pool uint)) 
    (let 
        (
            (current-pool (unwrap! (map-get? pools pool) (err "ERR-UNWRAP-POOL")))
            (current-mining-start-height (unwrap! (get startedMineHeight current-pool) (err "ERR-HASNT-STARTED")))
            (current-mining-end-height (+ u200 current-mining-start-height))
        )
        (ok {contribution-start-height: current-mining-start-height,
        contribution-end-height: current-mining-end-height})
    )
)

;; Get claimable height
(define-read-only (get-pool-claimable-height (pool uint)) 
    (let 
        (
            (current-pool (unwrap! (map-get? pools pool) (err "ERR-UNWRAP-POOL")))
            (current-mining-start-height (unwrap! (get startedMineHeight current-pool) (err "ERR-HASNT-STARTED")))
        )
        (ok (+ u300 current-mining-start-height))
    )
)

;; Get pool owner
;; Get pool members
;; Get total contribution
;; Get total coins won

;; Get contribution
(define-read-only (get-contribution (contributor principal) (pool uint)) 
    (map-get? contributions {contributor: contributor, pool: pool})
)
    ;; Get amount contributed
    ;; Get amount relative contributed
    ;; Get amount tear won



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;; Member Functions ;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Contribute
;; @desc - Function to contribute to a pool
;; @param - pool - uint - The pool id, amount - uint - The amount of STX to contribute
(define-public (contribute-pool (pool uint) (amount uint))
    (let 
        (
            (current-pool (unwrap! (map-get? pools pool) (err "ERR-UNWRAP-POOL")))
            (current-contribution-start-height (get contributionStartHeight current-pool))
            (current-contribution-end-height (get contributionEndHeight current-pool))
            (current-pool-owner (get poolOwner current-pool))
            (current-pool-members (get poolMembers current-pool))
            (current-contributor-amount (default-to u0 (get amountSTXContributed (map-get? contributions {contributor: tx-sender, pool: pool}))))
            (new-contributor-amount (+ current-contributor-amount amount))
            (current-total-contribution (get totalContributions current-pool))
            (new-total-contribution (+ current-total-contribution amount))
        )

        ;; Assert that block-height is higher than current-contribution-start-height & lower than current-contribution-end-height
        (asserts! (and (> block-height current-contribution-start-height) (< block-height current-contribution-end-height)) (err "ERR-CONTRIBUTION-HEIGHTS"))

        ;; Assert that amount is higher than minimum-contribution
        (asserts! (> amount min-stx-mining-contribution) (err "ERR-MIN-CONTRIBUTION"))

        ;; Assert not already a contributor / contribution is u0
        (asserts! (is-eq current-contributor-amount u0) (err "ERR-ALREADY-CONTRIBUTED"))

        ;; Send STX to contract
        (unwrap! (stx-transfer? amount tx-sender (as-contract tx-sender)) (err "ERR-TRANSFER-STX"))

        ;; Map-set contribution
        (map-set contributions { contributor: tx-sender, pool: pool } {
            amountSTXContributed: new-contributor-amount,
            amountRelativeContributed: none,
            amounttearWon: none
        })

        ;; Map-set pool with appended contributor list & new total contributions
        (ok (map-set pools pool 
            (merge
                current-pool
                { 
                    poolMembers: (unwrap! (as-max-len? (append current-pool-members tx-sender) u100) (err "ERR-POOL-OVERFLOW")),
                    totalContributions: new-total-contribution
                }
            )
        ))
    )
)

;; Claim pool
;; @desc - Function for *any* contibutor of an ended pool to claim & disperse any/all winning claims
;; @param - pool - uint - The pool ID

;; Each pool will mine for 200 blocks
;; After the 200 blocks we need to wait an additional 100 day blocks before we can claim the pool
;; totalCoinsWon can only be known ater these 100 blocks have passed
;; Once the 100 blocks have passed, we want anyone to be able to check & immediately disperse all winnings
;; Opted to wait & check all at once which means we need to wait a full 100 after the initial 200 blocks (300 total)

(define-public (claim-pool (pool uint)) 
    (let 
        (
            (current-pool (unwrap! (map-get? pools pool) (err "ERR-UNWRAP-POOL")))
            (current-mining-start-height (unwrap! (get startedMineHeight current-pool) (err "ERR-MINING-NOT-ACTIVE")))
            (current-mining-end-height (+ u198 current-mining-start-height))
            (current-claimable-height (+ u200 current-mining-end-height))
            (current-pool-members (get poolMembers current-pool))
            (current-total-contribution (get totalContributions current-pool))
            (current-total-won (get totalCoinsWon current-pool))
            (current-pool-owner (get poolOwner current-pool))
            (current-pool-owner-fee (get ownerFee current-pool))
            (current-admins (var-get admins))
        )

        ;; Assert that current-total-contribution > 0 (aka not empty pool)
        (asserts! (> current-total-contribution u20) (err "ERR-NO-CONTRIBUTIONS"))

        ;; Assert that block-height is higher than current-end-height + 100
        (asserts! (> block-height current-claimable-height) (err "ERR-CLAIM-TOO-EARLY"))

        ;; Assert that pool hasn't been mined / current-total-won = u0
        (asserts! (is-none current-total-won) (err "ERR-ALREADY-CLAIMED"))

        ;; Set pool helper var
        (var-set helper-uint-pool pool)

        ;; Need to get mining rewards
        ;; Best way of doing this is to first fold through all the blocks won
        ;; Then we can get the total amount of tear won
        ;; Then we need to map from the list of contributors to the percent of STX contributed relative to the total STX contribution
        ;; Then we can map from the list of contributors to the amount of tear won relative to the total tear won & transfer the TEAR to the contributor


        ;; Get rewards...
        (ok (unwrap! (match (fold map-from-list-of-zeros-to-tear-won empty-mine-list (ok { current-height: current-mining-start-height, blocks-won: u0, tear-won: u0 })) 
         returnOk
            (let 
                (
                    (current-height (get current-height returnOk))
                    (blocks-won (get blocks-won returnOk))
                    (tear-won (get tear-won returnOk))
                )

                ;; Check if pool-owner is an admin or was started by someone else
                (if (is-some (index-of current-admins tx-sender))

                    ;; Is an admin / no extra fees
                    ;; Mass-send all tear-won to pool-members
                    (map-set pools pool (merge
                        current-pool
                        {totalCoinsWon: (some tear-won)}
                    ))

                    ;; Is not an admin / independent operator, might have fees
                    (if (> current-pool-owner-fee u0)
                        (begin 
                            ;; Map-set pool with new tear won - operator fee
                            (map-set pools pool 
                                (merge
                                    current-pool
                                    { 
                                        totalCoinsWon: (some (- tear-won (/ (* current-pool-owner-fee tear-won) u100)))
                                    }
                                )
                            )

                            ;; Distribute operator fee
                            (unwrap! (as-contract (contract-call? .tear-token transfer (/ (* current-pool-owner-fee tear-won) u100) tx-sender current-pool-owner)) (err "ERR-TRANSFER-tear"))

                            true
                        )
                        
                        ;; Mass-send all tear-won to pool-members
                        false
                    )

                )
                
                ;;(ok tear-won)
                (ok (map payout-rewards-to-pool-owners current-pool-members))
                
            )
        returnErr
            (err returnErr)
        ) (err "ERR-UNWRAP-REWARDS-OUTER")))
    )
)

;; Check if mining reward was won for all 200 blocks in a pool & collect total tear rewards won
(define-private (map-from-list-of-zeros-to-tear-won (heightZero uint) (return (response { current-height: uint, blocks-won: uint, tear-won: uint} uint)))
    (match return
     returnOk 
     (let 
        (
            (current-block-height (get current-height returnOk))
            (current-block-rewards (unwrap! (contract-call? .tear-mining-staking claim-reward-block current-block-height) (err u60)))
            (next-block-height (+ u1 current-block-height))
            (blocks-won (get blocks-won returnOk))
            (tear-won (get tear-won returnOk))
        )

        ;; Check winner for each block
        (ok (if (> current-block-rewards u0)
            ;; Won block
            {
                current-height: next-block-height,
                blocks-won: (+ blocks-won u1),
                tear-won: (+ tear-won current-block-rewards)
            }
            ;; Did not win block
             {
                current-height: next-block-height,
                blocks-won: blocks-won,
                tear-won: tear-won
            }
        ))
     ) 
     returnErr
     (err u6)
    )
)

;; Prepare reward payout by calculcating reward per principal
(define-private (payout-rewards-to-pool-owners (participant principal)) 
    (let
        (
            (current-pool-id (var-get helper-uint-pool))
            (current-pool (default-to { 
                name: none,
                contributionStartHeight: block-height,
                contributionEndHeight: block-height,
                startedMineHeight: (some block-height),
                poolOwner: tx-sender,
                ownerFee: u0,
                poolMembers: (list tx-sender),
                poolMinMembers: none,
                claimHeights: (list u0),
                totalContributions: u0,
                totalCoinsWon: none,
            } (map-get? pools current-pool-id)))
            (current-pool-total-stx-contributions (get totalContributions current-pool))
            (current-pool-total-tear-won (get totalCoinsWon current-pool))
            (participant-contributions (default-to {amountSTXContributed: u1, amountRelativeContributed: none, amounttearWon: none} (map-get? contributions { contributor: participant, pool: current-pool-id })))
            (participant-stx-contributed (get amountSTXContributed participant-contributions))
            (participant-contribution-percent (/ (* participant-stx-contributed u100) current-pool-total-stx-contributions))
            (participant-tear-won (/ (* participant-contribution-percent (default-to u1 current-pool-total-tear-won)) u100))
        )

        ;; Distribute tear to participant
        (unwrap! (as-contract (contract-call? .tear-token transfer participant-tear-won tx-sender participant)) (err "ERR-TRANSFER-tear"))

        ;; Map-set Contributions with new amount of tear paid out
        (ok (map-set contributions { contributor: participant, pool: current-pool-id } 
            (merge 
                participant-contributions 
                { 
                    amountRelativeContributed: (some participant-contribution-percent),
                    amounttearWon: (some participant-tear-won)
                }
            )
        ))
    )
)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;; Owner Functions ;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Cteare pool
;; @desc - Function for owners or admins to cteare a new pool
;; @param - name (optional (string-ascii 96)) - Optional nickname of the pool, contribution-start-height (uint), contribution-length (uint), pool-min-members (optional uint)
;; Admins/TEAR Operators -> leave pool-min-members & pool-fee as none
;; Indepdent Operators -> fill in desired pool-min-members (> 1) & pool fee % (< 5%)
(define-public (create-pool (name (optional (string-ascii 96))) (contribution-start-height uint) (contribution-length uint) (pool-min-members (optional uint)) (pool-fee (optional uint)))
    (let
        (
            (current-pool-index (var-get pool-index))
            (next-pool-index (+ (var-get pool-index) u1))
            (current-pool-min-members (default-to u1 pool-min-members))
            (current-pool-fee (default-to u1 pool-fee))
        )

        ;; Assert contributionStartHeight is gtearer than current block-height
        (asserts! (< block-height contribution-start-height) (err "ERR-START-HEIGHT"))

        ;; Assert contributionLength is gtearer than u10
        (asserts! (> contribution-length u10) (err "ERR-SHORT-LENGTH"))

        ;; Check if admin
        (if (is-some (index-of (var-get admins) tx-sender))

            ;; Is admin, map set new pool accordingly
            (map-set pools current-pool-index {
                name: name,
                contributionStartHeight: contribution-start-height,
                contributionEndHeight: (+ contribution-start-height contribution-length),
                startedMineHeight: none,
                poolOwner: tx-sender,
                ownerFee: u0,
                poolMembers: (list ),
                poolMinMembers: none,
                claimHeights: (list ),
                totalContributions: u0,
                totalCoinsWon: none
            })
            

            ;; Is not admin, need to assign min-members & operator fee
            (begin 
            
                ;; Assert that pool-min-members is higher than u1
                (asserts! (> current-pool-min-members u1) (err "ERR-NOT-ENOUGH-MEMBERS"))

                ;; Assert that operator fee is lower than max independent operator fee
                (asserts! (< current-pool-fee u5) (err "ERR-FEE-TOO-HIGH"))
                
                ;; Map set for indenpendent operator
                (map-set pools current-pool-index {
                    name: name,
                    contributionStartHeight: contribution-start-height,
                    contributionEndHeight: (+ contribution-start-height contribution-length),
                    startedMineHeight: none,
                    poolOwner: tx-sender,
                    ownerFee: current-pool-fee,
                    poolMembers: (list ),
                    poolMinMembers: none,
                    claimHeights: (list ),
                    totalContributions: u0,
                    totalCoinsWon: none
                })
            )
        )
       
        ;; Get pool index
        (ok (var-set pool-index next-pool-index))

    )
)

;; Start mining
;; @desc - Function for owners or admins to start mining for a pool
;; @param - pool (uint)
(define-public (start-pool (pool uint)) 
    (let
        (
            (current-pool (unwrap! (map-get? pools pool) (err "ERR-UNWRAP-POOL")))
            (current-pool-start-mine-height (get startedMineHeight current-pool))
            (current-pool-owner (get poolOwner current-pool))
            (current-pool-members (get poolMembers current-pool))
            (current-pool-min-members (get poolMinMembers current-pool))
            (current-total-pool-member (len current-pool-members))
            (current-pool-total-contribution (get totalContributions current-pool))
            (current-pool-total-contribution-per-block (/ current-pool-total-contribution u200))
        )
        
        ;; Assert tx-sender is current pool owner
        (asserts! (is-eq tx-sender current-pool-owner) (err "ERR-NOT-OWNER"))

        ;; Assert startedMinHeight is-none
        (asserts! (is-none current-pool-start-mine-height) (err "ERR-ALREADY-MINED"))

        ;; Assert block-height is greater than contributionEndHeight
        (asserts! (> block-height (get contributionEndHeight current-pool)) (err "ERR-TOO-EARLY"))

        ;; Asserts that current-total-pool-members is greater than u1
        (asserts! (> current-total-pool-member u1) (err "ERR-NOT-ENOUGH-MEMBERS"))

        ;; Assert that total contributions is greater than u200000000 (200 STX)
        (asserts! (> current-pool-total-contribution u200000000) (err "ERR-NOT-ENOUGH-CONTRIBUTIONS"))

        ;; Map-set current-pool by merging current-pool with startedMineHeight
        (map-set pools pool 
            (merge 
                current-pool 
                { startedMineHeight: (some block-height) }
            )
        )

        ;; Set helper uint pool to current-pool-total-contribution-per-block
        (var-set helper-uint-pool current-pool-total-contribution-per-block)

        ;; Contract-call? the mine-many function from tear-mining-staking, first prepare mine-list
        (ok (as-contract (contract-call? .tear-mining-staking mine-many-blocks (map prepare-pool-list empty-mine-list))))

    )
)


;; Cancel pool
;; @desc - Function for owners or admins to cancel a pool before it starts mining (likely not enough members reached)
;; @param - pool (uint)
(define-public (cancel-pool (pool uint)) 
    (let 
        (
            (current-pool (unwrap! (map-get? pools pool) (err "ERR-UNWRAP-POOL")))
            (current-pool-start-mine-height (get startedMineHeight current-pool))
            (current-pool-owner (get poolOwner current-pool))
            (current-pool-members (get poolMembers current-pool))
            (current-pool-members-len (len current-pool-members))
        )

        ;; Assert tx-sender is current-pool-owner
        (asserts! (is-eq tx-sender current-pool-owner) (err "ERR-NOT-OWNER"))

        ;; Assert that startedMineHeight is-none
        (asserts! (is-none current-pool-start-mine-height) (err "ERR-ALREADY-STARTED"))

        ;; Check if current-pool-members-len is-eq u0
        (ok (if (is-eq current-pool-members-len u0)

            ;; Is-eq u0, map-delete current-pool, no need to return contributions
            (map-delete pools pool)

            ;; Is not-eq u0, map-delete current-pool & return contributions to each member
            (begin

                 ;; Var-set helper uint variable to access contributions while mapping
                (var-set helper-uint-pool pool)

                ;; Map through current-pool-members & return contributions to each member
                (map map-from-contributions-to-zero current-pool-members)

                ;; Map-delete current-pool
                (map-delete pools pool)
            )
        ))

    )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;; Helper Functions ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Helper function to prepare the (ustxAmounts (list 200 uint)) parameter for the mine-many-blocks function
(define-private (prepare-pool-list (totalSTXContribution uint)) 
    (var-get helper-uint-pool)
)

;; Helper function return stx from a cancelled pool (map from current-pool-members & return contributions to each member)
(define-private (map-from-contributions-to-zero (member principal))
    (let 
        (
            (current-pool (var-get helper-uint-pool))
            (current-contribution (unwrap! (map-get? contributions { pool: current-pool, contributor: member }) (err "ERR-UNWRAP-CONTRIBUTION")))
            (current-contribution-amount (get amountSTXContributed current-contribution))
        )
        
        ;; Send un-mined STX back to member
        (as-contract (unwrap! (stx-transfer? current-contribution-amount tx-sender member) (err "ERR-TRANSFER-FAILED")))

        ;; Map-delete current-contribution
        (ok (map-delete contributions { pool: current-pool, contributor: member }))

    )
)



;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;; Admin Functions ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Add admin / pool operators
;; @desc - Function for admins to add new admins which can cteare pools
;; @param - admin (principal)
(define-public (add-admin (new-admin principal)) 
    (let
        (
            (current-admins (var-get admins))
            (new-admins (unwrap! (as-max-len? (append current-admins new-admin) u10) (err "ERR-ADMIN-OVERFLOW")))
        )

        ;; Assert tx-sender is admin
        (asserts! (is-some (index-of current-admins tx-sender)) (err "ERR-NOT-ADMIN"))

        ;; Assert new-admin is not already an admin
        (asserts! (is-none (index-of current-admins new-admin)) (err "ERR-ALREADY-ADMIN"))

        ;; Add new-admin to admins
        (ok (var-set admins new-admins))

    )
)

;; Remove admin / pool operators
;; @desc - Function for admins to remove admins
;; @param - admin (principal)
(define-public (remove-admin (remove-whitelist principal))
  (let
    (
      (current-admins (var-get admins))
    )

    ;; asserts tx-sender is an existing whitelist address
    (asserts! (is-some (index-of current-admins tx-sender)) (err "ERR-NOT-ADMIN"))

    ;; asserts param principal (removeable whitelist) already exist
    (asserts! (is-some (index-of current-admins remove-whitelist)) (err "ERR-NO-ADMIN"))

    ;; temporary var set to help remove param principal
    (var-set helper-principal remove-whitelist)

    ;; filter existing whitelist address
    (ok (var-set admins (filter is-not-removeable current-admins)))
  )
)

;; @desc - Helper function for removing a specific admin from tne admin whitelist
(define-private (is-not-removeable (admin-principal principal))
  (not (is-eq admin-principal (var-get helper-principal)))
)

;; Admin function to retrieve STX from the contract
;; @desc - Function for admins to retrieve STX from the contract
;; @param - amount (uint)
(define-public (admin-retrieve-stx (amount uint))
    (let
        (
            (current-admins (var-get admins))
            (current-user tx-sender)
        )

        ;; Assert tx-sender is admin
        (asserts! (is-some (index-of current-admins tx-sender)) (err "ERR-NOT-ADMIN"))

        ;; Send STX to tx-sender
        (ok (as-contract (unwrap! (stx-transfer? amount tx-sender current-user) (err "ERR-TRANSFER-FAILED"))))

    )
)

;; Admin function to retrieve TEAR from the contract
;; @desc - Function for admins to retrieve TEAR from the contract
;; @param - amount (uint)
(define-public (admin-retrieve-tear (amount uint))
    (let
        (
            (current-admins (var-get admins))
            (current-user tx-sender)
        )

        ;; Assert tx-sender is admin
        (asserts! (is-some (index-of current-admins tx-sender)) (err "ERR-NOT-ADMIN"))

        ;; Send TEAR to tx-sender
        (ok (as-contract (unwrap! (contract-call? .tear-token transfer amount tx-sender current-user) (err "ERR-TRANSFER-FAILED"))))

    )
)


;; Open questions
;; Can *anyone* start a pool? or only TEAR admins?
;; Fees for TEAR on admin-cteared pools? How about owner-cteared pools?
;; Minimum members? contributions? do we leave that up to pool operators?
;; What should be minimum contribution? 20 STX? (.1 STX per block)
;; Do we *need* them to be able to contribute multiple times?