(impl-trait .proposal-trait.proposal-trait)

(define-constant ONE_8 (pow u10 u8))

(define-constant fifty-percent (/ ONE_8 u2)) ;; equal-weight pool (i.e. Uniswap-like)
(define-constant dx (* u105236 ONE_8)) ;; 105,236 STX
(define-constant dy (* u5 ONE_8)) ;; 5 XBTC
(define-constant oracle-average (/ (* ONE_8 u95) u100)) ;; resilient oracle follows (0.05 * now + 0.95 * resilient-oracle-before)
(define-constant fee-rebate (/ ONE_8 u2)) ;; 50% of tx fee goes to LPs
(define-constant fee-rate-x (/ (* ONE_8 u3) u1000)) ;; 0.3% charged on token-x when token-x is sold to buy token-y
(define-constant fee-rate-y (/ (* ONE_8 u3) u1000)) ;; 0.3% charged on token-y when token-y is sold to buy token-x

;; staking - fwp-wstx-wbtc-50-50
(define-constant fwp-activation-block u46601) ;; matches claim-end of IDO
(define-constant fwp-coinbase-1 (* u688000  ONE_8)) ;; emission of $ALEX per cycle in 1st year
(define-constant fwp-coinbase-2 (* u344000 ONE_8)) ;; emission of $ALEX per cycle in 2nd year
(define-constant fwp-coinbase-3 (* u172000 ONE_8)) ;; emission of $ALEX per cycle in 3rd year
(define-constant fwp-coinbase-4 (* u86000 ONE_8)) ;; emission of $ALEX per cycle in 4th year
(define-constant fwp-coinbase-5 (* u43000 ONE_8)) ;; emission of $ALEX per cycle in 5th year
(define-constant fwp-apower-multipler (/ (* u3 ONE_8) u10)) ;; APower multipler

(define-public (execute (sender principal))
	(begin
		(try! (contract-call? .fixed-weight-pool create-pool 
			.token-wstx 
			.token-wbtc
			fifty-percent 
			fifty-percent 
			.fwp-wstx-wbtc-50-50 
			.multisig-fwp-wstx-wbtc-50-50 
			dx
			dy
		))
		(try! (contract-call? .fixed-weight-pool set-fee-rebate .token-wstx .token-wbtc fifty-percent fifty-percent fee-rebate))
		(try! (contract-call? .fixed-weight-pool set-fee-rate-x .token-wstx .token-wbtc fifty-percent fifty-percent fee-rate-x))
		(try! (contract-call? .fixed-weight-pool set-fee-rate-y .token-wstx .token-wbtc fifty-percent fifty-percent fee-rate-y))
		(try! (contract-call? .fixed-weight-pool set-oracle-enabled .token-wstx .token-wbtc fifty-percent fifty-percent))
		(try! (contract-call? .fixed-weight-pool set-oracle-average .token-wstx .token-wbtc fifty-percent fifty-percent oracle-average))

		;; staking - fwp
    	(try! (contract-call? .alex-reserve-pool add-token .fwp-wstx-wbtc-50-50))
    	(try! (contract-call? .alex-reserve-pool set-coinbase-amount .fwp-wstx-wbtc-50-50 fwp-coinbase-1 fwp-coinbase-2 fwp-coinbase-3 fwp-coinbase-4 fwp-coinbase-5))
    	(try! (contract-call? .alex-reserve-pool set-apower-multiplier-in-fixed .fwp-wstx-wbtc-50-50 fwp-apower-multipler))
    	(contract-call? .alex-reserve-pool set-activation-block .fwp-wstx-wbtc-50-50 fwp-activation-block)		
	)
)
