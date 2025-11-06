;; @contract Blacklist
;; @version 0.1

;;-------------------------------------
;; Constants
;;-------------------------------------

(define-constant ERR_NOT_BLACKLISTER (err u108001))
(define-constant ERR_SOFT_BLACKLISTED (err u108002))
(define-constant ERR_FULLY_BLACKLISTED (err u108003))

;;-------------------------------------
;; Variables
;;-------------------------------------

(define-data-var soft-blacklist-active bool true)
(define-data-var full-blacklist-active bool false)

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

(define-read-only (get-soft-blacklist-active)
  (var-get soft-blacklist-active)
)

(define-read-only (get-full-blacklist-active)
  (var-get full-blacklist-active)
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

(define-read-only (check-is-not-soft (address principal))
  (ok (if (get-soft-blacklist-active)
    (asserts! (not (get-soft-blacklist address)) ERR_SOFT_BLACKLISTED)
    true
  ))
)

(define-read-only (check-is-not-full (address principal))
  (ok (if (get-full-blacklist-active)
    (asserts! (not (get-full-blacklist address)) ERR_FULLY_BLACKLISTED)
    true
  ))
)

(define-read-only (check-is-not-full-two (address1 principal) (address2 principal))
  (ok (if (get-full-blacklist-active)
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
    (try! (contract-call? .test-hq-vaults-v3 check-is-owner contract-caller))
    (print { action: "set-blacklister", user: contract-caller, data: { address: address, active: active } })
    (ok (map-set blacklister { address: address } { active: active }))
  )
)

(define-public (set-soft-blacklist-active (active bool))
  (begin
    (try! (contract-call? .test-hq-vaults-v3 check-is-owner contract-caller))
    (print { action: "set-soft-blacklist-active", user: contract-caller, data: { old-value: (get-soft-blacklist-active), new-value: active } })
    (ok (var-set soft-blacklist-active active))
  )
)

(define-public (set-full-blacklist-active (active bool))
  (begin
    (try! (contract-call? .test-hq-vaults-v3 check-is-owner contract-caller))
    (print { action: "set-full-blacklist-active", user: contract-caller, data: { old-value: (get-full-blacklist-active), new-value: active } })
    (ok (var-set full-blacklist-active active))
  )
)