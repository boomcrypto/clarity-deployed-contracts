;; @contract Bond Depository
;; @version 1.1

(use-trait ft-trait .sip-010-trait-ft-standard.sip-010-trait)
(use-trait treasury-trait .treasury-trait-v1-1.treasury-trait)
(use-trait staking-distributor-trait .staking-distributor-trait-v1-1.staking-distributor-trait)
(use-trait staking-trait .staking-trait-v1-1.staking-trait)
(use-trait bond-teller-trait .bond-teller-trait-v1-1.bond-teller-trait)
(use-trait value-calculator-trait .value-calculator-trait-v1-1.value-calculator-trait)

;; ------------------------------------------
;; Constants
;; ------------------------------------------

(define-constant ERR-NOT-AUTHORIZED u3203001)

(define-constant ERR-WRONG-TREASURY u3202001)
(define-constant ERR-WRONG-TOKEN u3202002)
(define-constant ERR-WRONG-BOND-TELLER u3202003)
(define-constant ERR-WRONG-VALUE-CALCULATOR u3202004)

(define-constant ERR-BOND-CONCLUDED u3200001)
(define-constant ERR-BOND-CAPACITY-REACHED u3200002)
(define-constant ERR-BOND-TOO-LARGE u3200003)
(define-constant ERR-SLIPPAGE-TOO-LARGE u3200004)

;; ------------------------------------------
;; Variables
;; ------------------------------------------

(define-data-var active-bond-teller principal .bond-teller-v1-1)
(define-data-var active-treasury principal .treasury-v1-1)

(define-data-var bond-counter uint u0)

;; ------------------------------------------
;; Maps
;; ------------------------------------------

(define-map bond-types
  { bond-id: uint }
  {
    ;; Type
    token-address: principal,     ;; token to accept as payment
    start-capacity: uint,         ;; start capacity
    capacity: uint,               ;; remaining capacity
    capacity-is-payout: bool,     ;; capacity limit for payout or principal
    total-debt: uint,             ;; total debt from bond
    last-decay: uint,             ;; last block when debt was decayed

    ;; Terms
    control-variable: uint,       ;; scaling variable for price
    fixed-term: bool,             ;; fixed term or fixed expiration
    vesting-term: uint,           ;; fixed-term - term in blocks
    expiration: uint,             ;; fixed-expiration - block number bond matures
    conclusion: uint,             ;; block number bond no longer offered
    minimum-price: uint,          ;; vs principal value
    max-payout: uint,             ;; in thousandths of a %. i.e. 500 = 0.5%
    max-debt: uint                ;; 9 decimal debt ratio, max % total supply created as debt
  }
)

(define-read-only (get-bond-type (bond-id uint))
  (map-get? bond-types { bond-id: bond-id })
)

;; ------------------------------------------
;; Var & Map Helpers
;; ------------------------------------------

(define-read-only (get-active-bond-teller)
  (var-get active-bond-teller)
)

(define-read-only (get-active-treasury)
  (var-get active-treasury)
)

(define-read-only (get-bond-counter)
  (var-get bond-counter)
)

;; ------------------------------------------
;; Deposit
;; ------------------------------------------

(define-public (deposit 
  (bond-teller <bond-teller-trait>) 
  (value-calculator <value-calculator-trait>) 
  (distributor <staking-distributor-trait>) 
  (treasury <treasury-trait>) 
  (staking <staking-trait>) 
  (token <ft-trait>) 
  (bond-id uint) 
  (amount uint) 
  (max-price uint)
  )
  (let (
    ;; lower debt first
    (decay-result (decay-debt bond-id))

    (bonder tx-sender)
    (bond-type (unwrap-panic (map-get? bond-types { bond-id: bond-id })))
    (capacity (get capacity bond-type))

    (token-value (unwrap-panic (contract-call? treasury get-token-value token value-calculator amount)))
    (payout (unwrap-panic (get-payout-for token-value bond-id)))
    (max-payout (unwrap-panic (get-max-payout bond-id)))
    (bond-price (unwrap-panic (get-bond-price bond-id)))
    (expiration (unwrap-panic (get-deposit-expiration bond-id)))
  )
    (asserts! (is-eq (contract-of bond-teller) (var-get active-bond-teller)) (err ERR-WRONG-BOND-TELLER))
    (asserts! (is-eq (contract-of treasury) (var-get active-treasury)) (err ERR-WRONG-TREASURY))
    (asserts! (is-eq (contract-of token) (get token-address bond-type)) (err ERR-WRONG-TOKEN))
    (asserts! (not (is-eq token-value u0)) (err ERR-WRONG-VALUE-CALCULATOR))

    (asserts! (< block-height (get conclusion bond-type)) (err ERR-BOND-CONCLUDED))
    (asserts! (<= payout max-payout) (err ERR-BOND-TOO-LARGE))
    (asserts! (>= max-price bond-price) (err ERR-SLIPPAGE-TOO-LARGE))

    ;; ensure there is remaining capacity for bond
    (if (get capacity-is-payout bond-type)
      (begin
        (asserts! (>= capacity payout) (err ERR-BOND-CAPACITY-REACHED))

        ;; set capacity and increase total debt
        (map-set bond-types { bond-id: bond-id } (merge bond-type { 
          capacity: (- capacity payout), 
          total-debt: (+ (get total-debt bond-type) token-value) 
        }))
      )
      (begin
        (asserts! (>= capacity amount) (err ERR-BOND-CAPACITY-REACHED))

        ;; set capacity and increase total debt
        (map-set bond-types { bond-id: bond-id } (merge bond-type { 
          capacity: (- capacity amount), 
          total-debt: (+ (get total-debt bond-type) token-value) 
        }))
      )
    )

    ;; send deposit to treasury
    (try! (contract-call? token transfer amount tx-sender (contract-of treasury) none))

    ;; user info stored with teller 
    (try! (as-contract (contract-call? bond-teller new-bond distributor treasury staking bond-id bonder (contract-of token) amount payout expiration)))

    ;; audit treasury reserve token
    (try! (contract-call? treasury audit-reserve-token token value-calculator))

    (ok payout)
  )
)

(define-read-only (get-deposit-expiration (bond-id uint))
  (let (
    (bond-type (unwrap-panic (map-get? bond-types { bond-id: bond-id })))
    (bond-fixed-term (get fixed-term bond-type))
  )
    (if (is-eq bond-fixed-term true)
      (ok (get expiration bond-type))
      (ok (+ (get vesting-term bond-type) block-height))
    )
  )
)

(define-private (decay-debt (bond-id uint))
  (let (
    (bond-type (unwrap-panic (map-get? bond-types { bond-id: bond-id })))
    (debt-decay (unwrap-panic (get-debt-decay bond-id)))
    (new-total-debt (- (get total-debt bond-type) debt-decay))
  )
    (map-set bond-types { bond-id: bond-id} (merge bond-type { total-debt: new-total-debt, last-decay: block-height }))
  )
)

;; ------------------------------------------
;; Payout
;; ------------------------------------------

;; determine maximum bond size
(define-read-only (get-max-payout (bond-id uint))
  (let (
    (total-supply (unwrap-panic (contract-call? .lydian-token get-total-supply)))
    (bond-type (unwrap-panic (map-get? bond-types { bond-id: bond-id })))
  )
    (ok (/ (* total-supply (get max-payout bond-type)) u100000))
  )
)

;; payout due for amount of treasury value
(define-read-only (get-payout-for (token-value uint) (bond-id uint))
  (let (
    (bond-price (unwrap-panic (get-bond-price bond-id)))
  )
    (ok (/ (/ (* token-value u100000000) bond-price) u1000000))
  )
)

;; ------------------------------------------
;; Bond price
;; ------------------------------------------

;; calculate current bond premium
(define-read-only (get-bond-price (bond-id uint))
  (let (
    (bond-type (unwrap-panic (map-get? bond-types { bond-id: bond-id })))
    (minimum-price (get minimum-price bond-type))
    (control-variable (get control-variable bond-type))
    (debt-ratio (unwrap-panic (get-debt-ratio bond-id)))
    (price (/ (+ (* control-variable debt-ratio) u1000000) u10000))
  )
    (if (< price minimum-price)
      (ok minimum-price)
      (ok price)
    )
  )
)

;; ------------------------------------------
;; Debt
;; ------------------------------------------

;; calculate current ratio of debt to LDN supply
(define-read-only (get-debt-ratio (bond-id uint))
  (let (
    (total-supply (unwrap-panic (contract-call? .lydian-token get-total-supply)))
    (current-debt (unwrap-panic (get-current-debt bond-id)))
  )
    (if (is-eq total-supply u0)
      (ok u0)
      (ok (/ (* current-debt u1000000) total-supply))
    )
  )
)

;; calculate debt factoring in decay
(define-read-only (get-current-debt (bond-id uint))
  (let (
    (bond-type (unwrap-panic (map-get? bond-types { bond-id: bond-id })))
    (total-debt (get total-debt bond-type))
    (debt-decay (unwrap-panic (get-debt-decay bond-id)))
  )
    (ok (- total-debt debt-decay))
  )
)

;; amount to decay total debt by
(define-read-only (get-debt-decay (bond-id uint))
  (let (
    (bond-type (unwrap-panic (map-get? bond-types { bond-id: bond-id })))
    (total-debt (get total-debt bond-type))
    (last-decay (get last-decay bond-type))
    (vesting-term (get vesting-term bond-type))
    (blocks-since-last (- block-height last-decay))
    (decay (/ (* total-debt blocks-since-last) vesting-term))
  )
    (if (> decay total-debt)
      (ok total-debt)
      (ok decay)
    )
  )
)

;; ---------------------------------------------------------
;; Admin
;; ---------------------------------------------------------

(define-public (add-bond 
    (token-address principal) 
    (capacity uint)
    (capacity-is-payout bool)

    (control-variable uint)
    (fixed-term bool)
    (vesting-term uint)
    (expiration uint)
    (conclusion uint)
    (minimum-price uint)
    (max-payout uint)
    (max-debt uint)
  )
  (let (
    (bond-id (var-get bond-counter))
  )
    (asserts! (is-eq tx-sender .lydian-dao) (err  ERR-NOT-AUTHORIZED))

    (map-set bond-types 
      { bond-id: bond-id } 
      { 
        token-address: token-address,
        start-capacity: capacity, 
        capacity: capacity,
        capacity-is-payout: capacity-is-payout,
        total-debt: u0,
        last-decay: block-height,

        control-variable: control-variable,
        fixed-term: fixed-term,
        vesting-term: vesting-term,
        expiration: expiration,
        conclusion: conclusion,
        minimum-price: minimum-price,
        max-payout: max-payout,
        max-debt: max-debt
      }
    )
    (var-set bond-counter (+ bond-id u1))
    (ok bond-id)
  )
)

(define-public (update-bond 
    (bond-id uint)
    (token-address principal) 
    (capacity uint)
    (capacity-is-payout bool)
    (total-debt uint)
    (last-decay uint)

    (control-variable uint)
    (fixed-term bool)
    (vesting-term uint)
    (expiration uint)
    (conclusion uint)
    (minimum-price uint)
    (max-payout uint)
    (max-debt uint)
  )
  (begin
    (asserts! (is-eq tx-sender .lydian-dao) (err  ERR-NOT-AUTHORIZED))

    (map-set bond-types 
      { bond-id: bond-id } 
      { 
        token-address: token-address, 
        start-capacity: capacity,
        capacity: capacity,
        capacity-is-payout: capacity-is-payout,
        total-debt: total-debt,
        last-decay: last-decay,

        control-variable: control-variable,
        fixed-term: fixed-term,
        vesting-term: vesting-term,
        expiration: expiration,
        conclusion: conclusion,
        minimum-price: minimum-price,
        max-payout: max-payout,
        max-debt: max-debt
      }
    )
    (ok bond-id)
  )
)

(define-public (set-active-bond-teller (bond-teller principal))
  (begin
    (asserts! (is-eq tx-sender .lydian-dao) (err  ERR-NOT-AUTHORIZED))

    (var-set active-bond-teller bond-teller)
    (ok true)
  )
)

(define-public (set-active-treasury (treasury principal))
  (begin
    (asserts! (is-eq tx-sender .lydian-dao) (err  ERR-NOT-AUTHORIZED))

    (var-set active-treasury treasury)
    (ok true)
  )
)
