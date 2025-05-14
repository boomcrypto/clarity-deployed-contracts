---
title: "Trait allied-harlequin-aardvark"
draft: true
---
```
(impl-trait 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.oracle-trait.oracle-trait)
(use-trait ft 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.ft-trait.ft-trait)

(define-constant deployer tx-sender)

(define-constant err-unauthorized (err u3000))
(define-constant err-above-threshold (err u3001))
(define-constant err-stale (err u3002))

;; seconds
(define-data-var max-delay uint u10800) ;; 3 hours
(define-data-var max-price uint u1000000000) ;; 10 USD

(define-public (set-max-delay (amount uint))
  (begin
    (asserts! (is-eq tx-sender deployer) err-unauthorized)
    (ok (var-set max-delay amount))
  )
)

(define-public (set-max-price (amount uint))
  (begin
    (asserts! (is-eq tx-sender deployer) err-unauthorized)
    (ok (var-set max-price amount))
  )
)

;; prices are fixed to 8 decimals
(define-public (get-asset-price (token <ft>))
  (let (
    (oracle-data (unwrap-panic (contract-call? 'SP1G48FZ4Y7JY8G2Z0N51QTCYGBQ6F4J43J77BQC0.dia-oracle
      get-value
      "ALEX/USD"
    )))
    ;; (last-stacks-timestamp (unwrap-panic (stacks-block-info? time (- stacks-block-height u1))))
    ;; ;; is 8 decimals
    (last-price (get value oracle-data))
    ;; ;; convert to seconds
    ;; (last-price-timestamp (/ (get timestamp oracle-data) u1000))
  )
    ;; (asserts! (< last-stacks-timestamp (- last-price-timestamp (var-get max-delay))) err-stale)
    ;; ;; sanity check
    ;; (asserts! (< last-price (var-get max-price)) err-above-threshold)
    ;; convert to fixed precision
    (ok last-price)
  )
)

;; ;; prices are fixed to 8 decimals
;; (define-read-only (get-price)
;;   (let (
;;     (oracle-data (unwrap-panic (contract-call? 'SP1G48FZ4Y7JY8G2Z0N51QTCYGBQ6F4J43J77BQC0.dia-oracle
;;       get-value
;;       "ALEX/USD"
;;     )))
;;     (last-stacks-timestamp (unwrap-panic (stacks-block-info? time (- stacks-block-height u1))))
;;     (last-price (get value oracle-data))
;;     (last-price-timestamp (/ (get timestamp oracle-data) u1000))
;;   )

;;     ;; (asserts! (< last-stacks-timestamp (- last-price-timestamp (var-get max-delay))) u0)
;;     ;; (asserts! (< last-price (var-get max-price)) u1)

;;     last-price
;;   )
;; )

```
