(use-trait sip-010-token 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.sip-010-v1a.sip-010-trait)
(use-trait liquidity-token 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-trait-v2a.liquidity-token-trait)

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
(define-constant lp-data-set-err (err u4180))
(define-constant lp-data-get-err (err u4181))

;; for future use, or debug
(define-constant e10-err (err u4120))
(define-constant e11-err (err u4121))
(define-constant e12-err (err u4122))


(define-map pairs-map
  { pair-id: uint }
  {
    token-x: principal,
    token-y: principal,
    liquidity-token: principal
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
    liquidity-token: principal
  }
)

(define-data-var pair-count uint u0)


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
        fee-to-address: contract-owner,
        liquidity-token: (contract-of token-liquidity-trait),
        name: pair-name,
      })
    )
    ;;TODO Check if the lp token is valid
    (asserts!
      (and
        (is-none (map-get? pairs-data-map { token-x: token-x, token-y: token-y }))
        (is-none (map-get? pairs-data-map { token-x: token-y, token-y: token-x }))
        (is-none (map-get? pairs-token-map { pair-token: token-liquidity}))
      )
      pair-already-exists-err
    )
    (unwrap! (contract-call? token-liquidity-trait initialize-swap token-x token-y) invalid-pair-err)
    (unwrap! (contract-call? token-liquidity-trait set-lp-data pair-data token-x token-y) lp-data-set-err)

    (map-set pairs-data-map { token-x: token-x, token-y: token-y } {liquidity-token: (contract-of token-liquidity-trait)})
    (map-set pairs-token-map { pair-token: token-liquidity} {exist: u1})
    (map-set pairs-map { pair-id: pair-id } { token-x: token-x, token-y: token-y, liquidity-token: (contract-of token-liquidity-trait)})
    (var-set pair-count pair-id)

    (try! (add-to-position token-x-trait token-y-trait token-liquidity-trait x y))
    (print { object: "pair", action: "created", data: pair-data })
    (ok true)
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
      (pair (unwrap! (contract-call? token-liquidity-trait get-lp-data) lp-data-get-err))
      ;; (pair (unwrap-panic (map-get? pairs-data-map { token-x: token-x, token-y: token-y })))
      (contract-address (contract-of token-liquidity-trait))
      (recipient-address tx-sender)
      (balance-x (get balance-x pair))
      (balance-y (get balance-y pair))
      (lp (asserts! (is-eq (get liquidity-token pair) (contract-of token-liquidity-trait)) wrong-token-err))
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
    ;;TODO transfer from lp-token
    (asserts! (is-ok (contract-call? token-x-trait transfer x tx-sender contract-address none)) transfer-x-failed-err)
    (asserts! (is-ok (contract-call? token-y-trait transfer new-y tx-sender contract-address none)) transfer-y-failed-err)

    (unwrap! (contract-call? token-liquidity-trait set-lp-data pair-updated token-x token-y) lp-data-set-err)
    (try! (contract-call? token-liquidity-trait mint recipient-address new-shares))
    (print { object: "pair", action: "liquidity-added", data: pair-updated })
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
      (pair (unwrap! (contract-call? token-liquidity-trait get-lp-data) lp-data-get-err))
      (balance-x (get balance-x pair))
      (balance-y (get balance-y pair))
      (lp (asserts! (is-eq (get liquidity-token pair) (contract-of token-liquidity-trait)) wrong-token-err))
      (shares (unwrap! (contract-call? token-liquidity-trait get-balance tx-sender) lp-data-get-err))
      (shares-total (get shares-total pair))
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
    (asserts! (is-ok (as-contract (contract-call? token-liquidity-trait transfer-token withdrawal-x token-x-trait sender))) transfer-x-failed-err)
    (asserts! (is-ok (as-contract (contract-call? token-liquidity-trait transfer-token withdrawal-y token-y-trait sender))) transfer-y-failed-err)

    (unwrap! (contract-call? token-liquidity-trait set-lp-data pair-updated token-x token-y) lp-data-set-err)

    (try! (contract-call? token-liquidity-trait burn tx-sender withdrawal))

    (print { object: "pair", action: "liquidity-removed", data: pair-updated })
    (ok (list withdrawal-x withdrawal-y))
  )
)

;; exchange known dx of x-token for whatever dy of y-token based on current liquidity, returns (dx dy)
;; the swap will not happen if can't get at least min-dy back
(define-public (swap-x-for-y (token-x-trait <sip-010-token>) (token-y-trait <sip-010-token>) (token-liquidity-trait <liquidity-token>) (dx uint) (min-dy uint))
  ;; calculate dy
  ;; calculate fee on dx
  ;; transfer
  ;; update balances
  (let
    (
      (token-x (contract-of token-x-trait))
      (token-y (contract-of token-y-trait))
      (pair (unwrap! (contract-call? token-liquidity-trait get-lp-data) lp-data-get-err))
      (balance-x (get balance-x pair))
      (balance-y (get balance-y pair))
      (contract-address (contract-of token-liquidity-trait))
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
            fee-balance-x: (+ fee (get fee-balance-x pair))
          }
        )
      )
    )

    (asserts! (< min-dy dy) too-much-slippage-err)

    ;;TODO transfer from lp-token
    (asserts! (is-ok (contract-call? token-x-trait transfer dx sender contract-address none)) transfer-x-failed-err)
    (asserts! (is-ok (as-contract (contract-call? token-liquidity-trait transfer-token dy token-y-trait sender))) transfer-y-failed-err)

    (unwrap! (contract-call? token-liquidity-trait set-lp-data pair-updated token-x token-y) lp-data-set-err)
    (print { object: "pair", action: "swap-x-for-y", data: pair-updated })
    (ok (list dx dy))
  )
)

;; exchange known dy for whatever dx based on liquidity, returns (dx dy)
;; the swap will not happen if can't get at least min-dx back
(define-public (swap-y-for-x (token-x-trait <sip-010-token>) (token-y-trait <sip-010-token>) (token-liquidity-trait <liquidity-token>) (dy uint) (min-dx uint))
  ;; calculate dx
  ;; calculate fee on dy
  ;; transfer
  ;; update balances
  (let ((token-x (contract-of token-x-trait))
        (token-y (contract-of token-y-trait))
        (pair (unwrap! (contract-call? token-liquidity-trait get-lp-data) lp-data-get-err))
        (balance-x (get balance-x pair))
        (balance-y (get balance-y pair))
        (contract-address (contract-of token-liquidity-trait))
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
          fee-balance-y: (+ fee (get fee-balance-y pair))
        })))

    (asserts! (< min-dx dx) too-much-slippage-err)

    ;;TODO transfer from lp-token
    (asserts! (is-ok (as-contract (contract-call? token-liquidity-trait transfer-token dx token-x-trait sender))) transfer-x-failed-err)
    (asserts! (is-ok (contract-call? token-y-trait transfer dy sender contract-address none)) transfer-y-failed-err)

    (unwrap! (contract-call? token-liquidity-trait set-lp-data pair-updated token-x token-y) lp-data-set-err)
    (print { object: "pair", action: "swap-y-for-x", data: pair-updated })
    (ok (list dx dy))
  )
)

;; ;; activate the contract fee for swaps by setting the collection address, restricted to contract owner
(define-public (set-fee-to-address (token-x principal) (token-y principal) (token-liquidity-trait <liquidity-token>) (address principal))
  (let (
      (pair (unwrap! (contract-call? token-liquidity-trait get-lp-data) lp-data-get-err))
    )

    (asserts! (is-eq tx-sender contract-owner) not-owner-err)

    (unwrap! (contract-call? token-liquidity-trait set-lp-data {
        shares-total: (get shares-total pair),
        balance-x: (get balance-y pair),
        balance-y: (get balance-y pair),
        fee-balance-x: (get fee-balance-y pair),
        fee-balance-y: (get fee-balance-y pair),
        fee-to-address: address,
        name: (get name pair),
        liquidity-token: (get liquidity-token pair),
      } token-x token-y) lp-data-set-err)
    (ok true)
  )
)

;; ;; send the collected fees the fee-to-address
(define-public (collect-fees (token-x-trait <sip-010-token>) (token-y-trait <sip-010-token>) (token-liquidity-trait <liquidity-token>))
  (let
    (
      (token-x (contract-of token-x-trait))
      (token-y (contract-of token-y-trait))
      (pair (unwrap! (contract-call? token-liquidity-trait get-lp-data) lp-data-get-err))
      (address (get fee-to-address pair))
      (fee-x (get fee-balance-x pair))
      (fee-y (get fee-balance-y pair))
    )
    (print {fee-x: fee-x})
    (print {fee-y: fee-y})
    (asserts! (> fee-x u0) no-fee-x-err)
    (asserts! (> fee-y u0) no-fee-y-err)

    (asserts! (is-ok (as-contract (contract-call? token-liquidity-trait transfer-token fee-x token-x-trait address))) transfer-x-failed-err)
    (asserts! (is-ok (as-contract (contract-call? token-liquidity-trait transfer-token fee-y token-y-trait address))) transfer-y-failed-err)

    
    (unwrap! (contract-call? token-liquidity-trait set-lp-data {
        shares-total: (get shares-total pair),
        balance-x: (get balance-x pair),
        balance-y: (get balance-y pair),
        fee-balance-x: u0,
        fee-balance-y: u0,
        fee-to-address: (get fee-to-address pair),
        name: (get name pair),
        liquidity-token: (get liquidity-token pair),
      } token-x token-y) lp-data-set-err)
    (ok (list fee-x fee-y))
  )
)