
(define-read-only (check-pox-reward-missed-btc-blocks)
  (get-burn-block-info? pox-addrs burn-block-height)
)
