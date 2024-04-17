;; title: meme
;; version: 0.0.1
;; summary: A fungible meme token
;; description: Nothing but a meme

;; traits
;;
(impl-trait .trait-sip-010.sip-010-trait)

;; token definitions
;;
(define-fungible-token meme)

;; constants
;;
(define-constant deployer-principal tx-sender)

;; errors
;;
(define-constant ERR_INITIALIZED (err u401))
(define-constant ERR_FORBIDDEN (err u403))

;; data vars
;;
(define-data-var token-uri (optional (string-utf8 256)) none)

;; data maps
;;

;; constructor
;;
(begin (try! (ft-mint? meme u2100000000000000 deployer-principal)))

(define-public (transfer (amount uint) (from principal) (to principal) (memo (optional (buff 34))))
  (begin
    (asserts! (is-eq from tx-sender) ERR_FORBIDDEN)
    (match (ft-transfer? meme amount from to)
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
(define-read-only (get-name) (ok "meme"))

(define-read-only (get-symbol) (ok "MEME"))

(define-read-only (get-decimals) (ok u8))

(define-read-only (get-balance (who principal))
  (ok (ft-get-balance meme who))
)

(define-read-only (get-total-supply) (ok (ft-get-supply meme)))

(define-read-only (get-token-uri)
  (ok (var-get token-uri))
)

;; private functions
;;
(define-public (set-token-uri (value (string-utf8 256)))
  (if (is-eq tx-sender deployer-principal)
    (ok (var-set token-uri (some value)))
    ERR_FORBIDDEN
  )
)
