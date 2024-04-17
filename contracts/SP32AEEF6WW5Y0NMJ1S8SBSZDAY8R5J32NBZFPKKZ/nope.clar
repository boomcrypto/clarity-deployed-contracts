;; Error codes
(define-constant ERR-UNAUTHORIZED u401)
(define-constant ERR-YOU-POOR u402)
(define-constant ERR-INVALID-PARAMS u400)

(define-constant WRAP-THRESHOLD (* u85 (pow u10 u12)))

;; 88,975,877,083,900
(define-constant MAX-SUPPLY u88975877083900)
(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(define-data-var contract-admin principal tx-sender)

;; can only be set once when the threshold is met
(define-data-var is-threshold-reached bool false)

(define-fungible-token NOT MAX-SUPPLY)

(define-private (update-threshold-state) 
    (if (var-get is-threshold-reached) false
        (var-set is-threshold-reached 
            (>= (ft-get-supply NOT) WRAP-THRESHOLD))))


(define-read-only (is-safe-to-wrap (amount uint) (wrapper principal)) 
    (let (
            (supply (ft-get-supply NOT)))
    
        (or 
            (var-get is-threshold-reached)
            (and
                ;; exclusive basically the threshold is a finish line
                (> supply WRAP-THRESHOLD)
                (<= (+ amount supply) MAX-SUPPLY))
            (is-eq contract-caller .napper))))


(define-public (wrap-nthng (amount uint))
    (begin
        (asserts! (is-safe-to-wrap amount tx-sender) (err ERR-UNAUTHORIZED))
        (unwrap! 
            (contract-call? 
                .micro-nthng 
                transfer (as-contract tx-sender) amount)
            (err ERR-YOU-POOR))
        (try! (ft-mint? NOT amount tx-sender))
        (update-threshold-state)
        (ok true)))


(define-public (unwrap (amount uint))
    (let (
        (unwrapper tx-sender)
    )
        (asserts! (>= (ft-get-balance NOT tx-sender) amount) (err ERR-YOU-POOR))
        (unwrap-panic (ft-burn? NOT amount tx-sender))
        (as-contract (contract-call? .micro-nthng transfer unwrapper amount))))

;;;;;;;;;;;;;;;;;;;;; SIP 010 ;;;;;;;;;;;;;;;;;;;;;;

(define-public (transfer (amount uint) (from principal) (to principal) (memo (optional (buff 34))))
    (begin
        (asserts! (is-eq from tx-sender) (err ERR-UNAUTHORIZED))
        (asserts! (not (is-eq to tx-sender)) (err ERR-INVALID-PARAMS))
        (asserts! (>= (ft-get-balance NOT from) amount) (err ERR-YOU-POOR))
        (print (default-to 0x memo))
        (ft-transfer? NOT amount from to)))


(define-read-only (get-name)
    (ok (var-get token-name)))

(define-read-only (get-symbol)
    (ok (var-get token-symbol)))

(define-read-only (get-decimals)
    (ok (var-get token-decimals)))

(define-read-only (get-balance (user principal))
    (ok (ft-get-balance NOT user)))

(define-read-only (get-total-supply)
    (ok (ft-get-supply NOT)))

(define-read-only (get-token-uri)
    (ok (var-get token-uri)))

;; send-many

(define-public (send-nothing (amount uint) (to principal) (memo (optional (buff 34))))
    (let ((transfer-ok (try! (transfer amount tx-sender to none))))
    (print (default-to 0x memo))
    (ok transfer-ok)))

(define-private (send-nothing-unwrap (recipient { to: principal, amount: uint, memo: (optional (buff 34)) }))
    (send-nothing
        (get amount recipient)
        (get to recipient)
        (get memo recipient)))

(define-private (check-err  (result (response bool uint))
                            (prior (response bool uint)))
    (match prior ok-value result
                err-value (err err-value)))

(define-public (send-many (recipients (list 200 { to: principal, amount: uint, memo: (optional (buff 34)) })))
    (fold check-err
        (map send-nothing-unwrap recipients)
        (ok true)))



;; METADATA
(define-data-var token-uri (optional (string-utf8 256)) (some u"ipfs://ipfs/bafkreigrnes22au2i45fcdsmrlq6srfyvxufjoosqpyafcz6ykbee2i6d4"))
(define-data-var token-name (string-ascii 32) "Nothing")
(define-data-var token-symbol (string-ascii 32) "NOT")
(define-data-var token-decimals uint u0)

;; anything can be edited
(define-public 
    (set-metadata 
        (uri (optional (string-utf8 256))) 
        (name (string-ascii 32))
        (symbol (string-ascii 32))
        (decimals uint))
    (begin
        (asserts! (is-eq tx-sender (var-get contract-admin)) (err ERR-UNAUTHORIZED))
        (asserts! 
            (and 
                (is-some uri)
                (> (len name) u0)
                (> (len symbol) u0)
                (<= decimals u6))
            (err ERR-INVALID-PARAMS))
        (var-set token-uri uri)
        (var-set token-name name)
        (var-set token-symbol symbol)
        (var-set token-decimals decimals)
        (print 
            {
                notification: "token-metadata-update",
                payload: {
                    token-class: "ft", 
                    contract-id: (as-contract tx-sender) 
                }
            })
        (ok true)))

;; should be set to a DAO contract in the future
;; this can only change the metadata nothing else
(define-public (set-admin (new-admin principal))
    (begin
        (asserts! (is-eq contract-caller (var-get contract-admin)) (err ERR-UNAUTHORIZED))
        (asserts! (not (is-eq new-admin (var-get contract-admin))) (err ERR-INVALID-PARAMS))
        (var-set contract-admin new-admin)
        (ok true)))
