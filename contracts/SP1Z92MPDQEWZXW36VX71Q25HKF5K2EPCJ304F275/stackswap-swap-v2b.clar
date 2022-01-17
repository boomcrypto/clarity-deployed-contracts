(use-trait sip-010-token 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.sip-010-v1a.sip-010-trait)
(use-trait liquidity-token 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-trait-v1a.liquidity-token-trait)

(define-constant contract-owner tx-sender)
(define-constant no-liquidity-err (err u4161))
;; (define-constant transfer-failed-err (err u4162))
(define-constant not-owner-err (err u4163))
(define-constant no-fee-to-address-err (err u4164))
(define-constant invalid-pair-err (err u4165))
(define-constant no-such-position-err (err u4166))
(define-constant balance-too-low-err (err u4167))
(define-constant too-many-pairs-err (err u4168))
(define-constant pair-already-exists-err (err u4169))
(define-constant wrong-token-err (err u4170))
(define-constant too-much-slippage-err (err u4171))
(define-constant transfer-x-failed-err (err u4172))
(define-constant transfer-y-failed-err (err u4173))
(define-constant value-out-of-range-err (err u4174))
(define-constant no-fee-x-err (err u4105))
(define-constant no-fee-y-err (err u4176))
(define-constant pair-token-already-used-err (err u4177))
(define-constant fee-contract-err (err u4178))
(define-constant not-upgraded-err (err u4179))

;; for future use, or debug
(define-constant e10-err (err u4120))
(define-constant e11-err (err u4121))
(define-constant e12-err (err u4122))


(define-map pairs-map
  { pair-id: uint }
  {
    token-x: principal,
    token-y: principal,
  }
)

(define-map pairs-token-map
  { pair-token: principal}
  { exist: uint}
  )

(define-map pairs-data-map
  {
    token-x: principal,
    token-y: principal,
  }
  {
    shares-total: uint,
    balance-x: uint,
    balance-y: uint,
    fee-balance-x: uint,
    fee-balance-y: uint,
    fee-to-address: (optional principal),
    liquidity-token: principal,
    name: (string-ascii 32),
  }
)

(define-data-var pair-count uint u0)


(define-read-only (get-name (token-x-trait <sip-010-token>) (token-y-trait <sip-010-token>))
  (let
    (
      (token-x (contract-of token-x-trait))
      (token-y (contract-of token-y-trait))
      (pair (unwrap! (map-get? pairs-data-map { token-x: token-x, token-y: token-y }) invalid-pair-err))
    )
    (ok (get name pair))
  )
)

(define-public (get-symbol (token-x-trait <sip-010-token>) (token-y-trait <sip-010-token>))
  (ok
    (concat
      (unwrap-panic (as-max-len? (unwrap-panic (contract-call? token-x-trait get-symbol)) u15))
      (concat "-"
        (unwrap-panic (as-max-len? (unwrap-panic (contract-call? token-y-trait get-symbol)) u15))
      )
    )
  )
)

(define-read-only (get-total-supply (token-x-trait <sip-010-token>) (token-y-trait <sip-010-token>))
  (let
    (
      (token-x (contract-of token-x-trait))
      (token-y (contract-of token-y-trait))
      (pair (unwrap! (map-get? pairs-data-map { token-x: token-x, token-y: token-y }) invalid-pair-err))
    )
    (ok (get shares-total pair))
  )
)

;; get the total number of shares in the pool
(define-read-only (get-shares (token-x principal) (token-y principal))
  (ok (get shares-total (unwrap! (map-get? pairs-data-map { token-x: token-x, token-y: token-y }) invalid-pair-err)))
)

;; get overall balances for the pair
(define-public (get-balances (token-x-trait <sip-010-token>) (token-y-trait <sip-010-token>))
  (let
    (
      (token-x (contract-of token-x-trait))
      (token-y (contract-of token-y-trait))
      (pair (unwrap! (map-get? pairs-data-map { token-x: token-x, token-y: token-y }) invalid-pair-err))
    )
    (ok (list (get balance-x pair) (get balance-y pair)))
  )
)

(define-public (get-data (token-x-trait <sip-010-token>) (token-y-trait <sip-010-token>) (token-liquidity-trait <liquidity-token>) (owner principal))
  (let
    (
      (token-data (unwrap-panic (contract-call? token-liquidity-trait get-data owner)))
      (balances (unwrap-panic (get-balances token-x-trait token-y-trait)))
    )
    (ok (merge token-data { balances: balances }))
  )
)

;; since we can't use a constant to refer to contract address, here what x and y are
;; (define-constant x-token 'SP2NC4YKZWM2YMCJV851VF278H9J50ZSNM33P3JM1.my-token)
;; (define-constant y-token 'SP1QR3RAGH3GEME9WV7XB0TZCX6D5MNDQP97D35EH.my-token)
(define-public (add-to-position (token-x-trait <sip-010-token>) (token-y-trait <sip-010-token>) (token-liquidity-trait <liquidity-token>) (x uint) (y uint) )
  (let
    (
      (token-x (contract-of token-x-trait))
      (token-y (contract-of token-y-trait))
      (pair (unwrap-panic (map-get? pairs-data-map { token-x: token-x, token-y: token-y })))
      (contract-address (as-contract tx-sender))
      (recipient-address tx-sender)
      (balance-x (get balance-x pair))
      (balance-y (get balance-y pair))
      (new-shares
        (if (is-eq (get shares-total pair) u0)
          (sqrti (* x y))  ;; burn a fraction of initial lp token to avoid attack as described in WP https://uniswap.org/whitepaper.pdf
          (/ (* x (get shares-total pair)) balance-x)
        )
      )
      (new-y
        (if (is-eq (get shares-total pair) u0)
          y
          (/ (* x balance-y) balance-x)
        )
      )
      (pair-updated (merge pair {
        shares-total: (+ new-shares (get shares-total pair)),
        balance-x: (+ balance-x x),
        balance-y: (+ balance-y new-y)
      }))
    )
    (asserts! (is-ok (contract-call? token-x-trait transfer x tx-sender contract-address none)) transfer-x-failed-err)
    (asserts! (is-ok (contract-call? token-y-trait transfer new-y tx-sender contract-address none)) transfer-y-failed-err)

    (map-set pairs-data-map { token-x: token-x, token-y: token-y } pair-updated)
    (try! (contract-call? token-liquidity-trait mint recipient-address new-shares))
    (print { object: "pair", action: "liquidity-added", data: pair-updated })
    (ok true)
  )
)

(define-read-only (get-pair-details (token-x principal) (token-y principal))
  (unwrap-panic (map-get? pairs-data-map { token-x: token-x, token-y: token-y }))
)

(define-read-only (get-pair-contracts (pair-id uint))
  (unwrap-panic (map-get? pairs-map { pair-id: pair-id }))
)

(define-read-only (get-pair-count)
  (ok (var-get pair-count))
)

(define-public (create-pair (token-x-trait <sip-010-token>) (token-y-trait <sip-010-token>) (token-liquidity-trait <liquidity-token>) (pair-name (string-ascii 32)) (x uint) (y uint))
  (let
    (
      (name-x (unwrap-panic (contract-call? token-x-trait get-name)))
      (name-y (unwrap-panic (contract-call? token-y-trait get-name)))
      (token-x (contract-of token-x-trait))
      (token-y (contract-of token-y-trait))
      (token-liquidity (contract-of token-liquidity-trait))
      (pair-id (+ (var-get pair-count) u1))
      (pair-data {
        shares-total: u0,
        balance-x: u0,
        balance-y: u0,
        fee-balance-x: u0,
        fee-balance-y: u0,
        fee-to-address: none,
        liquidity-token: (contract-of token-liquidity-trait),
        name: pair-name,
      })
    )
    (asserts!
      (and
        (is-none (map-get? pairs-data-map { token-x: token-x, token-y: token-y }))
        (is-none (map-get? pairs-data-map { token-x: token-y, token-y: token-x }))
        (is-none (map-get? pairs-token-map { pair-token: token-liquidity}))
      )
      pair-already-exists-err
    )
    (map-set pairs-data-map { token-x: token-x, token-y: token-y } pair-data)

    (map-set pairs-token-map { pair-token: token-liquidity} {exist: u1})
    (map-set pairs-map { pair-id: pair-id } { token-x: token-x, token-y: token-y })
    (var-set pair-count pair-id)
    (try! (add-to-position token-x-trait token-y-trait token-liquidity-trait x y))
    (print { object: "pair", action: "created", data: pair-data })
    (ok true)
  )
)

;; ;; reduce the amount of liquidity the sender provides to the pool
;; ;; to close, use u100
(define-public (reduce-position (token-x-trait <sip-010-token>) (token-y-trait <sip-010-token>) (token-liquidity-trait <liquidity-token>) (percent uint))
  (let
    (
      (token-x (contract-of token-x-trait))
      (token-y (contract-of token-y-trait))
      (pair (unwrap! (map-get? pairs-data-map { token-x: token-x, token-y: token-y }) invalid-pair-err))
      (balance-x (get balance-x pair))
      (balance-y (get balance-y pair))
      (shares (unwrap-panic (contract-call? token-liquidity-trait get-balance tx-sender)))
      (shares-total (get shares-total pair))
      (contract-address (as-contract tx-sender))
      (sender tx-sender)
      (withdrawal (/ (* shares percent) u100))
      (withdrawal-x (/ (* withdrawal balance-x) shares-total))
      (withdrawal-y (/ (* withdrawal balance-y) shares-total))
      (pair-updated
        (merge pair
          {
            shares-total: (- shares-total withdrawal),
            balance-x: (- (get balance-x pair) withdrawal-x),
            balance-y: (- (get balance-y pair) withdrawal-y)
          }
        )
      )
    )

    (asserts! (<= percent u100) value-out-of-range-err)
    (asserts! (is-ok (as-contract (contract-call? token-x-trait transfer withdrawal-x contract-address sender none))) transfer-x-failed-err)
    (asserts! (is-ok (as-contract (contract-call? token-y-trait transfer withdrawal-y contract-address sender none))) transfer-y-failed-err)

    (map-set pairs-data-map { token-x: token-x, token-y: token-y } pair-updated)

    (try! (contract-call? token-liquidity-trait burn tx-sender withdrawal))

    (print { object: "pair", action: "liquidity-removed", data: pair-updated })
    (ok (list withdrawal-x withdrawal-y))
  )
)

;; exchange known dx of x-token for whatever dy of y-token based on current liquidity, returns (dx dy)
;; the swap will not happen if can't get at least min-dy back
(define-public (swap-x-for-y (token-x-trait <sip-010-token>) (token-y-trait <sip-010-token>) (dx uint) (min-dy uint))
  ;; calculate dy
  ;; calculate fee on dx
  ;; transfer
  ;; update balances
  (let
    (
      (token-x (contract-of token-x-trait))
      (token-y (contract-of token-y-trait))
      (pair (unwrap! (map-get? pairs-data-map { token-x: token-x, token-y: token-y }) invalid-pair-err))
      (balance-x (get balance-x pair))
      (balance-y (get balance-y pair))
      (contract-address (as-contract tx-sender))
      (sender tx-sender)
      (fee-1 (unwrap! (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-fee-v1a get-fee-1) fee-contract-err))
      (fee-2 (unwrap! (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-fee-v1a get-fee-2) fee-contract-err))
      (fee-3 (unwrap! (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-fee-v1a get-fee-3) fee-contract-err))
      (fee-4 (unwrap! (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-fee-v1a get-fee-4) fee-contract-err))
      (dy (/ (* fee-1 balance-y dx) (+ (* fee-2 balance-x) (* fee-1 dx)))) ;; overall fee is 30 bp, all for the pool, or 25 bp for pool and 5 bp for operator
      (fee (/ (* fee-3 dx) fee-4)) ;; 5 bp
      (pair-updated
        (merge pair
          {
            balance-x: (+ (get balance-x pair) dx),
            balance-y: (- (get balance-y pair) dy),
            fee-balance-x: (if (is-some (get fee-to-address pair))  ;; only collect fee when fee-to-address is set
              (+ fee (get fee-balance-x pair))
              (get fee-balance-x pair))
          }
        )
      )
    )

    (asserts! (< min-dy dy) too-much-slippage-err)

    (asserts! (is-ok (contract-call? token-x-trait transfer dx sender contract-address none)) transfer-x-failed-err)
    (asserts! (is-ok (as-contract (contract-call? token-y-trait transfer dy contract-address sender none))) transfer-y-failed-err)

    (map-set pairs-data-map { token-x: token-x, token-y: token-y } pair-updated)
    (print { object: "pair", action: "swap-x-for-y", data: pair-updated })
    (ok (list dx dy))
  )
)

;; exchange known dy for whatever dx based on liquidity, returns (dx dy)
;; the swap will not happen if can't get at least min-dx back
(define-public (swap-y-for-x (token-x-trait <sip-010-token>) (token-y-trait <sip-010-token>) (dy uint) (min-dx uint))
  ;; calculate dx
  ;; calculate fee on dy
  ;; transfer
  ;; update balances
  (let ((token-x (contract-of token-x-trait))
        (token-y (contract-of token-y-trait))
        (pair (unwrap! (map-get? pairs-data-map { token-x: token-x, token-y: token-y }) invalid-pair-err))
        (balance-x (get balance-x pair))
        (balance-y (get balance-y pair))
        (contract-address (as-contract tx-sender))
        (sender tx-sender)
        (fee-1 (unwrap! (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-fee-v1a get-fee-1) fee-contract-err))
        (fee-2 (unwrap! (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-fee-v1a get-fee-2) fee-contract-err))
        (fee-3 (unwrap! (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-fee-v1a get-fee-3) fee-contract-err))
        (fee-4 (unwrap! (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-fee-v1a get-fee-4) fee-contract-err))
        ;; check formula, vs x-for-y???
        (dx (/ (* fee-1 balance-x dy) (+ (* fee-2 balance-y) (* fee-1 dy)))) ;; overall fee is 30 bp, all for the pool
        (fee (/ (* fee-3 dy) fee-4)) ;; 0 bp
        (pair-updated (merge pair {
          balance-x: (- (get balance-x pair) dx),
          balance-y: (+ (get balance-y pair) dy),
          fee-balance-y: (if (is-some (get fee-to-address pair))  ;; only collect fee when fee-to-address is set
            (+ fee (get fee-balance-y pair))
            (get fee-balance-y pair))
        })))

    (asserts! (< min-dx dx) too-much-slippage-err)

    (asserts! (is-ok (as-contract (contract-call? token-x-trait transfer dx contract-address sender none))) transfer-x-failed-err)
    (asserts! (is-ok (contract-call? token-y-trait transfer dy sender contract-address none)) transfer-y-failed-err)

    (map-set pairs-data-map { token-x: token-x, token-y: token-y } pair-updated)
    (print { object: "pair", action: "swap-y-for-x", data: pair-updated })
    (ok (list dx dy))
  )
)

;; ;; activate the contract fee for swaps by setting the collection address, restricted to contract owner
(define-public (set-fee-to-address (token-x principal) (token-y principal) (address principal))
  (let ((pair (unwrap! (map-get? pairs-data-map { token-x: token-x, token-y: token-y }) invalid-pair-err)))

    (asserts! (is-eq tx-sender contract-owner) not-owner-err)

    (map-set pairs-data-map { token-x: token-x, token-y: token-y }
      {
        shares-total: (get shares-total pair),
        balance-x: (get balance-y pair),
        balance-y: (get balance-y pair),
        fee-balance-x: (get fee-balance-y pair),
        fee-balance-y: (get fee-balance-y pair),
        fee-to-address: (some address),
        name: (get name pair),
        liquidity-token: (get liquidity-token pair),
      }
    )
    (ok true)
  )
)

;; ;; clear the contract fee addres
(define-public (reset-fee-to-address (token-x principal) (token-y principal))
  (let ((pair (unwrap! (map-get? pairs-data-map { token-x: token-x, token-y: token-y }) invalid-pair-err)))

    (asserts! (is-eq tx-sender contract-owner) not-owner-err)

    (map-set pairs-data-map { token-x: token-x, token-y: token-y }
      {
        shares-total: (get shares-total pair),
        balance-x: (get balance-x pair),
        balance-y: (get balance-y pair),
        fee-balance-x: (get fee-balance-y pair),
        fee-balance-y: (get fee-balance-y pair),
        fee-to-address: none,
        name: (get name pair),
        liquidity-token: (get liquidity-token pair),
      }
    )
    (ok true)
  )
)

;; ;; get the current address used to collect a fee
(define-read-only (get-fee-to-address (token-x principal) (token-y principal))
  (let ((pair (unwrap! (map-get? pairs-data-map { token-x: token-x, token-y: token-y }) invalid-pair-err)))
    (ok (get fee-to-address pair))
  )
)

;; ;; get the amount of fees charged on x-token and y-token exchanges that have not been collected yet
(define-read-only (get-fees (token-x principal) (token-y principal))
  (let ((pair (unwrap! (map-get? pairs-data-map { token-x: token-x, token-y: token-y }) invalid-pair-err)))
    (ok (list (get fee-balance-x pair) (get fee-balance-y pair)))
  )
)

;; ;; send the collected fees the fee-to-address
(define-public (collect-fees (token-x-trait <sip-010-token>) (token-y-trait <sip-010-token>))
  (let
    (
      (token-x (contract-of token-x-trait))
      (token-y (contract-of token-y-trait))
      (contract-address (as-contract tx-sender))
      (pair (unwrap! (map-get? pairs-data-map { token-x: token-x, token-y: token-y }) invalid-pair-err))
      (address (unwrap! (get fee-to-address pair) no-fee-to-address-err))
      (fee-x (get fee-balance-x pair))
      (fee-y (get fee-balance-y pair))
    )

    (asserts! (is-eq fee-x u0) no-fee-x-err)
    (asserts! (is-ok (as-contract (contract-call? token-x-trait transfer fee-x contract-address address none))) transfer-x-failed-err)
    (asserts! (is-eq fee-y u0) no-fee-y-err)
    (asserts! (is-ok (as-contract (contract-call? token-y-trait transfer fee-y contract-address address none))) transfer-y-failed-err)

    (map-set pairs-data-map { token-x: token-x, token-y: token-y }
      {
        shares-total: (get shares-total pair),
        balance-x: (get balance-x pair),
        balance-y: (get balance-y pair),
        fee-balance-x: u0,
        fee-balance-y: u0,
        fee-to-address: (get fee-to-address pair),
        name: (get name pair),
        liquidity-token: (get liquidity-token pair),
      }
    )
    (ok (list fee-x fee-y))
  )
)

(define-public (upgrade-swap-pair (token-x-trait <sip-010-token>) (token-y-trait <sip-010-token>))
  (let ((token-x (contract-of token-x-trait))
    (token-y (contract-of token-y-trait))
    (pair (unwrap! (map-get? pairs-data-map { token-x: token-x, token-y: token-y }) invalid-pair-err))
    (balance-x (get balance-x pair))
    (balance-y (get balance-y pair))
    (contract-address (as-contract tx-sender))
    (new-swap-contract (unwrap-panic (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-dao-v1a get-qualified-name-by-name "swap")))
    (pair-updated (merge pair {
      shares-total: u0,
      balance-x: u0,
      balance-y: u0
    })))
    (begin
      (asserts! (not (is-eq contract-address new-swap-contract)) not-upgraded-err)
      (map-set pairs-data-map { token-x: token-x, token-y: token-y } pair-updated)
      (asserts! (is-ok (as-contract (contract-call? token-x-trait transfer balance-x contract-address new-swap-contract none))) transfer-x-failed-err)
      (asserts! (is-ok (as-contract (contract-call? token-y-trait transfer balance-y contract-address new-swap-contract none))) transfer-y-failed-err)
      (ok true))))