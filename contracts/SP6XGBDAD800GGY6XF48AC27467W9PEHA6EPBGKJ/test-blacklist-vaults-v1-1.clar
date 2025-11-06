;; @contract Blacklist
;; @version 1

;;-------------------------------------
;; Constants
;;-------------------------------------

(define-constant ERR_NOT_BLACKLISTER (err u106001))
(define-constant ERR_SOFT_BLACKLISTED (err u106002))
(define-constant ERR_FULLY_BLACKLISTED (err u106003))

;;-------------------------------------
;; Variables
;;-------------------------------------

(define-data-var soft-blacklist-enabled bool true)
(define-data-var full-blacklist-enabled bool true)

;;-------------------------------------
;; Maps
;;-------------------------------------

(define-map blacklister
  {
    address: principal
  }
  {
    active: bool,
  }
)

(define-map blacklist
  {
    address: principal
  }
  {
    soft: bool,
    full: bool
  }
)

;;-------------------------------------
;; Getters
;;-------------------------------------

(define-read-only (get-soft-blacklist-enabled)
  (var-get soft-blacklist-enabled)
)

(define-read-only (get-full-blacklist-enabled)
  (var-get full-blacklist-enabled)
)

(define-read-only (get-blacklister (address principal))
  (get active
    (default-to
      { active: false }
      (map-get? blacklister { address: address })
    )
  )
)

(define-read-only (get-soft-blacklist (address principal))
  (get soft
    (default-to
      { soft: false }
      (map-get? blacklist { address: address })
    )
  )
)

(define-read-only (get-full-blacklist (address principal))
  (get full
    (default-to
      { full: false }
      (map-get? blacklist { address: address })
    )
  )
)

;;-------------------------------------
;; Checks
;;-------------------------------------

(define-read-only (check-is-blacklister (address principal))
  (ok (asserts! (get-blacklister address) ERR_NOT_BLACKLISTER))
)

(define-read-only (check-is-not-soft-blacklist (address principal))
  (ok (if (get-soft-blacklist-enabled)
    (asserts! (not (get-soft-blacklist address)) ERR_SOFT_BLACKLISTED)
    true
  ))
)

(define-read-only (check-is-not-full-blacklist (address principal))
  (ok (if (get-full-blacklist-enabled)
    (asserts! (not (get-full-blacklist address)) ERR_FULLY_BLACKLISTED)
    true
  ))
)

(define-read-only (check-is-not-full-blacklist-two (address1 principal) (address2 principal))
  (ok (if (get-full-blacklist-enabled)
    (asserts! (and (not (get-full-blacklist address1)) (not (get-full-blacklist address2))) ERR_FULLY_BLACKLISTED)
    true
  ))
)

;;-------------------------------------
;; Update
;;-------------------------------------

(define-private (blacklist-processor (entry { address: principal, full: bool }))
  (if (get full entry)
    (begin 
      (print { action: "add-blacklist", user: contract-caller, data: { entry: entry } })
      (map-set blacklist { address: (get address entry) } { soft: true, full: true }) 
    )
    (begin
      (print { action: "add-blacklist", user: contract-caller, data: { entry: entry } })
      (map-set blacklist { address: (get address entry) } { soft: true, full: false })
    )
  )
)

(define-private (blacklist-remover (address principal))
  (begin 
    (print { action: "remove-blacklist", user: contract-caller, data: { address: address } })
    (map-delete blacklist { address: address })
  )
)

(define-public (add-blacklist (entries (list 1000 { address: principal, full: bool })))
  (begin
    (try! (check-is-blacklister contract-caller))
    (ok (map blacklist-processor entries))
  )
)

(define-public (remove-blacklist (entries (list 1000 principal)))
  (begin
    (try! (check-is-blacklister contract-caller))
    (ok (map blacklist-remover entries))
  )
)

;;-------------------------------------
;; Admin
;;-------------------------------------

(define-public (set-blacklister (address principal) (active bool))
  (begin
    (try! (contract-call? .test-hq-vaults-v1-1 check-is-admin contract-caller))
    (print { action: "set-blacklister", user: contract-caller, data: { address: address, active: active } })
    (ok (map-set blacklister { address: address } { active: active }))
  )
)

(define-public (set-soft-blacklist-enabled (active bool))
  (begin
    (try! (contract-call? .test-hq-vaults-v1-1 check-is-owner contract-caller))
    (print { action: "set-soft-blacklist-enabled", user: contract-caller, data: { old-value: (get-soft-blacklist-enabled), new-value: active } })
    (ok (var-set soft-blacklist-enabled active))
  )
)

(define-public (set-full-blacklist-enabled (active bool))
  (begin
    (try! (contract-call? .test-hq-vaults-v1-1 check-is-owner contract-caller))
    (print { action: "set-full-blacklist-enabled", user: contract-caller, data: { old-value: (get-full-blacklist-enabled), new-value: active } })
    (ok (var-set full-blacklist-enabled active))
  )
)