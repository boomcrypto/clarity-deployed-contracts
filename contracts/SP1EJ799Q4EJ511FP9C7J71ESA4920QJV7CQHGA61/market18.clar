(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-MARKET-NOT-FOUND (err u101))
(define-constant ERR-MARKET-RESOLVED (err u102))
(define-constant ERR-MARKET-NOT-RESOLVED (err u103))
(define-constant ERR-NO-OUTCOME (err u104))
(define-constant ERR-INVALID-AMOUNT (err u105))
(define-constant ERR-TRANSFER-FAILED (err u106))
(define-constant ERR-INSUFFICIENT-BALANCE (err u107))
(define-constant ERR-INSUFFICIENT-LIQUIDITY (err u108))
(define-constant ERR-NO-POSITION (err u109))
(define-constant ERR-NO-WINNINGS (err u110))
(define-constant ERR-EXCESSIVE-SLIPPAGE (err u111))
(define-constant ERR-INVALID-ODDS (err u112))
(define-constant ERR-INVALID-FEE (err u113))
(define-constant ERR-INVALID-TITLE (err u114))
(define-constant ERR-INVALID-MARKET (err u115))
(define-constant ERR-CALCULATION-FAILED (err u116))
(define-constant ERR-INVARIANT-BROKEN (err u117))
(define-constant ERR-DIVISION-BY-ZERO (err 188))
(define-constant ERR-NEGATIVE-FINAL-STX (err 188))
ERR-NEGATIVE-FINAL-STX




;;final state, swapping from stx to yes or no grows K, swapping back DOES not work.  Also issues with LP claiming funds as there is an STX shortfall, the growing of K MIGHT fix the shortfall.


;; Precision Constant
(define-constant PRECISION u1000000)


;; Data Variables
(define-data-var contract-owner principal tx-sender)
(define-data-var next-market-id uint u1)

;; Data Variables
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
  lp-yes-pool: uint,    ;; Liquidity provider YES pool
  lp-no-pool: uint,     ;; Liquidity provider NO pool
  bet-yes-pool: uint,   ;; Total YES bets
  bet-no-pool: uint,    ;; Total NO bets
  total-lp-tokens: uint,
  fee-numerator: uint,
  market-title: (string-ascii 70),
  total-winning-tokens:  uint , ;; New field
  total-yes-tokens: uint,  ;; Add this field
  total-no-tokens: uint    ;; Add this field as well for completeness
})

(define-map lp-positions { market-id: uint, user: principal } uint)

;; Helper Functions
;; Updated user-positions map

(define-map user-positions { market-id: uint, user: principal } {
  yes-stx: uint,      ;; STX invested in YES bets
  no-stx: uint,       ;; STX invested in NO bets
  yes-tokens: uint,   ;; YES tokens held
  no-tokens: uint     ;; NO tokens held
})


;; Helper function to calculate k (product of pools)


(define-private (transfer-stx (amount uint) (sender principal) (recipient principal))
  (stx-transfer? amount sender recipient)
)

;; Public Functions
(define-public (create-market (initial-liquidity uint) (yes-percentage uint) (fee-numerator uint) (market-title (string-ascii 50)))
  (let
    (
      (market-id (var-get next-market-id))
      (lp-yes-pool (/ (* initial-liquidity yes-percentage) u100))
      (lp-no-pool (- initial-liquidity lp-yes-pool))
      (total-lp-tokens initial-liquidity)
    )
    (asserts! (is-contract-owner) ERR-NOT-AUTHORIZED)
    (asserts! (> initial-liquidity u0) ERR-INVALID-AMOUNT)
    (asserts! (> (len market-title) u0) ERR-INVALID-TITLE)
    (asserts! (and (>= yes-percentage u1) (<= yes-percentage u99)) ERR-INVALID-ODDS)
    (asserts! (and (> lp-yes-pool u0) (> lp-no-pool u0)) ERR-INSUFFICIENT-LIQUIDITY)
    (asserts! (and (>= fee-numerator u0) (<= fee-numerator u1000)) ERR-INVALID-FEE)

    (print { event: "market-created", market-id: market-id, initial-liquidity: initial-liquidity, yes-percentage: yes-percentage, fee-numerator: fee-numerator, market-title: market-title })

    (map-set markets market-id {
      resolved: false,
      outcome: none,
      lp-yes-pool: lp-yes-pool,
      lp-no-pool: lp-no-pool,
      bet-yes-pool: u0,
      bet-no-pool: u0,
      total-lp-tokens: total-lp-tokens,
      fee-numerator: fee-numerator,
      market-title: market-title,
      total-winning-tokens: u0,
      total-yes-tokens : u0,
      total-no-tokens: u0
    })

    (map-set lp-positions
      { market-id: market-id, user: tx-sender }
      total-lp-tokens
    )

    (match (stx-transfer? initial-liquidity tx-sender (as-contract tx-sender))
      success
        (begin
          (var-set next-market-id (+ market-id u1))
          (ok market-id)
        )
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
      (lp-yes-pool (get lp-yes-pool market))
      (lp-no-pool (get lp-no-pool market))
      (total-lp-tokens (get total-lp-tokens market))
      (total-liquidity (+ lp-yes-pool lp-no-pool))
      (lp-tokens-to-mint (if (is-eq total-lp-tokens u0)
                             stx-amount
                             (/ (* stx-amount total-lp-tokens) total-liquidity)))
      (yes-to-add (/ (* stx-amount lp-yes-pool) total-liquidity))
      (no-to-add (/ (* stx-amount lp-no-pool) total-liquidity))
      (new-lp-yes-pool (+ lp-yes-pool yes-to-add))
      (new-lp-no-pool (+ lp-no-pool no-to-add))
      (new-total-lp-tokens (+ total-lp-tokens lp-tokens-to-mint))
    )
      ;; Update market state
      (map-set markets market-id
        (merge market {
          lp-yes-pool: new-lp-yes-pool,
          lp-no-pool: new-lp-no-pool,
          total-lp-tokens: new-total-lp-tokens
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
        success
          (begin
            (print {
              event: "add-liquidity",
              market-id: market-id,
              user: caller,
              stx-amount: stx-amount,
              lp-tokens-minted: lp-tokens-to-mint,
              new-lp-yes-pool: new-lp-yes-pool,
              new-lp-no-pool: new-lp-no-pool,
              new-total-lp-tokens: new-total-lp-tokens
            })
            (ok lp-tokens-to-mint)
          )
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
      (lp-yes-pool (get lp-yes-pool market))
      (lp-no-pool (get lp-no-pool market))
      (total-lp-tokens (get total-lp-tokens market))
      (removal-ratio (/ (* lp-tokens-to-remove PRECISION) total-lp-tokens))
      (yes-to-remove (/ (* lp-yes-pool removal-ratio) PRECISION))
      (no-to-remove (/ (* lp-no-pool removal-ratio) PRECISION))
      (stx-to-return (+ yes-to-remove no-to-remove))
      (new-lp-yes-pool (- lp-yes-pool yes-to-remove))
      (new-lp-no-pool (- lp-no-pool no-to-remove))
      (new-total-lp-tokens (- total-lp-tokens lp-tokens-to-remove))
    )
      (print {
        event: "remove-liquidity-debug",
        market-id: market-id,
        user: tx-sender,
        lp-tokens-to-remove: lp-tokens-to-remove,
        user-lp-tokens: user-lp-tokens,
        initial-lp-yes-pool: lp-yes-pool,
        initial-lp-no-pool: lp-no-pool,
        initial-total-lp-tokens: total-lp-tokens,
        removal-ratio: removal-ratio,
        yes-to-remove: yes-to-remove,
        no-to-remove: no-to-remove,
        stx-to-return: stx-to-return,
        new-lp-yes-pool: new-lp-yes-pool,
        new-lp-no-pool: new-lp-no-pool,
        new-total-lp-tokens: new-total-lp-tokens,
        contract-balance: (stx-get-balance (as-contract tx-sender))
      })

      ;; Update market state
      (map-set markets market-id
        (merge market {
          lp-yes-pool: new-lp-yes-pool,
          lp-no-pool: new-lp-no-pool,
          total-lp-tokens: new-total-lp-tokens
        })
      )

      ;; Update LP position
      (map-set lp-positions
        { market-id: market-id, user: tx-sender }
        (- user-lp-tokens lp-tokens-to-remove)
      )

      ;; Transfer STX back to user
      (let ((caller tx-sender))
        (match (as-contract (stx-transfer? stx-to-return tx-sender caller))
          success
            (begin
              (print {
                event: "remove-liquidity",
                market-id: market-id,
                user: caller,
                lp-tokens-removed: lp-tokens-to-remove,
                stx-returned: stx-to-return,
                new-lp-yes-pool: new-lp-yes-pool,
                new-lp-no-pool: new-lp-no-pool
              })
              (ok {
                lp-tokens-removed: lp-tokens-to-remove,
                stx-returned: stx-to-return
              })
            )
          error ERR-TRANSFER-FAILED
        )
      )
    )
  )
)


(define-public (swap-stx-to-yes (market-id uint) (stx-amount uint) (min-yes-amount uint))
  (let 
    (
      (market (unwrap! (map-get? markets market-id) ERR-MARKET-NOT-FOUND))
      (caller tx-sender)
    )
    (asserts! (> stx-amount u0) ERR-INVALID-AMOUNT)
    (asserts! (not (get resolved market)) ERR-MARKET-RESOLVED)  
    
    (let
      (
        (lp-yes-pool (get lp-yes-pool market))
        (lp-no-pool (get lp-no-pool market))
        (initial-k (* lp-yes-pool lp-no-pool))
      )
      (print { 
        event: "swap-debug-1-initial",
        initial_yes_pool: lp-yes-pool,
        initial_no_pool: lp-no-pool,
        initial_k: initial-k
      })

      ;; Step 1: Calculate pure constant product swap
      (let
        (
          ;; dy = y - (xy/(x + dx))
          (new-yes-pool (+ lp-yes-pool stx-amount))
          (new-no-pool (/ (* lp-yes-pool lp-no-pool) new-yes-pool))
          (tokens-out-before-fee (- lp-no-pool new-no-pool))
        )
        (print {
          event: "swap-debug-2-pure-swap",
          tokens_out_before_fee: tokens-out-before-fee,
          new_yes_pool_before_fee: new-yes-pool,
          new_no_pool_before_fee: new-no-pool
        })

        ;; Step 2: Calculate and apply fee on output
        (let
          (
            (fee-numerator (get fee-numerator market))
            (fee-denominator u10000)
            (fee-amount (/ (* tokens-out-before-fee fee-numerator) fee-denominator))
            (final-tokens-out (- tokens-out-before-fee fee-amount))
            (final-no-pool (- lp-no-pool final-tokens-out))
            (new-k (* new-yes-pool final-no-pool))
          )
          (print {
            event: "swap-debug-3-final",
            fee_amount: fee-amount,
            final_tokens_out: final-tokens-out,
            final_yes_pool: new-yes-pool,
            final_no_pool: final-no-pool,
            initial_k: initial-k,
            new_k: new-k,
            k_growth: (- new-k initial-k)
          })

          (asserts! (>= final-tokens-out min-yes-amount) ERR-EXCESSIVE-SLIPPAGE)

          ;; Update market state
          (map-set markets market-id (merge market {
            lp-yes-pool: new-yes-pool,
            lp-no-pool: final-no-pool,
            bet-yes-pool: (+ (get bet-yes-pool market) stx-amount),
            total-yes-tokens: (+ (get total-yes-tokens market) final-tokens-out)
          }))

          ;; Update user position
          (let
            (
              (current-position (default-to { yes-stx: u0, no-stx: u0, yes-tokens: u0, no-tokens: u0 }
                (map-get? user-positions { market-id: market-id, user: caller })))
            )
            (map-set user-positions
              { market-id: market-id, user: caller }
              {
                yes-stx: (+ (get yes-stx current-position) stx-amount),
                no-stx: (get no-stx current-position),
                yes-tokens: (+ (get yes-tokens current-position) final-tokens-out),
                no-tokens: (get no-tokens current-position)
              })

            ;; Transfer STX from user to contract
            (match (stx-transfer? stx-amount caller (as-contract tx-sender))
              success (ok final-tokens-out)
              error ERR-TRANSFER-FAILED
            )))))))


(define-public (swap-stx-to-no (market-id uint) (stx-amount uint) (min-no-amount uint))
  (let 
    (
      (market (unwrap! (map-get? markets market-id) ERR-MARKET-NOT-FOUND))
      (caller tx-sender)
    )
    (asserts! (> stx-amount u0) ERR-INVALID-AMOUNT)
    (asserts! (not (get resolved market)) ERR-MARKET-RESOLVED)  
    
    (let
      (
        (lp-yes-pool (get lp-yes-pool market))
        (lp-no-pool (get lp-no-pool market))
        (initial-k (* lp-yes-pool lp-no-pool))
      )
      (print { 
        event: "swap-debug-1-initial",
        initial_yes_pool: lp-yes-pool,
        initial_no_pool: lp-no-pool,
        initial_k: initial-k
      })

      ;; Step 1: Calculate pure constant product swap
      (let
        (
          ;; Same formula but for NO pool
          (new-no-pool (+ lp-no-pool stx-amount))
          (new-yes-pool (/ (* lp-yes-pool lp-no-pool) new-no-pool))
          (tokens-out-before-fee (- lp-yes-pool new-yes-pool))
        )
        (print {
          event: "swap-debug-2-pure-swap",
          tokens_out_before_fee: tokens-out-before-fee,
          new_yes_pool_before_fee: new-yes-pool,
          new_no_pool_before_fee: new-no-pool
        })

        ;; Step 2: Calculate and apply fee on output
        (let
          (
            (fee-numerator (get fee-numerator market))
            (fee-denominator u10000)
            (fee-amount (/ (* tokens-out-before-fee fee-numerator) fee-denominator))
            (final-tokens-out (- tokens-out-before-fee fee-amount))
            (final-yes-pool (- lp-yes-pool final-tokens-out))
            (new-k (* final-yes-pool new-no-pool))
          )
          (print {
            event: "swap-debug-3-final",
            fee_amount: fee-amount,
            final_tokens_out: final-tokens-out,
            final_yes_pool: final-yes-pool,
            final_no_pool: new-no-pool,
            initial_k: initial-k,
            new_k: new-k,
            k_growth: (- new-k initial-k)
          })

          (asserts! (>= final-tokens-out min-no-amount) ERR-EXCESSIVE-SLIPPAGE)

          ;; Update market state
          (map-set markets market-id (merge market {
            lp-yes-pool: final-yes-pool,
            lp-no-pool: new-no-pool,
            bet-no-pool: (+ (get bet-no-pool market) stx-amount),
            total-no-tokens: (+ (get total-no-tokens market) final-tokens-out)
          }))

          ;; Update user position
          (let
            (
              (current-position (default-to { yes-stx: u0, no-stx: u0, yes-tokens: u0, no-tokens: u0 }
                (map-get? user-positions { market-id: market-id, user: caller })))
            )
            (map-set user-positions
              { market-id: market-id, user: caller }
              {
                yes-stx: (get yes-stx current-position),
                no-stx: (+ (get no-stx current-position) stx-amount),
                yes-tokens: (get yes-tokens current-position),
                no-tokens: (+ (get no-tokens current-position) final-tokens-out)
              })

            ;; Transfer STX from user to contract
            (match (stx-transfer? stx-amount caller (as-contract tx-sender))
              success (ok final-tokens-out)
              error ERR-TRANSFER-FAILED
            )))))))
(define-public (swap-yes-to-stx (market-id uint) (yes-amount uint) (min-stx-amount uint))
    (let 
        (
            (market (unwrap! (map-get? markets market-id) ERR-MARKET-NOT-FOUND))
            (caller tx-sender)
            (user-position (unwrap! (map-get? user-positions { market-id: market-id, user: caller }) ERR-NO-POSITION))
        )
        (asserts! (> yes-amount u0) ERR-INVALID-AMOUNT)
        (asserts! (<= yes-amount (get yes-tokens user-position)) ERR-INSUFFICIENT-BALANCE)
        
        (let
            (
                (lp-yes-pool (get lp-yes-pool market))
                (lp-no-pool (get lp-no-pool market))
                (initial-k (* lp-yes-pool lp-no-pool))
            )
            (print { 
                event: "swap-debug-1-initial",
                initial_yes_pool: lp-yes-pool,
                initial_no_pool: lp-no-pool,
                initial_k: initial-k
            })

            ;; Step 1: Calculate pure constant product swap
            (let
                (
                    (new-no-pool (+ lp-no-pool yes-amount))
                    (new-yes-pool (/ (* lp-yes-pool lp-no-pool) new-no-pool))
                    (stx-out-before-fee (- lp-yes-pool new-yes-pool))
                )
                (print {
                    event: "swap-debug-2-pure-swap",
                    new_no_pool_before_fee: new-no-pool,
                    new_yes_pool_before_fee: new-yes-pool,
                    stx_out_before_fee: stx-out-before-fee
                })

                ;; Step 2: Calculate and apply fee on output
                (let
                    (
                        (fee-numerator (get fee-numerator market))
                        (fee-denominator u10000)
                        (fee-amount (/ (* stx-out-before-fee fee-numerator) fee-denominator))
                        (final-stx-out (- stx-out-before-fee fee-amount))
                        (final-yes-pool (- lp-yes-pool final-stx-out))
                        (new-k (* final-yes-pool new-no-pool))
                    )
                    (print {
                        event: "swap-debug-3-final",
                        fee_amount: fee-amount,
                        final_stx_out: final-stx-out,
                        final_yes_pool: final-yes-pool,
                        final_no_pool: new-no-pool,
                        initial_k: initial-k,
                        new_k: new-k,
                        k_growth: (- new-k initial-k)
                    })

                    (asserts! (>= final-stx-out min-stx-amount) ERR-EXCESSIVE-SLIPPAGE)

                    (map-set markets market-id (merge market {
                        lp-yes-pool: final-yes-pool,
                        lp-no-pool: new-no-pool,
                        bet-yes-pool: (- (get bet-yes-pool market) final-stx-out),
                        total-yes-tokens: (- (get total-yes-tokens market) yes-amount)
                    }))

                    (map-set user-positions
                        { market-id: market-id, user: caller }
                        {
                            yes-stx: (get yes-stx user-position),
                            no-stx: (get no-stx user-position),
                            yes-tokens: (- (get yes-tokens user-position) yes-amount),
                            no-tokens: (get no-tokens user-position)
                        })

                    (match (as-contract (stx-transfer? final-stx-out tx-sender caller))
                        success (ok final-stx-out)
                        error ERR-TRANSFER-FAILED)
                    )))))



;; Updated swap-no-to-stx function
(define-public (swap-no-to-stx (market-id uint) (no-amount uint) (min-stx-amount uint))
    (let 
        (
            (market (unwrap! (map-get? markets market-id) ERR-MARKET-NOT-FOUND))
            (caller tx-sender)
            (user-position (unwrap! (map-get? user-positions { market-id: market-id, user: caller }) ERR-NO-POSITION))
        )
        (asserts! (> no-amount u0) ERR-INVALID-AMOUNT)
        (asserts! (<= no-amount (get no-tokens user-position)) ERR-INSUFFICIENT-BALANCE)
        
        (let
            (
                (lp-yes-pool (get lp-yes-pool market))
                (lp-no-pool (get lp-no-pool market))
                (initial-k (* lp-yes-pool lp-no-pool))
            )
            (print { 
                event: "swap-debug-1-initial",
                initial_yes_pool: lp-yes-pool,
                initial_no_pool: lp-no-pool,
                initial_k: initial-k
            })

            ;; Step 1: Calculate pure constant product swap
            (let
                (
                    (new-yes-pool (+ lp-yes-pool no-amount))
                    (new-no-pool (/ (* lp-yes-pool lp-no-pool) new-yes-pool))
                    (stx-out-before-fee (- lp-no-pool new-no-pool))
                )
                (print {
                    event: "swap-debug-2-pure-swap",
                    new_yes_pool_before_fee: new-yes-pool,
                    new_no_pool_before_fee: new-no-pool,
                    stx_out_before_fee: stx-out-before-fee
                })

                ;; Step 2: Calculate and apply fee on output
                (let
                    (
                        (fee-numerator (get fee-numerator market))
                        (fee-denominator u10000)
                        (fee-amount (/ (* stx-out-before-fee fee-numerator) fee-denominator))
                        (final-stx-out (- stx-out-before-fee fee-amount))
                        (final-no-pool (- lp-no-pool final-stx-out))
                        (new-k (* new-yes-pool final-no-pool))
                    )
                    (print {
                        event: "swap-debug-3-final",
                        fee_amount: fee-amount,
                        final_stx_out: final-stx-out,
                        final_yes_pool: new-yes-pool,
                        final_no_pool: final-no-pool,
                        initial_k: initial-k,
                        new_k: new-k,
                        k_growth: (- new-k initial-k)
                    })

                    (asserts! (>= final-stx-out min-stx-amount) ERR-EXCESSIVE-SLIPPAGE)

                    (map-set markets market-id (merge market {
                        lp-yes-pool: new-yes-pool,
                        lp-no-pool: final-no-pool,
                        bet-no-pool: (- (get bet-no-pool market) final-stx-out),
                        total-no-tokens: (- (get total-no-tokens market) no-amount)
                    }))

                    (map-set user-positions
                        { market-id: market-id, user: caller }
                        {
                            yes-stx: (get yes-stx user-position),
                            no-stx: (get no-stx user-position),
                            yes-tokens: (get yes-tokens user-position),
                            no-tokens: (- (get no-tokens user-position) no-amount)
                        })

                    (match (as-contract (stx-transfer? final-stx-out tx-sender caller))
                        success (ok final-stx-out)
                        error ERR-TRANSFER-FAILED)
                    )))))




(define-public (resolve-market (market-id uint) (outcome bool))
  (let
    (
      (market (unwrap! (map-get? markets market-id) ERR-MARKET-NOT-FOUND))
    )
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED)
    (asserts! (not (get resolved market)) ERR-MARKET-RESOLVED)

    (let
       (
    (total-yes-tokens (get total-yes-tokens market))
    (total-no-tokens (get total-no-tokens market))
    (winning-tokens (if outcome total-yes-tokens total-no-tokens))
       )
        (map-set markets market-id (merge market {
    resolved: true,
    outcome: (some outcome),
    total-winning-tokens: winning-tokens
         }))

      (print {
        event: "market-resolved-debug",
        market-id: market-id,
        outcome: outcome,
        total-yes-tokens: total-yes-tokens,
        total-no-tokens: total-no-tokens,
        winning-tokens: winning-tokens,
        lp-yes-pool: (get lp-yes-pool market),
        lp-no-pool: (get lp-no-pool market)
      })
      (ok true)
    )
  )
)

(define-public (claim-winnings (market-id uint))
 (let
   (
     (market (unwrap! (map-get? markets market-id) ERR-MARKET-NOT-FOUND))
     (user-position (unwrap! (map-get? user-positions { market-id: market-id, user: tx-sender }) ERR-NO-POSITION))
   )
   (asserts! (get resolved market) ERR-MARKET-NOT-RESOLVED)
   (asserts! (is-some (get outcome market)) ERR-NO-OUTCOME)
   (let
     (
       (outcome (unwrap! (get outcome market) ERR-NO-OUTCOME))
       (total-betting-pool (+ (get bet-yes-pool market) (get bet-no-pool market)))
       (total-winning-tokens (if outcome 
                                 (get total-yes-tokens market) 
                                 (get total-no-tokens market)))
       (user-winning-tokens (if outcome 
                                (get yes-tokens user-position) 
                                (get no-tokens user-position)))
       (caller tx-sender)
     )
     (asserts! (> user-winning-tokens u0) ERR-NO-WINNINGS)
     (let
       (
         (user-share (/ (* user-winning-tokens PRECISION) total-winning-tokens))
         (total-winnings (/ (* user-share total-betting-pool) PRECISION))
         (network-amount (/ total-winnings u100))
         (user-amount (- total-winnings network-amount))
       )
       (map-delete user-positions { market-id: market-id, user: tx-sender })

       (print {
         event: "claim-winnings-debug",
         market-id: market-id,
         user: caller,
         user-winning-tokens: user-winning-tokens,
         total-winning-tokens: total-winning-tokens,
         total-betting-pool: total-betting-pool,
         user-share: user-share,
         total-winnings: total-winnings,
         network-amount: network-amount,
         user-amount: user-amount
       })

       (try! (as-contract (stx-transfer? network-amount tx-sender (var-get contract-owner))))
       
       (match (as-contract (stx-transfer? user-amount tx-sender caller))
         success (ok user-amount)
         error ERR-TRANSFER-FAILED
       )
     )
   )
 )
)

(define-public (claim-lp-winnings (market-id uint))
  (let
    (
      (market (unwrap! (map-get? markets market-id) ERR-MARKET-NOT-FOUND))
      (caller tx-sender)
      (lp-tokens (unwrap! (map-get? lp-positions { market-id: market-id, user: caller }) ERR-NO-POSITION))
    )
    (asserts! (get resolved market) ERR-MARKET-NOT-RESOLVED)
    (asserts! (> lp-tokens u0) ERR-NO-WINNINGS)

    (let
      (
        (total-lp-tokens (get total-lp-tokens market))
        (lp-yes-pool (get lp-yes-pool market))
        (lp-no-pool (get lp-no-pool market))
        (bet-yes-pool (get bet-yes-pool market))
        (bet-no-pool (get bet-no-pool market))
        (removal-ratio (/ (* lp-tokens PRECISION) total-lp-tokens))
        (yes-to-remove (/ (* lp-yes-pool removal-ratio) PRECISION))
        (no-to-remove (/ (* lp-no-pool removal-ratio) PRECISION))
        (calculated-stx-transfer (+ yes-to-remove no-to-remove))
        (contract-balance (stx-get-balance (as-contract tx-sender)))
        ;; Use if instead of min
        (safe-stx-transfer (if (> calculated-stx-transfer contract-balance)
                              contract-balance
                              calculated-stx-transfer))
        (new-total-lp-tokens (- total-lp-tokens lp-tokens))
        (new-lp-yes-pool (- lp-yes-pool yes-to-remove))
        (new-lp-no-pool (- lp-no-pool no-to-remove))
      )
      (print {
        event: "lp-winnings-debug",
        market-id: market-id,
        user: caller,
        lp-tokens: lp-tokens,
        total-lp-tokens: total-lp-tokens,
        lp-yes-pool: lp-yes-pool,
        lp-no-pool: lp-no-pool,
        bet-yes-pool: bet-yes-pool,
        bet-no-pool: bet-no-pool,
        removal-ratio: removal-ratio,
        yes-to-remove: yes-to-remove,
        no-to-remove: no-to-remove,
        calculated-stx-transfer: calculated-stx-transfer,
        safe-stx-transfer: safe-stx-transfer
      })

      ;; Update market state
      (map-set markets market-id (merge market {
        lp-yes-pool: new-lp-yes-pool,
        lp-no-pool: new-lp-no-pool,
        total-lp-tokens: new-total-lp-tokens
      }))

      ;; Update LP's position
      (map-set lp-positions { market-id: market-id, user: caller } u0)

      (print { 
        event: "contract-balance-before-transfer",
        balance: contract-balance
      })

      ;; Transfer LP's share to the caller using safe amount
      (match (as-contract (stx-transfer? safe-stx-transfer tx-sender caller))
        success
          (begin
            (print {
              event: "lp-winnings-claimed",
              market-id: market-id,
              user: caller,
              new-lp-yes-pool: new-lp-yes-pool,
              new-lp-no-pool: new-lp-no-pool,
              new-total-lp-tokens: new-total-lp-tokens,
              stx-transferred: safe-stx-transfer
            })
            (ok safe-stx-transfer)
          )
        error ERR-TRANSFER-FAILED
      )
    )
  )
)

;; Read-only functions remain mostly unchanged
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
    (ok { yes-stx: u0, no-stx: u0, yes-tokens: u0, no-tokens: u0 })
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
        (
          (user-lp-tokens (default-to u0
                           (map-get? lp-positions { market-id: market-id, user: user })))
          (total-lp-tokens (get total-lp-tokens market))
          (total-liquidity (+ (get lp-yes-pool market) (get lp-no-pool market)))
        )

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
      lp-yes-pool: (get lp-yes-pool market),
      lp-no-pool: (get lp-no-pool market),
      bet-yes-pool: (get bet-yes-pool market),
      bet-no-pool: (get bet-no-pool market),
      total-liquidity: (+ (get lp-yes-pool market) (get lp-no-pool market)),
      total-lp-tokens: (get total-lp-tokens market),
      k: (calculate-k market-id)
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

(define-read-only (get-contract-balance)
  (stx-get-balance (as-contract tx-sender))
)

(define-read-only (get-user-liquidity-position (market-id uint) (user principal))
  (match (map-get? lp-positions { market-id: market-id, user: user })
    position (ok position)
    (err ERR-NO-POSITION)
  )
)
(define-read-only (get-current-price (market-id uint))
  (let
    (
      (market (unwrap! (map-get? markets market-id) ERR-MARKET-NOT-FOUND))
      (lp-yes-pool (get lp-yes-pool market))
      (lp-no-pool (get lp-no-pool market))
    )
    (ok (/ (* lp-yes-pool u1000000) (+ lp-yes-pool lp-no-pool)))  ;; Price in parts per million
  )
)
(define-read-only (estimate-swap-stx-to-yes (market-id uint) (stx-amount uint))
  (let
    (
      (market (unwrap! (map-get? markets market-id) ERR-MARKET-NOT-FOUND))
      (lp-yes-pool (get lp-yes-pool market))
      (lp-no-pool (get lp-no-pool market))
      (fee-numerator (get fee-numerator market))
      (fee-denominator u10000)
      (fee-amount (/ (* stx-amount fee-numerator) fee-denominator))
      (amount-in (- stx-amount fee-amount))
      (numerator (* amount-in lp-no-pool))
      (denominator (+ lp-yes-pool amount-in))
    )
    (ok (/ numerator denominator))
  )
)

(define-read-only (is-valid-active-market (market-id uint))
  (match (map-get? markets market-id)
    market (and (not (get resolved market)) (is-some (get outcome market)))
    false
  )
)



(define-read-only (calculate-k (market-id uint))
  (match (map-get? markets market-id)
    market 
      (ok (* (get lp-yes-pool market) (get lp-no-pool market)))
    ERR-MARKET-NOT-FOUND
  )
)