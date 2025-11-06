(define-public (call-get-pool-balance)
  (ok (contract-call? 'SP1KK89R86W73SJE6RQNQPRDM471008S9JY4FQA62.treasury-grant-v4-4 
                     get-pool-balance 
                     u140 
                     'SPGYCP878RYFVT03ZT8TWGPKNYTSQB1578VVXHGE))
)
(define-public (call-get-locked-balance)
  (ok (contract-call? 'SP1KK89R86W73SJE6RQNQPRDM471008S9JY4FQA62.treasury-grant-v4-4 
                     get-locked-balance 
                     u140 
                     'SPGYCP878RYFVT03ZT8TWGPKNYTSQB1578VVXHGE))
)