(use-trait ft-trait .sip010-ft-trait.sip010-ft-trait)

;; Transfer from the caller to a new principal
(define-trait swap-helper-trait
	(
		(swap-helper (<ft-trait> <ft-trait> uint (optional uint)) 
                     (response uint uint))
    )
)