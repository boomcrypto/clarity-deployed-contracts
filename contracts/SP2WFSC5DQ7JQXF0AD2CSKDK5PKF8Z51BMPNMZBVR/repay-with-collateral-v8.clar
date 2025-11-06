;; Traits
(use-trait ft-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)
(impl-trait 'SP3Y6GFKWN50HPA8RKRXMY0EXAJR9VXPY899P88JN.trait-flash-loan-v1.flash-loan)

;; Constants
(define-constant SELF (as-contract contract-caller))
(define-constant SUCCESS (ok true))

;; Errors
(define-constant ERR-UNAUTHORIZED (err u140000))
(define-constant ERR-INVALID-CALLBACK-DATA (err u140001))
(define-constant ERR-TIMEOUT (err u140002))

;; Variables
(define-data-var flash-loan-sc principal 'SP3Y6GFKWN50HPA8RKRXMY0EXAJR9VXPY899P88JN.flash-loan-v1)

;; View
(define-read-only (is-flash-loan-sc) (is-eq contract-caller (var-get flash-loan-sc)))

;; Public
(define-public (on-granite-flash-loan (amount uint) (fee uint) (data (optional (buff 20480))))
  (let (
    (cdata (unwrap! (from-consensus-buff? {
      pyth-price-feed-data: (optional (buff 8192)),
      deadline: uint,
      sbtc-to-withdraw: uint,
      user: principal
      } (unwrap-panic data)) ERR-INVALID-CALLBACK-DATA))
      (pyth-price-feed-data (get pyth-price-feed-data cdata))
      (sbtc-to-withdraw (get sbtc-to-withdraw cdata))
      (user (get user cdata))
      (sender tx-sender)
  )
    (asserts! (is-flash-loan-sc) ERR-UNAUTHORIZED)
    (asserts! (> (get deadline cdata) (default-to u0 (get-stacks-block-info? time (- stacks-block-height u1)))) ERR-TIMEOUT)
    ;; Transfer tokens from the user to the contract
    (try! (contract-call? 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc transfer amount sender SELF none))
    ;; Repay debt
    (try! (as-contract (contract-call? 'SP3Y6GFKWN50HPA8RKRXMY0EXAJR9VXPY899P88JN.borrower-v1 repay amount (some user))))
    ;; Withdraw sBTC
    ;; (try! (as-contract (contract-call? 'SP3Y6GFKWN50HPA8RKRXMY0EXAJR9VXPY899P88JN.borrower-v1 remove-collateral pyth-price-feed-data 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token sbtc-to-withdraw (some user))))
    ;; Swap from the user holding in sBTC to aeUSDC    
    (let (
      (to-repay (+ amount fee))
      (aeusdc-out u1);;(try! (as-contract (swap-sbtc-to-aeusdc-bitflow sbtc-to-withdraw to-repay))))
      )
      (print {
        action: "repay with collateral",
        user: user,
        repaid: amount,
        sbtc-withdrawn: sbtc-to-withdraw,
        aeusdc-obtained: aeusdc-out
      })
      SUCCESS
    )
  )
)

(define-public (swap-sbtc-to-aeusdc-bitflow (sbtc-in-amount uint) (aeusdc-min-out uint))
  (let (
    ;; sbtc->stx
    (stx-out (try! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-core-v-1-2 
      swap-x-for-y 
      'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-pool-sbtc-stx-v-1-1 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.token-stx-v-1-2 
      sbtc-in-amount 
      u1)))
    
    ;; stx->aeusdc
    (aeusdc-out (try! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-core-v-1-2 
      swap-x-for-y 
      'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-pool-stx-aeusdc-v-1-2 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.token-stx-v-1-2 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc  
      stx-out aeusdc-min-out)))
  )
  (print {
    action: "swap-sbtc-to-aeusdc-bitflow",
    sbtc-in: sbtc-in-amount,
    aeusdc-out: aeusdc-out,
    aeusdc-min-out: aeusdc-min-out
  })
  (ok aeusdc-out)
))
