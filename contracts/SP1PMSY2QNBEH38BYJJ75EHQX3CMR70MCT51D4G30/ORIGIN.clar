(define-constant ERR-UNAUTHORIZED u401)
(define-constant ERR-YOU-POOR u402)
(define-constant ERR-INVALID-PARAMS u400)

(define-constant MAX-SUPPLY u10000000000000000)
(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(define-fungible-token ORIGIN MAX-SUPPLY)

;;;;;;;;;;;;;;;;;;;;; SIP 010 ;;;;;;;;;;;;;;;;;;;;;;

(define-public (transfer (amount uint) (from principal) (to principal) (memo (optional (buff 34))))
    (begin
        (asserts! (is-eq from tx-sender) (err ERR-UNAUTHORIZED))
        (asserts! (not (is-eq to tx-sender)) (err ERR-INVALID-PARAMS))
        (asserts! (>= (ft-get-balance ORIGIN from) amount) (err ERR-YOU-POOR))
        (if (is-some memo)
            (print (unwrap-panic memo))
            0x
        )
        (ft-transfer? ORIGIN amount from to)))


(define-read-only (get-name)
    (ok (var-get token-name)))

(define-read-only (get-symbol)
    (ok (var-get token-symbol)))

(define-read-only (get-decimals)
    (ok (var-get token-decimals)))

(define-read-only (get-balance (user principal))
    (ok (ft-get-balance ORIGIN user)))

(define-read-only (get-total-supply)
    (ok (ft-get-supply ORIGIN)))

(define-read-only (get-token-uri)
    (ok (var-get token-uri)))

;; send-many

(define-public (send-ORIGIN (amount uint) (to principal))
    (let ((transfer-ok (try! (transfer amount tx-sender to none))))
    (ok transfer-ok)))

(define-private (send-ORIGIN-unwrap (recipient { to: principal, amount: uint }))
    (send-ORIGIN
        (get amount recipient)
        (get to recipient)))

(define-private (check-err  (result (response bool uint))
                            (prior (response bool uint)))
    (match prior ok-value result
                err-value (err err-value)))

(define-public (send-many (recipients (list 2500 { to: principal, amount: uint })))
    (fold check-err
        (map send-ORIGIN-unwrap recipients)
        (ok true)))

(define-public (send-more (recipients (list 2000 { to: principal, amount: uint })))
    (begin
        (map send-ORIGIN-unwrap recipients)
        (ok true)))

           
(define-data-var token-uri (optional (string-utf8 256)) (some u"https://ipfs.io/ipfs/Qmf5Qs8Qbkvf291xSBnBVVvofvgCthv4TmiJEdkYDU5SRY"))
(define-data-var token-name (string-ascii 32) "ORIGIN")
(define-data-var token-symbol (string-ascii 32) "ORIGIN")
(define-data-var token-decimals uint u6)


(define-public (burn (amount uint))
  (ft-burn? ORIGIN amount tx-sender)
)


(ft-mint? ORIGIN MAX-SUPPLY tx-sender)