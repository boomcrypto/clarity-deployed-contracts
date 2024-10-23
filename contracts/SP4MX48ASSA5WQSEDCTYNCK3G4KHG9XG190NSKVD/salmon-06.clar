(define-data-var alex-stx principal 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2)
(define-data-var alex-xbtc principal 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wxbtc)
(define-data-var alex-abtc principal 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc)
(define-data-var alex-xusd principal 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wxusd)
(define-data-var alex-susdt principal 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-susdt)
(define-data-var alex-alex principal 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex)
(define-data-var alex-usda principal 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wusda) 




;; Arkadiko
(define-public (swap-wstx-usda-arkadiko (dx uint))
  (let 
  
  ((r (try! (contract-call? 
  'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y 
  'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token 
  'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token 
  dx u0))))

  (ok (unwrap-panic (element-at r u1))))
)