;; usda-aeusdc-lp-token

;;;;;;;;;;;;;;;;;;;;; SIP 010 ;;;;;;;;;;;;;;;;;;;;;;
(impl-trait .sip-010-trait-ft-standard.sip-010-trait)
(impl-trait .lp-trait.lp-trait)


(define-fungible-token usda-aeusdc-lpt)


(define-constant CONTRACT-OWNER 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M)
(define-constant ERR-UNAUTHORIZED-MINT (err u100))
(define-constant ERR-NOT-AUTHORIZED (err u101))

;;vars
(define-data-var token-uri (string-utf8 256) u"")
(define-data-var approved-supply-controller principal 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stableswap-usda-aeusdc-v-1-3)


;; ---------------------------------------------------------
;; SIP-10 Functions
;; ---------------------------------------------------------
(define-read-only (adheres-to-sip-010)
  (ok true)
)

(define-read-only (get-name)
  (ok "USDA-aeUSDC-LP")
)

(define-read-only (get-symbol)
  (ok "USDA-aeUSDC-LP")
)

(define-read-only (get-decimals)
  (ok u6)
)

(define-read-only (get-balance (account principal))
  (ok (ft-get-balance usda-aeusdc-lpt account))
)

(define-read-only (get-total-supply)
  (ok (ft-get-supply usda-aeusdc-lpt))
)


(define-read-only (get-token-uri)
  (ok (some (var-get token-uri)))
)

(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (begin
    (asserts! (is-eq tx-sender sender) ERR-NOT-AUTHORIZED)

    (match (ft-transfer? usda-aeusdc-lpt amount sender recipient)
      response (begin
        (print memo)
        (ok response)
      )
      error (err error)
    )
  )
)

(define-public (mint (who principal) (amount uint))
  (begin
    (asserts! (is-eq tx-sender (var-get approved-supply-controller)) ERR-UNAUTHORIZED-MINT)
    (ft-mint? usda-aeusdc-lpt amount who)
  )
)


(define-public (burn (burner principal) (amount uint))
  (begin
    (asserts! (is-eq tx-sender burner) ERR-NOT-AUTHORIZED)
    (ft-burn? usda-aeusdc-lpt amount burner)
  )
)

;; Change the supply-controller to any other principal, can only be called the contract-owner
(define-public (set-supply-controller (who principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (ok (var-set approved-supply-controller who))
  )
)

(define-public (set-token-uri (uri (string-utf8 256)))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (ok (var-set token-uri uri))
  )
)