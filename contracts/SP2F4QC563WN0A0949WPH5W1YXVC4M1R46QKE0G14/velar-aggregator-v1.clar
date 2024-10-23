(impl-trait .dex-aggregator-trait.dex-aggregator-trait)
(use-trait ft-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)
(use-trait ft-trait-ext 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.trait-sip-010.sip-010-trait)

(define-constant ERR-INVALID-ROUTE (err u100))
(define-constant ERR-VELAR-ROUTES-NOT-SET (err u101))


(define-read-only (get-quote (amt-in uint) (route1 (optional (list 5 <ft-trait>))) (route2 (optional (list 5 <ft-trait-ext>))) (factors (optional (list 4 uint))))
  (let
    (
      (route (unwrap! route1 ERR-VELAR-ROUTES-NOT-SET))
      (n (len route))
      (t1 (element-at? route u0))
      (t2 (element-at? route u1))
      (t3 (element-at? route u2))
      (t4 (element-at? route u3))
      (t5 (element-at? route u4))
    )

    (if (is-eq n u2)
      (let (        
        (t1a (unwrap-panic t1))
        (t2a (unwrap-panic t2))
        (t2-out (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-path2 amount-out amt-in t1a t2a))
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
          (t-outs (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-path2 get-amount-out-3 amt-in t1a t2a t3a)))
          (ok {
            t2-out: (get b t-outs),
            t3-out: (get c t-outs),
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
            (t-outs (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-path2 get-amount-out-4 amt-in t1a t2a t3a t4a (list u0))))
            (ok {
              t2-out: (get b t-outs),
              t3-out: (get c t-outs),
              t4-out: (get d t-outs),
              t5-out: u0,
            })
          )
          (let (
            (t1a (unwrap-panic t1))
            (t2a (unwrap-panic t2)) 
            (t3a (unwrap-panic t3))
            (t4a (unwrap-panic t4))
            (t5a (unwrap-panic t1))
            (t-outs (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-path2 get-amount-out-5 amt-in t1a t2a t3a t4a t5a )))
            (ok {
              t2-out: (get b t-outs),
              t3-out: (get c t-outs),
              t4-out: (get d t-outs),
              t5-out: (get e t-outs),
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
      (route (unwrap! route1 ERR-VELAR-ROUTES-NOT-SET))
      (n (len route))
      (t1 (element-at? route u0))
      (t2 (element-at? route u1))
      (t3 (element-at? route u2))
      (t4 (element-at? route u3))
      (t5 (element-at? route u4))
    )
    
    ;; ensure correct number of tokens in route
    (asserts! (> n u1) ERR-INVALID-ROUTE)

    (if (is-eq n u2)
      (let (
        (t1a (unwrap-panic t1))
        (t2a (unwrap-panic t2)) 
        (t-outs (try! (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-path2 do-swap amt-in t1a t2a 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to))))
        (ok {
            t2-out: (get amt-out t-outs),
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
          (t-outs (try! (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-path2 swap-3 amt-in amt-out-min t1a t2a t3a 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to))))
          (ok {
            t2-out: (get amt-out (get b t-outs)),
            t3-out: (get amt-out (get c t-outs)),
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
            (t-outs (try! (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-path2 swap-4 amt-in amt-out-min t1a t2a t3a t4a  'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to))))
            (ok {
              t2-out: (get amt-out (get b t-outs)),
              t3-out: (get amt-out (get c t-outs)),
              t4-out: (get amt-out (get d t-outs)),
              t5-out: u0,
            })
          )
          (let (
            (t1a (unwrap-panic t1))
            (t2a (unwrap-panic t2)) 
            (t3a (unwrap-panic t3))
            (t4a (unwrap-panic t4))
            (t5a (unwrap-panic t5))
            (t-outs (try! (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-path2 swap-5 amt-in amt-out-min t1a t2a t3a t4a t5a 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to))))
            (ok {
              t2-out: (get amt-out (get b t-outs)),
              t3-out: (get amt-out (get c t-outs)),
              t4-out: (get amt-out (get d t-outs)),
              t5-out: (get amt-out (get e t-outs)),
            })
          )
        )
      )
    )
  )
)
