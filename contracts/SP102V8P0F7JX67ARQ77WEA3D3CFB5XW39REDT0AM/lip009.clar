(impl-trait 'SM26NBC8SFHNW4P1Y4DFH27974P56WN86C92HPEHH.proposal-trait.proposal-trait)
(define-public (execute (sender principal))
	(let (
      (current-cycle (unwrap-panic (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.alex-reserve-pool get-reward-cycle 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token block-height)))
      (intrinsic (contract-call? .auto-alex-v3 get-shares-to-tokens u100000000)))
    (try! (contract-call? .auto-alex-v3-registry set-shares-to-tokens-per-cycle (- current-cycle u1) intrinsic))
		(ok true)))