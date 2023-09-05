(define-constant DEPLOYER tx-sender)
(define-constant ERR-WL-PAUSED (err u100))
(define-constant ERR-INVALID-USER (err u101))
(define-constant ERR-ALREADY-WL (err u102))
(define-constant ERR-INVALID-ORDINAL (err u102))

(define-data-var wl-paused bool true)

(define-map squawklists uint (string-ascii 100))

(define-public (register (parrot-pass-id uint) (ordinal-address (string-ascii 100)))
    (begin
        (asserts! (is-eq (var-get wl-paused) false) ERR-WL-PAUSED)  
        (asserts! (is-none (map-get? squawklists parrot-pass-id)) ERR-ALREADY-WL)
        (asserts! (< u0 (len ordinal-address)) ERR-INVALID-ORDINAL)
        (map-insert squawklists parrot-pass-id ordinal-address)
        (ok true)))

(define-public (toggle-wl)
    (begin
        (asserts! (is-eq tx-sender DEPLOYER) ERR-INVALID-USER)
        (ok (var-set wl-paused (not (var-get wl-paused))))))

(define-public (get-wl (parrot-pass-id uint)) 
    (ok (map-get? squawklists parrot-pass-id)))

(define-read-only (get-register-status)
    (ok (var-get wl-paused)))