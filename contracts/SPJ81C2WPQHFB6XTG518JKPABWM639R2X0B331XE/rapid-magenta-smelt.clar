
(impl-trait 'SPX9XMC02T56N9PRXV4AM9TS88MMQ6A1Z3375MHD.proposal-trait.proposal-trait)

(define-public (execute (sender principal))
  (begin
    (try! (contract-call? 'SPJ81C2WPQHFB6XTG518JKPABWM639R2X0B331XE.free-tan-beaver set-extensions
      (list
        { extension: 'SPJ81C2WPQHFB6XTG518JKPABWM639R2X0B331XE.short-tan-ocelot, enabled: true }
        { extension: 'SPJ81C2WPQHFB6XTG518JKPABWM639R2X0B331XE.royal-chocolate-gorilla, enabled: true }
      )
    ))

    (try! (contract-call? 'SPJ81C2WPQHFB6XTG518JKPABWM639R2X0B331XE.royal-chocolate-gorilla set-approver 'SPJ81C2WPQHFB6XTG518JKPABWM639R2X0B331XE true))  
    (try! (contract-call? 'SPJ81C2WPQHFB6XTG518JKPABWM639R2X0B331XE.royal-chocolate-gorilla set-approver 'SP143YHR805B8S834BWJTMZVFR1WP5FFC03WZE4BF true))

    (try! (contract-call? 'SPJ81C2WPQHFB6XTG518JKPABWM639R2X0B331XE.royal-chocolate-gorilla set-signals-required u1))
    
    (try! (contract-call? 'SPJ81C2WPQHFB6XTG518JKPABWM639R2X0B331XE.short-tan-ocelot set-allowed 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.megapont-space-agency true))

    (print { message: "...to be a completely separate network and separate block chain, yet share CPU power with Bitcoin.", sender: sender })
    (ok true)
  )
)
