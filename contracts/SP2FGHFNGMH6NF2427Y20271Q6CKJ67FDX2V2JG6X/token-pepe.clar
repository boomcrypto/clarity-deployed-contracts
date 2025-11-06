(impl-trait 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.trait-sip-010.sip-010-trait)

(define-constant ERR-NOT-AUTHORIZED (err u1000))

(define-fungible-token token-pepe)

(define-data-var token-name (string-ascii 32) "PEPE the Frog")
(define-data-var token-symbol (string-ascii 10) "PEPE")
(define-data-var token-uri (optional (string-utf8 256)) (some u"https://cdn.brotocol.xyz/metadata/token-pepe.json"))

(define-data-var token-decimals uint u8)

;; --- Authorisation check

(define-read-only (is-dao-or-extension)
	(ok (asserts!
		(or (is-eq tx-sender 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.executor-dao) (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.executor-dao
			is-extension contract-caller
		))
		ERR-NOT-AUTHORIZED
	))
)

;; Other

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

;; --- Public functions

;; sip010-ft-trait

(define-public (transfer
		(amount uint)
		(sender principal)
		(recipient principal)
		(memo (optional (buff 34)))
	)
	(begin
		(asserts! (is-eq sender tx-sender) ERR-NOT-AUTHORIZED)
		(try! (ft-transfer? token-pepe amount sender recipient))
		(match memo
			to-print (print to-print)
			0x
		)
		(ok true)
	)
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
	(ok (ft-get-balance token-pepe who))
)

(define-read-only (get-total-supply)
	(ok (ft-get-supply token-pepe))
)

(define-read-only (get-token-uri)
	(ok (var-get token-uri))
)

;; --- Protocol functions

(define-constant ONE_8 u100000000)

;; @desc mint
;; @restricted ContractOwner/Approved Contract
;; @params token-id
;; @params amount
;; @params recipient
;; @returns (response bool)
(define-public (mint
		(amount uint)
		(recipient principal)
	)
	(begin
		(try! (is-dao-or-extension))
		(ft-mint? token-pepe amount recipient)
	)
)

;; @desc burn
;; @restricted ContractOwner/Approved Contract
;; @params token-id
;; @params amount
;; @params sender
;; @returns (response bool)
(define-public (burn
		(amount uint)
		(sender principal)
	)
	(begin
		(try! (is-dao-or-extension))
		(ft-burn? token-pepe amount sender)
	)
)

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
	(ok (decimals-to-fixed (unwrap-panic (get-total-supply))))
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
(define-public (transfer-fixed
		(amount uint)
		(sender principal)
		(recipient principal)
		(memo (optional (buff 34)))
	)
	(transfer (fixed-to-decimals amount) sender recipient memo)
)

;; @desc mint-fixed
;; @params token-id
;; @params amount
;; @params recipient
;; @returns (response bool)
(define-public (mint-fixed
		(amount uint)
		(recipient principal)
	)
	(mint (fixed-to-decimals amount) recipient)
)

;; @desc burn-fixed
;; @params token-id
;; @params amount
;; @params sender
;; @returns (response bool)
(define-public (burn-fixed
		(amount uint)
		(sender principal)
	)
	(burn (fixed-to-decimals amount) sender)
)

(define-private (burn-fixed-many-iter (item {
	amount: uint,
	sender: principal,
}))
	(burn-fixed (get amount item) (get sender item))
)

(define-public (burn-fixed-many (senders (list 200 {
	amount: uint,
	sender: principal,
})))
	(begin
		(try! (is-dao-or-extension))
		(ok (map burn-fixed-many-iter senders))
	)
)
