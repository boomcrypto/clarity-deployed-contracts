
;; title: baby token
;; version: 0.0.0
;; description: Commemorating  baby CEO of  baby

(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(define-fungible-token baby SUPPLY)

(define-constant MAX-MINT u100)
(define-constant SUPPLY u1000000)

(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
    (begin
        (asserts! (is-eq tx-sender sender) (err u1001))
        (asserts! (>= (ft-get-balance baby sender) amount) (err u1002))
        (asserts! (not (is-eq sender recipient)) (err u1003))
        (match memo to-print (print to-print) 0x)
        (ft-transfer? baby amount sender recipient))
)

(define-public (burn (amount uint))
    (begin
        (asserts! (is-eq contract-caller tx-sender) (err u1004))
        (asserts!  (>= (ft-get-balance baby tx-sender) amount) (err u1002))
        (ft-burn? baby amount tx-sender)
    ))

(define-public (mint (amount uint))
    (begin
        (asserts! (is-eq contract-caller tx-sender) (err u1004))
        ;; if yer a kentrekt then ye kant ment
        (asserts! (is-none (get name (unwrap-panic (principal-destruct? tx-sender)))) (err u1005))
        (asserts! (<= (ft-get-supply baby) SUPPLY) (err u1007))
        (asserts! (<= amount MAX-MINT) (err u1006))
        (ft-mint? baby amount tx-sender)
    ))

(define-read-only (get-balance (address principal))
    (ok (ft-get-balance baby address)))

(define-read-only (get-decimals)
    (ok u0))

(define-read-only (get-name)
    (ok "baby"))

(define-read-only (get-symbol)
    (ok "baby"))

(define-read-only (get-token-uri)
    (ok (some u"ipfs://ipfs/bafkreigs3bbcugtqng2opyzrghnmej6ob5iyfackipnw33vkpmf54nqrsa")))

(define-read-only (get-total-supply)
    (ok (ft-get-supply baby)))
