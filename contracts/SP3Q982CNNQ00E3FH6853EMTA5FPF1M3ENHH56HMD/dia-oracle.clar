(impl-trait .trait-dia-oracle.dia-oracle-trait)

(define-constant err-unauthorized (err u100))

(define-data-var oracle-updater principal tx-sender)

(define-map values
    (string-ascii 32)
    { value: uint, timestamp: uint }
)

(define-public (set-value (key (string-ascii 32)) (value uint) (timestamp uint))
    (begin
        (try! (check-is-oracle-updater))
        (update-value { key: key, value: value, timestamp: timestamp })
        (ok true)
    )
)

(define-public (set-multiple-values (entries (list 10 { key: (string-ascii 32), value: uint, timestamp: uint })))
    (begin
        (try! (check-is-oracle-updater))
        (map update-value entries)
        (ok true)
    )
)

(define-public (change-oracle-updater (new-oracle-updater principal))
    (begin
        ;; #[filter(new-oracle-updater)]
        (try! (check-is-oracle-updater))
        (var-set oracle-updater new-oracle-updater)
        (print
            {
                action: "oracle-updater-changed",
                data: { old-updater: tx-sender, new-updater: new-oracle-updater }
            }
        )
        (ok true)
    )
)

(define-read-only (get-oracle-updater)
    (var-get oracle-updater)
)

(define-read-only (get-value (key (string-ascii 32)))
    (ok (default-to { value: u0, timestamp: u0 } (map-get? values key)))
)

(define-private (check-is-oracle-updater)
    (ok (asserts! (is-eq tx-sender (var-get oracle-updater)) err-unauthorized))
)

(define-private (update-value (entry { key: (string-ascii 32), value: uint, timestamp: uint }))
    (begin
        (map-set values
            (get key entry)
            { value: (get value entry), timestamp: (get timestamp entry) }
        )
        (print { action: "updated", data: entry })
    )
)
