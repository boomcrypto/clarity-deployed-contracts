(define-constant block-rewards (list {bh: u666050, rewards: u2000}
                                {bh: u676050, rewards: u1000}
                                {bh: u876434, rewards: u500}
                                {bh: u1086818, rewards: u250}
                                {bh: u1297202, rewards: u125}))

(define-read-only (get-rewards (bh uint))
    (get rewards-at-bh (fold get-rewards-internal block-rewards {bh: bh, rewards-at-bh: u0})))

(define-private (get-rewards-internal (halving {bh: uint, rewards: uint}) (ctx {bh: uint, rewards-at-bh: uint}))
    (if (<= (get bh halving) (get bh ctx))
        (merge ctx {rewards-at-bh: (get rewards halving)})
        ctx))

;; get price for sats/stx from miner commits using the last 10 blocks
(define-read-only (get-sats-stx-price (bh uint))
    (let ((rewards (get-rewards bh)))
    (/ (get-sats-last-10-blocks bh) rewards)))

(define-read-only (get-sats-last-10-blocks (bh uint))
 (/
  (+ (unwrap! (get payout (get-burn-block-info? pox-addrs bh)) u0)
     (unwrap! (get payout (get-burn-block-info? pox-addrs (- bh u1))) u0)
     (unwrap! (get payout (get-burn-block-info? pox-addrs (- bh u2))) u0)
     (unwrap! (get payout (get-burn-block-info? pox-addrs (- bh u3))) u0)
     (unwrap! (get payout (get-burn-block-info? pox-addrs (- bh u4))) u0)
     (unwrap! (get payout (get-burn-block-info? pox-addrs (- bh u5))) u0)
     (unwrap! (get payout (get-burn-block-info? pox-addrs (- bh u6))) u0)
     (unwrap! (get payout (get-burn-block-info? pox-addrs (- bh u7))) u0)
     (unwrap! (get payout (get-burn-block-info? pox-addrs (- bh u8))) u0)
     (unwrap! (get payout (get-burn-block-info? pox-addrs (- bh u9))) u0))
  u10))
