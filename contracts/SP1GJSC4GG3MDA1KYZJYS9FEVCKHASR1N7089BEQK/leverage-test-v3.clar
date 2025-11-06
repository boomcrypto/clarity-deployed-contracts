;; Traits
(use-trait ft-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)
(impl-trait 'SP2Q5KYRHR7C07D5H5Y0QMN6K9F9410X1CS0J7YS0.trait-flash-loan-v1.flash-loan)

;; Constants
(define-constant SELF (as-contract contract-caller))
(define-constant SCALING-FACTOR u10000)
(define-constant SUCCESS (ok true))
(define-constant FEE u100)

;; Errors
(define-constant ERR-UNAUTHORIZED (err u20000))
(define-constant ERR-INVALID-DEX (err u20001))
(define-constant ERR-INSUFFICIENT-BALANCE (err u20002))
(define-constant ERR-INVALID-CALLBACK-DATA (err u20003))
(define-constant ERR-TIMEOUT (err u20004))
(define-constant ERR-INVALID-VALUE (err u20005))
(define-constant ERR-TRANSFER-NULL (err u20006))

;; Variables
(define-data-var flash-loan-sc principal 'SP2Q5KYRHR7C07D5H5Y0QMN6K9F9410X1CS0J7YS0.flash-loan-v1)

;; View
(define-read-only (is-flash-loan-sc) (is-eq contract-caller (var-get flash-loan-sc)))

;; Public
(define-public (on-granite-flash-loan (amount uint) (fee uint) (data (optional (buff 20480))))
  (let (
    (cdata (unwrap! (from-consensus-buff? {
      pyth-price-feed-data: (optional (buff 8192)),
      deadline: uint,
      borrow-amount: uint,
      min-sbtc-out: uint,
      user: principal
      } (unwrap-panic data)) ERR-INVALID-CALLBACK-DATA))
      (pyth-price-feed-data (get pyth-price-feed-data cdata))
      (borrow-amount (get borrow-amount cdata))
      (min-sbtc-out (get min-sbtc-out cdata))
      (user (get user cdata))
      (sender tx-sender)
  )
    (asserts! (is-flash-loan-sc) ERR-UNAUTHORIZED)
    (asserts! (> (get deadline cdata) (default-to u0 (get-stacks-block-info? time (- stacks-block-height u1)))) ERR-TIMEOUT)
    (try! (contract-call? 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc transfer amount sender SELF none))
    (try! (leverage-helper pyth-price-feed-data borrow-amount min-sbtc-out user))
    (try! (as-contract (contract-call? 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc transfer (+ amount fee) SELF sender none)))
    SUCCESS
  )
)

(define-private (leverage-helper 
  (pyth-price-feed-data (optional (buff 8192)))
  (borrow-amount uint)
  (min-sbtc-out uint)
  (user principal)
)
  (let 
    (
      ;; get USDC balance
      (market-asset-balance (unwrap-panic (contract-call? 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc get-balance SELF)))
      ;; swap USDC to sBTC
      (sbtc-out (try! (swap-aeusdc-to-sbtc-bitflow market-asset-balance min-sbtc-out)))
    )
      ;; deposit sBTC
      (try! (contract-call? 'SP2Q5KYRHR7C07D5H5Y0QMN6K9F9410X1CS0J7YS0.borrower-v1 add-collateral 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token sbtc-out (some user)))
      ;; borrow
      (try! (contract-call? 'SP2Q5KYRHR7C07D5H5Y0QMN6K9F9410X1CS0J7YS0.borrower-v1 borrow pyth-price-feed-data borrow-amount (some user)))
      (print {
        action: "sbtc leverage",
        user: user,
        borrowed: borrow-amount,
        sbtc-obtained: sbtc-out
      })
      SUCCESS
    )
)

(define-private (swap-aeusdc-to-sbtc-bitflow (aeusdc-in-amount uint) (sbtc-min-out uint))
  (let
    (
      ;; sbtc -> stx
      (o1 (try! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-core-v-1-2 swap-y-for-x 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-pool-stx-aeusdc-v-1-2 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.token-stx-v-1-2 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc aeusdc-in-amount u1)))
      ;; stx -> aeusdc
      (sbtc-out (try! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-core-v-1-2 swap-y-for-x 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-pool-sbtc-stx-v-1-1 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.token-stx-v-1-2 o1 sbtc-min-out)))
    )
    (print {
      action: "swap-aeusdc-to-sbtc-bitflow",
      aeusdc-in: aeusdc-in-amount,
      sbtc-out: sbtc-out,
      sbtc-min-out: sbtc-min-out
    })
    (ok sbtc-out)
  )
)

