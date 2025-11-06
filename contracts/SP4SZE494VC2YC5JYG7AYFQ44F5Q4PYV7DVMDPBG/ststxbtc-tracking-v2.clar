;; @contract stSTXbtc Tracking
;; @version 1
;;
;; sBTC rewards are distributed to holders of stSTXbtc tokens.
;; This contract tracks the positions of holders.
;; Wallet positions are tracked automatically.
;; Positions in other protocols need to be tracked through `refresh-position`.

(use-trait position-trait .position-trait-v1.position-trait)

;;-------------------------------------
;; Constants
;;-------------------------------------

(define-constant ERR_UNSUPPORTED_POSITION u10002001)
(define-constant ERR_CLAIMS_DISABLED u10002002)
(define-constant ERR_OVER_RESERVE u10002003)
(define-constant ERR_POSITION_SAME_STATE u10002004)
(define-constant ERR_POSITION_USED u10002005)

;;-------------------------------------
;; Variables
;;-------------------------------------

(define-data-var claims-enabled bool true)
(define-map saved-rewards { holder: principal, position: principal } uint)

;;-------------------------------------
;; Getters
;;-------------------------------------

(define-read-only (get-claims-enabled)
  (var-get claims-enabled)
)

(define-read-only (get-saved-rewards (holder principal) (position principal))
  (default-to u0 (map-get? saved-rewards { holder: holder, position: position }))
)

;;-------------------------------------
;; Tracking
;;-------------------------------------

(define-public (refresh-wallet (holder principal) (balance uint)) 
  (begin
    (try! (contract-call? .dao check-is-protocol contract-caller))
    
    (try! (save-pending-rewards holder holder))
    (try! (contract-call? .ststxbtc-tracking-data-v2 update-holder-position-amount holder holder balance))

    (ok balance)
  )
)

(define-public (refresh-position (holder principal) (position <position-trait>)) 
  (let (
    (position-address (contract-of position))
    (supported-position (contract-call? .ststxbtc-tracking-data-v2 get-supported-positions position-address))

    (supported-position-reserve (get amount (contract-call? .ststxbtc-tracking-data-v2 get-holder-position (get reserve supported-position) (get reserve supported-position))))

    (new-position-balance (try! (contract-call? position get-holder-balance holder)))
    (prev-position-balance (get amount (contract-call? .ststxbtc-tracking-data-v2 get-holder-position holder position-address)))

    (supported-position-new-total (- (+ (get total supported-position) new-position-balance) prev-position-balance))
  )
    (asserts! (get active supported-position) (err ERR_UNSUPPORTED_POSITION))
    (asserts! (not (and (> new-position-balance prev-position-balance) (> supported-position-new-total supported-position-reserve))) (err ERR_OVER_RESERVE))

    (try! (save-pending-rewards holder position-address))
    (try! (contract-call? .ststxbtc-tracking-data-v2 update-holder-position-amount holder position-address new-position-balance))
    (try! (contract-call? .ststxbtc-tracking-data-v2 update-supported-positions-total position-address supported-position-new-total))

    (ok new-position-balance)
  )
)

;;-------------------------------------
;; Rewards
;;-------------------------------------

(define-public (save-pending-rewards (holder principal) (position principal))
  (let (
    (pending-rewards (unwrap-panic (get-pending-rewards holder position)))
    (existing-rewards (get-saved-rewards holder position))
  )
    (if (> (- pending-rewards existing-rewards) u0)
      (begin
        (map-set saved-rewards { holder: holder, position: position } pending-rewards)
        ;; To set current cumm-reward
        (try! (contract-call? .ststxbtc-tracking-data-v2 update-holder-position holder position))
        (ok pending-rewards)
      )
      (ok u0)
    )
  )
)

(define-public (add-rewards (amount uint))
  (let (
    (reward-added-per-token (/ (* amount u10000000000) (contract-call? .ststxbtc-tracking-data-v2 get-total-supply)))
    (new-cumm-reward (+ (contract-call? .ststxbtc-tracking-data-v2 get-cumm-reward) reward-added-per-token))
  )
    (try! (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token transfer amount contract-caller (as-contract tx-sender) none))
    
    (try! (contract-call? .ststxbtc-tracking-data-v2 set-cumm-reward new-cumm-reward))

    (ok true)
  )
)

(define-read-only (get-pending-rewards-many (holders (list 200 (tuple (holder principal) (position principal)))))
  (map get-pending-rewards-iter holders)
)

(define-read-only (get-pending-rewards-iter (holder (tuple (holder principal) (position principal))))
  (get-pending-rewards (get holder holder) (get position holder))
)

(define-read-only (get-pending-rewards (holder principal) (position principal))
  (let (
    (holders-info (contract-call? .ststxbtc-tracking-data-v2 get-holder-position holder position))

    (supported-position (contract-call? .ststxbtc-tracking-data-v2 get-supported-positions position))
    (cumm-reward (if 
      (and 
        (not (is-eq holder position)) 
        (not (is-eq (get deactivated-cumm-reward supported-position) u0))
      )
        (get deactivated-cumm-reward supported-position)
        (contract-call? .ststxbtc-tracking-data-v2 get-cumm-reward)
    ))

    (amount-owed-per-token (- cumm-reward (get cumm-reward holders-info)))
    (rewards (/ (* (get amount holders-info) amount-owed-per-token) u10000000000))
    (rewards-saved (get-saved-rewards holder position))

    (is-holder-position (get active (contract-call? .ststxbtc-tracking-data-v2 get-supported-positions holder)))
  )
    (if is-holder-position
      (ok u0)
      (ok (+ rewards rewards-saved))
    )
  )
)

(define-public (claim-pending-rewards-many (holders (list 200 (tuple (holder principal) (position principal)))))
  (ok (map claim-pending-rewards-iter holders))
)

(define-public (claim-pending-rewards-iter (holder (tuple (holder principal) (position principal))))
  (claim-pending-rewards (get holder holder) (get position holder))
)

(define-public (claim-pending-rewards (holder principal) (position principal))
  (let (
    (pending-rewards (unwrap-panic (get-pending-rewards holder position)))
  )
    (asserts! (var-get claims-enabled) (err ERR_CLAIMS_DISABLED))

    (if (>= pending-rewards u1)
      (begin
        (try! (as-contract (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token transfer pending-rewards tx-sender holder none)))
        (map-delete saved-rewards { holder: holder, position: position })
        (try! (contract-call? .ststxbtc-tracking-data-v2 update-holder-position holder position))

        (ok pending-rewards)
      )
      (ok u0)
    )
  )
)

;;-------------------------------------
;; Admin
;;-------------------------------------

(define-public (withdraw-tokens (recipient principal) (amount uint))
  (begin
    (try! (contract-call? .dao check-is-protocol contract-caller))

    (try! (as-contract (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token transfer amount tx-sender recipient none)))

    (ok true)
  )
)

(define-public (set-claims-enabled (enabled bool))
  (begin
    (try! (contract-call? .dao check-is-protocol contract-caller))

    (var-set claims-enabled enabled)

    (ok true)
  )
)

(define-public (set-supported-positions (position <position-trait>) (active bool) (reserve principal))
  (let (
    (position-address (contract-of position))
    (supported-position (contract-call? .ststxbtc-tracking-data-v2 get-supported-positions position-address))
  )
    (try! (contract-call? .dao check-is-protocol contract-caller))

    (asserts! (not (is-eq active (get active supported-position))) (err ERR_POSITION_SAME_STATE))

    (if active
      (begin
        ;; Can not activate position if it was already active previously
        (asserts! (is-eq (get total supported-position) u0) (err ERR_POSITION_USED))

        (try! (claim-pending-rewards position-address position-address))
        (contract-call? .ststxbtc-tracking-data-v2 set-supported-positions position-address active reserve u0 u0)
      )
      (begin
        (try! (contract-call? .ststxbtc-tracking-data-v2 update-holder-position position-address position-address))
        (contract-call? .ststxbtc-tracking-data-v2 set-supported-positions position-address active (get reserve supported-position) (get total supported-position) (contract-call? .ststxbtc-tracking-data-v2 get-cumm-reward))
      )
    )
  )
)