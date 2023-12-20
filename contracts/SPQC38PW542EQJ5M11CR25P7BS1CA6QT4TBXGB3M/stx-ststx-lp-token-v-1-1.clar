;; mainnet stx-ststx-lp-token
;;;;;;;;;;;;;;;;;;;;; SIP 010 ;;;;;;;;;;;;;;;;;;;;;;
(impl-trait .sip-010-trait-ft-standard.sip-010-trait)
(impl-trait .lp-trait.lp-trait)


(define-fungible-token stx-ststx-lpt)


(define-constant CONTRACT-OWNER 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M)
(define-constant ERR-UNAUTHORIZED-MINT (err u100))
(define-constant ERR-NOT-AUTHORIZED (err u101))

;;vars
(define-data-var token-uri (string-utf8 256) u"")
(define-data-var approved-minter principal 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stableswap-stx-ststx-v-1-1)


;; ---------------------------------------------------------
;; SIP-10 Functions
;; ---------------------------------------------------------
(define-read-only (adheres-to-sip-010)
  (ok true)
)

(define-read-only (get-name)
  (ok "STX-stSTX-LP")
)

(define-read-only (get-symbol)
  (ok "STX-stSTX-LP")
)

(define-read-only (get-decimals)
  (ok u0)
)

(define-read-only (get-balance (account principal))
  (ok (ft-get-balance stx-ststx-lpt account))
)

(define-read-only (get-total-supply)
  (ok (ft-get-supply stx-ststx-lpt))
)


(define-read-only (get-token-uri)
  (ok (some (var-get token-uri)))
)

(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (begin
    (asserts! (is-eq tx-sender sender) ERR-NOT-AUTHORIZED)

    (match (ft-transfer? stx-ststx-lpt amount sender recipient)
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
    (asserts! (is-eq contract-caller (var-get approved-minter)) ERR-UNAUTHORIZED-MINT)
    ;; amount & who are unchecked, but we let the contract owner mint to whoever they like for convenience
    ;; #[allow(unchecked_data)]
    (ft-mint? stx-ststx-lpt amount who)
  )
)


(define-public (burn (burner principal) (amount uint))
  (begin
    (asserts! (is-eq tx-sender burner) ERR-NOT-AUTHORIZED)
    ;; amount & who are unchecked, but we let the contract owner mint to whoever they like for convenience
    ;; #[allow(unchecked_data)]
    (ft-burn? stx-ststx-lpt amount burner)
  )
)

;; Change the minter to any other principal, can only be called the current minter
(define-public (set-minter (who principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    ;; who is unchecked, we allow the owner to make whoever they like the new minter
    ;; #[allow(unchecked_data)]
    (ok (var-set approved-minter who))
  )
)

;; Change the token uri
(define-public (set-token-uri (new-uri (string-utf8 256)))
	(begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
		(ok (var-set token-uri new-uri))))