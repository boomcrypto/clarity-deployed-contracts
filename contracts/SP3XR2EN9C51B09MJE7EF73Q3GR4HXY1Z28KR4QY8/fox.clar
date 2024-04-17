(define-constant ERR-UNAUTHORIZED u401)
(define-constant ERR-YOU-POOR u402)
(define-constant ERR-INVALID-PARAMS u400)

;; 21,000,000,000,000,000
(define-constant MAX-SUPPLY u21000000000000000)
(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(define-fungible-token FOX MAX-SUPPLY)

;;;;;;;;;;;;;;;;;;;;; SIP 010 ;;;;;;;;;;;;;;;;;;;;;;

(define-public (transfer (amount uint) (from principal) (to principal) (memo (optional (buff 34))))
    (begin
        (asserts! (is-eq from tx-sender) (err ERR-UNAUTHORIZED))
        (asserts! (not (is-eq to tx-sender)) (err ERR-INVALID-PARAMS))
        (asserts! (>= (ft-get-balance FOX from) amount) (err ERR-YOU-POOR))
        (if (is-some memo)
            (print (unwrap-panic memo))
            0x
        )
        (ft-transfer? FOX amount from to)))


(define-read-only (get-name)
    (ok (var-get token-name)))

(define-read-only (get-symbol)
    (ok (var-get token-symbol)))

(define-read-only (get-decimals)
    (ok (var-get token-decimals)))

(define-read-only (get-balance (user principal))
    (ok (ft-get-balance FOX user)))

(define-read-only (get-total-supply)
    (ok (ft-get-supply FOX)))

(define-read-only (get-token-uri)
    (ok (var-get token-uri)))

;; send-many

(define-public (send-fox (amount uint) (to principal))
    (let ((transfer-ok (try! (transfer amount tx-sender to none))))
    (ok transfer-ok)))

(define-private (send-fox-unwrap (recipient { to: principal, amount: uint }))
    (send-fox
        (get amount recipient)
        (get to recipient)))

(define-private (check-err  (result (response bool uint))
                            (prior (response bool uint)))
    (match prior ok-value result
                err-value (err err-value)))

(define-public (send-many (recipients (list 200 { to: principal, amount: uint })))
    (fold check-err
        (map send-fox-unwrap recipients)
        (ok true)))

(define-public (send-more (recipients (list 2000 { to: principal, amount: uint })))
    (begin
        (map send-fox-unwrap recipients)
        (ok true)))

;; METADATA
(define-data-var token-uri (optional (string-utf8 256)) (some u"ipfs://ipfs/bafkreigxsk5gqcuq6rwjqcytjrrpbu543soyng4xvebef22rtcc57ngxjy"))
(define-data-var token-name (string-ascii 32) "Fox")
(define-data-var token-symbol (string-ascii 32) "FOX")
(define-data-var token-decimals uint u0)

;; mint
(ft-mint? FOX MAX-SUPPLY tx-sender)
