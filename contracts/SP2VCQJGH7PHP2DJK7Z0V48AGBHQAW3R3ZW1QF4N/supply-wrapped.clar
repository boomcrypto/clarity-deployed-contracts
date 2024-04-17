(use-trait ft .ft-trait.ft-trait)
(use-trait ft-mint-trait .ft-mint-trait.ft-mint-trait)
(use-trait a-token .a-token-trait.a-token-trait)
(use-trait flash-loan .flash-loan-trait.flash-loan-trait)
(use-trait oracle-trait .oracle-trait.oracle-trait)

(define-public (supply
  (lp <ft-mint-trait>)
  (pool-reserve principal)
  (asset <ft>)
  (amount uint)
  (owner principal)
  (referral (optional principal))
  )
  (begin
    (match referral
      referral-resp (begin
          (print { type: "supply-referral", payload: { key: owner, data: { asset: asset, amount: amount, referral: referral-resp } } })
          (contract-call? .pool-borrow supply lp pool-reserve asset amount owner)
        )
        (contract-call? .pool-borrow supply lp pool-reserve asset amount owner)
    )
  )
)
