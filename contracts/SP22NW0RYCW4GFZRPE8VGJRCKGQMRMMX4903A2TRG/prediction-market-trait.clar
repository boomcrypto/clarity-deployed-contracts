(use-trait ft-token 'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.sip-010-trait-ft-standard.sip-010-trait)
(define-trait prediction-market-trait
  (
    (dispute-resolution (uint principal uint) (response bool uint))
    (resolve-market-vote (uint uint) (response bool uint))
    (transfer-shares (uint uint principal principal uint <ft-token>) (response uint uint))
    (claim-winnings (uint <ft-token>) (response uint uint))
  )
)