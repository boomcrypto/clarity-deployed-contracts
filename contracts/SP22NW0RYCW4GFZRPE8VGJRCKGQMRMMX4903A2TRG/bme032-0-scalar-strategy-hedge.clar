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

(define-data-var hedge-market-contract principal .bme024-0-market-predicting)
(define-data-var hedge-scalar-contract principal .bme024-0-market-scalar-pyth)
(define-data-var hedge-multipliers (list 6 uint) (list u750 u500 u250 u250 u500 u750))

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

(define-public (perform-swap-hedge (market-id uint) (predicted-index uint) (feed-id (buff 32)) (token0 <ft-velar-token>) (token1 <ft-velar-token>) (token-in <ft-velar-token>) (token-out <ft-velar-token>))
  (let (
    (pair (unwrap! (map-get? swap-token-pairs feed-id) err-pair-not-found))
    (is-bearish (< predicted-index u3))
    ;; conditional direction
    (actual-token-in (if is-bearish token-in token-out))
    (actual-token-out (if is-bearish token-out token-in))
  )
    ;; caller must be both an ACTIVE extension and sepecifically the scalar prediction market
    (try! (is-dao-or-extension))
    (asserts! (is-eq contract-caller (var-get hedge-scalar-contract)) err-unauthorised)
    ;; Choose direction
    (try! (contract-call? .bme006-0-treasury swap-tokens
      token0
      token1
      actual-token-in
      actual-token-out
      (unwrap! (compute-swap-amount actual-token-in predicted-index) err-unauthorised)
    ))
    ;; Store hedge record
    (map-set hedges
      market-id
      {
        executed: true,
        feed-id : feed-id 
      }
    )
    (print {event: "perform-swap-hedge", market-id: market-id, predicted: predicted-index, feed-id: feed-id})
    (ok true)
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
