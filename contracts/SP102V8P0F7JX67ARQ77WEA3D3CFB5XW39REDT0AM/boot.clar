(impl-trait .proposal-trait.proposal-trait)
(define-public (execute (sender principal))
	(begin
		(try! (contract-call? .executor-dao set-extensions (list
			{ extension: .operators, enabled: true }
			{ extension: .token-alex, enabled: true }
		)))
		
		;; Set initial operators
		(try! (contract-call? .operators set-operators (list
			{ operator: 'SP3N9GSEWX710RE5PSD110APZGKSD1EFMBEWSBZJC, enabled: true }
			{ operator: 'SPEJJMSNMD1F74RKVJSGPXJ1839STT5EVY0C64KZ, enabled: true }
			{ operator: 'SP2N8EM3C6WTZXAR19DPWKV78224EK85HB75Y8M84, enabled: true }
			{ operator: 'SP1EF1PKR40XW37GDC0BP7SN4V4JCVSHSDVG71YTH, enabled: true }
			{ operator: 'SPYVNBH68KH10N3Q115VBRQW4E2F6TQVXTWCWNJC, enabled: true }
		)))
		;; Set operator signal threshold, i.e. 3-of-5
		(try! (contract-call? .operators set-proposal-threshold 3))
		(ok true)
	)
)