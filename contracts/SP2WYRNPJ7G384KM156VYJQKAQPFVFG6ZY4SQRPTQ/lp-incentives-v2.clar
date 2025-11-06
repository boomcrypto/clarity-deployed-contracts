;; Data vars

;; Epoch details
(define-data-var epoch-details {
  epoch-start-time: uint,
  epoch-end-time: uint,
  epoch-rewards: uint,
  epoch-initiated: bool,
  epoch-completed: bool
} {
  epoch-start-time: u0,
  epoch-end-time: u0,
  epoch-rewards: u0,
  epoch-initiated: false,
  epoch-completed: false
})

(define-data-var last-snapshot-details {
  snapshot-time: uint,
  total-lp-shares: uint,
  percent-of-epoch: uint,
} {
  snapshot-time: u0,
  total-lp-shares: u0,
  percent-of-epoch: u0
})

(define-map user-rewards principal {
  earned-rewards: uint,
  claimed-rewards: bool,
})
(define-data-var unclaimed-user-reward-count uint u0)

(define-data-var snapshot-uploader principal contract-caller)

;; CONSTANTS
(define-constant SUCCESS (ok true))
(define-constant scaling-factor (pow u10 (contract-call? 'SP1M6MHD4EJ70MPJSH1C0PXSHCQ3D9C881AB7CVAZ.constants-v1 get-market-token-decimals)))

;; Errors
(define-constant ERR-NOT-SNAPSHOT-UPLOADER (err u100000))
(define-constant ERR-EPOCH-INITIATED (err u100001))
(define-constant ERR-EPOCH-CLOSED (err u100002))
(define-constant ERR-EPOCH-INCOMPLETE (err u100003))
(define-constant ERR-EPOCH-NOT-INITIALIZED (err u100004))
(define-constant ERR-INVALID-START-AND-END-TIME (err u100005))
(define-constant ERR-ZERO-LP-SHARES (err u100006))
(define-constant ERR-ZERO-REWARDS (err u100007))
(define-constant ERR-NO-USER-REWARDS (err u100008))
(define-constant ERR-USER-REWARDS-CLAIMED (err u100009))
(define-constant ERR-FAILED-TO-GET-LP-BALANCE (err u100010))
(define-constant ERR-REWARDS-NOT-CLAIMED (err u100011))
(define-constant ERR-INVALID-SNAPSHOT-TIME (err u100012))

;; Read-only functions
(define-read-only (get-epoch-details)
  (ok (var-get epoch-details))
)

(define-read-only (get-last-snapshot-details)
  (ok (var-get last-snapshot-details))
)

(define-read-only (get-user-rewards (user principal))
  (ok (map-get? user-rewards user))
)

(define-read-only (get-snapshot-uploader)
  (ok (var-get snapshot-uploader))
)

(define-read-only (get-unclaimed-user-reward-count)
  (ok (var-get unclaimed-user-reward-count))
)

;; Public functions

(define-public (initiate-epoch (details {
  epoch-start-time: uint,
  epoch-end-time: uint,
  epoch-rewards: uint,
}))
  (begin 
    (try! (ensure-snapshot-uploader))
    (try! (ensure-epoch-uninitialized))
    (asserts! (> (get epoch-end-time details) (get epoch-start-time details)) ERR-INVALID-START-AND-END-TIME)
    (asserts! (> (get epoch-rewards details) u0) ERR-ZERO-REWARDS)
    (var-set epoch-details {
      epoch-start-time: (get epoch-start-time details),
      epoch-end-time: (get epoch-end-time details),
      epoch-rewards: (get epoch-rewards details),
      epoch-initiated: true,
      epoch-completed: false
    })
    (var-set last-snapshot-details {
      snapshot-time: (get epoch-start-time details),
      total-lp-shares: u0,
      percent-of-epoch: u0,
    })
    (print {
      action: "epoch-initiated",
      epoch-details: details
    })
    SUCCESS
))

(define-public (claim-rewards (on-behalf-of (optional principal)))
  (let (
      (user (default-to contract-caller on-behalf-of))
      (rewards (unwrap! (map-get? user-rewards user) ERR-NO-USER-REWARDS))
      (reward-amount (get earned-rewards rewards))
    )
    (try! (ensure-epoch-closed))
    (asserts! (not (get claimed-rewards rewards)) ERR-USER-REWARDS-CLAIMED)
    (if (> reward-amount u0) 
      (as-contract (try! (contract-call? 'SP1M6MHD4EJ70MPJSH1C0PXSHCQ3D9C881AB7CVAZ.state-v1 transfer reward-amount (as-contract contract-caller) user none)))
      true
    )
    (map-set user-rewards user {
      earned-rewards: (get earned-rewards rewards),
      claimed-rewards: true,
    })
    (var-set unclaimed-user-reward-count (- (var-get unclaimed-user-reward-count) u1))
    (print {
      action: "claim-rewards",
      claimed-rewards: reward-amount,
      user: user
    })
    SUCCESS
))

(define-public (transfer-remaining-lp-tokens (recipient principal))
  (let ((balance (unwrap! (contract-call? 'SP1M6MHD4EJ70MPJSH1C0PXSHCQ3D9C881AB7CVAZ.state-v1 get-balance (as-contract contract-caller)) ERR-FAILED-TO-GET-LP-BALANCE)))
    (try! (ensure-snapshot-uploader))
    (try! (ensure-epoch-closed))
    (asserts! (is-eq (var-get unclaimed-user-reward-count) u0) ERR-REWARDS-NOT-CLAIMED)
    (asserts! (> balance u0) ERR-ZERO-REWARDS)
    (as-contract (try! (contract-call? 'SP1M6MHD4EJ70MPJSH1C0PXSHCQ3D9C881AB7CVAZ.state-v1 transfer balance (as-contract contract-caller) recipient none)))
    (print {
      action: "transfer-remaining-lp-tokens",
      balance: balance,
      recipient: recipient
    })
    SUCCESS
))

(define-public (upload-snapshot (details {snapshot-time: uint, total-lp-shares: uint}) (batch (list 50 (optional {user: principal, lp-shares: uint}))))
  (let (
    (prev-snapshot (var-get last-snapshot-details))
    (prev-snapshot-time (get snapshot-time prev-snapshot))
    (epoch (var-get epoch-details))
    (epoch-start-time (get epoch-start-time epoch))
    (epoch-end-time (get epoch-end-time epoch))
    (snapshot-time (get snapshot-time details))
    (prev-percent-of-epoch (get percent-of-epoch prev-snapshot))
    (percent-of-epoch (try! (calculate-percent-of-epoch snapshot-time prev-snapshot-time epoch-start-time epoch-end-time prev-percent-of-epoch)))
  )
  (try! (ensure-snapshot-uploader))
  (try! (ensure-epoch-initialized))
  (try! (ensure-epoch-not-closed))
  (asserts! (> (get total-lp-shares details) u0) ERR-ZERO-LP-SHARES)
  (var-set last-snapshot-details {
    snapshot-time: snapshot-time,
    total-lp-shares: (get total-lp-shares details),
    percent-of-epoch: percent-of-epoch
  })
  (let ((new-users-count (try! (fold fold-upload-snapshot batch (ok u0)))))
    (var-set unclaimed-user-reward-count (+ (var-get unclaimed-user-reward-count) new-users-count))
    (print {
      action: "snapshot-uploaded",
      new-user-count: new-users-count,
      total-user-count: (var-get unclaimed-user-reward-count),
      details: details,
      percent-of-epoch: percent-of-epoch
    })
    SUCCESS
)))

(define-public (close-epoch)
  (let (
    (prev-snapshot (var-get last-snapshot-details))
    (prev-snapshot-time (get snapshot-time prev-snapshot))
    (epoch (var-get epoch-details))
    (epoch-end-time (get epoch-end-time epoch))
  )
    (try! (ensure-snapshot-uploader))
    (try! (ensure-epoch-initialized))
    (try! (ensure-epoch-not-closed))
    (asserts! (>= prev-snapshot-time epoch-end-time) ERR-EPOCH-INCOMPLETE)
    (var-set epoch-details {
      epoch-start-time: (get epoch-start-time epoch),
      epoch-end-time: (get epoch-end-time epoch),
      epoch-rewards: (get epoch-rewards epoch),
      epoch-initiated: true,
      epoch-completed: true
    })
    (print {action: "epoch-closed"})
    SUCCESS
  )
)


;; private functions

(define-private (ensure-snapshot-uploader)
  (begin 
    (asserts! (is-eq contract-caller (var-get snapshot-uploader)) ERR-NOT-SNAPSHOT-UPLOADER)
    SUCCESS
))

(define-private (ensure-epoch-uninitialized)
  (begin
    (asserts! (not (get epoch-initiated (var-get epoch-details))) ERR-EPOCH-INITIATED)
    SUCCESS  
))

(define-private (ensure-epoch-initialized)
  (begin
    (asserts! (get epoch-initiated (var-get epoch-details)) ERR-EPOCH-NOT-INITIALIZED)
    SUCCESS  
))

(define-private (ensure-epoch-closed)
  (begin
    (asserts! (get epoch-completed (var-get epoch-details)) ERR-EPOCH-INCOMPLETE)
    SUCCESS  
))

(define-private (ensure-epoch-not-closed)
  (begin
    (asserts! (not (get epoch-completed (var-get epoch-details))) ERR-EPOCH-CLOSED)
    SUCCESS  
))

(define-private (calculate-percent-of-epoch (snapshot-time uint) (prev-snapshot-time uint) (epoch-start-time uint) (epoch-end-time uint) (percent-of-epoch uint))
  (begin 
    ;; multiple transaction for same snapshot can arrive due to limitation on 50 users per transaction.
    (asserts! (>= snapshot-time prev-snapshot-time) ERR-INVALID-SNAPSHOT-TIME)
    (asserts! (<= snapshot-time epoch-end-time) ERR-INVALID-SNAPSHOT-TIME)
    (if (is-eq snapshot-time prev-snapshot-time)
      (ok percent-of-epoch)
      (ok (/ (* (- snapshot-time prev-snapshot-time) scaling-factor) (- epoch-end-time epoch-start-time)))
    )
))

(define-private (fold-upload-snapshot (user-data (optional {user: principal, lp-shares: uint})) (res (response uint uint)))
  (begin
    (match res count 
      (begin 
        (match user-data data
          (let (
            (user (get user data))
            (lp-shares (get lp-shares data))
            (updated-count (update-user-rewards user lp-shares)))
              (ok (+ updated-count count)))
          res
      )) 
    err-val res)
))

(define-private (update-user-rewards (user principal) (lp-shares uint) )
  (let (
      (snapshot (var-get last-snapshot-details))
      (epoch (var-get epoch-details))
      (maybe-user-rewards (map-get? user-rewards user))
      (snapshot-lp-shares (get total-lp-shares snapshot))
      (total-rewards (get epoch-rewards epoch))
      (percent-of-epoch (get percent-of-epoch snapshot))
      (percent-of-lp-shares (/ (* lp-shares scaling-factor) snapshot-lp-shares))
      (snapshot-rewards (/ (* percent-of-epoch percent-of-lp-shares total-rewards) (* scaling-factor scaling-factor)))
    )

    (match maybe-user-rewards rewards 
      (let (
          (current-rewards (get earned-rewards rewards))
          (total-earned-rewards (+ current-rewards snapshot-rewards))
        )
        (map-set user-rewards user {
          earned-rewards: total-earned-rewards,
          claimed-rewards: false,
        })
        (print {
          action: "user-rewards",
          prev-rewards: current-rewards,
          new-rewards: snapshot-rewards,
          total-rewards: total-earned-rewards,
          percent-of-lp-shares: percent-of-lp-shares,
          user: user
        })
        u0
      )
      (begin
        (map-set user-rewards user {
          earned-rewards: snapshot-rewards,
          claimed-rewards: false,
        })
        (print {
          action: "user-rewards",
          new-rewards: snapshot-rewards,
          total-rewards: snapshot-rewards,
          percent-of-lp-shares: percent-of-lp-shares,
          user: user
        })
        u1
      )
)))
