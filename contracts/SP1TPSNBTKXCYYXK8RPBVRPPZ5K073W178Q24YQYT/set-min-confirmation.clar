(impl-trait .traits.executor-trait)
(use-trait wallet-trait .traits.wallet-trait)

(define-public (execute (wallet <wallet-trait>) (arg-p principal) (arg-u uint) (arg-buff (buff 256)) (arg-bool bool))
	(contract-call? wallet set-min-confirmation arg-u)
)
