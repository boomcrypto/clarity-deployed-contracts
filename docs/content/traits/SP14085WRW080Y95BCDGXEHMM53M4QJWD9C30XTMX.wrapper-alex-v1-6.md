---
title: "Trait wrapper-alex-v1-6"
draft: true
---
```
(define-private (d (i uint) (mo uint)) (let ((o1 (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-helper 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.token-wsbtc u100000000 (/ (* i u100000000) u1000000) none))) (bb (stx-get-balance tx-sender)) (o2 (try! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-core-v-1-2 swap-x-for-y 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-pool-sbtc-stx-v-1-1 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.token-stx-v-1-2 o1 u1))) (ba (stx-get-balance tx-sender)) (r (- ba bb))) (asserts! (>= r mo) (err u5473)) (ok r))) (define-public (helper (i uint) (mo uint) (ti uint)) (let ((r (try! (d i mo)))) (and (> (stx-get-balance tx-sender) ti) (try! (stx-transfer? (- (stx-get-balance tx-sender) ti) tx-sender 'SP2JFQYP5V4P7F13SMT9GGMEC1F8X91YC4SF86G1J))) (ok r)))
```
