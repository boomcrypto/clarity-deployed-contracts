---
title: "Trait multihop"
draft: true
---
```
;; Title: Multi-hop Router
;; Version: 1.0.0
;; Description: 
;;   Router contract for executing multi-hop swaps across liquidity pools 
;;   that implement the execute/quote interface.

;; Use Traits
(use-trait pool-trait .dexterity-traits-v0.liquidity-pool-trait)

;; @desc Execute swap through a single pool
(define-private (execute-swap 
    (amount uint) 
    (hop {pool: <pool-trait>, opcode: (optional (buff 16))}))
  (let ((pool (get pool hop)))
    (contract-call? pool execute amount (get opcode hop))))
  
;; --- Core Functions ---

;; @desc Execute single swap through one pool
(define-public (swap-1 
    (amount uint) 
    (hop-1 {pool: <pool-trait>, opcode: (optional (buff 16))}))
  (let ((result (try! (execute-swap amount hop-1))))
    (ok (list result))))

;; @desc Execute two-hop swap through two pools
(define-public (swap-2
    (amount uint)
    (hop-1 {pool: <pool-trait>, opcode: (optional (buff 16))})
    (hop-2 {pool: <pool-trait>, opcode: (optional (buff 16))}))
  (let (
    (result-1 (try! (execute-swap amount hop-1)))
    (result-2 (try! (execute-swap (get dy result-1) hop-2))))
    (ok (list result-1 result-2))))

;; @desc Execute three-hop swap through three pools
(define-public (swap-3
    (amount uint)
    (hop-1 {pool: <pool-trait>, opcode: (optional (buff 16))})
    (hop-2 {pool: <pool-trait>, opcode: (optional (buff 16))})
    (hop-3 {pool: <pool-trait>, opcode: (optional (buff 16))}))
  (let (
    (result-1 (try! (execute-swap amount hop-1)))
    (result-2 (try! (execute-swap (get dy result-1) hop-2)))
    (result-3 (try! (execute-swap (get dy result-2) hop-3))))
    (ok (list result-1 result-2 result-3))))

;; @desc Execute four-hop swap
(define-public (swap-4
    (amount uint)
    (hop-1 {pool: <pool-trait>, opcode: (optional (buff 16))})
    (hop-2 {pool: <pool-trait>, opcode: (optional (buff 16))})
    (hop-3 {pool: <pool-trait>, opcode: (optional (buff 16))})
    (hop-4 {pool: <pool-trait>, opcode: (optional (buff 16))}))
  (let (
    (result-1 (try! (execute-swap amount hop-1)))
    (result-2 (try! (execute-swap (get dy result-1) hop-2)))
    (result-3 (try! (execute-swap (get dy result-2) hop-3)))
    (result-4 (try! (execute-swap (get dy result-3) hop-4))))
    (ok (list result-1 result-2 result-3 result-4))))

;; @desc Execute five-hop swap
(define-public (swap-5
    (amount uint)
    (hop-1 {pool: <pool-trait>, opcode: (optional (buff 16))})
    (hop-2 {pool: <pool-trait>, opcode: (optional (buff 16))})
    (hop-3 {pool: <pool-trait>, opcode: (optional (buff 16))})
    (hop-4 {pool: <pool-trait>, opcode: (optional (buff 16))})
    (hop-5 {pool: <pool-trait>, opcode: (optional (buff 16))}))
  (let (
    (result-1 (try! (execute-swap amount hop-1)))
    (result-2 (try! (execute-swap (get dy result-1) hop-2)))
    (result-3 (try! (execute-swap (get dy result-2) hop-3)))
    (result-4 (try! (execute-swap (get dy result-3) hop-4)))
    (result-5 (try! (execute-swap (get dy result-4) hop-5))))
    (ok (list result-1 result-2 result-3 result-4 result-5))))

;; @desc Execute six-hop swap
(define-public (swap-6
    (amount uint)
    (hop-1 {pool: <pool-trait>, opcode: (optional (buff 16))})
    (hop-2 {pool: <pool-trait>, opcode: (optional (buff 16))})
    (hop-3 {pool: <pool-trait>, opcode: (optional (buff 16))})
    (hop-4 {pool: <pool-trait>, opcode: (optional (buff 16))})
    (hop-5 {pool: <pool-trait>, opcode: (optional (buff 16))})
    (hop-6 {pool: <pool-trait>, opcode: (optional (buff 16))}))
  (let (
    (result-1 (try! (execute-swap amount hop-1)))
    (result-2 (try! (execute-swap (get dy result-1) hop-2)))
    (result-3 (try! (execute-swap (get dy result-2) hop-3)))
    (result-4 (try! (execute-swap (get dy result-3) hop-4)))
    (result-5 (try! (execute-swap (get dy result-4) hop-5)))
    (result-6 (try! (execute-swap (get dy result-5) hop-6))))
    (ok (list result-1 result-2 result-3 result-4 result-5 result-6))))

;; @desc Execute seven-hop swap
(define-public (swap-7
    (amount uint)
    (hop-1 {pool: <pool-trait>, opcode: (optional (buff 16))})
    (hop-2 {pool: <pool-trait>, opcode: (optional (buff 16))})
    (hop-3 {pool: <pool-trait>, opcode: (optional (buff 16))})
    (hop-4 {pool: <pool-trait>, opcode: (optional (buff 16))})
    (hop-5 {pool: <pool-trait>, opcode: (optional (buff 16))})
    (hop-6 {pool: <pool-trait>, opcode: (optional (buff 16))})
    (hop-7 {pool: <pool-trait>, opcode: (optional (buff 16))}))
  (let (
    (result-1 (try! (execute-swap amount hop-1)))
    (result-2 (try! (execute-swap (get dy result-1) hop-2)))
    (result-3 (try! (execute-swap (get dy result-2) hop-3)))
    (result-4 (try! (execute-swap (get dy result-3) hop-4)))
    (result-5 (try! (execute-swap (get dy result-4) hop-5)))
    (result-6 (try! (execute-swap (get dy result-5) hop-6)))
    (result-7 (try! (execute-swap (get dy result-6) hop-7))))
    (ok (list result-1 result-2 result-3 result-4 result-5 result-6 result-7))))

;; @desc Execute eight-hop swap
(define-public (swap-8
    (amount uint)
    (hop-1 {pool: <pool-trait>, opcode: (optional (buff 16))})
    (hop-2 {pool: <pool-trait>, opcode: (optional (buff 16))})
    (hop-3 {pool: <pool-trait>, opcode: (optional (buff 16))})
    (hop-4 {pool: <pool-trait>, opcode: (optional (buff 16))})
    (hop-5 {pool: <pool-trait>, opcode: (optional (buff 16))})
    (hop-6 {pool: <pool-trait>, opcode: (optional (buff 16))})
    (hop-7 {pool: <pool-trait>, opcode: (optional (buff 16))})
    (hop-8 {pool: <pool-trait>, opcode: (optional (buff 16))}))
  (let (
    (result-1 (try! (execute-swap amount hop-1)))
    (result-2 (try! (execute-swap (get dy result-1) hop-2)))
    (result-3 (try! (execute-swap (get dy result-2) hop-3)))
    (result-4 (try! (execute-swap (get dy result-3) hop-4)))
    (result-5 (try! (execute-swap (get dy result-4) hop-5)))
    (result-6 (try! (execute-swap (get dy result-5) hop-6)))
    (result-7 (try! (execute-swap (get dy result-6) hop-7)))
    (result-8 (try! (execute-swap (get dy result-7) hop-8))))
    (ok (list result-1 result-2 result-3 result-4 result-5 result-6 result-7 result-8))))

;; @desc Execute nine-hop swap
(define-public (swap-9
    (amount uint)
    (hop-1 {pool: <pool-trait>, opcode: (optional (buff 16))})
    (hop-2 {pool: <pool-trait>, opcode: (optional (buff 16))})
    (hop-3 {pool: <pool-trait>, opcode: (optional (buff 16))})
    (hop-4 {pool: <pool-trait>, opcode: (optional (buff 16))})
    (hop-5 {pool: <pool-trait>, opcode: (optional (buff 16))})
    (hop-6 {pool: <pool-trait>, opcode: (optional (buff 16))})
    (hop-7 {pool: <pool-trait>, opcode: (optional (buff 16))})
    (hop-8 {pool: <pool-trait>, opcode: (optional (buff 16))})
    (hop-9 {pool: <pool-trait>, opcode: (optional (buff 16))}))
  (let (
    (result-1 (try! (execute-swap amount hop-1)))
    (result-2 (try! (execute-swap (get dy result-1) hop-2)))
    (result-3 (try! (execute-swap (get dy result-2) hop-3)))
    (result-4 (try! (execute-swap (get dy result-3) hop-4)))
    (result-5 (try! (execute-swap (get dy result-4) hop-5)))
    (result-6 (try! (execute-swap (get dy result-5) hop-6)))
    (result-7 (try! (execute-swap (get dy result-6) hop-7)))
    (result-8 (try! (execute-swap (get dy result-7) hop-8)))
    (result-9 (try! (execute-swap (get dy result-8) hop-9))))
    (ok (list result-1 result-2 result-3 result-4 result-5 result-6 result-7 result-8 result-9))))
```
