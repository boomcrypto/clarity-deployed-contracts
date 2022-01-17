(define-fungible-token nothing u42)

(define-public (buy-nothing)
   (if (> (ft-get-supply nothing) u42)
      (if (is-eq (unwrap-panic (stx-burn? u101010 tx-sender)) true)
         (ft-mint? nothing u1 tx-sender)
         (err u0))
   (err u0)))

(define-public (transfer (to principal) (amount uint)) 
   (ft-transfer? nothing amount tx-sender to))


(define-public (donate-to-dan) 
   (stx-transfer? u100000000 tx-sender 'SP1AWFMSB3AGMFZY9JBWR9GRWR6EHBTMVA9JW4M20))

(define-public (donate-to-brad) 
   (stx-transfer? u100000000 tx-sender 'SPT9JHCME25ZBZM9WCGP7ZN38YA82F77YM5HM08B))

(define-public (donate-to-haz) 
   (stx-transfer? u100000000 tx-sender 'SP2F2NYNDDJTAXFB62PJX351DCM4ZNEVRYJSC92CT))

