;; zonefile map
(define-map zonefile {name: (buff 48), namespace: (buff 20)} (buff 4096))

(define-map zonefile-hash {name: (buff 48), namespace: (buff 20)} (buff 34))

;; set zonefile
(define-public (set-zonefile (name (buff 48)) (namespace (buff 20)) (new-zonefile (buff 4096)))
    (begin
        ;; update zonefile
        (map-set zonefile {name: name, namespace: namespace} new-zonefile)
        ;; call into update-zonefile-hash
        (ok 
            (if (is-eq u34 (len new-zonefile)) 
                (map-set zonefile-hash {name: name, namespace: namespace} (unwrap-panic (as-max-len? new-zonefile u34)))
                (map-set zonefile-hash {name: name, namespace: namespace} (hash160 new-zonefile))
            )
        )
    )
)

;; fetch zonefile
(define-read-only (resolve-zonefile (name (buff 48)) (namespace (buff 20))) 
    (map-get? zonefile {name: name, namespace: namespace})
)

(define-read-only (get-zonefile-hash (name (buff 48)) (namespace (buff 20))) 
    (map-get? zonefile-hash {name: name, namespace: namespace})
)
