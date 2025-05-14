---
title: "Trait sub-link-vault-v8"
draft: true
---
```
;; Title: SUB_LINK Vault
;; Version: 1.0.0
;; Description: A vault for moving tokens to and from the subnet

;; Constants
(define-constant DEPLOYER tx-sender)
(define-constant CONTRACT (as-contract tx-sender))
(define-constant ERR_INVALID_OPERATION (err u4002))

;; Opcodes
(define-constant OP_DEPOSIT  0x05)      ;; Deposit tokens to subnet
(define-constant OP_WITHDRAW 0x06)      ;; Withdraw tokens from subnet

;; Vault Metadata
(define-data-var token-uri (optional (string-utf8 256)) (some u"https://charisma-metadata.vercel.app/api/v1/metadata/SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.sub-link"))
(define-read-only (get-token-uri) (ok (var-get token-uri)))

;; --- Helper Functions ---

(define-private (get-byte (opcode (buff 16)) (position uint))
    (default-to 0x00 (element-at? opcode position)))

;; --- Core Functions ---
;; The execute function now properly conforms to the trait

(define-public (execute (amount uint) (opcode (buff 16)) (recipient principal))
    (let (
        (operation (get-byte opcode u0)))
        (if (is-eq operation OP_DEPOSIT) (deposit amount tx-sender)
        (if (is-eq operation OP_WITHDRAW) (withdraw amount recipient)
        ERR_INVALID_OPERATION))))

(define-read-only (quote (amount uint) (opcode (buff 16)) (recipient principal))
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
    (begin
        (try! (contract-call? .charisma-token-subnet-v1 deposit amount (some recipient)))
        (ok {dx: amount, dy: amount, dk: u0})))

(define-public (withdraw (amount uint) (recipient principal))
    (begin
        (try! (contract-call? .charisma-token-subnet-v1 withdraw amount (some recipient)))
        (ok {dx: amount, dy: amount, dk: u0})))

;; --- Subnet Functions ---

(define-public (x-execute (amount uint) (opcode (buff 16)) (signature (buff 65)) (uuid (string-ascii 36)) (recipient principal))
    (let (
        (operation (get-byte opcode u0)))
        (if (is-eq operation OP_DEPOSIT) (x-deposit amount signature uuid recipient)
        (if (is-eq operation OP_WITHDRAW) (x-withdraw amount signature uuid recipient)
        ERR_INVALID_OPERATION))))

(define-public (x-deposit (amount uint) (signature (buff 65)) (uuid (string-ascii 36)) (recipient principal))
    (begin
        (unwrap-panic (contract-call? .charisma-token-subnet-v1 x-transfer signature amount uuid CONTRACT))
        (contract-call? .charisma-token-subnet-v1 deposit amount (some recipient))))

(define-public (x-withdraw (amount uint) (signature (buff 65)) (uuid (string-ascii 36)) (recipient principal))
    (begin
        (unwrap-panic (contract-call? .charisma-token-subnet-v1 x-transfer signature amount uuid CONTRACT))
        (contract-call? .charisma-token-subnet-v1 withdraw amount (some recipient))))
```
