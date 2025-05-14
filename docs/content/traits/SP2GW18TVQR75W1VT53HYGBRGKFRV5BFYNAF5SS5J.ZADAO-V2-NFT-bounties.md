---
title: "Trait ZADAO-V2-NFT-bounties"
draft: true
---
```
(use-trait nft-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

;; Define Error Codes
(define-constant ERR_UNAUTHORIZED (err u1001))
(define-constant ERR_CLOSED_BY_CREATOR (err u1002))
(define-constant ERR_INVALID_BOUNTY (err u1003))
(define-constant ERR_COMPLETED_BOUNTY (err u1004))
(define-constant ERR_INVALID_ID (err u1005))
(define-constant ERR_NO_SUBMISSIONS (err u1006))
(define-constant ERR_ALREADY_SUBMITED (err u1007))
(define-constant ERR_WRONG_TOKEN (err u1008))

;; Status codes explanation:
;; u1 - Bounty is open and available.
(define-constant BOUNTY_OPEN u1)

;; u2 - Bounty is temporarily paused for submissions
(define-constant BOUNTY_PAUSED u2)

;; u3 - A winner has been selected.
(define-constant BOUNTY_WINNER_SELECTED u3)

;; u4 - The bounty has been cancelledfunds have been redeemed by the bounty creator.
(define-constant BOUNTY_CANCELLED u4)


(define-data-var fee uint u3000000)
(define-data-var contract-owner principal tx-sender)


;; Data maps and variables
(define-map bounties
 (string-ascii 36)
  {
    creator: principal,
    selected-token: principal,
    bounty-title: (string-ascii 200),
    token-id: uint,
    status: uint,
    selected-winner: (optional principal),
    submission-count: uint
  }
)
(define-map submissions { bounty-id:(string-ascii 36),submitter: principal} {
      entry-number:uint,
      submission-time: uint
    })
 

;; #[allow(unchecked_data)]
(define-public (create-bounty (token-id uint) (bounty-id (string-ascii 36)) (bounty-title (string-ascii 200)) (nft-asset-contract <nft-trait>))
  (begin 
    (asserts! (is-eq (len bounty-id) u36) ERR_INVALID_ID)
    (asserts! (is-token-enabled (contract-of nft-asset-contract)) ERR_WRONG_TOKEN)
    (try! (transfer-nft nft-asset-contract token-id tx-sender (as-contract tx-sender)))
    (try! (stx-transfer? (var-get fee) tx-sender (var-get contract-owner)))
    (asserts! (map-insert bounties bounty-id {
      creator: tx-sender, 
      selected-token: (contract-of nft-asset-contract),
      bounty-title: bounty-title, 
      token-id: token-id,
      status: BOUNTY_OPEN, 
      selected-winner: none,
      submission-count: u0}) ERR_INVALID_ID)
    (ok bounty-id)))

(define-public (submit-entry (bounty-id (string-ascii 36)))
        (let (
                (bounty-info (unwrap! (map-get? bounties bounty-id) ERR_INVALID_BOUNTY))
                (entry-number (+ (get submission-count bounty-info) BOUNTY_OPEN))
             )
                (asserts! (is-none (map-get? submissions { bounty-id: bounty-id,submitter: tx-sender })) ERR_ALREADY_SUBMITED)
                (asserts! (is-eq (get status bounty-info) BOUNTY_OPEN) ERR_COMPLETED_BOUNTY)
                (map-set bounties bounty-id (merge bounty-info {submission-count: entry-number}))
                (map-insert submissions
                { bounty-id: bounty-id,submitter: tx-sender }
                { entry-number: entry-number, submission-time: burn-block-height })
                (ok entry-number)
        )
)

;; #[allow(unchecked_data)]
(define-public (accept-submission (bounty-id (string-ascii 36)) (submitter principal) (nft-asset-contract <nft-trait>))
  (let (
        (bounty (unwrap! (map-get? bounties bounty-id) ERR_INVALID_BOUNTY))
        (contract-name (get selected-token bounty))
        (token-id (get token-id bounty))
       )
        (asserts! (is-eq (contract-of nft-asset-contract) contract-name) ERR_WRONG_TOKEN)
        (asserts! (is-eq tx-sender (get creator bounty)) ERR_UNAUTHORIZED)
        (asserts! (is-bounty-pending (get status bounty)) ERR_COMPLETED_BOUNTY)
        (asserts! (> (get submission-count bounty) u0) ERR_NO_SUBMISSIONS)
        (asserts! (is-some (map-get? submissions {bounty-id: bounty-id, submitter: submitter}))  ERR_UNAUTHORIZED)
        (as-contract (try! (transfer-nft nft-asset-contract token-id tx-sender submitter)))
        (map-set bounties
        bounty-id
          (merge bounty { status: BOUNTY_WINNER_SELECTED,selected-winner:(some submitter) }))
        (ok true)
    )
)

;; #[allow(unchecked_data)]
(define-public (redeem-fund (bounty-id (string-ascii 36)) (nft-asset-contract <nft-trait>))
  (let ((bounty (map-get? bounties bounty-id))
        (contract-name (get selected-token bounty))
        (token-id (get token-id bounty))
      )
    (asserts! (is-eq (contract-of nft-asset-contract) (unwrap-panic contract-name)) ERR_WRONG_TOKEN)
    (match bounty
      bounty-info
      (begin
        (asserts! (is-eq tx-sender (get creator bounty-info)) ERR_UNAUTHORIZED)
        (asserts! (is-bounty-pending (get status bounty-info)) ERR_COMPLETED_BOUNTY)
        (as-contract (try! (transfer-nft nft-asset-contract (unwrap-panic token-id) tx-sender (get creator bounty-info))))
        (ok (map-set bounties
          bounty-id
          (merge bounty-info { status: BOUNTY_CANCELLED }))
        ))
      ERR_INVALID_BOUNTY
    )
  )
)

(define-public (open-close-bounty (bounty-id (string-ascii 36)))
 (let ((bounty (unwrap! (map-get? bounties bounty-id) ERR_INVALID_BOUNTY))
     )
        (asserts! (is-eq tx-sender (get creator bounty)) ERR_UNAUTHORIZED)
        (asserts! (is-bounty-pending (get status bounty)) ERR_COMPLETED_BOUNTY)
      (if (is-eq (get status bounty) BOUNTY_OPEN) 
       (ok (map-set bounties bounty-id (merge bounty { status:BOUNTY_PAUSED })))
       (ok (map-set bounties bounty-id (merge bounty { status:BOUNTY_OPEN }))) 
      )
  )
)

(define-public (update-fee (amount uint))
  (begin
  (asserts! (is-eq tx-sender (var-get contract-owner)) ERR_UNAUTHORIZED)
  (ok (var-set fee amount))
  )
)

(define-private (is-bounty-pending (status uint))
  (or (is-eq status BOUNTY_OPEN) (is-eq status BOUNTY_PAUSED))
)

(define-private (transfer-nft (token-contract <nft-trait>) (token-id uint) (sender principal) (recipient principal))
	(contract-call? token-contract transfer token-id sender recipient)
)

(define-private (is-token-enabled (token-id principal))
    (contract-call? .ZADAO-token-whitelist-v1 is-token-enabled token-id))

(define-read-only (get-submission (bounty-id (string-ascii 36)) (submitter principal))
  (map-get? submissions { bounty-id: bounty-id, submitter: submitter }))

;; Read-only: Get bounty details
(define-read-only (get-bounty-details (bounty-id (string-ascii 36)))
  (map-get? bounties bounty-id)
)
```
