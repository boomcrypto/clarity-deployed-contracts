(define-trait ata-store-trait-v0 (
  (register-first-factory
    (principal)
    (response bool uint)
  )

  (get-player-wrapper
    (principal)
    (response (optional { factories: (list 16 uint), lma: uint }) uint)
  )

  (save-lma
    ()
    (response uint uint)
  )
))
