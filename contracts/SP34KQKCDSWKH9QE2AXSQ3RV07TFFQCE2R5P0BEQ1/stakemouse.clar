(define-constant ERR-UNAUTHORIZED (err u401))
(define-fungible-token stakemouse)
(define-data-var token-uri (optional (string-utf8 256)) (some u"https://ipfs.io/ipfs/QmNv45zmYv2W78czZTFEkkB53WGuEGGndUG1TTj98jtcyx"))
(define-constant contract-creator tx-sender)
(impl-trait 'SP34KQKCDSWKH9QE2AXSQ3RV07TFFQCE2R5P0BEQ1.sip-010-trait-ft-standard.sip-010-trait)

;; SIP-010 Standard
(define-public (transfer (amount uint) (from principal) (to principal) (memo (optional (buff 34))))
    (begin
        (asserts! (is-eq from tx-sender) ERR-UNAUTHORIZED)
        (ft-transfer? stakemouse amount from to)
    )
)

(define-read-only (get-name)
    (ok "Stakemouse")
)

(define-read-only (get-symbol)
    (ok "MICK")
)

(define-read-only (get-decimals)
    (ok u6)
)

(define-read-only (get-balance (user principal))
    (ok (ft-get-balance stakemouse user)
    )
)

(define-read-only (get-total-supply)
    (ok (ft-get-supply stakemouse)
    )
)

(define-public (set-token-uri (value (string-utf8 256)))
    (begin
        (asserts! (is-eq tx-sender contract-creator) ERR-UNAUTHORIZED)
        (var-set token-uri (some value))
        (ok (print {
              notification: "token-metadata-update",
              payload: {
                contract-id: (as-contract tx-sender),
                token-class: "ft"
              }
            })
        )
    )
)

(define-read-only (get-token-uri)
    (ok (var-get token-uri)
    )
)

;; ---------------------------------------------------------
;; Utility Functions
;; ---------------------------------------------------------
(define-public (send-many (recipients (list 200 { to: principal, amount: uint, memo: (optional (buff 34)) })))
  (fold check-err (map send-token recipients) (ok true))
)

(define-private (check-err (result (response bool uint)) (prior (response bool uint)))
  (match prior ok-value result err-value (err err-value))
)

(define-private (send-token (recipient { to: principal, amount: uint, memo: (optional (buff 34)) }))
  (send-token-with-memo (get amount recipient) (get to recipient) (get memo recipient))
)

(define-private (send-token-with-memo (amount uint) (to principal) (memo (optional (buff 34))))
  (let ((transferOk (try! (transfer amount tx-sender to memo))))
    (ok transferOk)
  )
)

(begin
  (try! (ft-mint? stakemouse u1000000000000000000 contract-creator))
)