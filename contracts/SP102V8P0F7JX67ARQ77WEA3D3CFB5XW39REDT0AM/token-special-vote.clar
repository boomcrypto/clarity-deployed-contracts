(impl-trait .trait-sip-010.sip-010-trait)
(define-constant err-unauthorised (err u3000))
(define-constant err-transfer (err u4000))
(define-fungible-token special-vote)
(define-data-var token-name (string-ascii 32) "special-vote token")
(define-data-var token-symbol (string-ascii 32) "special-vote")
(define-data-var token-decimals uint u8)
(define-data-var token-uri (optional (string-utf8 256)) (some u"https://cdn.special-votelab.co/metadata/token-special-vote.json"))
(define-public (is-dao-or-extension)
	(ok (asserts! (or (is-eq tx-sender .executor-dao) (contract-call? .executor-dao is-extension contract-caller)) err-unauthorised))
)
(define-public (edg-transfer (amount uint) (sender principal) (recipient principal))
	err-transfer
)
(define-public (edg-mint (amount uint) (recipient principal))
	(begin		
		(try! (is-dao-or-extension))
		(ft-mint? special-vote amount recipient)
	)
)
(define-public (edg-burn (amount uint) (owner principal))
	(begin
		(try! (is-dao-or-extension))
		(ft-burn? special-vote amount owner)
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
(define-private (edg-mint-many-iter (item {amount: uint, recipient: principal}))
	(ft-mint? special-vote (get amount item) (get recipient item))
)
(define-public (edg-mint-many (recipients (list 200 {amount: uint, recipient: principal})))
	(begin
		(try! (is-dao-or-extension))
		(ok (map edg-mint-many-iter recipients))
	)
)
(define-private (edg-burn-many-iter (item {amount: uint, recipient: principal}))
	(ft-burn? special-vote (get amount item) (get recipient item))
)
(define-public (edg-burn-many (recipients (list 200 {amount: uint, recipient: principal})))
	(begin
		(try! (is-dao-or-extension))
		(ok (map edg-burn-many-iter recipients))
	)
)
(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
	err-transfer
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
	(ok (ft-get-balance special-vote who))
)
(define-read-only (get-total-supply)
	(ok (ft-get-supply special-vote))
)
(define-read-only (get-token-uri)
	(ok (var-get token-uri))
)
(define-read-only (edg-get-balance (who principal))
	(get-balance who)
)
(define-read-only (edg-has-percentage-balance (who principal) (factor uint))
	(ok (>= (* (unwrap-panic (get-balance who)) factor) (* (unwrap-panic (get-total-supply)) u1000)))
)
(define-public (callback (sender principal) (payload (buff 2048)))
	(ok true)
)
(define-constant ONE_8 (pow u10 u8))
(define-public (mint (amount uint) (recipient principal))
  (edg-mint amount recipient)
)
(define-public (burn (amount uint) (sender principal))
  (edg-burn amount sender)
)
(define-private (pow-decimals)
  (pow u10 (unwrap-panic (get-decimals)))
)
(define-read-only (fixed-to-decimals (amount uint))
  (/ (* amount (pow-decimals)) ONE_8)
)
(define-private (decimals-to-fixed (amount uint))
  (/ (* amount ONE_8) (pow-decimals))
)
(define-read-only (get-total-supply-fixed)
  (ok (decimals-to-fixed (unwrap-panic (get-total-supply))))
)
(define-read-only (get-balance-fixed (account principal))
  (ok (decimals-to-fixed (unwrap-panic (get-balance account))))
)
(define-public (transfer-fixed (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (transfer (fixed-to-decimals amount) sender recipient memo)
)
(define-public (mint-fixed (amount uint) (recipient principal))
  (mint (fixed-to-decimals amount) recipient)
)
(define-public (burn-fixed (amount uint) (sender principal))
  (burn (fixed-to-decimals amount) sender)
)