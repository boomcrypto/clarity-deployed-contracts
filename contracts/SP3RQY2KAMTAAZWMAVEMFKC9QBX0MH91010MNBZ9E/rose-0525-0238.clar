;; test www
(use-trait sip-trait .sip-010-trait-ft-standard.sip-010-trait)
(define-constant sender 'SP3RQY2KAMTAAZWMAVEMFKC9QBX0MH91010MNBZ9E)






;; Arkadiko
(define-public (swap-wstx-usda-arkadiko (dx uint))
  (let ((r (try! 
          (contract-call? 
          'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y 
          'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token 
          'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token 
          dx 
          u0))))
  (ok (unwrap-panic (element-at r u1))))
)


(define-read-only (get-pair-usda-aeusdc)
  (let
    (          
      (pool (contract-call? 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stableswap-usda-aeusdc-v-1-2 get-pair-data 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.usda-aeusdc-lp-token-v-1-2))
    )
    (ok pool)
  )
)