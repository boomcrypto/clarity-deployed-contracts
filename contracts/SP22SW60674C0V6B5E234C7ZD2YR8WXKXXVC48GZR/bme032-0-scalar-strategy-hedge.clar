;; Title: BME032 Strategy for scalar market hedging
;; Synopsis:
;; Provides a hook for scalar markets to run hedging function during cool down.
;; Description:
;; The idea is to create an algorithmic hedge fund - we assume the community 
;; surfaces the winning outcome and swap treasury tokens in response. The contractcalls the 
;; the treasury with the form/to token contracts and works out the direction bearish/bullish
;; of the signal together with the signal strength strong/medium/weak. 

(impl-trait .hedge-trait.hedge-trait)
(use-trait ft-velar-token 'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.sip-010-trait-ft-standard.sip-010-trait)

(define-constant err-unauthorised (err u32000))
(define-constant err-already-hedged (err u32001))
(define-constant err-already-executed (err u32002))
(define-constant err-hedge-not-found (err u32003))
(define-constant err-token-incorrect (err u32004))
(define-constant err-pair-not-found (err u32005))
(define-constant err-cooldown (err u32006))
(define-constant err-amount-zero (err u32007))
(define-constant err-slippage (err u32008))
(define-constant err-invalid-amount (err u32009))

(define-data-var hedge-market-contract principal .bme024-0-market-predicting)
(define-data-var hedge-scalar-contract principal .bme024-0-market-scalar-pyth)
(define-data-var hedge-multipliers (list 6 uint) (list u750 u500 u250 u250 u500 u750))
(define-data-var max-hedge-bips uint u1000)      ;; hard cap per trade = 10% of balance
(define-data-var max-hedge-abs  uint u0)         ;; optional absolute cap (0 = disabled)
(define-data-var min-trade      uint u0)         ;; optional minimum trade size (0 = disabled)
(define-data-var per-market-cooldown uint u144)  ;; ~1 day (tune as needed)
(define-data-var per-trade-slippage uint u300)   ;; 3% default for hedges (stricter than treasury 5%)

(define-map last-hedge-height {market-id:uint} uint)  ;; anti-replay

(define-map swap-token-pairs (buff 32) {token-in: principal, token-out: principal, token0: principal, token1: principal})
(define-map hedges
  uint
  {executed: bool, feed-id: (buff 32)}
)

(define-public (is-dao-or-extension)
	(ok (asserts! (or (is-eq tx-sender .bigmarket-dao) (contract-call? .bigmarket-dao is-extension contract-caller)) err-unauthorised)))

(define-public (set-hedge-multipliers (multipliers (list 6 uint)))
  (begin
    (try! (is-dao-or-extension))
    (var-set hedge-multipliers multipliers)
    (print {event: "hedge-multipliers", multipliers: multipliers})
    (ok true)
  )
)

(define-public (set-hedge-market-contract (market-contract principal))
  (begin
    (try! (is-dao-or-extension))
    (var-set hedge-market-contract market-contract)
    (print {event: "hedge-market-contract", market-contract: market-contract})
    (ok true)
  )
)

(define-public (set-hedge-scalar-contract (market-contract principal))
  (begin
    (try! (is-dao-or-extension))
    (var-set hedge-scalar-contract market-contract)
    (print {event: "hedge-scalar-contract", market-contract: market-contract})
    (ok true)
  )
)

(define-public (set-hedge-caps (bips uint) (abs uint))
  (begin (try! (is-dao-or-extension))
         (asserts! (<= bips u5000) err-invalid-amount) ;; <=50%
         (var-set max-hedge-bips bips)
         (var-set max-hedge-abs  abs)
         (ok true)))

(define-public (set-hedge-min-trade (min uint))
  (begin (try! (is-dao-or-extension)) (var-set min-trade min) (ok true)))

(define-public (set-hedge-cooldown (blocks uint))
  (begin (try! (is-dao-or-extension)) (var-set per-market-cooldown blocks) (ok true)))

(define-public (set-hedge-slippage (bips uint))
  (begin (try! (is-dao-or-extension))
         (asserts! (and (>= bips u1) (<= bips u3000)) err-invalid-amount)
         (var-set per-trade-slippage bips) (ok true)))

(define-public (set-swap-token-pair
  (feed-id (buff 32))
  (token-a principal)
  (token-b principal)
  (token-in principal)
  (token-out principal))
  (begin
    (try! (is-dao-or-extension))
    ;; Check token-in is one of token-a or token-b
    (asserts! (or (is-eq token-in token-a) (is-eq token-in token-b)) err-token-incorrect)
    ;; Check token-out is the other one
    (asserts! (or (is-eq token-out token-a) (is-eq token-out token-b)) err-token-incorrect)
    (asserts! (not (is-eq token-in token-out)) err-token-incorrect)

    ;; Lexicographic ordering
    (let (
      (buff-a (unwrap! (to-consensus-buff? token-a) err-token-incorrect))
      (buff-b (unwrap! (to-consensus-buff? token-b) err-token-incorrect))
      (token0 (if (< buff-a buff-b) token-a token-b))
      (token1 (if (< buff-a buff-b) token-b token-a))

    )
      (map-set swap-token-pairs
        feed-id
        {
          token-in: token-in,
          token-out: token-out,
          token0: token0,
          token1: token1
        })
      (print {event: "swap-token-pair", feed-id: feed-id, token-in: token-in, token-out: token-out, token0: token0, token1: token1})
      (ok true)
    )
  )
)

(define-read-only (get-swap-token-pair (feed-id (buff 32)))
	(map-get? swap-token-pairs feed-id)
)

(define-public (perform-swap-hedge
  (market-id uint) (predicted-index uint) (feed-id (buff 32))
  (token0 <ft-velar-token>) (token1 <ft-velar-token>)
  (token-in <ft-velar-token>) (token-out <ft-velar-token>)
)
  (let (
    (pair (unwrap! (map-get? swap-token-pairs feed-id) err-pair-not-found))
    (is-bearish (< predicted-index u3))
    (expected-in  (if is-bearish (get token-in pair)  (get token-out pair)))
    (expected-out (if is-bearish (get token-out pair) (get token-in pair)))
    (lh (default-to u0 (map-get? last-hedge-height {market-id: market-id})))
    (cool (var-get per-market-cooldown))
  )
    ;; auth + source contract check
    (try! (is-dao-or-extension))
    (asserts! (is-eq contract-caller (var-get hedge-scalar-contract)) err-unauthorised)

    ;; one-shot safety: refuse if this market was already hedged here
    (asserts! (is-none (map-get? hedges market-id)) err-already-executed)

    ;; cooldown even if another component tries to hedge repeatedly
    (if (> lh u0)
      (asserts! (> stacks-block-height (+ lh cool)) err-cooldown)
      true
    )

    ;; pair validation: enforce tokens match configured direction
    (asserts! (is-eq (contract-of token-in)  expected-in)  err-token-incorrect)
    (asserts! (is-eq (contract-of token-out) expected-out) err-token-incorrect)

    ;; compute bounded amount
    (let (
      (balance (unwrap! (contract-call? token-in get-balance .bme006-0-treasury) err-unauthorised))
      (bips-mult (unwrap! (element-at? (var-get hedge-multipliers) predicted-index) err-token-incorrect)) ;; e.g., 750 = 7.5%
      (cap-bips (var-get max-hedge-bips))
      (bips (if (> bips-mult cap-bips) cap-bips bips-mult))
      (raw (/ (* balance bips) u10000))
      (abs-cap (var-get max-hedge-abs))
      (amt (if (and (> abs-cap u0) (> raw abs-cap)) abs-cap raw))
      (min-size (var-get min-trade))
    )
      (asserts! (> amt u0) err-amount-zero)
      (if (> min-size u0) (asserts! (>= amt min-size) err-amount-zero) true)

      ;; do the swap with stricter slippage than treasury default
      (let ((slip (var-get per-trade-slippage)))
        (asserts! (and (>= slip u1) (<= slip u3000)) err-slippage)
        (try! (contract-call? .bme006-0-treasury swap-tokens-with-slippage
              token0 token1 token-in token-out amt slip))
      )

      ;; record hedge + height
      (map-set hedges market-id {executed: true, feed-id: feed-id})
      (map-set last-hedge-height {market-id: market-id} stacks-block-height)
      (print {event:"perform-swap-hedge", market-id: market-id, predicted: predicted-index, feed-id: feed-id, amount: amt})
      (ok true)
    )
  )
)

;; can be implemented in later contract
(define-public (perform-custom-hedge (market-id uint) (predicted-index uint))
  (begin 
    ;; caller must be both an ACTIVE extension and sepecifically the scalar prediction market
    (try! (is-dao-or-extension))
    (asserts! (is-eq contract-caller (var-get hedge-market-contract)) err-unauthorised)
    (print {event: "perform-custom-hedge", market-id: market-id, predicted: predicted-index})
    (ok true)
  )
)

(define-private (compute-swap-amount (token <ft-velar-token>) (index uint))
  (let (
      (balance (unwrap! (contract-call? token get-balance .bme006-0-treasury) err-unauthorised))
      (bips (unwrap! (element-at? (var-get hedge-multipliers) index) err-token-incorrect))
      (amt (/ (* balance bips) u10000))
    )
    (ok amt)
  )
)
