(impl-trait .proposal-trait.proposal-trait)

(define-constant ONE_8 (pow u10 u8))

;; wstx-alex-50-50 pool
(define-constant fifty-percent (/ ONE_8 u2)) ;; equal-weight pool (i.e. Uniswap-like)
(define-constant dy (* u3150000 ONE_8)) ;; 3,150,000 $ALEX / 10x IDO to ensure liquidity
(define-constant dx (/ (* dy u16) u100)) ;; 3,150,000 $ALEX at 0.16 STX / 504,000 STX
(define-constant oracle-average (/ (* ONE_8 u95) u100)) ;; resilient oracle follows (0.05 * now + 0.95 * resilient-oracle-before)
(define-constant fee-rebate (/ ONE_8 u2)) ;; 50% of tx fee goes to LPs
(define-constant fee-rate-x (/ (* ONE_8 u3) u1000)) ;; 0.3% charged on token-x when token-x is sold to buy token-y
(define-constant fee-rate-y (/ (* ONE_8 u3) u1000)) ;; 0.3% charged on token-y when token-y is sold to buy token-x

;; flash-loan-fee
(define-constant flash-loan-fee-rate (/ (* ONE_8 u3) u1000)) ;; 0.3% charged on flash-loan

;; staking - default
(define-constant reward-cycle-length u525) ;; number of block-heights per cycle / ~ 3 days
(define-constant token-halving-cycle u100) ;; number of cycles before coinbase change / ~ 1 year

;; staking - alex
(define-constant alex-activation-block u46601) ;; matches claim-end of IDO
(define-constant alex-coinbase-1 (* u413000 ONE_8)) ;; emission of $ALEX per cycle in 1st year
(define-constant alex-coinbase-2 (* u206500 ONE_8)) ;; emission of $ALEX per cycle in 2nd year
(define-constant alex-coinbase-3 (* u103250 ONE_8)) ;; emission of $ALEX per cycle in 3rd year
(define-constant alex-coinbase-4 (* u51625 ONE_8)) ;; emission of $ALEX per cycle in 4th year
(define-constant alex-coinbase-5 (* u25813 ONE_8)) ;; emission of $ALEX per cycle in 5th year
(define-constant alex-apower-multipler ONE_8) ;; APower multipler

;; staking - fwp-wstx-alex-50-50
(define-constant fwp-activation-block u46601) ;; matches claim-end of IDO
(define-constant fwp-coinbase-1 (* u138000  ONE_8)) ;; emission of $ALEX per cycle in 1st year
(define-constant fwp-coinbase-2 (* u69000 ONE_8)) ;; emission of $ALEX per cycle in 2nd year
(define-constant fwp-coinbase-3 (* u34500 ONE_8)) ;; emission of $ALEX per cycle in 3rd year
(define-constant fwp-coinbase-4 (* u17250 ONE_8)) ;; emission of $ALEX per cycle in 4th year
(define-constant fwp-coinbase-5 (* u8625 ONE_8)) ;; emission of $ALEX per cycle in 5th year
(define-constant fwp-apower-multipler (/ (* u3 ONE_8) u10)) ;; APower multipler

(define-public (execute (sender principal))
	(begin
		;; wstx-alex-50-50
		(try! (contract-call? .age000-governance-token mint-fixed dy .executor-dao))
		(try! (contract-call? .fixed-weight-pool create-pool 
			.token-wstx 
			.age000-governance-token 
			fifty-percent 
			fifty-percent 
			.fwp-wstx-alex-50-50 
			.multisig-fwp-wstx-alex-50-50 
			dx
			dy
		))
		(try! (contract-call? .fixed-weight-pool set-fee-rebate .token-wstx .age000-governance-token fifty-percent fifty-percent fee-rebate))
		(try! (contract-call? .fixed-weight-pool set-fee-rate-x .token-wstx .age000-governance-token fifty-percent fifty-percent fee-rate-x))
		(try! (contract-call? .fixed-weight-pool set-fee-rate-y .token-wstx .age000-governance-token fifty-percent fifty-percent fee-rate-y))
		(try! (contract-call? .fixed-weight-pool set-oracle-enabled .token-wstx .age000-governance-token fifty-percent fifty-percent))
		(try! (contract-call? .fixed-weight-pool set-oracle-average .token-wstx .age000-governance-token fifty-percent fifty-percent oracle-average))

		;; flash-loan-fee
		(try! (contract-call? .alex-vault set-flash-loan-fee-rate flash-loan-fee-rate))

		;; staking - default
    	(try! (contract-call? .alex-reserve-pool set-reward-cycle-length reward-cycle-length))
    	(try! (contract-call? .alex-reserve-pool set-token-halving-cycle token-halving-cycle))

		;; staking - alex
    	(try! (contract-call? .alex-reserve-pool add-token .age000-governance-token))
    	(try! (contract-call? .alex-reserve-pool set-coinbase-amount .age000-governance-token alex-coinbase-1 alex-coinbase-2 alex-coinbase-3 alex-coinbase-4 alex-coinbase-5))
    	(try! (contract-call? .alex-reserve-pool set-apower-multiplier-in-fixed .age000-governance-token alex-apower-multipler))
    	(try! (contract-call? .alex-reserve-pool set-activation-block .age000-governance-token alex-activation-block))

		;; staking - fwp
    	(try! (contract-call? .alex-reserve-pool add-token .fwp-wstx-alex-50-50))
    	(try! (contract-call? .alex-reserve-pool set-coinbase-amount .fwp-wstx-alex-50-50 fwp-coinbase-1 fwp-coinbase-2 fwp-coinbase-3 fwp-coinbase-4 fwp-coinbase-5))
    	(try! (contract-call? .alex-reserve-pool set-apower-multiplier-in-fixed .fwp-wstx-alex-50-50 fwp-apower-multipler))
    	(contract-call? .alex-reserve-pool set-activation-block .fwp-wstx-alex-50-50 fwp-activation-block)
	)
)
