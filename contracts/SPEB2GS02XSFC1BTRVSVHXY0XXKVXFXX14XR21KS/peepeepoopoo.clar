(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(define-constant err-unauthorised (err u3000))
(define-constant err-not-token-owner (err u4))

(define-fungible-token peepeepoopoo)

(define-data-var token-uri (optional (string-utf8 256)) none)

(define-constant deployer tx-sender)
(define-data-var renounced-uri-ownership bool false)

(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
	(begin
		(asserts! (is-eq tx-sender sender) err-not-token-owner)
		(try! (ft-transfer? peepeepoopoo amount sender recipient))
    (match memo memo-print (print memo-print) 0x)
    (ok true)
	)
)

(define-read-only (get-name)
	(ok "PeePeePooPoo")
)

(define-read-only (get-symbol)
	(ok "PPPP")
)

(define-read-only (get-decimals)
	(ok u6)
)

(define-read-only (get-balance (who principal))
	(ok (ft-get-balance peepeepoopoo who))
)

(define-read-only (get-total-supply)
	(ok (ft-get-supply peepeepoopoo))
)

(define-read-only (get-token-uri)
	(ok (var-get token-uri))
)

(define-public (set-token-uri (uri (string-utf8 256)))
  (begin
    (asserts!
      (and (not (var-get renounced-uri-ownership)) (is-eq tx-sender deployer))
      err-unauthorised)
    (ok (var-set token-uri (some uri)))
  )
)

(define-public (renounce-uri-ownership)
  (begin
    (asserts! (is-eq tx-sender deployer) err-unauthorised)
    (ok (var-set renounced-uri-ownership true))
  )
)

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
  (try! (ft-mint? peepeepoopoo u10000000000000000 deployer))
)
