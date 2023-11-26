;; title: Cerulean Marketplace by ZeroAuthorityDAO
;; version:
;; summary:
;; description:


(define-constant ERR_NOT_FOUND (err u404))

(define-constant ERR_NOT_ARTIST (err u405))
(define-constant ERR_NOT_CLIENT (err u406))
(define-constant ERR_NOT_DAO (err u407))
(define-constant ERR_NOT_PARTICIPANT (err u408))

(define-constant ERR_EXPIRED (err u409))
(define-constant ERR_INVALID_SATISFACTION (err u410))

(define-constant ERR_NOT_PENDING (err u411))
(define-constant ERR_NOT_REDEEMABLE (err u412))
(define-constant ERR_NOT_ACCEPTED (err u413))
(define-constant ERR_NOT_ACCEPTANCE (err u414))
(define-constant ERR_NOT_DISPUTED (err u415))
(define-constant ERR_NOT_EXPIRED (err u416))


(define-constant days u14)
(define-data-var gig-count uint u0)
(define-data-var contract-owner principal tx-sender)

(define-constant vote-1 "strongly-agree")
(define-constant vote-2 "agree")
(define-constant vote-3 "somewhat-agree")
(define-constant vote-4 "disagree")

(define-constant commission u25)

;; create a new gig - id
;; from: client who creates the gig
;; to: artist
;; JOB: string, but one of these
;; Amount: 
;; Currency: just STX (others later on)
;; Date-created:
;; Date-accepted: needs a value at initialization, block 1 till overwrites it with the artist value
;; period: number of blocks in which artist has to end the work after accepting it
;; status: pending, accepted -> means in progress, declined, expired if the artist did not respond
;; status: artist-review
;; status: in dispute
;; status: completed -> money out of the contract
;; satisfaction:
;; completely-paid: true/false ( true when the money are released from this contract, being it to a user or to the dispute contract, false till then) ( once paid cannot be paid again )

;; if the gig is in dispute, DAO wallet votes about distribution
;; after vote ends, the function can be called by anyone and the funds can be moved in the decided manner


(define-map gig uint { 
  from: principal,
  to: principal,
  job: (string-ascii 20), 
  amount: uint, 
  ;; currency: (string-ascii 20),
  block-created: uint,
  block-accepted: uint,
  block-disputed: uint,
  period: uint,
  status: (string-ascii 20),
  satisfaction: (string-ascii 20),
  satisfaction-disputed: (string-ascii 20),
  completely-paid: bool })


;; private functions
(define-private (increment-gig-count)
  (begin
    (var-set gig-count (+ (var-get gig-count) u1))
    (var-get gig-count)))

;; create gig
(define-public (create-gig (artist principal) (amount uint) (job-title (string-ascii 20)) (period uint))
  (let ((gig-id (increment-gig-count))
        (fee (/ (* amount commission) u1000))
        (gig-amount (- amount fee)))
    (try! (stx-transfer? gig-amount tx-sender (as-contract tx-sender)))
    (try! (stx-transfer? fee tx-sender (var-get contract-owner)))
    (map-set gig gig-id {
      from: tx-sender, to: artist,
      job: job-title, amount: gig-amount, block-created: block-height, block-accepted: u1, block-disputed: u1, period: period, status: "pending", 
      satisfaction: "initialized", satisfaction-disputed: "initialized", completely-paid: false})
    (ok gig-id)))


;; accept gig as artist, only if pending
;; check if you are the artist
;; check if pending
;; update date-accepted block-height
(define-public (accept-gig (gig-id uint)) 
  ;; refund will be date-accepted+period, when date-accepted is not 1
  (begin 
    (asserts! (is-eq tx-sender (get to (unwrap! (map-get? gig gig-id) ERR_NOT_FOUND))) ERR_NOT_ARTIST)
    (let ((gig-info (unwrap-panic (map-get? gig gig-id)))) 
      (asserts! (is-eq (get status gig-info) "pending") ERR_NOT_PENDING)
      (asserts! (<= block-height (+ (get block-created gig-info) (* u144 days))) ERR_EXPIRED)
      (map-set gig gig-id (merge gig-info {block-accepted: block-height, status: "accepted"}))
      (ok gig-id))))


;; decline gig as artist, only if pending
;; check if you are the artist
;; check if pending
;; send back the stx
(define-public (decline-gig (gig-id uint)) 
  (begin 
    (asserts! (is-eq tx-sender (get to (unwrap! (map-get? gig gig-id) ERR_NOT_FOUND))) ERR_NOT_ARTIST)
    (let ((gig-info (unwrap-panic (map-get? gig gig-id)))) 
      (asserts! (is-eq (get status gig-info) "pending") ERR_NOT_PENDING)
      (asserts! (<= block-height (+ (get block-created gig-info) (* u144 days))) ERR_EXPIRED)
      (try! (as-contract (stx-transfer? (get amount gig-info) tx-sender (get from gig-info))))
      (map-set gig gig-id (merge gig-info {status: "declined", completely-paid: true}))
      (ok gig-id))))


;; getter and setter for gig
(define-read-only (get-gig (gig-id uint)) 
  (ok (unwrap! (map-get? gig gig-id) ERR_NOT_FOUND)))

;; redeem back funds as client if no answer in 7-14 days
;; if client who created the gig, gig still pending, and created block-heigh + 14 days > block height 
(define-read-only (can-redeem (gig-id uint) (client principal))
  (let ((gig-info (unwrap-panic (map-get? gig gig-id)))) 
    (if (and 
      (and (is-eq (get from gig-info) client) (is-eq (get status gig-info) "pending"))
        (> block-height (+ (get block-created gig-info) (* u144 days))))
      (ok true)
      (ok false))))


;; redeem funds back
;; set status expired
;; completely paid true
(define-public (redeem-back (gig-id uint)) 
  (begin 
    (asserts! (is-some (map-get? gig gig-id)) ERR_NOT_FOUND)
    (let ((gig-info (unwrap-panic (map-get? gig gig-id)))) 
      (asserts! (is-eq tx-sender (get from gig-info)) ERR_NOT_CLIENT)
      (asserts! (unwrap-panic (can-redeem gig-id tx-sender)) ERR_NOT_REDEEMABLE)
      (try! (as-contract (stx-transfer? (get amount gig-info) tx-sender (get from gig-info))))
      (ok (map-set gig gig-id (merge gig-info {status: "expired", completely-paid: true}))))))


;; go-to-dispute
;; if time passed and DAO wallet wants to vote
;; if client/artist know the gig will not be done till specified end of time 

;; time end for gig -> block-created + period < current-block-height
;; if status == acepted => block-created != 1
(define-public (send-to-dispute (gig-id uint)) 
  (let ((gig-info (unwrap-panic (map-get? gig gig-id))))
    (asserts! (or (is-eq tx-sender (get from gig-info)) (is-eq tx-sender (get to gig-info))) ERR_NOT_PARTICIPANT)
    (asserts! (is-eq (get status gig-info) "accepted") ERR_NOT_ACCEPTED)
    (asserts! (<= block-height (+ (get block-accepted gig-info) (* u144 days))) ERR_EXPIRED)
    (ok (map-set gig gig-id (merge gig-info {block-disputed: block-height, status: "disputed"})))))


;; if time expired, DAO can send it to dispute 
(define-public (send-to-dispute-passed-time-acceptance (gig-id uint))
  (let ((gig-info (unwrap-panic (map-get? gig gig-id))))
    (asserts! (is-eq (var-get contract-owner) tx-sender)  ERR_NOT_DAO)
    (asserts! (> block-height (+ (get block-accepted gig-info) (get period gig-info))) ERR_NOT_EXPIRED)
    (asserts! (is-eq (get status gig-info) "accepted") ERR_NOT_ACCEPTED)
    (ok (map-set gig gig-id (merge gig-info {block-disputed: block-height, status: "disputed"})))))

;; to be used to see if time period is expired
;; only for accepted
(define-read-only (check-is-expired (gig-id uint)) 
  (if (is-none (map-get? gig gig-id))
    false
    (let ((gig-info (unwrap-panic (map-get? gig gig-id))))
      (if (and (is-eq (get status gig-info) "accepted") (> block-height (+ (get block-accepted gig-info) (get period gig-info))))
        true
        false))))


(define-private (is-satisfaction-valid (satisfaction (string-ascii 20))) 
  (if (is-eq satisfaction vote-1) true
    (if (is-eq satisfaction vote-2) true
      (if (is-eq satisfaction vote-3) true
        (if (is-eq satisfaction vote-4) true
          false)))))


;; vote result as client
;; the gig has to be in status: accepted
;; the status will become artist-review
(define-public (satisfaction-vote-gig-as-client (gig-id uint) (satisfaction-vote (string-ascii 20)))
  (begin 
    (asserts! (is-satisfaction-valid satisfaction-vote)  ERR_INVALID_SATISFACTION)
    (let ((gig-info (unwrap-panic (map-get? gig gig-id))))
    (asserts! (is-eq tx-sender (get from gig-info)) ERR_NOT_CLIENT)
    (asserts! (is-eq "accepted" (get status gig-info)) ERR_NOT_ACCEPTED)
    ;; if the time is passed, will still let him vote
    ;; if vote 100% agree -> sent stx right away
    (if (is-eq satisfaction-vote vote-1)
      (begin
        (as-contract (try! (stx-transfer? (get amount gig-info) tx-sender (get to gig-info))))
        (ok (map-set gig gig-id (merge gig-info {status: "completed" , satisfaction: satisfaction-vote, completely-paid: true})))
      )
      ;; if vote 100% disagree -> start dispute
      (if (is-eq satisfaction-vote vote-4)
        (ok (map-set gig gig-id (merge gig-info {block-disputed: block-height, status: "disputed" , satisfaction: satisfaction-vote})))
        ;; else change status to await for artist vote
        (ok (map-set gig gig-id (merge gig-info {status: "artist-review" , satisfaction: satisfaction-vote}))))))))


(define-public (satisfaction-acceptance-as-artist (gig-id uint) (acceptance bool)) 
  (let ((gig-info (unwrap-panic (map-get? gig gig-id))))
    (asserts! (is-eq tx-sender (get to gig-info)) ERR_NOT_ARTIST)
    (asserts! (is-eq "artist-review" (get status gig-info)) ERR_NOT_ACCEPTANCE)
    ;; if good -> pay money
    (if acceptance 
      (if (is-eq (get satisfaction gig-info) vote-2) ;; pay 75% and 25%
        (begin 
          (as-contract (try! (stx-transfer? (/ (* (get amount gig-info) u75) u100) tx-sender (get to gig-info))))
          (as-contract (try! (stx-transfer? (/ (* (get amount gig-info) u25) u100) tx-sender (get from gig-info))))
          (ok (map-set gig gig-id (merge gig-info {status: "completed", completely-paid: true}))))
        ;; else it is 50% 50% - vote-3
        (begin
          (as-contract (try! (stx-transfer? (/ (* (get amount gig-info) u50) u100) tx-sender (get to gig-info))))
          (as-contract (try! (stx-transfer? (/ (* (get amount gig-info) u50) u100) tx-sender (get from gig-info))))
          (ok (map-set gig gig-id (merge gig-info {status: "completed", completely-paid: true})))))
      ;; else not accepted, went to dispute
      (ok (map-set gig gig-id (merge gig-info {block-disputed: block-height, status: "disputed"}))))))


;; DAO vote on the matters
;; vote with multisig wallet
(define-public (dao-vote-satisfaction (gig-id uint) (satisfaction-vote (string-ascii 20)))
  (begin 
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR_NOT_DAO)
    (asserts! (is-satisfaction-valid satisfaction-vote)  ERR_INVALID_SATISFACTION)
    (let ((gig-info (unwrap-panic (map-get? gig gig-id))))
      (asserts! (is-eq (get status gig-info) "disputed")  ERR_NOT_DISPUTED)
      ;; if 0 -> all money to client
      (if (is-eq satisfaction-vote vote-1) 
        (as-contract (try! (stx-transfer? (get amount gig-info) tx-sender (get to gig-info))))
        (if (is-eq satisfaction-vote vote-2) 
          (begin
            (as-contract (try! (stx-transfer? (/ (* (get amount gig-info) u75) u100) tx-sender (get to gig-info))))
            (as-contract (try! (stx-transfer? (/ (* (get amount gig-info) u25) u100) tx-sender (get from gig-info)))))
          (if (is-eq satisfaction-vote vote-3) 
            (begin
              (as-contract (try! (stx-transfer? (/ (* (get amount gig-info) u50) u100) tx-sender (get to gig-info))))
              (as-contract (try! (stx-transfer? (/ (* (get amount gig-info) u50) u100) tx-sender (get from gig-info)))))
            ;; satisfaction-vote-4            
            (as-contract (try! (stx-transfer? (get amount gig-info) tx-sender (get from gig-info)))))))
      ;; set map with satisfaction-disputed: value-parsed, completely-paid: true, status: completed
      (ok (map-set gig gig-id (merge gig-info {status: "completed", satisfaction-disputed: satisfaction-vote, completely-paid: true}))))))





;; client satisfaction-factor (amount-to-artist amount-to-client)
;; initialized: 0% 0%
;; strongly-agree: 100% 0%
;; agree: 75% 25%
;; somewhat-agree: 50% 50%
;; disagree: 0% 100%

;; artist response:
;; agree -> takes how much the client said
;; disagree -> funds are transfared in the dispute contract where zero_autority and others select the fit amount


;; have a list with the gigs fom any given client. same for arist
;; would mean to append to the list every time a new gig is created