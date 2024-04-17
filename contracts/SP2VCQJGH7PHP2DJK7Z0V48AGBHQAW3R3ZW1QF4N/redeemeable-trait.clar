(use-trait ft .ft-trait.ft-trait)
(use-trait ft-mint-trait .ft-mint-trait.ft-mint-trait)
(use-trait oracle-trait .oracle-trait.oracle-trait)

(define-trait redeemeable-trait
	(
		(withdraw
      (
        principal
        <ft>
        <oracle-trait>
        uint
        principal
        (list 100 (tuple (asset <ft>) (lp-token <ft-mint-trait>) (oracle <oracle-trait>)))
      )
      (response uint uint)
    )
	)
)
