(define-public (stake-tokens (amount-token uint) (lock-period uint))
    (begin 
        (try! (contract-call? .vault-welsh-pool mint-fixed amount-token tx-sender))
        (contract-call? .alex-reserve-pool stake-tokens .vault-welsh-pool amount-token lock-period)))
(define-public (claim-staking-reward-by-tx-sender (target-cycle uint))
    (let (
			(claimed (try! (contract-call? .dual-farming-pool-v1-03 claim-staking-reward-by-tx-sender .vault-welsh-pool .token-wcorgi target-cycle))))
		(and (> (get to-return claimed) u0) (try! (contract-call? .vault-welsh-pool burn-fixed (get to-return claimed) tx-sender)))
		(ok claimed)))
(define-public (claim-staking-reward (reward-cycles (list 200 uint)))
  (ok (map claim-staking-reward-by-tx-sender reward-cycles)))