(use-trait ft-velar-token 'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.sip-010-trait-ft-standard.sip-010-trait)
(define-trait hedge-trait
  (
    (perform-swap-hedge (uint uint (buff 32) <ft-velar-token> <ft-velar-token> <ft-velar-token> <ft-velar-token>) (response bool uint))
    (perform-custom-hedge (uint uint) (response bool uint))
  )
)
