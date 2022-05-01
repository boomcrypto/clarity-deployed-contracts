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

;; wstx-wxusd-50-50 pool v1.01
(define-constant fwp-wxusd-dy (* u50000 ONE_8)) ;; 50,000 xUSD
(define-constant fwp-wxusd-dx (* u50000 ONE_8)) ;; 50,000 STX

;; staking - fwp-wstx-wxusd-50-50 v1.01
(define-constant fwp-wxusd-activation-block u58151) ;;
(define-constant fwp-wxusd-coinbase-1 (* u20000  ONE_8)) ;; emission of $ALEX per cycle in 1st year
(define-constant fwp-wxusd-coinbase-2 (* u10000 ONE_8)) ;; emission of $ALEX per cycle in 2nd year
(define-constant fwp-wxusd-coinbase-3 (* u5000 ONE_8)) ;; emission of $ALEX per cycle in 3rd year
(define-constant fwp-wxusd-coinbase-4 (* u2500 ONE_8)) ;; emission of $ALEX per cycle in 4th year
(define-constant fwp-wxusd-coinbase-5 (* u1250 ONE_8)) ;; emission of $ALEX per cycle in 5th year
(define-constant fwp-wxusd-apower-multipler (/ (* u3 ONE_8) u10)) ;; APower multipler

(define-public (execute (sender principal))
	(begin
		(try! (contract-call? .weighted-equation-v1-01 set-max-in-ratio max-in-ratio))
        (try! (contract-call? .weighted-equation-v1-01 set-max-out-ratio max-out-ratio))

		(try! (contract-call? .alex-vault add-approved-contract .fixed-weight-pool-v1-01))
		(try! (contract-call? .alex-reserve-pool add-approved-contract .fixed-weight-pool-v1-01))

		;; wstx-wxusd-50-50 v1.01
		(try! (contract-call? .fixed-weight-pool-v1-01 create-pool 
			.token-wstx 
			.token-wxusd
			fifty-percent 
			fifty-percent 
			.fwp-wstx-wxusd-50-50-v1-01 
			.multisig-fwp-wstx-wxusd-50-50-v1-01 
			fwp-wxusd-dx
			fwp-wxusd-dy
		))

		(try! (contract-call? .fixed-weight-pool-v1-01 set-fee-rebate .token-wstx .token-wxusd fifty-percent fifty-percent fee-rebate))
		(try! (contract-call? .fixed-weight-pool-v1-01 set-fee-rate-x .token-wstx .token-wxusd fifty-percent fifty-percent fee-rate-x))
		(try! (contract-call? .fixed-weight-pool-v1-01 set-fee-rate-y .token-wstx .token-wxusd fifty-percent fifty-percent fee-rate-y))
		(try! (contract-call? .fixed-weight-pool-v1-01 set-oracle-enabled .token-wstx .token-wxusd fifty-percent fifty-percent))
		(try! (contract-call? .fixed-weight-pool-v1-01 set-oracle-average .token-wstx .token-wxusd fifty-percent fifty-percent oracle-average))

		;; staking - fwp-wstx-wxusd-50-50 v1.01
    	(try! (contract-call? .alex-reserve-pool add-token .fwp-wstx-wxusd-50-50-v1-01))
    	(try! (contract-call? .alex-reserve-pool set-coinbase-amount .fwp-wstx-wxusd-50-50-v1-01 fwp-wxusd-coinbase-1 fwp-wxusd-coinbase-2 fwp-wxusd-coinbase-3 fwp-wxusd-coinbase-4 fwp-wxusd-coinbase-5))
    	(try! (contract-call? .alex-reserve-pool set-apower-multiplier-in-fixed .fwp-wstx-wxusd-50-50-v1-01 fwp-wxusd-apower-multipler))
    	(try! (contract-call? .alex-reserve-pool set-activation-block .fwp-wstx-wxusd-50-50-v1-01 fwp-wxusd-activation-block))	
		
		(ok true)	
	)
)
