
;; counter
;; let's get started with smart contracts
(define-data-var counter uint u1)
(define-data-var counter-multi-key { k1: uint, k2: uint } { k1: u0, k2: u1})
(define-map simple-kv uint uint)
(define-map multi-kv { key1: uint, key2: uint} { value1: (string-ascii 10), value2: (string-ascii 10), value3: (string-ascii 10) })
(define-fungible-token token-name u100)
(define-non-fungible-token nft-name uint)
(define-non-fungible-token domain { id: uint, name: (string-ascii 15)})

(define-public (increment (step uint))
    (let ((new-val (+ step (var-get counter))))
        (var-set counter new-val)
        (print { object: "counter", action: "incremented", value: new-val })
        (ok new-val)))

(define-public (decrement (step uint))
    (let ((new-val (- step (var-get counter)))) 
        (var-set counter new-val)
        (print { object: "counter", action: "decremented", value: new-val })
        (ok new-val)))

(define-read-only (read-counter)
    (ok (var-get counter)))
