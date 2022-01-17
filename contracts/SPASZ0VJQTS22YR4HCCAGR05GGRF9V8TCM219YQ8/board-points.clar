(impl-trait .sip-010-trait.sip-010-trait)
(impl-trait .board-main-ft-trait.board-main-ft-trait)

(define-fungible-token points)

;; variables
(define-data-var token-uri (string-utf8 256) u"")
(define-data-var contract-owner principal tx-sender)

;; constants
(define-constant ERR-NOT-AUTHORIZED (err u404))

;;
;; SIP-010 
;; 

(define-read-only (get-total-supply)
  (ok (ft-get-supply points))
)

(define-read-only (get-name)
  (ok "points")
)

(define-read-only (get-symbol)
  (ok "PNT")
)

(define-read-only (get-decimals)
  (ok u6)
)

(define-read-only (get-balance (account principal))
  (ok (ft-get-balance points account))
)

(define-public (set-token-uri (value (string-utf8 256)))
  (if (is-eq tx-sender (var-get contract-owner))
    (ok (var-set token-uri value))
    ERR-NOT-AUTHORIZED
  )
)

(define-read-only (get-token-uri)
  (ok (some (var-get token-uri)))
)

(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (begin
    (asserts! (is-eq tx-sender sender) ERR-NOT-AUTHORIZED)
    (match (ft-transfer? points amount sender recipient)
      response (begin
        (print memo)
        (ok response)
      )
      error (err error)
    )
  )
)

;; 
;; Admin
;; 

(define-public (set-contract-owner (address principal))
  (begin
    (asserts! (is-eq (var-get contract-owner) tx-sender) ERR-NOT-AUTHORIZED)
    (var-set contract-owner address)
    (ok true)
  )
)

;; 
;; Mint / Burn
;; 

(define-public (main-mint (amount uint) (recipient principal))
  (begin
    (asserts! (is-eq contract-caller .board-main) ERR-NOT-AUTHORIZED)
    (ft-mint? points amount recipient)
  )
)

(define-public (main-burn (amount uint) (sender principal))
  (begin
    (asserts! (is-eq contract-caller .board-main) ERR-NOT-AUTHORIZED)
    (ft-burn? points amount sender)
  )
)

(define-public (user-burn (amount uint))
  (begin
    (ft-burn? points amount tx-sender)
  )
)

