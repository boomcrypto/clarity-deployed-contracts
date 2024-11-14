---
title: "Trait sys-rnft-staking"
draft: true
---
```
(define-constant err-already-staked (err u9666))
(define-constant err-not-staked (err u9777))
(define-constant err-no-such-token (err u404))

(define-map staked-tokens uint principal)
(define-map staked-counts principal uint)


(define-public (enter-staking (token uint))
    (let (
          (token-owner (unwrap! (unwrap-panic 
                                 (contract-call? .sys-rnft get-owner token)) err-no-such-token))
          (new-count (+ u1 (default-to u0 (map-get? staked-counts token-owner))))
          )
      (try! (contract-call? .sys-admin assert-invoked-by-operator))
      (asserts! (not (is-eq token-owner (as-contract tx-sender))) err-already-staked)
      (try! (contract-call? .sys-rnft transfer token token-owner (as-contract tx-sender)))
      (map-set staked-tokens token token-owner)
      (map-set staked-counts token-owner new-count)
      (ok new-count)
      )
  )

(define-public (leave-staking (token uint))
    (let (
          (owner (unwrap! (map-get? staked-tokens token) err-not-staked))
          (cur-count (unwrap! (map-get? staked-counts owner) err-not-staked))
          )
      (try! (contract-call? .sys-admin assert-invoked-by-operator))
      (try! (as-contract
             (contract-call? .sys-rnft transfer token tx-sender owner)))
      (map-delete staked-tokens token)
      (map-set staked-counts owner (- cur-count u1))
      (ok owner)
    )
  )

(define-read-only (is-token-staked (token uint))
    (is-some (map-get? staked-tokens token))
    )

(define-read-only (get-staked-tokens-count (who principal))
    (default-to u0 (map-get? staked-counts who))
    )

```
