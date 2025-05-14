---
title: "Trait sub-link-vault-v6"
draft: true
---
```
;; Constants
(define-constant DEPLOYER tx-sender)
(define-constant CONTRACT (as-contract tx-sender))
(define-constant ERR_INVALID_OPERATION (err u4002))

;; Opcodes
(define-constant OP_DEPOSIT  0x05)      ;; Swap token A for B
(define-constant OP_WITHDRAW 0x06)      ;; Swap token B for A

;; Vault Metadata
(define-data-var token-uri (optional (string-utf8 256)) (some u"https://charisma-metadata.vercel.app/api/v1/metadata/SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.sub-link"))
(define-read-only (get-token-uri) (ok (var-get token-uri)))

;; --- Helper Functions ---

(define-private (get-byte (opcode (optional (buff 16))) (position uint))
    (default-to 0x00 (element-at? (default-to 0x00 opcode) position)))

;; --- Core Functions ---

(define-public (execute (amount uint) (opcode (optional (buff 16))))
    (let (
        (operation (get-byte opcode u0)))
        (if (is-eq operation OP_DEPOSIT) (deposit amount tx-sender)
        (if (is-eq operation OP_WITHDRAW) (withdraw amount tx-sender)
        ERR_INVALID_OPERATION))))

(define-read-only (quote (amount uint) (opcode (optional (buff 16))))
    (let (
        (operation (get-byte opcode u0)))
        (if (is-eq operation OP_DEPOSIT) (ok (get-deposit-quote amount))
        (if (is-eq operation OP_WITHDRAW) (ok (get-withdraw-quote amount))
        ERR_INVALID_OPERATION))))

(define-read-only (get-deposit-quote (amount uint))
    {dx: amount, dy: amount, dk: u0})

(define-read-only (get-withdraw-quote (amount uint))
    {dx: amount, dy: amount, dk: u0})


(define-public (deposit (amount uint) (recipient principal))
    (contract-call? .charisma-token-subnet-v1 deposit amount (some recipient)))

(define-public (withdraw (amount uint) (recipient principal))
    (contract-call? .charisma-token-subnet-v1 withdraw amount (some recipient)))

;; --- Subnet Functions ---

(define-public (x-execute (amount uint) (opcode (buff 16)) (signature (buff 65)) (uuid (string-ascii 36)) (recipient principal))
    ERR_INVALID_OPERATION)

```
