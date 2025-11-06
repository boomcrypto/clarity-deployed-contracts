(define-public (route (t uint))
  (let
    (
      (stx_to_aeusdc
        (unwrap!
          (contract-call?
            'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-swap-helper-v-1-3
            swap-helper-a
            t
            u1
            none
            (tuple
              (a 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.token-stx-v-1-2)
              (b 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc)
            )
            (tuple
              (a 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-pool-stx-aeusdc-v-1-2)
            )
          )
          (err u1001)
        )
      )
      (aeusdc_to_sbtc
        (unwrap!
          (contract-call?
            'SPMGC5NE2SS13RACX328DZ90RZFTC2YHH068Y3FD.sbtc-aeusdc-v1
            swap-b-to-a
            stx_to_aeusdc
          )
          (err u1002)
        )
      )
      (dy (get dy aeusdc_to_sbtc))
      (min_recv (/ (* t u97) u100))
      (sbtc_to_stx
        (unwrap!
          (contract-call?
            'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-swap-helper-v-1-3
            swap-helper-a
            dy
            min_recv
            none
            (tuple
              (a 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token)
              (b 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.token-stx-v-1-2)
            )
            (tuple
              (a 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-pool-sbtc-stx-v-1-1)
            )
          )
          (err u1003)
        )
      )
    )
    (ok
      (tuple
        (stx_to_aeusdc stx_to_aeusdc)
        (aeusdc_to_sbtc aeusdc_to_sbtc)
        (sbtc_to_stx sbtc_to_stx)
      )
    )
  )
)
