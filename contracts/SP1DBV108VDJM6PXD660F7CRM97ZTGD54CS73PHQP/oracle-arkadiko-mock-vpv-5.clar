(impl-trait 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-oracle-trait-v1.oracle-trait)

(define-map prices
  { token: (string-ascii 12) }
  {
    last-price: uint,
    last-block: uint,
    decimals: uint
  }
)

(define-public (set-sbtc-info (new-price uint))
     (ok (map-set prices {token: "BTC"} { last-price: new-price, last-block: burn-block-height, decimals: u8 }))
)

;; @desc get price info for given token name
(define-read-only (get-price (token (string-ascii 12)))
  (unwrap! (map-get? prices { token: token }) { last-price: u0, last-block: u0, decimals: u0 })
)

;; @desc get price info response for given token name
(define-read-only (fetch-price (token (string-ascii 12)))
  (ok (get-price token))
)

;; init
(begin
  (map-set prices {token: "BTC"} { last-price: (* u70000 u100000000), last-block: burn-block-height, decimals: u8 })
)
