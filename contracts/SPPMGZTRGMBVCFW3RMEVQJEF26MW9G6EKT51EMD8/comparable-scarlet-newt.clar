
(impl-trait 'SPX9XMC02T56N9PRXV4AM9TS88MMQ6A1Z3375MHD.proposal-trait.proposal-trait)

(define-public (execute (sender principal))
  (begin
    (try! (contract-call? 'SPPMGZTRGMBVCFW3RMEVQJEF26MW9G6EKT51EMD8.underground-red-nightingale set-extensions
      (list
        { extension: 'SPPMGZTRGMBVCFW3RMEVQJEF26MW9G6EKT51EMD8.petite-purple-grouse, enabled: true }
        { extension: 'SPPMGZTRGMBVCFW3RMEVQJEF26MW9G6EKT51EMD8.diverse-purple-buzzard, enabled: true }
      )
    ))

    (try! (contract-call? 'SPPMGZTRGMBVCFW3RMEVQJEF26MW9G6EKT51EMD8.diverse-purple-buzzard set-approver 'SPDYN7ZFZA28PVXAD688T50J1P3QJT2HYEC0BZJM true))  
    (try! (contract-call? 'SPPMGZTRGMBVCFW3RMEVQJEF26MW9G6EKT51EMD8.diverse-purple-buzzard set-approver 'SPDFFG562C4A3Y35RHATSMX7YGDKM1XTZBB3BZ2E true))  
    (try! (contract-call? 'SPPMGZTRGMBVCFW3RMEVQJEF26MW9G6EKT51EMD8.diverse-purple-buzzard set-approver 'SP3WKZWBE7F7GR91GPFDNTT65A2J8WA8KZC9MFKQJ true))  
    (try! (contract-call? 'SPPMGZTRGMBVCFW3RMEVQJEF26MW9G6EKT51EMD8.diverse-purple-buzzard set-approver 'SPPMGZTRGMBVCFW3RMEVQJEF26MW9G6EKT51EMD8 true))

    (try! (contract-call? 'SPPMGZTRGMBVCFW3RMEVQJEF26MW9G6EKT51EMD8.diverse-purple-buzzard set-signals-required u2))
    
    

    (print { message: "...to be a completely separate network and separate block chain, yet share CPU power with Bitcoin.", sender: sender })
    (ok true)
  )
)
