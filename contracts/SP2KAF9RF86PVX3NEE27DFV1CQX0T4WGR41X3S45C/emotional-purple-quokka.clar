
(define-constant ERR-NOT-AUTHORIZED (err u401))
(define-constant ERR-NOT-OWNER (err u201))
(define-constant ERR-NOT-BUYER (err u301))
(define-constant ERR-NOT-ACTIVE (err u501))
(define-constant ERR-NOT-ON (err u601))
(define-constant ERR-BID-NOT-HIGH-ENOUGH (err u100))
(define-constant ERR-NOT-OPTIONAL (err u1000))
(define-constant ERR-ITEM-NOT-FOR-SALE (err u101))
(define-constant ERR-ITEM-PRICE-TOO-LOW (err u102))
(define-constant CONTRACT-OWNER tx-sender)

(define-data-var commission uint u250)
(define-data-var active bool true)

(define-map bids { namespace: (buff 20), name: (buff 48) } { buyer: principal, offer: uint })

(define-public (bid (namespace (buff 20))
                            (domain (buff 48))
                            (amount uint))
    (match (stx-transfer? amount tx-sender (as-contract tx-sender))
      success (begin
      (asserts! (is-eq (var-get active) true) ERR-NOT-ON)
     (map-set bids { namespace: namespace, name: domain } { buyer: tx-sender, offer: amount })
     (ok true)
    )
    error (err error)
    )
)

(define-public (get-bid (namespace (buff 20))
                            (domain (buff 48)))
     (ok (map-get? bids { namespace: namespace, name: domain } ))
)

(define-public (withdraw-bid (namespace (buff 20))
                            (domain (buff 48)))
    (let (
        (name (map-get? bids { namespace: namespace, name: domain } ))
        (offer (unwrap-panic (get offer name)))
        (buyer (unwrap-panic (get buyer name)))
    )
    (begin
    (asserts! (is-eq tx-sender buyer) ERR-NOT-BUYER)
    (try! (as-contract (stx-transfer? offer (as-contract tx-sender) buyer)))
     (map-delete bids { namespace: namespace, name: domain } )
    )
    (ok true)
)
)

(define-public (accept-bid (namespace (buff 20))
                            (domain (buff 48)))
    (let (
        (name (map-get? bids { namespace: namespace, name: domain } ))
        (offer (unwrap-panic (get offer name)))
        (commiss (/ (* offer (var-get commission)) u10000))
        (buyer (unwrap-panic (get buyer name)))
        (owner (get owner (unwrap-panic (contract-call? 'SP000000000000000000002Q6VF78.bns name-resolve namespace domain))))
        ;; (owner (get owner { owner: 'ST3PF13W7Z0RRM42A8VZRVFQ75SV1K26RXEP8YGKJ }))
    )
    
    
    (begin
    (print commiss)
    (print name)
    (print buyer)
    
    (asserts! (is-eq (var-get active) true) ERR-NOT-ACTIVE)
    (asserts! (is-eq owner tx-sender) ERR-NOT-AUTHORIZED)
    (try! (as-contract (stx-transfer? commiss (as-contract tx-sender) CONTRACT-OWNER)))
    (try! (as-contract (stx-transfer? (- offer commiss) (as-contract tx-sender) owner)))
    (try! (match (contract-call? 'SP000000000000000000002Q6VF78.bns name-transfer namespace domain buyer none) 
     success (ok success) 
     error (err (to-uint error))))
     (map-delete bids { namespace: namespace, name: domain } )
    )
    (ok true)
)
)          

(define-public (admin-unbid (namespace (buff 20))
                            (domain (buff 48)))
    (let (
        (name (map-get? bids { namespace: namespace, name: domain } ))
        (offer (unwrap-panic (get offer name)))
        (buyer (unwrap-panic (get buyer name)))
    )
    (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-OWNER)
    (try! (as-contract (stx-transfer? offer (as-contract tx-sender) buyer)))
     (map-delete bids { namespace: namespace, name: domain } )
     (ok true)
    )
)
)

(define-public (set-commisssion (value uint))
  (if (is-eq tx-sender CONTRACT-OWNER)
    (ok (var-set commission value))
    (err ERR-NOT-AUTHORIZED)
  )
)

(define-public (set-active (value bool))
  (if (is-eq tx-sender CONTRACT-OWNER)
    (ok (var-set active value))
    (err ERR-NOT-AUTHORIZED)
  )
)