;; Title: MultiSafe stx transfer executor
;; Author: Talha Bugra Bulut & Trust Machiness

(impl-trait 'SP282BC63F7JNK71YCF7HZHZZ2T9S9P3BN5ZAS3B6.multisafe-traits.executor-trait)
(use-trait safe-trait 'SP282BC63F7JNK71YCF7HZHZZ2T9S9P3BN5ZAS3B6.multisafe-traits.safe-trait)
(use-trait nft-trait 'SP282BC63F7JNK71YCF7HZHZZ2T9S9P3BN5ZAS3B6.multisafe-traits.sip-009-trait)
(use-trait ft-trait 'SP282BC63F7JNK71YCF7HZHZZ2T9S9P3BN5ZAS3B6.multisafe-traits.sip-010-trait)

(define-public (execute (safe <safe-trait>) (param-ft <ft-trait>) (param-nft <nft-trait>) (param-p (optional principal)) (param-u (optional uint)) (param-b (optional (buff 20))))
		(begin
			(try! (stx-transfer? (unwrap! param-u (err u9999)) (contract-of safe) (unwrap! param-p (err u9999))))
			(print param-b)
			(ok true)
		)		
)