(define-constant err-not-white-listed u51)

(define-data-var last-price uint u0)
(define-data-var last-block uint u0)
;; (define-data-var price uint u0)

(define-constant oracle-owner 'ST2WATQX70C2B6BS3YP0SA3288ZVAXJ5NBTC45Y4W)


;; for now, only allow owner, but eventually:
;;
;; Can be called by anyone using a vetted oracle that provides signed volume weighted price data for the past 24 hours
;; using stubbed calls till secp256k1 verification is implemented
;; will consider rewarding sender with some flexr tokens
;; data needs to be sent 10-15 blocks before next rebalance, picks a winner at random
;; or rather, the signed payload can be passed to flexr.rebase, removing the need for a separate oracle contract, and 1 less transaction per day
(define-public (update-price (price uint))
  (if (is-eq tx-sender oracle-owner)
    (begin
      (var-set last-price price)
      (var-set last-block block-height)
      (ok true)
    )
    (err err-not-white-listed)
  )
)

;; get the latest price within 10-15 blocks of rebalance, or no rebalance happens
(define-read-only (get-price)
  { price: (var-get last-price), height: (var-get last-block)}
)

;; TODO(psq): use the same format for messages as coinbase oracle with secp256k1 signatures