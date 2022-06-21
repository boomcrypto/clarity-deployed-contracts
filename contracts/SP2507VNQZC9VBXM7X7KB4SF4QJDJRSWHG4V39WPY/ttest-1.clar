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

(define-trait trustless-rewards-trait
  (
    (create-lobby ((string-ascii 99) uint uint uint (string-ascii 30) (string-ascii 10) (string-ascii 10) (string-ascii 10) uint) (response uint uint))

    (join (uint) (response uint uint))
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

(define-public (triggerCreateLobby (preimage (buff 32)) (amount uint) (description (string-ascii 99)) (price uint) (factor uint) (commission uint) 
  (mapy (string-ascii 30)) (length (string-ascii 10)) (traffic (string-ascii 10)) (curves (string-ascii 10)) (hours uint) (contractPrincipal <trustless-rewards-trait>))
    (begin 
        (try! (contract-call? .stxswap_v10 claimStx preimage amount))
        (try! (contract-call? contractPrincipal create-lobby description price factor commission mapy length traffic curves hours))
        (ok true)
    )
)

(define-public (triggerJoinLobby (preimage (buff 32)) (amount uint) (id uint) (contractPrincipal <trustless-rewards-trait>))
    (begin 
        (try! (contract-call? .stxswap_v10 claimStx preimage amount))
        (try! (contract-call? contractPrincipal join id))
        (ok true)
    )
)