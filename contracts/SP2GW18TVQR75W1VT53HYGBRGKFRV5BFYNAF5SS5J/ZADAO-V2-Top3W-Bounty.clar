(use-trait token 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)
;; top 3 bounty winner Zero Authority DAO V2
;; Define Error Codes
(define-constant ERR_UNAUTHORIZED (err u1001))
(define-constant ERR_CLOSED_BY_CREATOR (err u1002))
(define-constant ERR_INVALID_BOUNTY (err u1003))
(define-constant ERR_COMPLETED_BOUNTY (err u1004))
(define-constant ERR_INVALID_ID (err u1005))
(define-constant ERR_NO_SUBMISSIONS (err u1006))
(define-constant ERR_ALREADY_SUBMITED (err u1007))
(define-constant ERR_WRONG_TOKEN (err u1008))


;; Define commission
(define-data-var COMMISSION_RATE uint u30) ;; 3%

;; Status codes explanation:
;; u1 - Bounty is open and available.
(define-constant BOUNTY_OPEN u1)

;; u2 - Bounty is temporarily paused for submissions
(define-constant BOUNTY_PAUSED u2)

;; u3 - A winner has been selected.
(define-constant BOUNTY_WINNER_SELECTED u3)

;; u4 - The bounty has been cancelledfunds have been redeemed by the bounty creator.
(define-constant BOUNTY_CANCELLED u4)


;; Data maps and variables

(define-data-var contract-owner principal tx-sender)
(define-map bounties
  (string-ascii 36)
  {
    creator: principal,
    selected-token: principal,
    bounty-amount: uint,
    bounty-title: (string-ascii 200),
    status: uint,
    selected-winners: (optional  (list 3 principal)),
    submission-count: uint
  }
)
(define-map submissions { bounty-id:(string-ascii 36),submitter: principal} {
      entry-number:uint,
      submission-time: uint
    })


;; #[allow(unchecked_data)]
(define-public (create-bounty (amount uint) (bounty-title (string-ascii 200)) (bounty-id (string-ascii 36)) (token-name <token>))
  (let (
        (commission (/ (* amount (var-get COMMISSION_RATE)) u1000))
        (bounty-amount (- amount commission))
      )
    (asserts! (is-eq (len bounty-id) u36) ERR_INVALID_ID)
    (asserts! (is-token-enabled (contract-of token-name)) ERR_WRONG_TOKEN)
    (try! (contract-call? token-name transfer amount tx-sender (as-contract tx-sender) none))
    (try! (contract-call? token-name transfer commission tx-sender (var-get contract-owner) none))
    (asserts! (map-insert bounties bounty-id {
      creator: tx-sender,
      selected-token: (contract-of token-name),
      bounty-title: bounty-title,
      bounty-amount: amount,
      status: BOUNTY_OPEN,
      selected-winners: none,
      submission-count: u0}) ERR_INVALID_ID)
    (ok bounty-id)))

(define-public (submit-entry (bounty-id (string-ascii 36)))
        (let (
                (bounty-info (unwrap! (map-get? bounties bounty-id) ERR_INVALID_BOUNTY))
                (entry-number (+ (get submission-count bounty-info) u1))
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
(define-public (accept-submission (bounty-id (string-ascii 36)) (first-winner principal) (second-winner principal) (third-winner principal) (used-token <token>))
  (let (
        (bounty (unwrap! (map-get? bounties bounty-id) ERR_INVALID_BOUNTY))
        (contract-name (get selected-token bounty))
        (bounty-amount (get bounty-amount bounty))
        (first-winner-amount (/ (* bounty-amount u60) u100))
        (second-winner-amount (/ (* bounty-amount u30) u100))
        (third-winner-amount (/ (* bounty-amount u10) u100))
       )
        (asserts! (is-eq (contract-of used-token) contract-name) ERR_WRONG_TOKEN)
        (asserts! (is-eq tx-sender (get creator bounty)) ERR_UNAUTHORIZED)
        (asserts! (is-bounty-pending (get status bounty)) ERR_COMPLETED_BOUNTY)
        (asserts! (> (get submission-count bounty) u0) ERR_NO_SUBMISSIONS)
        (asserts! (and (is-some (map-get? submissions {bounty-id: bounty-id, submitter: first-winner}))
                       (is-some (map-get? submissions {bounty-id: bounty-id, submitter: second-winner}))
                       (is-some (map-get? submissions {bounty-id: bounty-id, submitter: third-winner}))) ERR_UNAUTHORIZED)
        (as-contract (try! (contract-call? used-token transfer first-winner-amount tx-sender first-winner none)))
        (as-contract (try! (contract-call? used-token transfer second-winner-amount tx-sender second-winner none)))
        (as-contract (try! (contract-call? used-token transfer third-winner-amount tx-sender third-winner none)))
        (map-set bounties
        bounty-id
          (merge bounty { status: BOUNTY_WINNER_SELECTED, selected-winners: (some (list first-winner second-winner third-winner)) }))
        (ok true)
    )
)


(define-public (open-close-bounty (bounty-id (string-ascii 36)))
 (let ((bounty (unwrap! (map-get? bounties bounty-id) ERR_INVALID_BOUNTY))
     )
        (asserts! (is-eq tx-sender (get creator bounty)) ERR_UNAUTHORIZED)
        (asserts! (is-bounty-pending (get status bounty)) ERR_COMPLETED_BOUNTY)
      (ok (map-set bounties bounty-id (merge bounty {
        status: (if (is-eq (get status bounty) BOUNTY_OPEN) BOUNTY_PAUSED BOUNTY_OPEN)
      })))
  )
)


;; #[allow(unchecked_data)]
(define-public (redeem-fund (bounty-id (string-ascii 36)) (token-used <token>))
  (let ((bounty (map-get? bounties bounty-id))
        (contract-name (get selected-token bounty))
      )
    (asserts! (is-eq (contract-of token-used) (unwrap-panic contract-name)) ERR_WRONG_TOKEN)
    (match bounty
      bounty-info
      (begin
        (asserts! (is-eq tx-sender (get creator bounty-info)) ERR_UNAUTHORIZED)
        (asserts! (is-bounty-pending (get status bounty-info)) ERR_COMPLETED_BOUNTY)
        (try! (as-contract (contract-call? token-used transfer (get bounty-amount bounty-info)  tx-sender (get creator bounty-info) none)))
        (ok (map-set bounties
          bounty-id
          (merge bounty-info { status: BOUNTY_CANCELLED}))
        ))
      ERR_INVALID_BOUNTY
    )
  )
)

(define-public (update-fee (amount uint))
(begin
  (asserts! (is-eq tx-sender (var-get contract-owner)) ERR_UNAUTHORIZED)
  (ok (var-set COMMISSION_RATE amount))
  )
)

(define-private (is-bounty-pending (status uint))
  (or (is-eq status BOUNTY_OPEN) (is-eq status BOUNTY_PAUSED))
)

(define-private (is-token-enabled (token-id principal))
    (contract-call? .ZADAO-token-whitelist-v1 is-token-enabled token-id))

(define-read-only (get-submission (bounty-id (string-ascii 36)) (submitter principal))
  (map-get? submissions { bounty-id: bounty-id, submitter: submitter }))

;; Read-only: Get bounty details
(define-read-only (get-bounty-details (bounty-id (string-ascii 36)))
  (map-get? bounties bounty-id)
)