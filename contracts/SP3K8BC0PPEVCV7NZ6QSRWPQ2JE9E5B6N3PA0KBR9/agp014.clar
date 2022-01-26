(impl-trait .proposal-trait.proposal-trait)

(define-constant ONE_8 (pow u10 u8))

;; staking - alex
(define-constant alex-coinbase-1 (* u206400 ONE_8)) ;; emission of $ALEX per cycle in 1st year
(define-constant alex-coinbase-2 (* u103200 ONE_8)) ;; emission of $ALEX per cycle in 2nd year
(define-constant alex-coinbase-3 (* u51600 ONE_8)) ;; emission of $ALEX per cycle in 3rd year
(define-constant alex-coinbase-4 (* u25800 ONE_8)) ;; emission of $ALEX per cycle in 4th year
(define-constant alex-coinbase-5 (* u12900 ONE_8)) ;; emission of $ALEX per cycle in 5th year

;; staking - fwp-alex
(define-constant fwp-alex-coinbase-1 (* u567600 ONE_8)) ;; emission of $ALEX per cycle in 1st year
(define-constant fwp-alex-coinbase-2 (* u283800 ONE_8)) ;; emission of $ALEX per cycle in 2nd year
(define-constant fwp-alex-coinbase-3 (* u141900 ONE_8)) ;; emission of $ALEX per cycle in 3rd year
(define-constant fwp-alex-coinbase-4 (* u70950 ONE_8)) ;; emission of $ALEX per cycle in 4th year
(define-constant fwp-alex-coinbase-5 (* u35475 ONE_8)) ;; emission of $ALEX per cycle in 5th year

;; staking - fwp-wbtc
(define-constant fwp-wbtc-coinbase-1 (* u258000 ONE_8)) ;; emission of $ALEX per cycle in 1st year
(define-constant fwp-wbtc-coinbase-2 (* u129000 ONE_8)) ;; emission of $ALEX per cycle in 2nd year
(define-constant fwp-wbtc-coinbase-3 (* u64500 ONE_8)) ;; emission of $ALEX per cycle in 3rd year
(define-constant fwp-wbtc-coinbase-4 (* u32250 ONE_8)) ;; emission of $ALEX per cycle in 4th year
(define-constant fwp-wbtc-coinbase-5 (* u16125 ONE_8)) ;; emission of $ALEX per cycle in 5th year

;; xbtc pool
(define-constant fifty-percent (/ ONE_8 u2)) ;; equal-weight pool (i.e. Uniswap-like)
(define-constant dx (* u40000 ONE_8))
(define-constant max-dy (some u202272879))

(define-public (execute (sender principal))
	(begin
		;; $ALEX single staking
		(try! (contract-call? .alex-reserve-pool set-coinbase-amount .age000-governance-token alex-coinbase-1 alex-coinbase-2 alex-coinbase-3 alex-coinbase-4 alex-coinbase-5))
		;; ALEX-STX Pool farming
    	(try! (contract-call? .alex-reserve-pool set-coinbase-amount .fwp-wstx-alex-50-50-v1-01 fwp-alex-coinbase-1 fwp-alex-coinbase-2 fwp-alex-coinbase-3 fwp-alex-coinbase-4 fwp-alex-coinbase-5))
		;; BTC-STX Pool farming
		(try! (contract-call? .alex-reserve-pool set-coinbase-amount .fwp-wstx-wbtc-50-50-v1-01 fwp-wbtc-coinbase-1 fwp-wbtc-coinbase-2 fwp-wbtc-coinbase-3 fwp-wbtc-coinbase-4 fwp-wbtc-coinbase-5))

		(try! (contract-call? .fixed-weight-pool-v1-01 add-to-position .token-wstx .token-wbtc fifty-percent fifty-percent .fwp-wstx-wbtc-50-50-v1-01 dx max-dy))

		(ok true)	
	)
)
