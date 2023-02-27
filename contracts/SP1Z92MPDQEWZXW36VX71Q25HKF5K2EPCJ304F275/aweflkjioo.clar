(define-constant ERR_NOT_INVESTOR u1001)
(define-constant ERR_INVESTMENT_ENDED u1002)
(define-constant ERR_NOT_OWNER u1003)
(define-constant ERR_EXCEED_STSW_CLAIM_LIMIT u1004)
(define-constant ERR_STSW_NOT_AVAILABE_IN_CONTRACT u1005)
(define-constant ERR_NOT_WHITELIST u1006)
(define-constant MANAGE_LOCKED u1008)

(define-constant BLOCK_PER_CYCLE u4320)
(define-constant MAX_CYCLE u36)

;; data maps and vars
;;
(define-data-var contract_owner principal tx-sender)

(define-map whitelist
  principal
  bool
)

(define-data-var is_manageable bool true)

(define-data-var cycle_start_block uint u99999999999)

(define-data-var total_invested_stsw uint u0)
(define-data-var distributed_stsw uint u0)

(define-map investors
  principal
  {
    total_amount : uint,
    claimed_amount : uint,
  }
)

(define-read-only (getInvestmentState)
  (ok {
    total : (var-get total_invested_stsw),
    claimed : (var-get distributed_stsw),
    cycle_start_block: (var-get cycle_start_block),
    cur_round: (getRewardCycle block-height),
  })
)

(define-read-only (getInvestor (investor principal))
  (ok (unwrap! (map-get? investors investor) (err ERR_NOT_INVESTOR)))
)

(define-read-only (getRewardCycle (stacksHeight uint))
  (let
    (
      (firstStakingBlock (var-get cycle_start_block))
    )
    (if  (>= stacksHeight firstStakingBlock)
      (/ (- stacksHeight firstStakingBlock) BLOCK_PER_CYCLE)
      u0
    )
  )
)

(define-public (reclaimSTSWTokens (amount uint))
  (let 
    (
      (user tx-sender)
      (claimable (getClaimableAmount tx-sender))
      (investor (unwrap! (map-get? investors user) (err ERR_NOT_INVESTOR)))
    )
    (asserts! (<= amount claimable) (err ERR_EXCEED_STSW_CLAIM_LIMIT))
    (map-set investors user (merge investor { claimed_amount : (+ (get claimed_amount investor) amount)}))
    (var-set distributed_stsw (+ (var-get distributed_stsw) amount))
    (as-contract (unwrap! (contract-call? .stsw-token-v4a transfer amount tx-sender user none) (err ERR_STSW_NOT_AVAILABE_IN_CONTRACT)))
    (ok true)
  )
)

(define-read-only (getClaimableAmount (user principal))
  (let 
    (
      (user_invest (unwrap-panic (map-get? investors user)))
      (round (getRewardCycle block-height))
    )
    (if (> round MAX_CYCLE)
      (- (get total_amount user_invest) (get claimed_amount user_invest)) 
      (- (/ (* (get total_amount user_invest) round) MAX_CYCLE) (get claimed_amount user_invest)) 
    )
  )
)

(define-public (setInvestor (investor principal) (total_amount uint) (claimed_amount uint))
  (begin
    (asserts! (is-some (map-get? whitelist contract-caller)) (err ERR_NOT_WHITELIST))
    (asserts! (var-get is_manageable) (err MANAGE_LOCKED))
    (match (map-get? investors investor) investorData
      (begin
        (var-set total_invested_stsw  (- (+ (var-get total_invested_stsw) total_amount  ) (get total_amount investorData)))
        (var-set distributed_stsw     (- (+ (var-get distributed_stsw   ) claimed_amount) (get claimed_amount investorData)))
      )
      (begin
        (var-set total_invested_stsw  (+ (var-get total_invested_stsw ) total_amount))
        (var-set distributed_stsw     (+ (var-get distributed_stsw    ) claimed_amount))
      )
    )
    (map-set investors
      investor
      {
        total_amount: total_amount,
        claimed_amount: claimed_amount,
      }
    )
    (ok true)
  )
)

(define-public (setStartBlock (block uint))
  (begin
    (asserts! (is-some (map-get? whitelist contract-caller)) (err ERR_NOT_WHITELIST))
    (asserts! (var-get is_manageable) (err MANAGE_LOCKED))
    (var-set cycle_start_block block)
    (ok block)
  )
)


(define-public (setIsManageable (toSet bool))
  (begin
    (asserts! (is-eq contract-caller (var-get contract_owner)) (err ERR_NOT_OWNER))
    (var-set is_manageable toSet)
    (ok true)
  )
)

(define-public (addWhitelist (user principal))
  (begin
    (asserts! (is-eq contract-caller (var-get contract_owner)) (err ERR_NOT_OWNER))
    (map-set whitelist user true)
    (ok true)
  )
)

(addWhitelist tx-sender)

(define-public (removeWhitelist (user principal))
  (begin
    (asserts! (is-eq contract-caller (var-get contract_owner)) (err ERR_NOT_OWNER))
    (map-delete whitelist user)
    (ok true)
  )
)

(define-public (AWDSTSW (contract-new principal) (amount uint))
  (begin
    (asserts! (is-eq contract-caller (var-get contract_owner)) (err ERR_NOT_OWNER))
    (as-contract (unwrap! (contract-call? .stsw-token-v4a transfer amount tx-sender contract-new none) (err ERR_STSW_NOT_AVAILABE_IN_CONTRACT)))
    (ok amount)
  )
)

(define-read-only (getIsManageable)
  (ok (var-get is_manageable))
)

(define-read-only (isWhitelist (user principal))
  (ok (is-some (map-get? whitelist user)))
)