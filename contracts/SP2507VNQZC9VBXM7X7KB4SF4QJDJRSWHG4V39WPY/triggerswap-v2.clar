;; triggers claimstx or claimtoken from lnswap contracts and claim from any contract for trustless LN purchases.

(define-trait claim-trait
  (
    (claim () (response uint uint))
  )
)

(use-trait ft-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(define-public (triggerStx (preimage (buff 32)) (amount (buff 16)) (claimAddress (buff 42)) (refundAddress (buff 42)) (timelock (buff 16)) (nftPrincipal <claim-trait>))
    (begin 
        (try! (contract-call? .stxswap_v8 claimStx preimage amount claimAddress refundAddress timelock))
        (try! (contract-call? nftPrincipal claim))
        (ok true)
    )
)

(define-public (triggerSip10 (preimage (buff 32)) (amount (buff 16)) (claimAddress (buff 42)) (refundAddress (buff 42)) (timelock (buff 16)) (tokenPrincipal <ft-trait>) (nftPrincipal <claim-trait>))
    (begin 
        (try! (contract-call? .sip10swap_v1 claimToken preimage amount claimAddress refundAddress timelock tokenPrincipal))
        (try! (contract-call? nftPrincipal claim))
        (ok true)
    )
)