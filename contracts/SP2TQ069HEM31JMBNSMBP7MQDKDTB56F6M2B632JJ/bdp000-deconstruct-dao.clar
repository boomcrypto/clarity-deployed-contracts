;; Title: BDP000 Deconstruct
;; Description:
;; Disables the extensions and switches dao off

(impl-trait  'SP3JP0N1ZXGASRJ0F7QAHWFPGTVK9T2XNXDB908Z.proposal-trait.proposal-trait)

(define-public (execute (sender principal))
	(begin
		(try! (contract-call? .bigmarket-dao set-extensions
			(list
				{extension: .bme000-0-governance-token, enabled: false}
				{extension: .bme001-0-proposal-voting, enabled: false}
				{extension: .bme003-0-core-proposals, enabled: false}
				{extension: .bme006-0-treasury, enabled: false}
				{extension: .bme010-0-liquidity-contribution, enabled: false}
				{extension: .bme021-0-market-voting, enabled: false}
				{extension: .bme022-0-market-gating, enabled: false}
				{extension: .bme024-0-market-scalar-pyth, enabled: false}
				{extension: .bme024-0-market-predicting, enabled: false}
				;;{extension: .bme030-0-reputation-token, enabled: false}
				{extension: .bme032-0-scalar-strategy-hedge, enabled: false}
			)
		))
		(ok true)
	)
)
