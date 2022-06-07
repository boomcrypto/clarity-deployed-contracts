(impl-trait .proposal-trait.proposal-trait)

(define-constant ONE_8 (pow u10 u8))

;; weighted-equation-v1-01 v1.01
(define-constant max-in-ratio (/ (* ONE_8 u1) u100))
(define-constant max-out-ratio (/ (* ONE_8 u1) u100))

;; fwp v1.01
(define-constant fifty-percent (/ ONE_8 u2)) ;; equal-weight pool (i.e. Uniswap-like)
(define-constant oracle-average (/ (* ONE_8 u95) u100)) ;; resilient oracle follows (0.05 * now + 0.95 * resilient-oracle-before)
(define-constant fee-rebate (/ ONE_8 u2)) ;; 50% of tx fee goes to LPs
(define-constant fee-rate-x (/ (* ONE_8 u3) u1000)) ;; 0.3% charged on token-x when token-x is sold to buy token-y
(define-constant fee-rate-y (/ (* ONE_8 u3) u1000)) ;; 0.3% charged on token-y when token-y is sold to buy token-x

;; wstx-wmia-50-50 pool v1.01
(define-constant fwp-wmia-dy u2688911400000000) ;; MIA
(define-constant fwp-wmia-dx u9165650000000) ;; STX

;; wstx-wnycc-50-50 pool v1.01
(define-constant fwp-wnycc-dy u6318941800000000) ;; NYC
(define-constant fwp-wnycc-dx u9165650000000) ;; STX

(define-public (execute (sender principal))
	(begin		
		(try! (contract-call? .weighted-equation-v1-01 set-max-in-ratio max-in-ratio))
        (try! (contract-call? .weighted-equation-v1-01 set-max-out-ratio max-out-ratio))

		;; wstx-wmia-50-50 v1.01
		(try! (contract-call? .fixed-weight-pool-v1-01 create-pool 
			.token-wstx 
			.token-wmia
			fifty-percent 
			fifty-percent 
			.fwp-wstx-wmia-50-50-v1-01 
			.multisig-fwp-wstx-wmia-50-50-v1-01 
			fwp-wmia-dx
			fwp-wmia-dy
		))

		(try! (contract-call? .fixed-weight-pool-v1-01 set-fee-rebate .token-wstx .token-wmia fifty-percent fifty-percent fee-rebate))
		(try! (contract-call? .fixed-weight-pool-v1-01 set-fee-rate-x .token-wstx .token-wmia fifty-percent fifty-percent fee-rate-x))
		(try! (contract-call? .fixed-weight-pool-v1-01 set-fee-rate-y .token-wstx .token-wmia fifty-percent fifty-percent fee-rate-y))
		(try! (contract-call? .fixed-weight-pool-v1-01 set-oracle-enabled .token-wstx .token-wmia fifty-percent fifty-percent))
		(try! (contract-call? .fixed-weight-pool-v1-01 set-oracle-average .token-wstx .token-wmia fifty-percent fifty-percent oracle-average))

		;; wstx-wnycc-50-50 v1.01
		(try! (contract-call? .fixed-weight-pool-v1-01 create-pool 
			.token-wstx 
			.token-wnycc
			fifty-percent 
			fifty-percent 
			.fwp-wstx-wnycc-50-50-v1-01 
			.multisig-fwp-wstx-wnycc-50-50-v1-01 
			fwp-wnycc-dx
			fwp-wnycc-dy
		))

		(try! (contract-call? .fixed-weight-pool-v1-01 set-fee-rebate .token-wstx .token-wnycc fifty-percent fifty-percent fee-rebate))
		(try! (contract-call? .fixed-weight-pool-v1-01 set-fee-rate-x .token-wstx .token-wnycc fifty-percent fifty-percent fee-rate-x))
		(try! (contract-call? .fixed-weight-pool-v1-01 set-fee-rate-y .token-wstx .token-wnycc fifty-percent fifty-percent fee-rate-y))
		(try! (contract-call? .fixed-weight-pool-v1-01 set-oracle-enabled .token-wstx .token-wnycc fifty-percent fifty-percent))
		(try! (contract-call? .fixed-weight-pool-v1-01 set-oracle-average .token-wstx .token-wnycc fifty-percent fifty-percent oracle-average))		
		
		(ok true)	
	)
)
