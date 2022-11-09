;; @contract Compound DIKO rewards to DIKO/USDA
;; @version 1.1

(impl-trait .lydian-dao-proposal-trait.lydian-dao-proposal-trait)

;; ------------------------------------------
;; Constants
;; ------------------------------------------

(define-constant  ERR-NOT-AUTHORIZED u1001)

;; ------------------------------------------
;; DAO execution
;; ------------------------------------------

(define-public (execute)
  (begin
    (asserts! (is-eq contract-caller .lydian-dao) (err  ERR-NOT-AUTHORIZED))
  
    ;; Get all USDA
    (try! (execute-get-usda))

    ;; Add DIKO/USDA liquidity
    (try! (execute-add-liquidity))

    ;; Stake LP
    (try! (execute-stake))

    ;; Return unused USDA
    (try! (execute-return-usda))

    (ok true)
  )
)

;; ------------------------------------------
;; Helpers
;; ------------------------------------------

(define-private (execute-get-usda)
  (let (
    (balance (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token get-balance .treasury-v1-1)))
  )
    (contract-call? .treasury-v1-1 transfer-tokens 
      'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token 
      balance
      .lydian-dao
      .value-calculator-v1-1
    )
  )
)

(define-private (execute-add-liquidity)
  (let (
    (balance-diko (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token get-balance .lydian-dao)))
    (balance-usda (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token get-balance .lydian-dao)))
  )
    (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 add-to-position 
      'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token
      'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
      'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-token-diko-usda
      balance-diko
      balance-usda
    )
  )
)

(define-private (execute-stake)
  (let (
    (balance (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-token-diko-usda get-balance .lydian-dao)))
  )
    (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-stake-registry-v1-1 stake 
      'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-stake-registry-v1-1
      'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-stake-pool-diko-usda-v1-1
      'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-token-diko-usda
      balance
    )
  )
)

(define-private (execute-return-usda)
  (let (
    (balance (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token get-balance .lydian-dao)))
  )
    (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token transfer balance .lydian-dao .lydian-treasury-v1-1 none)
  )
)
