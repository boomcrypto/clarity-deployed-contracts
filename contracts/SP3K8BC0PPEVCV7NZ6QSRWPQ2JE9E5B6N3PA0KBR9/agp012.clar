(impl-trait .proposal-trait.proposal-trait)

(define-constant ONE_8 (pow u10 u8))

;; weighted-equation v1.01
(define-constant max-in-ratio (/ (* ONE_8 u1) u100))
(define-constant max-out-ratio (/ (* ONE_8 u1) u100))

(define-constant reduce-amount (/ (* ONE_8 u95) u100))

;; fwp v1.01
(define-constant fifty-percent (/ ONE_8 u2)) ;; equal-weight pool (i.e. Uniswap-like)
(define-constant oracle-average (/ (* ONE_8 u95) u100)) ;; resilient oracle follows (0.05 * now + 0.95 * resilient-oracle-before)
(define-constant fee-rebate (/ ONE_8 u2)) ;; 50% of tx fee goes to LPs
(define-constant fee-rate-x (/ (* ONE_8 u3) u1000)) ;; 0.3% charged on token-x when token-x is sold to buy token-y
(define-constant fee-rate-y (/ (* ONE_8 u3) u1000)) ;; 0.3% charged on token-y when token-y is sold to buy token-x

;; wstx-wbtc-50-50 pool v1.01
(define-constant fwp-wbtc-dy (/ (* ONE_8 u1) u100)) ;; 0.01 XBTC
(define-constant fwp-wbtc-dx (* fwp-wbtc-dy u24620)) ;; 0.01 XBTC at 24,620 STX / 246.2 STX

;; staking - fwp-wstx-alex-50-50 v1.01
(define-constant fwp-alex-activation-block u46601) ;; matches claim-end of IDO
(define-constant fwp-alex-coinbase-1 (* u138000  ONE_8)) ;; emission of $ALEX per cycle in 1st year
(define-constant fwp-alex-coinbase-2 (* u69000 ONE_8)) ;; emission of $ALEX per cycle in 2nd year
(define-constant fwp-alex-coinbase-3 (* u34500 ONE_8)) ;; emission of $ALEX per cycle in 3rd year
(define-constant fwp-alex-coinbase-4 (* u17250 ONE_8)) ;; emission of $ALEX per cycle in 4th year
(define-constant fwp-alex-coinbase-5 (* u8625 ONE_8)) ;; emission of $ALEX per cycle in 5th year
(define-constant fwp-alex-apower-multipler (/ (* u3 ONE_8) u10)) ;; APower multipler

;; staking - fwp-wstx-wbtc-50-50 v1.01
(define-constant fwp-wbtc-activation-block u46601) ;; matches claim-end of IDO
(define-constant fwp-wbtc-coinbase-1 (* u688000  ONE_8)) ;; emission of $ALEX per cycle in 1st year
(define-constant fwp-wbtc-coinbase-2 (* u344000 ONE_8)) ;; emission of $ALEX per cycle in 2nd year
(define-constant fwp-wbtc-coinbase-3 (* u172000 ONE_8)) ;; emission of $ALEX per cycle in 3rd year
(define-constant fwp-wbtc-coinbase-4 (* u86000 ONE_8)) ;; emission of $ALEX per cycle in 4th year
(define-constant fwp-wbtc-coinbase-5 (* u43000 ONE_8)) ;; emission of $ALEX per cycle in 5th year
(define-constant fwp-wbtc-apower-multipler (/ (* u3 ONE_8) u10)) ;; APower multipler

;; staking - disable
(define-constant null-activation-block u340282366920938463463374607431768211455) ;; far away
(define-constant null-coinbase-1 u0) ;; emission of $ALEX per cycle in 1st year
(define-constant null-coinbase-2 u0) ;; emission of $ALEX per cycle in 2nd year
(define-constant null-coinbase-3 u0) ;; emission of $ALEX per cycle in 3rd year
(define-constant null-coinbase-4 u0) ;; emission of $ALEX per cycle in 4th year
(define-constant null-coinbase-5 u0) ;; emission of $ALEX per cycle in 5th year

(define-public (execute (sender principal))
	(let
		(
			(alex-reduce (try! (contract-call? .fixed-weight-pool reduce-position .token-wstx .age000-governance-token fifty-percent fifty-percent .fwp-wstx-alex-50-50 reduce-amount)))
			(wbtc-reduce (try! (contract-call? .fixed-weight-pool reduce-position .token-wstx .token-wbtc fifty-percent fifty-percent .fwp-wstx-wbtc-50-50 reduce-amount)))
		)

		(try! (contract-call? .weighted-equation-v1-01 set-max-in-ratio max-in-ratio))
        (try! (contract-call? .weighted-equation-v1-01 set-max-out-ratio max-out-ratio))

		(try! (contract-call? .alex-vault add-approved-contract .fixed-weight-pool-v1-01))
		(try! (contract-call? .alex-reserve-pool add-approved-contract .fixed-weight-pool-v1-01))

		;; wstx-alex-50-50 v1.01
		(try! (contract-call? .fixed-weight-pool-v1-01 create-pool 
			.token-wstx 
			.age000-governance-token 
			fifty-percent 
			fifty-percent 
			.fwp-wstx-alex-50-50-v1-01 
			.multisig-fwp-wstx-alex-50-50-v1-01 
			(get dx alex-reduce)
			(get dy alex-reduce)
		))
		(try! (contract-call? .fixed-weight-pool-v1-01 set-fee-rebate .token-wstx .age000-governance-token fifty-percent fifty-percent fee-rebate))
		(try! (contract-call? .fixed-weight-pool-v1-01 set-fee-rate-x .token-wstx .age000-governance-token fifty-percent fifty-percent fee-rate-x))
		(try! (contract-call? .fixed-weight-pool-v1-01 set-fee-rate-y .token-wstx .age000-governance-token fifty-percent fifty-percent fee-rate-y))
		(try! (contract-call? .fixed-weight-pool-v1-01 set-oracle-enabled .token-wstx .age000-governance-token fifty-percent fifty-percent))
		(try! (contract-call? .fixed-weight-pool-v1-01 set-oracle-average .token-wstx .age000-governance-token fifty-percent fifty-percent oracle-average))

		;; disable staking - fwp-wstx-alex-50-50
    	(try! (contract-call? .alex-reserve-pool set-coinbase-amount .fwp-wstx-alex-50-50 null-coinbase-1 null-coinbase-2 null-coinbase-3 null-coinbase-4 null-coinbase-5))
    	(try! (contract-call? .alex-reserve-pool set-activation-block .fwp-wstx-alex-50-50 null-activation-block))

		;; staking - fwp-wstx-alex-50-50 v1.01
    	(try! (contract-call? .alex-reserve-pool add-token .fwp-wstx-alex-50-50-v1-01))
    	(try! (contract-call? .alex-reserve-pool set-coinbase-amount .fwp-wstx-alex-50-50-v1-01 fwp-alex-coinbase-1 fwp-alex-coinbase-2 fwp-alex-coinbase-3 fwp-alex-coinbase-4 fwp-alex-coinbase-5))
    	(try! (contract-call? .alex-reserve-pool set-apower-multiplier-in-fixed .fwp-wstx-alex-50-50-v1-01 fwp-alex-apower-multipler))
    	(try! (contract-call? .alex-reserve-pool set-activation-block .fwp-wstx-alex-50-50-v1-01 fwp-alex-activation-block))

		;; wstx-wbtc-50-50 v1.01
		(try! (contract-call? .fixed-weight-pool-v1-01 create-pool 
			.token-wstx 
			.token-wbtc
			fifty-percent 
			fifty-percent 
			.fwp-wstx-wbtc-50-50-v1-01 
			.multisig-fwp-wstx-wbtc-50-50-v1-01 
			fwp-wbtc-dx
			fwp-wbtc-dy
		))
		(try! (contract-call? .fixed-weight-pool-v1-01 set-fee-rebate .token-wstx .token-wbtc fifty-percent fifty-percent fee-rebate))
		(try! (contract-call? .fixed-weight-pool-v1-01 set-fee-rate-x .token-wstx .token-wbtc fifty-percent fifty-percent fee-rate-x))
		(try! (contract-call? .fixed-weight-pool-v1-01 set-fee-rate-y .token-wstx .token-wbtc fifty-percent fifty-percent fee-rate-y))
		(try! (contract-call? .fixed-weight-pool-v1-01 set-oracle-enabled .token-wstx .token-wbtc fifty-percent fifty-percent))
		(try! (contract-call? .fixed-weight-pool-v1-01 set-oracle-average .token-wstx .token-wbtc fifty-percent fifty-percent oracle-average))

		;; disable staking - fwp-wstx-wbtc-50-50
    	(try! (contract-call? .alex-reserve-pool set-coinbase-amount .fwp-wstx-wbtc-50-50 null-coinbase-1 null-coinbase-2 null-coinbase-3 null-coinbase-4 null-coinbase-5))
    	(try! (contract-call? .alex-reserve-pool set-activation-block .fwp-wstx-wbtc-50-50 null-activation-block))

		;; staking - fwp-wstx-wbtc-50-50 v1.01
    	(try! (contract-call? .alex-reserve-pool add-token .fwp-wstx-wbtc-50-50-v1-01))
    	(try! (contract-call? .alex-reserve-pool set-coinbase-amount .fwp-wstx-wbtc-50-50-v1-01 fwp-wbtc-coinbase-1 fwp-wbtc-coinbase-2 fwp-wbtc-coinbase-3 fwp-wbtc-coinbase-4 fwp-wbtc-coinbase-5))
    	(try! (contract-call? .alex-reserve-pool set-apower-multiplier-in-fixed .fwp-wstx-wbtc-50-50-v1-01 fwp-wbtc-apower-multipler))
    	(try! (contract-call? .alex-reserve-pool set-activation-block .fwp-wstx-wbtc-50-50-v1-01 fwp-wbtc-activation-block))	
		
		(ok true)	
	)
)
