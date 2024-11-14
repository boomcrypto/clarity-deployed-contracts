(define-constant ERR-NOT-AUTHORIZED (err u2))
(define-constant ERR-MARKET-RESOLVED (err u102))
(define-constant ERR-MARKET-NOT-FOUND (err u101))
(define-constant ERR-MARKET-NOT-RESOLVED (err u103))
(define-constant ERR-NO-OUTCOME (err u104))
(define-constant ERR-INVALID-AMOUNT (err u105))
(define-constant ERR-TRANSFER-FAILED (err u150))
(define-constant ERR-INSUFFICIENT-BALANCE (err u107))
(define-constant ERR-ARITHMETIC-OVERFLOW (err u108))
(define-constant ERR-NO-POSITION (err u109))
(define-constant ERR-NO-WINNINGS (err u110))
(define-constant ERR-INSUFFICIENT-LIQUIDITY (err u111))
(define-constant ERR-REENTRANT-CALL (err u112))
(define-constant ERR-INVALID-MARKET (err u113))
(define-constant ERR-INVALID-FEE (err u114))
(define-constant ERR-NO-FEES-TO-CLAIM (err u115))
(define-constant PRECISION u1000000000000) ;; 10^12 for higher precision
(define-constant ERR-INVALID-ODDS (err u116))
(define-constant ERR-CALCULATION-FAILED (err u117))
(define-constant ERR-EXCESSIVE-SLIPPAGE (err u118))
(define-constant ERR-INVALID-TITLE (err u11))
(define-constant ERR-INVARIANT-BROKEN (err u119))






;; Data Variables (unchanged)
(define-data-var contract-owner principal tx-sender)
(define-data-var next-market-id uint u1)
(define-data-var reentrancy-guard bool false)
(define-data-var allowed-function (optional principal) none)
(define-data-var contract-initialized bool false)



;; Check if the caller is the contract owner
(define-private (is-contract-owner)
  (is-eq tx-sender (var-get contract-owner))
)


(define-public (set-allowed-function (function principal))
  (begin
    (asserts! (is-contract-owner) ERR-NOT-AUTHORIZED)
    (ok (var-set allowed-function (some function)))
  )
)

(define-map markets uint {
    resolved: bool,
    outcome: (optional bool),
    yes-pool: uint,
    no-pool: uint,
    total_lp_tokens: uint,
    fee-numerator: uint,
    market-title: (string-ascii 70)
})

(define-map lp-positions { market-id: uint, user: principal } uint)
(define-map user-positions { market-id: uint, user: principal } { yes: uint, no: uint })

;; Helper Functions

(define-private (is-valid-active-market (market-id uint))
  (match (map-get? markets market-id)
    market (not (get resolved market))
    false
  )
)

;; Helper function to calculate k
(define-read-only (calculate-k (yes-pool uint) (no-pool uint))
  (* yes-pool no-pool)
)


(define-private (calculate-and-deduct-fee (market-id uint) (amount uint))
    (let ((market (unwrap! (map-get? markets market-id) ERR-MARKET-NOT-FOUND))
          (fee-numerator (get fee-numerator market))
          (fee-amount (/ (* amount (- u10000 fee-numerator)) u10000)))
        (ok {
            net-bet-amount: (- amount fee-amount),
            fee-amount: fee-amount
        })
    )
)
(define-private (transfer-stx (amount uint) (sender principal) (recipient principal))
    (stx-transfer? amount sender recipient)
)



;; Public Functions
(define-public (create-market (initial-liquidity uint) (yes-percentage uint) (fee-numerator uint) (market-title (string-ascii 50)))
    (let
        ((market-id (var-get next-market-id))
         (yes-pool (/ (* initial-liquidity yes-percentage) u10000))
         (no-pool (- initial-liquidity yes-pool)))
        (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED)
        (asserts! (> initial-liquidity u0) ERR-INVALID-AMOUNT)
        (asserts! (> (len market-title) u0) ERR-INVALID-TITLE)
        (asserts! (and (>= yes-percentage u100) (<= yes-percentage u9900)) ERR-INVALID-ODDS)
        (asserts! (and (> yes-pool u0) (> no-pool u0)) ERR-INSUFFICIENT-LIQUIDITY)
        (asserts! (and (>= fee-numerator u0) (<= fee-numerator u1000)) ERR-INVALID-FEE) ;; Fee between 0% and 10%
        (print { event: "market-created", market-id: market-id, initial-liquidity: initial-liquidity, yes-percentage: yes-percentage, fee-numerator: fee-numerator, market-title: market-title })

        ;; Update market state
        (map-set markets market-id {
            resolved: false,
            outcome: none,
            yes-pool: yes-pool,
            no-pool: no-pool,
            total_lp_tokens: initial-liquidity,
            fee-numerator: fee-numerator,
            market-title: market-title
        })
   
        ;; Update LP position for the deployer
        (map-set lp-positions
          { market-id: market-id, user: tx-sender }
          initial-liquidity
        )
       
        ;; Transfer initial liquidity from contract owner
        (match (stx-transfer? initial-liquidity tx-sender (as-contract tx-sender))
            success (begin
                (var-set next-market-id (+ market-id u1))
                (ok market-id))
            error ERR-TRANSFER-FAILED
        )
    )
)
(define-public (add-liquidity (market-id uint) (stx-amount uint))
  (let (
    (market (unwrap! (map-get? markets market-id) ERR-MARKET-NOT-FOUND))
    (caller tx-sender)
  )
    (asserts! (not (get resolved market)) ERR-MARKET-RESOLVED)
    (asserts! (> stx-amount u0) ERR-INVALID-AMOUNT)
   
    (let (
      (yes-pool (get yes-pool market))
      (no-pool (get no-pool market))
      (total_lp_tokens (get total_lp_tokens market))
      (total-liquidity (+ yes-pool no-pool))
      (lp-tokens-to-mint (if (is-eq total_lp_tokens u0)
                             stx-amount
                             (/ (* stx-amount total_lp_tokens) total-liquidity)))
      (yes-to-add (/ (* stx-amount yes-pool) total-liquidity))
      (no-to-add (/ (* stx-amount no-pool) total-liquidity))
    )

(print {
  event: "add-liquidity",
  market-id: market-id,
  user: caller,
  stx-amount: stx-amount,
  initial-yes-pool: yes-pool,
  initial-no-pool: no-pool,
  initial-total-lp-tokens: total_lp_tokens,
  lp-tokens-to-mint: lp-tokens-to-mint,
  yes-to-add: yes-to-add,
  no-to-add: no-to-add,
  new-yes-pool: (+ yes-pool yes-to-add),
  new-no-pool: (+ no-pool no-to-add),
  new-total-lp-tokens: (+ total_lp_tokens lp-tokens-to-mint)
})





      ;; Update market state
      (map-set markets market-id
        (merge market {
          yes-pool: (+ yes-pool yes-to-add),
          no-pool: (+ no-pool no-to-add),
          total_lp_tokens: (+ total_lp_tokens lp-tokens-to-mint)
        })
      )
     
      ;; Update LP position
      (map-set lp-positions
        { market-id: market-id, user: caller }
        (+ (default-to u0 (map-get? lp-positions { market-id: market-id, user: caller }))
           lp-tokens-to-mint)
      )
     
      ;; Transfer STX from user to contract
      (match (stx-transfer? stx-amount caller (as-contract tx-sender))
        success (ok lp-tokens-to-mint)
        error ERR-TRANSFER-FAILED
      )
    )
  )
)
(define-public (remove-liquidity (market-id uint) (lp-tokens-to-remove uint))
  (let (
    (market (unwrap! (map-get? markets market-id) ERR-MARKET-NOT-FOUND))
    (user-lp-tokens (unwrap! (map-get? lp-positions { market-id: market-id, user: tx-sender }) ERR-NO-POSITION))
  )
    (asserts! (not (get resolved market)) ERR-MARKET-RESOLVED)
    (asserts! (> lp-tokens-to-remove u0) ERR-INVALID-AMOUNT)
    (asserts! (<= lp-tokens-to-remove user-lp-tokens) ERR-INSUFFICIENT-BALANCE)
   
    (let (
      (yes-pool (get yes-pool market))
      (no-pool (get no-pool market))
      (total_lp_tokens (get total_lp_tokens market))
      (removal-ratio (/ (* lp-tokens-to-remove PRECISION) total_lp_tokens))
    )
      (let (
        (yes-to-remove (/ (* yes-pool removal-ratio) PRECISION))
        (no-to-remove (/ (* no-pool removal-ratio) PRECISION))
        (liquidity-to-remove (+ yes-to-remove no-to-remove))
        (new-yes-pool (- yes-pool yes-to-remove))
        (new-no-pool (- no-pool no-to-remove))
      )

(print {
  event: "remove-liquidity",
  market-id: market-id,
  user: tx-sender,
  lp-tokens-to-remove: lp-tokens-to-remove,
  initial-yes-pool: yes-pool,
  initial-no-pool: no-pool,
  initial-total-lp-tokens: total_lp_tokens,
  removal-ratio: removal-ratio,
  yes-to-remove: yes-to-remove,
  no-to-remove: no-to-remove,
  liquidity-to-remove: liquidity-to-remove,
  new-yes-pool: new-yes-pool,
  new-no-pool: new-no-pool,
  new-total-lp-tokens: (- total_lp_tokens lp-tokens-to-remove)
})

        ;; Update market state
        (map-set markets market-id
          (merge market {
            yes-pool: new-yes-pool,
            no-pool: new-no-pool,
            total_lp_tokens: (- total_lp_tokens lp-tokens-to-remove)
          })
        )
       
        ;; Update LP position
        (map-set lp-positions
          { market-id: market-id, user: tx-sender }
          (- user-lp-tokens lp-tokens-to-remove)
        )
       
        ;; Transfer liquidity back to user
        (let ((caller tx-sender))
          (match (as-contract (stx-transfer? liquidity-to-remove tx-sender caller))
            success (begin
              (print {
                event: "liquidity-removed",
                market-id: market-id,
                user: caller,
                lp-tokens-removed: lp-tokens-to-remove,
                stx-returned: liquidity-to-remove,
                new-yes-pool: new-yes-pool,
                new-no-pool: new-no-pool
              })
              (ok {
                lp-tokens-removed: lp-tokens-to-remove,
                stx-returned: liquidity-to-remove
              })
            )
            error ERR-TRANSFER-FAILED
          )
        )
      )
    )
  )
)

(define-public (swap-stx-to-yes (market-id uint) (stx-amount uint) (min-yes-amount uint))
  (let
    (
      (market (unwrap! (map-get? markets market-id) ERR-MARKET-NOT-FOUND))
    )
    (asserts! (is-valid-active-market market-id) ERR-INVALID-MARKET)
    (asserts! (> stx-amount u0) ERR-INVALID-AMOUNT)

    (let
      (
        (yes-pool (get yes-pool market))
        (no-pool (get no-pool market))
        (fee-numerator (get fee-numerator market))
        (fee-denominator u10000)
        (fee-multiplier (- fee-denominator fee-numerator))
        ;; Net STX amount after fee
        (net-stx-amount (/ (* stx-amount fee-multiplier) fee-denominator))
        ;; Calculate YES tokens to give to user
        (numerator (* net-stx-amount no-pool))
        (denominator (+ yes-pool net-stx-amount))
        (yes-amount (/ numerator denominator))
        ;; Update pools
        (new-yes-pool (+ yes-pool net-stx-amount))
        (new-no-pool (- no-pool yes-amount))
      )
      ;; Slippage check
      (asserts! (>= yes-amount min-yes-amount) ERR-EXCESSIVE-SLIPPAGE)

      ;; Update market state
      (map-set markets market-id (merge market {
        yes-pool: new-yes-pool,
        no-pool: new-no-pool
      }))

      ;; Update user position
      (let
        (
          (current-position (default-to { yes: u0, no: u0 }
            (map-get? user-positions { market-id: market-id, user: tx-sender })))
        )
        (map-set user-positions
          { market-id: market-id, user: tx-sender }
          {
            yes: (+ (get yes current-position) yes-amount),
            no: (get no current-position)
          })
      )

      ;; Transfer STX from user to contract
      (match (stx-transfer? stx-amount tx-sender (as-contract tx-sender))
        success
          (begin
            (print {
              event: "swap-stx-to-yes",
              market-id: market-id,
              user: tx-sender,
              stx-amount: stx-amount,
              yes-amount: yes-amount,
              new-yes-pool: new-yes-pool,
              new-no-pool: new-no-pool
            })
            (ok yes-amount)
          )
        error ERR-TRANSFER-FAILED
      )
    )
  )
)


(define-public (swap-stx-to-no (market-id uint) (stx-amount uint) (min-no-amount uint))
  (let
    (
      (market (unwrap! (map-get? markets market-id) ERR-MARKET-NOT-FOUND))
    )
    (asserts! (is-valid-active-market market-id) ERR-INVALID-MARKET)
    (asserts! (> stx-amount u0) ERR-INVALID-AMOUNT)

    (let
      (
        (yes-pool (get yes-pool market))
        (no-pool (get no-pool market))
        (fee-numerator (get fee-numerator market))
        (fee-denominator u10000)
        (fee-multiplier (- fee-denominator fee-numerator))
        ;; Net STX amount after fee
        (net-stx-amount (/ (* stx-amount fee-multiplier) fee-denominator))
        ;; Calculate NO tokens to give to user
        (numerator (* net-stx-amount yes-pool))
        (denominator (+ no-pool net-stx-amount))
        (no-amount (/ numerator denominator))
        ;; Update pools
        (new-no-pool (+ no-pool net-stx-amount))
        (new-yes-pool (- yes-pool no-amount))
      )
      ;; Slippage check
      (asserts! (>= no-amount min-no-amount) ERR-EXCESSIVE-SLIPPAGE)

      ;; Update market state
      (map-set markets market-id (merge market {
        yes-pool: new-yes-pool,
        no-pool: new-no-pool
      }))

      ;; Update user position
      (let
        (
          (current-position (default-to { yes: u0, no: u0 }
            (map-get? user-positions { market-id: market-id, user: tx-sender })))
        )
        (map-set user-positions
          { market-id: market-id, user: tx-sender }
          {
            yes: (get yes current-position),
            no: (+ (get no current-position) no-amount)
          })
      )

      ;; Transfer STX from user to contract
      (match (stx-transfer? stx-amount tx-sender (as-contract tx-sender))
        success
          (begin
            (print {
              event: "swap-stx-to-no",
              market-id: market-id,
              user: tx-sender,
              stx-amount: stx-amount,
              no-amount: no-amount,
              new-yes-pool: new-yes-pool,
              new-no-pool: new-no-pool
            })
            (ok no-amount)
          )
        error ERR-TRANSFER-FAILED
      )
    )
  )
)




(define-public (swap-yes-to-stx (market-id uint) (yes-amount uint) (min-stx-amount uint))
  (let
    (
      (market (unwrap! (map-get? markets market-id) ERR-MARKET-NOT-FOUND))
      (user-position (unwrap! (map-get? user-positions { market-id: market-id, user: tx-sender }) ERR-NO-POSITION))
      (user-principal tx-sender) ;; Store user's principal
    )
    (asserts! (is-valid-active-market market-id) ERR-INVALID-MARKET)
    (asserts! (> yes-amount u0) ERR-INVALID-AMOUNT)
    (asserts! (>= (get yes user-position) yes-amount) ERR-INSUFFICIENT-BALANCE)

    (let
      (
        (yes-pool (get yes-pool market))
        (no-pool (get no-pool market))
        (fee-numerator (get fee-numerator market))
        (fee-denominator u10000)
        (fee-multiplier (- fee-denominator fee-numerator))
        ;; New YES pool after user adds yes-amount
        (new-yes-pool (+ yes-pool yes-amount))
        ;; Calculate STX amount to give to user before fee
        (numerator (* yes-amount no-pool))
        (denominator new-yes-pool)
        (stx-amount-before-fee (/ numerator denominator))
        ;; Apply fee
        (stx-amount (/ (* stx-amount-before-fee fee-multiplier) fee-denominator))
        ;; Update NO pool
        (new-no-pool (- no-pool stx-amount))
      )
      ;; Slippage check
      (asserts! (>= stx-amount min-stx-amount) ERR-EXCESSIVE-SLIPPAGE)

      ;; Update market state
      (map-set markets market-id (merge market {
        yes-pool: new-yes-pool,
        no-pool: new-no-pool
      }))

      ;; Update user position
      (map-set user-positions
        { market-id: market-id, user: user-principal }
        (merge user-position {
          yes: (- (get yes user-position) yes-amount)
        })
      )

      ;; Transfer STX from contract to user
      (match (as-contract (stx-transfer? stx-amount tx-sender user-principal))
        success
          (begin
            (print {
              event: "swap-yes-to-stx",
              market-id: market-id,
              user: user-principal,
              yes-amount: yes-amount,
              stx-amount: stx-amount,
              new-yes-pool: new-yes-pool,
              new-no-pool: new-no-pool
            })
            (ok stx-amount)
          )
        error ERR-TRANSFER-FAILED
      )
    )
  )
)


(define-public (swap-no-to-stx (market-id uint) (no-amount uint) (min-stx-amount uint))
  (let
    (
      (market (unwrap! (map-get? markets market-id) ERR-MARKET-NOT-FOUND))
      (user-position (unwrap! (map-get? user-positions { market-id: market-id, user: tx-sender }) ERR-NO-POSITION))
      (user-principal tx-sender) ;; Store user's principal
    )
    (asserts! (is-valid-active-market market-id) ERR-INVALID-MARKET)
    (asserts! (> no-amount u0) ERR-INVALID-AMOUNT)
    (asserts! (>= (get no user-position) no-amount) ERR-INSUFFICIENT-BALANCE)

    (let
      (
        (yes-pool (get yes-pool market))
        (no-pool (get no-pool market))
        (fee-numerator (get fee-numerator market))
        (fee-denominator u10000)
        (fee-multiplier (- fee-denominator fee-numerator))
        ;; New NO pool after user adds no-amount
        (new-no-pool (+ no-pool no-amount))
        ;; Calculate STX amount to give to user before fee
        (numerator (* no-amount yes-pool))
        (denominator new-no-pool)
        (stx-amount-before-fee (/ numerator denominator))
        ;; Apply fee
        (stx-amount (/ (* stx-amount-before-fee fee-multiplier) fee-denominator))
        ;; Update YES pool
        (new-yes-pool (- yes-pool stx-amount))
      )
      ;; Slippage check
      (asserts! (>= stx-amount min-stx-amount) ERR-EXCESSIVE-SLIPPAGE)
      ;; Underflow check for new-yes-pool
      (asserts! (>= new-yes-pool u0) ERR-INSUFFICIENT-LIQUIDITY)

      ;; Update market state
      (map-set markets market-id (merge market {
        yes-pool: new-yes-pool,
        no-pool: new-no-pool
      }))

      ;; Update user position
      (map-set user-positions
        { market-id: market-id, user: user-principal }
        (merge user-position {
          no: (- (get no user-position) no-amount)
        })
      )

      ;; Transfer STX from contract to user
      (match (as-contract (stx-transfer? stx-amount tx-sender user-principal))
        success
          (begin
            (print {
              event: "swap-no-to-stx",
              market-id: market-id,
              user: user-principal,
              no-amount: no-amount,
              stx-amount: stx-amount,
              new-yes-pool: new-yes-pool,
              new-no-pool: new-no-pool
            })
            (ok stx-amount)
          )
        error ERR-TRANSFER-FAILED
      )
    )
  )
)









(define-public (resolve-market (market-id uint) (outcome bool))
    (let
        ((market (unwrap! (map-get? markets market-id) ERR-MARKET-NOT-FOUND)))
        (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED)
        (asserts! (not (get resolved market)) ERR-MARKET-RESOLVED)
       
        (let
            ((yes-pool (get yes-pool market))
             (no-pool (get no-pool market))
             (total-liquidity (+ yes-pool no-pool)))
           
            ;; Set all liquidity to the winning pool, make losing pool zero
            (map-set markets market-id (merge market {
                resolved: true,
                outcome: (some outcome),
                yes-pool: (if outcome total-liquidity u0),
                no-pool: (if outcome u0 total-liquidity)
            }))
           
            (print {
                event: "market-resolved",
                market-id: market-id,
                outcome: outcome,
                total-liquidity: total-liquidity
            })
            (ok true)
        )
    )
)

(define-public (claim-winnings (market-id uint))
    (let
        ((market (unwrap! (map-get? markets market-id) (err ERR-MARKET-NOT-FOUND)))
         (user-position (unwrap! (map-get? user-positions { market-id: market-id, user: tx-sender }) (err ERR-NO-POSITION))))
       
        (asserts! (get resolved market) (err ERR-MARKET-NOT-RESOLVED))
        (asserts! (is-some (get outcome market)) (err ERR-NO-OUTCOME))
       
        (let
            ((outcome (unwrap! (get outcome market) (err ERR-NO-OUTCOME)))
             (winning-pool (if outcome (get yes-pool market) (get no-pool market)))
             (user-winning-tokens (if outcome (get yes user-position) (get no user-position)))
             (total-winning-tokens (if outcome (get yes-pool market) (get no-pool market))))
           
            (asserts! (> user-winning-tokens u0) (err ERR-NO-WINNINGS))
           
            (let
                ((winnings (/ (* user-winning-tokens winning-pool) total-winning-tokens))
                 (caller tx-sender))
               
                ;; Clear user position
                (map-delete user-positions { market-id: market-id, user: tx-sender })
               
                ;; Update market state
                (map-set markets market-id
                    (merge market {
                        yes-pool: (if outcome (- (get yes-pool market) winnings) u0),
                        no-pool: (if outcome u0 (- (get no-pool market) winnings))
                    })
                )
               
                ;; Transfer winnings to user
                (match (as-contract (stx-transfer? winnings tx-sender caller))
                    success (begin
                        (print {
                            event: "winnings-claimed",
                            market-id: market-id,
                            user: caller,
                            winnings: winnings
                        })
                        (ok winnings)
                    )
                    error (err ERR-TRANSFER-FAILED)
                )
            )
        )
    )
)

(define-public (claim-lp-winnings (market-id uint))
  (let
    (
      (market-opt (map-get? markets market-id))
      (caller tx-sender)
    )
    (match market-opt
      market
        (match (map-get? lp-positions { market-id: market-id, user: caller })
          lp-tokens
            (begin
              (asserts! (get resolved market) (err ERR-MARKET-NOT-RESOLVED))
              (asserts! (is-some (get outcome market)) (err ERR-NO-OUTCOME))
              (asserts! (> lp-tokens u0) (err ERR-NO-WINNINGS))
              
              (let
                (
                  (total_lp_tokens (get total_lp_tokens market))
                  (total_liquidity (+ (get yes-pool market) (get no-pool market)))
                  (lp-share (/ (* lp-tokens total_liquidity) total_lp_tokens))
                  (new_total_lp_tokens (- total_lp_tokens lp-tokens))
                  (new_liquidity (- total_liquidity lp-share))
                )
                ;; Update LP's position
                (map-set lp-positions { market-id: market-id, user: caller } u0)
                ;; Update market state
                (map-set markets market-id (merge market {
                  total_lp_tokens: new_total_lp_tokens,
                  yes-pool: new_liquidity,
                  no-pool: u0
                }))
                ;; Transfer winnings to LP
                (match (as-contract (stx-transfer? lp-share (as-contract tx-sender) caller))
                  success (ok lp-share)
                  error (err ERR-TRANSFER-FAILED)
                )
              )
            )
          (err ERR-NO-POSITION)
        )
      (err ERR-MARKET-NOT-FOUND)
    )
  )
)

;; Read-only functions
(define-read-only (get-user-liquidity (market-id uint) (user principal))
  (match (map-get? lp-positions { market-id: market-id, user: user })
    position (ok position)
    (ok u0)
  )
)
(define-read-only (get-market-title (market-id uint))
  (match (map-get? markets market-id)
    market (ok (get market-title market))
    ERR-MARKET-NOT-FOUND
  )
)


(define-read-only (get-user-position (market-id uint) (user principal))
  (match (map-get? user-positions { market-id: market-id, user: user })
    position (ok position)
    (ok { yes: u0, no: u0 })
  )
)




(define-read-only (get-total-markets)
  (- (var-get next-market-id) u1))

(define-read-only (market-exists? (market-id uint))
  (is-some (map-get? markets market-id)))



(define-read-only (get-lp-position-info (market-id uint) (user principal))
  (match (map-get? markets market-id)
    market
      (let
        ((user-lp-tokens (default-to u0
                         (map-get? lp-positions { market-id: market-id, user: user })))
         (total-lp-tokens (get total_lp_tokens market))
         (total-liquidity (+ (get yes-pool market) (get no-pool market))))
       
        (ok {
          user-lp-tokens: user-lp-tokens,
          total-lp-tokens: total-lp-tokens,
          total-liquidity: total-liquidity,
          lp-token-value: (if (is-eq total-lp-tokens u0)
                              u0
                              (/ (* total-liquidity PRECISION) total-lp-tokens)),
          position-value: (if (is-eq total-lp-tokens u0)
                              u0
                              (/ (* user-lp-tokens total-liquidity) total-lp-tokens))
        })
      )
    (err ERR-MARKET-NOT-FOUND)
  )
)


(define-read-only (get-market-details (market-id uint))
  (match (map-get? markets market-id)
    market (ok {
      resolved: (get resolved market),
      outcome: (get outcome market),
      yes-pool: (get yes-pool market),
      no-pool: (get no-pool market),
      total-liquidity: (+ (get yes-pool market) (get no-pool market)),
      total-lp-tokens: (get total_lp_tokens market),
      k: (calculate-k (get yes-pool market) (get no-pool market))
    })
    (err ERR-MARKET-NOT-FOUND)
  )
)


(define-read-only (is-market-resolved (market-id uint))
  (match (map-get? markets market-id)
    market (ok (get resolved market))
    (err ERR-MARKET-NOT-FOUND)
  )
)



;;(define-read-only (get-market-liquidity (market-id uint))
;;  (match (map-get? markets market-id)
 ;;   market (ok (get total-liquidity market))
 ;;   (err ERR-MARKET-NOT-FOUND)
 ;; )
;;)


(define-read-only (get-contract-balance)
  (stx-get-balance (as-contract tx-sender))
)
(define-read-only (get-user-liquidity-position (market-id uint) (user principal))
  (match (map-get? lp-positions { market-id: market-id, user: user })
    position (ok position)
    (err ERR-NO-POSITION)
  )
)