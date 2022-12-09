
(impl-trait 'SPX9XMC02T56N9PRXV4AM9TS88MMQ6A1Z3375MHD.proposal-trait.proposal-trait)

(define-public (execute (sender principal))
  (begin
    (try! (contract-call? 'SPJ81C2WPQHFB6XTG518JKPABWM639R2X0B331XE.free-tan-beaver set-extensions
      (list
        { extension: 'SPJ81C2WPQHFB6XTG518JKPABWM639R2X0B331XE.unfair-apricot-gerbil, enabled: true }
        { extension: 'SPJ81C2WPQHFB6XTG518JKPABWM639R2X0B331XE.coming-yellow-hyena, enabled: true }
      )
    ))

    

    (try! (contract-call? 'SPJ81C2WPQHFB6XTG518JKPABWM639R2X0B331XE.coming-yellow-hyena set-signals-required u1))
    
    

    (print { message: "...to be a completely separate network and separate block chain, yet share CPU power with Bitcoin.", sender: sender })
    (ok true)
  )
)
