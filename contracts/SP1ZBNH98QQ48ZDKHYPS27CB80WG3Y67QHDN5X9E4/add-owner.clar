;; Title: MultiSafe add owner executor
;; Author: Talha Bugra Bulut & Trust Machines

(impl-trait 'SP1ZBNH98QQ48ZDKHYPS27CB80WG3Y67QHDN5X9E4.multisafe-traits.executor-trait)
(use-trait safe-trait 'SP1ZBNH98QQ48ZDKHYPS27CB80WG3Y67QHDN5X9E4.multisafe-traits.safe-trait)
(use-trait nft-trait 'SP1ZBNH98QQ48ZDKHYPS27CB80WG3Y67QHDN5X9E4.multisafe-traits.sip-009-trait)
(use-trait ft-trait 'SP1ZBNH98QQ48ZDKHYPS27CB80WG3Y67QHDN5X9E4.multisafe-traits.sip-010-trait)

(define-public (execute (safe <safe-trait>) (param-ft <ft-trait>) (param-nft <nft-trait>) (param-p (optional principal)) (param-u (optional uint)) (param-b (optional (buff 20))))
	(contract-call? safe add-owner (unwrap! param-p (err u9999)))
)