
(define-read-only (get-user-total-stx-stacked-at-block-height (address principal) (stx-block-height uint))
   (at-block
    (unwrap-panic (get-stacks-block-info? id-header-hash stx-block-height))
    (+
      (get locked (stx-account address))
      (contract-call? 'SPMA4G7FYX926EQSD0J36B8AN4NS7823H7JRY414.stupid-amber-hawk get-ststxbtc-balance-in-defis address)
      (unwrap!
        (contract-call?
          'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststxbtc-token-v2
          get-balance address
        )
        u0
      )
      (/ (*
        (+ 
          (contract-call? 'SPMA4G7FYX926EQSD0J36B8AN4NS7823H7JRY414.stupid-amber-hawk get-ststx-balance-in-defis address)
          (unwrap!
            (contract-call?
              'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token
              get-balance address
            )
            u0
          )
        )
        (unwrap-panic (contract-call?
          'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.block-info-nakamoto-ststx-ratio-v2
          get-ststx-ratio
        ))
      ) u1000000)
    )
  )
)
