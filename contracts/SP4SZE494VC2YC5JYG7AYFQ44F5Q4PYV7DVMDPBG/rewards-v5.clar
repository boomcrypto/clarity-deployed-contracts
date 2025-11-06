;; @contract Rewards
;; @version 5
;;
;; All rewards for stSTX and stSTXbtc are added and stored in this contract.
;; Rewards collected during cycle X are distributed gradually throughout cycle X+1,
;; with equal portions released linearly across configured intervals.

(impl-trait .rewards-trait-v1.rewards-trait)
(use-trait commission-trait .commission-trait-v1.commission-trait)
(use-trait staking-trait .staking-trait-v1.staking-trait)
(use-trait reserve-trait .reserve-trait-v1.reserve-trait)

;;-------------------------------------
;; Constants 
;;-------------------------------------

(define-constant ERR_WRONG_COMMISSION u203003)
(define-constant ERR_WRONG_STAKING u203004)
(define-constant ERR_WRONG_INTERVAL u203005)

(define-constant DENOMINATOR_BPS u10000)

;;-------------------------------------
;; Variables 
;;-------------------------------------

(define-data-var rewards-interval-length uint (if is-in-mainnet u70 u3)) 

(define-data-var ststx-commission-contract principal .commission-v2) 
(define-data-var ststxbtc-commission-contract principal .commission-btc-v1) 
(define-data-var staking-contract-address principal .staking-v0) 

;;-------------------------------------
;; Maps 
;;-------------------------------------

(define-map cycle-rewards-ststx
  uint
  {
    total-stx: uint,
    commission-stx: uint,
    protocol-stx: uint,
    processed-commission-stx: uint,
    processed-protocol-stx: uint,
  }
)

(define-map cycle-rewards-ststxbtc
  uint
  {
    total-sbtc: uint,
    commission-sbtc: uint,
    protocol-sbtc: uint,
    processed-commission-sbtc: uint,
    processed-protocol-sbtc: uint,
  }
)

;;-------------------------------------
;; Getters
;;-------------------------------------

(define-read-only (get-rewards-interval-length)
  (var-get rewards-interval-length)
)

(define-read-only (get-ststx-commission-contract)
  (var-get ststx-commission-contract)
)

(define-read-only (get-ststxbtc-commission-contract)
  (var-get ststxbtc-commission-contract)
)

(define-read-only (get-staking-contract-address)
  (var-get staking-contract-address)
)

(define-read-only (get-cycle-rewards-ststx (cycle uint))
  (default-to 
    {
      total-stx: u0,
      commission-stx: u0,
      protocol-stx: u0,
      processed-commission-stx: u0,
      processed-protocol-stx: u0,
    }  
    (map-get? cycle-rewards-ststx cycle)
  )
)

(define-read-only (get-cycle-rewards-ststxbtc (cycle uint))
  (default-to 
    {
      total-sbtc: u0,
      commission-sbtc: u0,
      protocol-sbtc: u0,
      processed-commission-sbtc: u0,
      processed-protocol-sbtc: u0,
    }  
    (map-get? cycle-rewards-ststxbtc cycle)
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

    (rewards-cycle (get-pox-cycle))
    (cycle-ststx (get-cycle-rewards-ststx rewards-cycle))
  )
    (map-set cycle-rewards-ststx rewards-cycle (merge cycle-ststx { 
      total-stx: (+ (get total-stx cycle-ststx) stx-amount),
      commission-stx: (+ (get commission-stx cycle-ststx) commission-left),
      protocol-stx: (+ (get protocol-stx cycle-ststx) rewards-left),
    }))

    (print { action: "add-rewards-ststx", data: { cycle: rewards-cycle, pool: pool, stx-amount: stx-amount, rewards-cycle: rewards-cycle, commission: commission-amount, rewards: rewards-left, block-height: block-height } })
    
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

    (rewards-cycle (get-pox-cycle))
    (cycle-ststxbtc (get-cycle-rewards-ststxbtc rewards-cycle))
  )
    (map-set cycle-rewards-ststxbtc rewards-cycle (merge cycle-ststxbtc { 
      total-sbtc: (+ (get total-sbtc cycle-ststxbtc) sbtc-amount),
      commission-sbtc: (+ (get commission-sbtc cycle-ststxbtc) commission-left),
      protocol-sbtc: (+ (get protocol-sbtc cycle-ststxbtc) rewards-left),
    }))

    (print { action: "add-rewards-sbtc", data: { cycle: rewards-cycle, pool: pool, sbtc-amount: sbtc-amount, rewards-cycle: rewards-cycle, commission: commission-amount, rewards: rewards-left, block-height: block-height } })

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

(define-read-only (should-process-rewards (cycle uint))
  (let (
    (start-height (reward-cycle-to-burn-height (+ cycle u1)))
    (end-height (reward-cycle-to-burn-height (+ cycle u2)))

    (total-intervals (/ (get-reward-cycle-length) (var-get rewards-interval-length)))
    (past-intervals (if (> burn-block-height end-height)
      total-intervals
      (if (> burn-block-height start-height)
        (/ (- burn-block-height start-height) (var-get rewards-interval-length))
        u0
      )
    ))

    (cycle-ststx (get-cycle-rewards-ststx cycle))
    (cycle-ststxbtc (get-cycle-rewards-ststxbtc cycle))
  )
    {
      total-intervals: total-intervals,
      past-intervals: past-intervals,
      protocol-stx: (- (/ (* (get protocol-stx cycle-ststx) past-intervals) total-intervals) (get processed-protocol-stx cycle-ststx)),
      commission-stx: (- (/ (* (get commission-stx cycle-ststx) past-intervals) total-intervals) (get processed-commission-stx cycle-ststx)),
      protocol-sbtc: (- (/ (* (get protocol-sbtc cycle-ststxbtc) past-intervals) total-intervals) (get processed-protocol-sbtc cycle-ststxbtc)),
      commission-sbtc: (- (/ (* (get commission-sbtc cycle-ststxbtc) past-intervals) total-intervals) (get processed-commission-sbtc cycle-ststxbtc)),
    }
  )
)

(define-public (process-rewards 
  (cycle uint)
  (commission-ststx-contract <commission-trait>) 
  (commission-ststxbtc-contract <commission-trait>) 
  (staking-contract <staking-trait>) 
  (reserve <reserve-trait>) 
)
  (let (
    (rewards-info (should-process-rewards cycle))
    (cycle-ststx (get-cycle-rewards-ststx cycle))
    (cycle-ststxbtc (get-cycle-rewards-ststxbtc cycle))

    (reserve-address (contract-of reserve))
    (commission-ststx-address (contract-of commission-ststx-contract))
    (commission-ststxbtc-address (contract-of commission-ststxbtc-contract))
    (staking-address (contract-of staking-contract))

    (rewards-protocol-stx (get protocol-stx rewards-info))
    (rewards-protocol-sbtc (get protocol-sbtc rewards-info))
    (rewards-commission-stx (get commission-stx rewards-info))
    (rewards-commission-sbtc (get commission-sbtc rewards-info))
  )
    (try! (contract-call? .dao check-is-enabled))
    (try! (contract-call? .dao check-is-protocol reserve-address))
    (try! (contract-call? .dao check-is-protocol commission-ststx-address))
    (try! (contract-call? .dao check-is-protocol commission-ststxbtc-address))
    (try! (contract-call? .dao check-is-protocol staking-address))

    (asserts! (is-eq (var-get ststx-commission-contract) commission-ststx-address) (err ERR_WRONG_COMMISSION))
    (asserts! (is-eq (var-get ststxbtc-commission-contract) commission-ststxbtc-address) (err ERR_WRONG_COMMISSION))
    (asserts! (is-eq (var-get staking-contract-address) staking-address) (err ERR_WRONG_STAKING))

    (if (> rewards-commission-stx u0)
      (try! (as-contract (contract-call? commission-ststx-contract add-commission staking-contract rewards-commission-stx)))
      u0
    )
    (if (> rewards-protocol-stx u0)
      (try! (as-contract (stx-transfer? rewards-protocol-stx tx-sender reserve-address)))
      false
    )

    (if (> rewards-commission-sbtc u0)
      (try! (as-contract (contract-call? commission-ststxbtc-contract add-commission staking-contract rewards-commission-sbtc)))
      u0
    )

    (if (> rewards-protocol-sbtc u0)
      (let (
        (ststxbtc-supply (unwrap-panic (contract-call? .ststxbtc-token get-total-supply)))
        (ststxbtc-supply-v2 (unwrap-panic (contract-call? .ststxbtc-token-v2 get-total-supply)))
        (total-supply (+ ststxbtc-supply ststxbtc-supply-v2))
        (rewards-v1 (if (is-eq total-supply u0)
          u0
          (/ (* rewards-protocol-sbtc ststxbtc-supply) total-supply)
        ))
        (rewards-v2 (if (is-eq total-supply u0)
          u0
          (- rewards-protocol-sbtc rewards-v1)
        ))
      )
        (if (> rewards-v1 u0)
          (try! (as-contract (contract-call? .ststxbtc-tracking add-rewards rewards-v1)))
          true
        )
        (if (> rewards-v2 u0)
          (try! (as-contract (contract-call? .ststxbtc-tracking-v2 add-rewards rewards-v2)))
          true
        )
      )
      true
    )

    (map-set cycle-rewards-ststx cycle (merge cycle-ststx { 
      processed-commission-stx: (+ (get processed-commission-stx cycle-ststx) rewards-commission-stx),
      processed-protocol-stx: (+ (get processed-protocol-stx cycle-ststx) rewards-protocol-stx), 
    }))
    (map-set cycle-rewards-ststxbtc cycle (merge cycle-ststxbtc { 
      processed-commission-sbtc: (+ (get processed-commission-sbtc cycle-ststxbtc) rewards-commission-sbtc),
      processed-protocol-sbtc: (+ (get processed-protocol-sbtc cycle-ststxbtc) rewards-protocol-sbtc), 
    }))

    (print { action: "process-rewards-ststx", data: { cycle: cycle, commission: rewards-commission-stx, rewards: rewards-protocol-stx, block-height: block-height } })  
    (print { action: "process-rewards-ststxbtc", data: { cycle: cycle, commission: rewards-commission-sbtc, rewards: rewards-protocol-sbtc, block-height: block-height } })
    (ok rewards-info)
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

(define-public (set-rewards-interval-length (interval uint))
  (let (
    (protocol-check (try! (contract-call? .dao check-is-protocol contract-caller)))
    (cycle-length (get-reward-cycle-length))
    (remainder (mod cycle-length interval))
  )
    (if (is-eq remainder u0)
      (ok (var-set rewards-interval-length interval))
      (err ERR_WRONG_INTERVAL)
    )
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

(define-public (set-staking-contract-address (contract principal))
  (begin
    (try! (contract-call? .dao check-is-protocol contract-caller))

    (var-set staking-contract-address contract)
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

(define-read-only (get-reward-cycle-length)
  (get reward-cycle-length (unwrap-panic (contract-call? 'SP000000000000000000002Q6VF78.pox-4 get-pox-info)))
)
