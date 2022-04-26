(impl-trait .proposal-trait.proposal-trait)

(define-constant ONE_8 (pow u10 u8))

;; simple-equation
(define-constant max-in-ratio (/ (* ONE_8 u5) u100)) ;; 5%
(define-constant max-out-ratio (/ (* ONE_8 u5) u100)) ;; 5%

;; fwp-alex-autoalex
(define-constant oracle-average (/ (* ONE_8 u95) u100)) ;; resilient oracle follows (0.05 * now + 0.95 * resilient-oracle-before)
(define-constant fee-rebate (/ ONE_8 u2)) ;; 50% of tx fee goes to LPs
(define-constant fee-rate-x (/ (* ONE_8 u3) u1000)) ;; 0.3% charged on token-x when token-x is sold to buy token-y
(define-constant fee-rate-y (/ (* ONE_8 u3) u1000)) ;; 0.3% charged on token-y when token-y is sold to buy token-x
(define-constant start-block u57626)

(define-constant reward-cycles (list u17 u18 u19 u20))
(define-constant ERR-GET-BALANCE-FIXED-FAIL (err u6001))
(define-constant ERR-DX-DY-NOT-EQUAL (err u9002))

(define-private (claim-fwp-alex-staking-reward (reward-cycle uint))
  (contract-call? .alex-reserve-pool claim-staking-reward .fwp-wstx-alex-50-50-v1-01 reward-cycle)
)
(define-private (claim-fwp-wbtc-staking-reward (reward-cycle uint))
  (contract-call? .alex-reserve-pool claim-staking-reward .fwp-wstx-wbtc-50-50-v1-01 reward-cycle)
)
(define-private (claim-alex-staking-reward (reward-cycle uint))
  (contract-call? .alex-reserve-pool claim-staking-reward .age000-governance-token reward-cycle)
)

(define-public (execute (sender principal))
	(begin 
    	(map claim-alex-staking-reward reward-cycles)
		(map claim-fwp-alex-staking-reward reward-cycles)
		(map claim-fwp-wbtc-staking-reward reward-cycles)
		(let 
      		(
        		(claimed (unwrap! (contract-call? .age000-governance-token get-balance-fixed tx-sender) ERR-GET-BALANCE-FIXED-FAIL))
				(dx (/ claimed u2))
				(minted (try! (contract-call? .auto-alex add-to-position dx)))
				(dy (unwrap! (contract-call? .auto-alex get-balance-fixed tx-sender) ERR-GET-BALANCE-FIXED-FAIL))
      		)
			(asserts! (is-eq dx dy) ERR-DX-DY-NOT-EQUAL)
			
			(try! (contract-call? .simple-equation set-max-in-ratio max-in-ratio))
        	(try! (contract-call? .simple-equation set-max-out-ratio max-out-ratio))

			(try! (contract-call? .alex-vault add-approved-contract .simple-weight-pool-alex))
			(try! (contract-call? .alex-reserve-pool add-approved-contract .simple-weight-pool-alex))

			(try! (contract-call? .simple-weight-pool-alex create-pool 
				.age000-governance-token
				.auto-alex
				.fwp-alex-autoalex 
				.multisig-fwp-alex-autoalex
				dx 
				dy
			))
			(try! (contract-call? .simple-weight-pool-alex set-start-block .age000-governance-token .auto-alex start-block))		
			(try! (contract-call? .simple-weight-pool-alex set-fee-rebate .age000-governance-token .auto-alex fee-rebate))
			(try! (contract-call? .simple-weight-pool-alex set-fee-rate-x .age000-governance-token .auto-alex fee-rate-x))
			(try! (contract-call? .simple-weight-pool-alex set-fee-rate-y .age000-governance-token .auto-alex fee-rate-y))
			(try! (contract-call? .simple-weight-pool-alex set-oracle-enabled .age000-governance-token .auto-alex))
			(try! (contract-call? .simple-weight-pool-alex set-oracle-average .age000-governance-token .auto-alex oracle-average))

			(ok true)	
		)
	)
)
