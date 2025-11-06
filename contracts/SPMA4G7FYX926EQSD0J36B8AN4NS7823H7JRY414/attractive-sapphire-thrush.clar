(define-read-only (display-info-blocks-hashes (wanted-btc-block uint) (stx-block-height uint)) 
  (let
    ( 
      (stx-tenure-btc-hash (get-tenure-info? burnchain-header-hash stx-block-height))
      (prev-stx-tenure-btc-hash (get-tenure-info? burnchain-header-hash (- stx-block-height u1)))
    )
    {
      stx-tenure-btc-hash: stx-tenure-btc-hash,
      prev-stx-tenure-btc-hash: prev-stx-tenure-btc-hash,
      btc-block-hash: (get-burn-block-info? header-hash wanted-btc-block)
    }
  )
)
