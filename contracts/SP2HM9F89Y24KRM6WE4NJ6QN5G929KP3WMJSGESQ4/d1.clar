(define-constant owner tx-sender)
(define-constant D8 u100000000) 

(define-constant scale u291064)


(define-read-only (stx-alex-pool-details (x-in-y-out uint) (y-in-x-out uint))
  (let
    (
      (pool 
        (try! 
          (contract-call? 
          'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 
          get-pool-details 
          'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2 
          'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex D8)))

      (gety 
        (try! 
          (contract-call? 
          'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 
          get-y-given-x 
          'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2 
          'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex D8 x-in-y-out)))

      (getx 
        (try! 
          (contract-call? 
          'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 
          get-x-given-y 
          'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2 
          'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex D8 y-in-x-out)))
    )

     (ok (tuple (pool pool) (gety gety) (getx getx))) 
  )
)



(define-read-only (stx-nyc-pool-details (x-in-y-out uint) )
  (let
    (
      (pool 
        (try! 
          (contract-call? 
          'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 
          get-pool-details 
          'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2 
          'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wnyc D8)))

      (gety 
        (try! 
          (contract-call? 
          'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 
          get-y-given-x 
          'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2 
          'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wnyc D8 x-in-y-out)))

      (scaled-gety (/ (* gety scale) D8))
    )

     (ok (tuple (pool pool) (gety gety) (scaled-gety scaled-gety))) 
  )
)


(define-read-only (alex-pool-details-gety-getx (token-x principal) (token-y principal) (x-in-y-out uint) (y-in-x-out uint))
  (let
    (
      (pool (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-pool-details token-x token-y D8)))
      (gety (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-y-given-x token-x token-y D8 x-in-y-out)))
      (getx (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-x-given-y token-x token-y D8 y-in-x-out)))
    )

     (ok (tuple (pool pool) (gety gety) (getx getx)))
  )
)