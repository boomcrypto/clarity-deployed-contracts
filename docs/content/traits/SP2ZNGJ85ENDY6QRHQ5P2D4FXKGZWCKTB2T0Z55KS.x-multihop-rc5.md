---
title: "Trait x-multihop-rc5"
draft: true
---
```
;; Title: Multi-hop Router
;; Version: 1.0.0
;; Description: 
;;   Router contract for executing multi-hop swaps across liquidity pools 
;;   that implement the vault interface for subnet compatibility.

;; Constants
(define-constant CONTRACT (as-contract tx-sender))

;; Traits
(define-trait x-vault-trait (
    (x-execute 
      (uint (buff 16) (buff 65) (string-ascii 36) principal)
      (response (tuple (dx uint) (dy uint) (dk uint)) uint))))

(define-trait vault-trait (
    (execute 
      (uint (buff 16) principal) 
      (response (tuple (dx uint) (dy uint) (dk uint)) uint))))

;; @desc Execute signed swap through a single vault
(define-private (x-swap 
    (amount uint) 
    (hop {vault: <x-vault-trait>, opcode: (buff 16), signature: (buff 65), uuid: (string-ascii 36)})
    (recipient principal))
  (let (
    (vault (get vault hop)) 
    (signature (get signature hop)) 
    (uuid (get uuid hop)) 
    (opcode (get opcode hop)))
    (as-contract (contract-call? vault x-execute amount opcode signature uuid recipient))))

;; @desc Execute sender swap through a single vault
(define-private (s-swap 
    (amount uint) 
    (hop {vault: <vault-trait>, opcode: (buff 16)})
    (recipient principal))
  (let (
    (vault (get vault hop)) 
    (opcode (get opcode hop)))
    (contract-call? vault execute amount opcode recipient)))

;; @desc Execute contract swap through a single vault
(define-private (c-swap 
    (amount uint) 
    (hop {vault: <vault-trait>, opcode: (buff 16)})
    (recipient principal))
  (let (
    (vault (get vault hop)) 
    (opcode (get opcode hop)))
    (as-contract (contract-call? vault execute amount opcode recipient))))
  
;; --- Subnet Functions ---

;; @desc Execute single swap through one vault with signatures
(define-public (x-swap-1 
    (amount uint) 
    (hop-1 {vault: <x-vault-trait>, opcode: (buff 16), signature: (buff 65), uuid: (string-ascii 36)})
    (recipient principal))
  (let (
    (result (try! (x-swap amount hop-1 recipient))))
    (ok (list result))))

;; @desc Execute two-hop swap through two vaults with signatures
(define-public (x-swap-2
    (amount uint)
    (hop-1 {vault: <x-vault-trait>, opcode: (buff 16), signature: (buff 65), uuid: (string-ascii 36)})
    (hop-2 {vault: <vault-trait>, opcode: (buff 16)})
    (recipient principal))
  (let (
    (result-1 (try! (x-swap amount hop-1 CONTRACT)))
    (result-2 (try! (c-swap (get dy result-1) hop-2 recipient))))
    (ok (list result-1 result-2))))

;; @desc Execute three-hop swap through three vaults with signatures
(define-public (x-swap-3
    (amount uint)
    (hop-1 {vault: <x-vault-trait>, opcode: (buff 16), signature: (buff 65), uuid: (string-ascii 36)})
    (hop-2 {vault: <vault-trait>, opcode: (buff 16)})
    (hop-3 {vault: <vault-trait>, opcode: (buff 16)})
    (recipient principal))
  (let (
    (result-1 (try! (x-swap amount hop-1 CONTRACT)))
    (result-2 (try! (c-swap (get dy result-1) hop-2 CONTRACT)))
    (result-3 (try! (c-swap (get dy result-2) hop-3 recipient))))
    (ok (list result-1 result-2 result-3))))
  
;; --- Core Functions ---

;; @desc Execute single swap through one vault
(define-public (swap-1 
    (amount uint) 
    (hop-1 {vault: <vault-trait>, opcode: (buff 16)})
    (recipient principal))
  (let (
    (result (try! (s-swap amount hop-1 recipient))))
    (ok (list result))))

;; @desc Execute two-hop swap through two vaults
(define-public (swap-2
    (amount uint)
    (hop-1 {vault: <vault-trait>, opcode: (buff 16)})
    (hop-2 {vault: <vault-trait>, opcode: (buff 16)})
    (recipient principal))
  (let (
    (result-1 (try! (s-swap amount hop-1 CONTRACT)))
    (result-2 (try! (c-swap (get dy result-1) hop-2 recipient))))
    (ok (list result-1 result-2))))

;; @desc Execute three-hop swap through three vaults
(define-public (swap-3
    (amount uint)
    (hop-1 {vault: <vault-trait>, opcode: (buff 16)})
    (hop-2 {vault: <vault-trait>, opcode: (buff 16)})
    (hop-3 {vault: <vault-trait>, opcode: (buff 16)})
    (recipient principal))
  (let (
    (result-1 (try! (s-swap amount hop-1 CONTRACT)))
    (result-2 (try! (c-swap (get dy result-1) hop-2 CONTRACT)))
    (result-3 (try! (c-swap (get dy result-2) hop-3 recipient))))
    (ok (list result-1 result-2 result-3))))
```
