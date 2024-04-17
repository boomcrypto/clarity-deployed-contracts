;; not a production deployment

;;;;;;;;;;;;;;;;;;;;; SIP 010 ;;;;;;;;;;;;;;;;;;;;;;

;; change in final deployment
(impl-trait 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.sip-010-trait-ft-standard.sip-010-trait)
(impl-trait 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.lp-trait.lp-trait)


(define-fungible-token stx-ststx-lpt-test)


(define-constant CONTRACT-OWNER 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M)
(define-constant ERR-UNAUTHORIZED-MINT (err u100))
(define-constant ERR-NOT-AUTHORIZED (err u101))

;;vars
(define-data-var token-uri (string-utf8 256) u"")
(define-data-var approved-supply-controller principal 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stableswap-stx-ststx-v-1-2)


;; ---------------------------------------------------------
;; SIP-10 Functions
;; ---------------------------------------------------------
(define-read-only (adheres-to-sip-010)
  (ok true)
)

(define-read-only (get-name)
  (ok "STX-stSTX-LP-test")
)

(define-read-only (get-symbol)
  (ok "STX-stSTX-LP-test")
)

(define-read-only (get-decimals)
  (ok u6)
)

(define-read-only (get-balance (account principal))
  (ok (ft-get-balance stx-ststx-lpt-test account))
)

(define-read-only (get-total-supply)
  (ok (ft-get-supply stx-ststx-lpt-test))
)


(define-read-only (get-token-uri)
  (ok (some (var-get token-uri)))
)

;; added function
(define-public (set-token-uri (uri (string-utf8 256)))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (ok (var-set token-uri uri))
  )
)


(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (begin
    (asserts! (is-eq tx-sender sender) ERR-NOT-AUTHORIZED)

    (match (ft-transfer? stx-ststx-lpt-test amount sender recipient)
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
    ;; amount & who are unchecked, but we let the contract owner mint to whoever they like for convenience
    ;; #[allow(unchecked_data)]
    (ft-mint? stx-ststx-lpt-test amount who)
  )
)


(define-public (burn (burner principal) (amount uint))
  (begin
    (asserts! (is-eq tx-sender burner) ERR-NOT-AUTHORIZED)
    ;; amount & who are unchecked, but we let the contract owner mint to whoever they like for convenience
    ;; #[allow(unchecked_data)]
    (ft-burn? stx-ststx-lpt-test amount burner)
  )
)

;; Change the supply-controller to any other principal, can only be called the current supply-controller
(define-public (set-supply-controller (who principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    ;; who is unchecked, we allow the owner to make whoever they like the new minter
    ;; #[allow(unchecked_data)]
    (ok (var-set approved-supply-controller who))
  )
)