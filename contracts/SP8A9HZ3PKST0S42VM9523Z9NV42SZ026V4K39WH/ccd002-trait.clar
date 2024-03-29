(use-trait ft-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)
(use-trait nft-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-trait ccd002-treasury-trait
  (
    (set-allowed (principal bool)
      (response bool uint)
    )
    (deposit-stx (uint)
      (response bool uint)
    )
    (deposit-ft (<ft-trait> uint)
      (response bool uint)
    )
    (deposit-nft (<nft-trait> uint)
      (response bool uint)
    )
    (withdraw-stx (uint principal)
      (response bool uint)
    )
    (withdraw-ft (<ft-trait> uint principal)
      (response bool uint)
    )
    (withdraw-nft (<nft-trait> uint principal)
      (response bool uint)
    )
  )
)
