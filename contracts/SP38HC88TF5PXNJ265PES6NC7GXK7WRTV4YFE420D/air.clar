
;; title: Air token
;; version: 0.0.0
;; description: We are the opposite of nothing. Air is everything.

(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(define-fungible-token air SUPPLY)

(define-constant MAX-MINT u1000)
(define-constant SUPPLY u21000000)

(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
    (begin
        (asserts! (is-eq tx-sender sender) (err u1001))
        (asserts! (>= (ft-get-balance air sender) amount) (err u1002))
        (asserts! (not (is-eq sender recipient)) (err u1003))
        (match memo to-print (print to-print) 0x)
        (ft-transfer? air amount sender recipient))
)

(define-public (burn (amount uint))
    (begin
        (asserts! (is-eq contract-caller tx-sender) (err u1004))
        (asserts!  (>= (ft-get-balance air tx-sender) amount) (err u1002))
        (ft-burn? air amount tx-sender)
    ))

(define-public (mint (amount uint))
    (begin
        (asserts! (is-eq contract-caller tx-sender) (err u1004))
        ;; if yer a kentrekt then ye kant ment
        (asserts! (is-none (get name (unwrap-panic (principal-destruct? tx-sender)))) (err u1005))
        (asserts! (<= (ft-get-supply air) SUPPLY) (err u1007))
        (asserts! (<= amount MAX-MINT) (err u1006))
        (ft-mint? air amount tx-sender)
    ))

(define-read-only (get-balance (address principal))
    (ok (ft-get-balance air address)))

(define-read-only (get-decimals)
    (ok u0))

(define-read-only (get-name)
    (ok "Air"))

(define-read-only (get-symbol)
    (ok "Air"))

(define-read-only (get-token-uri)
    (ok (some u"ipfs://ipfs/bafkreicbhcnuuynyq4yabhjvmknc6upq6lsombmf26a27lynnl5xjhwsgy")))

(define-read-only (get-total-supply)
    (ok (ft-get-supply air)))
