(use-trait ft-trait .ft-trait.ft-trait)

(define-trait mint-with-trait 
  (
    ;; mints X NFTs using supplied FT as tender
    (mint-many-with (uint <ft-trait>) (response bool uint))

    ;; returns minting price in supplied FT
    (get-mint-price-in (<ft-trait>) (response uint uint))
  )
)