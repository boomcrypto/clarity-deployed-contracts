;; Title: BME024 CPMM Categorical Market Predictions 
;; Synopsis:
;; Implements CPMM binary and categorical prediciton markets.
;; Description:
;; Market creation allows a new binary or categorical market to be set up.
;; Off chain market data is verifiable via the markets data hash.
;; Markets run in a specific token (stx, sbtc, bmg etc) and the market token has 
;; to be enabled by the DAO.
;; Market creation can be gated via market proof and a market creator can
;; set their own fee up to a max fee amount determined by the DAO.
;; Anyone with the required token can buy shares. Resolution process begins via a call gated 
;; to the DAO controlled resolution agent address. The resolution can be challenged by anyone with a stake in the market
;; If a challenge is made the dispute resolution process begins which requires a DAO vote
;; to resolve - the outcome of the vote resolve the market and sets the outcome. 
;; If the dispute window passes without challenge or once the vote concludes the market is fully
;; resolved and claims can then be made.
;; Optional hedge strategy - the execute-hedge strategy can be run during market cool down period. The execute-hedge
;; function will call the market specific hedge strategy if supplied or the default startegy otherwise.
;; The hedge strategy can be switched off by the dao.

(use-trait ft-token 'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.sip-010-trait-ft-standard.sip-010-trait)
(impl-trait 'SP22NW0RYCW4GFZRPE8VGJRCKGQMRMMX4903A2TRG.prediction-market-trait.prediction-market-trait)
(use-trait hedge-trait 'SP22NW0RYCW4GFZRPE8VGJRCKGQMRMMX4903A2TRG.hedge-trait.hedge-trait)
(use-trait ft-velar-token 'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.sip-010-trait-ft-standard.sip-010-trait)

;; ---------------- CONSTANTS & TYPES ----------------
;; Market Types (1 => categorical market)
(define-constant MARKET_TYPE u1)
(define-constant DEFAULT_MARKET_DURATION u144) ;; ~1 day in Bitcoin blocks
(define-constant DEFAULT_COOL_DOWN_PERIOD u144) ;; ~1 day in Bitcoin blocks

(define-constant RESOLUTION_OPEN u0)
(define-constant RESOLUTION_RESOLVING u1)
(define-constant RESOLUTION_DISPUTED u2)
(define-constant RESOLUTION_RESOLVED u3)

(define-constant err-unauthorised (err u10000))
(define-constant err-invalid-market-type (err u10001))
(define-constant err-amount-too-low (err u10002))
(define-constant err-wrong-market-type (err u10003))
(define-constant err-already-concluded (err u10004))
(define-constant err-market-not-found (err u10005))
(define-constant err-user-not-winner-or-claimed (err u10006))
(define-constant err-user-not-staked (err u10008))
(define-constant err-market-not-concluded (err u10009))
(define-constant err-insufficient-balance (err u10011))
(define-constant err-insufficient-contract-balance (err u10012))
(define-constant err-user-share-is-zero (err u10013))
(define-constant err-dao-fee-bips-is-zero (err u10014))
(define-constant err-disputer-must-have-stake (err u10015))
(define-constant err-dispute-window-elapsed (err u10016))
(define-constant err-market-not-resolving (err u10017))
(define-constant err-market-not-open (err u10018))
(define-constant err-dispute-window-not-elapsed (err u10019))
(define-constant err-market-wrong-state (err u10020))
(define-constant err-invalid-token (err u10021))
(define-constant err-max-market-fee-bips-exceeded (err u10022))
(define-constant err-category-not-found (err u10023))
(define-constant err-too-few-categories (err u10024))
(define-constant err-element-expected (err u10025))
(define-constant err-winning-stake-not-zero (err u10026))
(define-constant err-losing-stake-is-zero (err u10027))
(define-constant err-amount-too-high (err u10029))
(define-constant err-fee-too-high (err u10030))
(define-constant err-slippage-too-high (err u10031))
(define-constant err-seed-amount-not-divisible (err u10032))
(define-constant err-overbuy (err u10034))
(define-constant err-token-not-configured (err u10035))
(define-constant err-seed-too-small (err u10036))
(define-constant err-already-hedged (err u10037))
(define-constant err-hedging-disabled (err u10038))
(define-constant err-hedge-unauthorised (err u10100))
(define-constant err-hedge-window (err u10101))
(define-constant err-hedge-already (err u10102))
(define-constant err-hedge-bad-prediction (err u10103))
(define-constant err-hedge-bad-token (err u10104))
(define-constant err-hedge-exec-mismatch (err u10105))
(define-constant err-insufficient-liquidity (err u11041))
(define-constant err-arithmetic (err u11043))

(define-constant marketplace .bme040-0-shares-marketplace)
(define-constant MIN_POOL u1)


(define-data-var market-counter uint u0)
(define-data-var dispute-window-length uint u144)
(define-data-var dev-fee-bips uint u200)
(define-data-var dao-fee-bips uint u200)
(define-data-var market-fee-bips-max uint u1000)
(define-data-var dev-fund principal tx-sender)
(define-data-var resolution-agent principal tx-sender)
(define-data-var dao-treasury principal tx-sender)
(define-data-var creation-gated bool true)
(define-data-var resolution-timeout uint u1000) ;; 1000 blocks (~9 days)
(define-data-var default-hedge-executor principal .bme032-0-scalar-strategy-hedge)
(define-data-var hedging-enabled bool true)

;; Data structure for each Market
;; outcome: winning category
(define-map markets
  uint
  {
		market-data-hash: (buff 32),
    token: principal,
    treasury: principal,
    creator: principal,
    market-fee-bips: uint,
    resolution-state: uint, ;; "open", "resolving", "disputed", "concluded"
    resolution-burn-height: uint,
    categories: (list 10 (string-ascii 64)), ;; List of available categories
    stakes: (list 10 uint), ;; Total staked per category - shares
    stake-tokens: (list 10 uint), ;; Total staked per category - tokens
    outcome: (optional uint),
    concluded: bool,
    market-start: uint,
    market-duration: uint,
    cool-down-period: uint,
    hedge-executor: (optional principal),
    hedged: bool,
  }
)
;; defines the minimum liquidity a market creator needs to provide
(define-map token-minimum-seed {token: principal} uint)

;; tracks the amount of shares the user owns per market / category
(define-map stake-balances
  { market-id: uint, user: principal }
  (list 10 uint)
)
;; tracks the cost of shares to the user per market / category
(define-map token-balances
  { market-id: uint, user: principal }
  (list 10 uint)
)
(define-map allowed-tokens principal bool)

;; ---------------- access control ----------------
(define-public (is-dao-or-extension)
	(ok (asserts! (or (is-eq tx-sender .bigmarket-dao) (contract-call? .bigmarket-dao is-extension contract-caller)) err-unauthorised))
)

;; ---------------- getters / setters ----------------
(define-public (set-allowed-token (token principal) (enabled bool))
	(begin
		(try! (is-dao-or-extension))
		(print {event: "allowed-token", token: token, enabled: enabled})
		(ok (map-set allowed-tokens token enabled))
	)
)
(define-read-only (is-allowed-token (token principal))
	(default-to false (map-get? allowed-tokens token))
)

(define-public (set-dispute-window-length (length uint))
  (begin
    (try! (is-dao-or-extension))
    (var-set dispute-window-length length)
    (ok true)
  )
)

(define-public (set-default-hedge-executor (p principal))
  (begin
		(try! (is-dao-or-extension))
    (var-set default-hedge-executor p)
		(print {event: "default-hedge-executor", default-hedge-executor: p})
    (ok true)
  )
)

(define-public (set-hedging-enabled (enabled bool))
  (begin
		(try! (is-dao-or-extension))
    (var-set hedging-enabled enabled)
    (ok enabled)
  )
)
(define-read-only (is-hedging-enabled) (var-get hedging-enabled))

(define-public (set-creation-gated (gated bool))
  (begin
    (try! (is-dao-or-extension))
    (var-set creation-gated gated)
    (ok true)
  )
)

(define-public (set-resolution-agent (new-agent principal))
  (begin
    (try! (is-dao-or-extension))
    (var-set resolution-agent new-agent)
    (ok true)
  )
)

(define-public (set-dev-fee-bips (new-fee uint))
  (begin
		(asserts! (<= new-fee u1000) err-max-market-fee-bips-exceeded)
    (try! (is-dao-or-extension))
    (var-set dev-fee-bips new-fee)
    (ok true)
  )
)

(define-public (set-dao-fee-bips (new-fee uint))
  (begin
		(asserts! (<= new-fee u1000) err-max-market-fee-bips-exceeded)
    (try! (is-dao-or-extension))
    (var-set dao-fee-bips new-fee)
    (ok true)
  )
)

(define-public (set-market-fee-bips-max (new-fee uint))
  (begin
		(asserts! (<= new-fee u1000) err-max-market-fee-bips-exceeded)
    (try! (is-dao-or-extension))
    (var-set market-fee-bips-max new-fee)
    (ok true)
  )
)

(define-public (set-token-minimum-seed (token principal) (min uint))
  (begin
    (try! (is-dao-or-extension))
    (map-set token-minimum-seed {token: token} min)
    (ok true)
  )
)

(define-read-only (get-token-minimum-seed (seed-token principal))
  (ok (map-get? token-minimum-seed {token: seed-token}))
)

(define-public (set-dev-fund (new-dev-fund principal))
  (begin
    (try! (is-dao-or-extension))
    (var-set dev-fund new-dev-fund)
    (ok true)
  )
)

(define-public (set-dao-treasury (new-dao-treasury principal))
  (begin
    (try! (is-dao-or-extension))
    (var-set dao-treasury new-dao-treasury)
    (ok true)
  )
)

(define-read-only (get-market-data (market-id uint))
	(map-get? markets market-id)
)

(define-read-only (get-stake-balances (market-id uint) (user principal))
  (ok (default-to (list u0 u0 u0 u0 u0 u0 u0 u0 u0 u0) (map-get? stake-balances {market-id: market-id, user: user})))
)

(define-read-only (get-token-balances (market-id uint) (user principal))
  (ok (default-to (list u0 u0 u0 u0 u0 u0 u0 u0 u0 u0) (map-get? token-balances {market-id: market-id, user: user})))
)

;; ---------------- public functions ----------------

(define-public (create-market 
    (categories (list 10 (string-ascii 64))) 
    (fee-bips (optional uint)) 
    (token <ft-token>) 
    (market-data-hash (buff 32)) 
    (proof (list 10 (tuple (position bool) (hash (buff 32)))))
    (treasury principal) 
    (market-duration (optional uint)) 
    (cool-down-period (optional uint))
    (seed-amount uint)
    (hedge-executor (optional principal))
  )
    (let (
        (creator tx-sender)
        (new-id (var-get market-counter))
        (market-fee-bips (default-to u0 fee-bips))
        (market-duration-final (default-to DEFAULT_MARKET_DURATION market-duration))
        (cool-down-final (default-to DEFAULT_COOL_DOWN_PERIOD cool-down-period))
        (current-block burn-block-height)
        (num-categories (len categories))
        ;; NOTE: seed is evenly divided with rounding error discarded
        (seed (/ seed-amount num-categories))
        (user-stake-list (list seed seed seed seed seed seed seed seed seed seed))
        (share-list (zero-after-n user-stake-list num-categories))
      )
      (asserts! (> market-duration-final u10) err-market-not-found)
      (asserts! (> cool-down-final u10) err-market-not-found)

		  (asserts! (> (len categories) u1) err-too-few-categories)
		  (asserts! (<= market-fee-bips (var-get market-fee-bips-max)) err-max-market-fee-bips-exceeded)
      ;; ensure the trading token is allowed 
		  (asserts! (is-allowed-token (contract-of token)) err-invalid-token)

      ;; ensure enough liquidity
      (asserts! (>= seed-amount (unwrap! (map-get? token-minimum-seed {token: (contract-of token)}) err-token-not-configured)) err-seed-too-small)
      ;; liquidity floor guards (for CPMM safety)
      (asserts! (>= seed MIN_POOL) err-insufficient-liquidity)
      (asserts! (>= seed-amount (* num-categories MIN_POOL)) err-insufficient-liquidity) ;; avoid rounding below floor

      ;; Transfer single winning portion of seed to market contract to fund claims
      (try! (contract-call? token transfer seed-amount tx-sender (as-contract tx-sender) none))

      ;; ensure the user is allowed to create if gating by merkle proof is required
      (if (var-get creation-gated) (try! (as-contract (contract-call? .bme022-0-market-gating can-access-by-account creator proof))) true)
      
      ;; dao is assigned the seed liquidity - share and tokens 1:1 at kick off
      (map-set stake-balances {market-id: new-id, user: (var-get dao-treasury)} share-list)
      (map-set token-balances {market-id: new-id, user: (var-get dao-treasury)} share-list)

      (map-set markets
        new-id
        {
          market-data-hash: market-data-hash,
          token: (contract-of token),
          treasury: treasury,
          creator: creator,
          market-fee-bips: market-fee-bips,
          resolution-state: RESOLUTION_OPEN,
          resolution-burn-height: u0,
          categories: categories,
          stakes: share-list,
          stake-tokens: share-list, ;; they start out the same
          outcome: none,
          concluded: false,
          market-start: current-block,
          market-duration: market-duration-final,
          cool-down-period: cool-down-final,
          hedge-executor: hedge-executor,
          hedged: false,
        }
      )   
      (var-set market-counter (+ new-id u1))
      (try! (contract-call? .bme030-0-reputation-token mint tx-sender u2 u8))
      (print {event: "create-market", market-id: new-id, categories: categories, market-fee-bips: market-fee-bips, token: token, market-data-hash: market-data-hash, creator: tx-sender, seed-amount: seed-amount})
      (ok new-id)
  )
)

;; Read-only: get current price to buy `amount` shares in a category
(define-read-only (get-share-cost (market-id uint) (index uint) (amount-shares uint))
  (let (
        (market-data (unwrap-panic (map-get? markets market-id)))
        (stake-list (get stakes market-data))
        (selected-pool (unwrap-panic (element-at? stake-list index)))
        (total-pool (fold + stake-list u0))
        (other-pool (- total-pool selected-pool))
        (max-purchase (if (> other-pool MIN_POOL) (- other-pool MIN_POOL) u0))
        (cost (unwrap! (cpmm-cost selected-pool other-pool amount-shares) err-arithmetic))
       )
    (ok { cost: cost, max-purchase: max-purchase })
  )
)

;; Compute the token cost to buy `amount-shares` from `selected-pool`,
;; given the rest-of-market liquidity `other-pool`.
(define-private (cpmm-cost (selected-pool uint) (other-pool uint) (amount-shares uint))
  (begin
    ;; Both pools must have liquidity
    (asserts! (> selected-pool u0) err-insufficient-liquidity)
    (asserts! (> other-pool u0) err-insufficient-liquidity)

    ;; You cannot buy so much that the counter-pool hits 0 or below MIN_POOL
    (let (
          (max-purchase (if (> other-pool MIN_POOL) (- other-pool MIN_POOL) u0))
         )
      (asserts! (<= amount-shares max-purchase) err-overbuy)

      (let (
            (new-y (- other-pool amount-shares))
            (numerator (* selected-pool other-pool))
            (new-x (/ numerator new-y))
            (cost   (if (> new-x selected-pool) (- new-x selected-pool) u0))
           )
        (ok cost)
      )
    )
  )
)

;; Read-only: get current price to buy `amount` shares in a category
(define-read-only (get-max-shares (market-id uint) (index uint) (total-cost uint))
  (let (
        (fee (/ (* total-cost (var-get dev-fee-bips)) u10000))
        (cost-of-shares (if (> total-cost fee) (- total-cost fee) u0))
        (market-data (unwrap-panic (map-get? markets market-id)))
        (stake-list (get stakes market-data))
        (selected-pool (unwrap-panic (element-at? stake-list index)))
        (total-pool (fold + stake-list u0))
        (other-pool (- total-pool selected-pool))
        (max-by-floor (if (> other-pool MIN_POOL) (- other-pool MIN_POOL) u0))
        (shares (unwrap! (cpmm-shares selected-pool other-pool cost-of-shares) err-arithmetic))
        (shares-clamped (if (> shares max-by-floor) max-by-floor shares))
       )
    (ok { shares: shares-clamped, fee: fee, cost-of-shares: cost-of-shares })
  )
)
;; Inverse: given a token `cost`, how many shares can be bought safely?
(define-private (cpmm-shares (selected-pool uint) (other-pool uint) (cost uint))
  (begin
    (asserts! (> selected-pool u0) err-insufficient-liquidity)
    (asserts! (> other-pool u0) err-insufficient-liquidity)

    (if (is-eq cost u0)
        (ok u0)
        (let (
              (denom (+ selected-pool cost))            ;; > selected-pool, non-zero
              (numerator (* selected-pool other-pool))
              (new-y (/ numerator denom))               ;; integer division
              (raw-shares (if (> other-pool new-y) (- other-pool new-y) u0))
              ;; Enforce floor: clamp to keep MIN_POOL on the other side
              (max-by-floor (if (> other-pool MIN_POOL) (- other-pool MIN_POOL) u0))
              (shares (if (> raw-shares max-by-floor) max-by-floor raw-shares))
             )
          (ok shares)
        )
    )
  )
)
;; Predict category with CPMM pricing
(define-public (predict-category (market-id uint) (min-shares uint) (category (string-ascii 64)) (token <ft-token>) (max-cost uint))
  (let (
        (md (unwrap! (map-get? markets market-id) err-market-not-found))
        (categories (get categories md))
        (index (unwrap! (index-of? categories category) err-category-not-found))
        (stake-tokens-list (get stake-tokens md))
        (selected-token-pool (unwrap! (element-at? stake-tokens-list index) err-category-not-found))
        (stake-list (get stakes md))
        (selected-pool (unwrap! (element-at? stake-list index) err-category-not-found))
        (total-pool (fold + stake-list u0))
        (other-pool (- total-pool selected-pool))
        (sender-balance (unwrap! (contract-call? token get-balance tx-sender) err-insufficient-balance))
        (fee (/ (* max-cost (var-get dev-fee-bips)) u10000))
        (cost-of-shares (if (> max-cost fee) (- max-cost fee) u0))
        (max-by-floor (if (> other-pool MIN_POOL) (- other-pool MIN_POOL) u0))
        (amount-shares (unwrap! (cpmm-shares selected-pool other-pool cost-of-shares) err-insufficient-balance))
        (max-cost-of-shares (unwrap! (cpmm-cost selected-pool other-pool max-by-floor) err-overbuy))
        (max-purchase (if (> other-pool u0) (- other-pool u1) u0))
        (market-end (+ (get market-start md) (get market-duration md)))
  )
    ;; Validate token and market state
    (asserts! (< index (len categories)) err-category-not-found)
    (asserts! (is-eq (get token md) (contract-of token)) err-invalid-token)
    (asserts! (not (get concluded md)) err-market-not-concluded)
    (asserts! (is-eq (get resolution-state md) RESOLUTION_OPEN) err-market-not-open)
    (asserts! (>= max-cost u100) err-amount-too-low)
    (asserts! (>= sender-balance max-cost) err-insufficient-balance)
    (asserts! (<= max-cost u50000000000000) err-amount-too-high)
    (asserts! (< burn-block-height market-end) err-market-not-open)
    ;; ensure the user cannot overpay for shares - this can skew liquidity in other pools
    (asserts! (<= cost-of-shares max-cost-of-shares) err-overbuy)
    (asserts! (< amount-shares other-pool) err-overbuy)
    (asserts! (>= amount-shares min-shares) err-slippage-too-high)
  (asserts! (> other-pool u0) err-insufficient-liquidity)
  (asserts! (<= amount-shares max-by-floor) err-overbuy)

    ;; --- Token Transfers ---
    (try! (contract-call? token transfer cost-of-shares tx-sender (as-contract tx-sender) none))
    (if (> fee u0)
      (try! (contract-call? token transfer fee tx-sender (var-get dev-fund) none))
      true
    )

    ;; --- Update Market State ---
    (let (
      (updated-stakes (unwrap! (replace-at? stake-list index (+ selected-pool amount-shares)) err-category-not-found))
      (updated-token-stakes (unwrap! (replace-at? stake-tokens-list index (+ selected-token-pool cost-of-shares)) err-category-not-found))
    )
      (map-set markets market-id (merge md {stakes: updated-stakes, stake-tokens: updated-token-stakes}))
    )

    ;; --- Update User Balances ---
    (let (
      (current-token-balances (default-to (list u0 u0 u0 u0 u0 u0 u0 u0 u0 u0) (map-get? token-balances {market-id: market-id, user: tx-sender})))
      (token-current (unwrap! (element-at? current-token-balances index) err-category-not-found))
      (user-token-updated (unwrap! (replace-at? current-token-balances index (+ token-current cost-of-shares)) err-category-not-found))

      (current-stake-balances (default-to (list u0 u0 u0 u0 u0 u0 u0 u0 u0 u0) (map-get? stake-balances {market-id: market-id, user: tx-sender})))
      (user-current (unwrap! (element-at? current-stake-balances index) err-category-not-found))
      (user-stake-updated (unwrap! (replace-at? current-stake-balances index (+ user-current amount-shares)) err-category-not-found))
    )
      (map-set stake-balances {market-id: market-id, user: tx-sender} user-stake-updated)
      (map-set token-balances {market-id: market-id, user: tx-sender} user-token-updated)
      (print {event: "market-stake", market-id: market-id, index: index, amount: amount-shares, cost: cost-of-shares, fee: fee, voter: tx-sender, max-cost: max-cost}) 
      (ok index)
    )
  )
)

;; Resolve a market invoked by ai-agent.
(define-public (resolve-market (market-id uint) (category (string-ascii 64)))
  (let (
      (md (unwrap! (map-get? markets market-id) err-market-not-found))
      (final-index (unwrap! (index-of? (get categories md) category) err-category-not-found))
      (market-end (+ (get market-start md) (get market-duration md)))
      (market-close (+ market-end (get cool-down-period md)))
    )
    (asserts! (or (is-eq tx-sender (var-get resolution-agent)) (is-eq tx-sender (get creator md))) err-unauthorised)
    (asserts! (>= burn-block-height market-close) err-market-wrong-state)
    (asserts! (is-eq (get resolution-state md) RESOLUTION_OPEN) err-market-wrong-state)

    (map-set markets market-id
      (merge md
        { outcome: (some final-index), resolution-state: RESOLUTION_RESOLVING, resolution-burn-height: burn-block-height }
      )
    )
    (print {event: "resolve-market", market-id: market-id, outcome: final-index, resolver: tx-sender, resolution-state: RESOLUTION_RESOLVING, resolution-burn-height: burn-block-height})
    (ok final-index)
  )
)

(define-public (execute-hedge
  (market-id uint)
  (hedge-executor <hedge-trait>)
  (token0 <ft-velar-token>) (token1 <ft-velar-token>)
  (token-in <ft-velar-token>) (token-out <ft-velar-token>))

  (let (
      (md (unwrap! (map-get? markets market-id) err-market-not-found))
      (market-end (+ (get market-start md) (get market-duration md)))
      (cool-end (+ market-end (get cool-down-period md)))
      (hedged (get hedged md))
      (stored-hexec (default-to (var-get default-hedge-executor) (get hedge-executor md)))
      (cats (get categories md))
      (stakes (get stakes md))
      (predicted (get-biggest-pool-index stakes))
    )

    ;; 0) Feature flag
    (asserts! (var-get hedging-enabled) err-hedging-disabled)

    ;; 1) Auth: restrict who can trigger the hedge (DAO or resolution-agent)
    (asserts!
      (or (is-eq tx-sender (var-get resolution-agent))
          (unwrap! (is-dao-or-extension) err-hedge-unauthorised))
      err-hedge-unauthorised)

    ;; 2) Executor authenticity: the provided contract must match stored one exactly
    (asserts! (is-eq (contract-of hedge-executor) stored-hexec) err-hedge-exec-mismatch)

    ;; 3) Time window: only during cool-down window
    (asserts! (>= burn-block-height market-end) err-hedge-window)
    (asserts! (<  burn-block-height cool-end)  err-hedge-window)

    ;; 4) Market must be unresolved + not already hedged
    (asserts! (not (get concluded md)) err-market-wrong-state)
    (asserts! (not hedged)            err-hedge-already)

    ;; 5) Validate predicted index against categories length
    (asserts! (< (get index (fold find-max-helper stakes { max-val: u0, index: u0, current-index: u0 }))
                 (len cats))
              err-hedge-bad-prediction)

    ;; 6) Validate all tokens are allowed & consistent
    (asserts! (is-allowed-token (contract-of token0)) err-hedge-bad-token)
    (asserts! (is-allowed-token (contract-of token1)) err-hedge-bad-token)
    (asserts! (is-allowed-token (contract-of token-in)) err-hedge-bad-token)
    (asserts! (is-allowed-token (contract-of token-out)) err-hedge-bad-token)
    ;; (optional) require token-in/out to be among token0/token1
    (asserts!
      (or (and (is-eq (contract-of token-in)  (contract-of token0))
               (is-eq (contract-of token-out) (contract-of token1)))
          (and (is-eq (contract-of token-in)  (contract-of token1))
               (is-eq (contract-of token-out) (contract-of token0))))
      err-hedge-bad-token)

    ;; 7) Reentrancy/race guard: set hedged=true before external call.
    ;; If the call fails, state reverts automatically.
    (map-set markets market-id (merge md { hedged: true }))
    (print {event: "hedge-start", market-id: market-id, predicted: predicted, executor: stored-hexec})

    ;; 8) Execute the hedge via the whitelisted strategy
    (try! (contract-call? hedge-executor perform-custom-hedge market-id predicted))

    (print {event: "hedge-done", market-id: market-id, predicted: predicted})
    (ok predicted)
  )
)

(define-public (resolve-market-undisputed (market-id uint))
  (let (
        (md (unwrap! (map-get? markets market-id) err-market-not-found))
    )
    (asserts! (> burn-block-height (+ (get resolution-burn-height md) (var-get dispute-window-length))) err-dispute-window-not-elapsed)
    (asserts! (is-eq (get resolution-state md) RESOLUTION_RESOLVING) err-market-not-open)

    (map-set markets market-id
      (merge md
        { concluded: true, resolution-state: RESOLUTION_RESOLVED, resolution-burn-height: burn-block-height }
      )
    )
    (print {event: "resolve-market-undisputed", market-id: market-id, resolution-burn-height: burn-block-height, resolution-state: RESOLUTION_RESOLVED})
    (ok true)
  )
)

;; concludes a market that has been disputed. This method has to be called at least
;; dispute-window-length blocks after the dispute was raised - the voting window.
;; a proposal with 0 votes will close the market with the outcome false
(define-public (resolve-market-vote (market-id uint) (outcome uint))
  (let (
        (md (unwrap! (map-get? markets market-id) err-market-not-found))
    )
    (try! (is-dao-or-extension))
    (asserts! (< outcome (len (get categories md))) err-market-not-found)
    (asserts! (or (is-eq (get resolution-state md) RESOLUTION_DISPUTED) (is-eq (get resolution-state md) RESOLUTION_RESOLVING)) err-market-wrong-state)

    (map-set markets market-id
      (merge md
        { concluded: true, outcome: (some outcome), resolution-state: RESOLUTION_RESOLVED }
      )
    )
    (print {event: "resolve-market-vote", market-id: market-id, resolver: contract-caller, outcome: outcome, resolution-state: RESOLUTION_RESOLVED})
    (ok true)
  )
)

;; Allows a user with a stake in market to contest the resolution
;; the call is made via the voting contract 'create-market-vote' function
(define-public (dispute-resolution (market-id uint) (disputer principal) (num-categories uint))
  (let (
        (md (unwrap! (map-get? markets market-id) err-market-not-found))
        ;; ensure user has a stake
        (stake-data (unwrap! (map-get? stake-balances { market-id: market-id, user: disputer }) err-disputer-must-have-stake)) 
    )
    ;; user call create-market-vote in the voting contract to start a dispute
    (try! (is-dao-or-extension))

    (asserts! (is-eq num-categories (len (get categories md))) err-too-few-categories)
    ;; prevent market getting locked in unresolved state
    (asserts! (<= burn-block-height (+ (get resolution-burn-height md) (var-get dispute-window-length))) err-dispute-window-elapsed)

    (asserts! (is-eq (get resolution-state md) RESOLUTION_RESOLVING) err-market-not-resolving) 

    (map-set markets market-id
      (merge md { resolution-state: RESOLUTION_DISPUTED }))
    (print {event: "dispute-resolution", market-id: market-id, disputer: disputer, resolution-state: RESOLUTION_DISPUTED})
    (ok true)
  )
)
(define-public (force-resolve-market (market-id uint))
  (let (
    (md (unwrap! (map-get? markets market-id) err-market-not-found))
    (elapsed (- burn-block-height (get resolution-burn-height md)))
  )
  (begin
    (asserts! (> elapsed (var-get resolution-timeout)) err-market-wrong-state)
    (asserts! (is-eq (get resolution-state md) RESOLUTION_DISPUTED) err-market-wrong-state)

    (map-set markets market-id
      (merge md { resolution-state: RESOLUTION_RESOLVED, concluded: true })
    )
    (print {event: "force-resolve", market-id: market-id, resolution-state: RESOLUTION_RESOLVED})
    (ok true)
  ))
)

;; Proportional payout with market fee only
(define-public (claim-winnings (market-id uint) (token <ft-token>))
  (let (
    (md (unwrap! (map-get? markets market-id) err-market-not-found))
    (index-won (unwrap! (get outcome md) err-market-not-concluded))
    (marketfee-bips (get market-fee-bips md))
    (treasury (get treasury md))
    (original-sender tx-sender)

    ;; user may have acquired shares via p2p and so have no entry under token-balances
    (user-token-list (default-to (list u0 u0 u0 u0 u0 u0 u0 u0 u0 u0) (map-get? token-balances {market-id: market-id, user: tx-sender})))
    (user-tokens (unwrap! (element-at? user-token-list index-won) err-user-not-staked))

    (user-stake-list (unwrap! (map-get? stake-balances {market-id: market-id, user: tx-sender}) err-user-not-staked))
    (user-shares (unwrap! (element-at? user-stake-list index-won) err-user-not-staked))

    (stake-list (get stakes md))
    (winning-pool (unwrap! (element-at? stake-list index-won) err-market-not-concluded))
    (total-share-pool (fold + stake-list u0))

    (staked-tokens (get stake-tokens md))
    (total-token-pool (fold + staked-tokens u0))

    ;; CPMM Payout: the proportion of the total tokens staked to the shares won
    (gross-refund (if (> winning-pool u0) (/ (* user-shares total-token-pool) winning-pool) u0))

    (marketfee (/ (* gross-refund marketfee-bips) u10000))
    (net-refund (- gross-refund marketfee))
  )
    ;; Check resolved and non zero payout
    (asserts! (is-eq (get resolution-state md) RESOLUTION_RESOLVED) err-market-not-concluded)
    (asserts! (get concluded md) err-market-not-concluded)
    (asserts! (> user-shares u0) err-user-not-winner-or-claimed)
    (asserts! (> winning-pool u0) err-amount-too-low)
    (asserts! (> net-refund u0) err-user-share-is-zero)

    ;; Transfer winnings and market fee
    (as-contract
      (begin
        (if (> marketfee u0)
            (try! (contract-call? token transfer marketfee tx-sender treasury none))
          true
        )
        (try! (contract-call? token transfer net-refund tx-sender original-sender none))
      )
    )

    ;; Zero out stake
    (map-set token-balances {market-id: market-id, user: tx-sender} (list u0 u0 u0 u0 u0 u0 u0 u0 u0 u0))
    (map-set stake-balances {market-id: market-id, user: tx-sender} (list u0 u0 u0 u0 u0 u0 u0 u0 u0 u0))
    (try! (contract-call? .bme030-0-reputation-token mint tx-sender u1 u10))
    (print {event: "claim-winnings", market-id: market-id, index-won: index-won, claimer: tx-sender, user-tokens: user-tokens, user-shares: user-shares, refund: net-refund, marketfee: marketfee, winning-pool: winning-pool, total-pool: total-share-pool})
    (ok net-refund)
  )
)

(define-read-only (get-expected-payout (market-id uint) (index uint) (user principal))
  (let (
    (md (unwrap-panic (map-get? markets market-id)))

    (token-pool (fold + (get stake-tokens md) u0))

    (user-shares-list (unwrap-panic (map-get? stake-balances {market-id: market-id, user: user})))
    (user-shares (unwrap-panic (element-at? user-shares-list index)))

    (winning-shares-pool (unwrap-panic (element-at? (get stakes md) index)))
    
    (marketfee-bips (get market-fee-bips md))
    (gross-refund (if (> winning-shares-pool u0) (/ (* user-shares token-pool) winning-shares-pool) u0))
    (marketfee (/ (* gross-refund marketfee-bips) u10000))
    (net-refund (- gross-refund marketfee))
  )
    (if (and (> user-shares u0) (> winning-shares-pool u0) (> net-refund u0))
      (ok { net-refund: net-refund, marketfee: marketfee-bips })
      (err u1) ;; not eligible or payout = 0
    )
  )
)

;; marketplace transfer function to move shares - dao extension callable
;; note - an automated dao function that fulfils orders functions as a 'sell-shares' feature
(define-public (transfer-shares 
  (market-id uint)
  (outcome uint)
  (seller principal)
  (buyer principal)
  (amount uint)
  (token <ft-token>)
)
  (let (
    (md (unwrap! (map-get? markets market-id) err-market-not-found))
    (stake-list (get stakes md))
    (market-token (get token md))
    (selected-pool (unwrap! (element-at? stake-list outcome) err-category-not-found))
    (other-pools (- (fold + stake-list u0) selected-pool))

    ;; Pricing
    (price (unwrap! (cpmm-cost selected-pool other-pools amount) err-overbuy))
    (marketfee-bips (get market-fee-bips md))
    (treasury (get treasury md))
    (fee (/ (* price marketfee-bips) u10000))
    (net-price (- price fee))
    (reduced-fee (/ fee u2))

    ;; Share balances
    (seller-balances (unwrap! (map-get? stake-balances {market-id: market-id, user: seller}) err-user-not-staked))
    (seller-shares (unwrap! (element-at? seller-balances outcome) err-user-not-staked))
    (buyer-balances (default-to (list u0 u0 u0 u0 u0 u0 u0 u0 u0 u0) (map-get? stake-balances {market-id: market-id, user: buyer})))
    (buyer-shares (unwrap! (element-at? buyer-balances outcome) err-category-not-found))
  )
    ;; dao extension callable only
    (try! (is-dao-or-extension))
    ;; Ensure seller has enough shares
    (asserts! (>= seller-shares amount) err-user-share-is-zero)
    (asserts! (is-eq market-token (contract-of token)) err-invalid-token)
    (asserts! (is-eq (get resolution-state md) RESOLUTION_OPEN) err-market-wrong-state)

    ;; Perform share transfer
    ;; Note: we do not update `stakes` here because total pool liquidity remains unchanged.
    (let (
        (buyer-updated (unwrap! (replace-at? buyer-balances outcome (+ buyer-shares amount)) err-category-not-found))
        (seller-updated (unwrap! (replace-at? seller-balances outcome (- seller-shares amount)) err-category-not-found))
      )
      ;; Update state
      (map-set stake-balances {market-id: market-id, user: buyer} buyer-updated)
      (map-set stake-balances {market-id: market-id, user: seller} seller-updated)

      ;; Transfer cost and fee from buyer to seller
      (begin
        (if (> reduced-fee u0)
          ;; buyer pays reduced fee as p2p incentive
          (try! (contract-call? token transfer reduced-fee buyer treasury none))
          true
        )
        (try! (contract-call? token transfer net-price buyer seller none))
      )
      (print {event: "transfer-shares", market-id: market-id, outcome: outcome, buyer: buyer, seller: seller, amount: amount, price: net-price, fee: fee })
      (ok price)
    )
  )
)

;; Helper function to create a list with zeros after index N
(define-private (zero-after-n (original-list (list 10 uint)) (n uint))
  (let (
    (element-0 (if (<= u0 n) (unwrap-panic (element-at? original-list u0)) u0))
    (element-1 (if (< u1 n) (unwrap-panic (element-at? original-list u1)) u0))
    (element-2 (if (< u2 n) (unwrap-panic (element-at? original-list u2)) u0))
    (element-3 (if (< u3 n) (unwrap-panic (element-at? original-list u3)) u0))
    (element-4 (if (< u4 n) (unwrap-panic (element-at? original-list u4)) u0))
    (element-5 (if (< u5 n) (unwrap-panic (element-at? original-list u5)) u0))
    (element-6 (if (< u6 n) (unwrap-panic (element-at? original-list u6)) u0))
    (element-7 (if (< u7 n) (unwrap-panic (element-at? original-list u7)) u0))
    (element-8 (if (< u8 n) (unwrap-panic (element-at? original-list u8)) u0))
    (element-9 (if (< u9 n) (unwrap-panic (element-at? original-list u9)) u0))
  )
    (list element-0 element-1 element-2 element-3 element-4 element-5 element-6 element-7 element-8 element-9)
  )
)

(define-private (get-biggest-pool-index (lst (list 10 uint)))
  (get index
    (fold find-max-helper
          lst
          { max-val: u0, index: u0, current-index: u0 }))
)

(define-private (find-max-helper (val uint) (state { max-val: uint, index: uint, current-index: uint }))
  {
    max-val: (if (> val (get max-val state)) val (get max-val state)),
    index: (if (> val (get max-val state)) (get current-index state) (get index state)),
    current-index: (+ (get current-index state) u1)
  }
)

