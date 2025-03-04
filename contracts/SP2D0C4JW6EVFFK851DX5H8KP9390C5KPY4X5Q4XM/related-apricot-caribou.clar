(define-public (swap-v0001 (in uint))
  (let ((sender tx-sender))
    (try! (stx-transfer? in sender (as-contract tx-sender)))
    (as-contract (let (
        (router_0 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
              u100000000 (* in u100) (some u0))))
        (router_1 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wdiko
              u100000000 (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex get-balance tx-sender)) (some u0))))
        (router_2 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-y-for-x 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wdiko
              u100000000 (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wdiko get-balance tx-sender)) (some u0))))
        (out (stx-get-balance tx-sender))
      )
      (asserts! (> out in) (err out))
      (try! (stx-transfer? out tx-sender sender))
      (ok (list out in))
))))
;;===============================================================================
(define-public (swap-v0002 (in uint))
  (let ((sender tx-sender))
    (try! (stx-transfer? in sender (as-contract tx-sender)))
    (as-contract (let (
        (router_0 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
              u100000000 (* in u100) (some u0))))
        (router_1 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wdiko
              u100000000 (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex get-balance tx-sender)) (some u0))))
        (router_2 (try! (contract-call?
            'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token
              (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token get-balance tx-sender)) u0)))
        (out (stx-get-balance tx-sender))
      )
      (asserts! (> out in) (err out))
      (try! (stx-transfer? out tx-sender sender))
      (ok (list out in))
))))
(define-public (swap-v0003 (in uint))
  (let ((sender tx-sender))
    (try! (stx-transfer? in sender (as-contract tx-sender)))
    (as-contract (let (
        (router_0 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
              u100000000 (* in u100) (some u0))))
        (router_1 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wdiko
              u100000000 (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex get-balance tx-sender)) (some u0))))
        (router_2 (try! (contract-call?
            'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y 
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
              (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token get-balance tx-sender)) u0)))
        (router_3 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-y-for-x 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wusda
              u100000000 (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wusda get-balance tx-sender)) (some u0))))
        (out (stx-get-balance tx-sender))
      )
      (asserts! (> out in) (err out))
      (try! (stx-transfer? out tx-sender sender))
      (ok (list out in))
))))
(define-public (swap-v0004 (in uint))
  (let ((sender tx-sender))
    (try! (stx-transfer? in sender (as-contract tx-sender)))
    (as-contract (let (
        (router_0 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
              u100000000 (* in u100) (some u0))))
        (router_1 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wdiko
              u100000000 (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex get-balance tx-sender)) (some u0))))
        (router_2 (try! (contract-call?
            'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y 
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
              (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token get-balance tx-sender)) u0)))
        (router_3 (try! (contract-call?
            'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
              (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token get-balance tx-sender)) u0)))
        (out (stx-get-balance tx-sender))
      )
      (asserts! (> out in) (err out))
      (try! (stx-transfer? out tx-sender sender))
      (ok (list out in))
))))
(define-public (swap-v0005 (in uint))
  (let ((sender tx-sender))
    (try! (stx-transfer? in sender (as-contract tx-sender)))
    (as-contract (let (
        (router_0 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
              u100000000 (* in u100) (some u0))))
        (router_1 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wdiko
              u100000000 (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex get-balance tx-sender)) (some u0))))
        (router_2 (try! (contract-call?
            'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y 
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
              (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token get-balance tx-sender)) u0)))
        (router_3 (try! (contract-call?
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x 
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5k0yl5ot8l
              (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token get-balance tx-sender)) u0)))
        (out (stx-get-balance tx-sender))
      )
      (asserts! (> out in) (err out))
      (try! (stx-transfer? out tx-sender sender))
      (ok (list out in))
))))
(define-public (swap-v0006 (in uint))
  (let ((sender tx-sender))
    (try! (stx-transfer? in sender (as-contract tx-sender)))
    (as-contract (let (
        (router_0 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
              u100000000 (* in u100) (some u0))))
        (router_1 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wdiko
              u100000000 (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex get-balance tx-sender)) (some u0))))
        (router_2 (try! (contract-call?
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x 
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kt9nmle8c
              (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token get-balance tx-sender)) u0)))
        (out (stx-get-balance tx-sender))
      )
      (asserts! (> out in) (err out))
      (try! (stx-transfer? out tx-sender sender))
      (ok (list out in))
))))
(define-public (swap-v0007 (in uint))
  (let ((sender tx-sender))
    (try! (stx-transfer? in sender (as-contract tx-sender)))
    (as-contract (let (
        (router_0 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
              u100000000 (* in u100) (some u0))))
        (router_1 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wdiko
              u100000000 (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex get-balance tx-sender)) (some u0))))
        (router_2 (try! (contract-call?
            'SP20X3DC5R091J8B6YPQT638J8NR1W83KN6TN5BJY.univ2-pool-v1_0_0-0056 swap
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token
              'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
              'SP20X3DC5R091J8B6YPQT638J8NR1W83KN6TN5BJY.univ2-fees-v1_0_0-0056
              (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token get-balance tx-sender)) u1)))
        (out (stx-get-balance tx-sender))
      )
      (asserts! (> out in) (err out))
      (try! (stx-transfer? out tx-sender sender))
      (ok (list out in))
))))
(define-public (swap-v0008 (in uint))
  (let ((sender tx-sender))
    (try! (stx-transfer? in sender (as-contract tx-sender)))
    (as-contract (let (
        (router_0 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
              u100000000 (* in u100) (some u0))))
        (router_1 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wusda
              u100000000 (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex get-balance tx-sender)) (some u0))))
        (router_2 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-y-for-x 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wusda
              u100000000 (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wusda get-balance tx-sender)) (some u0))))
        (out (stx-get-balance tx-sender))
      )
      (asserts! (> out in) (err out))
      (try! (stx-transfer? out tx-sender sender))
      (ok (list out in))
))))
(define-public (swap-v0009 (in uint))
  (let ((sender tx-sender))
    (try! (stx-transfer? in sender (as-contract tx-sender)))
    (as-contract (let (
        (router_0 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
              u100000000 (* in u100) (some u0))))
        (router_1 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wusda
              u100000000 (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex get-balance tx-sender)) (some u0))))
        (router_2 (try! (contract-call?
            'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
              (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token get-balance tx-sender)) u0)))
        (out (stx-get-balance tx-sender))
      )
      (asserts! (> out in) (err out))
      (try! (stx-transfer? out tx-sender sender))
      (ok (list out in))
))))
(define-public (swap-v0010 (in uint))
  (let ((sender tx-sender))
    (try! (stx-transfer? in sender (as-contract tx-sender)))
    (as-contract (let (
        (router_0 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
              u100000000 (* in u100) (some u0))))
        (router_1 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wusda
              u100000000 (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex get-balance tx-sender)) (some u0))))
        (router_2 (try! (contract-call?
            'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
              (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token get-balance tx-sender)) u0)))
        (router_3 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-y-for-x 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wdiko
              u100000000 (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wdiko get-balance tx-sender)) (some u0))))
        (out (stx-get-balance tx-sender))
      )
      (asserts! (> out in) (err out))
      (try! (stx-transfer? out tx-sender sender))
      (ok (list out in))
))))
(define-public (swap-v0011 (in uint))
  (let ((sender tx-sender))
    (try! (stx-transfer? in sender (as-contract tx-sender)))
    (as-contract (let (
        (router_0 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
              u100000000 (* in u100) (some u0))))
        (router_1 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wusda
              u100000000 (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex get-balance tx-sender)) (some u0))))
        (router_2 (try! (contract-call?
            'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
              (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token get-balance tx-sender)) u0)))
        (router_3 (try! (contract-call?
            'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token
              (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token get-balance tx-sender)) u0)))
        (out (stx-get-balance tx-sender))
      )
      (asserts! (> out in) (err out))
      (try! (stx-transfer? out tx-sender sender))
      (ok (list out in))
))))
(define-public (swap-v0012 (in uint))
  (let ((sender tx-sender))
    (try! (stx-transfer? in sender (as-contract tx-sender)))
    (as-contract (let (
        (router_0 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
              u100000000 (* in u100) (some u0))))
        (router_1 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wusda
              u100000000 (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex get-balance tx-sender)) (some u0))))
        (router_2 (try! (contract-call?
            'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
              (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token get-balance tx-sender)) u0)))
        (router_3 (try! (contract-call?
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x 
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kt9nmle8c
              (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token get-balance tx-sender)) u0)))
        (out (stx-get-balance tx-sender))
      )
      (asserts! (> out in) (err out))
      (try! (stx-transfer? out tx-sender sender))
      (ok (list out in))
))))
(define-public (swap-v0013 (in uint))
  (let ((sender tx-sender))
    (try! (stx-transfer? in sender (as-contract tx-sender)))
    (as-contract (let (
        (router_0 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
              u100000000 (* in u100) (some u0))))
        (router_1 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wusda
              u100000000 (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex get-balance tx-sender)) (some u0))))
        (router_2 (try! (contract-call?
            'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
              (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token get-balance tx-sender)) u0)))
        (router_3 (try! (contract-call?
            'SP20X3DC5R091J8B6YPQT638J8NR1W83KN6TN5BJY.univ2-pool-v1_0_0-0056 swap
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token
              'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
              'SP20X3DC5R091J8B6YPQT638J8NR1W83KN6TN5BJY.univ2-fees-v1_0_0-0056
              (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token get-balance tx-sender)) u1)))
        (out (stx-get-balance tx-sender))
      )
      (asserts! (> out in) (err out))
      (try! (stx-transfer? out tx-sender sender))
      (ok (list out in))
))))
(define-public (swap-v0014 (in uint))
  (let ((sender tx-sender))
    (try! (stx-transfer? in sender (as-contract tx-sender)))
    (as-contract (let (
        (router_0 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
              u100000000 (* in u100) (some u0))))
        (router_1 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wusda
              u100000000 (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex get-balance tx-sender)) (some u0))))
        (router_2 (try! (contract-call?
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x 
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5k0yl5ot8l
              (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token get-balance tx-sender)) u0)))
        (out (stx-get-balance tx-sender))
      )
      (asserts! (> out in) (err out))
      (try! (stx-transfer? out tx-sender sender))
      (ok (list out in))
))))
(define-public (swap-v0015 (in uint))
  (let ((sender tx-sender))
    (try! (stx-transfer? in sender (as-contract tx-sender)))
    (as-contract (let (
        (router_0 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
              u100000000 (* in u100) (some u0))))
        (router_1 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wusda
              u100000000 (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex get-balance tx-sender)) (some u0))))
        (router_2 (try! (contract-call?
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y 
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
              'SP32P7T7VSRKN8D1B9S6WYT8ZS4XAD6ZZJGBVSMRF.Boreden-Retriever-Token
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kko20x371
              (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token get-balance tx-sender)) u0)))
        (router_3 (try! (contract-call?
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x 
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
              'SP32P7T7VSRKN8D1B9S6WYT8ZS4XAD6ZZJGBVSMRF.Boreden-Retriever-Token
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kn32mkbag
              (unwrap-panic (contract-call? 'SP32P7T7VSRKN8D1B9S6WYT8ZS4XAD6ZZJGBVSMRF.Boreden-Retriever-Token get-balance tx-sender)) u0)))
        (out (stx-get-balance tx-sender))
      )
      (asserts! (> out in) (err out))
      (try! (stx-transfer? out tx-sender sender))
      (ok (list out in))
))))
(define-public (swap-v0016 (in uint))
  (let ((sender tx-sender))
    (try! (stx-transfer? in sender (as-contract tx-sender)))
    (as-contract (let (
        (router_0 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
              u100000000 (* in u100) (some u0))))
        (router_1 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wpepe
              u100000000 (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex get-balance tx-sender)) (some u0))))
        (router_2 (try! (contract-call?
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x 
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.tokensoft-token-v4k68639zxz
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kr3b59xpn
              (unwrap-panic (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.tokensoft-token-v4k68639zxz get-balance tx-sender)) u0)))
        (router_3 (try! (contract-call?
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x 
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-stx-stsw
              (unwrap-panic (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a get-balance tx-sender)) u0)))
        (out (stx-get-balance tx-sender))
      )
      (asserts! (> out in) (err out))
      (try! (stx-transfer? out tx-sender sender))
      (ok (list out in))
))))
(define-public (swap-v0017 (in uint))
  (let ((sender tx-sender))
    (try! (stx-transfer? in sender (as-contract tx-sender)))
    (as-contract (let (
        (router_0 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
              u100000000 (* in u100) (some u0))))
        (router_1 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wpepe
              u100000000 (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex get-balance tx-sender)) (some u0))))
        (router_2 (try! (contract-call?
            'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens u11
              'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.tokensoft-token-v4k68639zxz
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.tokensoft-token-v4k68639zxz
              'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
              'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to
              (unwrap-panic (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.tokensoft-token-v4k68639zxz get-balance tx-sender)) u1)))
        (out (stx-get-balance tx-sender))
      )
      (asserts! (> out in) (err out))
      (try! (stx-transfer? out tx-sender sender))
      (ok (list out in))
))))
(define-public (swap-v0018 (in uint))
  (let ((sender tx-sender))
    (try! (stx-transfer? in sender (as-contract tx-sender)))
    (as-contract (let (
        (router_0 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
              u100000000 (* in u100) (some u0))))
        (router_1 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wlong
              u100000000 (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex get-balance tx-sender)) (some u0))))
        (router_2 (try! (contract-call?
            'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens u14
              'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
              'SP265WBWD4NH7TVPYQTVD23X3607NNK4484DTXQZ3.longcoin
              'SP265WBWD4NH7TVPYQTVD23X3607NNK4484DTXQZ3.longcoin
              'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
              'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to
              (unwrap-panic (contract-call? 'SP265WBWD4NH7TVPYQTVD23X3607NNK4484DTXQZ3.longcoin get-balance tx-sender)) u1)))
        (out (stx-get-balance tx-sender))
      )
      (asserts! (> out in) (err out))
      (try! (stx-transfer? out tx-sender sender))
      (ok (list out in))
))))
(define-public (swap-v0019 (in uint))
  (let ((sender tx-sender))
    (try! (stx-transfer? in sender (as-contract tx-sender)))
    (as-contract (let (
        (router_0 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
              u100000000 (* in u100) (some u0))))
        (router_1 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wnot
              u100000000 (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex get-balance tx-sender)) (some u0))))
        (router_2 (try! (contract-call?
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y 
              'SP32AEEF6WW5Y0NMJ1S8SBSZDAY8R5J32NBZFPKKZ.nope
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kev7mmmd2
              (unwrap-panic (contract-call? 'SP32AEEF6WW5Y0NMJ1S8SBSZDAY8R5J32NBZFPKKZ.nope get-balance tx-sender)) u0)))
        (out (stx-get-balance tx-sender))
      )
      (asserts! (> out in) (err out))
      (try! (stx-transfer? out tx-sender sender))
      (ok (list out in))
))))
(define-public (swap-v0020 (in uint))
  (let ((sender tx-sender))
    (try! (stx-transfer? in sender (as-contract tx-sender)))
    (as-contract (let (
        (router_0 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
              u100000000 (* in u100) (some u0))))
        (router_1 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wnot
              u100000000 (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex get-balance tx-sender)) (some u0))))
        (router_2 (try! (contract-call?
            'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens u16
              'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
              'SP32AEEF6WW5Y0NMJ1S8SBSZDAY8R5J32NBZFPKKZ.nope
              'SP32AEEF6WW5Y0NMJ1S8SBSZDAY8R5J32NBZFPKKZ.nope
              'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
              'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to
              (unwrap-panic (contract-call? 'SP32AEEF6WW5Y0NMJ1S8SBSZDAY8R5J32NBZFPKKZ.nope get-balance tx-sender)) u1)))
        (out (stx-get-balance tx-sender))
      )
      (asserts! (> out in) (err out))
      (try! (stx-transfer? out tx-sender sender))
      (ok (list out in))
))))
(define-public (swap-v0021 (in uint))
  (let ((sender tx-sender))
    (try! (stx-transfer? in sender (as-contract tx-sender)))
    (as-contract (let (
        (router_0 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
              u100000000 (* in u100) (some u0))))
        (router_1 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wleo
              u100000000 (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex get-balance tx-sender)) (some u0))))
        (router_2 (try! (contract-call?
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x 
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
              'SP1AY6K3PQV5MRT6R4S671NWW2FRVPKM0BR162CT6.leo-token
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kj1jqlas1
              (unwrap-panic (contract-call? 'SP1AY6K3PQV5MRT6R4S671NWW2FRVPKM0BR162CT6.leo-token get-balance tx-sender)) u0)))
        (router_3 (try! (contract-call?
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x 
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-stx-stsw
              (unwrap-panic (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a get-balance tx-sender)) u0)))
        (out (stx-get-balance tx-sender))
      )
      (asserts! (> out in) (err out))
      (try! (stx-transfer? out tx-sender sender))
      (ok (list out in))
))))
(define-public (swap-v0022 (in uint))
  (let ((sender tx-sender))
    (try! (stx-transfer? in sender (as-contract tx-sender)))
    (as-contract (let (
        (router_0 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
              u100000000 (* in u100) (some u0))))
        (router_1 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wleo
              u100000000 (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex get-balance tx-sender)) (some u0))))
        (router_2 (try! (contract-call?
            'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens u28
              'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
              'SP1AY6K3PQV5MRT6R4S671NWW2FRVPKM0BR162CT6.leo-token
              'SP1AY6K3PQV5MRT6R4S671NWW2FRVPKM0BR162CT6.leo-token
              'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
              'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to
              (unwrap-panic (contract-call? 'SP1AY6K3PQV5MRT6R4S671NWW2FRVPKM0BR162CT6.leo-token get-balance tx-sender)) u1)))
        (out (stx-get-balance tx-sender))
      )
      (asserts! (> out in) (err out))
      (try! (stx-transfer? out tx-sender sender))
      (ok (list out in))
))))
(define-public (swap-v0023 (in uint))
  (let ((sender tx-sender))
    (try! (stx-transfer? in sender (as-contract tx-sender)))
    (as-contract (let (
        (router_0 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
              u100000000 (* in u100) (some u0))))
        (router_1 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
              'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.token-wsbtc
              u100000000 (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex get-balance tx-sender)) (some u0))))
        (router_2 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-y-for-x 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
              'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.token-wsbtc
              u100000000 (unwrap-panic (contract-call? 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.token-wsbtc get-balance tx-sender)) (some u0))))
        (out (stx-get-balance tx-sender))
      )
      (asserts! (> out in) (err out))
      (try! (stx-transfer? out tx-sender sender))
      (ok (list out in))
))))
(define-public (swap-v0024 (in uint))
  (let ((sender tx-sender))
    (try! (stx-transfer? in sender (as-contract tx-sender)))
    (as-contract (let (
        (router_0 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
              u100000000 (* in u100) (some u0))))
        (router_1 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
              'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.token-wsbtc
              u100000000 (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex get-balance tx-sender)) (some u0))))
        (router_2 (try! (contract-call?
            'SP20X3DC5R091J8B6YPQT638J8NR1W83KN6TN5BJY.univ2-pool-v1_0_0-0070 swap
              'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token
              'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
              'SP20X3DC5R091J8B6YPQT638J8NR1W83KN6TN5BJY.univ2-fees-v1_0_0-0070
              (unwrap-panic (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token get-balance tx-sender)) u1)))
        (out (stx-get-balance tx-sender))
      )
      (asserts! (> out in) (err out))
      (try! (stx-transfer? out tx-sender sender))
      (ok (list out in))
))))
(define-public (swap-v0025 (in uint))
  (let ((sender tx-sender))
    (try! (stx-transfer? in sender (as-contract tx-sender)))
    (as-contract (let (
        (router_0 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
              u100000000 (* in u100) (some u0))))
        (router_1 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
              'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.token-wsbtc
              u100000000 (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex get-balance tx-sender)) (some u0))))
        (router_2 (try! (contract-call?
            'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-core-v-1-2 swap-x-for-y 
              'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-pool-sbtc-stx-v-1-1
              'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token
              'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.token-stx-v-1-2
              (unwrap-panic (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token get-balance tx-sender)) u1)))
        (out (stx-get-balance tx-sender))
      )
      (asserts! (> out in) (err out))
      (try! (stx-transfer? out tx-sender sender))
      (ok (list out in))
))))
(define-public (swap-v0026 (in uint))
  (let ((sender tx-sender))
    (try! (stx-transfer? in sender (as-contract tx-sender)))
    (as-contract (let (
        (router_0 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
              u100000000 (* in u100) (some u0))))
        (router_1 (try! (contract-call?
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y 
              'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5k2658uqsb
              (unwrap-panic (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token get-balance tx-sender)) u0)))
        (router_2 (try! (contract-call?
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y 
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
              'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kbe3oqvac
              (unwrap-panic (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a get-balance tx-sender)) u0)))
        (router_3 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-y-for-x 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wcorgi
              u100000000 (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wcorgi get-balance tx-sender)) (some u0))))
        (out (stx-get-balance tx-sender))
      )
      (asserts! (> out in) (err out))
      (try! (stx-transfer? out tx-sender sender))
      (ok (list out in))
))))
(define-public (swap-v0027 (in uint))
  (let ((sender tx-sender))
    (try! (stx-transfer? in sender (as-contract tx-sender)))
    (as-contract (let (
        (router_0 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
              u100000000 (* in u100) (some u0))))
        (router_1 (try! (contract-call?
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y 
              'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5k2658uqsb
              (unwrap-panic (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token get-balance tx-sender)) u0)))
        (router_2 (try! (contract-call?
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y 
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
              'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kbe3oqvac
              (unwrap-panic (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a get-balance tx-sender)) u0)))
        (router_3 (try! (contract-call?
            'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
              'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token
              (unwrap-panic (contract-call? 'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token get-balance tx-sender)) u0)))
        (out (stx-get-balance tx-sender))
      )
      (asserts! (> out in) (err out))
      (try! (stx-transfer? out tx-sender sender))
      (ok (list out in))
))))
(define-public (swap-v0028 (in uint))
  (let ((sender tx-sender))
    (try! (stx-transfer? in sender (as-contract tx-sender)))
    (as-contract (let (
        (router_0 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
              u100000000 (* in u100) (some u0))))
        (router_1 (try! (contract-call?
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y 
              'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5k2658uqsb
              (unwrap-panic (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token get-balance tx-sender)) u0)))
        (router_2 (try! (contract-call?
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y 
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
              'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kbe3oqvac
              (unwrap-panic (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a get-balance tx-sender)) u0)))
        (router_3 (try! (contract-call?
            'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens u27
              'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
              'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token
              'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token
              'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
              'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to
              (unwrap-panic (contract-call? 'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token get-balance tx-sender)) u1)))
        (out (stx-get-balance tx-sender))
      )
      (asserts! (> out in) (err out))
      (try! (stx-transfer? out tx-sender sender))
      (ok (list out in))
))))
(define-public (swap-v0029 (in uint))
  (let ((sender tx-sender))
    (try! (stx-transfer? in sender (as-contract tx-sender)))
    (as-contract (let (
        (router_0 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
              u100000000 (* in u100) (some u0))))
        (router_1 (try! (contract-call?
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y 
              'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5k2658uqsb
              (unwrap-panic (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token get-balance tx-sender)) u0)))
        (router_2 (try! (contract-call?
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y 
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.tokensoft-token-v4k68639zxz
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kr3b59xpn
              (unwrap-panic (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a get-balance tx-sender)) u0)))
        (router_3 (try! (contract-call?
            'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens u11
              'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.tokensoft-token-v4k68639zxz
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.tokensoft-token-v4k68639zxz
              'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
              'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to
              (unwrap-panic (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.tokensoft-token-v4k68639zxz get-balance tx-sender)) u1)))
        (out (stx-get-balance tx-sender))
      )
      (asserts! (> out in) (err out))
      (try! (stx-transfer? out tx-sender sender))
      (ok (list out in))
))))
(define-public (swap-v0030 (in uint))
  (let ((sender tx-sender))
    (try! (stx-transfer? in sender (as-contract tx-sender)))
    (as-contract (let (
        (router_0 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
              u100000000 (* in u100) (some u0))))
        (router_1 (try! (contract-call?
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y 
              'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5k2658uqsb
              (unwrap-panic (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token get-balance tx-sender)) u0)))
        (router_2 (try! (contract-call?
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y 
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
              'SP32P7T7VSRKN8D1B9S6WYT8ZS4XAD6ZZJGBVSMRF.Boreden-Retriever-Token
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5ku0v6khj0
              (unwrap-panic (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a get-balance tx-sender)) u0)))
        (router_3 (try! (contract-call?
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x 
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
              'SP32P7T7VSRKN8D1B9S6WYT8ZS4XAD6ZZJGBVSMRF.Boreden-Retriever-Token
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kn32mkbag
              (unwrap-panic (contract-call? 'SP32P7T7VSRKN8D1B9S6WYT8ZS4XAD6ZZJGBVSMRF.Boreden-Retriever-Token get-balance tx-sender)) u0)))
        (out (stx-get-balance tx-sender))
      )
      (asserts! (> out in) (err out))
      (try! (stx-transfer? out tx-sender sender))
      (ok (list out in))
))))
(define-public (swap-v0031 (in uint))
  (let ((sender tx-sender))
    (try! (stx-transfer? in sender (as-contract tx-sender)))
    (as-contract (let (
        (router_0 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
              u100000000 (* in u100) (some u0))))
        (router_1 (try! (contract-call?
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y 
              'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5k2658uqsb
              (unwrap-panic (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token get-balance tx-sender)) u0)))
        (router_2 (try! (contract-call?
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y 
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
              'SP1AY6K3PQV5MRT6R4S671NWW2FRVPKM0BR162CT6.leo-token
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kj1jqlas1
              (unwrap-panic (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a get-balance tx-sender)) u0)))
        (router_3 (try! (contract-call?
            'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens u28
              'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
              'SP1AY6K3PQV5MRT6R4S671NWW2FRVPKM0BR162CT6.leo-token
              'SP1AY6K3PQV5MRT6R4S671NWW2FRVPKM0BR162CT6.leo-token
              'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
              'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to
              (unwrap-panic (contract-call? 'SP1AY6K3PQV5MRT6R4S671NWW2FRVPKM0BR162CT6.leo-token get-balance tx-sender)) u1)))
        (out (stx-get-balance tx-sender))
      )
      (asserts! (> out in) (err out))
      (try! (stx-transfer? out tx-sender sender))
      (ok (list out in))
))))
(define-public (swap-v0032 (in uint))
  (let ((sender tx-sender))
    (try! (stx-transfer? in sender (as-contract tx-sender)))
    (as-contract (let (
        (router_0 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
              u100000000 (* in u100) (some u0))))
        (router_1 (try! (contract-call?
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y 
              'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5k2658uqsb
              (unwrap-panic (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token get-balance tx-sender)) u0)))
        (router_2 (try! (contract-call?
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x 
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-stx-stsw
              (unwrap-panic (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a get-balance tx-sender)) u0)))
        (out (stx-get-balance tx-sender))
      )
      (asserts! (> out in) (err out))
      (try! (stx-transfer? out tx-sender sender))
      (ok (list out in))
))))
(define-public (swap-v0033 (in uint))
  (let ((sender tx-sender))
    (try! (stx-transfer? in sender (as-contract tx-sender)))
    (as-contract (let (
        (router_0 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wmia
              u100000000 (* in u100) (some u0))))
        (router_1 (try! (contract-call?
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x 
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
              'SP1H1733V5MZ3SZ9XRW9FKYGEZT0JDGEB8Y634C7R.miamicoin-token-v2
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kboyn2773
              (unwrap-panic (contract-call? 'SP1H1733V5MZ3SZ9XRW9FKYGEZT0JDGEB8Y634C7R.miamicoin-token-v2 get-balance tx-sender)) u0)))
        (out (stx-get-balance tx-sender))
      )
      (asserts! (> out in) (err out))
      (try! (stx-transfer? out tx-sender sender))
      (ok (list out in))
))))
(define-public (swap-v0034 (in uint))
  (let ((sender tx-sender))
    (try! (stx-transfer? in sender (as-contract tx-sender)))
    (as-contract (let (
        (router_0 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wcorgi
              u100000000 (* in u100) (some u0))))
        (router_1 (try! (contract-call?
            'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
              'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token
              (unwrap-panic (contract-call? 'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token get-balance tx-sender)) u0)))
        (out (stx-get-balance tx-sender))
      )
      (asserts! (> out in) (err out))
      (try! (stx-transfer? out tx-sender sender))
      (ok (list out in))
))))
(define-public (swap-v0035 (in uint))
  (let ((sender tx-sender))
    (try! (stx-transfer? in sender (as-contract tx-sender)))
    (as-contract (let (
        (router_0 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wcorgi
              u100000000 (* in u100) (some u0))))
        (router_1 (try! (contract-call?
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x 
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
              'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kbe3oqvac
              (unwrap-panic (contract-call? 'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token get-balance tx-sender)) u0)))
        (router_2 (try! (contract-call?
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x 
              'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5k2658uqsb
              (unwrap-panic (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a get-balance tx-sender)) u0)))
        (router_3 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-y-for-x 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
              u100000000 (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex get-balance tx-sender)) (some u0))))
        (out (stx-get-balance tx-sender))
      )
      (asserts! (> out in) (err out))
      (try! (stx-transfer? out tx-sender sender))
      (ok (list out in))
))))
(define-public (swap-v0036 (in uint))
  (let ((sender tx-sender))
    (try! (stx-transfer? in sender (as-contract tx-sender)))
    (as-contract (let (
        (router_0 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wcorgi
              u100000000 (* in u100) (some u0))))
        (router_1 (try! (contract-call?
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x 
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
              'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kbe3oqvac
              (unwrap-panic (contract-call? 'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token get-balance tx-sender)) u0)))
        (router_2 (try! (contract-call?
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y 
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.tokensoft-token-v4k68639zxz
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kr3b59xpn
              (unwrap-panic (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a get-balance tx-sender)) u0)))
        (router_3 (try! (contract-call?
            'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens u11
              'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.tokensoft-token-v4k68639zxz
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.tokensoft-token-v4k68639zxz
              'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
              'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to
              (unwrap-panic (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.tokensoft-token-v4k68639zxz get-balance tx-sender)) u1)))
        (out (stx-get-balance tx-sender))
      )
      (asserts! (> out in) (err out))
      (try! (stx-transfer? out tx-sender sender))
      (ok (list out in))
))))
(define-public (swap-v0037 (in uint))
  (let ((sender tx-sender))
    (try! (stx-transfer? in sender (as-contract tx-sender)))
    (as-contract (let (
        (router_0 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wcorgi
              u100000000 (* in u100) (some u0))))
        (router_1 (try! (contract-call?
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x 
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
              'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kbe3oqvac
              (unwrap-panic (contract-call? 'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token get-balance tx-sender)) u0)))
        (router_2 (try! (contract-call?
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y 
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
              'SP32P7T7VSRKN8D1B9S6WYT8ZS4XAD6ZZJGBVSMRF.Boreden-Retriever-Token
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5ku0v6khj0
              (unwrap-panic (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a get-balance tx-sender)) u0)))
        (router_3 (try! (contract-call?
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x 
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
              'SP32P7T7VSRKN8D1B9S6WYT8ZS4XAD6ZZJGBVSMRF.Boreden-Retriever-Token
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kn32mkbag
              (unwrap-panic (contract-call? 'SP32P7T7VSRKN8D1B9S6WYT8ZS4XAD6ZZJGBVSMRF.Boreden-Retriever-Token get-balance tx-sender)) u0)))
        (out (stx-get-balance tx-sender))
      )
      (asserts! (> out in) (err out))
      (try! (stx-transfer? out tx-sender sender))
      (ok (list out in))
))))
(define-public (swap-v0038 (in uint))
  (let ((sender tx-sender))
    (try! (stx-transfer? in sender (as-contract tx-sender)))
    (as-contract (let (
        (router_0 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wcorgi
              u100000000 (* in u100) (some u0))))
        (router_1 (try! (contract-call?
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x 
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
              'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kbe3oqvac
              (unwrap-panic (contract-call? 'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token get-balance tx-sender)) u0)))
        (router_2 (try! (contract-call?
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y 
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
              'SP1AY6K3PQV5MRT6R4S671NWW2FRVPKM0BR162CT6.leo-token
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kj1jqlas1
              (unwrap-panic (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a get-balance tx-sender)) u0)))
        (router_3 (try! (contract-call?
            'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens u28
              'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
              'SP1AY6K3PQV5MRT6R4S671NWW2FRVPKM0BR162CT6.leo-token
              'SP1AY6K3PQV5MRT6R4S671NWW2FRVPKM0BR162CT6.leo-token
              'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
              'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to
              (unwrap-panic (contract-call? 'SP1AY6K3PQV5MRT6R4S671NWW2FRVPKM0BR162CT6.leo-token get-balance tx-sender)) u1)))
        (out (stx-get-balance tx-sender))
      )
      (asserts! (> out in) (err out))
      (try! (stx-transfer? out tx-sender sender))
      (ok (list out in))
))))
(define-public (swap-v0039 (in uint))
  (let ((sender tx-sender))
    (try! (stx-transfer? in sender (as-contract tx-sender)))
    (as-contract (let (
        (router_0 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wcorgi
              u100000000 (* in u100) (some u0))))
        (router_1 (try! (contract-call?
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x 
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
              'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kbe3oqvac
              (unwrap-panic (contract-call? 'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token get-balance tx-sender)) u0)))
        (router_2 (try! (contract-call?
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x 
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-stx-stsw
              (unwrap-panic (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a get-balance tx-sender)) u0)))
        (out (stx-get-balance tx-sender))
      )
      (asserts! (> out in) (err out))
      (try! (stx-transfer? out tx-sender sender))
      (ok (list out in))
))))
(define-public (swap-v0040 (in uint))
  (let ((sender tx-sender))
    (try! (stx-transfer? in sender (as-contract tx-sender)))
    (as-contract (let (
        (router_0 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wcorgi
              u100000000 (* in u100) (some u0))))
        (router_1 (try! (contract-call?
            'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens u27
              'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
              'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token
              'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token
              'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
              'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to
              (unwrap-panic (contract-call? 'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token get-balance tx-sender)) u1)))
        (out (stx-get-balance tx-sender))
      )
      (asserts! (> out in) (err out))
      (try! (stx-transfer? out tx-sender sender))
      (ok (list out in))
))))
(define-public (swap-v0389 (in uint))
  (let ((sender tx-sender))
    (try! (stx-transfer? in sender (as-contract tx-sender)))
    (as-contract (let (
        (router_0 (try! (contract-call?
            'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-core-v-1-2 swap-y-for-x 
              'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-pool-sbtc-stx-v-1-1
              'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token
              'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.token-stx-v-1-2
              in u1)))
        (router_1 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-y-for-x 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
              'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.token-wsbtc
              u100000000 (unwrap-panic (contract-call? 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.token-wsbtc get-balance tx-sender)) (some u0))))
        (router_2 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wleo
              u100000000 (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex get-balance tx-sender)) (some u0))))
        (router_3 (try! (contract-call?
            'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens u28
              'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
              'SP1AY6K3PQV5MRT6R4S671NWW2FRVPKM0BR162CT6.leo-token
              'SP1AY6K3PQV5MRT6R4S671NWW2FRVPKM0BR162CT6.leo-token
              'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
              'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to
              (unwrap-panic (contract-call? 'SP1AY6K3PQV5MRT6R4S671NWW2FRVPKM0BR162CT6.leo-token get-balance tx-sender)) u1)))
        (out (stx-get-balance tx-sender))
      )
      (asserts! (> out in) (err out))
      (try! (stx-transfer? out tx-sender sender))
      (ok (list out in))
))))
(define-public (swap-v0390 (in uint))
  (let ((sender tx-sender))
    (try! (stx-transfer? in sender (as-contract tx-sender)))
    (as-contract (let (
        (router_0 (try! (contract-call?
            'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-core-v-1-2 swap-y-for-x 
              'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-pool-sbtc-stx-v-1-1
              'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token
              'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.token-stx-v-1-2
              in u1)))
        (router_1 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-y-for-x 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
              'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.token-wsbtc
              u100000000 (unwrap-panic (contract-call? 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.token-wsbtc get-balance tx-sender)) (some u0))))
        (router_2 (try! (contract-call?
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y 
              'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5k2658uqsb
              (unwrap-panic (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token get-balance tx-sender)) u0)))
        (router_3 (try! (contract-call?
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x 
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-stx-stsw
              (unwrap-panic (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a get-balance tx-sender)) u0)))
        (out (stx-get-balance tx-sender))
      )
      (asserts! (> out in) (err out))
      (try! (stx-transfer? out tx-sender sender))
      (ok (list out in))
))))
(define-public (swap-v0391 (in uint))
  (let ((sender tx-sender))
    (try! (stx-transfer? in sender (as-contract tx-sender)))
    (as-contract (let (
        (router_0 (try! (contract-call?
            'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-core-v-1-2 swap-y-for-x 
              'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-pool-sbtc-stx-v-1-1
              'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token
              'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.token-stx-v-1-2
              in u1)))
        (router_1 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-y-for-x 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
              'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.token-wsbtc
              u100000000 (unwrap-panic (contract-call? 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.token-wsbtc get-balance tx-sender)) (some u0))))
        (out (stx-get-balance tx-sender))
      )
      (asserts! (> out in) (err out))
      (try! (stx-transfer? out tx-sender sender))
      (ok (list out in))
))))
(define-public (swap-v0392 (in uint))
  (let ((sender tx-sender))
    (try! (stx-transfer? in sender (as-contract tx-sender)))
    (as-contract (let (
        (router_0 (try! (contract-call?
            'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-core-v-1-2 swap-y-for-x 
              'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-pool-sbtc-stx-v-1-1
              'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token
              'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.token-stx-v-1-2
              in u1)))
        (router_1 (try! (contract-call?
            'SP20X3DC5R091J8B6YPQT638J8NR1W83KN6TN5BJY.univ2-pool-v1_0_0-0070 swap
              'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token
              'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
              'SP20X3DC5R091J8B6YPQT638J8NR1W83KN6TN5BJY.univ2-fees-v1_0_0-0070
              (unwrap-panic (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token get-balance tx-sender)) u1)))
        (out (stx-get-balance tx-sender))
      )
      (asserts! (> out in) (err out))
      (try! (stx-transfer? out tx-sender sender))
      (ok (list out in))
))))