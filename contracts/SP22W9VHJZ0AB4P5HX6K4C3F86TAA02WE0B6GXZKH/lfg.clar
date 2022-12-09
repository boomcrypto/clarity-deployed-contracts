
(impl-trait 'SPX9XMC02T56N9PRXV4AM9TS88MMQ6A1Z3375MHD.proposal-trait.proposal-trait)

(define-public (execute (sender principal))
  (begin
    (try! (contract-call? 'SP22W9VHJZ0AB4P5HX6K4C3F86TAA02WE0B6GXZKH.only-gray-impala set-extensions
      (list
        { extension: 'SP22W9VHJZ0AB4P5HX6K4C3F86TAA02WE0B6GXZKH.multisig-vault-v2, enabled: true }
        { extension: 'SP22W9VHJZ0AB4P5HX6K4C3F86TAA02WE0B6GXZKH.multisig-v5, enabled: true }
      )
    ))

    
    
    

    (print { message: "...to be a completely separate network and separate block chain, yet share CPU power with Bitcoin.", sender: sender })
    (ok true)
  )
)
