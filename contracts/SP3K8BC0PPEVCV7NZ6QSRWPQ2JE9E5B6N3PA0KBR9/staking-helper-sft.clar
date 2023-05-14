(use-trait sft-trait .trait-semi-fungible.semi-fungible-trait)
(define-private (get-staker-at-cycle-or-default-by-tx-sender (token principal) (token-id uint) (reward-cycle uint))
  (contract-call? .alex-reserve-pool-sft get-staker-at-cycle-or-default token token-id reward-cycle (default-to u0 (contract-call? .alex-reserve-pool-sft get-user-id token token-id tx-sender)))
)
(define-private (get-staking-reward-by-tx-sender (token principal) (token-id uint) (target-cycle uint))
  (contract-call? .alex-reserve-pool-sft get-staking-reward token token-id (default-to u0 (contract-call? .alex-reserve-pool-sft get-user-id token token-id tx-sender)) target-cycle)
)
(define-public (claim-staking-reward-by-tx-sender (token <sft-trait>) (token-id uint) (reward-cycle uint))
  (contract-call? .alex-reserve-pool-sft claim-staking-reward token token-id reward-cycle)
)
(define-read-only (get-staking-stats-coinbase (token principal) (token-id uint) (reward-cycle uint))
    { 
        staking-stats: (contract-call? .alex-reserve-pool-sft get-staking-stats-at-cycle-or-default token token-id reward-cycle), 
        coinbase-amount: (contract-call? .alex-reserve-pool-sft get-coinbase-amount-or-default token token-id reward-cycle)
    }
)
(define-read-only (get-staking-stats-coinbase-as-list (token principal) (token-id uint) (reward-cycles (list 32 uint)))
    (let
        (
            (token-list (list token token token token token token token token token token token token token token token token token token token token token token token token token token token token token token token token))
            (token-id-list (list token-id token-id token-id token-id token-id token-id token-id token-id token-id token-id token-id token-id token-id token-id token-id token-id token-id token-id token-id token-id token-id token-id token-id token-id token-id token-id token-id token-id token-id token-id token-id token-id))
        )
        (map get-staking-stats-coinbase token-list token-id-list reward-cycles)
    )    
)
(define-read-only (get-staked (token principal) (token-id uint) (reward-cycles (list 200 uint)))
  (map 
    get-staker-at-cycle-or-default-by-tx-sender 
    (list 
      token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
      token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
      token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
      token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
      token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token      
    )
    (list 
      token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id
      token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id
      token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id
      token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id
      token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id          
    )
    reward-cycles
  )
)
(define-read-only (get-staking-rewards (token principal) (token-id uint) (reward-cycles (list 200 uint)))
  (map 
    get-staking-reward-by-tx-sender     
    (list 
      token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
      token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
      token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
      token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
      token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token      
    )
    (list 
      token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id
      token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id
      token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id
      token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id
      token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id          
    )
    reward-cycles    
  )
)
(define-public (claim-staking-reward (token <sft-trait>) (token-id uint) (reward-cycles (list 200 uint)))
  (ok 
    (map 
      claim-staking-reward-by-tx-sender 
    (list 
      token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
      token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
      token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
      token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
      token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token      
    )
    (list 
      token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id
      token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id
      token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id
      token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id
      token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id          
    )
      reward-cycles      
    )
  )
)