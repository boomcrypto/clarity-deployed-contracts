;; @contract Governance proposal
;; @version 1.1

(impl-trait .lydian-dao-proposal-trait.lydian-dao-proposal-trait)

;; ------------------------------------------
;; Constants
;; ------------------------------------------

(define-constant  ERR-NOT-AUTHORIZED u1001)

;; ------------------------------------------
;; Execute
;; ------------------------------------------

(define-public (execute)
  (begin
    (asserts! (is-eq contract-caller .lydian-dao) (err  ERR-NOT-AUTHORIZED))

    ;; Add USDA auction
    (unwrap-panic (contract-call? .auction-v1-1 add-auction
      
      'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token   ;; token to accept as payment
      u52390                                                  ;; auction start block
      u52966                                                  ;; auction end block
      u10000000000                                            ;; total number of tokens to sell in auction
      u400000000                                              ;; start price auction
      u40000000                                               ;; min price auction
    ))

    (ok true)
  )
)

