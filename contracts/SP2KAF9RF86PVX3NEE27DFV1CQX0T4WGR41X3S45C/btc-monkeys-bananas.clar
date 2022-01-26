(impl-trait .ft-trait.sip-010-trait)

(define-constant ERR-NOT-AUTHORIZED u401)
(define-constant ERR-INVALID-STAKE u104)
(define-constant ERR-NO-MORE-BANANAS u400)
(define-constant CONTRACT-OWNER tx-sender)

(define-data-var contract principal 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.btc-monkeys-staking)
(define-data-var shutoff-valve bool false)

;; Define BANANA with a maximum of 1,000,000 tokens / 1T microtokens.
(define-constant BANANA-CAP u1000000000000)
(define-fungible-token BANANA BANANA-CAP)

(define-public (harvest-bananas (sender principal) (blocks uint))
    (let (
        (contract-name (var-get contract))
        (supply (unwrap-panic (get-total-supply)))
    )
        (print (+ supply blocks))
        (asserts! (is-eq (<= (+ supply blocks) BANANA-CAP)) (err ERR-NO-MORE-BANANAS))
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

(define-read-only (get-balance (owner principal))
    (ok (ft-get-balance BANANA owner))
)

(define-read-only (get-name)
    (ok "BANANA")
)

(define-read-only (get-symbol)
    (ok "BAN")
)

(define-read-only (get-decimals)
    (ok u6)
)

(define-read-only (get-total-supply)
    (ok (ft-get-supply BANANA))
)

(define-read-only (get-token-uri)
  (ok (some u"https://bitcoinmonkeys.io")))

(define-public (burn (burn-amount uint))
    (begin
        (try! (ft-burn? BANANA burn-amount tx-sender))
        (ok true)
    )
)

(define-public (admin-airdrop (address principal) (amount uint))
    (let (
        (supply (unwrap-panic (get-total-supply)))
    )   
        (print (+ supply amount))
        (asserts! (is-eq (<= (+ supply amount) BANANA-CAP)) (err ERR-NO-MORE-BANANAS))
        (asserts! (or (is-eq tx-sender CONTRACT-OWNER) (is-eq tx-sender 'SP3B6T2P3C0XEH4RRFP9A4N1RAEWFNNVYFDHE538Y)) (err ERR-NOT-AUTHORIZED))
        (begin
            (try! (ft-mint? BANANA amount address))
            (ok true)
        )
    )
)

(define-public (contract-change (address principal))
  (if (is-eq tx-sender CONTRACT-OWNER)
    (ok (var-set contract address))
    (err ERR-NOT-AUTHORIZED)
  )
)

(begin
    (try! (ft-mint? BANANA u100000000000 'SP3B6T2P3C0XEH4RRFP9A4N1RAEWFNNVYFDHE538Y))
    (ok true)
)