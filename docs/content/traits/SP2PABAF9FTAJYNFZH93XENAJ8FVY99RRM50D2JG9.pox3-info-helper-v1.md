---
title: "Trait pox3-info-helper-v1"
draft: true
---
```
;; helper contract to calculate the threshold 
;; for stacking rewards slots of pox-3
(define-constant err-cycle-data-missing (err u404))
(define-constant err-invalid-cycle (err u501))
(define-constant err-invalid-block (err u502))

;;
;; manage map of cycles to stacks block height
;; any block not in the prepare phase of the cycle is accepted
;;

(define-map blocks-in-cycle uint uint)

(define-read-only (get-block-in-cycle (cycle uint))
    (map-get? blocks-in-cycle cycle))

(define-read-only (get-block-in-cycle-many (cycles (list 100 uint)))
    (map get-block-in-cycle cycles))

(define-public (set-block-in-cycle (block {cycle: uint, height: uint}))
    (let ((height (get height block))
          (cycle (get cycle block))
          (burn-height (at-block (unwrap! (get-block-info? id-header-hash height) err-invalid-block) burn-block-height)))
        ;; block must not be in prepare phase of next cycle
        (asserts! (< burn-height (+ (* cycle u2100) u668050)) err-invalid-block)
        ;; block must be in cycle
        (asserts! (is-eq cycle (/ (- burn-height u666050) u2100)) err-invalid-block)
        (ok (map-set blocks-in-cycle cycle height))))

(define-public (set-block-in-cycle-many (blocks (list 100 {cycle: uint, height: uint})))
    (ok (map set-block-in-cycle blocks)))

;;
;; calculate threshold for cycles
;;

(define-read-only (get-threshold-from-participation (liquid-ustx uint) (total-ustx-stacked uint) (reward-slots uint))
    (let ((scale-by (max total-ustx-stacked (/ liquid-ustx u4)))
            (threshold-precise (/ scale-by reward-slots))
            (remainder (mod threshold-precise u10000000000))
            (ceil-amount (if (is-eq remainder u0) u0 (- u10000000000 remainder))))
        (+ threshold-precise ceil-amount)))

(define-read-only (get-pox-info-for-cycle (cycle uint))
  (let ((block-in-cycle (unwrap! (map-get? blocks-in-cycle cycle) err-cycle-data-missing)))
    (at-block (unwrap! (get-block-info? id-header-hash block-in-cycle) err-invalid-block) 
      (let ((pox-info (unwrap! (contract-call? 'SP000000000000000000002Q6VF78.pox-3 get-pox-info) err-invalid-cycle))
            (total-ustx-stacked (contract-call? 'SP000000000000000000002Q6VF78.pox-3 get-total-ustx-stacked cycle))
            (min-threshold-ustx (get-threshold-from-participation 
                (get total-liquid-supply-ustx pox-info) 
                total-ustx-stacked
                u4000)))
            (ok {pox-info: pox-info, 
                total-ustx-stacked: total-ustx-stacked, 
                min-threshold-ustx: min-threshold-ustx})))))

;; helper function
(define-read-only (max (a uint) (b uint))
    (if (> a b) a b))

```
