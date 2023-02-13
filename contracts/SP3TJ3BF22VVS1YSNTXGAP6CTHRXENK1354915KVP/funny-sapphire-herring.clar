
(impl-trait 'SPX9XMC02T56N9PRXV4AM9TS88MMQ6A1Z3375MHD.proposal-trait.proposal-trait)

(define-public (execute (sender principal))
  (begin
    (try! (contract-call? 'SP3TJ3BF22VVS1YSNTXGAP6CTHRXENK1354915KVP.awful-olive-fowl set-extensions
      (list
        { extension: 'SP3TJ3BF22VVS1YSNTXGAP6CTHRXENK1354915KVP.puzzled-azure-blackbird, enabled: true }
        { extension: 'SP3TJ3BF22VVS1YSNTXGAP6CTHRXENK1354915KVP.willing-cyan-ptarmigan, enabled: true }
      )
    ))

    

    (try! (contract-call? 'SP3TJ3BF22VVS1YSNTXGAP6CTHRXENK1354915KVP.willing-cyan-ptarmigan set-signals-required u1))
    
    

    (print { message: "...to be a completely separate network and separate block chain, yet share CPU power with Bitcoin.", sender: sender })
    (ok true)
  )
)
