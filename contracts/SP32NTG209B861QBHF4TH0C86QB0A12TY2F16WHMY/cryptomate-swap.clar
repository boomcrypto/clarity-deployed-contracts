(use-trait sip-010-token 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)
(use-trait liquidity-token 'SP32NTG209B861QBHF4TH0C86QB0A12TY2F16WHMY.liquidity-token-trait.liquidity-token-trait)

(define-constant contract-owner tx-sender)
(define-constant not-authorized u4101)
(define-constant no-liquidity-err (err u4161))
(define-constant not-owner-err (err u4163))
(define-constant no-fee-to-address-err (err u4164))
(define-constant invalid-pair-err (err u4165))
(define-constant no-such-position-err (err u4166))
(define-constant balance-too-low-err (err u4167))
(define-constant too-many-pairs-err (err u4168))
(define-constant pair-already-exists-err (err u4169))
(define-constant wrong-token-err (err u4170))
(define-constant too-much-slippage-err (err u4171))
(define-constant transfer-x-failed-err (err u4172))
(define-constant transfer-y-failed-err (err u4173))
(define-constant value-out-of-range-err (err u4174))
(define-constant no-fee-x-err (err u4175))
(define-constant no-fee-y-err (err u4176))
(define-constant pair-token-already-used-err (err u4177))
(define-constant fee-contract-err (err u4178))
(define-constant not-upgraded-err (err u4179))
(define-constant lp-data-set-err (err u4180))
(define-constant lp-data-get-err (err u4181))
(define-constant SAFE_TRANSFER_AMOUNT_ERR (err u4182))
(define-constant SAFE_BURN_AMOUNT_ERR (err u4183))
(define-constant SAFE_MINT_AMOUNT_ERR (err u4184))
(define-constant PERMISSION_DENIED_ERROR u4185)

(define-map pairs-map
  { pair-id: uint }
  {
    token-x: principal,
    token-y: principal,
    liquidity-token: principal
  }
)

(define-map pairs-token-map
  { pair-token: principal}
  { exist: uint}
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

(define-map roles { role: uint, account: principal } { allowed: bool })


;; ROLES
(define-constant OWNER_ROLE u0)
(define-constant WHITELISTER_ROLE u1)
(define-constant BLACKLISTER_ROLE u2)

(define-map whitelist-for-new-pair {account: principal } {whitelisted: bool})
(define-map whitelist-for-liquidity-providers {account: principal } {whitelisted: bool})
(define-map blacklist-for-swapping {account: principal } {blacklisted: bool})

(define-read-only (has-role (role-to-check uint) (principal-to-check principal))
  (default-to false (get allowed (map-get? roles {role: role-to-check, account: principal-to-check}))))

(define-public (add-principal-to-role (role-to-add uint) (principal-to-add principal))
   (begin
    (asserts! (has-role OWNER_ROLE contract-caller) (err PERMISSION_DENIED_ERROR))
    (ok (map-set roles { role: role-to-add, account: principal-to-add } { allowed: true }))))

(define-public (remove-principal-from-role (role-to-remove uint) (principal-to-remove principal))
   (begin
    (asserts! (has-role OWNER_ROLE contract-caller) (err PERMISSION_DENIED_ERROR))
    (ok (map-set roles { role: role-to-remove, account: principal-to-remove } { allowed: false }))))

(define-public (update-whitelist-for-new-pairs (principal-to-update principal) (whitelist bool))
  (begin
    (asserts! (has-role  WHITELISTER_ROLE contract-caller) (err PERMISSION_DENIED_ERROR))
    (ok (map-set whitelist-for-new-pair { account: principal-to-update } { whitelisted: whitelist }))))

(define-public (update-whitelist-for-liquidity-providers (principal-to-update principal) (whitelist bool))
  (begin
    (asserts! (has-role  WHITELISTER_ROLE contract-caller) (err PERMISSION_DENIED_ERROR))
    (ok (map-set whitelist-for-liquidity-providers { account: principal-to-update } { whitelisted: whitelist }))))

(define-public (update-blacklist-for-swapping (principal-to-update principal) (blacklist bool))
  (begin
    (asserts! (has-role  BLACKLISTER_ROLE contract-caller) (err PERMISSION_DENIED_ERROR))
    (ok (map-set blacklist-for-swapping { account: principal-to-update } { blacklisted: blacklist }))))

(define-read-only (is-whitelisted-for-new-pairs (principal-to-check principal))
  (default-to false (get whitelisted (map-get? whitelist-for-new-pair {account: principal-to-check}))))

(define-read-only (is-whitelisted-for-lps (principal-to-check principal))
  (default-to false (get whitelisted (map-get? whitelist-for-liquidity-providers {account: principal-to-check}))))

(define-read-only (is-blacklisted-for-swapping (principal-to-check principal))
  (default-to false (get blacklisted (map-get? blacklist-for-swapping {account: principal-to-check}))))

(define-data-var pair-count uint u0)
(define-data-var pair-ids (list 1000 uint) (list))

(define-read-only (get-pair-details (token-x principal) (token-y principal))
  (unwrap-panic (map-get? pairs-data-map { token-x: token-x, token-y: token-y }))
)

(define-read-only (get-pair-contracts (pair-id uint))
  (unwrap-panic (map-get? pairs-map { pair-id: pair-id }))
)

(define-read-only (get-all-pair-contracts)
  (map get-pair-contracts (var-get pair-ids))
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
    (asserts! (is-eq amount (- end-amount-lp start-amount-lp)) SAFE_TRANSFER_AMOUNT_ERR)
    (asserts! (is-eq amount (- start-amount-user end-amount-user)) SAFE_TRANSFER_AMOUNT_ERR)
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
    (asserts! (is-eq amount (- end-amount-user start-amount-user)) SAFE_TRANSFER_AMOUNT_ERR)
    (asserts! (is-eq amount (- start-amount-lp end-amount-lp)) SAFE_TRANSFER_AMOUNT_ERR)
    (ok true)
  )
)

(define-private (safe-burn (lp <liquidity-token>) (user principal) (amount uint))
  (let (
      (start-amount-user (try! (contract-call? lp get-balance user)))
      (transfer-result (try! (contract-call? lp burn user amount)))
      (end-amount-user (try! (contract-call? lp get-balance user)))
    )
    (asserts! (is-eq amount (- start-amount-user end-amount-user)) SAFE_BURN_AMOUNT_ERR)
    (ok true)
  )
)

(define-private (safe-mint (lp <liquidity-token>) (user principal) (amount uint))
  (let (
      (start-amount-user (try! (contract-call? lp get-balance user)))
      (transfer-result (try! (contract-call? lp mint user amount)))
      (end-amount-user (try! (contract-call? lp get-balance user)))
    )
    (asserts! (is-eq amount (- end-amount-user start-amount-user)) SAFE_MINT_AMOUNT_ERR)
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
        fee-to-address: contract-owner,
        liquidity-token: (contract-of token-liquidity-trait),
        name: pair-name,
      })
    )
    (asserts!  (is-whitelisted-for-new-pairs tx-sender) (err not-authorized))
    (asserts!
      (and
        (is-none (map-get? pairs-data-map { token-x: token-x, token-y: token-y }))
        (is-none (map-get? pairs-data-map { token-x: token-y, token-y: token-x }))
        (is-none (map-get? pairs-token-map { pair-token: token-liquidity}))
      )
      pair-already-exists-err
    )
    (unwrap! (contract-call? token-liquidity-trait initialize-swap token-x token-y) invalid-pair-err)
    (unwrap! (contract-call? token-liquidity-trait set-lp-data pair-data token-x token-y) lp-data-set-err)

    (map-set pairs-data-map { token-x: token-x, token-y: token-y } {liquidity-token: (contract-of token-liquidity-trait)})
    (map-set pairs-token-map { pair-token: token-liquidity} {exist: u1})
    (map-set pairs-map { pair-id: pair-id } { token-x: token-x, token-y: token-y, liquidity-token: (contract-of token-liquidity-trait)})
    (var-set pair-count pair-id)
    (var-set pair-ids (unwrap-panic (as-max-len? (append (var-get pair-ids) pair-id) u1000)))

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
      (pair (unwrap! (contract-call? token-liquidity-trait get-lp-data) lp-data-get-err))
      (contract-address (contract-of token-liquidity-trait))
      (recipient-address tx-sender)
      (balance-x (get balance-x pair))
      (balance-y (get balance-y pair))
      (lp (asserts! (is-eq (get liquidity-token pair) (contract-of token-liquidity-trait)) wrong-token-err))
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

    (asserts!  (is-whitelisted-for-lps tx-sender) (err not-authorized))
    (try! (safe-transfer-to-lp token-x-trait tx-sender token-liquidity-trait x))
    (try! (safe-transfer-to-lp token-y-trait tx-sender token-liquidity-trait new-y))
    

    (unwrap! (contract-call? token-liquidity-trait set-lp-data pair-updated token-x token-y) lp-data-set-err)
    (try! (safe-mint token-liquidity-trait recipient-address new-shares))
    (print { object: "pair", action: "liquidity-added", data: pair-updated })
    (ok true)
  )
)
(define-public (reduce-position (token-x-trait <sip-010-token>) (token-y-trait <sip-010-token>) (token-liquidity-trait <liquidity-token>) (percent uint))
  (let
    (
      (token-x (contract-of token-x-trait))
      (token-y (contract-of token-y-trait))
      (pair (unwrap! (contract-call? token-liquidity-trait get-lp-data) lp-data-get-err))
      (balance-x (get balance-x pair))
      (balance-y (get balance-y pair))
      (lp (asserts! (is-eq (get liquidity-token pair) (contract-of token-liquidity-trait)) wrong-token-err))
      (shares (unwrap! (contract-call? token-liquidity-trait get-balance tx-sender) lp-data-get-err))
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

    (asserts!  (is-whitelisted-for-lps tx-sender) (err not-authorized))
    (asserts! (<= percent u100) value-out-of-range-err)

    (try! (safe-transfer-from-lp token-x-trait token-liquidity-trait tx-sender withdrawal-x))
    (try! (safe-transfer-from-lp token-y-trait token-liquidity-trait tx-sender withdrawal-y))


    (unwrap! (contract-call? token-liquidity-trait set-lp-data pair-updated token-x token-y) lp-data-set-err)

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
      (pair (unwrap! (contract-call? token-liquidity-trait get-lp-data) lp-data-get-err))
      (balance-x (get balance-x pair))
      (balance-y (get balance-y pair))
      (contract-address (contract-of token-liquidity-trait))
      (sender tx-sender)
      (dy (/ (* u997 balance-y dx) (+ (* u1000 balance-x) (* u997 dx))))
      (fee (/ (* u5 dx) u10000))
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
    (asserts! (not (is-blacklisted-for-swapping tx-sender)) (err not-authorized))
    (asserts! (< min-dy dy) too-much-slippage-err)

    (try! (safe-transfer-to-lp token-x-trait tx-sender token-liquidity-trait dx))
    (try! (safe-transfer-from-lp token-y-trait token-liquidity-trait tx-sender dy))


    (unwrap! (contract-call? token-liquidity-trait set-lp-data pair-updated token-x token-y) lp-data-set-err)
    (print { object: "pair", action: "swap-x-for-y", data: pair-updated })
    (ok (list dx dy))
  )
)

(define-public (swap-y-for-x (token-x-trait <sip-010-token>) (token-y-trait <sip-010-token>) (token-liquidity-trait <liquidity-token>) (dy uint) (min-dx uint))
  (let ((token-x (contract-of token-x-trait))
        (token-y (contract-of token-y-trait))
        (pair (unwrap! (contract-call? token-liquidity-trait get-lp-data) lp-data-get-err))
        (balance-x (get balance-x pair))
        (balance-y (get balance-y pair))
        (contract-address (contract-of token-liquidity-trait))
        (sender tx-sender)
        (dx (/ (* u997 balance-x dy) (+ (* u1000 balance-y) (* u997 dy)))) 
        (fee (/ (* u5 dy) u10000)) 
        (pair-updated (merge pair {
          balance-x: (- (get balance-x pair) dx),
          balance-y: (+ (get balance-y pair) (- dy fee)),
          fee-balance-y: (+ fee (get fee-balance-y pair))
        })))

    (asserts! (not (is-blacklisted-for-swapping tx-sender)) (err not-authorized))
    (asserts! (< min-dx dx) too-much-slippage-err)

    (try! (safe-transfer-from-lp token-x-trait token-liquidity-trait tx-sender dx))
    (try! (safe-transfer-to-lp token-y-trait tx-sender token-liquidity-trait dy))


    (unwrap! (contract-call? token-liquidity-trait set-lp-data pair-updated token-x token-y) lp-data-set-err)
    (print { object: "pair", action: "swap-y-for-x", data: pair-updated })
    (ok (list dx dy))
  )
)

(define-public (set-fee-to-address (token-x principal) (token-y principal) (token-liquidity-trait <liquidity-token>) (address principal))
  (let (
      (pair (unwrap! (contract-call? token-liquidity-trait get-lp-data) lp-data-get-err))
    )

    (asserts! (is-eq tx-sender contract-owner) not-owner-err)

    (unwrap! (contract-call? token-liquidity-trait set-lp-data {
        shares-total: (get shares-total pair),
        balance-x: (get balance-y pair),
        balance-y: (get balance-y pair),
        fee-balance-x: (get fee-balance-y pair),
        fee-balance-y: (get fee-balance-y pair),
        fee-to-address: address,
        name: (get name pair),
        liquidity-token: (get liquidity-token pair),
      } token-x token-y) lp-data-set-err)
    (ok true)
  )
)

(define-public (collect-fees (token-x-trait <sip-010-token>) (token-y-trait <sip-010-token>) (token-liquidity-trait <liquidity-token>))
  (let
    (
      (token-x (contract-of token-x-trait))
      (token-y (contract-of token-y-trait))
      (pair (unwrap! (contract-call? token-liquidity-trait get-lp-data) lp-data-get-err))
      (address (get fee-to-address pair))
      (fee-x (get fee-balance-x pair))
      (fee-y (get fee-balance-y pair))
    )
    (print {fee-x: fee-x})
    (print {fee-y: fee-y})
    (asserts! (> fee-x u0) no-fee-x-err)
    (asserts! (> fee-y u0) no-fee-y-err)
    (asserts! (is-eq tx-sender address) (err not-authorized))
    
    (try! (safe-transfer-from-lp token-x-trait token-liquidity-trait tx-sender fee-x))
    (try! (safe-transfer-from-lp token-y-trait token-liquidity-trait tx-sender fee-y))
    
    (unwrap! (contract-call? token-liquidity-trait set-lp-data {
        shares-total: (get shares-total pair),
        balance-x: (get balance-x pair),
        balance-y: (get balance-y pair),
        fee-balance-x: u0,
        fee-balance-y: u0,
        fee-to-address: (get fee-to-address pair),
        name: (get name pair),
        liquidity-token: (get liquidity-token pair),
      } token-x token-y) lp-data-set-err)
    (ok (list fee-x fee-y))
  )
)


(map-set roles { role: OWNER_ROLE, account: tx-sender } { allowed: true })
(add-principal-to-role WHITELISTER_ROLE tx-sender)
(add-principal-to-role BLACKLISTER_ROLE tx-sender)
(update-whitelist-for-new-pairs tx-sender true)
(update-whitelist-for-liquidity-providers tx-sender true)