
(impl-trait 'SPX9XMC02T56N9PRXV4AM9TS88MMQ6A1Z3375MHD.proposal-trait.proposal-trait)

(define-public (execute (sender principal))
  (begin
    (try! (contract-call? 'SP2X27ZA972JEPEKZPNBJ15EMBB7A9Q48E10181EC.wicked-amethyst-puma set-extensions
      (list
        { extension: 'SP2X27ZA972JEPEKZPNBJ15EMBB7A9Q48E10181EC.ok-silver-elephant, enabled: true }
        { extension: 'SP2X27ZA972JEPEKZPNBJ15EMBB7A9Q48E10181EC.wilful-lavender-moose, enabled: true }
      )
    ))

    

    (try! (contract-call? 'SP2X27ZA972JEPEKZPNBJ15EMBB7A9Q48E10181EC.wilful-lavender-moose set-signals-required u1))
    
    

    (print { message: "...to be a completely separate network and separate block chain, yet share CPU power with Bitcoin.", sender: sender })
    (ok true)
  )
)
