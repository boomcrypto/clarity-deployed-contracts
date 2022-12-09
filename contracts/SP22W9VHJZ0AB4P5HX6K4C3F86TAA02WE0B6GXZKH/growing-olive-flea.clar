
(impl-trait 'SPX9XMC02T56N9PRXV4AM9TS88MMQ6A1Z3375MHD.proposal-trait.proposal-trait)

(define-public (execute (sender principal))
  (begin
    (try! (contract-call? 'SP22W9VHJZ0AB4P5HX6K4C3F86TAA02WE0B6GXZKH.only-gray-impala set-extensions
      (list
        { extension: 'SP22W9VHJZ0AB4P5HX6K4C3F86TAA02WE0B6GXZKH.extraordinary-violet-stork, enabled: true }
        { extension: 'SP22W9VHJZ0AB4P5HX6K4C3F86TAA02WE0B6GXZKH.multisig-v5, enabled: true }
      )
    ))

    (try! (contract-call? 'SP22W9VHJZ0AB4P5HX6K4C3F86TAA02WE0B6GXZKH.multisig-v5 set-approver 'SP22W9VHJZ0AB4P5HX6K4C3F86TAA02WE0B6GXZKH true))  
    (try! (contract-call? 'SP22W9VHJZ0AB4P5HX6K4C3F86TAA02WE0B6GXZKH.multisig-v5 set-approver 'SP34YR9F2DPXG88K8HCHKTKPHRYT0BJM016QNY78C true))  
    (try! (contract-call? 'SP22W9VHJZ0AB4P5HX6K4C3F86TAA02WE0B6GXZKH.multisig-v5 set-approver 'SPYF9PC72BSWS0DGA33FR24GCG81MG1Z96463H68 true))

    (try! (contract-call? 'SP22W9VHJZ0AB4P5HX6K4C3F86TAA02WE0B6GXZKH.multisig-v5 set-signals-required u2))
    
    (try! (contract-call? 'SP22W9VHJZ0AB4P5HX6K4C3F86TAA02WE0B6GXZKH.extraordinary-violet-stork set-allowed 'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin true))  
    (try! (contract-call? 'SP22W9VHJZ0AB4P5HX6K4C3F86TAA02WE0B6GXZKH.extraordinary-violet-stork set-allowed 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.mega true))  
    (try! (contract-call? 'SP22W9VHJZ0AB4P5HX6K4C3F86TAA02WE0B6GXZKH.extraordinary-violet-stork set-allowed 'SP2TZK01NKDC89J6TA56SA47SDF7RTHYEQ79AAB9A.Wrapped-USD true))  
    (try! (contract-call? 'SP22W9VHJZ0AB4P5HX6K4C3F86TAA02WE0B6GXZKH.extraordinary-violet-stork set-allowed 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token true))  
    (try! (contract-call? 'SP22W9VHJZ0AB4P5HX6K4C3F86TAA02WE0B6GXZKH.extraordinary-violet-stork set-allowed 'SP1H1733V5MZ3SZ9XRW9FKYGEZT0JDGEB8Y634C7R.miamicoin-token-v2 true))  
    (try! (contract-call? 'SP22W9VHJZ0AB4P5HX6K4C3F86TAA02WE0B6GXZKH.extraordinary-violet-stork set-allowed 'SPSCWDV3RKV5ZRN1FQD84YE1NQFEDJ9R1F4DYQ11.newyorkcitycoin-token-v2 true))

    (print { message: "...to be a completely separate network and separate block chain, yet share CPU power with Bitcoin.", sender: sender })
    (ok true)
  )
)
