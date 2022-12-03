;; @contract gglr Stake Pool - Stake gglr to get stgglr
;; A fixed amount of rewards per block will be distributed across all stakers, according to their size in the pool
;; Rewards will be automatically staked before staking or unstaking. 
;; The cumm reward per stake represents the rewards over time, taking into account total staking volume over time
;; When total stake changes, the cumm reward per stake is increased accordingly.
;; The cooldown mechanism makes sure there is a period of 10 days before the user can unstake. 
;; Unstaking must happen within 2 days after the 10 days cooldown period.
;; @version 1.2

(impl-trait .googlier-stake-pool-trait-v1.stake-pool-trait)
(impl-trait .googlier-stake-pool-gglr-trait-v1.stake-pool-gglr-trait)
(use-trait ft-trait .sip-010-trait-ft-standard.sip-010-trait)
(use-trait stake-registry-trait .googlier-stake-registry-trait-v1.stake-registry-trait)

;; Errors
(define-constant ERR-NOT-AUTHORIZED (err u18401))
(define-constant ERR-REWARDS-CALC (err u18001))
(define-constant ERR-WRONG-TOKEN (err u18002))
(define-constant ERR-COOLDOWN-NOT-ENDED (err u18003))
(define-constant ERR-WRONG-REGISTRY (err u18004))

;; Constants
(define-constant POOL-TOKEN .googlier-token)

;; Variables
(define-data-var last-reward-add-block uint u0)

;; ---------------------------------------------------------
;; Migration
;; ---------------------------------------------------------

;; Set last rewards block
(define-public (set-last-reward-add-block (new-value uint))
  (begin
    (asserts! (is-eq tx-sender (contract-call? .googlier-dao get-dao-owner)) (err ERR-NOT-AUTHORIZED))
    (var-set last-reward-add-block new-value)
    (ok true)
  )
)

;; Migrate gglr from old to new contract
(define-public (migrate-gglr)
  (let (
    (gglr-supply-v1 (unwrap-panic (contract-call? .googlier-token get-balance .googlier-stake-pool-gglr-v1-1)))
  )
    (asserts! (is-eq tx-sender (contract-call? .googlier-dao get-dao-owner)) ERR-NOT-AUTHORIZED)
    
    ;; Burn gglr in pool V1, mint in V2
    (try! (as-contract (contract-call? .googlier-dao burn-token .googlier-token gglr-supply-v1 .googlier-stake-pool-gglr-v1-1)))
    (try! (as-contract (contract-call? .googlier-dao mint-token .googlier-token gglr-supply-v1 (as-contract tx-sender))))

    (ok gglr-supply-v1)
  )
)

;; ---------------------------------------------------------
;; Cooldown
;; ---------------------------------------------------------

;; Cooldown map
(define-map wallet-cooldown 
   { wallet: principal } 
   {
      redeem-period-start-block: uint,
      redeem-period-end-block: uint
   }
)

;; Get cooldown info for wallet
(define-read-only (get-cooldown-info-of (wallet principal))
  (default-to
    { redeem-period-start-block: u0, redeem-period-end-block: u0 }
    (map-get? wallet-cooldown { wallet: wallet })
  )
)

;; @desc start cooldown period of 10 days
;; @post uint; returns block number when redeem period of 2 days starts
(define-public (start-cooldown)
  (let (
    (redeem-period-start-block (+ block-height u1440)) ;; 1440 blocks = ~10 days
    (redeem-period-end-block (+ redeem-period-start-block u288)) ;; 288 blocks = ~2 days
  )
    (map-set wallet-cooldown { wallet: tx-sender } { 
      redeem-period-start-block: redeem-period-start-block,
      redeem-period-end-block: redeem-period-end-block 
    })
    (ok redeem-period-start-block)
  )
)


;; Check if cooldown ended
(define-read-only (wallet-can-redeem (wallet principal))
  (let (
    (wallet-cooldown-info (get-cooldown-info-of wallet))
    (redeem-period-start (get redeem-period-start-block wallet-cooldown-info))
    (redeem-period-end (get redeem-period-end-block wallet-cooldown-info))
  )
    (if (and (> block-height redeem-period-start) (< block-height redeem-period-end) (not (is-eq redeem-period-start u0)))
      true
      false
    )
  )
)


;; ---------------------------------------------------------
;; Stake Functions
;; ---------------------------------------------------------

;; Get variable last-reward-add-block
(define-read-only (get-last-reward-add-block)
  (var-get last-reward-add-block)
)

;; gglr (staked & rewards) over total supply of stgglr - Result with 6 decimals
(define-read-only (gglr-stgglr-ratio)
  (let (
    ;; Total stgglr supply
    (stgglr-supply (unwrap-panic (contract-call? .stgglr-token get-total-supply)))

    ;; Total gglr (staked + rewards)
    (gglr-supply (unwrap-panic (contract-call? .googlier-token get-balance (as-contract tx-sender))))
  )
    (if (is-eq stgglr-supply u0)
      (ok u1000000)
      (ok (/ (* gglr-supply u1000000) stgglr-supply))
    )
  )
)

;; @desc get amount of gglr to receive for given stgglr
;; @param registry-trait; current stake registry
;; @param amount; amount of stgglr tokens
;; @param stgglr-supply; total stgglr supply
;; @post uint; returns amount of gglr tokens
(define-public (gglr-for-stgglr (registry-trait <stake-registry-trait>) (amount uint) (stgglr-supply uint))
  (let (
    ;; gglr already in pool
    (gglr-supply (unwrap-panic (contract-call? .googlier-token get-balance (as-contract tx-sender))))

    ;; gglr still to be added to pool
    (rewards-to-add (calculate-pending-rewards-for-pool registry-trait))

    ;; Total gglr
    (total-gglr-supply (+ gglr-supply rewards-to-add))

    ;; User stgglr percentage
    (stgglr-percentage (/ (* amount u1000000000000) stgglr-supply))

    ;; Amount of gglr the user will receive
    (gglr-to-receive (/ (* stgglr-percentage total-gglr-supply) u1000000000000))
  )
    (ok gglr-to-receive)
  )
)

;; @desc get total amount of gglr in pool for staker, based on stgglr in wallet
;; @param registry-trait; current stake registry
;; @param staker; user for which we want to get total stake
;; @param stgglr-supply; total stgglr supply
;; @post uint; returns amount of gglr tokens the user would get when unstaking
(define-public (get-stake-of (registry-trait <stake-registry-trait>) (staker principal) (stgglr-supply uint))
  (let (
    ;; Sender stgglr balance
    (stgglr-balance (unwrap-panic (contract-call? .stgglr-token get-balance tx-sender)))
  )
    (if (> stgglr-balance u0)
      ;; Amount of gglr the user would receive when unstaking
      (ok (unwrap-panic (gglr-for-stgglr registry-trait stgglr-balance stgglr-supply)))
      (ok u0)
    )
  )
)

;; Get total amount of gglr in pool
(define-read-only (get-total-staked)
  (unwrap-panic (contract-call? .googlier-token get-balance (as-contract tx-sender)))
)

;; @desc stake tokens in the pool, used by stake-registry
;; @param registry-trait; current stake registry
;; @param token; token to stake
;; @param staker; user who wants to stake
;; @param amount; amount of tokens to stake
;; @post uint; returns amount of tokens staked
(define-public (stake (registry-trait <stake-registry-trait>) (token <ft-trait>) (staker principal) (amount uint))
  (begin
    (asserts! (is-eq contract-caller (unwrap-panic (contract-call? .googlier-dao get-qualified-name-by-name "stake-registry"))) ERR-NOT-AUTHORIZED)
    (asserts! (is-eq POOL-TOKEN (contract-of token)) ERR-WRONG-TOKEN)

    ;; Add pending rewards to pool
    (try! (add-rewards-to-pool registry-trait))

    (let (
      ;; gglr/stgglr 
      (gglr-stgglr (unwrap-panic (gglr-stgglr-ratio)))

      ;; Calculate amount of stgglr to receive
      (stgglr-to-receive (/ (* amount u1000000) gglr-stgglr))
    )
      ;; Mint stgglr
      (try! (contract-call? .googlier-dao mint-token .stgglr-token stgglr-to-receive staker))

      ;; Transfer gglr to this contract
      (try! (contract-call? .googlier-token transfer amount staker (as-contract tx-sender) none))

      (ok stgglr-to-receive)
    )
  )
)

;; @desc unstake tokens in the pool, used by stake-registry
;; @param registry-trait; current stake registry
;; @param token; token to unstake
;; @param staker; user who wants to unstake
;; @param amount; amount of tokens to unstake
;; @post uint; returns amount of tokens unstaked
(define-public (unstake (registry-trait <stake-registry-trait>) (token <ft-trait>) (staker principal) (amount uint))
  (begin
    (asserts! (is-eq contract-caller (unwrap-panic (contract-call? .googlier-dao get-qualified-name-by-name "stake-registry"))) ERR-NOT-AUTHORIZED)
    (asserts! (is-eq POOL-TOKEN (contract-of token)) ERR-WRONG-TOKEN)
    (asserts! (is-eq (wallet-can-redeem staker) true) ERR-COOLDOWN-NOT-ENDED)

    ;; Add pending rewards to pool
    (try! (add-rewards-to-pool registry-trait))

    (let (
      ;; Amount of gglr the user will receive
      (gglr-to-receive (unwrap-panic (gglr-for-stgglr registry-trait amount (unwrap-panic (contract-call? .stgglr-token get-total-supply)))))
    )
      ;; Burn stgglr 
      (try! (contract-call? .googlier-dao burn-token .stgglr-token amount staker))

      ;; Transfer gglr back from this contract to the user
      (try! (as-contract (contract-call? .googlier-token transfer gglr-to-receive tx-sender staker none)))

      (ok gglr-to-receive)
    )
  )
)

;; @desc add pending gglr rewards to the pool
;; @param registry-trait; current stake registry
;; @post uint; returns amount of rewards added
(define-public (add-rewards-to-pool (registry-trait <stake-registry-trait>))
  (let (
    (rewards-to-add (calculate-pending-rewards-for-pool registry-trait))
    (deactivated-block (unwrap-panic (contract-call? registry-trait get-pool-deactivated-block .googlier-stake-pool-gglr-v1-2)))
  )
    (asserts! (is-eq (contract-of registry-trait) (unwrap-panic (contract-call? .googlier-dao get-qualified-name-by-name "stake-registry"))) ERR-WRONG-REGISTRY)
    (asserts! (> block-height (var-get last-reward-add-block)) (ok u0))

    ;; Rewards to add can be 0 if called multiple times in same block
    ;; Do not mint if pool deactivated
    (if (or (is-eq rewards-to-add u0) (not (is-eq deactivated-block u0)))
      false
      (try! (contract-call? .googlier-dao mint-token .googlier-token rewards-to-add (as-contract tx-sender)))
    )

    ;; Update block number
    (var-set last-reward-add-block (get height (get-last-block-height registry-trait)))

    (ok rewards-to-add)
  )
)

;; Amount of rewards still to be added to the pool
;; This is an approximation as the rewards per block change every block
(define-private (calculate-pending-rewards-for-pool (registry-trait <stake-registry-trait>))
  (let (
    (rewards-per-block (unwrap-panic (contract-call? registry-trait get-rewards-per-block-for-pool .googlier-stake-pool-gglr-v1-2)))
    (last-block-info (get-last-block-height registry-trait))
    (block-diff (if (> (get height last-block-info) (var-get last-reward-add-block))
      (- (get height last-block-info) (var-get last-reward-add-block))
      u0
    ))
    (rewards-to-add (* rewards-per-block block-diff))
  )
    ;; Rewards to add can be 0 if called multiple times in same block
    ;; Do not mint if pool deactivated
    (if (or (is-eq rewards-to-add u0) (is-eq false (get pool-active last-block-info)))
      u0
      rewards-to-add
    )
  )
)

;; Return current block height, or block height when pool was deactivated
(define-private (get-last-block-height (registry-trait <stake-registry-trait>))
  (let (
    (deactivated-block (unwrap-panic (contract-call? registry-trait get-pool-deactivated-block .googlier-stake-pool-gglr-v1-2)))
    (pool-active (is-eq deactivated-block u0))
  )
    (if (is-eq pool-active true)
      { height: block-height, pool-active: true }
      { height: deactivated-block, pool-active: false }
    )
  )
)

;; @desc execute slash with given percentage
;; @param percentage; percentage to slash
;; @post uint; returns total tokens removed from pool
(define-public (execute-slash (percentage uint))
  (let (
    (gglr-supply (unwrap-panic (contract-call? .googlier-token get-balance (as-contract tx-sender))))
    (slash-total (/ (* gglr-supply percentage) u100))
    (dao-owner (contract-call? .googlier-dao get-dao-owner))
  )
    (asserts! (is-eq contract-caller (unwrap-panic (contract-call? .googlier-dao get-qualified-name-by-name "gglr-slash"))) ERR-NOT-AUTHORIZED)
    (try! (as-contract (contract-call? .googlier-token transfer slash-total tx-sender dao-owner none)))
    (ok slash-total)
  )
)

;; Needed because of pool trait
(define-public (claim-pending-rewards (registry-trait <stake-registry-trait>) (staker principal))
  (ok u0)
)

;; Needed because of pool trait
(define-public (get-pending-rewards (registry-trait <stake-registry-trait>) (staker principal))
  (ok u0)
)
