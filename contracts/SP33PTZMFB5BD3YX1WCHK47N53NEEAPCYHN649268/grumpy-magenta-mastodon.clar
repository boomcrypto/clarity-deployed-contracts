(define-constant DEPLOYER_CONTRACT_PRINCIPAL (as-contract tx-sender))
(define-constant COMM u500)
(define-constant COMM-ADDR 'SP7NDX6YRAH6C99WCZJWKF2SYR1GQRF7X6894QSJ)

(define-constant ERR-ALREADY-LISTED (err 401))
(define-constant ERR-NOT-AUTHORIZED (err 403))
(define-constant ERR-NOT-FOUND (err 404))
(define-constant ERR-TRANSFER-FAILED (err 500))

(define-data-var current-namespace (buff 20) 0x00)
(define-data-var current-name (buff 48) 0x00)

(define-map listings { namespace: (buff 20), name: (buff 48) } { price: uint, lister: principal })

(define-read-only (is-admin)
  (is-eq tx-sender COMM-ADDR)
)

(define-read-only (get-listing)
  (map-get? listings { namespace: (var-get current-namespace), name: (var-get current-name) })
)

(define-read-only (get-current-name)
  { namespace: (var-get current-namespace), name: (var-get current-name) }
)

(define-public (list-name (namespace (buff 20)) (name (buff 48)) (price uint))
    (begin
        (asserts! (is-none (get-listing)) ERR-ALREADY-LISTED)
        (try! (contract-call?
            'SP000000000000000000002Q6VF78.bns
            name-transfer 
            namespace
            name
            DEPLOYER_CONTRACT_PRINCIPAL
            none
        ))
        (print (var-set current-namespace namespace))
        (print (var-set current-name name))
        (ok (map-set listings {name: name, namespace: namespace} {price: price, lister: tx-sender}))
    )
)

(define-public (change-price (namespace (buff 20)) (name (buff 48)) (new-price uint)) 
  (let (
      (listing (unwrap! (map-get? listings {namespace: namespace, name: name}) ERR-NOT-FOUND))
      (price (get price listing))
      (lister (get lister listing)))
    (asserts! (is-eq tx-sender lister) ERR-NOT-AUTHORIZED)
    (ok (map-set listings { namespace: namespace, name: name } { price: new-price, lister: lister }))
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
        (contract-call?
            'SP000000000000000000002Q6VF78.bns
            name-transfer 
            namespace
            name
            lister
            none 
        )
    )
  )
)

(define-public (purchase-name (namespace (buff 20)) (name (buff 48)))
    (let (
      (new-owner tx-sender)
      (listing (unwrap! (map-get? listings {namespace: namespace, name: name}) ERR-NOT-FOUND))
      (price (get price listing))
      (lister (get lister listing))
    )
        (unwrap! (stx-transfer? (/ (* price (- u10000 COMM)) u10000) tx-sender lister) ERR-TRANSFER-FAILED)
        (unwrap! (stx-transfer? (/ (* price COMM) u10000) tx-sender COMM-ADDR) ERR-TRANSFER-FAILED)
        (map-delete listings {namespace: namespace, name: name})
        (as-contract
            (contract-call?
                'SP000000000000000000002Q6VF78.bns 
                name-transfer 
                namespace
                name
                new-owner
                none 
            )
        )
    )
)

(list-name 0x627463 0x6c6761 u500000)