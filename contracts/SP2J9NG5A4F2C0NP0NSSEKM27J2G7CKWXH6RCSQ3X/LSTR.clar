(define-public (doSwap (amount-to-send uint))

(contract-call? 
            'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.router-velar-alex-v-1-2 
            swap-helper-a
            amount-to-send  ;; Hardcoded value for current-balance
            u69000000              ;; Hardcoded value
            true            ;; Hardcoded boolean
            (tuple (a 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx) (b 'SP4M2C88EE8RQZPYTC4PZ88CE16YGP825EYF6KBQ.stacks-rock))  ;; Hardcoded tuple with constants
            'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to
            (tuple (a 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wlqstx-v3) (b 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2))  ;; Hardcoded tuple with constants
            (tuple (a u5000000))  ;; Hardcoded tuple for a-factors
          )

)