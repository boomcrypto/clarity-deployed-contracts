---
title: "Trait univ2-initial-lp-proxy-v1_0_0-0167"
draft: true
---
```
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; traits
(use-trait ft-trait 'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.sip-010-trait-ft-standard.sip-010-trait)

(use-trait pool-trait 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-pool-trait_v1_0_0.univ2-pool-trait)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; errors
(define-constant err-auth                   (err u2101))
(define-constant err-send-preconditions     (err u2102))
(define-constant err-retrieve-preconditions (err u2103))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; ownership
(define-constant OWNER tx-sender)               ;; can set retriever
(define-data-var RETRIEVER principal tx-sender) ;; can init pool

(define-public (set-retriever (new-retriever principal))
  (begin
    (asserts! (is-eq OWNER tx-sender) err-auth)
    (ok (var-set RETRIEVER new-retriever))
  ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; storage
(define-map entries
  { token0: principal, token1: principal }
  { amt0: uint, amt1: uint, user: principal })

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; read
(define-read-only (get-lp (token0 principal) (token1 principal))
  (map-get? entries { token0: token0, token1: token1 }))

(define-read-only (lookup (token0 principal) (token1 principal))
  (match (get-lp token0 token1)
         val (some {val: val, flipped: false})
         (match (get-lp token1 token0)
                val (some {val: val, flipped: true})
                none)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; write
(define-public (send
  (token0 <ft-trait>)
  (token1 <ft-trait>)
  (amt0 uint)
  (amt1 uint)
)
  (let ((user     tx-sender)
        (protocol (as-contract tx-sender))
        (t0       (contract-of token0))
        (t1       (contract-of token1))
        (entry    (lookup t0 t1))
        (entry_   (get val entry))
        (new      { amt0: amt0, amt1: amt1, user: user }))
    (asserts!
      (is-none entry)
    err-send-preconditions)
    ;; global state
    (try! (contract-call? token0 transfer amt0 user protocol none))
    (try! (contract-call? token1 transfer amt1 user protocol none))
    ;; local state
    (map-set entries { token0: t0, token1: t1 } new)
    (print { old: entry_, new: new, wrapped: entry })
    (ok true)
  ))

;; token0, token1, lp-token same as in pool should is checked in register
(define-public
  (retrieve
    (token0   <ft-trait>)
    (token1   <ft-trait>))

  (let ((sender   tx-sender)
        (contract contract-caller) ;;router-proxy
        (protocol (as-contract tx-sender))
        (t0       (contract-of token0))
        (t1       (contract-of token1))
        (entry    (unwrap! (lookup t0 t1) err-retrieve-preconditions))
        (entry_   (get val entry))
        (amt0     (get amt0 entry_))
        (amt1     (get amt1 entry_))
        (t0_      (if (get flipped entry) token1 token0))
        (t1_      (if (get flipped entry) token0 token1)))

    (asserts!
      (and (is-eq sender (var-get RETRIEVER)))
      err-retrieve-preconditions)

      ;; global state
      (try! (as-contract (contract-call? t0_ transfer amt0 protocol contract none)))
      (try! (as-contract (contract-call? t1_ transfer amt1 protocol contract none)))
      ;; local state

      (print { sender: sender, contract: contract, protocol: protocol })
      (ok entry_)
  ))

;;; eof

```
