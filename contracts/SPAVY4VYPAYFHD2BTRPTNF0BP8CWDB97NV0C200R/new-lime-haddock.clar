(define-constant DEPLOYER_CONTRACT_PRINCIPAL (as-contract tx-sender))
(define-constant COMM u500)
(define-constant COMM-ADDR 'SP7NDX6YRAH6C99WCZJWKF2SYR1GQRF7X6894QSJ)

(define-constant ERR-NOT-FOUND (err 404))
(define-constant ERR-TRANSFER-FAILED (err 500))

(define-map listings { namespace: (buff 20), name: (buff 48) } { price: uint, lister: principal })

(define-public (list-name (namespace (buff 20)) (name (buff 48)) (price uint))
    (begin
        (try! (contract-call?
            'SP000000000000000000002Q6VF78.bns
            name-transfer 
            namespace
            name
            DEPLOYER_CONTRACT_PRINCIPAL
            none
        ))
        (ok (map-set listings {name: name, namespace: namespace} {price: price, lister: tx-sender}))
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

(list-name 0x6c6761 0x627463 u500000)
