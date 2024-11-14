(define-constant err-not-authorized (err u5000))

(define-constant success (ok true))

(impl-trait .ft-trait.ft-trait)
(define-fungible-token token-btcz)
(define-data-var contract-owner principal tx-sender)
(define-map approved-contracts principal bool)
(define-constant token-name "BTCz")
(define-constant token-symbol "BTCz")
(define-constant token-decimals u12)
(define-data-var token-uri (optional (string-utf8 256)) (some u""))

;; token data
(define-read-only (get-name)
	(ok token-name))

(define-read-only (get-symbol)
	(ok token-symbol))

(define-read-only (get-decimals)
	(ok token-decimals))

(define-read-only (get-token-uri)
	(ok (var-get token-uri)))

(define-read-only (get-balance (who principal))
	(ok (ft-get-balance token-btcz who)))

(define-read-only (get-total-supply)
	(ok (ft-get-supply token-btcz)))

(define-public (set-token-uri (new-uri (optional (string-utf8 256))))
	(begin
		(try! (check-is-owner))
		(print { action: "set-token-uri", data: { new-uri: new-uri } })
		(ok (var-set token-uri new-uri))))

;; permission data
(define-read-only (get-contract-owner)
	(ok (var-get contract-owner)))

(define-private (check-is-owner)
	(ok (asserts! (is-eq contract-caller (var-get contract-owner)) err-not-authorized)))

(define-private (check-is-approved)
	(ok (asserts! (default-to false (map-get? approved-contracts contract-caller)) err-not-authorized)))

;; permission data setter
(define-public (set-contract-owner (owner principal))
	(begin
		(try! (check-is-owner))
		(print { action: "set-contract-owner", data: { owner: owner } })
		(ok (var-set contract-owner owner))))

(define-public (set-approved-contract (owner principal) (approved bool))
	(begin
		(try! (check-is-owner))
		(print { action: "set-approved-contract", data: { owner: owner, approved: approved } })
		(ok (map-set approved-contracts owner approved))))

;; token actions
(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
	(begin
		(asserts! (is-eq sender tx-sender) err-not-authorized)
		(try! (ft-transfer? token-btcz amount sender recipient))
		(match memo to-print (print to-print) 0x)
		success))

(define-public (mint (amount uint) (recipient principal))
	(begin
		(asserts! (is-ok (check-is-approved)) err-not-authorized)
		(ft-mint? token-btcz amount recipient)))

(define-public (burn (amount uint) (sender principal))
	(begin
		(asserts! (is-ok (check-is-approved)) err-not-authorized)
		(ft-burn? token-btcz amount sender)))
