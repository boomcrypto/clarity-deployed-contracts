---
title: "Trait univ2-fees-v1_0_0-0183"
draft: true
---
```
(use-trait ft-trait 'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.sip-010-trait-ft-standard.sip-010-trait)

(impl-trait 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-fees-trait_v1_0_0.univ2-fees-trait)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; errors
(define-constant err-auth      (err u999))
(define-constant err-anti-rug  (err u998))
(define-constant err-calc-fees (err u997))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; protocol fees
(define-data-var POOL principal tx-sender)
(define-data-var initalized bool false)
(define-public (init (pool principal)) ;;TODO: pool-trait?
  (begin
    (asserts!
      (and (is-eq contract-caller 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-registry_v1_0_0)
           (not (var-get initalized)))
      err-auth)
    (var-set POOL pool)
    (ok (var-set initalized true))))

(define-private (check-pool)
  (ok (asserts! (is-eq contract-caller (var-get POOL)) err-auth)))

(define-public (receive (is-token0 bool) (amt uint))
  (begin
   (try! (check-pool))
   (unwrap-panic (update-revenue is-token0 amt))
   (ok true)))

(define-data-var revenue
  (tuple (token0 uint) (token1 uint))
  { token0: u0, token1: u0 })

(define-read-only (get-revenue) (var-get revenue))

(define-private
  (update-revenue
   (is-token0 bool)
   (amt       uint))
  (let ((r0  (get-revenue))
        (t0r (get token0 r0))
        (t1r (get token1 r0))
        (r1  {token0: (if is-token0 (+ t0r amt) t0r),
              token1: (if is-token0 t1r (+ t1r amt)) }) )
    (ok (var-set revenue r1)) ))

(define-private (reset-revenue)
  (ok (var-set revenue {token0: u0, token1: u0})) )

(define-public
  (collect
    (token0 <ft-trait>)
    (token1 <ft-trait>))

  (let ((user     tx-sender)
        (protocol (as-contract tx-sender))

        (rev      (get-revenue))
        (amt0     (get token0 rev))
        (amt1     (get token1 rev)) )

    ;; Pre-conditions
    (try! (check-protocol-fee-to))

    ;; Update global state
    (if (> amt0 u0)
        (try! (as-contract (contract-call? token0 transfer amt0 protocol user none)))
        false)
    (if (> amt1 u0)
        (try! (as-contract (contract-call? token1 transfer amt1 protocol user none)))
        false)

    ;; Update local state
    (unwrap-panic (reset-revenue))

    ;; Post-conditions

    ;; Return
    (let ((event
          {op     : "collect",
           user   : user,
           revenue: rev }))
      (print event)
      (ok event) )))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; roles
(define-data-var owner principal tx-sender)
(define-read-only (get-owner) (var-get owner))
(define-private (check-owner)
  (ok (asserts! (is-eq contract-caller (get-owner)) err-auth)))
(define-public (set-owner (new-owner principal))
  (begin
   (try! (check-owner))
   (ok (var-set owner new-owner)) ))

(define-data-var protocol-fee-to principal tx-sender)
(define-read-only (get-protocol-fee-to) (var-get protocol-fee-to))
(define-private (check-protocol-fee-to)
  (ok (asserts! (is-eq tx-sender (get-protocol-fee-to)) err-auth)))
(define-public (set-protocol-fee-to (new-protocol-fee-to principal))
  (begin
   (try! (check-owner))
   (ok (var-set protocol-fee-to new-protocol-fee-to)) ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; fee state
(define-read-only (get-fees)    (ok (var-get state)))
(define-read-only (do-get-fees) (var-get state))

(define-data-var state
  {
  swap-fee     : {num: uint, den: uint}, ;;fraction of input
  protocol-fee : {num: uint, den: uint}, ;;fraction of swap fee
  }
  {
  swap-fee     : { num: u9970, den: u10000 },
  protocol-fee : { num: u2500, den: u10000 },
  })

(define-constant MAX-SWAP-FEE     {num: u9950, den: u10000})
(define-constant MAX-PROTOCOL-FEE {num: u5000, den: u10000})

(define-public
  (update-swap-fee
   (fee (tuple (num uint) (den uint))))
  (let ((state_ (var-get state)))
    (try! (check-owner))
    (asserts! (check-swap-fee fee MAX-SWAP-FEE) err-anti-rug)
    (ok (var-set state (merge state_ {swap-fee: fee})) )))

(define-public
  (update-protocol-fee
   (fee (tuple (num uint) (den uint))))
  (let ((state_ (var-get state)))
    (try! (check-owner))
    (asserts! (check-protocol-fee fee MAX-PROTOCOL-FEE) err-anti-rug)
    (ok (var-set state (merge state_ {protocol-fee: fee})) )))


(define-read-only
  (check-swap-fee
   (fee   (tuple (num uint) (den uint)))
   (guard (tuple (num uint) (den uint))) )

    (and (is-eq (get den fee) (get den guard))
         (<=    (get num fee) (get den guard))
         (>=    (get num fee) (get num guard)) ) )

(define-read-only
  (check-protocol-fee
   (fee   (tuple (num uint) (den uint)))
   (guard (tuple (num uint) (den uint))) )

  (and (is-eq (get den fee) (get den guard))
       (<=    (get num fee) (get num guard)) ) )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; fee calculation
(define-read-only (calc-fees (amt-in uint))
  (let ((state_            (var-get state))
        (swap-fee          (get swap-fee state_))
        (protocol-fee      (get protocol-fee state_))

        (amt-in-adjusted   (/ (* amt-in (get num swap-fee))
                              (get den swap-fee)))
        (amt-fee-total     (- amt-in amt-in-adjusted))
        (amt-fee-protocol  (/ (* amt-fee-total (get num protocol-fee))
                              (get den protocol-fee)) )
        (amt-fee-lps       (- amt-fee-total amt-fee-protocol))
        )

    (asserts!
     (and
      (or (is-eq (get num swap-fee) (get den swap-fee))
          (and (> amt-fee-lps u0))
          (or (is-eq (get num protocol-fee) (get den protocol-fee))
              (> amt-fee-protocol u0)))
      (is-eq amt-in (+ amt-in-adjusted amt-fee-lps amt-fee-protocol))
      ) err-calc-fees)

    (ok {
    amt-in-adjusted : amt-in-adjusted,
    amt-fee-lps     : amt-fee-lps,
    amt-fee-protocol: amt-fee-protocol,
    }) ))

;;; eof

```
