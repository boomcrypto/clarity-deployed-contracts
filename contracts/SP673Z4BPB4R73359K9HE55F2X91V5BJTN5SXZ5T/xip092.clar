;; SPDX-License-Identifier: BUSL-1.1

(impl-trait 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.proposal-trait.proposal-trait)
(use-trait ft-trait 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.trait-sip-010.sip-010-trait)

(define-constant err-token-mismatch (err u1001))

(define-constant MAX_UINT u240282366920938463463374607431768211455)
(define-constant ONE_8 u100000000)

(define-public (execute (sender principal))
	(begin
		(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.operators set-operators (list
			{ operator: 'SP3N9GSEWX710RE5PSD110APZGKSD1EFMBEWSBZJC, enabled: false }
			{ operator: 'SPEJJMSNMD1F74RKVJSGPXJ1839STT5EVY0C64KZ, enabled: false }
			{ operator: 'SP2N8EM3C6WTZXAR19DPWKV78224EK85HB75Y8M84, enabled: false }
			{ operator: 'SP414JA5BZ7QBWET7QEC8Y18KQFKRVXCST5JZZ24, enabled: false }
			{ operator: 'SP1YMSMZQ8XSNKWHEXPWJ03T18E6ZTFJD3SH40FBZ, enabled: false }

			{ operator: 'SP1ZSS4BHNV0K3A1T11VEWCB8D201YERK06NE77ZZ, enabled: true }
			{ operator: 'SP35FE814XBW9GN406MA4JD3ZN5TDX2S7X2VH0X6, enabled: true }
			{ operator: 'SP1K07FYC74N1WB5A7TM4WMB10GYQN64GDR1E645N, enabled: true }
			{ operator: 'SP2FGHFNGMH6NF2427Y20271Q6CKJ67FDX2V2JG6X, enabled: true }
			{ operator: 'SP11M99GX0YGHMBFCA7W4952AHFQTT9XEX33BFQSZ, enabled: true }
		)))
(ok true)))
