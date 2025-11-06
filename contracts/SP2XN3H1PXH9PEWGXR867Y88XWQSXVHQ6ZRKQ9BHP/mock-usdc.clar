(impl-trait .trait-sip-010.sip-010-trait)

(define-fungible-token mock-usdc)

;; ---------------------------------------------------------
;; SIP-10 Functions
;; ---------------------------------------------------------

;; @desc get-total-supply
;; @returns (response uint)
(define-read-only (get-total-supply)
    (ok (ft-get-supply mock-usdc))
)

;; @desc get-name
;; @returns (response string-utf8)
(define-read-only (get-name)
    (ok "mock-usdc")
)

;; @desc get-symbol
;; @returns (response string-utf8)
(define-read-only (get-symbol)
    (ok "mock-usdc")
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
    (ok (ft-get-balance mock-usdc account))
)

;; @desc get-token-uri
;; @params token-id
;; @returns (response none)
(define-read-only (get-token-uri)
    (ok (some u""))
)

;; @desc transfer
;; @restricted sender
;; @params token-id
;; @params amount
;; @params sender
;; @params recipient
;; @returns (response boolean)
(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
    (if (is-eq tx-sender sender)
        (begin
            (try! (ft-transfer? mock-usdc amount sender recipient))
            (print memo)
            (ok true)
        )
        (err u4)
    )
)

;; @desc mint
;; @params token-id
;; @params amount
;; @params recipient
;; @returns (response boolean)
(define-public (mint (amount uint) (recipient principal))
    (ft-mint? mock-usdc amount recipient)
)

;; @desc burn
;; @params token-id
;; @params amount
;; @params sender
;; @returns (response boolean)
(define-public (burn (amount uint) (sender principal))
    (ft-burn? mock-usdc amount sender)
)
