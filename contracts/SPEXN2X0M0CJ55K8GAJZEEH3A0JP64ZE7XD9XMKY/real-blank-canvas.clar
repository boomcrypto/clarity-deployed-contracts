;; wrapper-alex-v-2-2

(use-trait ft-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.trait-sip-010.sip-010-trait)

(define-read-only (get-helper
    (token-x principal) (token-y principal)
    (factor uint)
    (dx uint)
    (provider (optional principal))
  )
  (let (
    (amount-after-aggregator-fees (try! (get-aggregator-fees provider dx)))
    (call-a (try! (contract-call?
                  'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-helper
                  token-x token-y
                  factor
                  amount-after-aggregator-fees)))
  )
    (ok call-a)
  )
)

(define-read-only (get-helper-a
    (token-x principal) (token-y principal)
    (token-z principal)
    (factor-x uint) (factor-y uint)
    (dx uint)
    (provider (optional principal))
  )
  (let (
    (amount-after-aggregator-fees (try! (get-aggregator-fees provider dx)))
    (call-a (try! (contract-call?
                  'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-helper-a
                  token-x token-y
                  token-z
                  factor-x factor-y
                  amount-after-aggregator-fees)))
  )
    (ok call-a)
  )
)

(define-read-only (get-helper-b
    (token-x principal) (token-y principal)
    (token-z principal) (token-w principal)
    (factor-x uint) (factor-y uint) (factor-z uint)
    (dx uint)
    (provider (optional principal))
  )
  (let (
    (amount-after-aggregator-fees (try! (get-aggregator-fees provider dx)))
    (call-a (try! (contract-call?
                  'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-helper-b
                  token-x token-y
                  token-z token-w
                  factor-x factor-y factor-z
                  amount-after-aggregator-fees)))
  )
    (ok call-a)
  )
)

(define-read-only (get-helper-c
    (token-x principal) (token-y principal)
    (token-z principal) (token-w principal)
    (token-v principal)
    (factor-x uint) (factor-y uint) (factor-z uint) (factor-w uint)
    (dx uint)
    (provider (optional principal))
  )
  (let (
    (amount-after-aggregator-fees (try! (get-aggregator-fees provider dx)))
    (call-a (try! (contract-call?
                  'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-helper-c
                  token-x token-y
                  token-z token-w
                  token-v
                  factor-x factor-y factor-z factor-w
                  amount-after-aggregator-fees)))
  )
    (ok call-a)
  )
)

(define-public (swap-helper
    (token-x-trait <ft-trait>) (token-y-trait <ft-trait>)
    (factor uint)
    (dx uint) (min-dy (optional uint))
    (provider (optional principal))
  )
  (let (
    (amount-after-aggregator-fees (try! (transfer-aggregator-fees token-x-trait provider dx)))
    (swap-a (try! (contract-call?
                  'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-helper
                  token-x-trait token-y-trait
                  factor
                  amount-after-aggregator-fees min-dy)))
  )
    (ok swap-a)
  )
)

(define-public (swap-helper-a
    (token-x-trait <ft-trait>) (token-y-trait <ft-trait>)
    (token-z-trait <ft-trait>)
    (factor-x uint) (factor-y uint)
    (dx uint) (min-dz (optional uint))
    (provider (optional principal))
  )
  (let (
    (amount-after-aggregator-fees (try! (transfer-aggregator-fees token-x-trait provider dx)))
    (swap-a (try! (contract-call?
                  'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-helper-a
                  token-x-trait token-y-trait
                  token-z-trait
                  factor-x factor-y
                  amount-after-aggregator-fees min-dz)))
  )
    (ok swap-a)
  )
)

(define-public (swap-helper-b
    (token-x-trait <ft-trait>) (token-y-trait <ft-trait>)
    (token-z-trait <ft-trait>) (token-w-trait <ft-trait>)
    (factor-x uint) (factor-y uint) (factor-z uint)
    (dx uint) (min-dw (optional uint))
    (provider (optional principal))
  )
  (let (
    (amount-after-aggregator-fees (try! (transfer-aggregator-fees token-x-trait provider dx)))
    (swap-a (try! (contract-call?
                  'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-helper-b
                  token-x-trait token-y-trait
                  token-z-trait token-w-trait
                  factor-x factor-y factor-z
                  amount-after-aggregator-fees min-dw)))
  )
    (ok swap-a)
  )
)

(define-public (swap-helper-c
    (token-x-trait <ft-trait>) (token-y-trait <ft-trait>)
    (token-z-trait <ft-trait>) (token-w-trait <ft-trait>)
    (token-v-trait <ft-trait>)
    (factor-x uint) (factor-y uint) (factor-z uint) (factor-w uint)
    (dx uint) (min-dv (optional uint))
    (provider (optional principal))
  )
  (let (
    (amount-after-aggregator-fees (try! (transfer-aggregator-fees token-x-trait provider dx)))
    (swap-a (try! (contract-call?
                  'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-helper-c
                  token-x-trait token-y-trait
                  token-z-trait token-w-trait
                  token-v-trait
                  factor-x factor-y factor-z factor-w
                  amount-after-aggregator-fees min-dv)))
  )
    (ok swap-a)
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