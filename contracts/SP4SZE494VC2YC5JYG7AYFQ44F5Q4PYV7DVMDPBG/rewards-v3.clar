;; @contract Rewards
;; @version 3
;;
;; All rewards for stSTX and stSTXbtc are added and stored in this contract.
;; At the end of the cycle, all rewards are processed at once and added to the protocol.

(impl-trait .rewards-trait-v1.rewards-trait)
(use-trait commission-trait .commission-trait-v1.commission-trait)
(use-trait staking-trait .staking-trait-v1.staking-trait)
(use-trait reserve-trait .reserve-trait-v1.reserve-trait)

;;-------------------------------------
;; Constants 
;;-------------------------------------

(define-constant ERR_REWARDS_LOCKED u203001)
(define-constant ERR_ALREADY_PROCESSED u203002)
(define-constant ERR_WRONG_COMMISSION u203003)

(define-constant DENOMINATOR_BPS u10000)

;;-------------------------------------
;; Variables 
;;-------------------------------------

(define-data-var ststx-commission-contract principal .commission-v2) 
(define-data-var ststxbtc-commission-contract principal .commission-btc-v1) 

;;-------------------------------------
;; Maps 
;;-------------------------------------

(define-map cycle-rewards-ststx
  uint
  {
    processed: bool,
    total-stx: uint,
    commission-stx: uint,
    protocol-stx: uint,
  }
)

(define-map cycle-rewards-ststxbtc
  uint
  {
    processed: bool,
    total-sbtc: uint,
    commission-sbtc: uint,
    protocol-sbtc: uint,
  }
)

;;-------------------------------------
;; Getters
;;-------------------------------------

(define-read-only (get-ststx-commission-contract)
  (var-get ststx-commission-contract)
)

(define-read-only (get-ststxbtc-commission-contract)
  (var-get ststxbtc-commission-contract)
)

(define-read-only (get-cycle-rewards-ststx (cycle uint))
  (default-to 
    {
      processed: false,
      total-stx: u0,
      commission-stx: u0,
      protocol-stx: u0,
    }  
    (map-get? cycle-rewards-ststx cycle)
  )
)

(define-read-only (get-cycle-rewards-ststxbtc (cycle uint))
  (default-to 
    {
      processed: false,
      total-sbtc: u0,
      commission-sbtc: u0,
      protocol-sbtc: u0,
    }  
    (map-get? cycle-rewards-ststxbtc cycle)
  )
)

(define-read-only (get-rewards-cycle)
  (let (
    (current-cycle (get-pox-cycle))

    (start-block-next-cycle (reward-cycle-to-burn-height (+ current-cycle u1)))
    (withdrawal-offset (contract-call? .data-core-v1 get-cycle-withdraw-offset))
    (next-rewards-unlock (- start-block-next-cycle withdrawal-offset))
  )
    (if (> burn-block-height next-rewards-unlock)
      (+ current-cycle u1)
      current-cycle
    )
  )
)

;;-------------------------------------
;; Add rewards
;;-------------------------------------

(define-public (add-rewards 
  (pool principal)
  (stx-amount uint) 
) 
  (let (
    (commission (contract-call? .data-pools-v1 get-pool-commission pool))
    (commission-amount (/ (* stx-amount commission) DENOMINATOR_BPS))
    (rewards-left (- stx-amount commission-amount))

    (pool-owner-commission (contract-call? .data-pools-v1 get-pool-owner-commission pool))
    (pool-owner-amount (/ (* commission-amount (get share pool-owner-commission)) DENOMINATOR_BPS))
    (commission-left (- commission-amount pool-owner-amount))

    (rewards-cycle (get-rewards-cycle))
    (cycle-ststx (get-cycle-rewards-ststx rewards-cycle))
  )
    (map-set cycle-rewards-ststx rewards-cycle (merge cycle-ststx { 
      total-stx: (+ (get total-stx cycle-ststx) stx-amount),
      commission-stx: (+ (get commission-stx cycle-ststx) commission-left),
      protocol-stx: (+ (get protocol-stx cycle-ststx) rewards-left),
    }))

    (print { action: "add-rewards-ststx", data: { cycle: (get-pox-cycle), pool: pool, stx-amount: stx-amount, rewards-cycle: rewards-cycle, commission: commission-amount, rewards: rewards-left, block-height: block-height } })
    
    (try! (stx-transfer? stx-amount contract-caller (as-contract tx-sender)))

    (if (> pool-owner-amount u0)
      (as-contract (stx-transfer? pool-owner-amount contract-caller (get receiver pool-owner-commission)))
      (ok true)
    )
  )
)

(define-public (add-rewards-sbtc
  (pool principal)
  (sbtc-amount uint) 
) 
  (let (
    (commission (contract-call? .data-pools-v1 get-pool-commission pool))
    (commission-amount (/ (* sbtc-amount commission) DENOMINATOR_BPS))
    (rewards-left (- sbtc-amount commission-amount))

    (pool-owner-commission (contract-call? .data-pools-v1 get-pool-owner-commission pool))
    (pool-owner-amount (/ (* commission-amount (get share pool-owner-commission)) DENOMINATOR_BPS))
    (commission-left (- commission-amount pool-owner-amount))

    (rewards-cycle (get-rewards-cycle))
    (cycle-ststxbtc (get-cycle-rewards-ststxbtc rewards-cycle))
  )
    (map-set cycle-rewards-ststxbtc rewards-cycle (merge cycle-ststxbtc { 
      total-sbtc: (+ (get total-sbtc cycle-ststxbtc) sbtc-amount),
      commission-sbtc: (+ (get commission-sbtc cycle-ststxbtc) commission-left),
      protocol-sbtc: (+ (get protocol-sbtc cycle-ststxbtc) rewards-left),
    }))

    (print { action: "add-rewards-sbtc", data: { cycle: (get-pox-cycle), pool: pool, stx-amount: sbtc-amount, rewards-cycle: rewards-cycle, commission: commission-amount, rewards: rewards-left, block-height: block-height } })

    (try! (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token transfer sbtc-amount contract-caller (as-contract tx-sender) none))

    (if (> pool-owner-amount u0)
      (as-contract (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token transfer pool-owner-amount tx-sender (get receiver pool-owner-commission) none))
      (ok true)
    )
  )
)

;;-------------------------------------
;; Process rewards
;;-------------------------------------

(define-public (process-rewards 
  (cycle uint)
  (commission-ststx-contract <commission-trait>) 
  (commission-ststxbtc-contract <commission-trait>) 
  (staking-contract <staking-trait>) 
  (reserve <reserve-trait>) 
)
  (let (
    (cycle-ststx (get-cycle-rewards-ststx cycle))
    (cycle-ststxbtc (get-cycle-rewards-ststxbtc cycle))
  )
    (try! (contract-call? .dao check-is-enabled))
    (try! (contract-call? .dao check-is-protocol (contract-of reserve)))
    (try! (contract-call? .dao check-is-protocol (contract-of commission-ststx-contract)))
    (try! (contract-call? .dao check-is-protocol (contract-of commission-ststxbtc-contract)))
    (try! (contract-call? .dao check-is-protocol (contract-of staking-contract)))

    (asserts! (> (get-rewards-cycle) cycle) (err ERR_REWARDS_LOCKED))
    (asserts! (not (get processed cycle-ststx)) (err ERR_ALREADY_PROCESSED))
    (asserts! (not (get processed cycle-ststxbtc)) (err ERR_ALREADY_PROCESSED))
    (asserts! (is-eq (var-get ststx-commission-contract) (contract-of commission-ststx-contract)) (err ERR_WRONG_COMMISSION))
    (asserts! (is-eq (var-get ststxbtc-commission-contract) (contract-of commission-ststxbtc-contract)) (err ERR_WRONG_COMMISSION))

    (if (> (get commission-stx cycle-ststx) u0)
      (try! (as-contract (contract-call? commission-ststx-contract add-commission staking-contract (get commission-stx cycle-ststx))))
      u0
    )
    (if (> (get protocol-stx cycle-ststx) u0)
      (try! (as-contract (stx-transfer? (get protocol-stx cycle-ststx) tx-sender (contract-of reserve))))
      false
    )

    (if (> (get commission-sbtc cycle-ststxbtc) u0)
      (try! (as-contract (contract-call? commission-ststxbtc-contract add-commission staking-contract (get commission-sbtc cycle-ststxbtc))))
      u0
    )
    (if (> (get protocol-sbtc cycle-ststxbtc) u0)
      (try! (as-contract (contract-call? .ststxbtc-tracking add-rewards (get protocol-sbtc cycle-ststxbtc))))
      true
    )

    (map-set cycle-rewards-ststx cycle (merge cycle-ststx { processed: true }))
    (map-set cycle-rewards-ststxbtc cycle (merge cycle-ststxbtc { processed: true }))

    (print { action: "process-rewards-ststx", data: { cycle: cycle, commission: (get commission-stx cycle-ststx), rewards: (get protocol-stx cycle-ststx), block-height: block-height } })
    (print { action: "process-rewards-ststxbtc", data: { cycle: cycle, commission: (get commission-sbtc cycle-ststxbtc), rewards: (get protocol-sbtc cycle-ststxbtc), block-height: block-height } })
    (ok true)
  )
)

;;-------------------------------------
;; Admin
;;-------------------------------------

(define-public (get-stx (requested-stx uint) (receiver principal))
  (begin
    (try! (contract-call? .dao check-is-protocol contract-caller))

    (try! (as-contract (stx-transfer? requested-stx tx-sender receiver)))
    (ok requested-stx)
  )
)

(define-public (get-sbtc (requested-sbtc uint) (receiver principal))
  (begin
    (try! (contract-call? .dao check-is-protocol contract-caller))

    (try! (as-contract (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token transfer requested-sbtc tx-sender receiver none)))

    (ok requested-sbtc)
  )
)

(define-public (set-ststx-commission-contract (contract principal))
  (begin
    (try! (contract-call? .dao check-is-protocol contract-caller))

    (var-set ststx-commission-contract contract)
    (ok true)
  )
)

(define-public (set-ststxbtc-commission-contract (contract principal))
  (begin
    (try! (contract-call? .dao check-is-protocol contract-caller))

    (var-set ststxbtc-commission-contract contract)
    (ok true)
  )
)

;;-------------------------------------
;; PoX Helpers
;;-------------------------------------

(define-read-only (get-pox-cycle)
  (contract-call? 'SP000000000000000000002Q6VF78.pox-4 current-pox-reward-cycle)
)

(define-read-only (reward-cycle-to-burn-height (cycle-id uint)) 
  (contract-call? 'SP000000000000000000002Q6VF78.pox-4 reward-cycle-to-burn-height cycle-id)
)
