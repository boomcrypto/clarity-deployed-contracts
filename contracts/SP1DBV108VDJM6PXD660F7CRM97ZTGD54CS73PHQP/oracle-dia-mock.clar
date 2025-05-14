(impl-trait 'SP1G48FZ4Y7JY8G2Z0N51QTCYGBQ6F4J43J77BQC0.trait-dia-oracle.dia-oracle-trait)

(define-map prices
  { token: (string-ascii 32) }
  { value: uint, timestamp: uint }
)

(define-public (set-sbtc-info (value uint))
     (ok (map-set prices {token: "BTC/USD"} { value: value, timestamp: (unwrap-panic (get-stacks-block-info? time (- stacks-block-height u1))) }))
)

;; @desc get price info for given token name
(define-read-only (get-value (key (string-ascii 32)))
  (ok (unwrap-panic (map-get? prices { token: key })))
)

;; init
(begin
  (map-set prices {token: "BTC/USD"} { value: (* u70000 u100000000), timestamp: (unwrap-panic (get-stacks-block-info? time (- stacks-block-height u1))) })
)
