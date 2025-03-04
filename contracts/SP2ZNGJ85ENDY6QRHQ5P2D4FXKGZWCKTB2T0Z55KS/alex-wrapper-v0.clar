;; ALEX wrapper for STX-CHA swaps

(define-public (swap-stx-for-cha (amount-stx uint))
  (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-helper
    'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
    'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.token-wcharisma
    (pow u10 u8)
    (* amount-stx (pow u10 u8))
    none))

(define-public (swap-cha-for-stx (amount-cha uint))
  (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-helper 
    'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.token-wcharisma
    'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
    (pow u10 u8)
    (* amount-cha (pow u10 u8))
    none))