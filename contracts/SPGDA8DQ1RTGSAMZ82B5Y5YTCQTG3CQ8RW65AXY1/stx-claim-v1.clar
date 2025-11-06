;; SPDX-License-Identifier: BUSL-1.1
;; Data vars

(define-map user-rewards principal {
  earned-rewards: uint,
  claimed-rewards: bool,
})

;; CONSTANTS
(define-constant SUCCESS (ok true))

;; Errors
(define-constant ERR-NO-USER-REWARDS (err u130001))
(define-constant ERR-USER-REWARDS-CLAIMED (err u130002))

;; Read-only functions
(define-read-only (get-user-rewards (user principal))
  (ok (map-get? user-rewards user))
)

;; Public functions

(define-public (claim-rewards)
  (let (
      (user contract-caller)
      (rewards (unwrap! (map-get? user-rewards user) ERR-NO-USER-REWARDS))
      (reward-amount (get earned-rewards rewards))
    )
    (asserts! (not (get claimed-rewards rewards)) ERR-USER-REWARDS-CLAIMED)
    (if (> reward-amount u0) 
      (as-contract (try! (stx-transfer? reward-amount (as-contract contract-caller) user)))
      true
    )
    (map-set user-rewards user {
      earned-rewards: (get earned-rewards rewards),
      claimed-rewards: true,
    })
    (print {
      action: "claim-rewards",
      claimed-rewards: reward-amount,
      user: user
    })
    SUCCESS
))

(define-private (set-user-rewards (user principal) (rewards uint) )
  (begin 
    (map-set user-rewards user {
      earned-rewards: rewards,
      claimed-rewards: false,
    })
    (print {
      action: "user-rewards",
      new-rewards: rewards,
      user: user
    })
  )
)

(set-user-rewards 'SP1GJSC4GG3MDA1KYZJYS9FEVCKHASR1N7089BEQK u2000)