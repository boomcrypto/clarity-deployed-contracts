;; @contract Data stSTXbtc Tracking
;; @version 2
;;
;; Data contract for stSTXbtc tracking

;;-------------------------------------
;; Variables
;;-------------------------------------

(define-data-var total-supply uint u0)
(define-data-var next-holder-index uint u0) 
(define-data-var cumm-reward uint u0)

;;-------------------------------------
;; Maps
;;-------------------------------------

(define-map supported-positions 
  principal 
  {
    active: bool,
    total: uint,
    reserve: principal,
    deactivated-cumm-reward: uint
  }
)

(define-map holders-index-to-address uint principal)
(define-map holders-address-to-index principal uint)

(define-map holder-position
  { 
    holder: principal,
    position: principal
  }
  {
    amount: uint,
    cumm-reward: uint
  }
)

;;-------------------------------------
;; Getters
;;-------------------------------------

(define-read-only (get-total-supply)
  (var-get total-supply)
)

(define-read-only (get-next-holder-index)
  (var-get next-holder-index)
)

(define-read-only (get-cumm-reward)
  (var-get cumm-reward)
)

(define-read-only (get-supported-positions (position principal))
  (default-to 
    {
      active: false,
      total: u0,
      reserve: .ststxbtc-tracking-data-v2,
      deactivated-cumm-reward: u0
    }
    (map-get? supported-positions position)
  )
)

(define-read-only (get-holders-index-to-address (index uint))
  (map-get? holders-index-to-address index)
)

(define-read-only (get-holders-address-to-index (holder principal))
  (map-get? holders-address-to-index holder)
)

(define-read-only (get-holder-position (holder principal) (position principal))
  (default-to 
    {
      amount: u0,
      cumm-reward: u0
    }  
    (map-get? holder-position { holder: holder, position: position })
  )
)

;;-------------------------------------
;; Setters
;;-------------------------------------

(define-public (set-total-supply (supply uint))
  (begin
    (try! (contract-call? .dao check-is-protocol contract-caller))

    (var-set total-supply supply)
    (ok true)
  )
)

(define-public (set-next-holder-index (index uint))
  (begin
    (try! (contract-call? .dao check-is-protocol contract-caller))

    (var-set next-holder-index index)
    (ok true)
  )
)

(define-public (set-cumm-reward (cumm uint))
  (begin
    (try! (contract-call? .dao check-is-protocol contract-caller))

    (var-set cumm-reward cumm)
    (ok true)
  )
)

(define-public (set-supported-positions (position principal) (active bool) (reserve principal) (total uint) (deactivated-cumm-reward uint))
  (begin
    (try! (contract-call? .dao check-is-protocol contract-caller))

    (map-set supported-positions position { active: active, reserve: reserve, total: total, deactivated-cumm-reward: deactivated-cumm-reward })

    (ok true)
  )
)

(define-public (set-holders-index-to-address (index uint) (holder principal))
  (begin
    (try! (contract-call? .dao check-is-protocol contract-caller))

    (map-set holders-index-to-address index holder)

    (ok true)
  )
)

(define-public (set-holders-address-to-index (holder principal) (index uint))
  (begin
    (try! (contract-call? .dao check-is-protocol contract-caller))

    (map-set holders-address-to-index holder index)

    (ok true)
  )
)

(define-public (set-holder-position (holder principal) (position principal) (amount uint) (cumm uint))
  (begin
    (try! (contract-call? .dao check-is-protocol contract-caller))

    (map-set holder-position { holder: holder, position: position } { amount: amount, cumm-reward: cumm })

    (ok true)
  )
)

;;-------------------------------------
;; Helpers
;;-------------------------------------

(define-public (add-holder (holder principal)) 
  (let (
    (index (get-holders-address-to-index holder))
  )
    (try! (contract-call? .dao check-is-protocol contract-caller))

    (if (is-none index)
      (let (
        (next-index (get-next-holder-index))
      )
        (map-set holders-index-to-address next-index holder)
        (map-set holders-address-to-index holder next-index)
        (var-set next-holder-index (+ next-index u1))
      )
      true
    )
    (ok true)
  )
)

(define-public (update-holder-position (holder principal) (position principal))
  (begin
    (try! (contract-call? .dao check-is-protocol contract-caller))

    (try! (add-holder holder))

    (map-set holder-position { holder: holder, position: position } (merge 
      (get-holder-position holder position)
      { cumm-reward: (get-cumm-reward) }
    ))
    (ok true)
  )
)

(define-public (update-holder-position-amount (holder principal) (position principal) (amount uint))
  (begin
    (try! (contract-call? .dao check-is-protocol contract-caller))

    (try! (add-holder holder))

    (map-set holder-position 
      { holder: holder, position: position } 
      { amount: amount, cumm-reward: (get-cumm-reward) }
    )

    (ok true)
  )
)

(define-public (update-supported-positions-total (position principal) (total uint))
  (begin
    (try! (contract-call? .dao check-is-protocol contract-caller))

    (map-set supported-positions position (merge 
      (get-supported-positions position)
      { total: total }
    ))

    (ok true)
  )
)
