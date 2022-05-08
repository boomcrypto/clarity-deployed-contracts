;; Title: MultiSafe stx transfer executor
;; Author: Talha Bugra Bulut & Trust Machiness

(impl-trait 'SP1Z5Z68R05X2WKSSPQ0QN0VYPB1902884KPDJVNF.multisafe-traits.executor-trait)
(use-trait safe-trait 'SP1Z5Z68R05X2WKSSPQ0QN0VYPB1902884KPDJVNF.multisafe-traits.safe-trait)
(use-trait nft-trait 'SP1Z5Z68R05X2WKSSPQ0QN0VYPB1902884KPDJVNF.multisafe-traits.sip-009-trait)
(use-trait ft-trait 'SP1Z5Z68R05X2WKSSPQ0QN0VYPB1902884KPDJVNF.multisafe-traits.sip-010-trait)

(define-public (execute (safe <safe-trait>) (param-ft <ft-trait>) (param-nft <nft-trait>) (param-p (optional principal)) (param-u (optional uint)) (param-b (optional (buff 20))))
		(stx-transfer? (unwrap! param-u (err u9999)) (contract-of safe) (unwrap! param-p (err u9999)))
)