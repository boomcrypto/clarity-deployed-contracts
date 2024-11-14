;; Generic LP Token Arbitrage
;;
;; This contract arbitrages price discrepancies between any LP token market
;; and its underlying token components. On success, splits profits between:
;; 1. Contract deployer (configurable fee)
;; 2. CHA conversion (configurable reinvestment)
;; 3. Remaining profit to arbitrageur
;;
;; Key Features:
;; 1. Dual Trading Paths:
;;    - Forward: Buy LP -> Remove liquidity -> Sell Components
;;    - Reverse: Buy Components -> Add liquidity -> Sell LP
;;
;; 2. Profit Distribution:
;;    A. Deployer Fee:
;;       - Configurable from 1% to 50% of total profit
;;       - Paid in same token used for arbitrage
;;       - Default: 20% (2000 basis points)
;;    
;;    B. CHA Reinvestment:
;;       - Configurable from 1% to 50% of remaining profit
;;       - Converts portion to CHA automatically (via STX if needed)
;;       - Default: 50% of post-fee profit
;;    
;;    C. Arbitrageur Profit:
;;       - Receives remaining tokens after fees and reinvestment
;;
;; 3. Universal Token Support:
;;    - Works with any LP token market and base token
;;    - Uses same token for input and output to ensure accurate profit calculation
;;
;; Example Profit Split:
;; On 10 USDA profit with 20% fee and 50% reinvestment:
;; 1. Deployer receives: 2 USDA (20% fee)
;; 2. Arbitrageur receives: 4 USDA and X CHA (50% reinvestment)


;; Traits
(use-trait rulebook-trait .charisma-traits-v0.rulebook-trait)
(use-trait ft-trait .dao-traits-v4.sip010-ft-trait)
(use-trait ft-plus-trait .dao-traits-v4.ft-plus-trait)
(use-trait share-fee-to-trait .dao-traits-v4.share-fee-to-trait)

;; Constants
(define-constant DEPLOYER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u401))
(define-constant MIN_FEE_BPS u100)      ;; 1% minimum fee
(define-constant MAX_FEE_BPS u9000)     ;; 90% maximum fee
(define-constant MIN_REINVEST_BPS u100)  ;; 1% minimum reinvestment
(define-constant MAX_REINVEST_BPS u100000)  ;; 1000% maximum reinvestment

;; Variables
(define-data-var fee-bps uint u1000)      ;; Default 10% fee
(define-data-var reinvest-bps uint u9000) ;; Default 90% reinvestment

;; Admin Functions
(define-public (set-reinvestment-bps (rulebook <rulebook-trait>) (bps uint))
    (begin
        (try! (contract-call? rulebook is-owner tx-sender))
        (asserts! (>= bps MIN_REINVEST_BPS) ERR_UNAUTHORIZED)
        (asserts! (<= bps MAX_REINVEST_BPS) ERR_UNAUTHORIZED)
        (ok (var-set reinvest-bps bps))))

(define-public (set-fee-bps (rulebook <rulebook-trait>) (bps uint))
    (begin
        (try! (contract-call? rulebook is-owner tx-sender))
        (asserts! (>= bps MIN_FEE_BPS) ERR_UNAUTHORIZED)
        (asserts! (<= bps MAX_FEE_BPS) ERR_UNAUTHORIZED)
        (ok (var-set fee-bps bps))))

;; Helper Functions
(define-private (calculate-fee (profit uint))
    (/ (* profit (var-get fee-bps)) u10000))

(define-private (calculate-reinvestment (profit uint))
    (/ (* (- profit (calculate-fee profit)) (var-get reinvest-bps)) u10000))

;; Transfer fee to deployer
(define-private (pay-deployer-fee (base-token <ft-trait>) (profit uint))
    (contract-call? base-token transfer
        (calculate-fee profit)
        tx-sender
        DEPLOYER
        none))

;; Convert profits to CHA
(define-private (buy-cha (rulebook <rulebook-trait>) (amount uint) (base-token <ft-trait>) (share-fee-to <share-fee-to-trait>))
  (contract-call? .powered-swap-v0 do-token-swap 
    rulebook
    amount
    base-token
    .charisma-token 
    share-fee-to))

;; Forward Path (Buy LP -> Remove Liquidity -> Sell Components)
(define-public (try-forward-arbitrage 
    (rulebook <rulebook-trait>)
    (pool-id uint)
    (base-token <ft-trait>)
    (token0 <ft-trait>)
    (token1 <ft-trait>)
    (lp-token-buy <ft-trait>)
    (lp-token-burn <ft-plus-trait>)
    (input-amount uint)
    (share-fee-to <share-fee-to-trait>))
    (let (
        ;; Buy LP tokens with base-token
        (buy-lp (unwrap! 
            (contract-call? .powered-swap-v0 do-token-swap 
                rulebook
                input-amount
                base-token
                lp-token-buy
                share-fee-to) 
            (err "ARBITRAGE_FAILED")))
        
        ;; Remove liquidity
        (remove-lp (unwrap! 
            (contract-call? .univ2-core burn
                pool-id
                token0
                token1
                lp-token-burn
                (get amt-out buy-lp))
            (err "ARBITRAGE_FAILED")))

        ;; Sell token0 for base-token
        (sell-token0 (unwrap! 
            (contract-call? .powered-swap-v0 do-token-swap
                rulebook
                (get amt0 remove-lp)
                token0
                base-token
                share-fee-to)
            (err "ARBITRAGE_FAILED")))

        ;; Sell token1 for base-token
        (sell-token1 (unwrap! 
            (contract-call? .powered-swap-v0 do-token-swap
                rulebook
                (get amt1 remove-lp)
                token1
                base-token
                share-fee-to)
            (err "ARBITRAGE_FAILED")))
        
        ;; Calculate total received and profit in base-token
        (total-received (+ (get amt-out sell-token0) (get amt-out sell-token1)))
        (profit (- total-received input-amount)))
    (if (> total-received input-amount)
        (begin
            ;; Pay deployer fee in base-token
            (unwrap! (pay-deployer-fee base-token profit) (err "ARBITRAGE_FAILED"))
            ;; Convert to CHA (via STX if needed)
            (match (buy-cha 
                rulebook 
                (calculate-reinvestment profit)
                base-token
                share-fee-to)
                success (ok "ARBITRAGE_COMPLETE")
                error (err "ARBITRAGE_FAILED")))
        (err "NO_PROFIT_OPPORTUNITY"))))

;; Reverse Path (Buy Components -> Add Liquidity -> Sell LP)
(define-public (try-reverse-arbitrage 
    (rulebook <rulebook-trait>)
    (pool-id uint)
    (base-token <ft-trait>)
    (token0 <ft-trait>)
    (token1 <ft-trait>)
    (lp-token-mint <ft-plus-trait>)
    (lp-token-sell <ft-trait>)
    (input-amount uint)
    (share-fee-to <share-fee-to-trait>))
    (let (
        ;; Buy token0 with base-token
        (buy-token0 (unwrap! 
            (contract-call? .powered-swap-v0 do-token-swap
                rulebook
                (/ input-amount u2)
                base-token
                token0
                share-fee-to)
            (err "ARBITRAGE_FAILED")))

        ;; Buy token1 with base-token
        (buy-token1 (unwrap! 
            (contract-call? .powered-swap-v0 do-token-swap
                rulebook
                (/ input-amount u2)
                base-token
                token1
                share-fee-to)
            (err "ARBITRAGE_FAILED")))

        ;; Add liquidity
        (add-lp (unwrap! 
            (contract-call? .univ2-core mint
                pool-id
                token0
                token1
                lp-token-mint
                (get amt-out buy-token0)
                (get amt-out buy-token1))
            (err "ARBITRAGE_FAILED")))

        ;; Sell LP tokens for base-token
        (sell-lp (unwrap! 
            (contract-call? .powered-swap-v0 do-token-swap
                rulebook
                (get liquidity add-lp)
                lp-token-sell
                base-token
                share-fee-to)
            (err "ARBITRAGE_FAILED")))
            
        ;; Calculate profit in base-token
        (profit (- (get amt-out sell-lp) input-amount)))
    (if (> (get amt-out sell-lp) input-amount)
        (begin
            ;; Pay deployer fee in base-token
            (unwrap! (pay-deployer-fee base-token profit) (err "ARBITRAGE_FAILED"))
            ;; Convert to CHA (via STX if needed)
            (match (buy-cha 
                rulebook
                (calculate-reinvestment profit)
                base-token
                share-fee-to)
                success (ok "ARBITRAGE_COMPLETE")
                error (err "ARBITRAGE_FAILED")))
        (err "NO_PROFIT_OPPORTUNITY"))))

;; Read Functions
(define-read-only (get-profit-sharing-config)
    (ok {
        fee-bps: (var-get fee-bps),
        reinvest-bps: (var-get reinvest-bps),
        min-fee-bps: MIN_FEE_BPS,
        max-fee-bps: MAX_FEE_BPS,
        min-reinvest-bps: MIN_REINVEST_BPS,
        max-reinvest-bps: MAX_REINVEST_BPS
    }))

(define-read-only (calculate-profit-split (profit uint))
    (let (
        (fee (calculate-fee profit))
        (reinvestment (calculate-reinvestment profit)))
        (ok {
            total-profit: profit,
            deployer-fee: fee,
            cha-reinvestment: reinvestment,
            arbitrageur-remainder: (- (- profit fee) reinvestment)
        })))