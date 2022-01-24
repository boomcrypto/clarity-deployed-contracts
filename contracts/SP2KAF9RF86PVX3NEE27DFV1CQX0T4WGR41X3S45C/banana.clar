(impl-trait .ft-trait.sip-010-trait)

(define-constant ERR-NOT-AUTHORIZED u401)
(define-constant ERR-INVALID-STAKE u104)
(define-constant CONTRACT-OWNER tx-sender)

(define-data-var contract principal 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.bitcoin-monkeys-staking)
(define-data-var shutoff-valve bool false)

;; Define BANANA with a maximum of 1,000,000 tokens / 1T microtokens.
(define-fungible-token BANANA u1000000000000)

(define-public (harvest-bananas (sender principal) (blocks uint))
    (let (
        (contract-name (var-get contract))
    )
        (asserts! (is-eq tx-sender contract-name) (err ERR-NOT-AUTHORIZED))
        (asserts! (is-eq (var-get shutoff-valve) false) (err ERR-NOT-AUTHORIZED))
        (begin
            (try! (ft-mint? BANANA blocks sender))
            (ok true)
        )
    )
)

;; Transfers tokens to a recipient
(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (if (is-eq tx-sender sender)
    (begin
      (try! (ft-transfer? BANANA amount sender recipient))
      (print memo)
      (ok true)
    )
    (err u4)))

(define-public (get-balance (owner principal))
    (ok (ft-get-balance BANANA owner))
)

(define-public (get-name)
    (ok "BANANA")
)

(define-public (get-symbol)
    (ok "BAN")
)

(define-public (get-decimals)
    (ok u6)
)

(define-public (get-total-supply)
    (ok (ft-get-supply BANANA))
)

(define-public (get-token-uri)
  (ok (some u"https://bitcoinmonkeys.io")))

(define-public (burn (burn-amount uint))
    (begin
        (try! (ft-burn? BANANA burn-amount tx-sender))
        (ok true)
    )
)