(impl-trait .trait-ownable.ownable-trait)
(impl-trait .trait-sip-010.sip-010-trait)
(impl-trait .trait-ido-ft.ido-ft-trait)

(define-fungible-token wban)

(define-data-var token-name (string-ascii 32) "Wrapped Banana")
(define-data-var token-symbol (string-ascii 10) "WBAN")
(define-data-var token-uri (optional (string-utf8 256)) (some u"https://cdn.alexlab.co/metadata/token-wban.json"))

(define-data-var token-decimals uint u8)

(define-data-var contract-owner principal tx-sender)

;; errors
(define-constant ERR-NOT-AUTHORIZED (err u1000))
(define-constant ERR-MINT-FAILED (err u6002))
(define-constant ERR-BURN-FAILED (err u6003))
(define-constant ERR-TRANSFER-FAILED (err u3000))
(define-constant ERR-NOT-SUPPORTED (err u6004))

(define-read-only (get-contract-owner)
  (ok (var-get contract-owner))
)

(define-public (set-contract-owner (owner principal))
  (begin
    (try! (check-is-owner))
    (ok (var-set contract-owner owner))
  )
)

(define-private (check-is-owner)
  (ok (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED))
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

;; ---------------------------------------------------------
;; SIP-10 Functions
;; ---------------------------------------------------------

;; @desc get-total-supply
;; @returns (response uint)
(define-read-only (get-total-supply)
  ;; least authority Issue D
  ERR-NOT-SUPPORTED
)

;; @desc get-name
;; @returns (response string-utf8)
(define-read-only (get-name)
  (ok (var-get token-name))
)

;; @desc get-symbol
;; @returns (response string-utf8)
(define-read-only (get-symbol)
  (ok (var-get token-symbol))
)

;; @desc get-decimals
;; @returns (response uint)
(define-read-only (get-decimals)
  (ok (var-get token-decimals))
)

;; @desc get-balance
;; @params account
;; @returns (response uint)
(define-read-only (get-balance (account principal))
  (ok (/ (* (unwrap-panic (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.btc-monkeys-bananas get-balance account)) (pow-decimals)) (pow u10 u6)))
)

;; @desc get-token-uri
;; @returns (response some string-utf-8)
(define-read-only (get-token-uri)
  (ok (var-get token-uri))
)

;; @desc transfer
;; @restricted sender; tx-sender should be sender
;; @params amount
;; @params sender
;; @params recipient
;; @params memo; expiry
;; @returns (response bool uint)/ error
(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (begin
    (asserts! (is-eq sender tx-sender) ERR-NOT-AUTHORIZED)
    (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.btc-monkeys-bananas transfer (/ (* amount (pow u10 u6)) (pow-decimals)) sender recipient memo)
  )
)

(define-constant ONE_8 u100000000)

;; @desc pow-decimals
;; @returns uint
(define-private (pow-decimals)
  (pow u10 (unwrap-panic (get-decimals)))
)

;; @desc fixed-to-decimals
;; @params amount
;; @returns uint
(define-read-only (fixed-to-decimals (amount uint))
  (/ (* amount (pow-decimals)) ONE_8)
)

;; @desc decimals-to-fixed 
;; @params amount
;; @returns uint
(define-private (decimals-to-fixed (amount uint))
  (/ (* amount ONE_8) (pow-decimals))
)

;; @desc get-total-supply-fixed
;; @params token-id
;; @returns (response uint)
(define-read-only (get-total-supply-fixed)
  ;; least authority Issue D
  ERR-NOT-SUPPORTED
)

;; @desc get-balance-fixed
;; @params token-id
;; @params who
;; @returns (response uint)
(define-read-only (get-balance-fixed (account principal))
  (ok (decimals-to-fixed (unwrap-panic (get-balance account))))
)

;; @desc transfer-fixed
;; @params token-id
;; @params amount
;; @params sender
;; @params recipient
;; @returns (response bool)
(define-public (transfer-fixed (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (transfer (fixed-to-decimals amount) sender recipient memo)
)

(define-public (mint (amount uint) (recipient principal))
  ERR-MINT-FAILED
)

(define-public (burn (amount uint) (sender principal))
  ERR-BURN-FAILED
)

(define-public (mint-fixed (amount uint) (recipient principal))
  (mint (fixed-to-decimals amount) recipient)
)

;; @desc burn-fixed
;; @params token-id
;; @params amount
;; @params sender
;; @returns (response bool)
(define-public (burn-fixed (amount uint) (sender principal))
  (burn (fixed-to-decimals amount) sender)
)

;; @desc check-err
;; @params result 
;; @params prior
;; @returns (response bool uint)
(define-private (check-err (result (response bool uint)) (prior (response bool uint)))
    (match prior 
        ok-value result
        err-value (err err-value)
    )
)

(define-private (transfer-from-tuple (recipient { to: principal, amount: uint }))
  (ok (unwrap! (transfer-fixed (get amount recipient) tx-sender (get to recipient) none) ERR-TRANSFER-FAILED))
)

(define-public (send-many (recipients (list 200 { to: principal, amount: uint})))
  (fold check-err (map transfer-from-tuple recipients) (ok true))
)

(define-private (transfer-many-ido-iter (recipient principal) (params {amount: uint, result: (response bool uint)}))
	(begin
		(unwrap! (get result params) params)
		{amount: (get amount params), result: (transfer-fixed (get amount params) contract-caller recipient none)}
	)
)

(define-public (transfer-many-ido (amount uint) (recipients (list 200 principal)))
	(get result (fold transfer-many-ido-iter recipients {amount: amount, result: (ok true)}))
)

(define-private (transfer-many-amounts-ido-iter (item {recipient: principal, amount: uint}) (result (response bool uint)))
	(begin
		(try! result)
		(transfer-fixed (get amount item) contract-caller (get recipient item) none)
	)
)

(define-public (transfer-many-amounts-ido (recipients (list 200 {recipient: principal, amount: uint})))
	(fold transfer-many-amounts-ido-iter recipients (ok true))
)


;; contract initialisation
(set-contract-owner .executor-dao)