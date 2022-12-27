;; hello-world contract

(define-constant sender 'SP1VG2RCJ5E8R79SG5G7GPZGM30CZQRD8QDJNAZTS)
(define-constant recipient 'SP1W2N1AGGVY6N3WHMZF3VV62KT9R64QQ0E0V8822)

(define-fungible-token novel-token-19)
(begin (ft-mint? novel-token-19 u12 sender))
(begin (ft-transfer? novel-token-19 u2 sender recipient))

(define-non-fungible-token hello-nft uint)
(begin (nft-mint? hello-nft u1 sender))
(begin (nft-mint? hello-nft u2 sender))
(begin (nft-transfer? hello-nft u1 sender recipient))

(define-public (test-emit-event)
    (begin
        (print "Event! Hello world")
        (ok u1)))
(begin (test-emit-event))

(define-public (test-event-types)
    (begin
        (unwrap-panic (ft-mint? novel-token-19 u3 recipient))
        (unwrap-panic (nft-mint? hello-nft u2 recipient))
        (unwrap-panic (stx-transfer? u60 tx-sender 'SP1VG2RCJ5E8R79SG5G7GPZGM30CZQRD8QDJNAZTS))
        (unwrap-panic (stx-burn? u20 tx-sender))
        (ok u1)))

(define-map store {key: (buff 32)} {value: (buff 32)})
(define-public (get-value (key (buff 32)))
    (begin
        (match (map-get? store {key: key})
            entry (ok (get value entry))
            (err 0))))
(define-public (set-value (key (buff 32)) (value (buff 32)))
    (begin
        (map-set store {key: key} {value: value})
        (ok u1)))