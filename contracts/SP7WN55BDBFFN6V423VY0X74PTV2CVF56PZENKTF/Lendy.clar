
(use-trait nft-tokens 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)




(define-constant CONTRACT_OWNER 'SP7WN55BDBFFN6V423VY0X74PTV2CVF56PZENKTF)



;; Price feed ID
(define-constant BTC-USD-FEED-ID 0xe62df6c8b4a85fe1a67db44dc12de5db330f7ac66b72dc658afedf0f4a415b43)

;; ERROR
(define-constant ERR_INVALID_WITHDRAW_AMOUNT (err u100))
(define-constant ERR_EXCEED_MAX_BORROW_AMOUNT (err u101))
(define-constant ERR_CANNOT_BE_LIQUIDITED (err u102))
(define-constant ERR_ZERO_AMOUNT_NOT_ALLOWED (err u104))
(define-constant ERR_ONLY_OWNER_CAN_COLLECT_FEE (err u105))
(define-constant ERR_REPAY_AMOUNT_IS_BELLOW_BORROWED_AMOUNT (err u106))
(define-constant ERR_NO_FEES_TO_COLLECT (err u107))
(define-constant ERR_NOT_ADMIN (err u108))
(define-constant ERR_INSUFFICIENT_BALANCE (err u109))




;; Constants
(define-constant LVT_PERCENTAGE u50)
(define-constant INTEREST_RATE_PERCENTAGE u20)
(define-constant LIQUIDATION_THRESHOLD_PERCENTAGE u90)
(define-constant ONE_YEAR_IN_SECONDS u31556952)
(define-constant PROTOCOL_FEE_PERCENTAGE u5) ;; 5% protocol fee


;; Storage 

;; Total sBTC collateral for lending 
(define-data-var total-sbtc-collateral uint u0)


;; Total STX that the lenders have deposited 
(define-data-var total-stx-deposit uint u0)

;;Total STX that the borrowers have borrowed 
(define-data-var total-stx-borrowed uint u0)

;; Last time interest was accrued 
(define-data-var last-interest-accrual uint (get-latest-timestamps))

;; Protocol fee 
(define-data-var protocol-fee uint u0)

;; Cumlative interest earned  
(define-data-var cumulative-interest-yield uint u0)


;; Mapping of users pricipals to their collateral 

(define-map collateral 
  {user: principal}
  {amount: uint}
)

;; map of users pricipal to the amount of sbtc to deposited 

(define-map deposits 
  {user: principal}
  {amount: uint, yield: uint,}
 )



 ;; map of users pricipal to the amount of stx to borrowed 
 (define-map borrows 
  {user: principal}
  {amount: uint, last-accrual: uint,}
 )

 ;; map the protocol fee to the protocl contract address

 (define-map fees
  {protocol-contract: principal}
  {amount: uint}
 )



 



;; The deposit function handles the deposit of STX into the lending pool 
;; @param amount of STX to be deposited tnto the lending pool 
;; @return ok if the deposit is successful, err if the deposit is not successful
(define-public (deposit  (deposit-nft <nft-tokens>) (amount uint))
  (let (
   
    (user-deposit (map-get? deposits {user: tx-sender}))
    (existing-amount (default-to u0 (get amount user-deposit)))
  )
    (asserts! (not (is-eq amount u0)) ERR_ZERO_AMOUNT_NOT_ALLOWED)
    
    ;; Calculate interest before deposit
    (unwrap-panic (calculate-interest))
    
    ;; Transfer STX to contract
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
    
    ;; Update user's deposit (allow multiple deposits)
    (map-set deposits {user: tx-sender} {
      amount: (+ existing-amount amount), 
      yield: (var-get cumulative-interest-yield)
    })

    ;; Update total deposits
    (var-set total-stx-deposit (+ (var-get total-stx-deposit) amount))

     ;; Mint the Nft to the user 
     (try! (contract-call? 'SP7WN55BDBFFN6V423VY0X74PTV2CVF56PZENKTF.Lendo_NFT mint tx-sender))

    (ok true)


  )
)


;; The withdraw function handles the withdrawal of STX from the lending pool 
;; @param amount of STX to be withdrawn from the lending pool 
;;@return ok if the withdrawal is successful, err if the withdrawal is not successful 

(define-public (withdraw  (withdraw-nft <nft-tokens>) (amount uint))
(let (
    (user tx-sender)
    (user-deposit (map-get? deposits {user: user}))
    (existing-amount (default-to u0 (get amount user-deposit)))
    (yield-index (default-to u0 (get yield user-deposit)))
    (pending-yield (unwrap-panic (get-all-pending-yields)))
)

    (asserts! (>= existing-amount amount) ERR_INVALID_WITHDRAW_AMOUNT)
     (asserts! (not (is-eq amount u0)) ERR_ZERO_AMOUNT_NOT_ALLOWED)

     ;; get the interest accumulated 
     (unwrap-panic (calculate-interest))

     ;; update the user's deposit map
     (map-set deposits {user: user} {
        amount: (- existing-amount amount),
        yield: (var-get cumulative-interest-yield),
     })

     ;; update the total deposits
     (var-set total-stx-deposit (- (var-get total-stx-deposit) amount))

     ;; transfer the stx to the user
     (try! (as-contract (stx-transfer? (+ amount pending-yield) tx-sender user)))

     ;; mint the withdraw nft to the users 
     (try! (contract-call? 'SP7WN55BDBFFN6V423VY0X74PTV2CVF56PZENKTF.Lendx_NFT mint user))

     (ok true)

)

)


;; User's could borrow STX from the lending pool for as long as they have deposited sBTC as collateral 
;; Therefore , the process of borrowing the borrower will be minted an NFT represting that the borrower has borrowed 
;; @param stx-amount of STX to be borrowed from the lending pool 
;; @param sbtc-amount of sBTC to be deposited as collateral 
;; @return ok if the borrow is successful, err if the borrow is not successful 

(define-public (borrow (borrow-nft <nft-tokens>) (stx-amount uint) (sbtc-amount uint) (price-feed-bytes (buff 8192)))
  (let (
    (user tx-sender)
    (user-collateral (map-get? collateral {user: user}))
    (deposited-sbtc-amount (default-to u0 (get amount user-collateral)))
    (new-collateral-amount (+ deposited-sbtc-amount sbtc-amount))
     (price-data (unwrap-panic (get-sbtc-stx-price price-feed-bytes)))
     (exponent (get expo price-data))
     (denominator (pow u10 (to-uint (* exponent -1))))
     (price (/ (to-uint (get price price-data)) denominator))
     (max-borrow-amount ( / (* (* new-collateral-amount price ) LVT_PERCENTAGE ) u100))

    (user-borrow-amount (map-get? borrows {user: user}))
    (borrowed-stx-amount (default-to u0 (get amount user-borrow-amount)))
    (new-debt (+ borrowed-stx-amount stx-amount))
    

  ) 
    (asserts! (<= new-debt max-borrow-amount) ERR_EXCEED_MAX_BORROW_AMOUNT)
    (asserts! (<= stx-amount max-borrow-amount) ERR_EXCEED_MAX_BORROW_AMOUNT)
    (asserts! (not (is-eq stx-amount u0)) ERR_ZERO_AMOUNT_NOT_ALLOWED)
    (asserts! (not (is-eq sbtc-amount u0)) ERR_ZERO_AMOUNT_NOT_ALLOWED)
    
    ;; interest accrual 
    (unwrap-panic (calculate-interest))

    ;; update the user's borrow map
    ( map-set borrows {user: user} {
        amount: new-debt,
        last-accrual: (get-latest-timestamps)
    } )

    ;; update the total borrowed amount
    (var-set total-stx-borrowed (+ (var-get total-stx-borrowed) stx-amount))

    ;;update the collateral map
    (map-set collateral {user: user} {
        amount: new-collateral-amount
    })

    ;; set the total sbtc collateral
    (var-set total-sbtc-collateral (+ (var-get total-sbtc-collateral) sbtc-amount))
   
     ;; tranfer the sbtc collateral into the contract 

     (try! (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token transfer 
            sbtc-amount tx-sender (as-contract tx-sender) 
            none
              ))

      (try! (as-contract (stx-transfer? stx-amount tx-sender user)))

      ;; mint the borrow nft to the user
      (try! (contract-call? 'SP7WN55BDBFFN6V423VY0X74PTV2CVF56PZENKTF.LenBo_NFT mint user))

      (ok true)
  
  )
)


;; Repays the loan to the lender
;; @returns ok if the repayment is successful, err if the repayment is not successful
(define-public (repay (repay-nft <nft-tokens>))
   (let (
      (user-borrow (map-get? borrows {user: tx-sender}))
      (borrowed-stx-amount (default-to u0 (get amount user-borrow)))
      (total-debt  (unwrap-panic (get-user-debt tx-sender)))
      (user-collateral (map-get? collateral {user: tx-sender}))
      (deposited-sbtc (default-to u0 (get amount user-collateral)))
      (user-stx-balance (stx-get-balance tx-sender))
   )
     ;; Check if user has sufficient STX balance to repay the loan
     (asserts! (>= user-stx-balance total-debt) ERR_INSUFFICIENT_BALANCE)
     
     (asserts! (>= total-debt borrowed-stx-amount) ERR_REPAY_AMOUNT_IS_BELLOW_BORROWED_AMOUNT)
     
     ;; interest accrual
     (unwrap-panic (calculate-interest))

     (map-delete collateral {user: tx-sender})

     (var-set total-sbtc-collateral (- (var-get total-sbtc-collateral) deposited-sbtc))

     (map-delete borrows {user: tx-sender})

     (var-set total-stx-borrowed (- (var-get total-stx-borrowed) borrowed-stx-amount))

     (try! (stx-transfer? total-debt tx-sender (as-contract tx-sender)))

     (try! (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token transfer deposited-sbtc (as-contract tx-sender) tx-sender none))


      (try! (contract-call? 'SP7WN55BDBFFN6V423VY0X74PTV2CVF56PZENKTF.Lendy_NFT mint tx-sender))

      (ok true)

   )
)



;; Liquidation a borrower if their collateral is below the liquidation threshold
;; @Param user: The user to liquidate
;; @return ok if the liquidation is successful, err if the liquidation is not successful
(define-public (Liquidate (liquidate-nft <nft-tokens>) (user principal) (price-feed-bytes (buff 8192)))
    (let (
        (user-debt (unwrap-panic (get-user-debt user)))
        (forfeited-borrows ( if (> user-debt (var-get total-stx-borrowed))
          (var-get total-stx-borrowed)
           user-debt
        ))
        (user-collateral (map-get? collateral {user: user}))
        (deposited-sbtc (default-to u0 (get amount user-collateral)))
        (price-data (unwrap-panic (get-sbtc-stx-price price-feed-bytes)))
        (exponent (get expo price-data))
        (denominator (pow u10 (to-uint (* exponent -1))))
        (price (/ (to-uint (get price price-data)) denominator))
        
        (collateral-value-in-stx (* deposited-sbtc price))
        (liquidation-threshold ( / ( * deposited-sbtc u10) u100))
        (pool-reward (- deposited-sbtc liquidation-threshold))
        (sbtc-balance (unwrap-panic (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token get-balance (as-contract user))))

       

        (xyk-tokens {
            a: 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token,  
            b: 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.token-stx-v-1-2,
        })
        (xyk-pool {a: 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-pool-sbtc-stx-v-1-1}) 

    )
      (unwrap-panic (calculate-interest))

      (asserts! (>= user-debt u0 ) ERR_CANNOT_BE_LIQUIDITED)

      (asserts! (<= (* collateral-value-in-stx u100)
         (* user-debt LIQUIDATION_THRESHOLD_PERCENTAGE)
         ) ERR_CANNOT_BE_LIQUIDITED)

         (var-set total-sbtc-collateral (- (var-get total-sbtc-collateral) deposited-sbtc))

         (var-set total-stx-borrowed (- (var-get total-stx-borrowed) forfeited-borrows))

         (map-delete collateral {user: user})

         (map-delete borrows {user: user})


         (try! (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token transfer (+ pool-reward liquidation-threshold) (as-contract tx-sender) tx-sender  none))

  

    

         (let ((received-stx (try! (contract-call?
        'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-swap-helper-v-1-3
        swap-helper-a pool-reward u0 none xyk-tokens xyk-pool
      ))))


         (try! (stx-transfer? received-stx tx-sender (as-contract tx-sender)))

         (var-set cumulative-interest-yield
         (+ (var-get cumulative-interest-yield)
          (/ (* (- received-stx forfeited-borrows) u10000)
          (var-get total-stx-deposit)
          
          ) )
         )

         (let ((lenBo-token-id (unwrap-panic (contract-call? 'SP7WN55BDBFFN6V423VY0X74PTV2CVF56PZENKTF.LenBo_NFT get-last-token-id)))
               (lendo-token-id (unwrap-panic (contract-call? 'SP7WN55BDBFFN6V423VY0X74PTV2CVF56PZENKTF.Lendo_NFT get-last-token-id))))

       ;; burn the borrow nft to the user
        (try! (contract-call? 'SP7WN55BDBFFN6V423VY0X74PTV2CVF56PZENKTF.LenBo_NFT burn lenBo-token-id))
        ;; burn the borrow nft to the user
      (try! (contract-call? 'SP7WN55BDBFFN6V423VY0X74PTV2CVF56PZENKTF.Lendo_NFT burn lendo-token-id))
    
         (ok true)
    )
    )
)
)


  ;; get the price of the sbtc in stx from the pyth oracle
  ;; @return response uint

  (define-public (get-sbtc-stx-price (price-feed-bytes (buff 8192)))
    (let (
  ;; Update the price feed with fresh data 

  (update-result (try! (contract-call? 'SP3R4F6C1J3JQWWCVZ3S7FRRYPMYG6ZW6RZK31FXY.pyth-oracle-v3
  
     verify-and-update-price-feeds price-feed-bytes {
       pyth-storage-contract: 'SP3R4F6C1J3JQWWCVZ3S7FRRYPMYG6ZW6RZK31FXY.pyth-storage-v3,
       pyth-decoder-contract: 'SP3R4F6C1J3JQWWCVZ3S7FRRYPMYG6ZW6RZK31FXY.pyth-pnau-decoder-v2,
       wormhole-core-contract: 'SP3R4F6C1J3JQWWCVZ3S7FRRYPMYG6ZW6RZK31FXY.wormhole-core-v3
     })))

     ;; read the updated price 
     (price-data (try! (contract-call? 'SP3R4F6C1J3JQWWCVZ3S7FRRYPMYG6ZW6RZK31FXY.pyth-oracle-v3
       get-price
       0xe62df6c8b4a85fe1a67db44dc12de5db330f7ac66b72dc658afedf0f4a415b43
       'SP3R4F6C1J3JQWWCVZ3S7FRRYPMYG6ZW6RZK31FXY.pyth-storage-v3
     
     )))
  
  
    )
    (ok price-data)
  ))



  (define-read-only (process-price-data (price-data {
    price-identifier: (buff 32),
    price: int,
    conf: uint,
    expo: int,
    ema-price: int,
    ema-conf: uint,
    publish-time: uint,
    prev-publish-time: uint
  }))
  
   (let (

    (exponent (get expo price-data ))
    (denominator (pow u10 (to-uint (* exponent -1))))

    (adjusted-price (/ (to-uint (get price price-data)) denominator))

   )
   adjusted-price
   ))


   (define-read-only (get-all-pending-yields)
    (let (
        (user-deposit (map-get? deposits {user: tx-sender}))
        (yield-index (default-to u0 (get yield user-deposit)))
        (amount (default-to u0 (get amount user-deposit)))
        (delta-yield (- (var-get cumulative-interest-yield) yield-index))
        (pending-yield (/ (* amount delta-yield) u10000))
    )
    (ok pending-yield)
    
    )
   )



   (define-read-only (get-user-debt (user principal))
     (let (
        (user-borrow-amount (map-get? borrows {user: user}))
        (borrowed-stx-amount (default-to u0 (get amount user-borrow-amount)))
        (last-accrual (default-to u0 (get last-accrual user-borrow-amount)))
        (latest-timestamp (unwrap-panic (get-stacks-block-info? time (- stacks-block-height u1))))
        (time-elapsed (- latest-timestamp last-accrual))
        (interest-numerator (* borrowed-stx-amount time-elapsed INTEREST_RATE_PERCENTAGE))
        (interest-denominator (* ONE_YEAR_IN_SECONDS u100))
        (total-interest (/ interest-numerator interest-denominator))
        (user-debt (+ borrowed-stx-amount total-interest))
    )
    (ok user-debt)
   )
   )


 (define-read-only (get-contract-balance)
  (ok (stx-get-balance (as-contract tx-sender)))
  )
 


   


;; get the latest timestamp , this is exactly like the block.timestamp in solidity
;; @return timestamp uint
;; TODO test for time manupulations 
 (define-private (get-latest-timestamps)
  (unwrap-panic (get-stacks-block-info? time (- stacks-block-height u1)))
  )




;; The interest calculation for all lenders based on total boorrowed STX 
;; @return bool

(define-private (calculate-interest)
  (let (
    (time-elapsed (- (get-latest-timestamps) (var-get last-interest-accrual)))
    (borrowed-amount (var-get total-stx-borrowed))
    (deposited-amount (var-get total-stx-deposit))
    
    ;; Interest = (borrowed * time * rate) / (seconds_per_year * 100)
    (interest-numerator (* borrowed-amount time-elapsed INTEREST_RATE_PERCENTAGE))
    (interest-denominator (* ONE_YEAR_IN_SECONDS u100))
    (total-interest (/ interest-numerator interest-denominator))
    
    ;; Calculate protocol fee (5% of total interest)
    (protocol-fee-amount (calculate-protocol-fee total-interest))
    
    ;; Calculate net interest for lenders (95% of total interest)
    (net-interest (calculate-net-interest total-interest))
    
    ;; Yield per depositor = net_interest / total_deposits
    (new-yield (if (is-eq deposited-amount u0) 
                   u0 
                   (/ net-interest deposited-amount)))
  )
  
  (var-set last-interest-accrual (get-latest-timestamps))
  (var-set cumulative-interest-yield (+ (var-get cumulative-interest-yield) new-yield))
  (var-set total-stx-deposit (+ (var-get total-stx-deposit) net-interest))
  (update-protocol-fees protocol-fee-amount)
  (ok true)
))



;; Calculate protocol fee from interest earned
;; @param interest-amount: the total interest amount
;; @return protocol fee amount
(define-private (calculate-protocol-fee (interest-amount uint))
  (/ (* interest-amount PROTOCOL_FEE_PERCENTAGE) u100)
)

;; Calculate net interest after protocol fee
;; @param total-interest: the total interest amount
;; @return net interest for lenders
(define-private (calculate-net-interest (total-interest uint))
  (- total-interest (calculate-protocol-fee total-interest))
)

;; Update protocol fees
;; @param fee-amount: amount to add to protocol fees
(define-private (update-protocol-fees (fee-amount uint))
  (var-set protocol-fee (+ (var-get protocol-fee) fee-amount))
)


(define-private (is-owner)
 (is-eq tx-sender CONTRACT_OWNER)
)



;; Collect protocol fees - only owner can call this function
;; @return ok if successful, err if not owner or no fees to collect
(define-public (collect-protocol-fees)
  (let (
   
    (total-fees (var-get protocol-fee))
  )

    ;; Check if caller is the owner
    (asserts! (is-owner) ERR_ONLY_OWNER_CAN_COLLECT_FEE)
  

    ;; Check if there are fees to collect
    (asserts! (> total-fees u0) ERR_NO_FEES_TO_COLLECT)
    
    ;; Transfer fees to owner
    (try! (as-contract (stx-transfer? total-fees tx-sender CONTRACT_OWNER)))
    
    ;; Reset protocol fees to zero
    (var-set protocol-fee u0)
    
    (ok total-fees)
  )
)

