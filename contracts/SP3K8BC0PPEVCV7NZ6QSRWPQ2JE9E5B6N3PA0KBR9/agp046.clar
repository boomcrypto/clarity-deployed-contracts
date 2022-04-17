(impl-trait .proposal-trait.proposal-trait)

(define-constant ONE_8 (pow u10 u8))

;; simple-equation
(define-constant max-in-ratio (/ (* ONE_8 u5) u100)) ;; 5%
(define-constant max-out-ratio (/ (* ONE_8 u5) u100)) ;; 5%

;; fwp-alex-wslm
(define-constant oracle-average (/ (* ONE_8 u95) u100)) ;; resilient oracle follows (0.05 * now + 0.95 * resilient-oracle-before)
(define-constant fee-rebate (/ ONE_8 u2)) ;; 50% of tx fee goes to LPs
(define-constant fee-rate-x (/ (* ONE_8 u3) u1000)) ;; 0.3% charged on token-x when token-x is sold to buy token-y
(define-constant fee-rate-y (/ (* ONE_8 u3) u1000)) ;; 0.3% charged on token-y when token-y is sold to buy token-x
(define-constant start-block u56576)

;; initial liquidity
(define-constant dy (* u360000 ONE_8)) ;; 360,000 SLIME
(define-constant dx (* u67950 ONE_8)) ;; 67,950 ALEX

(define-public (execute (sender principal))
	(begin
		(try! (contract-call? .simple-equation set-max-in-ratio max-in-ratio))
        (try! (contract-call? .simple-equation set-max-out-ratio max-out-ratio))

		(try! (contract-call? .alex-vault add-approved-contract .simple-weight-pool-alex))
		(try! (contract-call? .alex-reserve-pool add-approved-contract .simple-weight-pool-alex))

		(try! (contract-call? .age000-governance-token mint-fixed dx .executor-dao))

		(try! (contract-call? .simple-weight-pool-alex create-pool 
			.age000-governance-token
			.token-wslm
			.fwp-alex-wslm 
			.multisig-fwp-alex-wslm 
			dx 
			dy
		))
		(try! (contract-call? .simple-weight-pool-alex set-start-block .age000-governance-token .token-wslm start-block))		
		(try! (contract-call? .simple-weight-pool-alex set-fee-rebate .age000-governance-token .token-wslm fee-rebate))
		(try! (contract-call? .simple-weight-pool-alex set-fee-rate-x .age000-governance-token .token-wslm fee-rate-x))
		(try! (contract-call? .simple-weight-pool-alex set-fee-rate-y .age000-governance-token .token-wslm fee-rate-y))
		(try! (contract-call? .simple-weight-pool-alex set-oracle-enabled .age000-governance-token .token-wslm))
		(try! (contract-call? .simple-weight-pool-alex set-oracle-average .age000-governance-token .token-wslm oracle-average))

		(ok true)	
	)
)
