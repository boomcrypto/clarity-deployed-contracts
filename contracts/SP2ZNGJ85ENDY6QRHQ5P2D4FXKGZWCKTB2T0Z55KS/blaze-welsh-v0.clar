;; title: blaze
;; authors: rozar.btc, brice.btc
;; version: 0.1.1
;; summary: A permissionless credit tracking system for SIP-010 tokens with automatic
;;   deposits, withdrawals, and off-chain signed transfers.

;; Constants for SIP-018 structured data
(define-constant structured-data-prefix 0x534950303138)
(define-constant message-domain-hash (sha256 (unwrap-panic (to-consensus-buff?
  {
    name: "blaze",
    version: "0.1.1",
    chain-id: chain-id
  }
))))
(define-constant structured-data-header (concat structured-data-prefix message-domain-hash))

;; Errors
(define-constant ERR_INSUFFICIENT_BALANCE (err u100))
(define-constant ERR_INVALID_SIGNATURE (err u101))
(define-constant ERR_NONCE_TOO_LOW (err u102))
(define-constant ERR_CONSENSUS_BUFF (err u103))
(define-constant ERR_TOO_MANY_OPERATIONS (err u104))
(define-constant ERR_TRANSFER_FAILED (err u105))

;; Constants
(define-constant MAX_BATCH_SIZE u200)

;; Maps
(define-map balances { owner: principal } { amount: uint })
(define-map nonces principal uint)

;; Public Functions

;; Deposit tokens and receive credits
(define-public (deposit (amount uint))
  (let
    (
      (sender tx-sender)
      (balance-key { owner: sender })
      (current-balance (default-to { amount: u0 } (map-get? balances balance-key)))
    )
    ;; First transfer tokens to contract
    (try! (contract-call? 'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token transfer amount sender (as-contract tx-sender) none))
    
    ;; Then credit the balance
    (map-set balances balance-key
      { amount: (+ (get amount current-balance) amount) }
    )
    
    (print {
      event: "deposit",
      user: sender,
      amount: amount
    })
    (ok true)
  )
)

;; Withdraw tokens by spending credits
(define-public (withdraw (amount uint))
  (let
    (
      (sender tx-sender)
      (balance-key { owner: sender })
      (current-balance (default-to { amount: u0 } (map-get? balances balance-key)))
    )
    ;; Check sufficient balance
    (asserts! (>= (get amount current-balance) amount) ERR_INSUFFICIENT_BALANCE)
    
    ;; First reduce the credit balance
    (map-set balances balance-key
      { amount: (- (get amount current-balance) amount) }
    )
    
    ;; Then transfer tokens from contract
    (try! (as-contract (contract-call? 'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token transfer amount tx-sender sender none)))
    
    (print {
      event: "withdraw",
      user: sender,
      amount: amount
    })
    (ok true)
  )
)

;; Transfer credits between users
(define-public (transfer
  (signature (buff 65))
  (signer principal)
  (to principal)
  (amount uint)
  (nonce uint)
)
  (let 
    (
      (from-balance-key { owner: signer })
      (to-balance-key { owner: to })
      (current-from-balance (default-to { amount: u0 } (map-get? balances from-balance-key)))
      (current-to-balance (default-to { amount: u0 } (map-get? balances to-balance-key)))
      (current-nonce (default-to u0 (map-get? nonces signer)))
    )
    ;; Verify nonce
    (asserts! (> nonce current-nonce) ERR_NONCE_TOO_LOW)
    
    ;; Verify signature
    (asserts! (verify-signature signature signer to amount nonce) ERR_INVALID_SIGNATURE)
    
    ;; Check balance
    (asserts! (>= (get amount current-from-balance) amount) ERR_INSUFFICIENT_BALANCE)
    
    ;; Update balances
    (map-set balances from-balance-key
      { amount: (- (get amount current-from-balance) amount) }
    )
    (map-set balances to-balance-key
      { amount: (+ (get amount current-to-balance) amount) }
    )
    
    ;; Update nonce
    (map-set nonces signer nonce)
    
    (print {
      event: "transfer",
      from: signer,
      to: to,
      amount: amount,
      nonce: nonce
    })
    (ok true)
  )
)

;; Batch credit transfers with success/failure tracking
(define-public (batch-transfer
    (operations (list 200 {
      signature: (buff 65),
      signer: principal,
      to: principal,
      amount: uint,
      nonce: uint,
    }))
  )
  (let
    (
      (results (map try-transfer operations))
    )
    (asserts! (<= (len operations) MAX_BATCH_SIZE) ERR_TOO_MANY_OPERATIONS)
    (ok results)
  )
)

;; Read-only functions

(define-read-only (get-balance (owner principal))
  (get amount (default-to { amount: u0 }
    (map-get? balances { owner: owner })))
)

(define-read-only (get-nonce (owner principal))
  (default-to u0 (map-get? nonces owner))
)

;;; Validates that `signature` is a valid signature from `signer for the
;;; structured data constructed from the other arguments.
;;; Returns:
;;; - `true` if the signature is valid.
;;; - `false` if the signature is invalid.
(define-read-only (verify-signature
    (signature (buff 65))
    (signer principal)
    (to principal)
    (amount uint)
    (nonce uint)
  )
  (let ((hash (unwrap! (make-structured-data-hash to amount nonce) false)))
    (verify-hash-signature hash signature signer)
  )
)

;;; Generate a hash of the structured data for a transfer.
;;; Returns:
;;; - (ok (buff 32)) with the hash of the structured data on success
;;; - `ERR_CONSENSUS_BUFF` if the structured data cannot be converted to a
;;;   consensus buff
(define-read-only (make-structured-data-hash
    (to principal)
    (amount uint)
    (nonce uint)
  )
  (let (
      (structured-data { to: to, amount: amount, nonce: nonce })
      (data-hash (sha256 (unwrap! (to-consensus-buff? structured-data) ERR_CONSENSUS_BUFF)))
    )
    (ok (sha256 (concat structured-data-header data-hash)))
  )
)

;; Private functions

;;; Verify a signature for a hash.
;;; Returns `true` if the signature is valid, `false` otherwise.
(define-private (verify-hash-signature
    (hash (buff 32))
    (signature (buff 65))
    (signer principal)
  )
  (is-eq (principal-of? (unwrap! (secp256k1-recover? hash signature) false)) (ok signer))
)

(define-private (try-transfer
    (operation {
      signature: (buff 65),
      signer: principal,
      to: principal,
      amount: uint,
      nonce: uint,
    })
  )
  (match (transfer
    (get signature operation)
    (get signer operation)
    (get to operation)
    (get amount operation)
    (get nonce operation)
  )
    success true
    error false
  )
)