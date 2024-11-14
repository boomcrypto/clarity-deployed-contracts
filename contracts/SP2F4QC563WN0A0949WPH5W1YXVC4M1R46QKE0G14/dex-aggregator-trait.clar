(use-trait ft-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)
(use-trait ft-trait-ext 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.trait-sip-010.sip-010-trait)

(define-trait dex-aggregator-trait
	(
    (get-quote 
			(uint (optional (list 5 <ft-trait>)) (optional (list 5 <ft-trait-ext>)) (optional (list 4 uint))) 
			(response {t2-out: uint, t3-out: uint, t4-out: uint, t5-out: uint} uint)
		)
		
		(swap 
			(uint uint (optional (list 5 <ft-trait>)) (optional (list 5 <ft-trait-ext>)) (optional (list 4 uint)))  
			(response {t2-out: uint, t3-out: uint, t4-out: uint, t5-out: uint} uint)
		)
			
	)
)
