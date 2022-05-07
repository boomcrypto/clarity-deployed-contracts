;; Title: MultiSafe remove owner executor
;; Author: Talha Bugra Bulut & Trust Machines

(impl-trait 'SPZ0PQ7779KHB62W8FQQD6NB7C4GADXFXXD0Q1TD.traits.executor-trait)
(use-trait safe-trait 'SPZ0PQ7779KHB62W8FQQD6NB7C4GADXFXXD0Q1TD.traits.safe-trait)
(use-trait nft-trait 'SPZ0PQ7779KHB62W8FQQD6NB7C4GADXFXXD0Q1TD.traits.sip-009-trait)
(use-trait ft-trait 'SPZ0PQ7779KHB62W8FQQD6NB7C4GADXFXXD0Q1TD.traits.sip-010-trait)

(define-public (execute (safe <safe-trait>) (param-ft <ft-trait>) (param-nft <nft-trait>) (param-p (optional principal)) (param-u (optional uint)) (param-b (optional (buff 20))))
	(contract-call? safe remove-owner (unwrap! param-p (err u9999)))
)