
(impl-trait .stackswap-collateral-types-trait-v1a.collateral-types-trait)

(define-constant ERR-NOT-AUTHORIZED u17401)
(define-constant OWNER tx-sender)

(define-map collateral-types
  { name: (string-ascii 12) }
  {
    name: (string-ascii 256),
    token: (string-ascii 12),
    token-type: (string-ascii 12),
    token-address: principal,
    url: (string-ascii 256),
    total-debt: uint,
    liquidation-ratio: uint,
    collateral-to-debt-ratio: uint,
    maximum-debt: uint,
    stability-fee: uint,
    stability-fee-decimals: uint,
    stability-fee-apy: uint
  }
)

(define-read-only (get-collateral-type-by-name (name (string-ascii 12)))
  (ok
    (default-to
      {
        name: "",
        token: "",
        token-type: "",
        token-address: OWNER,
        url: "",
        total-debt: u1,
        liquidation-ratio: u0,
        collateral-to-debt-ratio: u0,
        maximum-debt: u0,
        stability-fee: u0,
        stability-fee-decimals: u0,
        stability-fee-apy: u0
      }
      (map-get? collateral-types { name: name })
    )
  )
)

(define-read-only (get-token-address (token (string-ascii 12)))
  (ok (get token-address (unwrap-panic (get-collateral-type-by-name token))))
)

(define-read-only (get-liquidation-ratio (token (string-ascii 12)))
  (ok (get liquidation-ratio (unwrap-panic (get-collateral-type-by-name token))))
)

(define-read-only (get-collateral-to-debt-ratio (token (string-ascii 12)))
  (ok (get collateral-to-debt-ratio (unwrap-panic (get-collateral-type-by-name token))))
)

(define-read-only (get-maximum-debt (token (string-ascii 12)))
  (ok (get maximum-debt (unwrap-panic (get-collateral-type-by-name token))))
)

(define-read-only (get-total-debt (token (string-ascii 12)))
  (ok (get total-debt (unwrap-panic (get-collateral-type-by-name token))))
)

(define-read-only (get-stability-fee (token (string-ascii 12)))
  (ok (get stability-fee (unwrap-panic (get-collateral-type-by-name token))))
)

(define-read-only (get-stability-fee-decimals (token (string-ascii 12)))
  (ok (get stability-fee-decimals (unwrap-panic (get-collateral-type-by-name token))))
)

(define-read-only (get-stability-fee-apy (token (string-ascii 12)))
  (ok (get stability-fee-apy (unwrap-panic (get-collateral-type-by-name token))))
)

(define-public (add-debt-to-collateral-type (token (string-ascii 12)) (debt uint))
  (begin
    (asserts! (is-eq contract-caller (unwrap-panic (contract-call? .stackswap-dao-v5k get-qualified-name-by-name "mortgager"))) (err ERR-NOT-AUTHORIZED))
    (let ((collateral-type (unwrap-panic (get-collateral-type-by-name token))))
      (map-set collateral-types
        { name: token }
        (merge collateral-type { total-debt: (+ debt (get total-debt collateral-type)) }))
      (ok debt)
    )
  )
)

(define-public (subtract-debt-from-collateral-type (token (string-ascii 12)) (debt uint))
  (begin
    (asserts! (is-eq contract-caller (unwrap-panic (contract-call? .stackswap-dao-v5k get-qualified-name-by-name "mortgager"))) (err ERR-NOT-AUTHORIZED))
    (let ((collateral-type (unwrap-panic (get-collateral-type-by-name token))))
      (if (> (get total-debt collateral-type) debt)
        (map-set collateral-types { name: token } (merge collateral-type { total-debt: (- (get total-debt collateral-type) debt) }))
        (map-set collateral-types { name: token } (merge collateral-type { total-debt: u0 }))
      )
      (ok debt)
    )
  )
)

(define-public (change-risk-parameters (collateral-type (string-ascii 12)) (changes (list 10 (tuple (key (string-ascii 256)) (new-value uint)))))
  (let (
    (type (unwrap-panic (get-collateral-type-by-name collateral-type)))
    (result (fold change-risk-parameter changes type))
  )
    (asserts! (is-eq contract-caller OWNER) (err ERR-NOT-AUTHORIZED))

    (map-set collateral-types { name: collateral-type } result)
    (ok true)
  )
)

(define-public (change-token-address (collateral-type (string-ascii 12)) (address principal))
  (let (
    (type (unwrap-panic (get-collateral-type-by-name collateral-type)))
  )
    (asserts! (is-eq contract-caller OWNER) (err ERR-NOT-AUTHORIZED))

    (map-set collateral-types { name: collateral-type } (merge type { token-address: address }))
    (ok true)
  )
)

(define-private (change-risk-parameter (change (tuple (key (string-ascii 256)) (new-value uint)))
                                       (type (tuple (collateral-to-debt-ratio uint) (liquidation-ratio uint)
                                              (maximum-debt uint) (name (string-ascii 256)) (stability-fee uint) (stability-fee-apy uint) (stability-fee-decimals uint)
                                              (token (string-ascii 12)) (token-address principal) (token-type (string-ascii 12)) (total-debt uint) (url (string-ascii 256)))
                                       )
                )
  (let ((key (get key change)))
    (if (is-eq key "liquidation-ratio")
      (merge type {
        liquidation-ratio: (get new-value change)
      })
      (if (is-eq key "collateral-to-debt-ratio")
        (merge type {
          collateral-to-debt-ratio: (get new-value change)
        })
        (if (is-eq key "maximum-debt")
          (merge type {
            maximum-debt: (get new-value change)
          })
          (if (is-eq key "stability-fee")
            (merge type {
              stability-fee: (get new-value change)
            })
            (if (is-eq key "stability-fee-apy")
              (merge type {
                stability-fee-apy: (get new-value change)
              })
              (if (is-eq key "stability-fee-decimals")
                (merge type {
                  stability-fee-decimals: (get new-value change)
                })
                type
              )
            )
          )
        )
      )
    )
  )
)

(begin
  (map-set collateral-types
    { name: "STX-A" }
    {
      name: "Stacks",
      token: "STX",
      token-type: "STX-A",
      token-address: OWNER,
      url: "https://www.stacks.co/",
      total-debt: u0,
      liquidation-ratio: u150, 
      collateral-to-debt-ratio: u150, ;; ~25% LTV
      maximum-debt: u1000000000000000, ;; 1B
      stability-fee: u9512937595, ;; 4% / 365 days / (24*6) blocks = 0.00007610350076 fee per block
      stability-fee-decimals: u16,
      stability-fee-apy: u500 ;; 400 basis points
    }
  )
  (map-set collateral-types
    { name: "STX-B" }
    {
      name: "Stacks",
      token: "STX",
      token-type: "STX-B",
      token-address: OWNER,
      url: "https://www.stacks.co/",
      total-debt: u0,
      liquidation-ratio: u130,
      collateral-to-debt-ratio: u130,
      maximum-debt: u500000000000000, 
      stability-fee: u1902587519, 
      stability-fee-decimals: u15,
      stability-fee-apy: u1000 
    }
  )
  (map-set collateral-types
    { name: "STSW-A" }
    {
      name: "STACKSWAP",
      token: "STSW",
      token-type: "STSW-A",
      token-address: 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a,
      url: "https://app.stackswap.org/",
      total-debt: u0,
      liquidation-ratio: u140,
      collateral-to-debt-ratio: u140, 
      maximum-debt: u500000000000000, 
      stability-fee: u3805175038,
      stability-fee-decimals: u16,
      stability-fee-apy: u200
    }
  )
  (map-set collateral-types
    { name: "STSW-B" }
    {
      name: "STACKSWAP",
      token: "STSW",
      token-type: "STSW-B",
      token-address: 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a,
      url: "https://app.stackswap.org/",
      total-debt: u0,
      liquidation-ratio: u120,
      collateral-to-debt-ratio: u120, 
      maximum-debt: u500000000000000,
      stability-fee: u7610350076, 
      stability-fee-decimals: u16,
      stability-fee-apy: u400 
    }
  )
)
