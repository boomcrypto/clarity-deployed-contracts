;; wrapper-arkadiko-v-1-2

(use-trait ft-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(define-constant ERR_PAIR_EXTERNAL (err u201))
(define-constant ERR_BALANCE_X (err u201))
(define-constant ERR_BALANCE_Y (err u201))

(define-read-only (get-dy
    (token-x principal) (token-y principal)
    (dx uint) (provider (optional principal))
  )
  (let (
    (amount-after-aggregator-fees (try! (get-aggregator-fees provider dx)))
    (arkadiko-pool (unwrap! (contract-call?
                            'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 get-pair-details
                            token-x token-y) ERR_PAIR_EXTERNAL))
    (balance-x (unwrap! (get balance-x arkadiko-pool) ERR_BALANCE_X))
    (balance-y (unwrap! (get balance-y arkadiko-pool) ERR_BALANCE_Y))
    (dx-with-fees (/ (* u997 amount-after-aggregator-fees) u1000))
    (dy (/ (* balance-y dx-with-fees) (+ balance-x dx-with-fees)))
  )
    (ok dy)
  )
)

(define-read-only (get-dx
    (token-x principal) (token-y principal)
    (dy uint) (provider (optional principal))
  )
  (let (
    (amount-after-aggregator-fees (try! (get-aggregator-fees provider dy)))
    (arkadiko-pool (unwrap! (contract-call?
                            'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 get-pair-details
                            token-x token-y) ERR_PAIR_EXTERNAL))
    (balance-x (unwrap! (get balance-x arkadiko-pool) ERR_BALANCE_X))
    (balance-y (unwrap! (get balance-y arkadiko-pool) ERR_BALANCE_Y))
    (dy-with-fees (/ (* u997 amount-after-aggregator-fees) u1000))
    (dx (/ (* balance-x dy-with-fees) (+ balance-y dy-with-fees)))
  )
    (ok dx)
  )
)

(define-public (swap-x-for-y (token-x-trait <ft-trait>) (token-y-trait <ft-trait>) (dx uint) (min-dy uint) (provider (optional principal)))
  (let (
    (amount-after-aggregator-fees (try! (transfer-aggregator-fees token-x-trait provider dx)))
    (call (try! (contract-call?
                'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y
                token-x-trait
                token-y-trait
                amount-after-aggregator-fees min-dy)))
  )
    (ok call)
  )
)

(define-public (swap-y-for-x (token-x-trait <ft-trait>) (token-y-trait <ft-trait>) (dy uint) (min-dx uint) (provider (optional principal)))
  (let (
    (amount-after-aggregator-fees (try! (transfer-aggregator-fees token-y-trait provider dy)))
    (call (try! (contract-call?
                'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x
                token-x-trait
                token-y-trait
                amount-after-aggregator-fees min-dx)))
  )
    (ok call)
  )
)

(define-private (get-aggregator-fees (provider (optional principal)) (amount uint))
  (let (
    (call-a (try! (contract-call?
                  'SPEXN2X0M0CJ55K8GAJZEEH3A0JP64ZE7XD9XMKY.tart-red-carp get-aggregator-fees
                  (as-contract tx-sender) provider amount)))
    (amount-after-fees (- amount (get amount-fees-total call-a)))
  )
    (ok amount-after-fees)
  )
)

(define-private (transfer-aggregator-fees (token <ft-trait>) (provider (optional principal)) (amount uint))
  (let (
    (call-a (try! (contract-call?
                  'SPEXN2X0M0CJ55K8GAJZEEH3A0JP64ZE7XD9XMKY.tart-red-carp transfer-aggregator-fees
                  token (as-contract tx-sender) provider amount)))
    (amount-after-fees (- amount (get amount-fees-total call-a)))
  )
    (ok amount-after-fees)
  )
)