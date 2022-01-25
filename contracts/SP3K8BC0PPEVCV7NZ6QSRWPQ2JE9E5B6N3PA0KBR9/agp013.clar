(impl-trait .proposal-trait.proposal-trait)

(define-constant ONE_8 (pow u10 u8))

;; staking
(define-constant coinbase-1 (* u344000 ONE_8)) ;; emission of $ALEX per cycle in 1st year
(define-constant coinbase-2 (* u172000 ONE_8)) ;; emission of $ALEX per cycle in 2nd year
(define-constant coinbase-3 (* u86000 ONE_8)) ;; emission of $ALEX per cycle in 3rd year
(define-constant coinbase-4 (* u43000 ONE_8)) ;; emission of $ALEX per cycle in 4th year
(define-constant coinbase-5 (* u21500 ONE_8)) ;; emission of $ALEX per cycle in 5th year

;; xbtc pool
(define-constant fifty-percent (/ ONE_8 u2)) ;; equal-weight pool (i.e. Uniswap-like)
(define-constant dx (* u40000 ONE_8))
(define-constant max-dy (some u202272879))

(define-public (execute (sender principal))
	(begin
		;; $ALEX single staking
		(try! (contract-call? .alex-reserve-pool set-coinbase-amount .age000-governance-token coinbase-1 coinbase-2 coinbase-3 coinbase-4 coinbase-5))
		;; ALEX-STX Pool farming
    	(try! (contract-call? .alex-reserve-pool set-coinbase-amount .fwp-wstx-alex-50-50-v1-01 coinbase-1 coinbase-2 coinbase-3 coinbase-4 coinbase-5))
		;; BTC-STX Pool farming
		(try! (contract-call? .alex-reserve-pool set-coinbase-amount .fwp-wstx-wbtc-50-50-v1-01 coinbase-1 coinbase-2 coinbase-3 coinbase-4 coinbase-5))

		(try! (contract-call? .fixed-weight-pool-v1-01 add-to-position .token-wstx .token-wbtc fifty-percent fifty-percent .fwp-wstx-wbtc-50-50-v1-01 dx max-dy))

		(ok true)	
	)
)
