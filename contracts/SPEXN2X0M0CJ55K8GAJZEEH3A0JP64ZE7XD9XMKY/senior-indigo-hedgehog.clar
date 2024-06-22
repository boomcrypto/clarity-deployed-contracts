;; wrapper-alex-v-2-1

(use-trait ft-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.trait-sip-010.sip-010-trait)

(define-public (swap-helper
    (token-x-trait <ft-trait>) (token-y-trait <ft-trait>)
    (factor uint)
    (dx uint) (min-dy (optional uint))
  )
  (let (
    (swap-a (try! (contract-call?
                  'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-helper
                  token-x-trait
                  token-y-trait
                  factor
                  dx min-dy)))
  )
    (ok swap-a)
  )
)

(define-public (swap-helper-a
    (token-x-trait <ft-trait>) (token-y-trait <ft-trait>)
    (token-z-trait <ft-trait>)
    (factor-x uint) (factor-y uint)
    (dx uint) (min-dz (optional uint))
  )
  (let (
    (swap-a (try! (contract-call?
                  'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-helper-a
                  token-x-trait token-y-trait
                  token-z-trait
                  factor-x factor-y
                  dx min-dz)))
  )
    (ok swap-a)
  )
)

(define-public (swap-helper-b
    (token-x-trait <ft-trait>) (token-y-trait <ft-trait>)
    (token-z-trait <ft-trait>) (token-w-trait <ft-trait>)
    (factor-x uint) (factor-y uint) (factor-z uint)
    (dx uint) (min-dw (optional uint))
  )
  (let (
    (swap-a (try! (contract-call?
                  'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-helper-b
                  token-x-trait token-y-trait
                  token-z-trait token-w-trait
                  factor-x factor-y factor-z
                  dx min-dw)))
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
  )
  (let (
    (swap-a (try! (contract-call?
                  'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-helper-c
                  token-x-trait token-y-trait
                  token-z-trait token-w-trait
                  token-v-trait
                  factor-x factor-y factor-z factor-w
                  dx min-dv)))
  )
    (ok swap-a)
  )
)