(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

;; ---- Constants ----
(define-constant CONTRACT_OWNER 'SP1T0VY3DNXRVP6HBM75DFWW0199CR0X15PC1D81B)
(define-constant TOKEN_NAME "The MAS Network")
(define-constant TOKEN_SYMBOL "MAS")
(define-constant TOKEN_DECIMALS u8)
(define-constant MAX_SUPPLY u2100000000000000) ;; 21 million * 10^8
(define-constant DEX_CONTRACT 'SP1T0VY3DNXRVP6HBM75DFWW0199CR0X15PC1D81B.mas-sats-treasury)

;; ---- Errors ----
(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_ALREADY_MINTED (err u101))
(define-constant ERR_INVALID_AMOUNT (err u102))
(define-constant ERR_NOTHING_TO_UNLOCK (err u103))
(define-constant ERR_NOT_MAJORITY (err u104))
(define-constant ERR_NO_MAJORITY_HOLDER (err u105))

;; ---- Token Definition ----
(define-fungible-token mas-sats MAX_SUPPLY)

;; ---- Metadata + Mint State ----
(define-data-var token-uri (optional (string-utf8 256)) none)
(define-data-var minted bool false)

;; ---- Token Locking System ----
(define-map locked-balances { user: principal } { amount: uint })
(define-data-var total-locked uint u0)
(define-data-var majority-holder (optional principal) none)

;; ---- SIP-010 Read-Only Functions ----
(define-read-only (get-balance (who principal))
  (ok (ft-get-balance mas-sats who))
)

(define-read-only (get-total-supply)
  (ok (ft-get-supply mas-sats))
)

(define-read-only (get-name)
  (ok TOKEN_NAME)
)

(define-read-only (get-symbol)
  (ok TOKEN_SYMBOL)
)

(define-read-only (get-decimals)
  (ok TOKEN_DECIMALS)
)

(define-read-only (get-token-uri)
  (ok (var-get token-uri))
)

;; ---- SIP-010 Transfer Function ----
(define-public (transfer (amount uint) (from principal) (to principal) (memo (optional (buff 34))))
  (begin
    (asserts! (is-eq from tx-sender) ERR_UNAUTHORIZED)
    (ft-transfer? mas-sats amount from to)
  )
)

;; ---- Send Many Function for Airdrops ----
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

;; ---- Optional Metadata Setter (Majority Holder Only) ----
(define-public (set-token-uri (value (string-utf8 256)))
  (begin
    (asserts! (is-eq (var-get majority-holder) (some tx-sender)) ERR_UNAUTHORIZED)
    (var-set token-uri (some value))
    (ok true)
  )
)

;; ---- One-Time Mint to DEX Contract ----
(define-public (mint-entire-supply-to-dex)
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (asserts! (is-eq (var-get minted) false) ERR_ALREADY_MINTED)
    (try! (ft-mint? mas-sats MAX_SUPPLY DEX_CONTRACT))
    (var-set minted true)
    (ok true)
  )
)

;; ---- Token Locking System ----

(define-public (lock-tokens (amount uint))
  (begin
    (asserts! (> amount u0) ERR_INVALID_AMOUNT)
    (try! (ft-transfer? mas-sats amount tx-sender (as-contract tx-sender)))
    (let ((currently-locked (default-to u0 (get amount (map-get? locked-balances { user: tx-sender })))))
      (map-set locked-balances { user: tx-sender } { amount: (+ currently-locked amount) })
      (var-set total-locked (+ (var-get total-locked) amount))
    )
    (ok true)
  )
)

(define-public (unlock-tokens (amount uint))
  (let ((locked (default-to u0 (get amount (map-get? locked-balances { user: tx-sender })))))
    (begin
      (asserts! (> amount u0) ERR_INVALID_AMOUNT)
      (asserts! (>= locked amount) ERR_NOTHING_TO_UNLOCK)
      (try! (ft-transfer? mas-sats amount (as-contract tx-sender) tx-sender))
      (map-set locked-balances { user: tx-sender } { amount: (- locked amount) })
      (var-set total-locked (- (var-get total-locked) amount))
      (ok true)
    )
  )
)

(define-public (claim-majority-holder-status)
  (let (
    (user-locked (default-to u0 (get amount (map-get? locked-balances { user: tx-sender }))))
    (total (var-get total-locked))
  )
    (begin
      (asserts! (> total u0) ERR_NOTHING_TO_UNLOCK)
      (if (> (* user-locked u100) (/ (* total u100) u2))
        (begin
          (var-set majority-holder (some tx-sender))
          (ok true)
        )
        ERR_NOT_MAJORITY
      )
    )
  )
)

;; ---- Read-Only Functions for Locking System ----

(define-read-only (get-locked-balance (user principal))
  (ok (default-to u0 (get amount (map-get? locked-balances { user: user }))))
)

(define-read-only (get-total-locked)
  (ok (var-get total-locked))
)

(define-read-only (get-majority-holder)
  (ok (var-get majority-holder))
)