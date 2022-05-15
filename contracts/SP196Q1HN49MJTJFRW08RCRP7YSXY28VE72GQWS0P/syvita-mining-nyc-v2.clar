;;                __   __
;;               __ \ / __
;;              /  \ | /  \
;;                  \|/
;;             _,.---v---._
;;    /\__/\  /            \
;;    \_  _/ /              \
;;      \ \_|           @ __|
;; NYC   \                \_
;;        \     ,__/       /
;;      ~~~`~~~~~~~~~~~~~~/~~~~

;; constants
(define-constant ERR_ADDRESS_NOT_FOUND u1001)
(define-constant ERR_ID_NOT_FOUND u1002)
(define-constant ERR_CANNOT_START_ON_PREVIOUS_BLOCK u1003)
(define-constant ERR_POOL_NOT_FOUND u1004)
(define-constant ERR_POOL_STILL_OPEN u1005)
(define-constant ERR_INSUFFICIENT_BALANCE u1006)
(define-constant ERR_CONTRIBUTION_BELOW_MINIMUM u1007)
(define-constant ERR_CONTRIBUTION_PERIOD_ENDED u1008)
(define-constant ERR_CONTRIBUTION_PERIOD_NOT_STARTED u1009)
(define-constant ERR_CONTRIBUTION_NOT_FOUND u1010)
(define-constant ERR_CALLER_NOT_AUTHORISED u1011)
(define-constant ERR_MINE_MANY_NOT_FOUND u1012)
(define-constant ERR_BLOCK_NOT_WON u1013)
(define-constant ERR_CLAIMING_UNAVAILABLE u1014)
(define-constant ERR_CLAIMING_ALREADY_ENABLED u1015)
(define-constant ERR_CLAIMING_NOT_ENABLED u1016)
(define-constant ERR_ALREADY_CLAIMED u1017)
(define-constant ERR_CLAIMS_NOT_FOUND u1018)
(define-constant ERR_CANNOT_REMOVE_FEE_ADDRESS u1019)
(define-constant POOL_CONTRACT_ADDRESS (as-contract tx-sender))

;; data-vars
(define-data-var poolIdTip uint u0)
(define-data-var mineManyIdTip uint u0)
(define-data-var feeAddress principal tx-sender)
(define-data-var adminAddresses (list 10 principal) (list tx-sender))
(define-data-var blocksWon (list 200 uint) (list))
(define-data-var mineManyIdToUpdate uint u0)
(define-data-var poolIdToClaim uint u0)
(define-data-var addressToRemove principal tx-sender)
(define-data-var blockCount uint u0)

;; maps
(define-map Pools
    { id: uint }
    { 
      contributionsStartBlock: uint,
      contributionsEndBlock: uint,
      totalContributed: uint,
      totalCoinsWon: uint,
      mineManyIds: (list 100 uint),
      feePercentage: uint,
      minContribution: uint
    }
)

(define-map Contributions
    { poolId: uint, address: principal }
    { 
      amountUstx: uint
    }
)

(define-map MineManys
    { id: uint } 
    { 
      poolId: uint,
      blockMiningStarted: uint,
      ustxAmounts: (list 200 uint),
      coinsWon: uint,
      claimingEnabled: bool, 
    }
)

(define-map Claims
    {poolId: uint, address: principal}
    {
      mineManysClaimed: (list 100 uint)
    }
)

;; private functions
(define-private (is-not-address (address principal))
  (not (is-eq address (var-get addressToRemove)))
)

(define-private (contract-claim-mining-reward (block uint))
    (let
      (
        (mineManyId (var-get mineManyIdToUpdate))
        (mineMany (unwrap! (map-get? MineManys { id: mineManyId }) (err ERR_MINE_MANY_NOT_FOUND)))
        (poolId (get poolId mineMany))
        (pool (unwrap! (map-get? Pools { id: poolId }) (err ERR_POOL_NOT_FOUND)))
        (coinbaseAmount (as-contract (contract-call? 'SPSCWDV3RKV5ZRN1FQD84YE1NQFEDJ9R1F4DYQ11.newyorkcitycoin-core-v2 get-coinbase-amount block)))
        (isWinner (as-contract (contract-call? 'SPSCWDV3RKV5ZRN1FQD84YE1NQFEDJ9R1F4DYQ11.newyorkcitycoin-core-v2 can-claim-mining-reward POOL_CONTRACT_ADDRESS block)))
      )
      (if isWinner
        (begin
          (try! (as-contract (contract-call? 'SPSCWDV3RKV5ZRN1FQD84YE1NQFEDJ9R1F4DYQ11.newyorkcitycoin-core-v2 claim-mining-reward block)))
          (asserts! (map-set MineManys {id: mineManyId} 
            {
              poolId: poolId,
              blockMiningStarted: (get blockMiningStarted mineMany),
              ustxAmounts: (get ustxAmounts mineMany),
              coinsWon: (+ (get coinsWon mineMany) coinbaseAmount),
              claimingEnabled: (get claimingEnabled mineMany)
            })
          (err u0))
          (asserts! (map-set Pools {id: poolId}
            {
              contributionsStartBlock: (get contributionsStartBlock pool),
              contributionsEndBlock: (get contributionsEndBlock pool),
              totalContributed: (get totalContributed pool),
              totalCoinsWon: (+ (get totalCoinsWon pool) coinbaseAmount),
              mineManyIds: (get mineManyIds pool),
              feePercentage: (get feePercentage pool),
              minContribution: (get minContribution pool)
            }
          ) (err u0))
          (ok true)
        )
        (ok false)
      )
    )
)

(define-private (payout-fee (mineManyId uint))
    (let
      (
        (mineMany (unwrap! (map-get? MineManys { id: mineManyId }) (err ERR_MINE_MANY_NOT_FOUND)))
        (coinsWon (get coinsWon mineMany))
        (poolId (get poolId mineMany))
        (pool (unwrap! (map-get? Pools { id: poolId }) (err ERR_POOL_NOT_FOUND)))
        (fee (get feePercentage pool))
      )
      (try! (as-contract (contract-call? 'SPSCWDV3RKV5ZRN1FQD84YE1NQFEDJ9R1F4DYQ11.newyorkcitycoin-token-v2 transfer (* (/ coinsWon u100) fee) POOL_CONTRACT_ADDRESS (var-get feeAddress) none)))
      (ok true)
    )
)

;; public functions
(define-public (contribute (poolId uint) (amountUstx uint)) 
    (let
      (
        (pool (unwrap! (map-get? Pools { id: poolId }) (err ERR_POOL_NOT_FOUND)))
        (contributionsEndBlock (get contributionsEndBlock pool))
        (contributionsStartBlock (get contributionsStartBlock pool))
        (callerAddress tx-sender)
        (currentContribution (get amountUstx (map-get? Contributions {poolId: poolId, address: callerAddress})))
      )

      (asserts! (< block-height contributionsEndBlock) (err ERR_CONTRIBUTION_PERIOD_ENDED))
      (asserts! (>= block-height contributionsStartBlock) (err ERR_CONTRIBUTION_PERIOD_NOT_STARTED))
      (asserts! (>= (stx-get-balance callerAddress) amountUstx) (err ERR_INSUFFICIENT_BALANCE))
      (asserts! (>= amountUstx (get minContribution pool)) (err ERR_CONTRIBUTION_BELOW_MINIMUM))

      (try! (stx-transfer? amountUstx callerAddress POOL_CONTRACT_ADDRESS))

      (if (is-none currentContribution)
          (begin
            (asserts! (map-insert Contributions {poolId: poolId, address: callerAddress} {amountUstx: amountUstx}) (err u0))
            (asserts! (map-insert Claims {poolId: poolId, address: callerAddress} {mineManysClaimed: (list)}) (err u0))
          )
          (asserts! (map-set Contributions {poolId: poolId, address: callerAddress} {amountUstx: (+ (unwrap-panic currentContribution) amountUstx)}) (err u0))
      )

      (asserts! (map-set Pools {id: poolId}
        {
          contributionsStartBlock: (get contributionsStartBlock pool),
          contributionsEndBlock: contributionsEndBlock,
          totalContributed: (+ (get totalContributed pool) amountUstx),
          totalCoinsWon: (get totalCoinsWon pool),
          mineManyIds: (get mineManyIds pool),
          feePercentage: (get feePercentage pool),
          minContribution: (get minContribution pool)
        }
      ) (err u0))

      (ok true)
    )
)

;; called by admin to set an ending block for contributions
(define-public (set-end-block (poolId uint) (contributionsEndBlock uint)) 
  (let
      (
        (pool (unwrap! (map-get? Pools { id: poolId }) (err ERR_POOL_NOT_FOUND)))
      )
      (asserts! (is-some (index-of (var-get adminAddresses) tx-sender)) (err ERR_CALLER_NOT_AUTHORISED))
      (asserts! (map-set Pools {id: poolId}
        {
          contributionsStartBlock: (get contributionsStartBlock pool),
          contributionsEndBlock: contributionsEndBlock,
          totalContributed: (get totalContributed pool),
          totalCoinsWon: (get totalCoinsWon pool),
          mineManyIds: (get mineManyIds pool),
          feePercentage: (get feePercentage pool),
          minContribution: (get minContribution pool)
        }
      ) (err u0))
      (ok true)
  )
)

;; called by a contributor to claim rewards for all mine-manys in a pool
(define-public (contributor-claim-all-rewards-for-pool (poolId uint)) 
  (let
    (
      (pool (unwrap! (map-get? Pools { id: poolId }) (err ERR_POOL_NOT_FOUND)))
      (mineManyIds (get mineManyIds pool))
    )
    (map contributor-claim-single-reward-from-pool mineManyIds)
    (ok true)
  )
)

;; called by a contributor to claim the reward for a mine-many id
(define-public (contributor-claim-single-reward-from-pool (mineManyId uint))
   (let
      (
          (callerAddress tx-sender)
          (mineMany (unwrap! (map-get? MineManys { id: mineManyId }) (err ERR_MINE_MANY_NOT_FOUND)))
          (poolId (get poolId mineMany))
          (pool (unwrap! (map-get? Pools { id: poolId }) (err ERR_POOL_NOT_FOUND)))
          (contribution (unwrap! (map-get? Contributions {poolId: poolId, address: callerAddress}) (err ERR_CONTRIBUTION_NOT_FOUND)))
          (currentContribution (get amountUstx contribution))
          (totalContributed (get totalContributed pool))
          (coinsWon (get coinsWon mineMany))
          (claimingEnabled (get claimingEnabled mineMany))
          (claims (unwrap! (map-get? Claims {poolId: poolId, address: callerAddress}) (err ERR_CLAIMS_NOT_FOUND)))
          (mineManysClaimed (get mineManysClaimed claims))
          (fee (get feePercentage pool))
      )
      (asserts! claimingEnabled (err ERR_CLAIMING_NOT_ENABLED))
      (asserts! (is-none (index-of mineManysClaimed mineManyId)) (err ERR_ALREADY_CLAIMED))
      (try! (as-contract (contract-call? 'SPSCWDV3RKV5ZRN1FQD84YE1NQFEDJ9R1F4DYQ11.newyorkcitycoin-token-v2 transfer (/ (* (* (/ coinsWon u100) (- u100 fee)) currentContribution) totalContributed) POOL_CONTRACT_ADDRESS callerAddress none)))
      (asserts! (map-set Claims {poolId: poolId, address: callerAddress} 
        {mineManysClaimed: (unwrap-panic (as-max-len? (append mineManysClaimed mineManyId) u100))}) 
      (err u0))
      (ok true)
  )
)

;; called by an admin to send a mine-many transaction to the citycoin contract
(define-public (contract-mine-many (poolId uint) (amounts (list 200 uint)))
    (let
      (
        (pool (unwrap! (map-get? Pools { id: poolId }) (err ERR_POOL_NOT_FOUND)))
        (prevMineManyId (var-get mineManyIdTip))
      )
      (asserts! (is-some (index-of (var-get adminAddresses) tx-sender)) (err ERR_CALLER_NOT_AUTHORISED))
      (asserts! (>= block-height (get contributionsEndBlock pool)) (err ERR_POOL_STILL_OPEN))

      (try! (as-contract (contract-call? 'SPSCWDV3RKV5ZRN1FQD84YE1NQFEDJ9R1F4DYQ11.newyorkcitycoin-core-v2 mine-many amounts)))

      (asserts! (map-insert MineManys {id: (+ prevMineManyId u1)} 
        {
          poolId: poolId,
          blockMiningStarted: block-height,
          ustxAmounts: amounts,
          coinsWon: u0,
          claimingEnabled: false
        })
      (err u0))
      
      (asserts! (map-set Pools {id: poolId}
        {
          contributionsStartBlock: (get contributionsStartBlock pool),
          contributionsEndBlock: (get contributionsEndBlock pool),
          totalContributed: (get totalContributed pool),
          totalCoinsWon: (get totalCoinsWon pool),
          mineManyIds: (unwrap-panic (as-max-len? (append (get mineManyIds pool) (+ prevMineManyId u1)) u100)),
          feePercentage: (get feePercentage pool),
          minContribution: (get minContribution pool)
        }
      ) (err u0))

      (var-set mineManyIdTip (+ prevMineManyId u1))
      (ok true)
    )
)

;; called by an admin to claim up to 10 blocks at once
(define-public (contract-claim-many (mineManyId uint) (blocks (list 10 uint)))
  (let
    (
      (mineMany (unwrap! (map-get? MineManys { id: mineManyId }) (err ERR_MINE_MANY_NOT_FOUND)))
      (poolId (get poolId mineMany))
    )
    (var-set mineManyIdToUpdate mineManyId)
    (map contract-claim-mining-reward blocks)
    (ok true)
  )
)

;; called by an admin to claim a single block
(define-public (contract-claim-single (mineManyId uint) (block uint))
  (let
    (
      (mineMany (unwrap! (map-get? MineManys { id: mineManyId }) (err ERR_MINE_MANY_NOT_FOUND)))
      (poolId (get poolId mineMany))
    )
    (var-set mineManyIdToUpdate mineManyId)
    (try! (contract-claim-mining-reward block))
    (ok true)
  )
)

;; called by an admin to start the next pool
(define-public (start-next-pool (contributionsStartBlock uint) (feePercent uint) (minContributionUstx uint))
  (let
    (
      (prevPoolId (var-get poolIdTip))
      (newPoolId (+ prevPoolId u1))
    )
    (asserts! (is-some (index-of (var-get adminAddresses) tx-sender)) (err ERR_CALLER_NOT_AUTHORISED))
    (asserts! (map-insert Pools {id: newPoolId}
        {
          contributionsStartBlock: contributionsStartBlock,
          contributionsEndBlock: (+ block-height u300),
          totalContributed: u0,
          totalCoinsWon: u0,
          mineManyIds: (list),
          feePercentage: feePercent,
          minContribution: minContributionUstx
        }
    ) (err u0))

    (var-set poolIdTip newPoolId)
    
    (ok true)
  )
)

;; called by an admin to enable contributor claiming for a mine-many
(define-public (contract-enable-contributor-claiming (mineManyId uint))
    (let
      (
        (mineMany (unwrap! (map-get? MineManys { id: mineManyId }) (err ERR_MINE_MANY_NOT_FOUND)))
        (poolId (get poolId mineMany))
        (pool (unwrap! (map-get? Pools { id: poolId }) (err ERR_POOL_NOT_FOUND)))
      )
      
      (asserts! (is-some (index-of (var-get adminAddresses) tx-sender)) (err ERR_CALLER_NOT_AUTHORISED))
      (asserts! (not (get claimingEnabled mineMany)) (err ERR_CLAIMING_ALREADY_ENABLED))
      (asserts! (>= block-height (get contributionsEndBlock pool)) (err ERR_POOL_STILL_OPEN))

      (try! (payout-fee mineManyId))

      (asserts! (map-set MineManys {id: mineManyId} 
        {
          poolId: poolId,
          blockMiningStarted: (get blockMiningStarted mineMany),
          ustxAmounts: (get ustxAmounts mineMany),
          coinsWon: (get coinsWon mineMany),
          claimingEnabled: true
        })
      (err u0))
    (ok true)
    )
)

(define-public (add-admin-address (address principal))
    (begin
        (asserts! (is-some (index-of (var-get adminAddresses) tx-sender)) (err ERR_CALLER_NOT_AUTHORISED))
        (var-set adminAddresses (unwrap-panic (as-max-len? (append (var-get adminAddresses) address) u10)))
        (ok true)
    )
)

(define-public (remove-admin-address (address principal))
    (begin
        (asserts! (is-some (index-of (var-get adminAddresses) tx-sender)) (err ERR_CALLER_NOT_AUTHORISED))
        (asserts! (not (is-eq address (var-get feeAddress))) (err ERR_CANNOT_REMOVE_FEE_ADDRESS))
        (var-set addressToRemove address)
        (var-set adminAddresses (filter is-not-address (var-get adminAddresses)))
        (ok true)
    )
)

(define-public (update-fee-address (newAddress principal))
    (begin
        (asserts! (is-eq contract-caller (var-get feeAddress)) (err ERR_CALLER_NOT_AUTHORISED))
        (var-set feeAddress newAddress)
        (ok true)
    )
)

;; read-only functions

(define-read-only (get-pool (poolId uint))
    (ok (unwrap! (map-get? Pools { id: poolId }) (err ERR_POOL_NOT_FOUND)))
)

(define-read-only (get-contribution (poolId uint) (address principal))
    (ok (unwrap! (map-get? Contributions {poolId: poolId, address: address}) (err ERR_CONTRIBUTION_NOT_FOUND)))
)

(define-read-only (get-admin-addresses)
    (var-get adminAddresses)
)

(define-read-only (get-fee-address)
    (var-get feeAddress)
)

(define-read-only (get-latest-pool-id)
    (var-get poolIdTip)
)

(define-read-only (get-mine-many (mineManyId uint))
    (ok (unwrap! (map-get? MineManys { id: mineManyId }) (err ERR_MINE_MANY_NOT_FOUND)))
)

(define-read-only (get-claims-for-pool (poolId uint) (address principal))
    (ok (unwrap! (map-get? Claims { poolId: poolId, address: address }) (err ERR_CLAIMS_NOT_FOUND)))
)