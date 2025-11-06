;; title: retroactive-gigs
;; version: 1.0.0
;; summary: Contract for handling retroactive gig payments with DAO commission
;; description: Allows users to send SIP-010 tokens to workers and DAO wallet in a single transaction with adjustable commission rates

(use-trait token 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

;; Constants
(define-constant ERR_NOT_AUTHORIZED (err u401))
(define-constant ERR_INVALID_ID (err u402))
(define-constant ERR_INVALID_AMOUNT (err u403))
(define-constant ERR_CANNOT_SEND_TO_SELF (err u404))
(define-constant ERR_WRONG_TOKEN (err u405))

(define-constant RETROACTIVE_GIG_CREATED u1000)


;; Data variables
(define-data-var contract-owner principal tx-sender)
(define-data-var COMMISSION_RATE uint u30) ;; 3% = 30 basis points (30/1000)

;; Maps
(define-map retroactive-gigs
  (string-ascii 36)
  {
    client: principal,
    worker: principal,
    amount: uint,
    token: principal,
    memo: (optional (buff 34)),
    block-created: uint
  }
)

;; Read-only functions
(define-read-only (get-dao-wallet)
  (ok (var-get contract-owner))
)

(define-read-only (get-commission-rate)
  (ok (var-get COMMISSION_RATE))
)

(define-read-only (get-retroactive-gig (gig-id (string-ascii 36)))
  (ok (unwrap! (map-get? retroactive-gigs gig-id) ERR_INVALID_AMOUNT))
)


;; Public functions

;; Update DAO wallet (only current DAO can change)
(define-public (set-dao-wallet (new-dao principal))
  (begin 
    (asserts! (is-eq contract-caller (var-get contract-owner)) ERR_NOT_AUTHORIZED)
    (ok (var-set contract-owner new-dao))
  )
)   

;; Update commission rate
(define-public (update-fee (amount uint))
(begin
  (asserts! (is-eq contract-caller (var-get contract-owner)) ERR_NOT_AUTHORIZED)
  (ok (var-set COMMISSION_RATE amount))
  )
)

;; Create retroactive gig payment
(define-public (create-retroactive-gig
  (gig-id (string-ascii 36))
  (worker principal)
  (amount uint)
  (pay-on <token>)
  (memo (optional (buff 34)))
)
 (let (
        (commission (/ (* amount (var-get COMMISSION_RATE)) u1000))
        (gig-data {
          client: tx-sender,
          worker: worker,
          amount: amount,
          token: (contract-of pay-on),
          memo: memo,
          block-created: burn-block-height
        })
      )
      (asserts! (is-eq (len gig-id) u36) ERR_INVALID_ID)
      (asserts! (is-token-enabled (contract-of pay-on)) ERR_WRONG_TOKEN)
      (asserts! (> amount u0) ERR_INVALID_AMOUNT)
      (asserts! (not (is-eq worker tx-sender)) ERR_CANNOT_SEND_TO_SELF)
      (try! (contract-call? pay-on transfer amount tx-sender worker memo))
      (try! (contract-call? pay-on transfer commission tx-sender (var-get contract-owner) none))
      (asserts! (map-insert retroactive-gigs gig-id gig-data) ERR_INVALID_ID)
      (print {
        notification: RETROACTIVE_GIG_CREATED,
        gig-id: gig-id,
        gig-data: gig-data
      })
      (ok true))
    
)

;; mainnet
(define-private (is-token-enabled (token-id principal))
  (contract-call? .ZADAO-token-whitelist-v2 is-token-enabled token-id))