(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)
;; (impl-trait 'ST1NXBK3K5YYMD6FD41MVNP3JS1GABZ8TRVX023PT.sip-010-trait-ft-standard.sip-010-trait) ;; testnet trait

(define-constant ERR-SUSS-OWNER (err u69))
(define-constant ERR-NOT-AUTHORIZED (err u6969))
(define-constant err-suspected-evil (err u6009))
(define-constant there-is-no-saint (err u1069))
(define-constant err-the-source-of-all-evil (err u21669))

(define-constant block-deploy (+ block-height u1669))

(define-data-var token-decimals uint u8)

(define-constant ONE_8 u100000000)

(define-public (set-decimals (new-decimals uint))
	(begin
		(try! (call-god))
		(ok (var-set token-decimals new-decimals))))

(define-read-only (get-decimals)
	(ok (var-get token-decimals)))

;; function to read block-deploy
(define-read-only (get-block-deploy)
    (ok block-deploy)
)

(define-constant block-residual (+ block-height u6969))
;; function to read block-residual
(define-read-only (get-block-residual)
    (ok block-residual)
)

(define-constant err-cant-resurrect (err u11111))
(define-constant err-time-exists-so-we-can-see-evil (err u33339))

(define-data-var POWER-OF-GO principal tx-sender)

;; set new owner
(define-public (set-POWER-OF-GO (new-owner principal))
    (begin
        (try! (call-god))
        (ok (var-set POWER-OF-GO new-owner))))

(define-data-var token-uri (optional (string-utf8 256)) (some u"https://stacks.gamma.io/collections/aint"))

(define-fungible-token suss)


(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
    (begin
        (asserts! (is-eq tx-sender sender) err-suspected-evil)
        (try! (ft-transfer? suss amount sender recipient))
        (match memo to-print (print to-print) 0x)
        (ok true)
    )
)

(define-read-only (get-name)
    (ok "$uss")
)

(define-read-only (get-symbol)
    (ok "$uss")
)

(define-read-only (get-balance (user principal))
    (ok (ft-get-balance suss user))
)
(define-read-only (get-total-supply)
    (ok (ft-get-supply suss))
)
(define-read-only (get-POWER-OF-GO)
    (ok (var-get POWER-OF-GO))
)

(define-public (set-token-uri (new-uri (optional (string-utf8 256))))
	(begin
		(try! (call-god))
		(ok (var-set token-uri new-uri)))
)

(define-read-only (get-token-uri)
	(ok (var-get token-uri))
)

(define-private (call-god)
	(ok (asserts! (is-eq tx-sender (var-get POWER-OF-GO)) ERR-NOT-AUTHORIZED))
)

(define-public (pre-mint (saint-id uint))
    (let 
        (
            (saint (unwrap! (contract-call? 'SP207ESW7AKHTPRYAAD9QP8Q1TE1F57D2S8RGPJCC.saints get-owner saint-id) there-is-no-saint))
        )
        ;; Tx-sender is a $aint 
        (asserts! (is-eq saint (some tx-sender)) ERR-SUSS-OWNER)
        (asserts! (not (default-to false (map-get? ssupects tx-sender))) err-cant-resurrect)
        (asserts! (map-set ssupects tx-sender true) err-suspected-evil)
        ;; Assert that the total-supply is less than 21000000
        (asserts! (<= (ft-get-supply suss) (* (- u21000000 u6969) ONE_8)) err-the-source-of-all-evil)
        (print "$aints have come to the table of the lord, and the lord has blessed them with the power of the holy spirit.")
        (ft-mint? suss (* u6969 ONE_8) tx-sender)

    )
)

(define-map ssupects principal bool)

(define-public (mint)
    (begin
        (asserts! (> block-height block-deploy) err-time-exists-so-we-can-see-evil)
        (asserts! (<= (ft-get-supply suss) (* (- u21000000 u1000) ONE_8)) err-the-source-of-all-evil)
        ;; we have to add this wallet to a map and then assert that they haven't already minted
        (asserts! (not (default-to false (map-get? ssupects tx-sender))) err-cant-resurrect)
        (asserts! (map-set ssupects tx-sender true) err-suspected-evil)

        (print "In the dance of the cosmos, each soul now finds its way to the sacred wellspring, where the nectar of holiness awaits to quench the deepest thirst.")
        (ft-mint? suss (* u1000 ONE_8) tx-sender)
    )
)

;; mint residual using an amount
(define-public (mint-residual (amount uint))
    (begin
        (asserts! (> block-height block-residual) err-suspected-evil)
        (try! (call-god)) ;; Power of god completes the wholly trinity 
        ;; we have to add this wallet to a map and then assert that they haven't already minted
        (asserts! (<= (+ (ft-get-supply suss) amount) (* u21000000 ONE_8)) err-the-source-of-all-evil)
        (print "Integrate the evil, and you will find true peace.")

        (ft-mint? suss amount tx-sender)
    )
)

(print "Integrate the evil and you will find true peace.")