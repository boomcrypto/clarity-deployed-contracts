---
title: "Trait lp-incentives-v1"
draft: true
---
```

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

(define-data-var next-snapshot-id uint u0)
(define-map snapshot-details uint {
  snapshot-time: uint,
  total-lp-shares: uint,
})

(define-map user-rewards principal {
  earned-rewards: uint,
  last-snapshot: uint,
  claimed-rewards: bool,
})
(define-data-var unclaimed-user-reward-count uint u0)

(define-data-var snapshot-uploader principal contract-caller)

;; CONSTANTS
(define-constant SUCCESS (ok true))
(define-constant scaling-factor (pow u10 (contract-call? 'SP35E2BBMDT2Y1HB0NTK139YBGYV3PAPK3WA8BRNA.constants-v1 get-market-token-decimals)))

;; Errors
(define-constant ERR-NOT-SNAPSHOT-UPLOADER (err u100000))
(define-constant ERR-EPOCH-INITIATED (err u100001))
(define-constant ERR-MISSING-SNAPSHOT (err u100002))
(define-constant ERR-SNAPSHOT-INCOMPLETE (err u100003))
(define-constant ERR-EPOCH-CLOSED (err u100004))
(define-constant ERR-EPOCH-INCOMPLETE (err u100005))
(define-constant ERR-EPOCH-NOT-INITIALIZED (err u100006))
(define-constant ERR-INVALID-START-AND-END-TIME (err u100007))
(define-constant ERR-ZERO-LP-SHARES (err u100008))
(define-constant ERR-ZERO-REWARDS (err u100009))
(define-constant ERR-NO-USER-REWARDS (err u100010))
(define-constant ERR-USER-REWARDS-CLAIMED (err u100011))
(define-constant ERR-FAILED-TO-GET-LP-BALANCE (err u100012))
(define-constant ERR-REWARDS-NOT-CLAIMED (err u100013))
(define-constant ERR-DUPLICATE-USER-REWARDS (err u100014))
(define-constant ERR-OLD-SNAPSHOT (err u100015))
(define-constant ERR-INVALID-SNAPSHOT-TIME (err u100016))

;; Read-only functions
(define-read-only (get-epoch-details)
  (ok (var-get epoch-details))
)

(define-read-only (get-snapshot-details (snapshot-id uint))
  (ok (map-get? snapshot-details snapshot-id))
)

(define-read-only (get-user-rewards (user principal))
  (ok (map-get? user-rewards user))
)

(define-read-only (get-snapshot-uploader)
  (ok (var-get snapshot-uploader))
)

(define-read-only (get-next-snapshot-id)
  (ok (var-get next-snapshot-id))
)

(define-read-only (get-unclaimed-user-reward-count)
  (ok (var-get unclaimed-user-reward-count))
)

;; Public functions

(define-public (initiate-epoch (details {
  epoch-start-time: uint,
  epoch-end-time: uint,
  epoch-rewards: uint,
  snapshot-uploader: principal
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
    (var-set snapshot-uploader (get snapshot-uploader details))
    (print {
      action: "epoch-initiated",
      epoch-details: details
    })
    SUCCESS
))


(define-public (initiate-new-snapshot (details {
  snapshot-time: uint,
  total-lp-shares: uint
}))
  (let ((snapshot-id (var-get next-snapshot-id)))
    (try! (ensure-snapshot-uploader))
    (try! (ensure-epoch-initialized))
    (try! (ensure-current-snapshot-completed (get snapshot-time details)))
    (asserts! (> (get total-lp-shares details) u0) ERR-ZERO-LP-SHARES)
    (map-set snapshot-details snapshot-id details)
    (var-set next-snapshot-id (+ snapshot-id u1))
    (print {
      action: "new-snapshot-initiated",
      snapshot-id: snapshot-id,
      snapshot-details: details,
    })
    (ok snapshot-id)
  )
)

(define-public (close-epoch)
  (let ((epoch (var-get epoch-details)))
    (try! (ensure-snapshot-uploader))
    (try! (ensure-epoch-initialized))
    (try! (can-close-epoch epoch))
    (var-set epoch-details {
      epoch-start-time: (get epoch-start-time epoch),
      epoch-end-time: (get epoch-end-time epoch),
      epoch-rewards: (get epoch-rewards epoch),
      epoch-initiated: true,
      epoch-completed: true
    })
    (print {
      action: "epoch-closed",
      details: (var-get epoch-details)
    })
    SUCCESS
  )
)

(define-public (claim-rewards (on-behalf-of (optional principal)))
  (let (
      (user (default-to contract-caller on-behalf-of))
      (rewards (unwrap! (map-get? user-rewards user) ERR-NO-USER-REWARDS))
      (reward-amount (get earned-rewards rewards))
    )
    (try! (ensure-epoch-closed))
    (asserts! (not (get claimed-rewards rewards)) ERR-USER-REWARDS-CLAIMED)
    (asserts! (> reward-amount u0) ERR-NO-USER-REWARDS)
    (as-contract (try! (contract-call? 'SP35E2BBMDT2Y1HB0NTK139YBGYV3PAPK3WA8BRNA.state-v1 transfer reward-amount (as-contract contract-caller) user none)))
    (map-set user-rewards user {
      earned-rewards: (get earned-rewards rewards),
      last-snapshot: (get last-snapshot rewards),
      claimed-rewards: true,
    })
    (var-set unclaimed-user-reward-count (- (var-get unclaimed-user-reward-count) u1))
    (print {
      action: "claim-rewards",
      claied-rewards: reward-amount,
      user: user
    })
    SUCCESS
))

(define-public (transfer-remaining-lp-tokens (recipient principal))
  (let ((balance (unwrap! (contract-call? 'SP35E2BBMDT2Y1HB0NTK139YBGYV3PAPK3WA8BRNA.state-v1 get-balance (as-contract contract-caller)) ERR-FAILED-TO-GET-LP-BALANCE)))
    (try! (ensure-snapshot-uploader))
    (try! (ensure-epoch-closed))
    (asserts! (is-eq (var-get unclaimed-user-reward-count) u0) ERR-REWARDS-NOT-CLAIMED)
    (asserts! (> balance u0) ERR-ZERO-REWARDS)
    (as-contract (try! (contract-call? 'SP35E2BBMDT2Y1HB0NTK139YBGYV3PAPK3WA8BRNA.state-v1 transfer balance (as-contract contract-caller) recipient none)))
    (print {
      action: "transfer-remaining-lp-tokens",
      balance: balance,
      recipient: recipient
    })
    SUCCESS
))

(define-public (upload-snapshot (batch (list 50 (optional {user: principal, lp-shares: uint, snapshot-id: uint}))))
  (let ((new-users-count (try! (fold fold-upload-snapshot batch (ok u0)))))
    (try! (ensure-snapshot-uploader))
    (var-set unclaimed-user-reward-count (+ (var-get unclaimed-user-reward-count) new-users-count))
    (print {
      action: "snapshot-uploaded",
      new-user-count: new-users-count,
      total-user-count: (var-get unclaimed-user-reward-count)
    })
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

(define-private (can-close-epoch (epoch {
  epoch-start-time: uint,
  epoch-end-time: uint,
  epoch-rewards: uint,
  epoch-initiated: bool,
  epoch-completed: bool
}))
  (let ((block-timestamp (unwrap-panic (get-stacks-block-info? time (- stacks-block-height u1)))))
    (asserts! (not (get epoch-completed epoch)) ERR-EPOCH-CLOSED)
    (asserts! (>= block-timestamp (get epoch-end-time epoch)) ERR-EPOCH-INCOMPLETE)
    SUCCESS
))

(define-private (ensure-current-snapshot-completed (new-snapshot-time uint))
  (if (is-eq (var-get next-snapshot-id) u0)
    SUCCESS
    (let (
        (current-snapshot-id (- (var-get next-snapshot-id) u1))
        (snapshot-time (get snapshot-time (unwrap! (map-get? snapshot-details current-snapshot-id) ERR-MISSING-SNAPSHOT)))
        (block-timestamp (unwrap-panic (get-stacks-block-info? time (- stacks-block-height u1))))
      )

      (asserts! (>= block-timestamp snapshot-time) ERR-SNAPSHOT-INCOMPLETE)
      (asserts! (> new-snapshot-time snapshot-time) ERR-INVALID-SNAPSHOT-TIME)
      SUCCESS  
    )
  )
)

(define-private (fold-upload-snapshot (user-data (optional {user: principal, lp-shares: uint, snapshot-id: uint})) (res (response uint uint)))
  (begin
    (match res count 
      (begin 
        (match user-data data
          (let (
            (user (get user data))
            (lp-shares (get lp-shares data))
            (snapshot-id (get snapshot-id data))
            (updated-count (try! (update-user-rewards user lp-shares snapshot-id))))
              (ok (+ updated-count count)))
          res
      )) 
    err-val res)
))

(define-private (get-snapshot-time (snapshot-id uint))
  (let ((snapshot (unwrap! (map-get? snapshot-details snapshot-id) ERR-MISSING-SNAPSHOT)))
    (ok (get snapshot-time snapshot))
  )
)

(define-private (update-user-rewards (user principal) (lp-shares uint) (snapshot-id uint))
  (let (
      (snapshot (unwrap! (map-get? snapshot-details snapshot-id) ERR-MISSING-SNAPSHOT))
      (epoch (var-get epoch-details))
      (previous-snapshot-time (if (is-eq snapshot-id u0) (get epoch-start-time epoch) (try! (get-snapshot-time (- snapshot-id u1)))))
      (snapshot-time (get snapshot-time snapshot))
      (epoch-start-time (get epoch-start-time epoch))
      (epoch-end-time (get epoch-end-time epoch))
      (maybe-user-rewards (map-get? user-rewards user))
      (snapshot-lp-shares (get total-lp-shares snapshot))
      (total-rewards (get epoch-rewards epoch))
      (percent-of-epoch (/ (* (- snapshot-time previous-snapshot-time) scaling-factor) (- epoch-end-time epoch-start-time)))
      (percent-of-lp-shares (/ (* lp-shares scaling-factor) snapshot-lp-shares))
      (snapshot-rewards (/ (* percent-of-epoch percent-of-lp-shares total-rewards) (* scaling-factor scaling-factor)))
    )

    (match maybe-user-rewards rewards 
      (let (
          (current-rewards (get earned-rewards rewards))
          (total-earned-rewards (+ current-rewards snapshot-rewards))
          (last-snapshot-id (get last-snapshot rewards))
          (current-snapshot-id (- (var-get next-snapshot-id) u1))
        )
        (asserts! (> snapshot-id last-snapshot-id) ERR-DUPLICATE-USER-REWARDS)
        (asserts! (is-eq snapshot-id current-snapshot-id) ERR-OLD-SNAPSHOT)
        (map-set user-rewards user {
          earned-rewards: total-earned-rewards,
          last-snapshot: snapshot-id,
          claimed-rewards: false,
        })
        (print {
          action: "user-rewards",
          prev-rewards: current-rewards,
          new-rewards: snapshot-rewards,
          total-rewards: total-earned-rewards,
          percent-of-epoch: percent-of-epoch,
          percent-of-lp-shares: percent-of-lp-shares,
          user: user
        })
        (ok u0)
      )
      (begin
        (map-set user-rewards user {
          earned-rewards: snapshot-rewards,
          last-snapshot: snapshot-id,
          claimed-rewards: false,
        })
        (print {
          action: "user-rewards",
          new-rewards: snapshot-rewards,
          total-rewards: snapshot-rewards,
          percent-of-epoch: percent-of-epoch,
          percent-of-lp-shares: percent-of-lp-shares,
          user: user
        })
        (ok u1)
      )
    )
  )
)

```
