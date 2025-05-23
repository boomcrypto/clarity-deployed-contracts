;; @title Bonding Curve DEX by STX.CITY
;; @notice This decentralized exchange (DEX) facilitates the trading of tokens using a bonding curve mechanism.
;; @dev This DEX will receive token from another contract and allow users to buy or sell this token.
;; @dev Once the target STX amount is reached, the contract automatically sends the tokens and STX to the DEX addresses like Velar.
;; @dev The deployer has no ownership privileges or control over the contract's operations.
;; @version 1.0

(use-trait sip-010-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait) 
;; error constants
(define-constant ERR-UNAUTHORIZED (err u401))
(define-constant ERR-UNAUTHORIZED-TOKEN (err u402))
(define-constant ERR-TRADING-DISABLED (err u1001))
(define-constant DEX-HAS-NOT-ENOUGH-STX (err u1002))
(define-constant ERR-NOT-ENOUGH-STX-BALANCE (err u1003))
(define-constant ERR-NOT-ENOUGH-TOKEN-BALANCE (err u1004))
(define-constant ERR-SELF-LISTING-FAIL (err u1005))
(define-constant BUY-INFO-ERROR (err u2001))
(define-constant SELL-INFO-ERROR (err u2002))
(define-constant ONE_8 u100000000)

(define-constant token-supply u69000000000000000) ;; match with the token's supply (6 decimals)
(define-constant BONDING-DEX-ADDRESS (as-contract tx-sender)) ;; one contract per token

;; ;; bonding curve config
(define-constant VIRTUAL_STX_VALUE u500000) ;; 0.5 stx
(define-constant STX_TARGET_AMOUNT u2000000) ;; 2 stx
(define-constant COMPLETE_FEE u20000) ;; 2%

;; FEE AND DEX WALLETS
(define-constant STX_CITY_SWAP_FEE_WALLET 'SPREJB8EY2CK2ZZR35P25TP9EYX2TKMBZS1PDS00)
(define-constant STX_CITY_COMPLETE_FEE_WALLET 'SP2BESX3AA24QH95JRYVQCED4K1TEZ1WAAH2EDH6X)

(define-constant BURN_ADDRESS 'SP000000000000000000002Q6VF78) ;; burn mainnet


(define-constant allow-token 'SPWECF3XYVRBRCN23CJJCX9XKSF8RFWQPAQMWXT.pepe)

;; (define-constant token-x 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2)

;; (define-constant alex-listing 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.self-listing-helper-v2-02)



;; data vars
(define-data-var tradable bool false)
(define-data-var virtual-stx-amount uint u0)
(define-data-var token-balance uint u0)
(define-data-var stx-balance uint u0)
(define-data-var burn-percent uint u10)

(define-public (buy (token-trait <sip-010-trait>) (stx-amount uint))
  (begin
    (asserts! (var-get tradable) ERR-TRADING-DISABLED)
    (asserts! (> stx-amount u0) ERR-NOT-ENOUGH-STX-BALANCE)
    (asserts! (is-eq allow-token (contract-of token-trait)) ERR-UNAUTHORIZED-TOKEN)
    
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
      (var-set stx-balance new-stx-balance)
      (var-set token-balance new-token-balance)
      (if (>= new-stx-balance STX_TARGET_AMOUNT)
        (let (
          (contract-token-balance (var-get token-balance))
          (burn-percent-val (var-get burn-percent))
          (burn-amount (/ (* contract-token-balance burn-percent-val) u100))
          (remain-tokens (- contract-token-balance burn-amount))
          (remain-stx (- (var-get stx-balance) COMPLETE_FEE))
          (remain-stx-alex-format (/ remain-stx ONE_8))
          (remain-tokens-alex-format (/ remain-tokens ONE_8))
        )
          ;; burn tokens
          (try! (as-contract (contract-call? token-trait transfer burn-amount tx-sender BURN_ADDRESS none)))
          ;; send fee
          (try! (as-contract (stx-transfer? COMPLETE_FEE tx-sender STX_CITY_COMPLETE_FEE_WALLET)))
          
          ;; Use asserts! to ensure the contract-call succeeds
                   ;; Use asserts! to ensure the contract-call succeeds
          (asserts! (is-ok (as-contract (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.self-listing-helper-v2-02 
                                                        request-create-and-fund 
{ 
  token-x: 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2,  
  token-y: (contract-of token-trait),
  factor: u100000000, 
  bal-x: remain-stx-alex-format, 
  bal-y: remain-tokens-alex-format, 
  fee-rate-x: u500000, 
  fee-rate-y: u500000, 
  max-in-ratio: u60000000, 
  max-out-ratio: u60000000, 
  threshold-x: u0, 
  threshold-y: u0, 
  oracle-enabled: true, 
  oracle-average: u99000000, 
  start-block: u0, 
  memo: none
}
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
token-trait
)))                                                        
                   ERR-SELF-LISTING-FAIL)
          ;; update global variables
            (var-set tradable false)
            (var-set stx-balance u0)
            (var-set token-balance u0) 
            (print {tokens-receive: tokens-out, stx-fee: stx-fee, final-fee: COMPLETE_FEE, tokens-burn: burn-amount, tokens-to-dex: remain-tokens, stx-to-dex: remain-stx,
                current-stx-balance: (var-get stx-balance), token-balance: (var-get token-balance), tradable: (var-get tradable) })    
            (ok tokens-out) 
        )
        (begin 
          (print {tokens-receive: tokens-out, 
                  stx-fee: stx-fee, 
                  current-stx-balance: (var-get stx-balance), 
                  token-balance: (var-get token-balance), 
                  tradable: (var-get tradable)})  
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
      (stx-fee (/ (* stx-amount u1) u100)) ;; 1% fee
      (stx-after-fee (- stx-amount stx-fee))
      (k (* current-token-balance current-stx-balance )) ;; k = x*y 
      (new-stx-balance (+ current-stx-balance stx-after-fee)) 
      (new-token-balance (/ k new-stx-balance)) ;; x' = k / y'
      (tokens-out (- current-token-balance new-token-balance))
      (recommend-stx-amount (- STX_TARGET_AMOUNT (var-get stx-balance) ))
      (recommend-stx-amount-after-fee (/ (* recommend-stx-amount u102) u100)) ;; 2% (including 1% fee)
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
      (stx-fee (/ (* stx-out u1) u100)) ;; 1% fee
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
  (var-set token-balance token-supply)  
  (var-set tradable true)
  (var-set burn-percent u20)
  (ok true)
)