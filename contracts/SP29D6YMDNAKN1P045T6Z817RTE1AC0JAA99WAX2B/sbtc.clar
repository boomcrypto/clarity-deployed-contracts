;;;;;;;;;;;;;;;;;;;;; SIP 010 ;;;;;;;;;;;;;;;;;;;;;;
(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)
;; (impl-trait .sip-010-trait-ft-standard.sip-010-trait)
;; (impl-trait .arkadiko-dao-token-trait-v1.dao-token-trait)

;; Defines the sbtc Stablecoin according to the SIP-010 Standard
(define-fungible-token sbtc u2100000000)

(define-data-var token-uri (string-utf8 256) u"")

;; errors
(define-constant ERR-NOT-AUTHORIZED u14401)

;; ---------------------------------------------------------
;; SIP-10 Functions
;; ---------------------------------------------------------

(define-read-only (get-total-supply)
  (ok (ft-get-supply sbtc))
)

(define-read-only (get-name)
  (ok "sbtc")
)

(define-read-only (get-symbol)
  (ok "sbtc")
)

(define-read-only (get-decimals)
  (ok u8)
)

(define-read-only (get-balance (account principal))
  (ok (ft-get-balance sbtc account))
)

(define-public (set-token-uri (value (string-utf8 256)))
  ;;(if (is-eq tx-sender (contract-call? .arkadiko-dao get-dao-owner))
    (ok (var-set token-uri value))
    ;; (err ERR-NOT-AUTHORIZED)
  ;;)
)

(define-read-only (get-token-uri)
  (ok (some (var-get token-uri)))
)

(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (begin
    (asserts! (is-eq tx-sender sender) (err ERR-NOT-AUTHORIZED))

    (match (ft-transfer? sbtc amount sender recipient)
      response (begin
        (print memo)
        (ok response)
      )
      error (err error)
    )
  )
)

;; ---------------------------------------------------------
;; DAO token trait
;; ---------------------------------------------------------

;; Mint method for DAO
(define-public (mint-for-dao (amount uint) (recipient principal))
  (begin
    (asserts! (is-eq contract-caller .arkadiko-dao) (err ERR-NOT-AUTHORIZED))
    (ft-mint? sbtc amount recipient)
  )
)

;; Burn method for DAO
(define-public (burn-for-dao (amount uint) (sender principal))
  (begin
    (asserts! (is-eq contract-caller .arkadiko-dao) (err ERR-NOT-AUTHORIZED))
    (ft-burn? sbtc amount sender)
  )
)

;; Burn external - Should never happen
(define-public (burn (amount uint) (sender principal))
  (err ERR-NOT-AUTHORIZED)
)

;; ---------------------------------------------------------
;; Testnet Minting UASU Finance
;; ---------------------------------------------------------
;; (define-public (mint-to (amount uint) (recipient principal))
;;   (begin
;;     ;; (asserts! (is-eq contract-caller .arkadiko-dao) (err ERR-NOT-AUTHORIZED))
;;     ;; anyone can mint let's party 
;;     ;; (ft-mint? sbtc amount recipient)
;;   )
;; )

(ft-mint? sbtc u1000000000 'SP29D6YMDNAKN1P045T6Z817RTE1AC0JAA99WAX2B)
(ft-mint? sbtc  u1100000000 'SP1JAG6TV2XRYFGJN7CAAN6Z3CEW2YMZWMHJAJV91)