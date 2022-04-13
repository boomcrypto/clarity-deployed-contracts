(use-trait commission-trait .commission-trait.commission)
(use-trait lookup-trait .lookup-trait.lookup-trait)

(define-trait staking
  (
    (stake (<commission-trait> <lookup-trait> uint) (response bool uint))

    (unstake (<commission-trait> <lookup-trait> uint) (response bool uint))
  )
)