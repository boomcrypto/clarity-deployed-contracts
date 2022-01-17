
(use-trait ft-trait .trait-sip-010.sip-010-trait)

;; helper functions:

(define-private (get-staker-at-cycle-or-default-by-tx-sender (token principal) (reward-cycle uint))
  (contract-call? .alex-reserve-pool get-staker-at-cycle-or-default token reward-cycle (default-to u0 (contract-call? .alex-reserve-pool get-user-id token tx-sender)))
)

(define-private (get-staking-reward-by-tx-sender (token principal) (target-cycle uint))
  (contract-call? .alex-reserve-pool get-staking-reward token (default-to u0 (contract-call? .alex-reserve-pool get-user-id token tx-sender)) target-cycle)
)

(define-public (claim-staking-reward-by-tx-sender (token <ft-trait>) (reward-cycle uint))
  (contract-call? .alex-reserve-pool claim-staking-reward token reward-cycle)
)

(define-read-only (get-staking-stats-coinbase (token principal) (reward-cycle uint))
    { 
        staking-stats: (contract-call? .alex-reserve-pool get-staking-stats-at-cycle-or-default token reward-cycle), 
        coinbase-amount: (contract-call? .alex-reserve-pool get-coinbase-amount-or-default token reward-cycle)
    }
)

(define-read-only (get-staking-stats-coinbase-as-list (token principal) (reward-cycles (list 32 uint)))
    (let
        (
            (token-list (list token token token token token token token token token token token token token token token token token token token token token token token token token token token token token token token token))
        )
        (map get-staking-stats-coinbase token-list reward-cycles)
    )    
)

(define-read-only (get-staked (token principal) (reward-cycles (list 1000 uint)))
  (map 
    get-staker-at-cycle-or-default-by-tx-sender 
    (list 
      token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
      token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
      token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
      token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
      token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
      token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
      token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
      token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
      token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
      token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
      token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
      token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
      token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
      token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
      token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
      token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
      token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
      token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
      token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
      token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
      token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
      token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
      token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
      token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
      token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
      token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
      token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
      token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
      token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
      token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
      token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
      token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
      token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
      token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
      token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
      token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
      token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
      token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
      token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
      token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
      token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
      token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
      token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
      token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
      token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
      token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
      token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
      token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
      token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
      token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
    )
    reward-cycles
  )
)

(define-read-only (get-staking-rewards (token principal) (reward-cycles (list 1000 uint)))
  (map 
    get-staking-reward-by-tx-sender     
    (list 
      token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
      token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
      token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
      token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
      token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
      token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
      token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
      token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
      token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
      token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
      token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
      token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
      token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
      token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
      token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
      token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
      token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
      token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
      token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
      token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
      token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
      token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
      token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
      token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
      token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
      token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
      token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
      token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
      token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
      token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
      token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
      token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
      token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
      token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
      token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
      token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
      token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
      token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
      token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
      token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
      token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
      token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
      token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
      token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
      token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
      token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
      token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
      token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
      token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
      token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
    )  
    reward-cycles    
  )
)

(define-public (claim-staking-reward (token <ft-trait>) (reward-cycles (list 1000 uint)))
  (ok 
    (map 
      claim-staking-reward-by-tx-sender 
      (list 
        token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
        token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
        token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
        token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
        token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
        token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
        token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
        token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
        token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
        token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
        token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
        token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
        token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
        token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
        token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
        token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
        token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
        token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
        token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
        token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
        token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
        token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
        token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
        token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
        token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
        token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
        token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
        token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
        token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
        token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
        token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
        token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
        token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
        token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
        token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
        token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
        token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
        token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
        token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
        token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
        token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
        token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
        token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
        token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
        token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
        token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
        token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
        token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
        token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
        token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token	token
      ) 
      reward-cycles      
    )
  )
)