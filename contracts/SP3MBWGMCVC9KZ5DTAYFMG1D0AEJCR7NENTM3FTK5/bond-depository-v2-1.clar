;; @contract Bond Depository
;; @version 2.1

(use-trait ft-trait .sip-010-trait-ft-standard.sip-010-trait)
(use-trait treasury-trait .treasury-trait-v1-1.treasury-trait)
(use-trait staking-distributor-trait .staking-distributor-trait-v1-1.staking-distributor-trait)
(use-trait staking-trait .staking-trait-v1-1.staking-trait)
(use-trait bond-teller-trait .bond-teller-trait-v1-1.bond-teller-trait)
(use-trait value-calculator-trait .value-calculator-trait-v1-1.value-calculator-trait)
(use-trait bond-values-trait .bond-values-trait-v1-1.bond-values-trait)

;; ------------------------------------------
;; Constants
;; ------------------------------------------

(define-constant ERR-NOT-AUTHORIZED u3203001)

(define-constant ERR-WRONG-TREASURY u3202001)
(define-constant ERR-WRONG-TOKEN u3202002)
(define-constant ERR-WRONG-BOND-TELLER u3202003)
(define-constant ERR-WRONG-BOND-VALUES u3202004)

(define-constant ERR-BOND-CONCLUDED u3200001)
(define-constant ERR-BOND-CAPACITY-REACHED u3200002)
(define-constant ERR-BOND-TOO-LARGE u3200003)
(define-constant ERR-SLIPPAGE-TOO-LARGE u3200004)
(define-constant ERR-BOND-NOT-STARTED u3200005)

;; ------------------------------------------
;; Variables
;; ------------------------------------------

(define-data-var active-bond-teller principal .bond-teller-v1-1)
(define-data-var active-treasury principal .treasury-v1-1)

(define-data-var bond-counter uint u4)

;; ------------------------------------------
;; Maps
;; ------------------------------------------

(define-map bond-types
  { bond-id: uint }
  {
    ;; Type
    token-address: principal,     ;; token to accept as payment
    bond-values: principal,       ;; bond-values contract to use
    start-capacity: uint,         ;; start capacity
    capacity: uint,               ;; remaining capacity
    capacity-is-payout: bool,     ;; capacity limit for payout or principal
    start-block: uint,            ;; bond start block

    ;; Terms
    fixed-term: bool,             ;; fixed term or fixed expiration
    vesting-term: uint,           ;; fixed-term - term in blocks
    expiration: uint,             ;; fixed-expiration - block number bond matures
    conclusion: uint,             ;; block number bond no longer offered
    max-payout: uint,             ;; in LDN

    ;; Rate
    maximum-rate: uint,           ;; bp to define max price based on swap price
    minimum-rate: uint,           ;; bp to define min price based on swap price
    last-price: uint,             ;; last saved price
    last-price-block: uint,       ;; block for last saved price
    increase-amount: uint,        ;; increase price per 1 LDN out
    decrease-amount: uint,        ;; decrease price per block
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
  (bond-values <bond-values-trait>) 
  (distributor <staking-distributor-trait>) 
  (treasury <treasury-trait>) 
  (staking <staking-trait>) 
  (token <ft-trait>) 
  (bond-id uint) 
  (amount uint) 
  (max-price uint)
  )
  (let (
    (bonder tx-sender)
    (bond-type (unwrap-panic (map-get? bond-types { bond-id: bond-id })))
    (capacity (get capacity bond-type))

    (payout (unwrap-panic (get-payout-for bond-id amount (contract-of token) bond-values)))
    (bond-price (unwrap-panic (get-bond-price bond-id (contract-of token) bond-values)))
    (expiration (unwrap-panic (get-deposit-expiration bond-id)))
    (new-price (unwrap-panic (get-price-after-deposit bond-id payout (contract-of token) bond-values)))
  )
    (asserts! (is-eq (contract-of bond-teller) (var-get active-bond-teller)) (err ERR-WRONG-BOND-TELLER))
    (asserts! (is-eq (contract-of treasury) (var-get active-treasury)) (err ERR-WRONG-TREASURY))
    (asserts! (is-eq (contract-of token) (get token-address bond-type)) (err ERR-WRONG-TOKEN))
    (asserts! (is-eq (contract-of bond-values) (get bond-values bond-type)) (err ERR-WRONG-BOND-VALUES))

    (asserts! (>= block-height (get start-block bond-type)) (err ERR-BOND-NOT-STARTED))
    (asserts! (< block-height (get conclusion bond-type)) (err ERR-BOND-CONCLUDED))
    (asserts! (<= payout (get max-payout bond-type)) (err ERR-BOND-TOO-LARGE))
    (asserts! (>= max-price bond-price) (err ERR-SLIPPAGE-TOO-LARGE))

    ;; ensure there is remaining capacity for bond
    (if (get capacity-is-payout bond-type)
      (begin
        (asserts! (>= capacity payout) (err ERR-BOND-CAPACITY-REACHED))

        ;; set capacity and increase total debt
        (map-set bond-types { bond-id: bond-id } (merge bond-type { 
          capacity: (- capacity payout), 
          last-price: new-price,
          last-price-block: block-height
        }))
      )
      (begin
        (asserts! (>= capacity amount) (err ERR-BOND-CAPACITY-REACHED))

        ;; set capacity and increase total debt
        (map-set bond-types { bond-id: bond-id } (merge bond-type { 
          capacity: (- capacity amount), 
          last-price: new-price,
          last-price-block: block-height
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


;; ------------------------------------------
;; Bond Price
;; ------------------------------------------

(define-public (get-payout-for (bond-id uint) (amount uint) (token principal) (bond-values <bond-values-trait>))
  (let (
    (price (unwrap-panic (get-bond-price bond-id token bond-values)))
  )
    (ok (/ (* amount u1000000) price))
  )
)

(define-public (get-price-after-deposit (bond-id uint) (amount-out uint) (token principal) (bond-values <bond-values-trait>))
  (let (
    (bond-type (unwrap-panic (map-get? bond-types { bond-id: bond-id })))
    (current-price (unwrap-panic (get-bond-price bond-id token bond-values)))
    (increase (/ (* amount-out (get increase-amount bond-type)) u1000000))
    (new-price (+ current-price increase))
    (maximum-price (get max-price (unwrap-panic (get-min-max-price bond-id token bond-values))))
  )
    (if (> new-price maximum-price)
      (ok maximum-price)
      (ok new-price)
    )
  )
)

(define-public (get-bond-price (bond-id uint) (token principal) (bond-values <bond-values-trait>))
  (let (
    (bond-type (unwrap-panic (map-get? bond-types { bond-id: bond-id })))
    (block-diff (if (< block-height (get last-price-block bond-type))
      u0
      (- block-height (get last-price-block bond-type))
    ))
    (decrease (* block-diff (get decrease-amount bond-type)))
    (new-price (if (> decrease (get last-price bond-type))
      u0
      (- (get last-price bond-type) decrease)
    ))
    (minimum-price (get min-price (unwrap-panic (get-min-max-price bond-id token bond-values))))
  )
    (if (< new-price minimum-price)
      (ok minimum-price)
      (ok new-price)
    )
  )
)

(define-public (get-min-max-price (bond-id uint) (token principal) (bond-values <bond-values-trait>))
  (let (
    (bond-type (unwrap-panic (map-get? bond-types { bond-id: bond-id })))
    (price-value (unwrap-panic (contract-call? bond-values get-valuation token)))
    (minimum-price (/ (* (- u10000 (get minimum-rate bond-type)) price-value) u10000))
    (maximum-price (/ (* (+ u10000 (get maximum-rate bond-type)) price-value) u10000))
  )
    (ok { min-price: minimum-price, max-price: maximum-price })
  )
)


;; ------------------------------------------
;; Payout
;; ------------------------------------------

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


;; ---------------------------------------------------------
;; Admin
;; ---------------------------------------------------------

(define-public (add-bond 
    (token-address principal) 
    (bond-values principal) 
    (capacity uint)
    (capacity-is-payout bool)
    (start-block uint)

    (fixed-term bool)
    (vesting-term uint)
    (expiration uint)
    (conclusion uint)
    (max-payout uint)

    (maximum-rate uint)
    (minimum-rate uint)
    (start-price uint)
    (increase-amount uint)
    (decrease-amount uint)
  )
  (let (
    (bond-id (var-get bond-counter))
  )
    (asserts! (is-eq tx-sender .lydian-dao) (err  ERR-NOT-AUTHORIZED))

    (map-set bond-types 
      { bond-id: bond-id } 
      { 
        ;; Type
        token-address: token-address,
        bond-values: bond-values,
        start-capacity: capacity, 
        capacity: capacity,
        capacity-is-payout: capacity-is-payout,
        start-block: start-block,

        ;; Terms
        fixed-term: fixed-term,
        vesting-term: vesting-term,
        expiration: expiration,
        conclusion: conclusion,
        max-payout: max-payout,

        ;; Rate
        maximum-rate: maximum-rate,
        minimum-rate: minimum-rate,        
        last-price: start-price,
        last-price-block: start-block,
        increase-amount: increase-amount,         
        decrease-amount: decrease-amount,
      }
    )
    (var-set bond-counter (+ bond-id u1))
    (ok bond-id)
  )
)

(define-public (update-bond-type 
    (bond-id uint)

    (token-address principal) 
    (bond-values principal) 
    (start-capacity uint)
    (capacity uint)
    (capacity-is-payout bool)
    (start-block uint)
  )
  (let (
    (bond-type (unwrap-panic (map-get? bond-types { bond-id: bond-id })))
  )
    (asserts! (is-eq tx-sender .lydian-dao) (err  ERR-NOT-AUTHORIZED))

    (map-set bond-types 
      { bond-id: bond-id } 
      ( merge bond-type { 
        token-address: token-address,
        bond-values: bond-values,
        start-capacity: capacity, 
        capacity: capacity,
        capacity-is-payout: capacity-is-payout,
        start-block: start-block,
      })
    )
    (ok bond-id)
  )
)

(define-public (update-bond-terms 
    (bond-id uint)

    (fixed-term bool)
    (vesting-term uint)
    (expiration uint)
    (conclusion uint)
    (max-payout uint)
  )
  (let (
    (bond-type (unwrap-panic (map-get? bond-types { bond-id: bond-id })))
  )
    (asserts! (is-eq tx-sender .lydian-dao) (err  ERR-NOT-AUTHORIZED))

    (map-set bond-types 
      { bond-id: bond-id } 
      ( merge bond-type { 
        fixed-term: fixed-term,
        vesting-term: vesting-term,
        expiration: expiration,
        conclusion: conclusion,
        max-payout: max-payout,
      })
    )
    (ok bond-id)
  )
)

(define-public (update-bond-rate
    (bond-id uint)

    (maximum-rate uint)
    (minimum-rate uint)
    (last-price uint)
    (last-price-block uint)
    (increase-amount uint)
    (decrease-amount uint)
  )
  (let (
    (bond-type (unwrap-panic (map-get? bond-types { bond-id: bond-id })))
  )
    (asserts! (is-eq tx-sender .lydian-dao) (err  ERR-NOT-AUTHORIZED))

    (map-set bond-types 
      { bond-id: bond-id } 
      ( merge bond-type { 
        maximum-rate: maximum-rate,
        minimum-rate: minimum-rate,        
        last-price: last-price,
        last-price-block: last-price-block,
        increase-amount: increase-amount,         
        decrease-amount: decrease-amount,
      })
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
