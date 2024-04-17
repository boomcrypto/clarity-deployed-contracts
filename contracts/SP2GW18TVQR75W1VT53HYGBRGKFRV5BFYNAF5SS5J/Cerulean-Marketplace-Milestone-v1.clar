
;; title: milestone
;; version:
;; constants
;;
(define-constant ERR_NOT_FOUND (err u404))
(define-constant ERR_EXPIRED (err u409))
(define-constant ERR_LESSTHAN_ONE_MONTH (err u410))
(define-data-var contract-owner principal tx-sender)
(define-constant commission u25)
(define-constant ERR_NOT_ARTIST (err u405))
(define-constant ERR_NOT_CLIENT (err u406))
(define-constant ERR_ALREADY_ACCEPTED (err u407))
(define-constant ERR_COPLETED_GIG (err u408))
(define-constant NOT_ACCEPTED (err u411))
(define-constant ERR_NOT_REDEEMABLE (err u412))
(define-constant ERR_NOT_AUTHORIZED (err u413))

(define-constant days u14)


;; data vars
;;
(define-data-var gig-count uint u0)

;; data maps
;; create a new gig - id
;; from: client who creates the gig
;; to: artist
;; JOB: string, but one of these
;; period: number of blocks in which artist has to end the work after accepting it
;; remaining-amount: amount that keeps the record of how much amount is hold by the contract of specific gig
;; current-stage: tracks which milestone is running for a particular gig
;; milestones: tracks all data related to milestones
(define-map gig uint { 
  from: principal,
  to: principal,
  job: (string-ascii 30), 
  block-created: uint,
  block-accepted: uint,
  period: uint,
  remaining-amount: uint,
  current-stage: uint,
  milestones: { first-mile: {amount:uint, completed:bool}, second-mile: {amount:uint, completed:bool},
   third-mile: {amount:uint, completed:bool}, fourth-mile: {amount:uint, completed:bool}, fifth-mile: {amount:uint, completed:bool}}
   }
)
;; public functions
;;
;; This is the function called by the client to create gig where they should enter the amount based on milestones
(define-public (create-milestone-gig (artist principal) (period uint) (job-title (string-ascii 30))
 (first-milestone-amount uint) (second-milestone-amount uint) (third-milestone-amount uint)
 (fourth-milestone-amount uint) (fifth-milestone-amount uint))
    (let ((gig-id (increment-gig-count)) (total-amount (+ first-milestone-amount second-milestone-amount third-milestone-amount fourth-milestone-amount fifth-milestone-amount)))
    (asserts! (> period (* u30 u144)) ERR_LESSTHAN_ONE_MONTH)
    (try! (stx-transfer? total-amount tx-sender (as-contract tx-sender)))
    (map-set gig gig-id {from: tx-sender, to:artist,job: job-title, block-created: block-height,block-accepted: u1,period: period,current-stage: u0,remaining-amount: total-amount, milestones: {
        first-mile: {amount: first-milestone-amount, completed:false}, second-mile: {amount:second-milestone-amount, completed:false}, third-mile: {amount:third-milestone-amount, completed:false},
        fourth-mile: {amount:fourth-milestone-amount, completed:false}, fifth-mile: {amount:fifth-milestone-amount, completed:false}}})
    (ok gig-id)
    )
)

(define-private (increment-gig-count)
  (begin
    (var-set gig-count (+ (var-get gig-count) u1))
    (var-get gig-count)))


;; This is the function called by the creator to accept the milestone gig
(define-public (accept-gig (gig-id uint))
(begin 
    (asserts! (is-eq tx-sender (get to (unwrap! (map-get? gig gig-id) ERR_NOT_FOUND))) ERR_NOT_ARTIST)
    (asserts! (> (get remaining-amount (unwrap-panic (map-get? gig gig-id))) u0) ERR_COPLETED_GIG)
    (let ((gig-info (unwrap-panic (map-get? gig gig-id)))
          (get-milestones  (get milestones gig-info))
          (get-stage (get current-stage gig-info))
          (get-first-milestone (get first-mile get-milestones))
          (amount (get amount get-first-milestone))
          (fee (/ (* amount commission) u1000)) 
    )
      (asserts! (is-eq get-stage u0) ERR_ALREADY_ACCEPTED)
      (asserts! (<= block-height (+ (get block-created gig-info) (* u144 days))) ERR_EXPIRED)
      (as-contract (try! (stx-transfer? ( - amount fee) tx-sender (get to gig-info))))
      (as-contract (try! (stx-transfer? fee tx-sender (var-get contract-owner))))
      (map-set gig gig-id (merge gig-info {block-accepted: block-height,current-stage: u1,remaining-amount:(- (get remaining-amount gig-info) amount) ,milestones: (merge get-milestones {first-mile:{amount:amount, completed: true}})}))
      (ok gig-id))
)
)

;; This function helps creator to decline the gig
(define-public (decline-gig (gig-id uint)) 
  (begin 
    (asserts! (is-eq tx-sender (get to (unwrap! (map-get? gig gig-id) ERR_NOT_FOUND))) ERR_NOT_ARTIST)
    (let ((gig-info (unwrap-panic (map-get? gig gig-id)))
        (get-stage (get current-stage gig-info))
    ) 
      (asserts! (is-eq get-stage u0) ERR_ALREADY_ACCEPTED)
      (asserts! (<= block-height (+ (get block-created gig-info) (* u144 days))) ERR_EXPIRED)
      (try! (as-contract (stx-transfer? (get remaining-amount gig-info) tx-sender (get from gig-info))))
      (map-set gig gig-id (merge gig-info {remaining-amount: u0}))
      (ok gig-id))))


;; This is the function called by the client to mark milestone as complete and sends the milestone amount
(define-public (complete-milestone (gig-id uint))
  (let ((gig-info (unwrap! (map-get? gig gig-id) ERR_NOT_FOUND))
        (get-milestones  (get milestones gig-info))
        (get-milestone (latest-milestone gig-id))
        (total-amount (get remaining-amount gig-info))
        (amount (get amount get-milestone))
        (current-stage (get current-stage gig-info))
        (fee (/ (* amount commission) u1000)) 
      ) 
    (asserts! (is-eq tx-sender (get from (unwrap! (map-get? gig gig-id) ERR_NOT_FOUND))) ERR_NOT_CLIENT)
    (asserts! (and  (not (get completed get-milestone)) (> amount u0)) ERR_COPLETED_GIG)
    (asserts! (>= current-stage u1) NOT_ACCEPTED)
    (as-contract (try! (stx-transfer? ( - amount fee) tx-sender (get to gig-info))))
    (as-contract (try! (stx-transfer? fee tx-sender (var-get contract-owner))))
      (if (is-eq current-stage u1) 
        (ok (map-set gig gig-id (merge gig-info {current-stage: (+ (get current-stage gig-info) u1),remaining-amount:(- total-amount amount),milestones: (merge get-milestones {second-mile:{amount:amount, completed: true}})})))
        (if (is-eq current-stage u2)
          (ok (map-set gig gig-id (merge gig-info {current-stage: (+ (get current-stage gig-info) u1),remaining-amount:(- total-amount amount),milestones: (merge get-milestones {third-mile:{amount:amount, completed: true}})})))
          (if (is-eq current-stage u3)
            (ok (map-set gig gig-id (merge gig-info {current-stage: (+ (get current-stage gig-info) u1),remaining-amount:(- total-amount amount),milestones: (merge get-milestones {fourth-mile:{amount:amount, completed: true}})})))
            (ok (map-set gig gig-id (merge gig-info {current-stage: (+ (get current-stage gig-info) u1),remaining-amount:(- total-amount amount),milestones: (merge get-milestones {fifth-mile:{amount:amount, completed: true}})})))
      )
    ))
  )
)
;; This is the function called by the client or creator
;; If the client don't reedeem-fund after 5 days of end date then creator can redeem it and client don't

(define-public (redeem-fund (gig-id uint)) 
  (begin 
    (asserts! (is-some (map-get? gig gig-id)) ERR_NOT_FOUND)
    (let ((gig-info (unwrap-panic (map-get? gig gig-id)))) 
      (asserts! (or (is-eq tx-sender (get from gig-info)) (is-eq tx-sender (get to gig-info))) ERR_NOT_AUTHORIZED)
      (if (is-eq tx-sender (get from gig-info))
          (begin 
            (asserts! (unwrap-panic (can-client-redeem gig-id tx-sender)) ERR_NOT_REDEEMABLE)
            (try! (as-contract (stx-transfer? (get remaining-amount gig-info) tx-sender (get from gig-info))))
          )
          (let ((total-amount (get remaining-amount gig-info))
                (fee (/ (* total-amount commission) u1000))
              )
            (asserts! (unwrap-panic (can-creator-redeem gig-id tx-sender)) ERR_NOT_REDEEMABLE)       
            (try! (as-contract (stx-transfer? (- (get remaining-amount gig-info) fee) tx-sender (get to gig-info))))
            (as-contract (try! (stx-transfer? fee tx-sender (var-get contract-owner))))
          )
      )
      (ok (map-set gig gig-id (merge gig-info {remaining-amount: u0})))
    )
  )
)

;; read only functions
;;
(define-read-only (get-gig (gig-id uint)) 
  (ok (unwrap! (map-get? gig gig-id) ERR_NOT_FOUND)));; private functions
;;

;; if client who created the gig didn't collect his collateral after 5 days of end date then creator will collect it.
(define-read-only (can-creator-redeem (gig-id uint) (creator principal))
 (let ((gig-info (unwrap-panic (map-get? gig gig-id)))) 
    (if (and (and (and (is-eq (get to gig-info) creator) 
            (> (get remaining-amount gig-info) u0))
            (>  (get current-stage gig-info) u0)
        (> block-height (+ (+ (get block-accepted gig-info) (get period gig-info) (* u5 u144))))))
      (ok true)
      (ok false)
)))

;; redeem back funds as client if no answer in 7-14 days
(define-read-only (can-client-redeem (gig-id uint) (client principal))
 (let ((gig-info (unwrap-panic (map-get? gig gig-id)))) 
    (if (and 
      (and (is-eq (get from gig-info) client) (> (get remaining-amount gig-info) u0))
        (> block-height (+ (get block-created gig-info) (* u144 days))))
      (if (and (> block-height (+ (+ (get block-accepted gig-info) (get period gig-info) (* u5 u144))))
           (>  (get current-stage gig-info) u0)
      ) 
          (ok false) 
          (ok true))
      (ok false))))


(define-private (latest-milestone (gig-id uint))
 (let ((gig-info (unwrap-panic (map-get? gig gig-id)))
       (get-milestones  (get milestones gig-info))
       (get-stage (get current-stage gig-info))
      )
      (if (is-eq get-stage u1)
          (get second-mile get-milestones)
          (if (is-eq get-stage u2)
              (get third-mile get-milestones)
            (if (is-eq get-stage u3)
                (get fourth-mile get-milestones)
                (get fifth-mile get-milestones)
            )
          )
      )
  )
)
;; to be used to see if time period is expired
;; only for accepted
(define-read-only (check-is-expired (gig-id uint)) 
  (if (is-none (map-get? gig gig-id))
    false
    (let ((gig-info (unwrap-panic (map-get? gig gig-id)))
          (get-stage (get current-stage gig-info))
          (current-stage (get current-stage gig-info)))
      (if (and (>= current-stage u1) (> block-height (+ (get block-accepted gig-info) (get period gig-info))))
        true
        false))))