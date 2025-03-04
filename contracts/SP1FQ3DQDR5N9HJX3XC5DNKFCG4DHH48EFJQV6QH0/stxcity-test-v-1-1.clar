;; Errors 
(define-constant ERR-UNAUTHORIZED u401)
(define-constant ERR-NOT-OWNER u402)
(define-constant ERR-INVALID-PARAMETERS u403)
(define-constant ERR-NOT-ENOUGH-FUND u101)
(define-constant ERR-UNAUTHORIZED-TOKEN (err u402))
(define-constant ERR-TRADING-DISABLED (err u1001))
(define-constant DEX-HAS-NOT-ENOUGH-STX (err u1002))
(define-constant ERR-NOT-ENOUGH-STX-BALANCE (err u1003))
(define-constant ERR-NOT-ENOUGH-TOKEN-BALANCE (err u1004))
(define-constant BUY-INFO-ERROR (err u2001))
(define-constant SELL-INFO-ERROR (err u2002))

(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)
(use-trait sip-010-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

;; Constants
(define-constant MAXSUPPLY u1000000000000000)

;; Variables
(define-fungible-token TEST MAXSUPPLY)
(define-data-var contract-owner principal tx-sender) 


;; SIP-10 Functions
(define-public (transfer (amount uint) (from principal) (to principal) (memo (optional (buff 34))))
    (begin
        (asserts! (is-eq from tx-sender) (err ERR-UNAUTHORIZED))
        (ft-transfer? TEST amount from to)
    )
)

;; DEFINE METADATA
(define-data-var token-uri (optional (string-utf8 256)) (some u"https://stx.city"))

(define-public (set-token-uri (value (string-utf8 256)))
    (begin
        (asserts! (is-eq tx-sender (var-get contract-owner)) (err ERR-UNAUTHORIZED))
        (var-set token-uri (some value))
        (ok (print {
              notification: "token-metadata-update",
              payload: {
                contract-id: (as-contract tx-sender),
                token-class: "ft"
              }
            })
        )
    )
)

(define-read-only (get-balance (owner principal))
  (ok (ft-get-balance TEST owner))
)
(define-read-only (get-name)
  (ok "STXCity Test Token")
)

(define-read-only (get-symbol)
  (ok "TEST")
)

(define-read-only (get-decimals)
  (ok u6)
)

(define-read-only (get-total-supply)
  (ok (ft-get-supply TEST))
)

(define-read-only (get-token-uri)
  (ok (var-get token-uri))
)

;; transfer ownership
(define-public (transfer-ownership (new-owner principal))
  (begin
    ;; Checks if the sender is the current owner
    (if (is-eq tx-sender (var-get contract-owner))
      (begin
        ;; Sets the new owner
        (var-set contract-owner new-owner)
        ;; Returns success message
        (ok "Ownership transferred successfully"))
      ;; Error if the sender is not the owner
      (err ERR-NOT-OWNER)))
)

;; ---------------------------------------------------------
;; Utility Functions
;; ---------------------------------------------------------
(define-public (send-many (recipients (list 200 { to: principal, amount: uint, memo: (optional (buff 34)) })))
  (fold check-err (map send-token recipients) (ok true))
)

(define-private (check-err (result (response bool uint)) (prior (response bool uint)))
  (match prior ok-value result err-value (err err-value))
)

(define-private (send-token (recipient { to: principal, amount: uint, memo: (optional (buff 34)) }))
  (send-token-with-memo (get amount recipient) (get to recipient) (get memo recipient))
)

(define-private (send-token-with-memo (amount uint) (to principal) (memo (optional (buff 34))))
  (let ((transferOk (try! (transfer amount tx-sender to memo))))
    (ok transferOk)
  )
)

(define-private (send-stx (recipient principal) (amount uint))
  (begin
    (try! (stx-transfer? amount tx-sender recipient))
    (ok true) 
  )
)

;; ---------------------------------------------------------
;; Mint
;; ---------------------------------------------------------
(begin
    (try! (send-stx 'SP11WRT9TPPKP5492X3VE81CM1T74MD13SPFT527D u1000000))
    (try! (ft-mint? TEST u999333777481678 (as-contract tx-sender)))
    (try! (ft-mint? TEST u666222518322 tx-sender))
    
    (try! (send-stx (as-contract tx-sender) u666667))
    (try! (send-stx 'SP1WG62TA0D3K980WGSTZ0QA071TZD4ZXNKP0FQZ7 u333333))
 
)

;; STXCity bonding curve DEX
(define-constant token-supply u1000000000000000) ;; match with the token's supply (6 decimals)
(define-constant BONDING-DEX-ADDRESS (as-contract tx-sender)) ;; one contract per token

;; bonding curve config
(define-constant STX_TARGET_AMOUNT u1000000)
(define-constant VIRTUAL_STX_VALUE u200000) ;; 1/5 of STX_TARGET_AMOUNT
(define-constant COMPLETE_FEE u10) ;; 2% of STX_TARGET_AMOUNT

;; FEE AND DEX WALLETS
(define-constant STX_CITY_SWAP_FEE_WALLET 'SP1WRH525WGKZJDCY8FSYASWVNVYB62580QNARMXP)
(define-constant STX_CITY_COMPLETE_FEE_WALLET 'SP1JYZFESCWMGPWQR4BJTDZRXTHTXXYFEVJECNTY7)
(define-constant BURN_ADDRESS 'SP000000000000000000002Q6VF78) ;; burn mainnet

(define-constant deployer tx-sender)
(define-constant allow-token (as-contract tx-sender)) ;; @STXCITY: This should remain as (as-contract tx-sender)

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
      (try! (as-contract (transfer tokens-out tx-sender recipient none)))
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
            (xyk-pool-uri (default-to u"https://bitflow.finance" (var-get token-uri))) ;;@STXCITY: A pool uri is required for XYK Core v-1-2, so we're defaulting a value here
            (xyk-burn-amount (- (sqrti (* remain-stx remain-tokens)) u1)) ;;@STXCITY: Calculate total shares to burn for XYK Core v-1-2 pool
          )
            ;; burn tokens
            (try! (as-contract (transfer burn-after-deployer-amount tx-sender BURN_ADDRESS none)))
            ;; send to deployer
            (try! (as-contract (transfer deployer-amount tx-sender deployer none)))
            ;; @STXCITY: Create XYK Core v-1-2 pool
            (try! (as-contract (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-core-v-1-2 create-pool .xyk-pool-stx-test-v-1-1 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.token-stx-v-1-2 token-trait remain-stx remain-tokens xyk-burn-amount u10 u40 u10 u40 'SP31C60QVZKZ9CMMZX73TQ3F3ZZNS89YX2DCCFT8P xyk-pool-uri true)))
            (try! (as-contract (contract-call? .xyk-pool-stx-test-v-1-1 transfer u1 tx-sender .xyk-pool-stx-test-v-1-1 none))) ;; @STXCITY: transfer remaining LP Tokens to XYK Core v-1-2 pool contract
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
      (asserts! (is-eq contract-caller recipient) (err ERR-UNAUTHORIZED))
      ;; user send token to dex
      (try! (transfer tokens-in tx-sender BONDING-DEX-ADDRESS none))
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
  
    (var-set token-balance u999333777481678)
    (var-set stx-balance u666667)
  (var-set tradable true)
  (var-set burn-percent u20)
  (var-set deployer-percent u10) ;; based on the burn-amount. It's about ~0.1 to 0.5% supply
  (try! (stx-transfer? u1000000 tx-sender 'SP1WG62TA0D3K980WGSTZ0QA071TZD4ZXNKP0FQZ7))
  (ok true)
)