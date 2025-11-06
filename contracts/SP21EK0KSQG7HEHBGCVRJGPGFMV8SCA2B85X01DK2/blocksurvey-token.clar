;; title: blocksurvey-token
;; version:
;; summary:
;; description:

;; traits
(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

;; token definitions
(define-fungible-token blocksurvey)

;; constants
(define-constant CONTRACT-OWNER tx-sender)
;; Errors
(define-constant ERR-OWNER-ONLY (err u100))
(define-constant ERR-NOT-TOKEN-OWNER (err u101))
(define-constant ERR-INVALID-DATA (err u102))

;; data vars
(define-data-var token-name (string-ascii 32) "BlockSurvey")
(define-data-var token-symbol (string-ascii 10) "BST")
(define-data-var token-decimals uint u6)
(define-data-var token-uri (optional (string-utf8 256)) (some u"https://cdn.blocksurvey.io/token/metadata/blocksurvey-token.json"))

;; public functions
(define-public (mint (amount uint) (recipient principal))
    (begin
        (asserts! (and (is-eq tx-sender CONTRACT-OWNER) (is-eq tx-sender recipient)) ERR-OWNER-ONLY)
        (ft-mint? blocksurvey amount (as-contract tx-sender))
    )
)

(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
    (begin
        (asserts! (is-eq tx-sender sender) ERR-NOT-TOKEN-OWNER)
        (try! (ft-transfer? blocksurvey amount sender recipient))
        (match memo to-print (print to-print) 0x)
        (ok true)
    )
)

(define-public (transfer-contract-balance (amount uint))
    (begin 
        (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-OWNER-ONLY)
        (try! (ft-transfer? blocksurvey amount (as-contract tx-sender) CONTRACT-OWNER))
        (ok true)
    )
)

(define-public (update-name (name (string-ascii 32)))
    (begin 
        ;; Validation
        (asserts! (validate-ownership) ERR-OWNER-ONLY)
        (asserts! (> (len name) u3) ERR-INVALID-DATA)
        
        ;; Update the name
        (var-set token-name name)
        
        (ok true)
    )
)

(define-public (update-symbol (symbol (string-ascii 10)))
    (begin 
        ;; Validation
        (asserts! (validate-ownership) ERR-OWNER-ONLY)
        (asserts! (> (len symbol) u2) ERR-INVALID-DATA)

        ;; Update the symbol
        (var-set token-symbol symbol)

        (ok true)
    )
)

(define-public (update-decimals (decimals uint))
    (begin 
        ;; Validation
        (asserts! (validate-ownership) ERR-OWNER-ONLY)
        (asserts! (>= decimals u0) ERR-INVALID-DATA)
        (asserts! (<= decimals u20) ERR-INVALID-DATA)

        ;; Update the decimals
        (var-set token-decimals decimals)

        (ok true)
    )
)

(define-public (update-uri (uri (string-utf8 256)))
    (begin 
        ;; Validation
        (asserts! (validate-ownership) ERR-OWNER-ONLY)
        (asserts! (is-eq (len uri) u0) ERR-INVALID-DATA)

        ;; Update the URI
        (var-set token-uri (some uri))

        (ok true)
    )
)

;; read only functions
(define-read-only (get-name)
    (ok (var-get token-name))
)

(define-read-only (get-symbol)
    (ok (var-get token-symbol))
)

(define-read-only (get-decimals)
    (ok (var-get token-decimals))
)

(define-read-only (get-token-uri)
    (ok (var-get token-uri))
)

(define-read-only (get-total-supply)
    (ok (ft-get-supply blocksurvey))
)

(define-read-only (get-balance (who principal))
    (ok (ft-get-balance blocksurvey who))
)

(define-read-only (get-contract-balance)
    (ok (ft-get-balance blocksurvey (as-contract tx-sender)))
)

;; private functions
(define-private (validate-ownership)
    (is-eq tx-sender CONTRACT-OWNER)
)

