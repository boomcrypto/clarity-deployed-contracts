;; @contract Bond Teller
;; @version 1

(impl-trait .bond-teller-trait-v1-1.bond-teller-trait)

(use-trait staking-distributor-trait .staking-distributor-trait-v1-1.staking-distributor-trait)
(use-trait treasury-trait .treasury-trait-v1-1.treasury-trait)
(use-trait staking-trait .staking-trait-v1-1.staking-trait)

;; ------------------------------------------
;; Constants
;; ------------------------------------------

(define-constant ERR-NOT-AUTHORIZED u3303001)

(define-constant ERR-CONTRACT-DISABLED u3301001)

(define-constant ERR-WRONG-TREASURY u3302001)
(define-constant ERR-WRONG-STAKING u3302002)
(define-constant ERR-WRONG-BOND-DEPOSITORY u3302003)

;; ------------------------------------------
;; Variables
;; ------------------------------------------

(define-data-var active-treasury principal .treasury-v1-1)
(define-data-var active-staking principal .staking-v1-1)
(define-data-var active-bond-depository principal .bond-depository-v1-1)

(define-data-var contract-is-enabled bool true)

(define-data-var last-bond-id uint u0)

;; ------------------------------------------
;; Maps
;; ------------------------------------------

(define-map user-bonds 
  { 
    bonder: principal,
    bond-type: uint 
  } 
  { 
    ids: (list 1000 uint) 
  }
)

(define-map bond-info
  { id: uint }
  {
    principal: principal,
    principal-paid: uint,
    payout-fragments: uint,
    vested: uint
  }
)

(define-map removing-bond
  { bonder: principal }
  { bond-ids: (list 1000 uint) }
)

;; ------------------------------------------
;; Var & Map Helpers
;; ------------------------------------------

(define-read-only (get-contract-is-enabled)
  (var-get contract-is-enabled)
)

(define-read-only (get-active-treasury)
  (var-get active-treasury)
)

(define-read-only (get-active-staking)
  (var-get active-staking)
)

(define-read-only (get-active-bond-depository)
  (var-get active-bond-depository)
)

(define-read-only (get-user-bonds (bonder principal) (bond-type uint))
  (unwrap! (map-get? user-bonds { bonder: bonder, bond-type: bond-type }) (tuple (ids (list ) )))
)

(define-read-only (get-bond-info (id uint))
  (default-to
    {
      principal: .lydian-token,
      principal-paid: u0,
      payout-fragments: u0,
      vested: u0,
    }
    (map-get? bond-info { id: id })
  )
)

;; ---------------------------------------------------------
;; Add bond
;; ---------------------------------------------------------

(define-public (new-bond (distributor <staking-distributor-trait>) (treasury <treasury-trait>) (staking <staking-trait>) (bond-type uint) (bonder principal) (principal principal) (principal-paid uint) (payout uint) (expires uint))
  (let (
    (new-bond-id (+ (var-get last-bond-id) u1))
    (current-user-bonds (get ids (get-user-bonds bonder bond-type)))

    (fragments-per-token (contract-call? .staked-lydian-token get-fragments-per-token))
    (fragments-for-payout (* fragments-per-token payout))
  ) 
    (asserts! (var-get contract-is-enabled) (err ERR-CONTRACT-DISABLED))
    (asserts! (is-eq contract-caller (var-get active-bond-depository)) (err ERR-WRONG-BOND-DEPOSITORY))

    ;; Check treasury and staking
    ;; Distributor checked in staking
    (asserts! (is-eq (contract-of treasury) (var-get active-treasury)) (err ERR-WRONG-TREASURY))
    (asserts! (is-eq (contract-of staking) (var-get active-staking)) (err ERR-WRONG-STAKING))

    ;; Mint and stake
    (try! (as-contract (contract-call? treasury mint (as-contract tx-sender) payout)))
    (try! (as-contract (contract-call? staking stake distributor treasury payout)))

    ;; Update bond-info
    (map-set bond-info { id: new-bond-id } 
      {
        principal: principal,
        principal-paid: principal-paid,
        payout-fragments: fragments-for-payout,
        vested: expires 
      }
    )

    ;; Update user-bonds
    (map-set user-bonds { bonder: bonder, bond-type: bond-type } { ids: (unwrap-panic (as-max-len? (append current-user-bonds new-bond-id) u1000)) })

    ;; Increase last bond id
    (var-set last-bond-id new-bond-id)

    (ok payout)
  )
)

;; ---------------------------------------------------------
;; Redeem
;; ---------------------------------------------------------

(define-read-only (get-pending (bond-id uint))
  (let (    
    (current-bond-info (get-bond-info bond-id))

    (fragments-per-token (contract-call? .staked-lydian-token get-fragments-per-token))
    (amount (/ (get payout-fragments current-bond-info) fragments-per-token))
  )
    (if (<= (get vested current-bond-info) block-height)
      u0
      amount
    )
  )
)

(define-read-only (get-all-pending (bonder principal) (bond-type uint))
  (let (
    (bond-ids (get ids (get-user-bonds bonder bond-type)))
    (pending-list (map get-pending bond-ids))
    (sum-all (fold + pending-list u0))
  )
    sum-all
  )
)

(define-read-only (get-claimable (bond-id uint))
  (let (    
    (current-bond-info (get-bond-info bond-id))

    (fragments-per-token (contract-call? .staked-lydian-token get-fragments-per-token))
    (amount (/ (get payout-fragments current-bond-info) fragments-per-token))
  )
    (if (<= (get vested current-bond-info) block-height)
      amount
      u0
    )
  )
)

(define-read-only (get-all-claimable (bonder principal) (bond-type uint))
  (let (
    (bond-ids (get ids (get-user-bonds bonder bond-type)))
    (pending-list (map get-claimable bond-ids))
    (sum-all (fold + pending-list u0))
  )
    sum-all
  )
)

(define-public (redeem (bond-type uint) (bond-id uint))
  (let (
    (bonder tx-sender)
    (amount-claimable (get-claimable bond-id))
    (current-user-bonds (get ids (get-user-bonds bonder bond-type)))
    (user-bond-index (index-of current-user-bonds bond-id))
  )
    (asserts! (var-get contract-is-enabled) (err ERR-CONTRACT-DISABLED))
    (asserts! (not (is-eq user-bond-index none)) (err ERR-NOT-AUTHORIZED))

    (if (is-eq amount-claimable u0)
      (ok u0)
      (begin
        ;; Tranfer to user
        (try! (as-contract (contract-call? .staked-lydian-token transfer amount-claimable (as-contract tx-sender) bonder none)))

        ;; Remove bond from user list
        (map-set removing-bond { bonder: bonder } { bond-ids: (list bond-id) })
        (map-set user-bonds { bonder: bonder, bond-type: bond-type } { ids: (filter remove-user-redeemed-bond current-user-bonds) })

        ;; Remove bond-info
        (map-delete bond-info { id: bond-id })

        (ok amount-claimable)
      )
    )
  )
)

(define-public (redeem-all (bond-type uint))
  (let (
    (bonder tx-sender)
    (current-user-bonds (get ids (get-user-bonds bonder bond-type)))
    (amount-claimable (get-all-claimable bonder bond-type))
  )
    (asserts! (var-get contract-is-enabled) (err ERR-CONTRACT-DISABLED))
    
    (if (is-eq amount-claimable u0)
      (ok u0)
      (begin
        ;; Tranfer to user
        (try! (as-contract (contract-call? .staked-lydian-token transfer amount-claimable (as-contract tx-sender) bonder none)))

        ;; Remove all bonds from user list
        (map-set removing-bond { bonder: bonder } { bond-ids: current-user-bonds })
        (map-set user-bonds { bonder: bonder, bond-type: bond-type } { ids: (filter remove-user-redeemed-bond current-user-bonds) })

        ;; Remove all user bonds
        (map remove-redeemed-bond current-user-bonds)

        (ok amount-claimable)
      )
    )
  )
)

(define-private (remove-redeemed-bond (bond-id uint))
  (map-delete bond-info { id: bond-id })
)

(define-private (remove-user-redeemed-bond (bond-id uint))
  (let (
    (ids-to-remove (get bond-ids (unwrap-panic (map-get? removing-bond { bonder: tx-sender }))))
    (bond-index (index-of ids-to-remove bond-id))  
  )
    (if (is-eq bond-index none)
      true
      false
    )
  )
)

;; ---------------------------------------------------------
;; Admin
;; ---------------------------------------------------------

(define-public (set-active-bond-depository (depository principal))
  (begin
    (asserts! (is-eq tx-sender .lydian-dao) (err ERR-NOT-AUTHORIZED))

    (var-set active-bond-depository depository)
    (ok true)
  )
)

(define-public (set-active-staking (staking principal))
  (begin
    (asserts! (is-eq tx-sender .lydian-dao) (err ERR-NOT-AUTHORIZED))

    (var-set active-staking staking)
    (ok true)
  )
)

(define-public (set-active-treasury (treasury principal))
  (begin
    (asserts! (is-eq tx-sender .lydian-dao) (err ERR-NOT-AUTHORIZED))

    (var-set active-treasury treasury)
    (ok true)
  )
)

(define-public (set-contract-is-enabled (enabled bool))
  (begin
    (asserts! (is-eq tx-sender .lydian-dao) (err ERR-NOT-AUTHORIZED))
    (var-set contract-is-enabled enabled)
    (ok true)
  )
)

(define-public (migrate-funds (recipient principal))
  (let (
    (sldn-balance (unwrap-panic (contract-call? .staked-lydian-token get-balance (as-contract tx-sender))))
  )
    (asserts! (is-eq tx-sender .lydian-dao) (err ERR-NOT-AUTHORIZED))
    
    ;; Transfer sLDN
    (if (> sldn-balance u0)
      (try! (as-contract (contract-call? .staked-lydian-token transfer sldn-balance (as-contract tx-sender) recipient none)))
      true
    )

    (ok true)
  )
)
