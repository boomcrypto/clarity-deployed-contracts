(impl-trait .s-trait.s-trait)
  
(use-trait token-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(define-constant err-tok u2000) 
  
(define-private (ex
  (y2x bool)
  (d uint)
  (x <token-trait>)
  (y <token-trait>)
) 
  (let
    (
      (v (if y2x
        (try! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x x y d u0))
        (try! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y x y d u0))
      ))
    )
    (ok (if y2x
      (unwrap-panic (element-at v u0))
      (unwrap-panic (element-at v u1))
    ))
  ) 
)   
    
(define-private (wstx-xbtc (y2x bool) (d uint))
  (ex y2x d
  'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
  'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin
))  
  
(define-private (wstx-diko (y2x bool) (d uint))
  (ex y2x d
  'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
  'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token
))  

(define-private (wstx-usda (y2x bool) (d uint))
  (ex y2x d
  'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
  'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
))

(define-private (xbtc-usda (y2x bool) (d uint))
  (ex y2x d
  'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin
  'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
))

(define-private (diko-usda (y2x bool) (d uint))
  (ex y2x d
  'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token
  'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
))

(define-public (z
  (a uint)
  (b uint)
  (x uint)
)
  (if (is-eq a u1) ;; stx
    (if (is-eq b u3) (wstx-xbtc false x)
    (if (is-eq b u5) (wstx-diko false x)
    (if (is-eq b u6) (wstx-usda false x)
    (err err-tok)
    )))
  (if (is-eq a u3) ;; xbtc
    (if (is-eq b u1) (wstx-xbtc true  x)
    (if (is-eq b u6) (xbtc-usda false x)
    (err err-tok)
    ))
  (if (is-eq a u5) ;; diko
    (if (is-eq b u1) (wstx-diko true  x)
    (if (is-eq b u6) (diko-usda false x)
    (err err-tok)
    ))
  (if (is-eq a u6) ;; usda
    (if (is-eq b u1) (wstx-usda true x)
    (if (is-eq b u3) (xbtc-usda true x)
    (if (is-eq b u5) (diko-usda true x)
    (err err-tok)
    )))
  (err err-tok)
  ))))
)