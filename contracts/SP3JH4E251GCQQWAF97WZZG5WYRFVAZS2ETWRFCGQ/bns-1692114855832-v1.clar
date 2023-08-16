
  ;; version: 1
  ;; name: 39
  ;; namespace: stx

  (use-trait commission-trait 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.commission-trait.commission)
  
  (define-constant DEPLOYER_CONTRACT_PRINCIPAL (as-contract tx-sender))
  (define-constant COMM-ADDR 'SP7NDX6YRAH6C99WCZJWKF2SYR1GQRF7X6894QSJ)
  
  (define-constant ERR-ALREADY-LISTED (err u401))
  (define-constant ERR-WRONG-COMMISSION (err u402))
  (define-constant ERR-NOT-AUTHORIZED (err u403))
  (define-constant ERR-NOT-FOUND (err u404))
  (define-constant ERR-WRONG-PRICE (err u405))
  (define-constant ERR-TRANSFER-FAILED (err u500))
  
  (define-data-var current-namespace (buff 20) 0x00)
  (define-data-var current-name (buff 48) 0x00)
  
  (define-map listings { namespace: (buff 20), name: (buff 48) } { price: uint, lister: principal, commission: principal })
  
  (define-read-only (is-admin)
    (is-eq tx-sender COMM-ADDR)
  )
  
  (define-read-only (get-listing)
    (map-get? listings { namespace: (var-get current-namespace), name: (var-get current-name) })
  )
  
  (define-read-only (get-current-name)
    { namespace: (var-get current-namespace), name: (var-get current-name) }
  )
  
  (define-private (list-name (namespace (buff 20)) (name (buff 48)) (price uint) (commission <commission-trait>))
      (begin
          (asserts! (is-none (get-listing)) ERR-ALREADY-LISTED)
          (try! (to-bool-response (contract-call?
              'SP000000000000000000002Q6VF78.bns
              name-transfer 
              namespace
              name
              DEPLOYER_CONTRACT_PRINCIPAL
              none
          )))
          (var-set current-namespace namespace)
          (var-set current-name name)
          (ok (map-set listings {name: name, namespace: namespace} 
                                {price: price, lister: tx-sender, commission: (contract-of commission)}))
      )
  )
  
  (define-public (change-price (namespace (buff 20)) (name (buff 48)) (new-price uint) (commission <commission-trait>))
    (let (
        (listing (unwrap! (map-get? listings {namespace: namespace, name: name}) ERR-NOT-FOUND))
        (price (get price listing))
        (lister (get lister listing)))
      (asserts! (is-eq tx-sender lister) ERR-NOT-AUTHORIZED)
      (ok (map-set listings { namespace: namespace, name: name } { price: new-price, lister: lister, commission: (contract-of commission) }))
    )
  )
  
  (define-public (unlist-name (namespace (buff 20)) (name (buff 48)))
    (let (
        (listing (unwrap! (map-get? listings {namespace: namespace, name: name}) ERR-NOT-FOUND))
        (price (get price listing))
        (lister (get lister listing)))
      (asserts! (or (is-eq tx-sender lister) (is-admin)) ERR-NOT-AUTHORIZED)
      (map-delete listings {namespace: namespace, name: name})
      (as-contract
          (to-bool-response (contract-call?
              'SP000000000000000000002Q6VF78.bns 
              name-transfer 
              namespace
              name
              lister
              none 
          ))
      )
    )
  )
  
  (define-public (purchase-name (namespace (buff 20)) (name (buff 48)) (expected-price uint) (commission <commission-trait>) (recipient (optional principal)))
      (let (
        (new-owner (if (is-some recipient) (unwrap-panic recipient) tx-sender))
        (listing (unwrap! (map-get? listings {namespace: namespace, name: name}) ERR-NOT-FOUND))
        (price (get price listing))
        (lister (get lister listing))
        (list-commission (get commission listing))
      )
        (asserts! (is-eq (contract-of commission) list-commission) ERR-WRONG-COMMISSION)
        (asserts! (is-eq price expected-price) ERR-WRONG-PRICE)
        (try! (contract-call? commission pay u0 price))
        (try! (stx-transfer? price tx-sender lister))
        (map-delete listings {namespace: namespace, name: name})
        (to-bool-response (as-contract
            (contract-call?
                'SP000000000000000000002Q6VF78.bns 
                name-transfer 
                namespace
                name
                new-owner
                none 
            )
        ))
      )
  )
  
  (define-public (withdraw-stx (amount uint))
      (let (
        (listing (unwrap! (get-listing) ERR-NOT-FOUND))
        (lister (get lister listing))
      )  
        (asserts! (or (is-eq tx-sender lister) (is-admin)) ERR-NOT-AUTHORIZED)
        (try! (as-contract (stx-transfer? amount tx-sender lister)))
        (ok amount)
      )
  )

  (define-private (to-bool-response (value (response bool int)))
      (match value
             success (ok success)
             error (err (to-uint error))))
  
  (list-name 0x737478 0x3339 u18357488 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.gamma-commission-3-5)
  