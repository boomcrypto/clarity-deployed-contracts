(impl-trait .oracle-trait.oracle-trait)
(use-trait ft .ft-trait.ft-trait)

(define-read-only (to-fixed (a uint) (decimals-a uint))
  (contract-call? .math-v1-2 to-fixed a decimals-a))

(define-read-only (mul-to-fixed-precision (a uint) (decimals-a uint) (b-fixed uint))
  (contract-call? .math-v1-2 mul-to-fixed-precision a decimals-a b-fixed))

(define-read-only (mul (a uint) (b uint))
  (contract-call? .math-v1-2 mul a b))

(define-constant one-diko u1000000)
(define-constant one-stx u1000000)
(define-constant one-usda u1000000)

(define-constant err-panic (err u2999))
(define-constant err-unauthorized (err u3000))
(define-constant err-below-threshold (err u3001))
(define-constant err-above-threshold (err u3002))
(define-constant err-out-of-range (err u3003))
(define-constant err-stale-price (err u3004))
(define-constant err-pair-does-not-exist (err u3005))

(define-constant deployer tx-sender)

(define-constant dex-stx 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token)
(define-constant dex-diko 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token)

;; maximum difference of 1% from average dex diko price
(define-data-var max-delta uint u1000000)
;; 2USD
(define-data-var max-price uint u200000000)
;; 0.01USD
(define-data-var min-price uint u1000000)

(define-data-var validate-oracle-price bool false)

(define-public (set-validate-oracle-price (enabled bool))
  (begin
    (asserts! (is-eq tx-sender deployer) err-unauthorized)
    (ok (var-set validate-oracle-price enabled))
  )
)

(define-public (set-min-price (amount uint))
  (begin
    (asserts! (is-eq tx-sender deployer) err-unauthorized)
    (ok (var-set min-price amount))
  )
)

(define-public (set-max-price (amount uint))
  (begin
    (asserts! (is-eq tx-sender deployer) err-unauthorized)
    (ok (var-set max-price amount))
  )
)

(define-public (set-max-delta (amount uint))
  (begin
    (asserts! (is-eq tx-sender deployer) err-unauthorized)
    (ok (var-set max-delta amount))
  )
)

;; get the price from the oracle and use the average dex price for sanity checks
(define-public (get-asset-price (token <ft>))
  (let (
    (last-price (to-fixed (get last-price (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-oracle-v2-3 get-price "DIKO")) u6))
    ;; (last-price (to-fixed (get last-price (contract-call? .arkadiko-oracle get-price "DIKO")) u6))
  )
    (if (var-get validate-oracle-price)
      (try! (validate-price last-price))
      false
    )
    ;; sanity check
    (asserts! (> last-price (var-get min-price)) err-below-threshold)
    (asserts! (< last-price (var-get max-price)) err-above-threshold)

    (ok last-price)
  )
)

;; read-only version, non-functional
(define-read-only (get-price)
  (let (
    (last-price (to-fixed (get last-price (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-oracle-v2-3 get-price "DIKO")) u6))
    ;; (last-price (to-fixed (get last-price (contract-call? .arkadiko-oracle get-price "DIKO")) u6))
  )
    (asserts! (> last-price (var-get min-price)) err-below-threshold)
    (asserts! (< last-price (var-get max-price)) err-above-threshold)

    (ok last-price)
  )
)

(define-read-only (validate-price (oracle-price uint))
  (let (
    (average-dex-diko-price (try! (get-average-dex-diko-price)))
    (diff (mul average-dex-diko-price (var-get max-delta))))
    ;; ensure that price from oracle is between a range of the average dex price
    (asserts! (< oracle-price (+ average-dex-diko-price diff)) err-out-of-range)
    (asserts! (> oracle-price (- average-dex-diko-price diff)) err-out-of-range)
    (ok true)
  )
)

(define-read-only (get-average-dex-diko-price)
  (let (
    (last-block (- burn-block-height u1))
    (random-bytes (unwrap! (get-random-bytes last-block u2) err-panic))
    (rand-1 (mod (buff-to-uint-le (unwrap-panic (slice? random-bytes u0 u1))) u10))
    (rand-2 (mod (buff-to-uint-le (unwrap-panic (slice? random-bytes u1 u2))) u10))
    (heights (list last-block (- last-block rand-1) (- last-block rand-2)))
    (prices (get-diko-prices heights))
  )
    ;; average price from the last 3 blocks
    (ok (/ (try! (fold add-resp prices (ok u0))) (len heights)))
  )
)

(define-read-only (add-resp (amount-to-add (response uint uint)) (total (response uint uint)))
  (match amount-to-add
    amount (ok (+ (try! total) amount))
    bad-resp (err bad-resp)
  )
)

(define-read-only (get-random-bytes (height uint) (size uint))
  (match (get-block-info? vrf-seed height)
    vrf-seed (some (unwrap! (as-max-len? (unwrap! (slice? vrf-seed u0 size) none) u16) none))
    none)
)

(define-read-only (get-diko-prices (heights (list 10 uint)))
  (map get-diko-price-at heights)
)

(define-read-only (get-diko-price-at (height uint))
  (ok
    (at-block
      (unwrap-panic (get-block-info? id-header-hash height))
      (try! (get-diko-dex-price))
    )
  )
)

;; get exchange rate between stx/diko, convert stx amount to it's currency value
(define-read-only (get-diko-dex-price)
  (ok (mul-to-fixed-precision (try! (get-y-for-x dex-stx dex-diko one-diko)) u6 (try! (get-stx-price))))
)

(define-read-only (get-stx-price)
  (let (
    (oracle-data (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-oracle-v2-3 get-price "STX"))
    ;; (oracle-data (contract-call? .arkadiko-oracle get-price "STX"))
  )
    (asserts! (<= (- burn-block-height (get last-block oracle-data)) u10) err-stale-price)
    (ok (to-fixed (get last-price oracle-data) u6))
  )
)

;; get the value of 1 DIKO in STX using x*y=k curve
(define-read-only (get-y-for-x (contract-x principal) (contract-y principal) (dx uint))
  ;; ref: https://github.com/arkadiko-dao/arkadiko/blob/master/clarity/contracts/swap/arkadiko-swap-v2-1.clar#L473
  (match
    (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 get-pair-details contract-x contract-y)
    ;; (contract-call? .dex get-pair-details contract-x contract-y)
    pair
      (let (
        (balance-x (get balance-x (unwrap-panic pair)))
        (balance-y (get balance-y (unwrap-panic pair)))
        (dx-with-fees (/ (* u997 dx) u1000))
        (dy (/ (* balance-x dx-with-fees) (+ balance-y dx-with-fees)))
        )
        (ok dy)
      )
    err-res err-pair-does-not-exist
  )
)
