(define-constant ERR-NOT-WHITELISTED u851)
(define-constant ERR-NOT-AUTHORIZED u8401)

(define-data-var oracle-owner principal tx-sender)
(define-data-var last-price uint u0)
(define-data-var last-block uint u0)

(define-map prices1
  { token: (string-ascii 12) }
  {
    last-price: uint,
    last-block: uint,
    decimals: uint
  }
)

(define-map prices2
  { token: (string-ascii 12) }
  {
    last-price: uint,
    last-block: uint,
    decimals: uint
  }
)

(define-map prices3
  { token: (string-ascii 12) }
  {
    last-price: uint,
    last-block: uint,
    decimals: uint
  }
)


(define-public (set-oracle-owner (address principal))
  (begin
    (asserts! (is-eq tx-sender (var-get oracle-owner)) (err ERR-NOT-AUTHORIZED))

    (ok (var-set oracle-owner address))
  )
)

(define-public (update-price (token (string-ascii 12)) (price uint) (decimals uint))
  (if (is-eq tx-sender (var-get oracle-owner))
    (begin
      (map-set prices1 { token: token } (get-price2 token))
      (map-set prices2 { token: token } (get-price3 token))
      (map-set prices3 { token: token } { last-price: price, last-block: block-height, decimals: decimals })

      (ok price)
    )
    (err ERR-NOT-WHITELISTED)
  )
)

(define-read-only (get-price (token (string-ascii 12)))
  (let (
      (price1 (get-price1 token))
      (price2 (get-price2 token))
      (price3 (get-price3 token))
    )
    (if (or (is-eq u0 (get last-price price1)) (is-eq u0 (get last-price price2)))
      price3
      (if (< (get last-price price1) (get last-price price2))
        (if (< (get last-price price2) (get last-price price3))
          (merge price3 {last-price: (get last-price price2)})
          (if (< (get last-price price3) (get last-price price1))
            (merge price3 {last-price: (get last-price price1)})
            price3
          )
        )
        (if (< (get last-price price1) (get last-price price3))
          (merge price3 {last-price: (get last-price price1)})
          (if (< (get last-price price3) (get last-price price2))
            (merge price3 {last-price: (get last-price price2)})
            price3
          )
        )
      )
    )
  )
)

(define-read-only (get-price1 (token (string-ascii 12)))
  (unwrap! (map-get? prices1 { token: token }) { last-price: u0, last-block: u0, decimals: u0 })
)
(define-read-only (get-price2 (token (string-ascii 12)))
  (unwrap! (map-get? prices2 { token: token }) { last-price: u0, last-block: u0, decimals: u0 })
)
(define-read-only (get-price3 (token (string-ascii 12)))
  (unwrap! (map-get? prices3 { token: token }) { last-price: u0, last-block: u0, decimals: u0 })
)

(define-public (fetch-price (token (string-ascii 12)))
  (ok (get-price token))
)
