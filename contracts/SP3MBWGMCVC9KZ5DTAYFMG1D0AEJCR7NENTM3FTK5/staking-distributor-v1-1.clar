;; @contract Staking Distributor
;; @version 1.1

(impl-trait .staking-distributor-trait-v1-1.staking-distributor-trait)

(use-trait treasury-trait .treasury-trait-v1-1.treasury-trait)

;; ------------------------------------------
;; Constants
;; ------------------------------------------

(define-constant ERR-NOT-AUTHORIZED u3103001)

(define-constant ERR-WRONG-TREASURY u3102001)

;; ------------------------------------------
;; Variables
;; ------------------------------------------

(define-data-var active-treasury principal .treasury-v1-1)

;; ------------------------------------------
;; Maps
;; ------------------------------------------

(define-map recipient-info
  { recipient: principal }
  {
    rate: uint
  }
)

(define-map recipient-adjust
  { recipient: principal }
  {
    add: bool,
    rate: uint,
    target: uint
  }
)

;; ------------------------------------------
;; Var & Map Helpers
;; ------------------------------------------

(define-read-only (get-active-treasury)
  (var-get active-treasury)
)

(define-read-only (get-recipient-info (recipient principal))
  (default-to
    {
      rate: u0,
    }
    (map-get? recipient-info { recipient: recipient })
  )
)

(define-read-only (get-recipient-adjust (recipient principal))
  (default-to
    {
      add: true,
      rate: u0,
      target: u0
    }
    (map-get? recipient-adjust { recipient: recipient })
  )
)

;; ------------------------------------------
;; Distribute
;; ------------------------------------------

(define-public (distribute (treasury <treasury-trait>))
  (let (
    (recipient tx-sender)
    (info (get-recipient-info recipient))
    (info-rate (get rate info))
    (next-reward (unwrap-panic (get-next-reward-at info-rate)))
  )
    (asserts! (is-eq (contract-of treasury) (var-get active-treasury)) (err ERR-WRONG-TREASURY))

    (if (is-eq next-reward u0)
      (ok u0)
      (begin
        (try! (contract-call? treasury mint recipient next-reward))
        (unwrap-panic (adjust recipient))
        (ok next-reward)
      )
    )
  )
)

;; ------------------------------------------
;; Adjust
;; ------------------------------------------

(define-private (adjust (recipient principal))
  (let (
    (next-rate (unwrap-panic (next-adjust-rate recipient)))
  )
    (if (is-eq next-rate u0)
      (ok u0)
      (begin
        (map-set recipient-info { recipient: recipient } { rate: next-rate })
        (ok next-rate)
      )
    )
  )
)

(define-read-only (next-adjust-rate (recipient principal))
  (let (
    (info (get-recipient-info recipient))
    (info-rate (get rate info))

    (adjust-add (get add (get-recipient-adjust recipient)))
    (adjust-rate (get rate (get-recipient-adjust recipient)))
    (adjust-target (get target (get-recipient-adjust recipient)))
  )
    (if (is-eq adjust-rate u0)
      (ok u0)
      (begin
        (if (is-eq adjust-add true)
          (let (
            (new-rate (+ info-rate adjust-rate))
          )
            (if (>= new-rate adjust-target)
              (ok u0)
              (ok new-rate)
            )
          )
          (let (
            (new-rate (- info-rate adjust-rate))
          )
            (if (<= new-rate adjust-target)
              (ok u0)
              (ok new-rate)
            )
          )
        )
      )
    )
  )
)

;; ------------------------------------------
;; Getters
;; ------------------------------------------

(define-read-only (get-next-reward-at (rate uint))
  (let (
    (total-supply (unwrap-panic (contract-call? .lydian-token get-total-supply)))
    (rate-denominator u1000000)
  )
    (ok (/ (* total-supply rate) rate-denominator))
  )
)

(define-read-only (get-next-reward-for (recipient principal))
  (let (
    (info-rate (get rate (get-recipient-info recipient)))
    (next-reward (unwrap-panic (get-next-reward-at info-rate)))
  )
    (ok next-reward)
  )
)

;; ------------------------------------------
;; Admin
;; ------------------------------------------

(define-public (set-active-treasury (treasury principal))
  (begin
    (asserts! (is-eq tx-sender .lydian-dao) (err ERR-NOT-AUTHORIZED))

    (var-set active-treasury treasury)
    (ok true)
  )
)

(define-public (add-recipient (recipient principal) (reward-rate uint))
  (begin
    (asserts! (is-eq tx-sender .lydian-dao) (err ERR-NOT-AUTHORIZED))

    (map-set recipient-info 
      { recipient: recipient } 
      { 
        rate: reward-rate
      }
    )
    (ok true)
  )
)

(define-public (set-adjustment (recipient principal) (add bool) (rate uint) (target uint))
  (begin
    (asserts! (is-eq tx-sender .lydian-dao) (err ERR-NOT-AUTHORIZED))

    (map-set recipient-adjust 
      { recipient: recipient } 
      { 
        add: add, 
        rate: rate,
        target: target
      }
    )
    (ok true)
  )
)
