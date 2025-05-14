---
title: "Trait prediction-test-2"
draft: true
---
```
;; Title: Blaze Prediction Market Vault
;; Version: 1.0.0
;; Description: 
;;   Implementation of a prediction market vault for the Stacks blockchain.
;;   Allows users to create markets, make predictions, and claim rewards.
;;   Market resolution is controlled by the vault deployer or authorized admins.
;;   Each prediction is tracked as a non-fungible token receipt.

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
(define-constant PRECISION u1000000)
(define-constant ADMIN_FEE u50000)   ;; 5% fee to admin who resolves the market

;; Opcodes (0xA* range to avoid LP conflicts)
(define-constant OP_PREDICT 0xA1)    ;; Make a prediction
(define-constant OP_CLAIM_REWARD 0xA3)  ;; Claim rewards

;; Define NFT for prediction receipts
(define-non-fungible-token prediction-receipt uint)

;; Data structures
(define-map markets uint {
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
  market-id: uint,
  outcome-id: uint,
  amount: uint
})

;; Map for authorized oracles/admins
(define-map authorized-admins principal bool)

;; Next token ID counter
(define-data-var next-receipt-id uint u1)

;; Token metadata URI
(define-data-var token-uri (string-utf8 256) u"https://charisma.rocks/predictions/receipt.json")

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
;;         (outcome-id (get-byte op-buffer u2)))
;;         (if (is-eq op-type (buff-to-uint-le OP_PREDICT)) (make-prediction market-id outcome-id amount)
;;         (if (is-eq op-type (buff-to-uint-le OP_CLAIM_REWARD)) (claim-reward market-id)
;;         ERR_INVALID_OPERATION))))

;; (define-read-only (quote (amount uint) (opcode (optional (buff 16))))
;;     (let (
;;         (op-buffer (default-to 0x00 opcode))
;;         (op-type (get-byte op-buffer u0))
;;         (market-id (get-byte op-buffer u1))
;;         (outcome-id (get-byte op-buffer u2)))
;;         (if (is-eq op-type (buff-to-uint-le OP_PREDICT)) (quote-prediction market-id outcome-id)
;;         (if (is-eq op-type (buff-to-uint-le OP_CLAIM_REWARD)) (quote-reward market-id)
;;         ERR_INVALID_OPERATION))))

;; --- Market Management Functions ---

;; Create a new prediction market (standard function, not an opcode)
;; (define-public (create-market 
;;     (market-id uint) 
;;     (name (string-ascii 64)) 
;;     (description (string-ascii 128))
;;     (outcome-names (list 16 (string-ascii 32))))
;;     (begin
;;         ;; Check if market ID already exists
;;         (asserts! (is-none (map-get? markets market-id)) ERR_MARKET_EXISTS)
        
;;         ;; Initialize empty outcome pools
;;         (let ((empty-pools (list 
;;             u0 u0 u0 u0 u0 u0 u0 u0
;;             u0 u0 u0 u0 u0 u0 u0 u0)))
            
;;             ;; Create a new prediction market
;;             (map-set markets market-id {
;;                 creator: tx-sender,
;;                 name: name,
;;                 description: description,
;;                 outcome-names: outcome-names,
;;                 outcome-pools: empty-pools,
;;                 total-pool: u0,
;;                 is-open: true,
;;                 is-resolved: false,
;;                 winning-outcome: u0,
;;                 resolver: none,
;;                 creation-time: block-height,
;;                 resolution-time: u0
;;             })
            
;;             (ok {
;;                 market-id: market-id,
;;                 creator: tx-sender,
;;                 creation-time: block-height
;;             })
;;         )
;;     )
;; )

;; Close a market (no more predictions allowed)
;; (define-public (close-market (market-id uint))
;;     (let ((market (unwrap! (map-get? markets market-id) ERR_MARKET_NOT_FOUND)))
;;         ;; Only vault deployer or authorized admin can close
;;         (asserts! (or 
;;             (is-eq tx-sender DEPLOYER)
;;             (default-to false (map-get? authorized-admins tx-sender))) 
;;             ERR_UNAUTHORIZED)
        
;;         ;; Update market status
;;         (map-set markets market-id (merge market { is-open: false }))
        
;;         (ok true)
;;     )
;; )

;; Resolve a market (determine correct outcome)
;; (define-public (resolve-market (market-id uint) (winning-outcome uint))
;;     (let ((market (unwrap! (map-get? markets market-id) ERR_MARKET_NOT_FOUND)))
;;         ;; Only vault deployer or authorized admin can resolve
;;         (asserts! (or 
;;             (is-eq tx-sender DEPLOYER)
;;             (default-to false (map-get? authorized-admins tx-sender))) 
;;             ERR_UNAUTHORIZED)
        
;;         ;; Check that outcome is valid
;;         (asserts! (< winning-outcome (len (get outcome-names market))) ERR_INVALID_OUTCOME)

;;         ;; Admin collects 5% fee in the form of a prediction
;;         (try! (make-prediction market-id winning-outcome (/ (* (get total-pool market) ADMIN_FEE) PRECISION)))
        
;;         ;; Update market status with winning outcome and resolver
;;         (map-set markets market-id (merge market { 
;;             is-resolved: true,
;;             winning-outcome: winning-outcome,
;;             resolver: (some tx-sender),
;;             resolution-time: block-height
;;         }))
        
;;         (ok true)
;;     )
;; )

;; --- Execute Functions ---

;; (define-public (make-prediction (market-id uint) (outcome-id uint) (amount uint))
;;     (let (
;;         (sender tx-sender)
;;         (market (unwrap! (map-get? markets market-id) ERR_MARKET_NOT_FOUND))
;;         (receipt-id (var-get next-receipt-id)))
        
;;         ;; Verify market is open
;;         (asserts! (get is-open market) ERR_MARKET_CLOSED)
        
;;         ;; Verify outcome ID is valid
;;         (asserts! (< outcome-id (len (get outcome-names market))) ERR_INVALID_OUTCOME)
        
;;         ;; Transfer STX to contract
;;         (try! (stx-transfer? amount sender CONTRACT))
        
;;         ;; Mint NFT receipt
;;         (try! (nft-mint? prediction-receipt receipt-id sender))
        
;;         ;; Update outcome pools
;;         (let (
;;             (current-pools (get outcome-pools market))
;;             (current-pool (default-to u0 (element-at? current-pools outcome-id)))
;;             (updated-pool (+ current-pool amount))
;;             (updated-pools (replace-at? current-pools outcome-id updated-pool)))
            
;;             ;; Update market state
;;             (map-set markets market-id (merge market {
;;                 outcome-pools: (unwrap-panic updated-pools),
;;                 total-pool: (+ (get total-pool market) amount)
;;             }))
            
;;             ;; Increment receipt ID counter
;;             (var-set next-receipt-id (+ receipt-id u1))
            
;;             (ok {
;;                 dx: amount,
;;                 dy: updated-pool,
;;                 dk: receipt-id
;;             })
;;         )
;;     )
;; )

;; (define-public (claim-reward (receipt-id uint))
;;     (let (
;;         (sender tx-sender)
;;         (quote (unwrap-panic (quote-reward receipt-id)))
;;         (total-reward (get dy quote)))
        
;;         ;; Verify user owns the NFT receipt
;;         (asserts! (is-eq (some sender) (nft-get-owner? prediction-receipt receipt-id)) ERR_UNAUTHORIZED)

;;         ;; Verify has rewards
;;         (asserts! (> total-reward u0) ERR_NOT_WINNER)
        
;;         ;; Transfer reward to user
;;         (try! (as-contract (stx-transfer? total-reward CONTRACT sender)))
        
;;             ;; Burn the NFT receipt (marks as claimed)
;;         (try! (nft-burn? prediction-receipt receipt-id sender))
                
;;         (ok {
;;             dx: (get dx quote),
;;             dy: total-reward,
;;             dk: receipt-id
;;         })
;;     )
;; )

;; --- Quote Functions ---

;; (define-read-only (quote-prediction (market-id uint) (outcome-id uint))
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

;; (define-read-only (quote-reward (receipt-id uint))
;;     (let (
;;         (prediction (unwrap! (map-get? predictions receipt-id) ERR_PREDICTION_NOT_FOUND))
;;         (market-id (get market-id prediction))
;;         (market (unwrap! (map-get? markets market-id) ERR_MARKET_NOT_FOUND))
;;         (amount (get amount prediction))
;;         (total-pot (get total-pool market))
;;         (winning-outcome (get winning-outcome market))
;;         (winning-pool (default-to u0 (element-at? (get outcome-pools market) winning-outcome)))
;;         (total-reward (if (> winning-pool u0) (/ (* amount total-pot) winning-pool) u0)))        
;;         (ok {
;;             dx: amount,
;;             dy: total-reward,
;;             dk: receipt-id
;;         })
;;     )
;; )

;; --- Helper Functions ---

(define-read-only (get-byte (opcode (buff 16)) (position uint))
   (buff-to-uint-le (default-to 0x00 (element-at? opcode position))))

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

(define-read-only (get-market-info (market-id uint))
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

;; --- Initialization ---
(begin
    ;; Initialize admin
    (map-set authorized-admins DEPLOYER true)
)
```
