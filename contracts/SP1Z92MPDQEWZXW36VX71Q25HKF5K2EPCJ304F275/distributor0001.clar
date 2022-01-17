
(define-constant ERR_NOT_INVESTER u1001)
(define-constant ERR_INVESTMENT_ENDED u1002)
(define-constant ERR_NOT_OWNER u1003)
(define-constant ERR_EXCEED_LP_RECLAIM_LIMIT u1004)
(define-constant ERR_EXCEED_STSW_CLAIM_LIMIT u1005)
(define-constant ERR_LP_NOT_AVAILABE_IN_CONTRACT u1006)


(define-constant BLOCK_PER_CYCLE u4320)
(define-constant MAX_CYCLE u36)

(define-constant INVESTER_LIST 
  (list
    'SPDP8YK19CE3G3J2PGCRWXK770VQC8P5GC341JZM
    'SP3Q3Y5E2S782ZWCQNQM6S66FCBVB4SS764RMV6KF
    'SPR8ZXFPMW6CGWQVTKM3BSZYGRZ3JDHV61CCVRXN
    'SP2QM2TZP4DD8KP2MX6C5TA5P82S3KXZM9NV267RN
    'SP1420SJVGARGC631S7NSDJJHX85ZZXD6Q3CF13K6
    'SP3M0Z1ZFCW7P3VXYT1ACRHE4GV7926SYZQ7ZBV03
    'SPA7KHZWAV9HZWA6T8VC242D23VDK521M61YGEMD
    'SPJ2VG1VQHTWSS7D7MPYKGPM8CBCVSVH53D6WDBR
    ))
(define-constant INVESTER_COMPANY 'SPDP8YK19CE3G3J2PGCRWXK770VQC8P5GC341JZM)

;; data maps and vars
;;
(define-data-var contract_owner principal tx-sender)

(define-data-var cycle_start_block uint u0)

(define-data-var total_invested_stx uint u0)

(define-data-var invest_ended bool false)

(define-data-var initial_lp_amount uint u0)

(define-data-var now_invested_lp uint u0)

(define-map investers
  principal
  {
    invested_stx : uint,
    invested_lp : uint,
    claimable_stsw : uint,
    claimed_lp : uint,
    claimed_stsw : uint
  }
)

(begin
  (map-set investers
    'SPDP8YK19CE3G3J2PGCRWXK770VQC8P5GC341JZM
    {
      invested_stx : u0,
      invested_lp : u0,
      claimable_stsw : u0,
      claimed_lp : u0,
      claimed_stsw : u0
    }
  )
  (map-set investers
    'SP3Q3Y5E2S782ZWCQNQM6S66FCBVB4SS764RMV6KF
    {
      invested_stx : u0,
      invested_lp : u0,
      claimable_stsw : u0,
      claimed_lp : u0,
      claimed_stsw : u0
    }
  )
  (map-set investers
    'SPR8ZXFPMW6CGWQVTKM3BSZYGRZ3JDHV61CCVRXN
    {
      invested_stx : u0,
      invested_lp : u0,
      claimable_stsw : u0,
      claimed_lp : u0,
      claimed_stsw : u0
    }
  )
  (map-set investers
    'SP2QM2TZP4DD8KP2MX6C5TA5P82S3KXZM9NV267RN
    {
      invested_stx : u0,
      invested_lp : u0,
      claimable_stsw : u0,
      claimed_lp : u0,
      claimed_stsw : u0
    }
  )
  (map-set investers
    'SP1420SJVGARGC631S7NSDJJHX85ZZXD6Q3CF13K6
    {
      invested_stx : u0,
      invested_lp : u0,
      claimable_stsw : u0,
      claimed_lp : u0,
      claimed_stsw : u0
    }
  )
  (map-set investers
    'SP3M0Z1ZFCW7P3VXYT1ACRHE4GV7926SYZQ7ZBV03
    {
      invested_stx : u0,
      invested_lp : u0,
      claimable_stsw : u0,
      claimed_lp : u0,
      claimed_stsw : u0
    }
  )
  (map-set investers
    'SPA7KHZWAV9HZWA6T8VC242D23VDK521M61YGEMD
    {
      invested_stx : u0,
      invested_lp : u0,
      claimable_stsw : u0,
      claimed_lp : u0,
      claimed_stsw : u0
    }
  )
  (map-set investers
    'SPJ2VG1VQHTWSS7D7MPYKGPM8CBCVSVH53D6WDBR
    {
      invested_stx : u0,
      invested_lp : u0,
      claimable_stsw : u0,
      claimed_lp : u0,
      claimed_stsw : u0
    }
  )
)

(define-public (invest (amount_stx uint))
  (let
    (
      (invester (unwrap! (map-get? investers contract-caller) (err ERR_NOT_INVESTER)))
      (invested_amount (get invested_stx invester))
    )
    (asserts! (not (var-get invest_ended)) (err ERR_INVESTMENT_ENDED))
    (try! (stx-transfer? amount_stx contract-caller (as-contract tx-sender)))
    (map-set investers contract-caller (merge invester { invested_stx : (+ invested_amount amount_stx)}))
    (var-set total_invested_stx (+ (var-get total_invested_stx) amount_stx))
    (ok true)
  )
)

(define-read-only (get-invester (invester principal))
  (ok (unwrap! (map-get? investers invester) (err ERR_NOT_INVESTER)))
)

(define-read-only (get-total-invest)
  (ok (var-get total_invested_stx))
)

(define-read-only (get-reward-cycle (stacksHeight uint))
  (let
    (
      (firstStakingBlock (var-get cycle_start_block))
      (rcLen BLOCK_PER_CYCLE)
    )
    (if (and (>= stacksHeight firstStakingBlock) (not (is-eq firstStakingBlock u0)))
      (/ (- stacksHeight firstStakingBlock) rcLen)
      u0
    )
  )
)

(define-public (reclaim-lp-tokens (lp_amount uint))
  (let 
    (
      (claimable_lp (get-claimable-amount contract-caller))
      (user contract-caller)
      (invester (unwrap! (map-get? investers user) (err ERR_NOT_INVESTER)))
    )
    (asserts! (< lp_amount claimable_lp) (err ERR_EXCEED_LP_RECLAIM_LIMIT))
    (as-contract (unwrap! (contract-call? .liquidity-token-stx-stsw transfer lp_amount tx-sender user none) (err ERR_LP_NOT_AVAILABE_IN_CONTRACT)))
    (map-set investers user (merge invester { claimed_lp : (+ (get claimed_lp invester) lp_amount)}))
    (var-set now_invested_lp (- (var-get now_invested_lp) lp_amount))
    (ok true)
  )
)

(define-public (claim-stsw-tokens (stsw_amount uint))
  (let 
    (
      (user contract-caller)
      (invester (unwrap! (map-get? investers user) (err ERR_NOT_INVESTER)))
    )
    (asserts! (< stsw_amount (get claimable_stsw invester)) (err ERR_EXCEED_STSW_CLAIM_LIMIT))
    (as-contract (unwrap! (contract-call? .stsw-token-v4a transfer stsw_amount tx-sender user none) (err ERR_LP_NOT_AVAILABE_IN_CONTRACT)))
    (map-set investers user (merge invester 
        { 
          claimed_stsw : (+ (get claimed_stsw invester) stsw_amount),
          claimable_stsw : (- (get claimable_stsw invester) stsw_amount)
        }))
    (ok true)
  )
)

(define-read-only (get-claimable-amount (user principal))
  (let 
    (
      (user_invest (unwrap-panic (map-get? investers user)))
      (round (get-reward-cycle block-height))
    )
    (if (> round MAX_CYCLE)
      (- (get invested_lp user_invest) (get claimed_lp user_invest)) 
      (- (/ (* (get invested_lp user_invest) round) MAX_CYCLE) (get claimed_lp user_invest)) 
    )
  )
)

(define-public (add-liquidity (x uint) (y uint))
  (begin
    (asserts! (is-eq contract-caller (var-get contract_owner)) (err ERR_NOT_OWNER))
    (asserts! (not (var-get invest_ended)) (err ERR_INVESTMENT_ENDED))
    (try! (as-contract (contract-call? .stackswap-swap-v5k add-to-position .wstx-token-v4a .stsw-token-v4a .liquidity-token-stx-stsw x y)))
    (let 
      (
        (lp_amount (unwrap-panic (contract-call? .liquidity-token-stx-stsw get-balance (as-contract tx-sender))))
      )
      (var-set initial_lp_amount lp_amount)
      (var-set now_invested_lp lp_amount)
      (var-set invest_ended true)
      (var-set cycle_start_block block-height)
      (fold set-initial-lp-closure INVESTER_LIST (/ (* lp_amount u85) u100))
      (let 
        (
          (company (unwrap-panic (map-get? investers INVESTER_COMPANY)))
        )
        (map-set investers INVESTER_COMPANY (merge company { invested_lp : (+ (get invested_lp company) (/ (* lp_amount u15) u100))}))
        (ok true)
      )
    )
  )
)

(define-private (set-initial-lp-closure (user principal) (amount uint))
  (let
    (
      (total_invest (var-get total_invested_stx))
      (invester (unwrap-panic (map-get? investers user)))
    )
    (map-set investers user (merge invester { invested_lp : (/ (* amount (get invested_stx invester)) total_invest)}))
    amount
  )
)

(define-public (invest-to-farm (month uint))
  (let
    (
      (lp_amount (unwrap-panic (contract-call? .liquidity-token-stx-stsw get-balance (as-contract tx-sender))))
    )
    (asserts! (is-eq contract-caller (var-get contract_owner)) (err ERR_NOT_OWNER))
    (as-contract (try! (contract-call? .stackswap-farming-v1l stake-tokens lp_amount .liquidity-token-stx-stsw month)))
    (ok true)
  )
)

(define-public (claim-from-farm (round uint))
  (let
    (
      (stsw_amount_before (unwrap-panic (contract-call? .stsw-token-v4a get-balance (as-contract tx-sender))))
    )
    (asserts! (is-eq contract-caller (var-get contract_owner)) (err ERR_NOT_OWNER))
    (as-contract (try! (contract-call? .stackswap-farming-v1l claim-staking-reward round .liquidity-token-stx-stsw)))
    (let
      (
        (stsw_amount_after (unwrap-panic (contract-call? .stsw-token-v4a get-balance (as-contract tx-sender))))
        (reward_stx (- stsw_amount_after stsw_amount_before))
      )
      (fold set-farming-reward-closure INVESTER_LIST reward_stx)
    )
    (ok true)
  )
)

(define-public (unstake-from-farming (round uint))
  (begin
    (asserts! (is-eq contract-caller (var-get contract_owner)) (err ERR_NOT_OWNER))
    (as-contract (try! (contract-call? .stackswap-farming-v1l unstake-from-farming round .liquidity-token-stx-stsw)))
    (ok true)
  )
)

(define-private (set-farming-reward-closure (user principal) (amount uint))
  (let
    (
      (invester (unwrap-panic (map-get? investers user)))
    )
    (map-set investers user (merge invester { claimable_stsw : (+ (get claimable_stsw invester) (/ (* amount (- (get invested_lp invester) (get claimed_lp invester))) (var-get now_invested_lp)))}))
    amount
  )
)

(define-public (awd-lp (contract-new principal))
  (let
    (
      (lp_amount (unwrap-panic (contract-call? .liquidity-token-stx-stsw get-balance (as-contract tx-sender))))
    )
    (asserts! (is-eq contract-caller (var-get contract_owner)) (err ERR_NOT_OWNER))
    (as-contract (unwrap! (contract-call? .liquidity-token-stx-stsw transfer lp_amount tx-sender contract-new none) (err ERR_LP_NOT_AVAILABE_IN_CONTRACT)))
    (ok lp_amount)
  )
)

(define-public (awd-stsw (contract-new principal) (amount uint))
  (begin
    (asserts! (is-eq contract-caller (var-get contract_owner)) (err ERR_NOT_OWNER))
    (as-contract (unwrap! (contract-call? .stsw-token-v4a transfer amount tx-sender contract-new none) (err ERR_LP_NOT_AVAILABE_IN_CONTRACT)))
    (ok amount)
  )
)