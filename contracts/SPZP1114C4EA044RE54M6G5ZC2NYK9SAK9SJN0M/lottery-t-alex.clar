(impl-trait .trait-ownable.ownable-trait)
(impl-trait .trait-sip-010.sip-010-trait)


(define-fungible-token lottery-t-alex)

(define-data-var token-uri (string-utf8 256) u"")
(define-data-var contract-owner principal tx-sender)
(define-map approved-contracts principal bool)

;; errors
(define-constant ERR-NOT-AUTHORIZED (err u1000))
(define-constant ERR-TRANSFER-FAILED (err u3000))

(define-read-only (get-contract-owner)
  (ok (var-get contract-owner))
)

(define-public (set-contract-owner (owner principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED)
    (ok (var-set contract-owner owner))
  )
)

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

(define-read-only (get-total-supply)
  (ok (ft-get-supply lottery-t-alex))
)

(define-read-only (get-name)
  (ok "lottery-t-alex")
)

(define-read-only (get-symbol)
  (ok "lottery-t-alex")
)

(define-read-only (get-decimals)
  (ok u8)
)

(define-read-only (get-balance (account principal))
  (ok (ft-get-balance lottery-t-alex account))
)

(define-public (set-token-uri (value (string-utf8 256)))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED)
    (ok (var-set token-uri value))
  )
)

(define-read-only (get-token-uri)
  (ok (some (var-get token-uri)))
)

(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (begin
    (asserts! (is-eq sender tx-sender) ERR-NOT-AUTHORIZED)
    (match (ft-transfer? lottery-t-alex amount sender recipient)
      response (begin
        (print memo)
        (ok response)
      )
      error (err error)
    )
  )
)

(define-public (mint (amount uint) (recipient principal))
  (begin
    (try! (check-is-approved contract-caller))
    (ft-mint? lottery-t-alex amount recipient)
  )
)

(define-public (burn (amount uint) (sender principal))
  (begin
    (try! (check-is-approved contract-caller))
    (ft-burn? lottery-t-alex amount sender)
  )
)

(define-constant ONE_8 (pow u10 u8))

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
  (ok (decimals-to-fixed (ft-get-supply lottery-t-alex)))
)

(define-read-only (get-balance-fixed (account principal))
  (ok (decimals-to-fixed (ft-get-balance lottery-t-alex account)))
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

;; @desc mint-from-tuple
;; @params recipient; tuple
;; returns (response bool uint)
(define-private (mint-from-tuple (recipient { to: principal, amount: uint }))
  (ok (unwrap! (mint-fixed (get amount recipient) (get to recipient)) ERR-TRANSFER-FAILED))
)

(define-private (transfer-from-tuple (recipient { to: principal, amount: uint }))
  (ok (unwrap! (transfer-fixed (get amount recipient) tx-sender (get to recipient) none) ERR-TRANSFER-FAILED))
)

;; @desc mint-many
;; @params recipient; list of tuple
;; returns (bool uint)
(define-public (mint-many (recipients (list 200 { to: principal, amount: uint })))
  (begin
    (try! (check-is-approved tx-sender))
    (fold check-err (map mint-from-tuple recipients) (ok true))
  )
)

(define-public (send-many (recipients (list 200 { to: principal, amount: uint})))
  (begin
    (try! (check-is-approved tx-sender))
    (fold check-err (map transfer-from-tuple recipients) (ok true))
  )
)

(map-set approved-contracts .alex-launchpad true)