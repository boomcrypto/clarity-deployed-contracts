(define-constant err-block-not-found (err u404))

(define-read-only (get-rnd (block uint))
    (let (
        (vrf (buff-to-uint-be (unwrap-panic (as-max-len? (unwrap-panic (slice? (unwrap! (get-block-info? vrf-seed block) err-block-not-found) u16 u32)) u16))))
        (time (unwrap! (get-block-info? time block) err-block-not-found)))
        ;; Because time is not deterministic we ignore it in testing envs
        (ok (if is-in-mainnet (+ vrf time) vrf))))

(define-read-only (tenure-height) block-height)