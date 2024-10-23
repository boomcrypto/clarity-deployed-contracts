(impl-trait .dex-aggregator-trait.dex-aggregator-trait)
(use-trait ft-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)
(use-trait ft-trait-ext 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.trait-sip-010.sip-010-trait)


(define-constant ERR-INVALID-ROUTE (err u100))
(define-constant ERR-ALEX-ROUTES-NOT-SET (err u101))


(define-read-only (get-quote (amt-in uint) (route1 (optional (list 5 <ft-trait>))) (route2 (optional (list 5 <ft-trait-ext>))) (factors (optional (list 4 uint))))
  (let
    (
      (route (unwrap! route2 ERR-ALEX-ROUTES-NOT-SET))
      (n (len route))
      (unwrapped-factors (unwrap! factors ERR-INVALID-ROUTE))
      (m (len unwrapped-factors))
      (t1 (element-at? route u0))
      (t2 (element-at? route u1))
      (t3 (element-at? route u2))
      (t4 (element-at? route u3))
      (t5 (element-at? route u4))
      (f1 (default-to u0 (element-at? unwrapped-factors u0)))
      (f2 (default-to u0 (element-at? unwrapped-factors u1)))
      (f3 (default-to u0 (element-at? unwrapped-factors u2)))
      (f4 (default-to u0 (element-at? unwrapped-factors u3)))
    )

    ;; check that route is valid
    ;; (asserts! (> n u1) ERR-INVALID-ROUTE)

    (if (and (is-eq n u2) (is-eq m u1))
      (let (
        (t1a (unwrap-panic t1))
        (t2a (unwrap-panic t2))
        (t2-out (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-helper (contract-of t1a) (contract-of t2a) f1 amt-in)))
        )
        (ok {
          t2-out: t2-out,
          t3-out: u0,
          t4-out: u0,
          t5-out: u0,
        })
      )
      (if (and (is-eq n u3) (is-eq m u2))
        (let (
          (t1a (unwrap-panic t1))
          (t2a (unwrap-panic t2))
          (t3a (unwrap-panic t3))
          (t2-out (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-helper (contract-of t1a) (contract-of t2a) f1 amt-in)))
          (t3-out (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-helper (contract-of t2a) (contract-of t3a) f2 t2-out)))
          )
          (ok {
            t2-out: t2-out,
            t3-out: t3-out,
            t4-out: u0,
            t5-out: u0,
          })
        )
        (if (and (is-eq n u4) (is-eq m u3))
          (let (
            (t1a (unwrap-panic t1))
            (t2a (unwrap-panic t2))
            (t3a (unwrap-panic t3))
            (t4a (unwrap-panic t4))
            (t2-out (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-helper (contract-of t1a) (contract-of t2a) f1 amt-in)))
            (t3-out (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-helper (contract-of t2a) (contract-of t3a) f2 t2-out)))
            (t4-out (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-helper (contract-of t3a) (contract-of t4a) f3 t3-out)))
            )
            (ok {
              t2-out: t2-out,
              t3-out: t3-out,
              t4-out: t4-out,
              t5-out: u0,
            })
          )
          (let (
            (t1a (unwrap-panic t1))
            (t2a (unwrap-panic t2))
            (t3a (unwrap-panic t3))
            (t4a (unwrap-panic t4))
            (t5a (unwrap-panic t5))
            (t2-out (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-helper (contract-of t1a) (contract-of t2a) f1 amt-in)))
            (t3-out (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-helper (contract-of t2a) (contract-of t3a) f2 t2-out)))
            (t4-out (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-helper (contract-of t3a) (contract-of t4a) f3 t3-out)))
            (t5-out (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-helper (contract-of t4a) (contract-of t5a) f4 t4-out)))
            )
            (ok {
              t2-out: t2-out,
              t3-out: t3-out,
              t4-out: t4-out,
              t5-out: t5-out,
            })
          )
        )
      )
    )
  )
)



(define-public (swap (amt-in uint) (amt-out-min uint) (route1 (optional (list 5 <ft-trait>))) (route2 (optional (list 5 <ft-trait-ext>))) (factors (optional (list 4 uint))))
  (let
    (
      (route (unwrap! route2 ERR-ALEX-ROUTES-NOT-SET))
      (n (len route))
      (unwrapped-factors (unwrap! factors ERR-INVALID-ROUTE))
      (m (len unwrapped-factors))
      (t1 (element-at? route u0))
      (t2 (element-at? route u1))
      (t3 (element-at? route u2))
      (t4 (element-at? route u3))
      (t5 (element-at? route u4))
      (f1 (default-to u0 (element-at? unwrapped-factors u0)))
      (f2 (default-to u0 (element-at? unwrapped-factors u1)))
      (f3 (default-to u0 (element-at? unwrapped-factors u2)))
      (f4 (default-to u0 (element-at? unwrapped-factors u3)))
    )
    
    ;; ensure correct number of tokens in route
    (asserts! (> n u1) ERR-INVALID-ROUTE)

    (if (is-eq n u2)
      (let (
        (t1a (unwrap-panic t1))
        (t2a (unwrap-panic t2))
        (t2-out (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-helper t1a t2a f1 amt-in (some amt-out-min))))
        )
        (ok {
            t2-out: t2-out,
            t3-out: u0,
            t4-out: u0,
            t5-out: u0,
          })
      )
      (if (is-eq n u3)
        (let (
          (t1a (unwrap-panic t1))
          (t2a (unwrap-panic t2))
          (t3a (unwrap-panic t3))
          (t2-out (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-helper t1a t2a f1 amt-in none))) 
          (t3-out (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-helper t2a t3a f2 t2-out (some amt-out-min)))) 
          )
          (ok {
            t2-out: t2-out,
            t3-out: t3-out,
            t4-out: u0,
            t5-out: u0,
          })
        )
        (if (is-eq n u4)
          (let (
            (t1a (unwrap-panic t1))
            (t2a (unwrap-panic t2))
            (t3a (unwrap-panic t3))
            (t4a (unwrap-panic t4))
            (t2-out (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-helper t1a t2a f1 amt-in none))) 
            (t3-out (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-helper t2a t3a f2 t2-out none))) 
            (t4-out (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-helper t3a t4a f3 t3-out (some amt-out-min)))) 
            )
            (ok {
              t2-out: t2-out,
              t3-out: t3-out,
              t4-out: t4-out,
              t5-out: u0,
            })
          )
          (let (
            (t1a (unwrap-panic t1))
            (t2a (unwrap-panic t2))
            (t3a (unwrap-panic t3))
            (t4a (unwrap-panic t4))
            (t5a (unwrap-panic t5))
            (t2-out (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-helper t1a t2a f1 amt-in none))) 
            (t3-out (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-helper t2a t3a f2 t2-out none))) 
            (t4-out (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-helper t3a t4a f3 t3-out none))) 
            (t5-out (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-helper t4a t5a f4 t4-out (some amt-out-min)))) 
            )
            (ok {
              t2-out: t2-out,
              t3-out: t3-out,
              t4-out: t4-out,
              t5-out: t5-out,
            })
          )
        )
      )
    )
  )
)