;; Experience

(impl-trait .dao-traits-v2.sip010-ft-trait)
(impl-trait .dao-traits-v2.extension-trait)

(define-constant err-unauthorized (err u401))
(define-constant err-not-token-owner (err u4))

(define-fungible-token experience)

(define-data-var token-name (string-ascii 32) "Experience")
(define-data-var token-symbol (string-ascii 10) "EXP")
(define-data-var token-uri (optional (string-utf8 256)) (some u"https://charisma.rocks/experience.json"))
(define-data-var token-decimals uint u6)

;; --- Authorization check

(define-public (is-dao-or-extension)
	(ok (asserts! (or (is-eq tx-sender 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master) (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master is-extension contract-caller)) err-unauthorized))
)

;; --- Internal DAO functions

(define-public (mint (amount uint) (recipient principal))
	(begin
		(try! (is-dao-or-extension))
		(ft-mint? experience amount recipient)
	)
)

(define-public (burn (amount uint) (owner principal))
	(begin
		(try! (is-dao-or-extension))
		(ft-burn? experience amount owner)
	)
)

(define-public (set-name (new-name (string-ascii 32)))
	(begin
		(try! (is-dao-or-extension))
		(ok (var-set token-name new-name))
	)
)

(define-public (set-symbol (new-symbol (string-ascii 10)))
	(begin
		(try! (is-dao-or-extension))
		(ok (var-set token-symbol new-symbol))
	)
)

(define-public (set-decimals (new-decimals uint))
	(begin
		(try! (is-dao-or-extension))
		(ok (var-set token-decimals new-decimals))
	)
)

(define-public (set-token-uri (new-uri (optional (string-utf8 256))))
	(begin
		(try! (is-dao-or-extension))
		(ok (var-set token-uri new-uri))
	)
)

(define-private (mint-many-iter (item {amount: uint, recipient: principal}))
	(ft-mint? experience (get amount item) (get recipient item))
)

(define-public (mint-many (recipients (list 200 {amount: uint, recipient: principal})))
	(begin
		(try! (is-dao-or-extension))
		(ok (map mint-many-iter recipients))
	)
)

(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
	(begin
		(try! (is-dao-or-extension))
		(asserts! (or (is-eq tx-sender sender) (is-eq contract-caller sender)) err-not-token-owner)
		(ft-transfer? experience amount sender recipient)
	)
)

;; --- Public functions

(define-read-only (get-name)
	(ok (var-get token-name))
)

(define-read-only (get-symbol)
	(ok (var-get token-symbol))
)

(define-read-only (get-decimals)
	(ok (var-get token-decimals))
)

(define-read-only (get-balance (who principal))
	(ok (ft-get-balance experience who))
)

(define-read-only (get-total-supply)
	(ok (ft-get-supply experience))
)

(define-read-only (get-token-uri)
	(ok (var-get token-uri))
)

;; --- Utility functions

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

(define-read-only (has-percentage-balance (who principal) (factor uint))
	(ok (>= (* (unwrap-panic (get-balance who)) factor) (* (unwrap-panic (get-total-supply)) u1000)))
)

;; --- Extension callback

(define-public (callback (sender principal) (memo (buff 34)))
	(ok true)
)
