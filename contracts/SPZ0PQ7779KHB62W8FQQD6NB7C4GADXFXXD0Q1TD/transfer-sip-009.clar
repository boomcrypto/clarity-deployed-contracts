;; Title: MultiSafe sip-009 non-fungible token transfer executor
;; Author: Talha Bugra Bulut & Trust Machiness

(impl-trait 'SPZ0PQ7779KHB62W8FQQD6NB7C4GADXFXXD0Q1TD.traits.executor-trait)
(use-trait safe-trait 'SPZ0PQ7779KHB62W8FQQD6NB7C4GADXFXXD0Q1TD.traits.safe-trait)
(use-trait nft-trait 'SPZ0PQ7779KHB62W8FQQD6NB7C4GADXFXXD0Q1TD.traits.sip-009-trait)
(use-trait ft-trait 'SPZ0PQ7779KHB62W8FQQD6NB7C4GADXFXXD0Q1TD.traits.sip-010-trait)

(define-public (execute (safe <safe-trait>) (param-ft <ft-trait>) (param-nft <nft-trait>) (param-p (optional principal)) (param-u (optional uint)) (param-b (optional (buff 20))))
        (contract-call? param-nft transfer (unwrap! param-u (err u9999)) (contract-of safe) (unwrap! param-p (err u9999)))
)