
(impl-trait 'SPX9XMC02T56N9PRXV4AM9TS88MMQ6A1Z3375MHD.proposal-trait.proposal-trait)

(define-public (execute (sender principal))
  (begin
    (try! (contract-call? 'SPFP7J5S351CGCPBS2BX06HRF0WF3BYKQEZCGBW5.wooden-purple-turtle set-extensions
      (list
        { extension: 'SPFP7J5S351CGCPBS2BX06HRF0WF3BYKQEZCGBW5.informal-ivory-rook, enabled: true }
        { extension: 'SPFP7J5S351CGCPBS2BX06HRF0WF3BYKQEZCGBW5.diverse-salmon-antlion, enabled: true }
      )
    ))

    

    (try! (contract-call? 'SPFP7J5S351CGCPBS2BX06HRF0WF3BYKQEZCGBW5.diverse-salmon-antlion set-signals-required u1))
    
    

    (print { message: "...to be a completely separate network and separate block chain, yet share CPU power with Bitcoin.", sender: sender })
    (ok true)
  )
)
