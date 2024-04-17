
;; title: Unity Hub token
;; version: 0.0.0
;; description: Token launched by the Stacks Unity Hub Community

(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(define-fungible-token unity-hub SUPPLY)

(define-constant MAX-MINT u10000)
(define-constant SUPPLY u111000000)

(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
    (begin
        (asserts! (is-eq tx-sender sender) (err u1001))
        (asserts! (>= (ft-get-balance unity-hub sender) amount) (err u1002))
        (asserts! (not (is-eq sender recipient)) (err u1003))
        (match memo to-print (print to-print) 0x)
        (ft-transfer? unity-hub amount sender recipient))
)

(define-public (burn (amount uint))
    (begin
        (asserts! (is-eq contract-caller tx-sender) (err u1004))
        (asserts!  (>= (ft-get-balance unity-hub tx-sender) amount) (err u1002))
        (ft-burn? unity-hub amount tx-sender)
    ))

(define-public (mint (amount uint))
    (begin
        (asserts! (is-eq contract-caller tx-sender) (err u1004))
        ;; if yer a kentrekt then ye kant ment
        (asserts! (is-none (get name (unwrap-panic (principal-destruct? tx-sender)))) (err u1005))
        (asserts! (<= (ft-get-supply unity-hub) SUPPLY) (err u1007))
        (asserts! (<= amount MAX-MINT) (err u1006))
        (ft-mint? unity-hub amount tx-sender)
    ))

(define-read-only (get-balance (address principal))
    (ok (ft-get-balance unity-hub address)))

(define-read-only (get-decimals)
    (ok u100000))

(define-read-only (get-name)
    (ok "Unity Hub"))

(define-read-only (get-symbol)
    (ok "UNITY"))

(define-read-only (get-token-uri)
    (ok (some u"ipfs://ipfs/bafkreib2gvqghy2hiugzc5kdogkw5ot7wikc4qlt2icdawn2c2bznnvjs4")))

(define-read-only (get-total-supply)
    (ok (ft-get-supply unity-hub)))
