---
title: "Trait exp-v3"
draft: true
---
```
(use-trait ft-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(define-public (sweep-xxy (token1-amount uint) (token1 <ft-trait>) (token2 <ft-trait>) (token3 <ft-trait>))
  (begin
    (let ((token1-org-amount (stx-get-balance contract-caller)))
      (print {token1-org-amount: token1-org-amount})
      (try! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v1-1 swap-x-for-y token1 token2 token1-amount u0))
      (let ((token2-amount (unwrap-panic (contract-call? token2 get-balance contract-caller))))
        (print {token2-amount: token2-amount})
        (try! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v1-1 swap-x-for-y token2 token3 token2-amount u0))
        (let ((token3-amount (unwrap-panic (contract-call? token3 get-balance contract-caller))))
          (print {token3-amount: token3-amount})
          (try! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v1-1 swap-y-for-x token1 token3 token3-amount u0))
          (let ((token1-new-amount (stx-get-balance contract-caller)))
            (print {token1-new-amount: token1-new-amount})
            (if (> token1-new-amount (+ u500000 token1-org-amount))
              (ok true)
              (err u1001)
            )
          )
        )
      )
    )
  )
)

(define-public (sweep-xyy (token1-amount uint) (token1 <ft-trait>) (token2 <ft-trait>) (token3 <ft-trait>))
  (begin
    (let ((token1-org-amount (stx-get-balance contract-caller)))
      (print {token1-org-amount: token1-org-amount})
      (try! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v1-1 swap-x-for-y token1 token3 token1-amount u0))
      (let ((token3-amount (unwrap-panic (contract-call? token3 get-balance contract-caller))))
        (print {token3-amount: token3-amount})
        (try! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v1-1 swap-y-for-x token2 token3 token3-amount u0))
        (let ((token2-amount (unwrap-panic (contract-call? token2 get-balance contract-caller))))
          (print {token2-amount: token2-amount})
          (try! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v1-1 swap-y-for-x token1 token2 token2-amount u0))
          (let ((token1-new-amount (stx-get-balance contract-caller)))
            (print {token1-new-amount: token1-new-amount})
            (if (> token1-new-amount (+ u500000 token1-org-amount))
              (ok true)
              (err u1001)
            )
          )
        )
      )
    )
  )
)
```