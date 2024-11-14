---
title: "Trait curve-fees-v1_0_0_ststx-0000"
draft: true
---
```
(use-trait ft-trait 'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.sip-010-trait-ft-standard.sip-010-trait)

(impl-trait .curve-fees-trait_v1_0_0.curve-fees-trait)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; errors
(define-constant err-auth      (err u999))
(define-constant err-anti-rug  (err u998))
(define-constant err-calc-fees (err u997))
(define-constant err-balance   (err u996))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; protocol fees
(define-data-var initalized bool false)
(define-public (init (pool_ principal)) ;;ignored / backwards compat
  (begin
    (asserts!
      (and (is-eq contract-caller .curve-registry_v1_0_0)
           (not (var-get initalized)))
      err-auth)
    (ok (var-set initalized true))))

(define-public (receive (is-token0 bool) (amt uint))
  (if true (ok true) (err u0))) ;;nop for backwards compat

(define-public
  (collect
    (token0 <ft-trait>)
    (token1 <ft-trait>))

  (let ((user     tx-sender)
        (protocol (as-contract tx-sender))
        (bal0     (try! (contract-call? token0 get-balance protocol)))
        (bal1     (try! (contract-call? token1 get-balance protocol)))
        )

    ;; Pre-conditions
    (try! (check-protocol-fee-to))

    ;; Update global state
    (if (> bal0 u0)
        (try! (as-contract (contract-call? token0 transfer bal0 protocol user none)))
        false)
    (if (> bal1 u0)
        (try! (as-contract (contract-call? token1 transfer bal1 protocol user none)))
        false)

    ;; Post-conditions

    ;; Return
    (let ((event
          {op     : "collect",
           user   : user,
          }))
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
      ;; (or (is-eq (get num swap-fee) (get den swap-fee))
      ;;     (and (> amt-fee-lps u0))
      ;;     (or (is-eq (get num protocol-fee) (get den protocol-fee))
      ;;         (> amt-fee-protocol u0)))
      (is-eq amt-in (+ amt-in-adjusted amt-fee-lps amt-fee-protocol))
      ) err-calc-fees)

    (ok {
    amt-in-adjusted : amt-in-adjusted,
    amt-fee-lps     : amt-fee-lps,
    amt-fee-protocol: amt-fee-protocol,
    }) ))

;;; eof

```
