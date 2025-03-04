;; TOKENS
(define-fungible-token staked-lp-token)

;; ERRORS
(define-constant ERR-SENDER-MISMATCH (err u60000))
(define-constant ERR-LP-TOKEN-SUPPLY (err u60001))
(define-constant ERR-STAKED-LP-TOKEN-USER-NOT-ENOUGH-BALANCE (err u60002))
(define-constant ERR-MISSING-WITHDRAWAL (err u60003))
(define-constant ERR-WITHDRAWAL-NOT-FINALIZED (err u60004))
(define-constant ERR-ZERO-LP-TOKEN-STAKE (err u60005))
(define-constant ERR-ZERO-STAKED-LP-TOKEN-UNSTAKE (err u60006))
(define-constant ERR-NOT-GOVERNANCE (err u60007))
(define-constant ERR-INTEREST-PARAMS (err u60008))
(define-constant ERR-STAKING-DISABLED (err u60009))

;; Constants
(define-constant SUCCESS (ok true))

;; lp-token
(define-constant token-prefix "gusdc")

;; staking storages
(define-data-var withdrawal-finalization-period uint u100)
(define-data-var unfinalized-withdrawals {lp-tokens: uint, shares: uint} {lp-tokens: u0, shares: u0})
(define-map user-withdrawal-index principal uint)
(define-map user-withdrawals { user: principal, index: uint } { withdrawal-shares: uint, finalization-at: uint })
(define-data-var total-lp-tokens-staked uint u0)

;; governance
(define-public (update-withdrawal-finalization-period (new-value uint))
  (begin
    (asserts! (is-eq contract-caller (contract-call? .state-v1 get-governance)) ERR-NOT-GOVERNANCE)
    (print {
      sender: contract-caller,
      old-withdrawal-finalization-period: (var-get withdrawal-finalization-period),
      new-withdrawal-finalization-period: new-value,
      action: "update-withdrawal-finalization-period"
    })
    (var-set withdrawal-finalization-period new-value)
    SUCCESS
  )
)

;; SIP-10 LP-TOKEN FUNCTIONS
(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (begin
    (asserts! (or (is-eq tx-sender sender) (is-eq contract-caller sender)) ERR-SENDER-MISMATCH)
    (asserts! (contract-call? .state-v1 is-staking-enabled) ERR-STAKING-DISABLED)
    (match memo to-print (print to-print) 0x)
    (try! (ft-transfer? staked-lp-token amount sender recipient))
    (print {
      sender: sender,
      recipient: recipient,
      amount: amount,
      memo: memo,
      action: "staked-lp-token-transfer"
    })
    SUCCESS
  )
)

(define-read-only (get-balance (account principal))
  (ok (ft-get-balance staked-lp-token account))
)

(define-read-only (get-total-supply)
  (ok (ft-get-supply staked-lp-token))
)

(define-read-only (get-name)
  (ok (concat token-prefix " - Granite Staked LP Token"))
)

(define-read-only (get-symbol)
  (ok (concat token-prefix "-GSLP"))
)

(define-read-only (get-decimals)
  ;; Lp token decimals -> market asset decimals
  (contract-call? .state-v1 get-decimals)
)

(define-read-only (get-token-uri)
  (ok none)
)

;; Read only functions
;; lp-tokens * total-staked-lp-tokens / total-lp-token
(define-read-only (convert-to-staked-lp-tokens (lp-tokens uint) (round-up bool))
  (let (
      (total-staked-lp-tokens (ft-get-supply staked-lp-token))
      (total-lp-tokens (var-get total-lp-tokens-staked))
    )
    (if (is-eq total-staked-lp-tokens u0)
      lp-tokens
      (contract-call? .math-v1 divide round-up (* total-staked-lp-tokens lp-tokens) total-lp-tokens)
    )
))

;; staked-lp-tokens * total-lp-tokens / total-staked-lp-tokens
(define-read-only (convert-to-lp-tokens (staked-lp-tokens uint) (round-up bool))
  (let (
      (total-staked-lp-tokens (ft-get-supply staked-lp-token))
      (total-lp-tokens (var-get total-lp-tokens-staked))
    )
    (if (is-eq total-lp-tokens u0)
      staked-lp-tokens
      (contract-call? .math-v1 divide round-up (* staked-lp-tokens total-lp-tokens) total-staked-lp-tokens)
    )
))

;; lp-tokens * total-withdraw-share / total-lp-tokens-in-withdrawal
(define-read-only (convert-to-withdrawal-shares (lp-tokens uint))
  (let (
      (unfinalized-withdrawals-info (var-get unfinalized-withdrawals))
      (total-withdrawal-shares (get shares unfinalized-withdrawals-info))
      (total-withdrawal-lp-tokens (get lp-tokens unfinalized-withdrawals-info))
    )
    (if (is-eq total-withdrawal-shares u0)
      lp-tokens
      (contract-call? .math-v1 divide false (* total-withdrawal-shares lp-tokens) total-withdrawal-lp-tokens)
    )
))

;; withdrawal-shares * total-withdrawal-lp-tokens / total-withdrawal-shares
(define-read-only (convert-to-withdrawal-lp-tokens (withdrawal-shares uint))
  (let (
      (unfinalized-withdrawals-info (var-get unfinalized-withdrawals))
      (total-withdrawal-shares (get shares unfinalized-withdrawals-info))
      (total-withdrawal-lp-tokens (get lp-tokens unfinalized-withdrawals-info))
    )
    (if (is-eq total-withdrawal-lp-tokens u0)
      u0
      (contract-call? .math-v1 divide false (* withdrawal-shares total-withdrawal-lp-tokens) total-withdrawal-shares)
    )
))

(define-read-only (get-withdrawal (user principal) (index uint))
  (map-get? user-withdrawals {user: user, index: index})
)

(define-read-only (get-active-staked-lp-tokens)
  (var-get total-lp-tokens-staked)
)

(define-read-only (get-total-staked-lp-tokens)
  (+ (var-get total-lp-tokens-staked) (get lp-tokens (var-get unfinalized-withdrawals)))
)

(define-read-only (get-withdrawal-finalization-period)
  (var-get withdrawal-finalization-period)
)

;; Public functions
(define-public (stake (lp-tokens uint))
  (let (
      (staking-enabled (try! (check-staking-enabled)))
      (staked-lp-tokens-to-mint (convert-to-staked-lp-tokens lp-tokens false))
    )
    (try! (accrue-interest))
    (asserts! (> lp-tokens u0) ERR-ZERO-LP-TOKEN-STAKE)
    ;; transfer lp-tokens to staking contract and mint staked lp tokens to user
    (try! (contract-call? .state-v1 transfer lp-tokens contract-caller (as-contract contract-caller) none))
    (try! (ft-mint? staked-lp-token staked-lp-tokens-to-mint contract-caller))
    (var-set total-lp-tokens-staked (+ (var-get total-lp-tokens-staked) lp-tokens))
    (print {
      sender: contract-caller,
      lp-tokens: lp-tokens,
      staked-lp-tokens: staked-lp-tokens-to-mint,
      action: "lp-token-staked"
    })
    SUCCESS
))

(define-public (increase-lp-staked-balance (lp-tokens uint))
  (begin
    (try! (contract-call? .state-v1 is-allowed-contract contract-caller))
    (var-set total-lp-tokens-staked (+ (var-get total-lp-tokens-staked) lp-tokens))
    (print {
      action: "increase-lp-staked-balance",
      amount: lp-tokens,
    })
    SUCCESS
  )
)


(define-public (slash-total-staked-lp-tokens (lp-tokens uint))
  (let (
      (total-staked-lp-tokens (get-total-staked-lp-tokens))
      (scaling-factor (contract-call? .constants-v1 get-scaling-factor))
      (unfinalized-withdrawal-info (var-get unfinalized-withdrawals))
      (withdrawal-lp-tokens (get lp-tokens unfinalized-withdrawal-info))
      (withdrawal-lp-token-rate (/ (* withdrawal-lp-tokens scaling-factor) total-staked-lp-tokens))
      (withdrawal-lp-tokens-to-slash (/ (* lp-tokens withdrawal-lp-token-rate) scaling-factor))
      (active-staked-lp-tokens-to-slash (- lp-tokens withdrawal-lp-tokens-to-slash))
    ) 
    (try! (contract-call? .state-v1 is-allowed-contract contract-caller))
    (var-set total-lp-tokens-staked (- (var-get total-lp-tokens-staked) active-staked-lp-tokens-to-slash))
    (if (is-eq withdrawal-lp-tokens withdrawal-lp-tokens-to-slash)
      (var-set unfinalized-withdrawals {
        lp-tokens: u0,
        shares: u0,
      })
      (var-set unfinalized-withdrawals {
        lp-tokens: (- withdrawal-lp-tokens withdrawal-lp-tokens-to-slash),
        shares: (get shares unfinalized-withdrawal-info),
      })
    )
    (print {
      action: "slash-total-staked-lp-tokens",
      amount: lp-tokens,
    })
    SUCCESS
  )
)

(define-public (reconcile-lp-token-balance)
  (let (
      (current-balance (unwrap! (contract-call? .state-v1 get-balance (as-contract contract-caller)) ERR-LP-TOKEN-SUPPLY))
      (staked-lp-tokens (var-get total-lp-tokens-staked))
      (accounted-lp-tokens (+ staked-lp-tokens (get lp-tokens (var-get unfinalized-withdrawals))))
    )
    (try! (accrue-interest))
    (asserts! (is-eq (contract-call? .state-v1 get-governance) contract-caller) ERR-NOT-GOVERNANCE)
    (if (>= current-balance accounted-lp-tokens)
      (var-set total-lp-tokens-staked (+ staked-lp-tokens (- current-balance accounted-lp-tokens)))
      (var-set total-lp-tokens-staked (- staked-lp-tokens (- accounted-lp-tokens current-balance)))
    )
    (print {
      action: "reconcile-lp-token-balance",
      previous-staked-lp-tokens: staked-lp-tokens,
      new-staked-lp-tokens: (var-get total-lp-tokens-staked)
    })  
    SUCCESS
  )
)

(define-public (initiate-unstake (staked-lp-tokens uint))
  (let (
      (staking-enabled (try! (check-staking-enabled)))
      (user contract-caller)
      (user-total-balance (ft-get-balance staked-lp-token user))
      (withdrawal-index (default-to u0 (map-get? user-withdrawal-index user)))
      (finalization-at (+ stacks-block-height (var-get withdrawal-finalization-period)))
      (lp-tokens-to-return (convert-to-lp-tokens staked-lp-tokens false))
      (withdraw-shares (convert-to-withdrawal-shares lp-tokens-to-return))
      (unfinalized-withdrawal-info (var-get unfinalized-withdrawals))
    )
    (try! (accrue-interest))
    (asserts! (> staked-lp-tokens u0) ERR-ZERO-STAKED-LP-TOKEN-UNSTAKE)
    (asserts! (>= user-total-balance staked-lp-tokens) ERR-STAKED-LP-TOKEN-USER-NOT-ENOUGH-BALANCE)
    (map-set user-withdrawal-index user (+ withdrawal-index u1))
    (try! (ft-burn? staked-lp-token staked-lp-tokens user))
    (map-set user-withdrawals {user: user, index: withdrawal-index} {withdrawal-shares: withdraw-shares, finalization-at: finalization-at})
    (var-set total-lp-tokens-staked (- (var-get total-lp-tokens-staked) lp-tokens-to-return))
    (var-set unfinalized-withdrawals {
      lp-tokens: (+ (get lp-tokens unfinalized-withdrawal-info) lp-tokens-to-return),
      shares: (+ (get shares unfinalized-withdrawal-info) withdraw-shares),
    })
    (print {
      sender: user,
      index: withdrawal-index,
      amount: staked-lp-tokens,
      action: "initiated-unstake"
    })
    (ok withdrawal-index)
))

(define-public (finalize-unstake (index uint))
  (let (
      (staking-enabled (try! (check-staking-enabled)))
      (user contract-caller)
      (unfinalized-withdrawal-info (var-get unfinalized-withdrawals))
      (withdrawal (unwrap! (map-get? user-withdrawals {user: user, index: index}) ERR-MISSING-WITHDRAWAL))
      (withdraw-shares (get withdrawal-shares withdrawal))
      (lp-tokens-to-return (convert-to-withdrawal-lp-tokens withdraw-shares))
      (finalization-at (get finalization-at withdrawal))
    )
    (asserts! (>= stacks-block-height finalization-at) ERR-WITHDRAWAL-NOT-FINALIZED)
    (try! (if (> lp-tokens-to-return u0)
      (as-contract (contract-call? .state-v1 transfer lp-tokens-to-return (as-contract contract-caller) user none))
      SUCCESS
    ))
    (var-set unfinalized-withdrawals {
      lp-tokens: (- (get lp-tokens unfinalized-withdrawal-info) lp-tokens-to-return),
      shares: (- (get shares unfinalized-withdrawal-info) withdraw-shares),
    })
    (map-delete user-withdrawals {user: user, index: index})
     (print {
      sender: user,
      index: index,
      lp-tokens: lp-tokens-to-return,
      action: "finalize-unstake"
    })
    SUCCESS
  )
)

;; private functions
(define-private (accrue-interest)
  (let (
    (accrue-interest-params (unwrap! (contract-call? .state-v1 get-accrue-interest-params) ERR-INTEREST-PARAMS))
    (accrued-interest (try! (contract-call? .linear-kinked-ir-v1 accrue-interest
      (get last-accrued-block-time accrue-interest-params)
      (get lp-interest accrue-interest-params)
      (get staked-interest accrue-interest-params)
      (try! (contract-call? .staking-reward-v1 calculate-staking-reward-percentage (get-active-staked-lp-tokens)))
      (get protocol-interest accrue-interest-params)
      (get protocol-reserve-percentage accrue-interest-params)
      (get total-assets accrue-interest-params)))
    )
  )
  (contract-call? .state-v1 set-accrued-interest accrued-interest)
))

(define-private (check-staking-enabled)
  (if (is-eq (contract-call? .state-v1 is-staking-enabled) true)
    (ok true)
    ERR-STAKING-DISABLED
  )
)
