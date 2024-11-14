(define-public (execute)
  (begin
    ;; send-many
    (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.experience send-many 
      (list 
        { to: 'SPGYCP878RYFVT03ZT8TWGPKNYTSQB1578VVXHGE, amount: u100000000, memo: none }
        { to: 'SP1F1JA8SSGGGFN0PDX55J25YRNRJQAWY56QR0F6J, amount: u5000000, memo: none }
      )
    )
  )
)