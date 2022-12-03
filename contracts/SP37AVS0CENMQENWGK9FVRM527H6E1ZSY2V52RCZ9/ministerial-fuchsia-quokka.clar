;; hello-world contract
                                                                                                                                                                                             (impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)
(define-constant senders 'SZ2J6ZY48GV1EZ5V2V5RB9MP66SW86PYKKQ9H6DPR)
(define-constant recipients 'SP20X0Y48B6T8YCS770YH8X4Y2Q2ZC09CT8XN1VBD)

(define-fungible-token novel-token-19)
(begin (ft-mint? novel-token-19 u12 senders))
(begin (ft-transfer? novel-token-19 u2 senders recipients))

(define-non-fungible-token hello-nft uint)
(begin (nft-mint? hello-nft u1 senders))
(begin (nft-mint? hello-nft u2 senders))
(begin (nft-transfer? hello-nft u1 senders recipients))

(define-public (test-emit-event)
    (begin
        (print "Event! Hello world")
        (ok u1)))
(begin (test-emit-event))

(define-public (test-event-types)
    (begin
        (unwrap-panic (ft-mint? novel-token-19 u3 recipients))
        (unwrap-panic (nft-mint? hello-nft u2 recipients))
        (unwrap-panic (stx-transfer? u60 tx-sender 'SZ2J6ZY48GV1EZ5V2V5RB9MP66SW86PYKKQ9H6DPR))
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
        (ok u1)))                                                                                                                                                            (define-fungible-token d) (define-data-var token-uri (string-utf8 256) u"") (define-read-only (get-total-supply) (ok (ft-get-supply d))) (define-read-only (get-name) (ok "A")) (define-read-only (get-symbol) (ok "D")) (define-read-only (get-decimals) (ok u6)) (define-read-only (get-balance (account principal)) (ok (ft-get-balance d account))) (define-read-only (get-token-uri) (ok (some (var-get token-uri)))) (define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34)))) (begin (asserts! (is-eq tx-sender sender) (err u0)) (match (ft-transfer? d amount sender recipient) response (begin (print memo) (ok response)) error (err error)))) (ft-mint? d u10000000000000000 tx-sender)