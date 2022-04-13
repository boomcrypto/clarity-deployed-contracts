(impl-trait 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.ft-trait.sip-010-trait)

(define-constant ERR-NOT-AUTHORIZED u401)
(define-constant ERR-INVALID-STAKE u104)
(define-constant ERR-NO-MORE-SLIMES u400)
(define-constant CONTRACT-OWNER tx-sender)

(define-data-var approved-principals (list 1000 principal) (list ))
(define-data-var shutoff-valve bool false)

;; Define SLIME with a maximum of 4,000,000 tokens / 1T microtokens.
(define-constant SLIME-CAP u4000000000000)
(define-fungible-token SLIME SLIME-CAP)

(define-public (collect (sender principal) (amount uint))
    (let (
        (supply (unwrap-panic (get-total-supply)))
    )
        (asserts! (is-some (index-of (var-get approved-principals) contract-caller)) (err ERR-NOT-AUTHORIZED))
        (asserts! (is-eq (var-get shutoff-valve) false) (err ERR-NOT-AUTHORIZED))
        (begin
            (try! (ft-mint? SLIME amount sender))
            (ok true)
        )
    )
)

;; Transfers tokens to a recipient
(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (if (is-eq tx-sender sender)
    (begin
      (try! (ft-transfer? SLIME amount sender recipient))
      (print memo)
      (ok true)
    )
    (err u4)))

(define-read-only (get-balance (owner principal))
    (ok (ft-get-balance SLIME owner))
)

(define-read-only (get-name)
    (ok "SLIME")
)

(define-read-only (get-symbol)
    (ok "SLM")
)

(define-read-only (get-decimals)
    (ok u6)
)

(define-read-only (get-total-supply)
    (ok (ft-get-supply SLIME))
)

(define-read-only (get-token-uri)
  (ok (some u"https://bitcoinmonkeys.io")))

(define-public (burn (burn-amount uint))
    (begin
        (try! (ft-burn? SLIME burn-amount tx-sender))
        (ok true)
    )
)

(define-public (admin-airdrop (address principal) (amount uint))
    (let (
        (supply (unwrap-panic (get-total-supply)))
    )   
        (asserts! (or (is-eq tx-sender CONTRACT-OWNER) (is-eq tx-sender 'ST3ZJP253DENMN3CQFEQSPZWY7DK35EH3SD98HKWK)) (err ERR-NOT-AUTHORIZED))
        (begin
            (try! (ft-mint? SLIME amount address))
            (ok true)
        )
    )
)

(define-public (principal-add (address principal))
  (if (is-eq tx-sender CONTRACT-OWNER)
    (ok (var-set approved-principals (unwrap-panic (as-max-len? (append (var-get approved-principals) address) u1000))))
    (err ERR-NOT-AUTHORIZED)
  )
)

(define-public (principal-change (addresses (list 1000 principal)))
  (if (is-eq tx-sender CONTRACT-OWNER)
    (ok (var-set approved-principals addresses))
    (err ERR-NOT-AUTHORIZED)
  )
)