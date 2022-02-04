(define-trait reserve-nft-trait
  (

    (get-reserve-token () (response principal uint))

    (get-reserve-amount-total () (response uint uint))

    (get-reserve-amount (uint) (response uint uint))

    (regress-token (uint) (response uint uint))

  )
)