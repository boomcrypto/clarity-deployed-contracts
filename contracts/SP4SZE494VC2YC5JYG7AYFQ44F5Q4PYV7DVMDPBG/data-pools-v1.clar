;; @contract Data Pools
;; @version 1
;;
;; Save which pools are active, their commission and stacking share.
;; Also set delegates per pool and the delegate share.

;;-------------------------------------
;; Init 
;;-------------------------------------

(begin
  (var-set active-pools (list .stacking-pool-v1))

  ;; Pool commission
  (map-set pool-commission .stacking-pool-v1 u1000)

  ;; Pool share
  (map-set pool-share .stacking-pool-v1 u10000)

  ;; Pool delegates
  (map-set pool-delegates .stacking-pool-v1 (list .stacking-delegate-1-1 .stacking-delegate-1-2 .stacking-delegate-1-3))

  ;; Delegate share
  (map-set delegate-share .stacking-delegate-1-1 u5000)
  (map-set delegate-share .stacking-delegate-1-2 u3000)
  (map-set delegate-share .stacking-delegate-1-3 u2000)

  (map-set delegate-share .stacking-delegate-2-1 u5000)
  (map-set delegate-share .stacking-delegate-2-2 u3000)
  (map-set delegate-share .stacking-delegate-2-3 u2000)
)

;;-------------------------------------
;; Constants 
;;-------------------------------------

(define-constant ERR_POOL_OWNER_SHARE u2011001)
(define-constant ERR_MAX_COMMISSION u2011002)

(define-constant MAX_COMMISSION u4000) ;; 40% in basis points

;;-------------------------------------
;; Commission
;;-------------------------------------

;; If specific pool commission is not set
(define-data-var standard-commission uint u500) ;; 5% in bps

;; Map pool to commission
(define-map pool-commission principal uint)

;; Map pool to info for commision share
(define-map pool-owner-commission 
  principal 
  {
    receiver: principal,
    share: uint, ;; bps
  }
)

(define-read-only (get-standard-commission)
  (var-get standard-commission)
)

(define-read-only (get-pool-commission (pool principal))
  (default-to
    (var-get standard-commission)
    (map-get? pool-commission pool)
  )
)

(define-read-only (get-pool-owner-commission (pool principal))
  (default-to
    {
      receiver: .rewards-v1,
      share: u0
    }
    (map-get? pool-owner-commission pool)
  )
)

(define-public (set-standard-commission (commission uint))
  (begin
    (try! (contract-call? .dao check-is-protocol contract-caller))
    (asserts! (<= commission MAX_COMMISSION) (err ERR_MAX_COMMISSION))

    (var-set standard-commission commission)
    (ok true)
  )
)

(define-public (set-pool-commission (pool principal) (commission uint))
  (begin
    (try! (contract-call? .dao check-is-protocol contract-caller))
    (asserts! (<= commission MAX_COMMISSION) (err ERR_MAX_COMMISSION))

    (map-set pool-commission pool commission)
    (ok true)
  )
)

(define-public (set-pool-owner-commission (pool principal) (receiver principal) (share uint))
  (begin
    (try! (contract-call? .dao check-is-protocol contract-caller))
    (asserts! (<= share u10000) (err ERR_POOL_OWNER_SHARE))

    (map-set pool-owner-commission pool { receiver: receiver, share: share })
    (ok true)
  )
)


;;-------------------------------------
;; Pool and Delegates
;;-------------------------------------

;; List of active pools
(define-data-var active-pools (list 30 principal) (list))

;; Map pool address to share in bps
(define-map pool-share principal uint)

;; Map pool address to delegates
(define-map pool-delegates principal (list 30 principal))

;; Map deleget address to delegate share in bps
(define-map delegate-share principal uint)


(define-read-only (get-active-pools)
  (var-get active-pools)
)

(define-read-only (get-pool-share (pool principal))
  (default-to
    u0
    (map-get? pool-share pool)
  )
)

(define-read-only (get-pool-delegates (pool principal))
  (default-to
    (list)
    (map-get? pool-delegates pool)
  )
)

(define-read-only (get-delegate-share (delegate principal))
  (default-to
    u0
    (map-get? delegate-share delegate)
  )
)

(define-public (set-active-pools (pools (list 30 principal)))
  (begin
    (try! (contract-call? .dao check-is-protocol contract-caller))

    (var-set active-pools pools)
    (ok true)
  )
)

(define-public (set-pool-share (pool principal) (share uint))
  (begin
    (try! (contract-call? .dao check-is-protocol contract-caller))

    (map-set pool-share pool share)
    (ok true)
  )
)

(define-public (set-pool-delegates (pool principal) (delegates (list 30 principal)))
  (begin
    (try! (contract-call? .dao check-is-protocol contract-caller))

    (map-set pool-delegates pool delegates)
    (ok true)
  )
)

(define-public (set-delegate-share (delegate principal) (share uint))
  (begin
    (try! (contract-call? .dao check-is-protocol contract-caller))

    (map-set delegate-share delegate share)
    (ok true)
  )
)
