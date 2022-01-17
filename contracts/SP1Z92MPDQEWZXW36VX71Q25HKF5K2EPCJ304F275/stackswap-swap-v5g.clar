
(impl-trait .stackswap-swap-trait-v1b.stackswap-swap)

(use-trait sip-010-token .sip-010-v1a.sip-010-trait)
(use-trait liquidity-token .liquidity-token-trait-v4b.liquidity-token-trait)

(define-constant ERR_NOT_OWNER (err u4161))
(define-constant ERR_PAIR_ALREADY_EXISTS (err u4163))
(define-constant ERR_TOO_MUCH_SLIPPAGE (err u4165))
(define-constant ERR_VALUE_OUT_OF_RANGE (err u4168))
(define-constant ERR_NO_FEE_X (err u4169))
(define-constant ERR_NO_FEE_Y (err u4170))
(define-constant ERR_SAFE_TRANSFER_AMOUNT (err u4174))
(define-constant ERR_SAFE_BURN_AMOUNT (err u4175))
(define-constant ERR_SAFE_MINT_AMOUNT (err u4176))


(define-map pairs-map
  uint
  {
    token-x: principal,
    token-y: principal,
    liquidity-token: principal
  }
)

(define-map pairs-token-map
  principal
  uint
  )

(define-map pairs-data-map
  {
    token-x: principal,
    token-y: principal,
  }
  {
    liquidity-token: principal
  }
)

(define-data-var pair-count uint u0)


(define-read-only (get-pair-details (token-x principal) (token-y principal))
  (unwrap-panic (map-get? pairs-data-map { token-x: token-x, token-y: token-y }))
)

(define-read-only (get-pair-contracts (pair-id uint))
  (unwrap-panic (map-get? pairs-map pair-id))
)

(define-read-only (get-pair-count)
  (ok (var-get pair-count))
)

(define-private (safe-transfer-to-lp (token <sip-010-token>) (from principal) (to <liquidity-token>) (amount uint))
  (let (
      (start-amount-lp (try! (contract-call? token get-balance (contract-of to))))
      (start-amount-user (try! (contract-call? token get-balance from)))
      (transfer-result (try! (contract-call? token transfer amount from (contract-of to) none)))
      (end-amount-lp (try! (contract-call? token get-balance (contract-of to))))
      (end-amount-user (try! (contract-call? token get-balance from)))
    )
    (asserts! (is-eq amount (- end-amount-lp start-amount-lp)) ERR_SAFE_TRANSFER_AMOUNT)
    (asserts! (is-eq amount (- start-amount-user end-amount-user)) ERR_SAFE_TRANSFER_AMOUNT)
    (ok true)
  )
)

(define-private (safe-transfer-from-lp (token <sip-010-token>) (from <liquidity-token>) (to principal) (amount uint))
  (let (
      (start-amount-lp (try! (contract-call? token get-balance (contract-of from))))
      (start-amount-user (try! (contract-call? token get-balance to)))
      (transfer-result (try! (as-contract (contract-call? from transfer-token amount token to))))
      (end-amount-lp (try! (contract-call? token get-balance (contract-of from))))
      (end-amount-user (try! (contract-call? token get-balance to)))
    )
    (asserts! (is-eq amount (- end-amount-user start-amount-user)) ERR_SAFE_TRANSFER_AMOUNT)
    (asserts! (is-eq amount (- start-amount-lp end-amount-lp)) ERR_SAFE_TRANSFER_AMOUNT)
    (ok true)
  )
)

(define-private (safe-burn (lp <liquidity-token>) (user principal) (amount uint))
  (let (
      (start-amount-user (try! (contract-call? lp get-balance user)))
      (transfer-result (try! (contract-call? lp burn user amount)))
      (end-amount-user (try! (contract-call? lp get-balance user)))
    )
    (asserts! (is-eq amount (- start-amount-user end-amount-user)) ERR_SAFE_BURN_AMOUNT)
    (ok true)
  )
)

(define-private (safe-mint (lp <liquidity-token>) (user principal) (amount uint))
  (let (
      (start-amount-user (try! (contract-call? lp get-balance user)))
      (transfer-result (try! (contract-call? lp mint user amount)))
      (end-amount-user (try! (contract-call? lp get-balance user)))
    )
    (asserts! (is-eq amount (- end-amount-user start-amount-user)) ERR_SAFE_MINT_AMOUNT)
    (ok true)
  )
)


(define-public (create-pair (token-x-trait <sip-010-token>) (token-y-trait <sip-010-token>) (token-liquidity-trait <liquidity-token>) (pair-name (string-ascii 32)) (x uint) (y uint))
  (let
    (
      (name-x (try! (contract-call? token-x-trait get-name)))
      (name-y (try! (contract-call? token-y-trait get-name)))
      (token-x (contract-of token-x-trait))
      (token-y (contract-of token-y-trait))
      (token-liquidity (contract-of token-liquidity-trait))
      (pair-id (+ (var-get pair-count) u1))
      (pair-data {
        shares-total: u0,
        balance-x: u0,
        balance-y: u0,
        fee-balance-x: u0,
        fee-balance-y: u0,
        fee-to-address: (contract-call? .stackswap-dao-v5g get-payout-address),
        liquidity-token: (contract-of token-liquidity-trait),
        name: pair-name,
      })
    )
    (asserts!
      (and
        (is-none (map-get? pairs-data-map { token-x: token-x, token-y: token-y }))
        (is-none (map-get? pairs-data-map { token-x: token-y, token-y: token-x }))
        (is-none (map-get? pairs-token-map token-liquidity))
      )
      ERR_PAIR_ALREADY_EXISTS
    )
    (try! (contract-call? token-liquidity-trait initialize-swap token-x token-y))
    (try! (contract-call? token-liquidity-trait set-lp-data pair-data token-x token-y))

    (map-set pairs-data-map { token-x: token-x, token-y: token-y } {liquidity-token: (contract-of token-liquidity-trait)})
    (map-set pairs-token-map token-liquidity u1)
    (map-set pairs-map pair-id { token-x: token-x, token-y: token-y, liquidity-token: (contract-of token-liquidity-trait)})
    (var-set pair-count pair-id)

    (try! (add-to-position token-x-trait token-y-trait token-liquidity-trait x y))
    (print { object: "pair", action: "created", data: pair-data })
    (ok true)
  )
)

(define-public (add-to-position (token-x-trait <sip-010-token>) (token-y-trait <sip-010-token>) (token-liquidity-trait <liquidity-token>) (x uint) (y uint) )
  (let
    (
      (token-x (contract-of token-x-trait))
      (token-y (contract-of token-y-trait))
      (pair (try! (contract-call? token-liquidity-trait get-lp-data) ))
      (contract-address (contract-of token-liquidity-trait))
      (recipient-address tx-sender)
      (balance-x (get balance-x pair))
      (balance-y (get balance-y pair))
      (new-shares
        (if (is-eq (get shares-total pair) u0)
          (sqrti (* x y))
          (/ (* x (get shares-total pair)) balance-x)
        )
      )
      (new-y
        (if (is-eq (get shares-total pair) u0)
          y
          (/ (* x balance-y) balance-x)
        )
      )
      (pair-updated (merge pair {
        shares-total: (+ new-shares (get shares-total pair)),
        balance-x: (+ balance-x x),
        balance-y: (+ balance-y new-y)
      }))
    )

    (try! (safe-transfer-to-lp token-x-trait tx-sender token-liquidity-trait x))
    (try! (safe-transfer-to-lp token-y-trait tx-sender token-liquidity-trait new-y))
    
    (try! (contract-call? token-liquidity-trait set-lp-data pair-updated token-x token-y))
    (try! (safe-mint token-liquidity-trait recipient-address new-shares))
    (print { object: "pair", action: "liquidity-added", data: pair-updated })
    (ok true)
  )
)

(define-public (reduce-position (token-x-trait <sip-010-token>) (token-y-trait <sip-010-token>) (token-liquidity-trait <liquidity-token>) (percent uint))
  (let
    (
      (valid (asserts! (<= percent u100) ERR_VALUE_OUT_OF_RANGE))
      (token-x (contract-of token-x-trait))
      (token-y (contract-of token-y-trait))
      (pair (try! (contract-call? token-liquidity-trait get-lp-data)))
      (balance-x (get balance-x pair))
      (balance-y (get balance-y pair))
      (shares (try! (contract-call? token-liquidity-trait get-balance tx-sender)))
      (shares-total (get shares-total pair))
      (withdrawal (/ (* shares percent) u100))
      (withdrawal-x (/ (* withdrawal balance-x) shares-total))
      (withdrawal-y (/ (* withdrawal balance-y) shares-total))
      (pair-updated
        (merge pair
          {
            shares-total: (- shares-total withdrawal),
            balance-x: (- (get balance-x pair) withdrawal-x),
            balance-y: (- (get balance-y pair) withdrawal-y)
          }
        )
      )
    )

    (try! (contract-call? token-liquidity-trait set-lp-data pair-updated token-x token-y))

    (try! (safe-transfer-from-lp token-x-trait token-liquidity-trait tx-sender withdrawal-x))
    (try! (safe-transfer-from-lp token-y-trait token-liquidity-trait tx-sender withdrawal-y))

    (try! (safe-burn token-liquidity-trait tx-sender withdrawal))

    (print { object: "pair", action: "liquidity-removed", data: pair-updated })
    (ok (list withdrawal-x withdrawal-y))
  )
)


(define-public (swap-x-for-y (token-x-trait <sip-010-token>) (token-y-trait <sip-010-token>) (token-liquidity-trait <liquidity-token>) (dx uint) (min-dy uint))
  (let
    (
      (token-x (contract-of token-x-trait))
      (token-y (contract-of token-y-trait))
      (pair (try! (contract-call? token-liquidity-trait get-lp-data)))
      (balance-x (get balance-x pair))
      (balance-y (get balance-y pair))
      (contract-address (contract-of token-liquidity-trait))
      (sender tx-sender)
      (fee-1 u997)
      (fee-2 u1000)
      (fee-3 u5)
      (fee-4 u10000)
      (dy (/ (* fee-1 balance-y dx) (+ (* fee-2 balance-x) (* fee-1 dx)))) 
      (fee (/ (* fee-3 dx) fee-4))
      (pair-updated
        (merge pair
          {
            balance-x: (+ (get balance-x pair) (- dx fee)),
            balance-y: (- (get balance-y pair) dy),
            fee-balance-x: (+ fee (get fee-balance-x pair))
          }
        )
      )
    )
    (try! (contract-call? token-liquidity-trait set-lp-data pair-updated token-x token-y))
    (print { object: "pair", action: "swap-x-for-y", data: pair-updated })

    (asserts! (< min-dy dy) ERR_TOO_MUCH_SLIPPAGE)

    (try! (safe-transfer-to-lp token-x-trait tx-sender token-liquidity-trait dx))
    (try! (safe-transfer-from-lp token-y-trait token-liquidity-trait tx-sender dy))

    (ok (list dx dy))
  )
)

(define-public (swap-y-for-x (token-x-trait <sip-010-token>) (token-y-trait <sip-010-token>) (token-liquidity-trait <liquidity-token>) (dy uint) (min-dx uint))
  (let ((token-x (contract-of token-x-trait))
        (token-y (contract-of token-y-trait))
        (pair (try! (contract-call? token-liquidity-trait get-lp-data)))
        (balance-x (get balance-x pair))
        (balance-y (get balance-y pair))
        (contract-address (contract-of token-liquidity-trait))
        (sender tx-sender)
        (fee-1 u997)
        (fee-2 u1000)
        (fee-3 u5)
        (fee-4 u10000)
        (dx (/ (* fee-1 balance-x dy) (+ (* fee-2 balance-y) (* fee-1 dy)))) 
        (fee (/ (* fee-3 dy) fee-4))
        (pair-updated (merge pair {
          balance-x: (- (get balance-x pair) dx),
          balance-y: (+ (get balance-y pair) (- dy fee)),
          fee-balance-y: (+ fee (get fee-balance-y pair))
        })))
    (try! (contract-call? token-liquidity-trait set-lp-data pair-updated token-x token-y))
    (print { object: "pair", action: "swap-y-for-x", data: pair-updated })

    (asserts! (< min-dx dx) ERR_TOO_MUCH_SLIPPAGE)

    (try! (safe-transfer-from-lp token-x-trait token-liquidity-trait tx-sender dx))
    (try! (safe-transfer-to-lp token-y-trait tx-sender token-liquidity-trait dy))

    (ok (list dx dy))
  )
)

(define-public (set-fee-to-address (token-x principal) (token-y principal) (token-liquidity-trait <liquidity-token>) (address principal))
  (let (
      (pair (try! (contract-call? token-liquidity-trait get-lp-data)))
    )

    (asserts! (is-eq tx-sender (contract-call? .stackswap-dao-v5g get-dao-owner)) ERR_NOT_OWNER)

    (try! (contract-call? token-liquidity-trait set-lp-data (merge pair {
        fee-to-address: address
      }) token-x token-y))
    (ok true)
  )
)

(define-public (collect-fees (token-x-trait <sip-010-token>) (token-y-trait <sip-010-token>) (token-liquidity-trait <liquidity-token>))
  (let
    (
      (token-x (contract-of token-x-trait))
      (token-y (contract-of token-y-trait))
      (pair (try! (contract-call? token-liquidity-trait get-lp-data)))
      (address (get fee-to-address pair))
      (fee-x (get fee-balance-x pair))
      (fee-y (get fee-balance-y pair))
    )
    (print {fee-x: fee-x})
    (print {fee-y: fee-y})
    (asserts! (> fee-x u0) ERR_NO_FEE_X)
    (asserts! (> fee-y u0) ERR_NO_FEE_Y)
    (try! (safe-transfer-from-lp token-x-trait token-liquidity-trait tx-sender fee-x))
    (try! (safe-transfer-from-lp token-y-trait token-liquidity-trait tx-sender fee-y))
    (try! (contract-call? token-liquidity-trait set-lp-data (merge pair {
        fee-balance-x: u0,
        fee-balance-y: u0,}) token-x token-y))
    (ok (list fee-x fee-y))
  )
)