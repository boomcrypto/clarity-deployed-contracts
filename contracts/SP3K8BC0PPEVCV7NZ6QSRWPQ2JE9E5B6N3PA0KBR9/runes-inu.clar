(define-constant ERR-NOT-AUTHORIZED (err u1000))
(define-constant ONE_8 u100000000)
(define-fungible-token runes-inu)
(define-data-var contract-owner principal tx-sender)
(define-data-var token-name (string-ascii 32) "SATOSHI NAKAMOTO INU (RUNES)")
(define-data-var token-symbol (string-ascii 32) "INU")
(define-data-var token-uri (optional (string-utf8 256)) (some u"https://cdn.alexlab.co/metadata/runes-inu.json"))
(define-data-var token-decimals uint u8)
(define-map approved-contracts principal bool)
(define-read-only (get-contract-owner)
  (ok (var-get contract-owner))
)
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
	(ok (ft-get-balance runes-inu who))
)
(define-read-only (get-total-supply)
	(ok (ft-get-supply runes-inu))
)
(define-read-only (get-token-uri)
	(ok (var-get token-uri))
)
(define-read-only (fixed-to-decimals (amount uint))
  (/ (* amount (pow-decimals)) ONE_8)
)
(define-read-only (get-total-supply-fixed)
  (ok (decimals-to-fixed (unwrap-panic (get-total-supply))))
)
(define-read-only (get-balance-fixed (account principal))
  (ok (decimals-to-fixed (unwrap-panic (get-balance account))))
)
(define-public (set-contract-owner (owner principal))
  (begin
    (try! (check-is-owner))
    (ok (var-set contract-owner owner))
  )
)
(define-public (set-name (new-name (string-ascii 32)))
	(begin
		(try! (check-is-owner))
		(ok (var-set token-name new-name))
	)
)
(define-public (set-symbol (new-symbol (string-ascii 10)))
	(begin
		(try! (check-is-owner))
		(ok (var-set token-symbol new-symbol))
	)
)
(define-public (set-decimals (new-decimals uint))
	(begin
		(try! (check-is-owner))
		(ok (var-set token-decimals new-decimals))
	)
)
(define-public (set-token-uri (new-uri (optional (string-utf8 256))))
	(begin
		(try! (check-is-owner))
		(ok (var-set token-uri new-uri))
	)
)
(define-public (add-approved-contract (new-approved-contract principal))
	(begin
		(try! (check-is-owner))
		(ok (map-set approved-contracts new-approved-contract true))
	)
)
(define-public (set-approved-contract (owner principal) (approved bool))
	(begin
		(try! (check-is-owner))
		(ok (map-set approved-contracts owner approved))
	)
)
(define-public (mint (amount uint) (recipient principal))
	(begin		
		(asserts! (or (is-ok (check-is-approved)) (is-ok (check-is-owner))) ERR-NOT-AUTHORIZED)
		(ft-mint? runes-inu amount recipient)
	)
)
(define-public (burn (amount uint) (sender principal))
	(begin
		(asserts! (or (is-ok (check-is-approved)) (is-ok (check-is-owner))) ERR-NOT-AUTHORIZED)
		(ft-burn? runes-inu amount sender)
	)
)
(define-public (mint-fixed (amount uint) (recipient principal))
  (mint (fixed-to-decimals amount) recipient)
)
(define-public (burn-fixed (amount uint) (sender principal))
  (burn (fixed-to-decimals amount) sender)
)
(define-public (mint-fixed-many (recipients (list 200 { amount: uint, to: principal})))
	(fold mint-many-iter recipients (ok true))
)
(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
    (begin
        (asserts! (is-eq sender tx-sender) ERR-NOT-AUTHORIZED)
        (try! (ft-transfer? runes-inu amount sender recipient))
        (match memo to-print (print to-print) 0x)
        (ok true)
    )
)
(define-public (transfer-fixed (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (transfer (fixed-to-decimals amount) sender recipient memo)
)
(define-public (transfer-fixed-many (recipients (list 200 { amount: uint, to: principal})))
	(fold transfer-many-iter recipients (ok true))
)
(define-private (check-is-owner)
  (ok (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED))
)
(define-private (check-is-approved)
  (ok (asserts! (default-to false (map-get? approved-contracts tx-sender)) ERR-NOT-AUTHORIZED))
)
(define-private (decimals-to-fixed (amount uint))
  (/ (* amount ONE_8) (pow-decimals))
)
(define-private (pow-decimals)
  (pow u10 (unwrap-panic (get-decimals)))
)
(define-private (mint-many-iter (recipient { amount: uint, to: principal }) (previous-response (response bool uint)))
	(match previous-response prev-ok (mint-fixed (get amount recipient) (get to recipient)) prev-err previous-response)
)
(define-private (transfer-many-iter (recipient { amount: uint, to: principal }) (previous-response (response bool uint)))
	(match previous-response prev-ok (transfer-fixed (get amount recipient) tx-sender (get to recipient) none) prev-err previous-response)
)
(contract-call? .alex-vault-v1-1 set-approved-token .runes-inu true)