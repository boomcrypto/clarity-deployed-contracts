(impl-trait 'SP3XD84X3PE79SHJAZCDW1V5E9EA8JSKRBPEKAEK7.multisig-traits.executor-trait)
(use-trait wallet-trait 'SP3XD84X3PE79SHJAZCDW1V5E9EA8JSKRBPEKAEK7.multisig-traits.wallet-trait)

(define-public (execute (wallet <wallet-trait>) (arg-p principal) (arg-u uint))
		(stx-transfer? arg-u (contract-of wallet) arg-p)
)