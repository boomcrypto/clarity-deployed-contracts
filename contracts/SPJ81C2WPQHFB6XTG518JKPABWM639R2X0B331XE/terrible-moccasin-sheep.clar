
(impl-trait 'SPX9XMC02T56N9PRXV4AM9TS88MMQ6A1Z3375MHD.proposal-trait.proposal-trait)

(define-public (execute (sender principal))
  (begin
    (try! (contract-call? 'SPJ81C2WPQHFB6XTG518JKPABWM639R2X0B331XE.major-orange-snake set-extensions
      (list
        { extension: 'SPJ81C2WPQHFB6XTG518JKPABWM639R2X0B331XE.glamorous-blush-dinosaur, enabled: true }
        { extension: 'SPJ81C2WPQHFB6XTG518JKPABWM639R2X0B331XE.slimy-copper-walrus, enabled: true }
      )
    ))

    

    (try! (contract-call? 'SPJ81C2WPQHFB6XTG518JKPABWM639R2X0B331XE.slimy-copper-walrus set-signals-required u2))
    
    

    (print { message: "...to be a completely separate network and separate block chain, yet share CPU power with Bitcoin.", sender: sender })
    (ok true)
  )
)
