---
title: "Trait bwpt9"
draft: true
---
```
;; Title: blaze
;; Version: welsh-predict-v1
;; Description: 
;;   Implementation of a prediction market vault for the Stacks blockchain that
;;   supports both on-chain and off-chain (signed) operations.
;;   Allows users to create markets, make predictions, and claim rewards.
;;   Market resolution is controlled by the vault deployer or authorized admins.
;;   Each prediction is tracked as a non-fungible token receipt.
;;   This version adds support for Blaze subnet tokens and signed operations.

;; Traits
;; (impl-trait 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.betting-traits-v0.betting-vault-trait)
;; (impl-trait 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.nft-trait.nft-trait)

;; Constants
(define-constant DEPLOYER tx-sender)
(define-constant CONTRACT (as-contract tx-sender))
(define-constant ERR_UNAUTHORIZED (err u403))
(define-constant ERR_INVALID_OPERATION (err u400))
(define-constant ERR_MARKET_EXISTS (err u401))
(define-constant ERR_MARKET_NOT_FOUND (err u404))
(define-constant ERR_MARKET_CLOSED (err u405))
(define-constant ERR_MARKET_NOT_RESOLVED (err u406))
(define-constant ERR_NOT_WINNER (err u408))
(define-constant ERR_INVALID_OUTCOME (err u409))
(define-constant ERR_INVALID_TOKEN_ID (err u410))
(define-constant ERR_NO_PREDICTION (err u411))
(define-constant ERR_PREDICTION_NOT_FOUND (err u412))
(define-constant ERR_INSUFFICIENT_BALANCE (err u413))
(define-constant ERR_INVALID_SIGNATURE (err u414))
(define-constant ERR_NONCE_TOO_LOW (err u415))
(define-constant ERR_CONSENSUS_BUFF (err u416))
(define-constant ERR_TOO_MANY_OPERATIONS (err u417))
(define-constant ERR_PREDICTION_FAILED (err u418))
(define-constant ERR_CLAIM_FAILED (err u419))
(define-constant PRECISION u1000000)
(define-constant ADMIN_FEE u50000)   ;; 5% fee to admin who resolves the market
(define-constant MAX_BATCH_SIZE u200)  ;; Maximum number of operations in a batch

;; Opcodes (0xA* range to avoid LP conflicts)
(define-constant OP_PREDICT 0xA1)    ;; Make a prediction
(define-constant OP_CLAIM_REWARD 0xA3)  ;; Claim rewards

;; Constants for SIP-018 structured data
(define-constant structured-data-prefix 0x534950303138)
(define-constant message-domain-hash (sha256 (unwrap-panic (to-consensus-buff?
  {
    name: "blaze",
    version: "welsh-predict-v1",
    chain-id: chain-id
  }
))))
(define-constant structured-data-header (concat structured-data-prefix message-domain-hash))

;; Define NFT for prediction receipts
(define-non-fungible-token prediction-receipt uint)

;; Data structures
(define-map markets (string-ascii 64) {
  creator: principal,
  name: (string-ascii 64),
  description: (string-ascii 128),
  outcome-names: (list 16 (string-ascii 32)),
  outcome-pools: (list 16 uint),
  total-pool: uint,
  is-open: bool,
  is-resolved: bool,
  winning-outcome: uint,
  resolver: (optional principal),  ;; Admin who resolved the market
  creation-time: uint,
  resolution-time: uint
})

;; Map to track receipts by receipt ID (no predictor field)
(define-map predictions uint {
  market-id: (string-ascii 64),
  outcome-id: uint,
  amount: uint
})

;; Map for authorized oracles/admins
(define-map authorized-admins principal bool)

;; Next token ID counter
(define-data-var next-receipt-id uint u1)

;; Token metadata URI
(define-data-var token-uri (string-utf8 256) u"https://charisma.rocks/sip9/predictions/receipt.json")

;; --- NFT Trait Functions ---

(define-public (transfer (receipt-id uint) (sender principal) (recipient principal))
    (begin
        (asserts! (is-eq tx-sender sender) ERR_UNAUTHORIZED)
        (nft-transfer? prediction-receipt receipt-id sender recipient)
    ))

(define-read-only (get-last-token-id)
    (ok (- (var-get next-receipt-id) u1)))

(define-read-only (get-token-uri (token-id uint))
    (ok (some (var-get token-uri))))

(define-public (set-token-uri (new-uri (string-utf8 256)))
    (begin
        (asserts! (is-eq tx-sender DEPLOYER) ERR_UNAUTHORIZED)
        (ok (var-set token-uri new-uri))
    ))

(define-read-only (get-owner (token-id uint))
    (ok (nft-get-owner? prediction-receipt token-id)))

;; --- Core Functions ---

;; (define-public (execute (amount uint) (opcode (optional (buff 16))))
;;     (let (
;;         (op-buffer (default-to 0x00 opcode))
;;         (op-type (get-byte op-buffer u0))
;;         (market-id (get-byte op-buffer u1))
;;         (outcome-id (get-byte op-buffer u2))
;;         (receipt-id amount))
;;         (if (is-eq op-type (buff-to-uint-le OP_PREDICT)) (make-prediction market-id outcome-id amount)
;;         (if (is-eq op-type (buff-to-uint-le OP_CLAIM_REWARD)) (claim-reward receipt-id)
;;         ERR_INVALID_OPERATION))))

;; (define-read-only (quote (amount uint) (opcode (optional (buff 16))))
;;     (let (
;;         (op-buffer (default-to 0x00 opcode))
;;         (op-type (get-byte op-buffer u0))
;;         (market-id (get-byte op-buffer u1))
;;         (outcome-id (get-byte op-buffer u2))
;;         (receipt-id amount))
;;         (if (is-eq op-type (buff-to-uint-le OP_PREDICT)) (quote-prediction market-id outcome-id)
;;         (if (is-eq op-type (buff-to-uint-le OP_CLAIM_REWARD)) (quote-reward receipt-id)
;;         ERR_INVALID_OPERATION))))

;; --- Market Management Functions ---

;; Create a new prediction market (standard function, not an opcode)
(define-public (create-market 
    (market-id (string-ascii 64)) 
    (name (string-ascii 64)) 
    (description (string-ascii 128))
    (outcome-names (list 16 (string-ascii 32))))
    (begin
        ;; Check if market ID already exists
        (asserts! (is-none (map-get? markets market-id)) ERR_MARKET_EXISTS)
        
        ;; Initialize empty outcome pools
        (let ((empty-pools (list 
            u0 u0 u0 u0 u0 u0 u0 u0
            u0 u0 u0 u0 u0 u0 u0 u0)))
            
            ;; Create a new prediction market
            (map-set markets market-id {
                creator: tx-sender,
                name: name,
                description: description,
                outcome-names: outcome-names,
                outcome-pools: empty-pools,
                total-pool: u0,
                is-open: true,
                is-resolved: false,
                winning-outcome: u0,
                resolver: none,
                creation-time: stacks-block-height,
                resolution-time: u0
            })
            
            (ok {
                market-id: market-id,
                creator: tx-sender,
                creation-time: stacks-block-height
            })
        )
    )
)

;; Close a market (no more predictions allowed)
(define-public (close-market (market-id (string-ascii 64)))
    (let ((market (unwrap! (map-get? markets market-id) ERR_MARKET_NOT_FOUND)))
        ;; Only vault deployer or authorized admin can close
        (asserts! (or 
            (is-eq tx-sender DEPLOYER)
            (default-to false (map-get? authorized-admins tx-sender))) 
            ERR_UNAUTHORIZED)
        
        ;; Update market status
        (map-set markets market-id (merge market { is-open: false }))
        
        (ok true)
    )
)

;; Resolve a market (determine correct outcome)
(define-public (resolve-market (market-id (string-ascii 64)) (winning-outcome uint))
    (let (
        (sender tx-sender)
        (market (unwrap! (map-get? markets market-id) ERR_MARKET_NOT_FOUND))
        (admin-fee (/ (* (get total-pool market) ADMIN_FEE) PRECISION))  ;; Calculate 5% fee
    )
        ;; Only vault deployer or authorized admin can resolve
        (asserts! (or 
            (is-eq sender DEPLOYER)
            (default-to false (map-get? authorized-admins sender))) 
            ERR_UNAUTHORIZED)
        
        ;; Check that outcome is valid
        (asserts! (< winning-outcome (len (get outcome-names market))) ERR_INVALID_OUTCOME)

        ;; Pay admin fee directly to resolver
        (try! (as-contract (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.blaze-welsh-v1 transfer admin-fee CONTRACT sender none)))
        
        ;; Update market state
        (map-set markets market-id (merge market {
            is-open: false,
            is-resolved: true,
            winning-outcome: winning-outcome,
            resolver: (some sender),
            resolution-time: stacks-block-height
        }))
        
        (ok true)
    )
)

;; --- Execute Functions ---

(define-public (make-prediction (market-id (string-ascii 64)) (outcome-id uint) (amount uint))
    (let (
        (sender tx-sender)
        (market (unwrap! (map-get? markets market-id) ERR_MARKET_NOT_FOUND))
        (receipt-id (var-get next-receipt-id)))
        
        ;; Verify market is open
        (asserts! (get is-open market) ERR_MARKET_CLOSED)
        
        ;; Verify outcome ID is valid
        (asserts! (< outcome-id (len (get outcome-names market))) ERR_INVALID_OUTCOME)
        
        ;; Transfer tokens to contract
        (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.blaze-welsh-v1 transfer amount sender CONTRACT none))

        ;; Store receipt data without predictor field
        (map-set predictions receipt-id {
            market-id: market-id,
            outcome-id: outcome-id,
            amount: amount
        })
        
        ;; Mint NFT receipt
        (try! (nft-mint? prediction-receipt receipt-id sender))
        
        ;; Update outcome pools
        (let (
            (current-pools (get outcome-pools market))
            (current-pool (default-to u0 (element-at? current-pools outcome-id)))
            (updated-pool (+ current-pool amount))
            (updated-pools (replace-at? current-pools outcome-id updated-pool)))
            
            ;; Update market state
            (map-set markets market-id (merge market {
                outcome-pools: (unwrap-panic updated-pools),
                total-pool: (+ (get total-pool market) amount)
            }))
            
            ;; Increment receipt ID counter
            (var-set next-receipt-id (+ receipt-id u1))
            
            (ok {
                dx: market-id,
                dy: updated-pool,
                dk: receipt-id
            })
        )
    )
)

;; Make a prediction using a signed transaction from the Blaze subnet token
(define-public (signed-predict
  (signet {signature: (buff 65), nonce: uint})
  (market-id (string-ascii 64))
  (outcome-id uint)
  (amount uint)
)
  (let (
    ;; Get the signer principal from the signet verification function in the subnet contract
    (signer-principal (unwrap! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.blaze-welsh-v1
                             verify-transfer-signer
                             signet
                             CONTRACT  ;; The target of the transfer is this contract
                             amount) 
                    ERR_INVALID_SIGNATURE))
    (market (unwrap! (map-get? markets market-id) ERR_MARKET_NOT_FOUND))
    (receipt-id (get nonce signet)))
    
    ;; Verify market is open
    (asserts! (get is-open market) ERR_MARKET_CLOSED)
    
    ;; Verify outcome ID is valid
    (asserts! (< outcome-id (len (get outcome-names market))) ERR_INVALID_OUTCOME)
    
    ;; Check if signer has sufficient balance in the blaze subnet
    (asserts! (>= (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.blaze-welsh-v1 get-balance signer-principal) amount) 
              ERR_INSUFFICIENT_BALANCE)
    
    ;; Transfer tokens from signer to contract using signed-transfer from subnet
    (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.blaze-welsh-v1 
           signed-transfer 
           signet    ;; We use the same signet for the transfer
           CONTRACT  ;; The target is this contract
           amount))  ;; Same amount we're using for the prediction
    
    ;; Store receipt data
    (map-set predictions receipt-id {
        market-id: market-id,
        outcome-id: outcome-id,
        amount: amount
    })
    
    ;; Mint NFT receipt to the signer (not tx-sender)
    (try! (nft-mint? prediction-receipt receipt-id signer-principal))
    
    ;; Update outcome pools
    (let (
        (current-pools (get outcome-pools market))
        (current-pool (default-to u0 (element-at? current-pools outcome-id)))
        (updated-pool (+ current-pool amount))
        (updated-pools (replace-at? current-pools outcome-id updated-pool)))
        
        ;; Update market state
        (map-set markets market-id (merge market {
            outcome-pools: (unwrap-panic updated-pools),
            total-pool: (+ (get total-pool market) amount)
        }))
        
        ;; Increment receipt ID counter
        (var-set next-receipt-id (+ receipt-id u1))
        
        (ok {
            dx: market-id,
            dy: updated-pool,
            dk: receipt-id
        })
    )
  )
)

;; Helper function that attempts to execute a signed prediction and returns a boolean
;; Used for batch operations to continue processing even if some predictions fail
(define-private (try-predict
  (operation {
    signet: {signature: (buff 65), nonce: uint},
    market-id: (string-ascii 64),
    outcome-id: uint, 
    amount: uint
  })
)
  (match (signed-predict
    (get signet operation)
    (get market-id operation)
    (get outcome-id operation)
    (get amount operation)
  )
    success true
    error false
  )
)

(define-public (claim-reward (receipt-id uint))
    (let (
        (sender tx-sender)
        (reward-quote (unwrap-panic (quote-reward receipt-id)))
        (total-reward (get dy reward-quote)))
        
        ;; Verify user owns the NFT receipt
        (asserts! (is-eq (some sender) (nft-get-owner? prediction-receipt receipt-id)) ERR_UNAUTHORIZED)

        ;; Verify has rewards
        (asserts! (> total-reward u0) ERR_NOT_WINNER)
        
        ;; Transfer reward to user
        (try! (as-contract (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.blaze-welsh-v1 transfer total-reward CONTRACT sender none)))
        
        ;; Burn the NFT receipt (marks as claimed)
        (try! (nft-burn? prediction-receipt receipt-id sender))
                
        (ok {
            dx: (get dx reward-quote),
            dy: total-reward,
            dk: receipt-id
        })
    )
)

;; Claim a reward using a signed transaction
(define-public (signed-claim-reward
  (signet {signature: (buff 65), nonce: uint})
  (receipt-id uint)
)
  (let (
    ;; Get the signer principal from our verify-receipt-signer function
    (signer-principal (unwrap! (verify-receipt-signer signet receipt-id) ERR_INVALID_SIGNATURE))
    (reward-quote (unwrap-panic (quote-reward receipt-id)))
    (total-reward (get dy reward-quote)))
    
    ;; Verify signer owns the NFT receipt
    (asserts! (is-eq (some signer-principal) (nft-get-owner? prediction-receipt receipt-id)) ERR_UNAUTHORIZED)

    ;; Verify has rewards
    (asserts! (> total-reward u0) ERR_NOT_WINNER)
    
    ;; Transfer reward to user through the subnet contract using SIP-010 standard interface
    ;; For rewards, we use the standard transfer since the contract is the sender
    (try! (as-contract (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.blaze-welsh-v1 
           transfer
           total-reward      ;; amount
           CONTRACT          ;; from (as-contract makes this the sender)
           signer-principal  ;; to
           none)))           ;; memo
    
    ;; Burn the NFT receipt (marks as claimed)
    (try! (nft-burn? prediction-receipt receipt-id signer-principal))
            
    (ok {
        dx: (get dx reward-quote),
        dy: total-reward,
        dk: receipt-id
    })
  )
)

;; Helper function that attempts to execute a signed claim reward and returns a boolean
;; Used for batch operations to continue processing even if some claims fail
(define-private (try-claim-reward
  (operation {
    signet: {signature: (buff 65), nonce: uint},
    receipt-id: uint
  })
)
  (match (signed-claim-reward
    (get signet operation)
    (get receipt-id operation)
  )
    success true
    error false
  )
)

;; ;; --- Quote Functions ---

;; (define-read-only (quote-prediction (market-id (string-ascii 64)) (outcome-id uint))
;;     (match (map-get? markets market-id)
;;         market 
;;         (if (not (get is-open market))
;;             (ok {
;;                 dx: u0,
;;                 dy: u0,
;;                 dk: u0
;;             })
;;             (let (
;;                 (outcome-pools (get outcome-pools market))
;;                 (outcome-pool (default-to u0 (element-at? outcome-pools outcome-id))))
;;                 (ok {
;;                     dx: market-id,
;;                     dy: outcome-pool,  ;; Current pool for this outcome
;;                     dk: (get total-pool market)  ;; Total pool across all outcomes
;;                 })
;;             ))
;;         ERR_MARKET_NOT_FOUND)
;; )

(define-read-only (quote-reward (receipt-id uint))
    (let (
        (prediction (unwrap! (map-get? predictions receipt-id) ERR_PREDICTION_NOT_FOUND))
        (market-id (get market-id prediction))
        (market (unwrap! (map-get? markets market-id) ERR_MARKET_NOT_FOUND)))
        
        ;; Verify market is resolved
        (if (get is-resolved market)
            (let (
                (outcome-id (get outcome-id prediction))
                (amount (get amount prediction))
                (total-pot (get total-pool market))
                (winning-outcome (get winning-outcome market))
                (winning-pool (default-to u0 (element-at? (get outcome-pools market) winning-outcome))))
                
                ;; Calculate reward with fee deduction in one step to preserve precision
                ;; First multiply by (PRECISION - ADMIN_FEE) to apply 95% factor
                ;; Then divide by PRECISION to normalize
                ;; This is equivalent to: (amount * total_pot * 0.95) / winning_pool
                (let (
                    (net-reward (if (and (is-eq outcome-id winning-outcome) (> winning-pool u0)) 
                                  (/ (* (* amount total-pot) (- PRECISION ADMIN_FEE)) (* winning-pool PRECISION))
                                  u0)))
                    
                    (ok {
                        dx: market-id,
                        dy: net-reward,
                        dk: receipt-id
                    })
                )
            )
            (ok {
                dx: market-id,
                dy: u0,
                dk: u0
            })
        )
    )
)

;; ;; --- Helper Functions ---

;; (define-read-only (get-byte (opcode (buff 16)) (position uint))
;;    (buff-to-uint-le (default-to 0x00 (element-at? opcode position))))

;;; Generate a hash of the structured data for redeeming a prediction receipt.
;;; This authorizes the receipt to be redeemed from the signer's account.
;;; Returns:
;;; - (ok (buff 32)) with the hash of the structured data on success
;;; - `ERR_CONSENSUS_BUFF` if the structured data cannot be converted to a
;;;   consensus buff
(define-read-only (make-redeem-receipt-hash
    (receipt-id uint)
    (nonce uint)
  )
  (let (
      (structured-data { receipt-id: receipt-id, nonce: nonce })
      (data-hash (sha256 (unwrap! (to-consensus-buff? structured-data) ERR_CONSENSUS_BUFF)))
    )
    (ok (sha256 (concat structured-data-header data-hash)))
  )
)

;;; Recovers a principal from a signature and message hash
;;; Returns:
;;; - (ok principal) with the address of the signer
;;; - ERR_INVALID_SIGNATURE if recovery fails
(define-read-only (get-signer
    (hash (buff 32))
    (signature (buff 65))
  )
  (match (secp256k1-recover? hash signature)
    public-key (principal-of? public-key)
    error ERR_INVALID_SIGNATURE
  )
)

;;; Verify a receipt redemption signet and return the signer principal
;;; This is a convenience function that combines make-redeem-receipt-hash and get-signer
;;; Returns:
;;; - (ok principal) with the address of the signer for the given signet + receipt
;;; - Error if signature verification fails
(define-read-only (verify-receipt-signer
    (signet {signature: (buff 65), nonce: uint})
    (receipt-id uint)
  )
  (let (
    (signature (get signature signet))
    (nonce (get nonce signet))
    (hash (unwrap! (make-redeem-receipt-hash receipt-id nonce) ERR_CONSENSUS_BUFF))
  )
    (get-signer hash signature)
  )
)

;; --- Admin Functions ---

(define-public (add-admin (admin principal))
    (begin
        (asserts! (is-eq tx-sender DEPLOYER) ERR_UNAUTHORIZED)
        (ok (map-set authorized-admins admin true))
    )
)

(define-public (remove-admin (admin principal))
    (begin
        (asserts! (is-eq tx-sender DEPLOYER) ERR_UNAUTHORIZED)
        (ok (map-set authorized-admins admin false))
    )
)

;; --- Market Info Functions ---

(define-read-only (get-market-info (market-id (string-ascii 64)))
    (match (map-get? markets market-id)
        market (ok market)
        ERR_MARKET_NOT_FOUND)
)

(define-read-only (get-receipt-info (receipt-id uint))
    (match (map-get? predictions receipt-id)
        receipt 
        (match (nft-get-owner? prediction-receipt receipt-id)
            owner (ok (merge receipt { predictor: owner }))
            (err ERR_INVALID_TOKEN_ID))
        (err ERR_INVALID_TOKEN_ID))
)

;; ;; --- Batch Functions ---

;; ;; Batch process multiple signed predictions at once
;; (define-public (batch-predict
;;     (operations (list 200 {
;;       signet: {signature: (buff 65), nonce: uint},
;;       market-id: (string-ascii 64),
;;       outcome-id: uint,
;;       amount: uint
;;     }))
;;   )
;;   (let
;;     (
;;       (results (map try-predict operations))
;;     )
;;     (asserts! (<= (len operations) MAX_BATCH_SIZE) ERR_TOO_MANY_OPERATIONS)
;;     (ok results)
;;   )
;; )

;; ;; Batch process multiple signed reward claims at once
;; (define-public (batch-claim-reward
;;     (operations (list 200 {
;;       signet: {signature: (buff 65), nonce: uint},
;;       receipt-id: uint
;;     }))
;;   )
;;   (let
;;     (
;;       (results (map try-claim-reward operations))
;;     )
;;     (asserts! (<= (len operations) MAX_BATCH_SIZE) ERR_TOO_MANY_OPERATIONS)
;;     (ok results)
;;   )
;; )

;; --- Initialization ---
(begin
    ;; Initialize admin
    (map-set authorized-admins DEPLOYER true)
)
```
