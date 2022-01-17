(use-trait ft-trait .sip-010-v1a.sip-010-trait)
(use-trait oracle-trait .stackwap-oracle-trait-v1b.oracle-trait)

(define-trait vault-trait
  (
    (calculate-lbtc-count ((string-ascii 12) uint uint <oracle-trait>) (response uint uint))

    (calculate-current-collateral-to-debt-ratio ((string-ascii 12) uint uint <oracle-trait>) (response uint uint))

    (collateralize-and-mint (<ft-trait> (string-ascii 12) uint uint principal (string-ascii 256) bool) (response uint uint))

    (deposit (<ft-trait> (string-ascii 12) uint (string-ascii 256)) (response bool uint))

    (withdraw (<ft-trait> (string-ascii 12) principal uint) (response bool uint))

    (mint ((string-ascii 12) principal uint uint uint uint <oracle-trait>) (response bool uint))

    (burn (<ft-trait> principal uint) (response bool uint))

    (get-next-stacker-name () (response (string-ascii 256) uint))
  )
)
