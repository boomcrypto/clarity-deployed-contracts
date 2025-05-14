
;; title: marketplace
;; version:
;; summary:
;; description:
(use-trait token 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)


(define-constant ERR_NOT_FOUND (err u404))

(define-constant ERR_NOT_AUTHORIZED (err u401))
(define-constant ERR_INVALID_PARAMS (err u400))
(define-constant ERR_INVALID_ID (err u4400))
(define-constant ERR_INVALID_AMOUNT (err u4401))
(define-constant ERR_INVALID_PERIOD (err u4402))
(define-constant ERR_EXISTING_ID (err u4403))
(define-constant ERR_CANNOT_HIRE_SELF (err u4404))

(define-constant ERR_EXPIRED (err u409))
(define-constant ERR_INVALID_RATING (err u410))

(define-constant ERR_NOT_PENDING (err u411))
(define-constant ERR_NOT_REDEEMABLE (err u412))
(define-constant ERR_NOT_ACCEPTED (err u413))
(define-constant ERR_NOT_ACCEPTANCE (err u414))
(define-constant ERR_NOT_DISPUTED (err u415))
(define-constant ERR_NOT_EXPIRED (err u416))
(define-constant ERR_WRONG_TOKEN (err u417))



(define-constant TWO_BTC_WEEKS (* u144 u14))
(define-data-var contract-owner principal tx-sender)

(define-constant GIG_PENDING u1000)
(define-constant GIG_ACCEPTED u1001)
(define-constant GIG_DECLINED u1002)
(define-constant GIG_IN_WORKER_REVIEW u1003)
(define-constant GIG_DISPUTED u1004)
(define-constant GIG_CANCELLED u1005)
(define-constant GIG_COMPLETED u1006)
(define-constant GIG_PAST_PERIOD_DISPUTE u1007)
(define-constant GIG_CLIENT_RATED u1008)
(define-constant WORKER_REJECTED_CLIENT_RATING u1009)
(define-constant WORKER_ACCEPTED_CLIENT_RATING u1010)
(define-constant DAO_SETTLE_DISPUTE u1011)
(define-constant commission u25)

;; create a new gig - id
;; client: client who creates the gig
;; worker: worker
;; JOB: string, but one of these
;; Amount:
;; Currency: just STX (others later on)
;; Date-created:
;; Date-accepted: needs a value at initialization, block 1 till overwrites it with the worker value
;; period: number of blocks in which worker has to end the work after accepting it
;; status: pending, accepted -> means in progress, declined, expired if the worker did not respond
;; status: worker-review
;; status: in dispute
;; status: completed -> money out of the contract
;; rating:
;; completely-paid: true/false ( true when the money are released from this contract, being it to a user or to the dispute contract, false till then) ( once paid cannot be paid again )

;; if the gig is in dispute, DAO wallet votes about distribution
;; after vote ends, the function can be called by anyone and the funds can be moved in the decided manner


(define-map gigs (string-ascii 36)
    {
        client: principal,
        worker: principal,
        amount: uint,
        currency: principal,
        block-created: uint,
        block-accepted: uint,
        block-disputed: uint,
        period: uint,
        status: uint,
        rating: uint,
        rating-after-dispute: uint,
})


;; private functions

(define-private (pay-as-contract (pay-on <token>) (amount uint) (recipient principal))
  (as-contract (contract-call? pay-on transfer amount tx-sender recipient none)))

(define-private (pay-if-valid (pay-on <token>) (amount uint) (recipient principal))
  (if (> amount u0)
    (pay-as-contract pay-on amount recipient)
    (ok false)))


(define-public (create-gig (id (string-ascii 36)) (worker principal) (amount uint) (pay-on <token>) (period uint))
  (let ((fee (/ (* amount commission) u1000))
        (gig-amount (- amount fee))
        (gig-data {
            amount: gig-amount,
            block-accepted: u1,
            block-created: burn-block-height,
            block-disputed: u1,
            client: tx-sender,
            currency: (contract-of pay-on),
            period: period,
            rating: u0,
            rating-after-dispute: u0,
            status: GIG_PENDING,
            worker: worker
      }))
    (asserts! (contract-call? .ZADAO-token-whitelist-v1 is-token-enabled (contract-of pay-on)) ERR_WRONG_TOKEN)
    (asserts! (is-eq (len id) u36) ERR_INVALID_ID)
    (asserts! (> amount u0) ERR_INVALID_AMOUNT)
    (asserts! (> period (* u144 u14)) ERR_INVALID_PERIOD)
    (asserts! (not (is-eq worker tx-sender)) ERR_CANNOT_HIRE_SELF)
    (try! (contract-call? pay-on transfer gig-amount tx-sender (as-contract tx-sender) none))
    (try! (contract-call? pay-on transfer fee tx-sender (var-get contract-owner) none))
    (asserts!
      (map-insert gigs id
        gig-data) ERR_EXISTING_ID)
    (print {
      notification: GIG_PENDING,
      gig-id: id,
      gig-data: gig-data
    })
    (ok true)))


;; accept gig as worker, only if pending
;; check if you are the worker
;; check if pending
;; update date-accepted burn-block-height
(define-public (accept-gig (gig-id (string-ascii 36)))
  ;; refund will be date-accepted+period, when date-accepted is not 1
  (let
    (
        (gig (try! (get-gig gig-id)))
    )
    (asserts! (is-eq tx-sender (get worker gig)) ERR_NOT_AUTHORIZED)
    (asserts! (is-eq (get status gig) GIG_PENDING) ERR_NOT_PENDING)
    (asserts! (<= burn-block-height (+ (get block-created gig) TWO_BTC_WEEKS)) ERR_EXPIRED)
    (map-set gigs gig-id (merge gig {block-accepted: burn-block-height, status: GIG_ACCEPTED}))
    (print {
      notification: GIG_ACCEPTED,
      gig-id: gig-id
    })
    (ok true)))


;; decline gig as worker, only if pending
;; check if you are the worker
;; check if pending
;; send back the stx
(define-public (decline-gig (gig-id (string-ascii 36)) (pay-on <token>))
  (let (
    (gig (try! (get-gig gig-id)))
  )
    (asserts! (is-eq (contract-of pay-on) (get currency gig)) ERR_WRONG_TOKEN)
    (asserts! (is-eq tx-sender (get worker gig)) ERR_NOT_AUTHORIZED)
    (asserts! (is-eq (get status gig) GIG_PENDING) ERR_NOT_PENDING)
    (asserts! (<= burn-block-height (+ (get block-created gig) TWO_BTC_WEEKS)) ERR_EXPIRED)
    (try! (pay-as-contract pay-on (get amount gig) (get client gig)))
    (map-set gigs gig-id (merge gig {status: GIG_DECLINED}))
    (print {
      notification: GIG_DECLINED,
      gig-id: gig-id
    })
    (ok true)))


;; getter and setter for gig
(define-read-only (get-gig (gig-id (string-ascii 36)))
  (ok (unwrap! (map-get? gigs gig-id) ERR_NOT_FOUND)))

;; redeem back funds as client if no answer in 7-14 days
;; if client who created the gig, gig still pending, and created block-heigh + 14 days > block height
(define-read-only (is-past-two-btc-weeks (height uint))
  (> burn-block-height (+ height TWO_BTC_WEEKS)))


;; redeem funds back
;; set status expired
;; completely paid true
(define-public (redeem-back (gig-id (string-ascii 36)) (pay-on <token>))
    (let (
        (gig (try! (get-gig gig-id)))
    )
    (asserts! (is-eq tx-sender (get client gig)) ERR_NOT_AUTHORIZED)
    (asserts! (is-eq (contract-of pay-on) (get currency gig)) ERR_WRONG_TOKEN)
    (asserts! (is-eq (get status gig) GIG_PENDING) ERR_NOT_PENDING)
    (asserts! (is-past-two-btc-weeks (get block-created gig)) ERR_NOT_REDEEMABLE)
    (try! (pay-as-contract pay-on (get amount gig) (get client gig)))
    (map-set gigs gig-id (merge gig {status: GIG_CANCELLED}))
    (print {
      notification: GIG_CANCELLED,
      gig-id: gig-id,
    })
    (ok true)))


;; go-to-dispute
;; if time passed and DAO wallet wants to vote
;; if client/worker know the gig will not be done till specified end of time

;; time end for gig -> block-created + period < current-burn-block-height
;; if status == acepted => block-created != 1
(define-public (send-to-dispute (gig-id (string-ascii 36)))
  (let ((gig (try! (get-gig gig-id))))
    (asserts! (or (is-eq tx-sender (get client gig)) (is-eq tx-sender (get worker gig))) ERR_NOT_AUTHORIZED)
    (asserts! (is-eq (get status gig) GIG_ACCEPTED) ERR_NOT_ACCEPTED)
    (asserts! (not (is-past-two-btc-weeks (get block-accepted gig))) ERR_EXPIRED)
    ;; (asserts! (<= burn-block-height (+ (get block-accepted gig) TWO_BTC_WEEKS)) ERR_EXPIRED)
    (map-set gigs gig-id (merge gig {block-disputed: burn-block-height, status: GIG_DISPUTED}))
    (print {
      notification: GIG_DISPUTED,
      gig-id: gig-id,
      disputed-by: tx-sender,
    })
    (ok true)))


;; if time expired, DAO can send it to dispute
(define-public (send-to-dispute-passed-time-acceptance (gig-id (string-ascii 36)))
  (let ((gig (try! (get-gig gig-id))))
    (asserts! (is-eq (var-get contract-owner) tx-sender)  ERR_NOT_AUTHORIZED)
    (asserts! (> burn-block-height (+ (get block-accepted gig) (get period gig))) ERR_NOT_EXPIRED)
    (asserts! (is-eq (get status gig) GIG_ACCEPTED) ERR_NOT_ACCEPTED)
    (map-set gigs gig-id (merge gig {block-disputed: burn-block-height, status: GIG_DISPUTED}))
    (print {
      notification: GIG_PAST_PERIOD_DISPUTE,
      gig-id: gig-id,
      disputed-by: tx-sender,
    })
    (ok true)))


(define-private (is-rating-valid (rating uint))
  (and
    (is-eq (mod rating u25) u0)
    (<= rating u100)))


;; vote result as client
;; the gig has to be in status: accepted
;; the status will become worker-review
(define-public (rating-vote-gig-as-client (gig-id (string-ascii 36)) (rating-vote uint) (pay-on <token>))
  (let ((gig (try! (get-gig gig-id))))
    (asserts! (is-eq (contract-of pay-on) (get currency gig)) ERR_WRONG_TOKEN)
    (asserts! (is-rating-valid rating-vote)  ERR_INVALID_RATING)

    (asserts! (is-eq tx-sender (get client gig)) ERR_NOT_AUTHORIZED)
    (asserts! (is-eq GIG_ACCEPTED (get status gig)) ERR_NOT_ACCEPTED)
    ;; if the time is passed, will still let him vote
    ;; if vote 100% agree -> sent stx right away
    (if (is-eq rating-vote u100)
      (begin
        (try! (pay-if-valid pay-on (get amount gig) (get worker gig)))
        ;; (as-contract (try! (contract-call? pay-on transfer (get amount gig)  tx-sender (get worker gig) none)))
        (map-set gigs gig-id (merge gig {status: GIG_COMPLETED , rating: rating-vote}))
      )
      ;; if vote 100% disagree -> start dispute
      (if (is-eq rating-vote u0)
        (map-set gigs gig-id (merge gig {block-disputed: burn-block-height, status: GIG_DISPUTED , rating: rating-vote}))
        ;; else change status to await for worker vote
        (map-set gigs gig-id (merge gig {status: GIG_IN_WORKER_REVIEW , rating: rating-vote}))))
    (print {
      notification: GIG_CLIENT_RATED,
      gig-id: gig-id,
      rating: rating-vote
    })
    (ok true)))

(define-public (worker-reject-client-rating (gig-id (string-ascii 36)))
  (let ((gig (try! (get-gig gig-id))))
    (asserts! (is-eq tx-sender (get worker gig)) ERR_NOT_AUTHORIZED)
    (asserts! (is-eq GIG_IN_WORKER_REVIEW (get status gig)) ERR_NOT_ACCEPTANCE)
    (map-set gigs gig-id (merge gig {block-disputed: burn-block-height, status: GIG_DISPUTED}))
    (print {
      notification: WORKER_REJECTED_CLIENT_RATING,
      gig-id: gig-id,
    })
    (ok true)))

(define-public (worker-accept-client-rating (gig-id (string-ascii 36)) (pay-on <token>))
  (let (
      (gig (try! (get-gig gig-id)))
      (worker-amount (get rating gig))
      (client-amount (- u100 worker-amount))
    )
    (asserts! (is-eq (contract-of pay-on) (get currency gig)) ERR_WRONG_TOKEN)
    (asserts! (is-eq tx-sender (get worker gig)) ERR_NOT_AUTHORIZED)
    (asserts! (is-eq GIG_IN_WORKER_REVIEW (get status gig)) ERR_NOT_ACCEPTANCE)
    (try! (pay-if-valid pay-on worker-amount (get worker gig)))
    (try! (pay-if-valid pay-on client-amount (get client gig)))
    (map-set gigs gig-id (merge gig {status: GIG_COMPLETED}))
    (print {
      notification: WORKER_ACCEPTED_CLIENT_RATING,
      gig-id: gig-id,
    })
    (ok true)))


;; DAO vote on the matters
;; vote with multisig wallet
(define-public (dao-settle-dispute (gig-id (string-ascii 36)) (rating uint) (pay-on <token>))
  (let (
      (gig (try! (get-gig gig-id)))
      (worker-amount rating)
      (client-amount (- u100 rating))
    )
    (asserts! (is-eq (contract-of pay-on) (get currency gig)) ERR_WRONG_TOKEN)
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR_NOT_AUTHORIZED)
    (asserts! (is-rating-valid rating)  ERR_INVALID_RATING)
    (asserts! (is-eq (get status gig) GIG_DISPUTED)  ERR_NOT_DISPUTED)
    ;; if 0 -> all money to client
    (try! (pay-if-valid pay-on worker-amount (get worker gig)))
    (try! (pay-if-valid pay-on client-amount (get client gig)))
    (map-set gigs gig-id (merge gig {status: GIG_COMPLETED, rating-after-dispute: rating}))
    (print {
      notification: DAO_SETTLE_DISPUTE,
      gig-id: gig-id,
      rating: rating
    })
    (ok true)))


(define-private (create-gig-helper (gig {
    id: (string-ascii 36),
    worker: principal,
    amount: uint,
    pay-on: <token>,
    period: uint
  }))
    (create-gig
    (get id gig)
    (get worker gig)
    (get amount gig)
    (get pay-on gig)
    (get period gig))
  )

(define-private (check-err  (result (response bool uint))
                            (prior (response bool uint)))
    (match prior ok-value result
                err-value (err err-value)))


(define-public (create-many-gigs (gig-list (list 20
  {
    id: (string-ascii 36),
    worker: principal,
    amount: uint,
    pay-on: <token>,
    period: uint
  })))
  (fold check-err (map create-gig-helper gig-list) (ok true)))



(define-public (accept-many-gigs (gig-list (list 20 (string-ascii 36))))
  (fold check-err (map accept-gig gig-list) (ok true)))

(define-private (decline-gig-helper (gig {
  id: (string-ascii 36),
  pay-on: <token>,
}))
  (decline-gig
    (get id gig)
    (get pay-on gig))
)

(define-public (decline-many-gigs (gig-list (list 20 {
  id: (string-ascii 36),
  pay-on: <token>,
})))
  (fold check-err (map decline-gig-helper gig-list) (ok true)))


(define-private (redeem-gig-helper (gig {
  id: (string-ascii 36),
  pay-on: <token>,
}))
  (redeem-back
    (get id gig)
    (get pay-on gig))
)

(define-public (redeem-many-gigs (gig-list (list 20 {
  id: (string-ascii 36),
  pay-on: <token>,
})))
  (fold check-err (map redeem-gig-helper gig-list) (ok true)))

(define-private (rate-gig-helper (gig {
  id: (string-ascii 36),
  pay-on: <token>,
  rating: uint,
}))
  (rating-vote-gig-as-client 
    (get id gig)
    (get rating gig)
    (get pay-on gig))
)

(define-public (rate-many-gigs (gig-list (list 20 {
  id: (string-ascii 36),
  pay-on: <token>,
  rating: uint,
})))
  (fold check-err (map rate-gig-helper gig-list) (ok true)))
;; client rating-factor (amount-to-worker amount-to-client)
;; initialized: 0% 0%
;; strongly-agree: 100% 0%
;; agree: 75% 25%
;; somewhat-agree: 50% 50%
;; disagree: 0% 100%

;; worker response:
;; agree -> takes how much the client said
;; disagree -> funds are transfared in the dispute contract where zero_autority and others select the fit amount


;; have a list with the gigs fom any given client. same for arist
;; would mean to append to the list every time a new gig is created