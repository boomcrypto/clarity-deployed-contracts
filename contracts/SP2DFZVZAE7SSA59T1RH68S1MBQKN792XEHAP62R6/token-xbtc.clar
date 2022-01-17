(impl-trait .trait-ownable.ownable-trait)
(impl-trait .trait-sip-010.sip-010-trait)


(define-fungible-token xbtc)

(define-data-var token-uri (string-utf8 256) u"")
(define-data-var contract-owner principal tx-sender)
(define-map approved-contracts principal bool)

;; errors
(define-constant ERR-NOT-AUTHORIZED (err u1000))

(define-read-only (get-contract-owner)
  (ok (var-get contract-owner))
)

(define-public (set-contract-owner (owner principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED)
    (ok (var-set contract-owner owner))
  )
)

;; @desc check-is-approved
;; @restricted Contract-Owner
;; @params sender
;; @returns (response bool)
(define-private (check-is-approved (sender principal))
  (ok (asserts! (or (default-to false (map-get? approved-contracts sender)) (is-eq sender (var-get contract-owner))) ERR-NOT-AUTHORIZED))
)

(define-public (add-approved-contract (new-approved-contract principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED)
    (map-set approved-contracts new-approved-contract true)
    (ok true)
  )
)

;; ---------------------------------------------------------
;; SIP-10 Functions
;; ---------------------------------------------------------

;; @desc get-total-supply
;; @returns (response uint)
(define-read-only (get-total-supply)
  (ok (ft-get-supply xbtc))
)

;; @desc get-name
;; @returns (response string-utf8)
(define-read-only (get-name)
  (ok "xbtc")
)

;; @desc get-symbol
;; @returns (response string-utf8)
(define-read-only (get-symbol)
  (ok "xbtc")
)

;; @desc get-decimals
;; @returns (response uint)
(define-read-only (get-decimals)
   	(ok u8)
)

;; @desc get-balance
;; @params token-id
;; @params who
;; @returns (response uint)
(define-read-only (get-balance (account principal))
  (ok (ft-get-balance xbtc account))
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
;; @params token-id
;; @returns (response none)
(define-read-only (get-token-uri)
  (ok (some (var-get token-uri)))
)

;; @desc transfer
;; @restricted sender
;; @params token-id 
;; @params amount
;; @params sender
;; @params recipient
;; @returns (response boolean)
(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (begin
    (asserts! (is-eq sender tx-sender) ERR-NOT-AUTHORIZED)
    (match (ft-transfer? xbtc amount sender recipient)
      response (begin
        (print memo)
        (ok response)
      )
      error (err error)
    )
  )
)

;; @desc mint
;; @restricted ContractOwner/Approved Contract
;; @params token-id
;; @params amount
;; @params recipient
;; @returns (response boolean)
(define-public (mint (amount uint) (recipient principal))
  (begin
    (try! (check-is-approved tx-sender))
    (ft-mint? xbtc amount recipient)
  )
)

;; @desc burn
;; @restricted ContractOwner/Approved Contract
;; @params token-id
;; @params amount
;; @params sender
;; @returns (response boolean)
(define-public (burn (amount uint) (sender principal))
  (begin
    (try! (check-is-approved tx-sender))
    (ft-burn? xbtc amount sender)
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
  (ok (decimals-to-fixed (ft-get-supply xbtc)))
)

;; @desc get-balance-fixed
;; @params token-id
;; @params who
;; @returns (response uint)
(define-read-only (get-balance-fixed (account principal))
  (ok (decimals-to-fixed (ft-get-balance xbtc account)))
)

;; @desc transfer-fixed
;; @params token-id
;; @params amount
;; @params sender
;; @params recipient
;; @returns (response boolean)
(define-public (transfer-fixed (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (transfer (fixed-to-decimals amount) sender recipient memo)
)

;; @desc mint-fixed
;; @params token-id
;; @params amount
;; @params recipient
;; @returns (response boolean)
(define-public (mint-fixed (amount uint) (recipient principal))
  (mint (fixed-to-decimals amount) recipient)
)

;; @desc burn-fixed
;; @params token-id
;; @params amount
;; @params sender
;; @returns (response boolean)
(define-public (burn-fixed (amount uint) (sender principal))
  (burn (fixed-to-decimals amount) sender)
)

(map-set approved-contracts .faucet true)
