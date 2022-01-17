(impl-trait .trait-ownable.ownable-trait)
(impl-trait .trait-sip-010.sip-010-trait)

(define-fungible-token wstx)

(define-data-var token-uri (string-utf8 256) u"")
(define-data-var contract-owner principal tx-sender)

;; errors
(define-constant ERR-NOT-AUTHORIZED (err u1000))
(define-constant ERR-MINT-FAILED (err u6002))
(define-constant ERR-BURN-FAILED (err u6003))

(define-read-only (get-contract-owner)
  (ok (var-get contract-owner))
)

(define-public (set-contract-owner (owner principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED)
    (ok (var-set contract-owner owner))
  )
)

;; ---------------------------------------------------------
;; SIP-10 Functions
;; ---------------------------------------------------------

;; @desc get-total-supply
;; @returns (response uint)
(define-read-only (get-total-supply)
  (ok u0)
)

;; @desc get-name
;; @returns (response string-utf8)
(define-read-only (get-name)
  (ok "wstx")
)

;; @desc get-symbol
;; @returns (response string-utf8)
(define-read-only (get-symbol)
  (ok "wstx")
)

;; @desc get-decimals
;; @returns (response uint)
(define-read-only (get-decimals)
  (ok u8)
)

;; @desc get-balance
;; @params account
;; @returns (response uint)
(define-read-only (get-balance (account principal))
  (ok (/ (* (stx-get-balance account) ONE_8) (pow u10 u6)))
)

;; @desc set-token-uri
;; @restricted Contract-Owner
;; @params value
;; @returns (response bool)
(define-public (set-token-uri (value (string-utf8 256)))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED)
    (ok (var-set token-uri value))
  )
)

;; @desc get-token-uri
;; @returns (response some string-utf-8)
(define-read-only (get-token-uri)
  (ok (some (var-get token-uri)))
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
    (match (stx-transfer? (/ (* amount (pow u10 u6)) ONE_8) sender recipient)
      response (begin
        (print memo)
        (ok response)
      )
      error (err error)
    )
  )
)

(define-constant ONE_8 (pow u10 u8))

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