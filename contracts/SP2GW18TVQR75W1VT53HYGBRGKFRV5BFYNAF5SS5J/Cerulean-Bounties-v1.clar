;; Cerulean Bounties v1 by Zero Authoirty DAO / Trajan

;; Define Error Codes
(define-constant ERR_UNAUTHORIZED (err u1001))
(define-constant ERR_BOUNTY_EXPIRED (err u1002))
(define-constant ERR_INVALID_BOUNTY (err u1003))
(define-constant ERR_BOUNTY_NOT_OPEN (err u1004))
(define-constant ERR_SUBMISSION_PERIOD_OVER (err u1005))
(define-constant ERR_NO_SUBMISSIONS (err u1006))
(define-constant ERR_ALREADY_SUBMITED (err u1007))
(define-constant BOUNTY_NOT_REDEEMABLE (err u1008))

;; Define commission and duration extension (14 days in blocks)
(define-constant COMMISSION_RATE u25) ;; 2.5%
(define-constant REVIEW_EXTENSION u2016) ;; assuming 1 block ~ 10 minutes
(define-data-var contract-owner principal tx-sender)


;; Data maps and variables
(define-data-var bounty-counter uint u0)
(define-map bounties
  uint
  {
    creator: principal,
    bounty-amount: uint,
    bounty-title: (string-ascii 200),
    status: (string-ascii 20),
    selected-winner: (optional principal),
    expiry: uint,
    submission-count: uint
  }
)
(define-map submissions { bounty-id:uint,submitter: principal} {
      entry-number:uint,
      submission-time: uint
    })


(define-public (create-bounty (amount uint) (bounty-title (string-ascii 200)) (duration uint))
  (let ((bounty-id (+ (var-get bounty-counter) u1))
        (commission (/ (* amount COMMISSION_RATE) u1000))
        (bounty-amount (- amount commission)))
    (try! (stx-transfer? bounty-amount tx-sender (as-contract tx-sender)))
    (try! (stx-transfer? commission tx-sender (var-get contract-owner)))
    (map-insert bounties bounty-id {
      creator: tx-sender, 
      bounty-title: bounty-title, 
      bounty-amount: bounty-amount, 
      status: "open", 
      selected-winner: none,
      expiry: (+ block-height duration), 
      submission-count: u0})
    (var-set bounty-counter bounty-id)
    (ok bounty-id)))

(define-public (submit-entry (bounty-id uint))
        (let (
                (bounty-info (unwrap! (map-get? bounties bounty-id) ERR_INVALID_BOUNTY))
                (entry-number (+ (get submission-count bounty-info) u1))
             )
                (asserts! (is-none (map-get? submissions { bounty-id: bounty-id,submitter: tx-sender })) ERR_ALREADY_SUBMITED)
                (asserts! (is-eq (get status bounty-info) "open") ERR_BOUNTY_NOT_OPEN)
                (asserts! (<= block-height (get expiry bounty-info)) ERR_BOUNTY_EXPIRED)
                (map-set bounties bounty-id (merge bounty-info {submission-count: entry-number}))
                (map-insert submissions
                { bounty-id: bounty-id,submitter: tx-sender }
                { entry-number: entry-number, submission-time: block-height })
                (ok entry-number)
        )
)

;; Client accepts a submission
(define-public (accept-submission (bounty-id uint) (submitter principal))
  (let (
        (bounty (unwrap! (map-get? bounties bounty-id) ERR_INVALID_BOUNTY))
       )
        (asserts! (is-eq tx-sender (get creator bounty)) ERR_UNAUTHORIZED)
        (asserts! (is-eq (get status bounty) "open") ERR_BOUNTY_NOT_OPEN)
        (asserts! (< block-height (+ (get expiry bounty) REVIEW_EXTENSION)) ERR_SUBMISSION_PERIOD_OVER)
        (asserts! (> (get submission-count bounty) u0) ERR_NO_SUBMISSIONS)
        (asserts! (is-some (map-get? submissions {bounty-id: bounty-id, submitter: submitter}))  ERR_UNAUTHORIZED)
        (as-contract (try! (stx-transfer? (get bounty-amount bounty) tx-sender submitter)))
        (map-set bounties
        bounty-id
          (merge bounty { status: "accepted",selected-winner:(some submitter) }))
        (ok true)
    )
)

(define-public (redeem-fund (bounty-id uint))
  (let ((bounty (map-get? bounties bounty-id)))
    (match bounty
      bounty-info
      (begin
        (asserts! (is-eq tx-sender (get creator bounty-info)) ERR_UNAUTHORIZED)
        (asserts! (is-eq (get status bounty-info) "open") ERR_BOUNTY_NOT_OPEN)
        (asserts! (>= block-height (+ (get expiry bounty-info) REVIEW_EXTENSION)) BOUNTY_NOT_REDEEMABLE)
        (as-contract (try! (stx-transfer? (get bounty-amount bounty-info) tx-sender (get creator bounty-info))))
        (ok (map-set bounties
          bounty-id
          (merge bounty-info { status: "expired" }))
        ))
      ERR_INVALID_BOUNTY
    )
  )
)

(define-read-only (get-submission (bounty-id uint) (submitter principal))
  (map-get? submissions { bounty-id: bounty-id, submitter: submitter }))

;; Read-only: Get bounty details
(define-read-only (get-bounty-details (bounty-id uint))
  (map-get? bounties bounty-id)
)