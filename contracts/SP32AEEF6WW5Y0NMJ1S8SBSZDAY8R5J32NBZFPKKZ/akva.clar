
;; title: Akva token
;; version: 0.0.0
;; description: Commemorating Akva CEO of Stacks

(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(define-fungible-token akva SUPPLY)

(define-constant MAX-MINT u1)
(define-constant SUPPLY u100)

(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
    (begin
        (asserts! (is-eq tx-sender sender) (err u1001))
        (asserts! (>= (ft-get-balance akva sender) amount) (err u1002))
        (asserts! (not (is-eq sender recipient)) (err u1003))
        (match memo to-print (print to-print) 0x)
        (ft-transfer? akva amount sender recipient))
)

(define-public (burn (amount uint))
    (begin
        (asserts! (is-eq contract-caller tx-sender) (err u1004))
        (asserts!  (>= (ft-get-balance akva tx-sender) amount) (err u1002))
        (ft-burn? akva amount tx-sender)
    ))

(define-public (mint (amount uint))
    (begin
        (asserts! (is-eq contract-caller tx-sender) (err u1004))
        ;; if yer a kentrekt then ye kant ment
        (asserts! (is-none (get name (unwrap-panic (principal-destruct? tx-sender)))) (err u1005))
        (asserts! (<= (ft-get-supply akva) SUPPLY) (err u1007))
        (asserts! (<= amount MAX-MINT) (err u1006))
        (ft-mint? akva amount tx-sender)
    ))

(define-read-only (get-balance (address principal))
    (ok (ft-get-balance akva address)))

(define-read-only (get-decimals)
    (ok u0))

(define-read-only (get-name)
    (ok "Akva"))

(define-read-only (get-symbol)
    (ok "AKVA"))

(define-read-only (get-token-uri)
    (ok (some u"ipfs://ipfs/bafkreicdyt4ta5y76dgxmm6hs4mzxs3lyhk52poqjws5dljxglwnoatv4m")))

(define-read-only (get-total-supply)
    (ok (ft-get-supply akva)))
