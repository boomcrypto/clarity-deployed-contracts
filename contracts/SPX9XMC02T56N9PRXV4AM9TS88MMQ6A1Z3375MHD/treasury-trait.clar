(use-trait ft-trait .ft-trait.ft-trait)
(use-trait nft-trait .nft-trait.nft-trait)

(define-trait treasury-trait
  (
    ;; deposit assets into dao
    (deposit-stx (uint) (response bool uint))
    (deposit-ft (<ft-trait> uint) (response bool uint))
    (deposit-nft (<nft-trait> uint) (response bool uint))

    ;; dao moves asset out of treasury
    (move-stx (uint principal) (response bool uint))
    (move-ft (<ft-trait> uint principal) (response bool uint))
    (move-nft (<nft-trait> uint principal) (response bool uint))
  )
)