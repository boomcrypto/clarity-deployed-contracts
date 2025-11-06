;; Title: NOT Sublink
;; Version: 1.0.0
;; Description: A vault for moving tokens to and from the subnet

(impl-trait 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.dexterity-traits-v0.liquidity-pool-trait)

;; Constants
(define-constant DEPLOYER tx-sender)
(define-constant CONTRACT (as-contract tx-sender))
(define-constant ERR_INVALID_OPERATION (err u4002))

;; Opcodes
(define-constant OP_DEPOSIT  0x05)  ;; Deposit tokens to subnet
(define-constant OP_WITHDRAW 0x06)  ;; Withdraw tokens from subnet

;; Vault Metadata
(define-data-var token-uri (optional (string-utf8 256)) (some u"data:application/json;base64,eyJuYW1lIjoiTk9ULXN1YmxpbmsiLCJpbWFnZSI6ImRhdGE6aW1hZ2UvcG5nO2Jhc2U2NCxpVkJPUncwS0dnb0FBQUFOU1VoRVVnQUFBQUVBQUFBQkNBWUFBQUFmRmNTSkFBQUFBWE5TUjBJQXJzNGM2UUFBQUExSlJFRlVHRmRqK1BmUTRUOEFDQjhESC80bjVwb0FBQUFBU1VWT1JLNUNZSUk9In0="))
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
    (begin
        (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.nope-subnet deposit amount (some recipient)))
        (ok {dx: amount, dy: amount, dk: u0})))

(define-public (withdraw (amount uint) (recipient principal))
    (begin
        (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.nope-subnet withdraw amount (some recipient)))
        (ok {dx: amount, dy: amount, dk: u0})))