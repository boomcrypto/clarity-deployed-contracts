---
title: "Trait wrapper-alex-v1-11"
draft: true
---
```
(define-private (d (i uint) (mo uint)) (let ((o1 (try! (contract-call? 'SP20X3DC5R091J8B6YPQT638J8NR1W83KN6TN5BJY.univ2-pool-v1_0_0-0070 swap 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token 'SP20X3DC5R091J8B6YPQT638J8NR1W83KN6TN5BJY.univ2-fees-v1_0_0-0070 i u1))) (bb (stx-get-balance tx-sender)) (o2 (try! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-core-v-1-2 swap-x-for-y 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-pool-sbtc-stx-v-1-1 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.token-stx-v-1-2 (get amt-out o1) u1))) (ba (stx-get-balance tx-sender)) (r (- ba bb))) (asserts! (>= r mo) (err u5473)) (ok r))) (define-public (helper (i uint) (mo uint) (ti uint)) (let ((r (try! (d i mo)))) (and (> (stx-get-balance tx-sender) ti) (try! (stx-transfer? (- (stx-get-balance tx-sender) ti) tx-sender 'SP2JFQYP5V4P7F13SMT9GGMEC1F8X91YC4SF86G1J))) (ok r)))
```
