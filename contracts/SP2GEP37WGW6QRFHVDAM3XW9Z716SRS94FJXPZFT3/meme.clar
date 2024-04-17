;; title: meme
;; version: 0.0.1
;; summary: A fungible meme token
;; description: Nothing but a meme

;; traits
;;
(impl-trait .trait-sip-010.sip-010-trait)

;; token definitions
;;
(define-fungible-token sip)

;; constants
;;

;; errors
;;
(define-constant ERR_INITIALIZED (err u401))
(define-constant ERR_FORBIDDEN (err u403))

;; data vars
;;
(define-data-var token-name (string-ascii 32) "")
(define-data-var token-symbol (string-ascii 32) "")
(define-data-var token-uri (string-utf8 256) u"")
(define-data-var token-decimals uint u0)

(define-data-var deployer-principal principal tx-sender)
(define-data-var is-initialized bool false)

;; data maps
;;

;; public functions
;;
(define-public (initialize (name (string-ascii 32)) (symbol (string-ascii 32)) (decimals uint) (supply uint) (uri (string-utf8 256)))
  (begin
    ;; check
    (asserts! (is-eq tx-sender (var-get deployer-principal)) ERR_FORBIDDEN)
    (asserts! (not (var-get is-initialized)) ERR_INITIALIZED)
    ;; effect
    (var-set is-initialized true)
    (var-set token-name name)
    (var-set token-symbol symbol)
    (var-set token-decimals decimals)
    (var-set token-uri uri)
    (ft-mint? sip supply tx-sender)
  )
)

(define-public (transfer (amount uint) (from principal) (to principal) (memo (optional (buff 34))))
  (begin
    (asserts! (is-eq from tx-sender) ERR_FORBIDDEN)
    (match (ft-transfer? sip amount from to)
      response (begin
        (print memo)
        (ok response)
      )
      error (err error)
    )
  )
)

;; read only functions
;;
(define-read-only (get-name) (ok (var-get token-name)))

(define-read-only (get-symbol) (ok (var-get token-symbol)))

(define-read-only (get-decimals) (ok (var-get token-decimals)))

(define-read-only (get-balance (who principal))
  (ok (ft-get-balance sip who))
)

(define-read-only (get-total-supply) (ok (ft-get-supply sip)))

(define-read-only (get-token-uri) (ok (some (var-get token-uri))))

;; private functions
;;

