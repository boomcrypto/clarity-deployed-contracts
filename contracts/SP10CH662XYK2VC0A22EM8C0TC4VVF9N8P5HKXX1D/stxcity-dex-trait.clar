;; title: stxcity-dex-trait by stx.city
(use-trait sip-010-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait) 

(define-trait stxcity-dex-trait
  (
    (buy (<sip-010-trait> uint) (response uint uint) )

    (sell (<sip-010-trait> uint) (response uint uint) )
  )
)