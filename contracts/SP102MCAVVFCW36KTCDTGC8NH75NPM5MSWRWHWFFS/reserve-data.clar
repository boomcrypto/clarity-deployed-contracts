(use-trait ft 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.ft-trait.ft-trait)


(define-public (get-reserves-state
  (assets (list 100 <ft>))
  )
  (begin
    (ok 
      {
        reserves:(map get-reserve-state-iter assets),
        stx-rewards-for-sbtc-supply-apy: (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.rewards-data
          get-reward-program-income-read
         'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token
         'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.wstx
         )
      }
    )
  )
)

(define-private (get-reserve-state-iter (reserve <ft>))
  {
    reserve-state: (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-reserve-data get-reserve-state-read (contract-of reserve)),
    reserve-amount: (unwrap-panic (contract-call? reserve get-balance 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-vault)),
    reserve-factor: (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-reserve-data get-reserve-factor-read (contract-of reserve)),
    liquidation-close-factor: (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-reserve-data get-liquidation-close-factor-percent-read (contract-of reserve)),
    liquidation-bonus-e-mode: (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-reserve-data-4 get-liquidation-bonus-e-mode-read (contract-of reserve)),
  }
)