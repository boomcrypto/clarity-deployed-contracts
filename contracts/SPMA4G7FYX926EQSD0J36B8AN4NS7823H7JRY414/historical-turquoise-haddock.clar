
(define-read-only (check-pox-reward-missed-btc-blocks (btc-block-height uint))
  (get-burn-block-info? pox-addrs btc-block-height)
)