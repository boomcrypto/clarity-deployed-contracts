;; Title: Off-Chain Multi-hop Router
;; Version: 1.0.0
;; Description: 
;;   Router contract for executing multi-hop swaps across liquidity vaults 
;;   that implement the x-execute interface for subnet compatibility.

;; Use Traits
(define-trait x-vault-trait
  (
    (x-execute 
      (uint (optional (buff 16)) (buff 65) (string-ascii 36) principal)
      (response (tuple (dx uint) (dy uint) (dk uint)) uint))
  )
)

(define-trait vault-trait
  (
    (execute 
      (uint (optional (buff 16))) 
      (response (tuple (dx uint) (dy uint) (dk uint)) uint))
  )
)

;; Constants
(define-constant CONTRACT (as-contract tx-sender))

;; @desc Execute signed swap through a single vault
(define-private (x-swap 
    (amount uint) 
    (hop {vault: <x-vault-trait>, opcode: (optional (buff 16)), signature: (buff 65), uuid: (string-ascii 36)})
    (recipient principal)
  )
  (let (
    (vault (get vault hop)) 
    (signature (get signature hop)) 
    (uuid (get uuid hop)) 
    (opcode (get opcode hop)))
    (as-contract (contract-call? vault x-execute amount opcode signature uuid recipient))))

;; @desc Execute swap through a single vault
(define-private (swap 
    (amount uint) 
    (hop {vault: <vault-trait>, opcode: (optional (buff 16))}))
  (let (
    (vault (get vault hop)) 
    (opcode (get opcode hop)))
    (as-contract (contract-call? vault execute amount opcode))))
  
;; --- Core Functions ---

;; @desc Execute single swap through one vault with signatures
(define-public (x-swap-1 
    (amount uint) 
    (hop-1 {vault: <x-vault-trait>, opcode: (optional (buff 16)), signature: (buff 65), uuid: (string-ascii 36)})
    (recipient principal)
  )
  (let (
    (result (try! (x-swap amount hop-1 recipient))))
    (ok (list result))))

;; @desc Execute two-hop swap through two vaults with signatures
(define-public (x-swap-2
    (amount uint)
    (hop-1 {vault: <x-vault-trait>, opcode: (optional (buff 16)), signature: (buff 65), uuid: (string-ascii 36)})
    (hop-2 {vault: <vault-trait>, opcode: (optional (buff 16))})
    (recipient principal)
  )
  (let (
    (result-1 (try! (x-swap amount hop-1 CONTRACT)))
    (result-2 (try! (swap (get dy result-1) hop-2 recipient))))
    (ok (list result-1 result-2))))

;; @desc Execute three-hop swap through three vaults with signatures
(define-public (x-swap-3
    (amount uint)
    (hop-1 {vault: <x-vault-trait>, opcode: (optional (buff 16)), signature: (buff 65), uuid: (string-ascii 36)})
    (hop-2 {vault: <vault-trait>, opcode: (optional (buff 16))})
    (hop-3 {vault: <vault-trait>, opcode: (optional (buff 16))})
    (recipient principal)
  )
  (let (
    (result-1 (try! (x-swap amount hop-1 CONTRACT)))
    (result-2 (try! (swap (get dy result-1) hop-2 CONTRACT)))
    (result-3 (try! (swap (get dy result-2) hop-3 recipient))))
    (ok (list result-1 result-2 result-3))))

;; @desc Execute single swap through one vault
(define-public (swap-1 
    (amount uint) 
    (hop-1 {vault: <vault-trait>, opcode: (optional (buff 16))})
    (recipient principal)
  )
  (let (
    (result (try! (swap amount hop-1 recipient))))
    (ok (list result))))

;; @desc Execute two-hop swap through two vaults
(define-public (swap-2
    (amount uint)
    (hop-1 {vault: <vault-trait>, opcode: (optional (buff 16))})
    (hop-2 {vault: <vault-trait>, opcode: (optional (buff 16))})
    (recipient principal)
  )
  (let (
    (result-1 (try! (swap amount hop-1 CONTRACT)))
    (result-2 (try! (swap (get dy result-1) hop-2 recipient))))
    (ok (list result-1 result-2))))

;; @desc Execute three-hop swap through three vaults
(define-public (swap-3
    (amount uint)
    (hop-1 {vault: <vault-trait>, opcode: (optional (buff 16))})
    (hop-2 {vault: <vault-trait>, opcode: (optional (buff 16))})
    (hop-3 {vault: <vault-trait>, opcode: (optional (buff 16))})
    (recipient principal)
  )
  (let (
    (result-1 (try! (swap amount hop-1 CONTRACT)))
    (result-2 (try! (swap (get dy result-1) hop-2 CONTRACT)))
    (result-3 (try! (swap (get dy result-2) hop-3 recipient))))
    (ok (list result-1 result-2 result-3))))