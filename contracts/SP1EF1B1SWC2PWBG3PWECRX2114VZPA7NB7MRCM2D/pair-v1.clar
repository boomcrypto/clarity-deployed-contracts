;; pair-stackswap-arkadiko

(use-trait ark-ft-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)
;; (use-trait ark-ft-trait .sip-010-trait-ft-standard.sip-010-trait)

(use-trait ss-ft-trait 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.sip-010-v1a.sip-010-trait)
(use-trait ss-liquidity-token-trait 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-trait-v4c.liquidity-token-trait)
;; (use-trait ss-ft-trait .sip-010-v1a.sip-010-trait)
;; (use-trait ss-liquidity-token-trait .liquidity-token-trait-v4c.liquidity-token-trait)


(define-public
  (swap-ss-ark-x
    (ss-token1 <ss-ft-trait>)
    (ss-token2 <ss-ft-trait>)
    (ss-liquidity-token <ss-liquidity-token-trait>)
    (ark-token1 <ark-ft-trait>)
    (ark-token2 <ark-ft-trait>)
    (token1-amount uint)
  )

  (let ((stx-org-amount (stx-get-balance contract-caller)))
    (print {stx-org-amount: stx-org-amount})

    (try! (contract-call?
      'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k
      ;; .stackswap-swap-v5k
      swap-x-for-y
      ss-token1
      ss-token2
      ss-liquidity-token
      token1-amount
      u0)
    )

    ;; get token2 balance
    (let ((token2-amount (unwrap-panic (contract-call? ss-token2 get-balance contract-caller))))
      ;; swap token2 back to token1 on arkadiko

      (try! (contract-call?
         'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1
         ;; .arkadiko-swap-v2-1
         swap-y-for-x
         ark-token1
         ark-token2
         token2-amount
         u0)
      )

      ;; check there was a profit
      (let ((stx-new-amount (stx-get-balance contract-caller)))
        (print {stx-new-amount: stx-new-amount})
        (if (> stx-new-amount (+ u500000 stx-org-amount))
          (ok true)
          (err u1001)
        )
      )
    )
  )
)

(define-public
  (swap-ark-ss-x
    (ss-token1 <ss-ft-trait>)
    (ss-token2 <ss-ft-trait>)
    (ss-liquidity-token <ss-liquidity-token-trait>)
    (ark-token1 <ark-ft-trait>)
    (ark-token2 <ark-ft-trait>)
    (token1-amount uint)
  )
  (let ((stx-org-amount (stx-get-balance contract-caller)))
    (print {stx-org-amount: stx-org-amount})

    (try! (contract-call?
      'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1
      ;; .arkadiko-swap-v2-1
      swap-x-for-y
      ark-token1
      ark-token2
      token1-amount
      u0)
    )

    ;; get token2 balance
    (let ((token2-amount (unwrap-panic (contract-call? ark-token2 get-balance contract-caller))))
      ;; swap token2 back to token1 on arkadiko

      (try! (contract-call?
        'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k
        ;; .stackswap-swap-v5k
        swap-y-for-x
        ss-token1
        ss-token2
        ss-liquidity-token
        token2-amount
        u0)
      )

      ;; check there was a profit
      (let ((stx-new-amount (stx-get-balance contract-caller)))
        (print {stx-new-amount: stx-new-amount})
        (if (> stx-new-amount (+ u500000 stx-org-amount))
          (ok true)
          (err u1001)
        )
      )
    )
  )
)

(define-public
  (swap-ss-ark-y
    (ss-token1 <ss-ft-trait>)
    (ss-token2 <ss-ft-trait>)
    (ss-liquidity-token <ss-liquidity-token-trait>)
    (ark-token1 <ark-ft-trait>)
    (ark-token2 <ark-ft-trait>)
    (token1-amount uint)
  )

  (let ((stx-org-amount (stx-get-balance contract-caller)))
    (print {stx-org-amount: stx-org-amount})

    (try! (contract-call?
      'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k
      ;; .stackswap-swap-v5k
      swap-y-for-x
      ss-token1
      ss-token2
      ss-liquidity-token
      token1-amount
      u0)
    )

    ;; get token2 balance
    (let ((token2-amount (unwrap-panic (contract-call? ss-token2 get-balance contract-caller))))
      ;; swap token2 back to token1 on arkadiko

      (try! (contract-call?
         'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1
         ;; .arkadiko-swap-v2-1
         swap-x-for-y
         ark-token1
         ark-token2
         token2-amount
         u0)
      )

      ;; check there was a profit
      (let ((stx-new-amount (stx-get-balance contract-caller)))
        (print {stx-new-amount: stx-new-amount})
        (if (> stx-new-amount (+ u500000 stx-org-amount))
          (ok true)
          (err u1001)
        )
      )
    )
  )
)

(define-public
  (swap-ark-ss-y
    (ss-token1 <ss-ft-trait>)
    (ss-token2 <ss-ft-trait>)
    (ss-liquidity-token <ss-liquidity-token-trait>)
    (ark-token1 <ark-ft-trait>)
    (ark-token2 <ark-ft-trait>)
    (token1-amount uint)
  )
  (let ((stx-org-amount (stx-get-balance contract-caller)))
    (print {stx-org-amount: stx-org-amount})

    (try! (contract-call?
      'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1
      ;; .arkadiko-swap-v2-1
      swap-y-for-x
      ark-token1
      ark-token2
      token1-amount
      u0)
    )

    ;; get token2 balance
    (let ((token2-amount (unwrap-panic (contract-call? ark-token2 get-balance contract-caller))))
      ;; swap token2 back to token1 on arkadiko

      (try! (contract-call?
        'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k
        ;; .stackswap-swap-v5k
        swap-x-for-y
        ss-token1
        ss-token2
        ss-liquidity-token
        token2-amount
        u0)
      )

      ;; check there was a profit
      (let ((stx-new-amount (stx-get-balance contract-caller)))
        (print {stx-new-amount: stx-new-amount})
        (if (> stx-new-amount (+ u500000 stx-org-amount))
          (ok true)
          (err u1001)
        )
      )
    )
  )
)

;; add y-x combos


