
;; @title Bonding Curve DEX by STX.CITY
;; @notice This decentralized exchange (DEX) facilitates the trading of tokens using a bonding curve mechanism.
;; @dev This DEX will receive token from another contract and allow users to buy or sell this token.
;; @dev Once the target STX amount is reached, the contract automatically sends the tokens and STX to the DEX addresses like Velar.
;; @dev The deployer has no ownership privileges or control over the contract's operations.
;; @version 2.0

(use-trait sip-010-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait) 
;; error constants
(define-constant ERR-UNAUTHORIZED (err u401))
(define-constant ERR-UNAUTHORIZED-TOKEN (err u402))
(define-constant ERR-TRADING-DISABLED (err u1001))
(define-constant DEX-HAS-NOT-ENOUGH-STX (err u1002))
(define-constant ERR-NOT-ENOUGH-STX-BALANCE (err u1003))
(define-constant ERR-NOT-ENOUGH-TOKEN-BALANCE (err u1004))
(define-constant BUY-INFO-ERROR (err u2001))
(define-constant SELL-INFO-ERROR (err u2002))

(define-constant token-supply u1000000000000000) ;; match with the token's supply (6 decimals)
(define-constant BONDING-DEX-ADDRESS (as-contract tx-sender)) ;; one contract per token

;; bonding curve config
(define-constant STX_TARGET_AMOUNT u2000000000)
(define-constant VIRTUAL_STX_VALUE u400000000) ;; 1/5 of STX_TARGET_AMOUNT
(define-constant COMPLETE_FEE u40000000) ;; 2% of STX_TARGET_AMOUNT

;; FEE AND DEX WALLETS
(define-constant STX_CITY_SWAP_FEE_WALLET 'SP1WRH525WGKZJDCY8FSYASWVNVYB62580QNARMXP)
(define-constant STX_CITY_COMPLETE_FEE_WALLET 'SP1JYZFESCWMGPWQR4BJTDZRXTHTXXYFEVJECNTY7)
(define-constant AMM_WALLET 'SP2BN9JN4WEG02QYVX5Y21VMB2JWV3W0KNHPH9R4P)
(define-constant BURN_ADDRESS 'SP000000000000000000002Q6VF78) ;; burn mainnet

(define-constant deployer tx-sender)
(define-constant allow-token 'SP2EFJTN3BG3TH785NTV66VQS58XCNKQY1M5BAZ2S.trumps-ai-guard-dog-circuit-stxcity)

;; data vars
(define-data-var tradable bool false)
(define-data-var virtual-stx-amount uint u0)
(define-data-var token-balance uint u0)
(define-data-var stx-balance uint u0)
(define-data-var burn-percent uint u10)
(define-data-var deployer-percent uint u10)

(define-public (buy (token-trait <sip-010-trait>) (stx-amount uint) ) 
  (begin
    (asserts! (var-get tradable) ERR-TRADING-DISABLED)
    (asserts! (> stx-amount u0) ERR-NOT-ENOUGH-STX-BALANCE)
    (asserts! (is-eq allow-token (contract-of token-trait)) ERR-UNAUTHORIZED-TOKEN )
    (let (
      (buy-info (unwrap! (get-buyable-tokens stx-amount) BUY-INFO-ERROR))
      (stx-fee (get fee buy-info))
      (stx-after-fee (get stx-buy buy-info))
      (tokens-out (get buyable-token buy-info))
      (new-token-balance (get new-token-balance buy-info))
      (recipient tx-sender)
      (new-stx-balance (+ (var-get stx-balance) stx-after-fee))
      
    )
      ;; user send stx fee to stxcity
      (try! (stx-transfer? stx-fee tx-sender STX_CITY_SWAP_FEE_WALLET))
      ;; user send stx to dex
      (try! (stx-transfer? stx-after-fee tx-sender (as-contract tx-sender)))
      ;; dex send token to user
      (try! (as-contract (contract-call? token-trait transfer tokens-out tx-sender recipient none)))
      (var-set stx-balance new-stx-balance )
      (var-set token-balance new-token-balance)
      (if (>= new-stx-balance  STX_TARGET_AMOUNT)
        (begin
          (let (
            (contract-token-balance (var-get token-balance))
            (burn-percent-val (var-get burn-percent) )
            (burn-amount (/ (* contract-token-balance burn-percent-val) u100)) ;; burn tokens for a deflationary boost after the bonding curve completed
            (remain-tokens (- contract-token-balance burn-amount))
            (remain-stx (- (var-get stx-balance) COMPLETE_FEE))
            (deployer-amount (/ (* burn-amount (var-get deployer-percent)) u100)) ;; deployer-amount is based on the burn amount
            (burn-after-deployer-amount (- burn-amount deployer-amount))
          )
            ;; burn tokens
            (try! (as-contract (contract-call? token-trait transfer burn-after-deployer-amount tx-sender BURN_ADDRESS none)))
            ;; send to deployer
            (try! (as-contract (contract-call? token-trait transfer deployer-amount tx-sender deployer none)))
            ;; send to AMM's address
            (try! (as-contract (contract-call? token-trait transfer remain-tokens tx-sender AMM_WALLET none)))
            (try! (as-contract (stx-transfer? remain-stx tx-sender AMM_WALLET)))
            ;; send fee
            (try! (as-contract (stx-transfer? COMPLETE_FEE tx-sender STX_CITY_COMPLETE_FEE_WALLET)))
            ;; update global variables
            (var-set tradable false)
            (var-set stx-balance u0)
            (var-set token-balance u0) 
            (print {tokens-receive: tokens-out, stx-fee: stx-fee, final-fee: COMPLETE_FEE, tokens-burn: burn-amount, tokens-to-dex: remain-tokens, stx-to-dex: remain-stx,
                current-stx-balance: (var-get stx-balance), token-balance: (var-get token-balance), tradable: (var-get tradable) })    
            (ok tokens-out)
          )
        )
        (begin 
          (print {tokens-receive: tokens-out, stx-fee: stx-fee, current-stx-balance: (var-get stx-balance), token-balance: (var-get token-balance), tradable: (var-get tradable) })  
          (ok tokens-out)
        )
      )
    )
  )
)
(define-public (sell (token-trait <sip-010-trait>) (tokens-in uint) ) ;; swap out for virtual trading
  (begin
    (asserts! (var-get tradable) ERR-TRADING-DISABLED)
    (asserts! (> tokens-in u0) ERR-NOT-ENOUGH-TOKEN-BALANCE)
    (asserts! (is-eq allow-token (contract-of token-trait)) ERR-UNAUTHORIZED-TOKEN )
    (let (
      (sell-info (unwrap! (get-sellable-stx tokens-in) SELL-INFO-ERROR))
      (stx-fee (get fee sell-info))
      (stx-receive (get stx-receive sell-info))
      (current-stx-balance (get current-stx-balance sell-info))
      (stx-out (get stx-out sell-info))
      (new-token-balance (get new-token-balance sell-info))
      (recipient tx-sender)
    )
      (asserts! (>= current-stx-balance stx-receive) DEX-HAS-NOT-ENOUGH-STX)
      (asserts! (is-eq contract-caller recipient) ERR-UNAUTHORIZED)
      ;; user send token to dex
      (try! (contract-call? token-trait transfer tokens-in tx-sender BONDING-DEX-ADDRESS none))
      ;; dex transfer stx to user and stxcity
      (try! (as-contract (stx-transfer? stx-receive tx-sender recipient)))
      (try! (as-contract (stx-transfer? stx-fee tx-sender STX_CITY_SWAP_FEE_WALLET)))
      ;; update global variable
      (var-set stx-balance (- (var-get stx-balance) stx-out))
      (var-set token-balance new-token-balance)
      (print {stx-receive: stx-receive, stx-fee: stx-fee, current-stx-balance: (var-get stx-balance), token-balance: (var-get token-balance), tradable: (var-get tradable) })
      (ok stx-receive)
    )
  )
)
;; stx -> token. Estimate the number of token you can receive with a stx amount
(define-read-only (get-buyable-tokens (stx-amount uint)) 
  (let 
      (
      (current-stx-balance (+ (var-get stx-balance) (var-get virtual-stx-amount)))
      (current-token-balance (var-get token-balance))
      (stx-fee (/ (* stx-amount u2) u100)) ;; 2% fee
      (stx-after-fee (- stx-amount stx-fee))
      (k (* current-token-balance current-stx-balance )) ;; k = x*y 
      (new-stx-balance (+ current-stx-balance stx-after-fee)) 
      (new-token-balance (/ k new-stx-balance)) ;; x' = k / y'
      (tokens-out (- current-token-balance new-token-balance))
      (recommend-stx-amount (- STX_TARGET_AMOUNT (var-get stx-balance) ))
      (recommend-stx-amount-after-fee (/ (* recommend-stx-amount u103) u100)) ;; 3% (including 2% fee)
  )
   (ok  {fee: stx-fee, buyable-token: tokens-out, stx-buy: stx-after-fee, 
        new-token-balance: new-token-balance, stx-balance: (var-get stx-balance), 
      recommend-stx-amount: recommend-stx-amount-after-fee, token-balance: (var-get token-balance) } ) ))  

;; token -> stx. Estimate the number of stx you can receive with a token amount
(define-read-only (get-sellable-stx (token-amount uint)) 
  (let 
      (
      (tokens-in token-amount)
      (current-stx-balance (+ (var-get stx-balance) (var-get virtual-stx-amount)))
      (current-token-balance (var-get token-balance))
      (k (* current-token-balance current-stx-balance )) ;; k = x*y 
      (new-token-balance (+ current-token-balance tokens-in))
      (new-stx-balance (/ k new-token-balance)) ;; y' = k / x'
      (stx-out (- (- current-stx-balance new-stx-balance) u1)) ;; prevent the round number
      (stx-fee (/ (* stx-out u2) u100)) ;; 2% fee
      (stx-receive (- stx-out stx-fee))
  )
   (ok  {fee: stx-fee, 
        current-stx-balance: current-stx-balance,
        receivable-stx: stx-receive, 
        stx-receive: stx-receive,
        new-token-balance: new-token-balance, 
        stx-out: stx-out,
        stx-balance: (var-get stx-balance), 
        token-balance: (var-get token-balance) } ) ))  

(define-read-only (get-tradable) 
  (ok (var-get tradable))
)

;; initialize contract based on token's details
(begin
  (var-set virtual-stx-amount VIRTUAL_STX_VALUE)
  
    (var-set token-balance u900090009000900)
    (var-set stx-balance u44400000)
  (var-set tradable true)
  (var-set burn-percent u20)
  (var-set deployer-percent u10) ;; based on the burn-amount. It's about ~0.1 to 0.5% supply
  (try! (stx-transfer? u1000000 tx-sender 'SP1WG62TA0D3K980WGSTZ0QA071TZD4ZXNKP0FQZ7))
  (ok true)
)
