;; this trait is meant to be used in pair with the official sip-010 trait

(define-trait ata-ft-trait-v0 (
  (mint
    (uint)
    (response bool uint)
  )

  (burn
    (uint)
    (response bool uint)
  )
))
