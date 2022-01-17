
(impl-trait .stackswap-swap-trait-v1c.stackswap-swap)

(use-trait sip-010-token .sip-010-v1a.sip-010-trait)
(use-trait liquidity-token .liquidity-token-trait-v4c.liquidity-token-trait)

(define-constant ERR_NOT_OWNER (err u4161))
(define-constant ERR_INVALID_ROUTER (err u4162))
(define-constant ERR_PAIR_ALREADY_EXISTS (err u4163))
(define-constant ERR_TOO_MUCH_SLIPPAGE (err u4165))
(define-constant ERR_VALUE_OUT_OF_RANGE (err u4168))
(define-constant ERR_NO_FEE_X (err u4169))
(define-constant ERR_NO_FEE_Y (err u4170))
(define-constant ERR_SAFE_TRANSFER_AMOUNT (err u4174))
(define-constant ERR_SAFE_BURN_AMOUNT (err u4175))
(define-constant ERR_SAFE_MINT_AMOUNT (err u4176))
(define-constant ERR_DAO_ACCESS (err u4177))
(define-constant ERR_MAP_GET (err u4178))

(define-constant FEE_1 u997)
(define-constant FEE_2 u1000)
(define-constant FEE_3 u5)
(define-constant FEE_4 u10000)

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
  bool
)

(define-map pairs-data-map
  {
    token-x: principal,
    token-y: principal,
  }
  {
    liquidity-token: principal,
    pair-id: uint
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

(define-private (safe-transfer (x-to-lp bool) (y-to-lp bool) (dx uint) (dy uint) (token-x-trait <sip-010-token>) (token-y-trait <sip-010-token>) (token-liquidity-trait <liquidity-token>))
    (let 
      (
        (start-amount-x-lp (try! (contract-call? token-x-trait get-balance (contract-of token-liquidity-trait))))
        (start-amount-x-user (try! (contract-call? token-x-trait get-balance tx-sender)))
        (start-amount-y-lp (try! (contract-call? token-y-trait get-balance (contract-of token-liquidity-trait))))
        (start-amount-y-user (try! (contract-call? token-y-trait get-balance tx-sender)))
        (transfer-x-result 
          (if x-to-lp
            (try! (contract-call? token-x-trait transfer dx tx-sender (contract-of token-liquidity-trait) none))
            (try! (contract-call? token-liquidity-trait transfer-token dx token-x-trait tx-sender))
          )
        )
        (transfer-y-result 
          (if y-to-lp
            (try! (contract-call? token-y-trait transfer dy tx-sender (contract-of token-liquidity-trait) none))
            (try! (contract-call? token-liquidity-trait transfer-token dy token-y-trait tx-sender))
          )
        )
        (end-amount-x-lp (try! (contract-call? token-x-trait get-balance (contract-of token-liquidity-trait))))
        (end-amount-x-user (try! (contract-call? token-x-trait get-balance tx-sender)))
        (end-amount-y-lp (try! (contract-call? token-y-trait get-balance (contract-of token-liquidity-trait))))
        (end-amount-y-user (try! (contract-call? token-y-trait get-balance tx-sender)))
      )
        (if x-to-lp
          (begin
            (asserts! (is-eq dx (- end-amount-x-lp start-amount-x-lp)) ERR_SAFE_TRANSFER_AMOUNT)
            (asserts! (is-eq dx (- start-amount-x-user end-amount-x-user)) ERR_SAFE_TRANSFER_AMOUNT)
          )
          (begin
            (asserts! (is-eq dx (- end-amount-x-user start-amount-x-user)) ERR_SAFE_TRANSFER_AMOUNT)
            (asserts! (is-eq dx (- start-amount-x-lp end-amount-x-lp)) ERR_SAFE_TRANSFER_AMOUNT)
          )
        )
        (if y-to-lp
          (begin
            (asserts! (is-eq dy (- end-amount-y-lp start-amount-y-lp)) ERR_SAFE_TRANSFER_AMOUNT)
            (asserts! (is-eq dy (- start-amount-y-user end-amount-y-user)) ERR_SAFE_TRANSFER_AMOUNT)
          )
          (begin
            (asserts! (is-eq dy (- end-amount-y-user start-amount-y-user)) ERR_SAFE_TRANSFER_AMOUNT)
            (asserts! (is-eq dy (- start-amount-y-lp end-amount-y-lp)) ERR_SAFE_TRANSFER_AMOUNT)
          )
        )
      (ok true)
    )
)

(define-public (create-pair (token-x-trait <sip-010-token>) (token-y-trait <sip-010-token>) (token-liquidity-trait <liquidity-token>) (pair-name (string-ascii 32)) (x uint) (y uint))
  (let
    (
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
        fee-to-address: (contract-call? .stackswap-dao-v5j get-payout-address),
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
    (asserts! (is-eq contract-caller (unwrap-panic (contract-call? .stackswap-dao-v5j get-qualified-name-by-name "one-step-mint"))) ERR_DAO_ACCESS)
    (try! (contract-call? token-liquidity-trait initialize-swap token-x token-y))
    (try! (contract-call? token-liquidity-trait set-lp-data pair-data token-x token-y))

    (map-set pairs-data-map { token-x: token-x, token-y: token-y } {liquidity-token: (contract-of token-liquidity-trait), pair-id: pair-id})
    (map-set pairs-token-map token-liquidity true)
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
      (pair (try! (contract-call? token-liquidity-trait get-lp-data) ))
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

    (asserts! (or (contract-call? .stackswap-security-list-v1a is-secure-router-or-user contract-caller) (is-eq contract-caller (unwrap-panic (contract-call? .stackswap-dao-v5j get-qualified-name-by-name "one-step-mint")))) ERR_INVALID_ROUTER)

    (try! (safe-transfer true true x new-y token-x-trait token-y-trait token-liquidity-trait))

    (try! (contract-call? token-liquidity-trait set-lp-data pair-updated (contract-of token-x-trait) (contract-of token-y-trait)))
    (try! (safe-mint token-liquidity-trait tx-sender new-shares))
    (print { object: "pair", action: "liquidity-added", data: pair-updated })
    (ok true)
  )
)

(define-public (reduce-position (token-x-trait <sip-010-token>) (token-y-trait <sip-010-token>) (token-liquidity-trait <liquidity-token>) (percent uint))
  (let
    (
      (valid (asserts! (<= percent u100) ERR_VALUE_OUT_OF_RANGE))
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

    (asserts! (contract-call? .stackswap-security-list-v1a is-secure-router-or-user contract-caller) ERR_INVALID_ROUTER)
    (try! (contract-call? token-liquidity-trait set-lp-data pair-updated (contract-of token-x-trait) (contract-of token-y-trait)))

    (try! (safe-transfer false false withdrawal-x withdrawal-y token-x-trait token-y-trait token-liquidity-trait))

    (try! (safe-burn token-liquidity-trait tx-sender withdrawal))

    (print { object: "pair", action: "liquidity-removed", data: pair-updated })
    (ok (list withdrawal-x withdrawal-y))
  )
)


(define-public (swap-x-for-y (token-x-trait <sip-010-token>) (token-y-trait <sip-010-token>) (token-liquidity-trait <liquidity-token>) (dx uint) (min-dy uint))
  (let
    (
      (pair (try! (contract-call? token-liquidity-trait get-lp-data)))
      (balance-x (get balance-x pair))
      (balance-y (get balance-y pair))
      (dy (/ (* FEE_1 balance-y dx) (+ (* FEE_2 balance-x) (* FEE_1 dx)))) 
      (fee (/ (* FEE_3 dx) FEE_4))
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
    (asserts! (contract-call? .stackswap-security-list-v1a is-secure-router-or-user contract-caller) ERR_INVALID_ROUTER)

    (try! (contract-call? token-liquidity-trait set-lp-data pair-updated (contract-of token-x-trait) (contract-of token-y-trait)))
    (print { object: "pair", action: "swap-x-for-y", data: pair-updated })

    (asserts! (< min-dy dy) ERR_TOO_MUCH_SLIPPAGE)
    (try! (safe-transfer true false dx dy token-x-trait token-y-trait token-liquidity-trait))

    (ok (list dx dy))
  )
)

(define-public (swap-y-for-x (token-x-trait <sip-010-token>) (token-y-trait <sip-010-token>) (token-liquidity-trait <liquidity-token>) (dy uint) (min-dx uint))
  (let (
        (pair (try! (contract-call? token-liquidity-trait get-lp-data)))
        (balance-x (get balance-x pair))
        (balance-y (get balance-y pair))
        (dx (/ (* FEE_1 balance-x dy) (+ (* FEE_2 balance-y) (* FEE_1 dy)))) 
        (fee (/ (* FEE_3 dy) FEE_4))
        (pair-updated (merge pair
          {
            balance-x: (- (get balance-x pair) dx),
            balance-y: (+ (get balance-y pair) (- dy fee)),
            fee-balance-y: (+ fee (get fee-balance-y pair))
          }
        )
      )
    )
    (asserts! (contract-call? .stackswap-security-list-v1a is-secure-router-or-user contract-caller) ERR_INVALID_ROUTER)

    (try! (contract-call? token-liquidity-trait set-lp-data pair-updated (contract-of token-x-trait) (contract-of token-y-trait)))
    (print { object: "pair", action: "swap-y-for-x", data: pair-updated })

    (asserts! (< min-dx dx) ERR_TOO_MUCH_SLIPPAGE)

    (try! (safe-transfer false true dx dy token-x-trait token-y-trait token-liquidity-trait))

    (ok (list dx dy))
  )
)

(define-public (set-fee-to-address (token-liquidity-trait <liquidity-token>) (address principal))
  (begin
    (asserts! (is-eq contract-caller (contract-call? .stackswap-dao-v5j get-dao-owner)) ERR_NOT_OWNER)
    (try! (contract-call? token-liquidity-trait set-fee-to-address address))
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
    
    (try! (safe-transfer false false fee-x fee-y token-x-trait token-y-trait token-liquidity-trait))

    (try! (contract-call? token-liquidity-trait set-lp-data (merge pair {
        fee-balance-x: u0,
        fee-balance-y: u0,}) token-x token-y))
    (ok (list fee-x fee-y))
  )
)

(define-public (fix-or-add-pair (token-x-trait <sip-010-token>) (token-y-trait <sip-010-token>) (token-liquidity-trait <liquidity-token>))
  (let
    (
      (contract-owner-check (asserts! (is-eq contract-caller (contract-call? .stackswap-dao-v5j get-dao-owner)) ERR_NOT_OWNER))
      (token-x (contract-of token-x-trait))
      (token-y (contract-of token-y-trait))
      (token-liquidity (contract-of token-liquidity-trait))
      (x-to-y (is-some (map-get? pairs-data-map { token-x: token-x, token-y: token-y })))
      (y-to-x (is-some (map-get? pairs-data-map { token-x: token-y, token-y: token-x })))
    )
    (if x-to-y 
      (let
        (
            (pair-id (unwrap! (get pair-id (map-get? pairs-data-map { token-x: token-x, token-y: token-y })) ERR_MAP_GET))
        )
        (map-set pairs-data-map { token-x: token-x, token-y: token-y } {liquidity-token: token-liquidity, pair-id: pair-id})
        (map-set pairs-token-map token-liquidity true)
        (map-set pairs-map pair-id { token-x: token-x, token-y: token-y, liquidity-token: token-liquidity})
        (ok pair-id)
      )
      (if y-to-x
        (let
          (
            (pair-id (unwrap! (get pair-id (map-get? pairs-data-map { token-x: token-y, token-y: token-x })) ERR_MAP_GET))
          )
          (map-delete pairs-data-map { token-x: token-y, token-y: token-x })
          (map-set pairs-data-map { token-x: token-x, token-y: token-y } {liquidity-token: token-liquidity, pair-id: pair-id})
          (map-set pairs-token-map token-liquidity true)
          (map-set pairs-map pair-id { token-x: token-x, token-y: token-y, liquidity-token: token-liquidity})
          (ok pair-id)

        )
        (let
          (
            (pair-id (+ (var-get pair-count) u1))
          )
          (map-set pairs-data-map { token-x: token-x, token-y: token-y } {liquidity-token: token-liquidity, pair-id: pair-id})
          (map-set pairs-token-map token-liquidity true)
          (map-set pairs-map pair-id { token-x: token-x, token-y: token-y, liquidity-token: token-liquidity})
          (var-set pair-count pair-id)
          (ok pair-id)
        )
      )
    )
  )
)

