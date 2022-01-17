;; This is stxpredict - A prediction market on Stacks - v5
;; Create a new market by sending description, resolver account, resolve type: auto or manual and resolve date/time.
;; Once resolve date/time has passed, resolver can call resolveMarket with the final result. Users will manually exit markets.
;; For Auto resolve markets, user can ping oracle to request resolution of the market.
;; Limitations: Only yes/no questions, static payment per vote, one account can join only one side, Auto-resolve markets can only be defined as higher, No fees for oracle (yet), traits WIP
(define-map marketDatabase {marketId: int} {question: (string-ascii 99), threshold: int, balance: uint, paypervote: uint, resolver: principal, yescount: uint, nocount: uint, resolveTime: uint, resolveType: (string-ascii 10), resolved: bool, result: bool})

;; voters db
(define-map yesvoters {marketId: int, voter: principal} {amount: uint})
(define-map novoters {marketId: int, voter: principal} {amount: uint})

(define-data-var numberOfMarkets int 0)

;; increment marketId
(define-private (incrementMarketId)
  (begin
    (var-set numberOfMarkets (+ (var-get numberOfMarkets) 1))
    (var-get numberOfMarkets)
  )
)

;; trait for oracle autoresolve
(define-trait prediction-market-oracle
  (
    ;; oracle shall accept requests from users to resolve markets
    (requestResolution (int) (response bool uint))

    ;; oracle shall read threshold value from market
    (readMarketThreshold (int) (response int uint))
    
    ;; oracle shall resolve markets
    (resolveMarket (int bool) (response bool uint))
  )
)

;; public functions
;; create a new prediction market
(define-public (createMarket (question (string-ascii 99)) (threshold int) (paypervote uint) (resolver principal) (resolveTime uint) (resolveType (string-ascii 10)))
  (begin
    (map-set marketDatabase {marketId: (incrementMarketId)} {question: question, threshold: threshold, balance: u0, paypervote: paypervote, resolver: resolver, yescount: u0, nocount: u0, resolveTime: resolveTime, resolveType: resolveType, resolved: false, result: false})
    (ok "Prediction market created")
  )
)

(define-public (joinMarket (marketId int) (side bool) (amount uint))
  (let (
    (validMarketId (<= marketId (var-get numberOfMarkets)))
    (resolved (getResolved marketId))
    (validAmount (>= amount (default-to u1 (get paypervote (map-get? marketDatabase {marketId: marketId})))))
    )
    (if (and validMarketId (not resolved) validAmount)
      (begin
        (if side (map-insert yesvoters {marketId: marketId, voter: tx-sender} {amount: amount}) (map-insert novoters {marketId: marketId, voter: tx-sender} {amount: amount}))
        (addBalance marketId tx-sender amount)
        (incrementCount marketId side)
      )
      (err u2)
    )
  )
)

(define-public (resolveMarket (marketId int) (result bool))
  (let (
    (resolved (getResolved marketId))
    (timeToResolve (check-time-to-resolve marketId))
    (resolver (default-to 'SP15RGYVK9ACFQWMFFA2TVASDVZH38B4VATY8CJ01 (get resolver (map-get? marketDatabase {marketId: marketId}))))
    )
    (if (and (not resolved) timeToResolve (is-eq resolver tx-sender))
      (ok (setResult marketId result))
      (ok false)
    )
  )
)

(define-public (exitMarket (marketId int))
  (let (
    (resolved (getResolved marketId))
    (result (getResult marketId))
    (vote (getVote marketId))
    (payout (getPayout marketId))
    )
    (if (and resolved vote)
      (stx-transfer? payout (as-contract tx-sender) tx-sender)
      (err u2)
    )
  )
)

;; helpers/private functions
;; get threshold of a market - for oracle usage
(define-read-only (readMarketThreshold (marketId int))
  (ok (get threshold (map-get? marketDatabase {marketId: marketId})))
)

;; add stx to the contract
(define-private (addBalance (marketId int) (participant principal) (amount uint))
  (begin
    (unwrap-panic (stx-transfer? amount participant (as-contract tx-sender)))
    (match
      (map-get? marketDatabase {marketId: marketId})
      market
      (map-set marketDatabase {marketId: marketId} (merge market {balance: (+ (default-to u0 (get balance (map-get? marketDatabase {marketId: marketId}))) amount)}))
      false
    )
  )
)

;; get balance of marketId
(define-private (getBalance (marketId int))
    (default-to u0 (get balance (map-get? marketDatabase {marketId: marketId})))
)

;; get resolveTime of marketId
(define-private (getResolveTime (marketId int))
    (default-to u2147483647 (get resolveTime (map-get? marketDatabase {marketId: marketId})))
)

;; get payout of marketId, calculate payout = divide market balance by # of winning votes
(define-private (getPayout (marketId int))
    (if (unwrap-panic (get result (map-get? marketDatabase {marketId: marketId})))
        (let ((count (default-to u1 (get yescount (map-get? marketDatabase {marketId: marketId})))) (balance (getBalance marketId))) (print count) (print balance) (/ balance count))
        (let ((count (default-to u1 (get nocount (map-get? marketDatabase {marketId: marketId})))) (balance (getBalance marketId))) (print count) (print balance) (/ balance count))
    )
)

;; check if user voted for a marketId same as resolved
(define-private (getVote (marketId int))
    (if (unwrap-panic (get result (map-get? marketDatabase {marketId: marketId})))
        (is-some (map-get? yesvoters {marketId: marketId, voter: tx-sender}))
        (is-some (map-get? novoters {marketId: marketId, voter: tx-sender}))
    )
)

;; check if market resolved
(define-private (getResolved (marketId int))
  (if (unwrap-panic (get resolved (map-get? marketDatabase {marketId: marketId})))
    (print true)
    (print false)
  )
)

;; get market result - not really needed - public for informational purposes
(define-private (getResult (marketId int))
  (if (unwrap-panic (get result (map-get? marketDatabase {marketId: marketId})))
    (print true)
    (print false)
  )
)

(define-private (setResult (marketId int) (result bool))
  (match
    (map-get? marketDatabase {marketId: marketId})
    market
    (map-set marketDatabase {marketId: marketId}
      (merge market { result: result, resolved: true })
    )
    false
  )
)

;; add 1 to yescount/nocount depending on which side user took for this market
(define-private (incrementCount (marketId int) (side bool))
  (begin
    (match
      (map-get? marketDatabase {marketId: marketId})
      market
      (if side
        (map-set marketDatabase {marketId: marketId} (merge market {yescount: (+ (default-to u0 (get yescount (map-get? marketDatabase {marketId: marketId}))) u1)}))
        (map-set marketDatabase {marketId: marketId} (merge market {nocount: (+ (default-to u0 (get nocount (map-get? marketDatabase {marketId: marketId}))) u1)}))
      )
      false
    )
    (ok u8)
  )
)

;; utils
;; get time from current block
(define-private (get-current-block-time)
  (default-to u0 (get-block-info? time block-height)))

;; get if resolve time has passed
(define-private (check-time-to-resolve (marketId int))
  (if (>= (get-current-block-time) (getResolveTime marketId))
      true
      false
  )
)
