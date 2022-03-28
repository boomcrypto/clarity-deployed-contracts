(impl-trait .proposal-trait.proposal-trait)

(define-constant ONE_8 (pow u10 u8))

;; simple-equation
(define-constant max-in-ratio (/ (* ONE_8 u1) u100))
(define-constant max-out-ratio (/ (* ONE_8 u1) u100))

;; fwp-alex-wban
(define-constant oracle-average (/ (* ONE_8 u95) u100)) ;; resilient oracle follows (0.05 * now + 0.95 * resilient-oracle-before)
(define-constant fee-rebate (/ ONE_8 u2)) ;; 50% of tx fee goes to LPs
(define-constant fee-rate-x (/ (* ONE_8 u3) u1000)) ;; 0.3% charged on token-x when token-x is sold to buy token-y
(define-constant fee-rate-y (/ (* ONE_8 u3) u1000)) ;; 0.3% charged on token-y when token-y is sold to buy token-x
(define-constant start-block u340282366920938463463374607431768211455) ;; disable first

;; initial liquidity
(define-constant dy (* u50000 ONE_8)) ;; 50,000 BANANA
(define-constant dx (* u16500 ONE_8)) ;; 16,500 ALEX

;; staking
(define-constant fwp-alex-activation-block u53951) ;; matches claim-end of IDO
(define-constant fwp-alex-coinbase-1 (* u2000 ONE_8)) ;; emission of $ALEX per cycle in 1st year
(define-constant fwp-alex-coinbase-2 (* u1000 ONE_8)) ;; emission of $ALEX per cycle in 2nd year
(define-constant fwp-alex-coinbase-3 (* u500 ONE_8)) ;; emission of $ALEX per cycle in 3rd year
(define-constant fwp-alex-coinbase-4 (* u250 ONE_8)) ;; emission of $ALEX per cycle in 4th year
(define-constant fwp-alex-coinbase-5 (* u125 ONE_8)) ;; emission of $ALEX per cycle in 5th year
(define-constant fwp-alex-apower-multipler (/ (* u3 ONE_8) u10)) ;; APower multipler

(define-public (execute (sender principal))
	(begin
		(try! (contract-call? .simple-equation set-max-in-ratio max-in-ratio))
        (try! (contract-call? .simple-equation set-max-out-ratio max-out-ratio))

		(try! (contract-call? .alex-vault add-approved-contract .simple-weight-pool-alex))
		(try! (contract-call? .alex-reserve-pool add-approved-contract .simple-weight-pool-alex))

		(try! (contract-call? .age000-governance-token mint-fixed dx .executor-dao))

		(try! (contract-call? .simple-weight-pool-alex create-pool 
			.age000-governance-token
			.token-wban
			.fwp-alex-wban 
			.multisig-fwp-alex-wban 
			dx 
			dy
		))
		(try! (contract-call? .simple-weight-pool-alex set-start-block .age000-governance-token .token-wban start-block))		
		(try! (contract-call? .simple-weight-pool-alex set-fee-rebate .age000-governance-token .token-wban fee-rebate))
		(try! (contract-call? .simple-weight-pool-alex set-fee-rate-x .age000-governance-token .token-wban fee-rate-x))
		(try! (contract-call? .simple-weight-pool-alex set-fee-rate-y .age000-governance-token .token-wban fee-rate-y))
		(try! (contract-call? .simple-weight-pool-alex set-oracle-enabled .age000-governance-token .token-wban))
		(try! (contract-call? .simple-weight-pool-alex set-oracle-average .age000-governance-token .token-wban oracle-average))

		;; staking
    	(try! (contract-call? .alex-reserve-pool add-token .fwp-alex-wban))
    	(try! (contract-call? .alex-reserve-pool set-coinbase-amount .fwp-alex-wban fwp-alex-coinbase-1 fwp-alex-coinbase-2 fwp-alex-coinbase-3 fwp-alex-coinbase-4 fwp-alex-coinbase-5))
    	(try! (contract-call? .alex-reserve-pool set-apower-multiplier-in-fixed .fwp-alex-wban fwp-alex-apower-multipler))
    	(try! (contract-call? .alex-reserve-pool set-activation-block .fwp-alex-wban fwp-alex-activation-block))

		(ok true)	
	)
)
