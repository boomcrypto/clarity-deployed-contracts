(use-trait ft .ft-trait.ft-trait)
(use-trait z-token-trait .a-token-trait.a-token-trait)
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
        (list 100 (tuple (asset <ft>) (lp-token <z-token-trait>) (oracle <oracle-trait>)))
      )
      (response uint uint)
    )
	)
)
