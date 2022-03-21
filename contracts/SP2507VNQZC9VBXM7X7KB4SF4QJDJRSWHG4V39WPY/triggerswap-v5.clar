;; LNSwap external atomic swap triggers
;; triggers claim from lnswap contracts and mint/transfer to any contract/principal for trustless LN -> STX interaction.

(define-trait claim-trait
  (
    (claim () (response uint uint))
  )
)

(define-trait claim-usda-trait
  (
    (claim-usda () (response uint uint))
  )
)

(use-trait ft-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(define-public (triggerStx (preimage (buff 32)) (amount uint) (nftPrincipal <claim-trait>))
    (begin 
        (try! (contract-call? .stxswap_v10 claimStx preimage amount))
        (try! (contract-call? nftPrincipal claim))
        (ok true)
    )
)

(define-public (triggerTransferStx (preimage (buff 32)) (amount uint) (receiver principal) (memo (string-ascii 40)))
    (begin
        (try! (contract-call? .stxswap_v10 claimStx preimage amount))
        (try! (stx-transfer? amount tx-sender receiver))
        (print {action: "transfer", address: tx-sender, memo: memo})
        (ok true)
    )
)

(define-public (triggerSip10 (preimage (buff 32)) (amount uint) (tokenPrincipal <ft-trait>) (nftPrincipal <claim-usda-trait>))
    (begin 
        (try! (contract-call? .sip10swap_v3 claimToken preimage amount tokenPrincipal))
        (try! (contract-call? nftPrincipal claim-usda))
        (ok true)
    )
)
