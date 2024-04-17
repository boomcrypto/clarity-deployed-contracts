(use-trait ft .ft-trait.ft-trait)

(define-trait vault-trait
  (
    ;; transfer ft from the contract to a new principal
    ;; amount sender recipient <token-contract>
    (transfer (uint principal <ft>) (response bool uint))
  )
)
