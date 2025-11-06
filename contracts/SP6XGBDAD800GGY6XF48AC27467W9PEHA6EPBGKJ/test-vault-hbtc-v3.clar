;; @contract Vault
;; @version 0.1

(impl-trait .test-vault-trait-v1.vault-trait)

;;-------------------------------------
;; Constants
;;-------------------------------------

(define-constant ERR_DEPOSIT_CAP_EXCEEDED (err u103001))
(define-constant ERR_INVALID_AMOUNT (err u103002))
(define-constant ERR_BELOW_MIN_AMOUNT (err u103003))
(define-constant ERR_NO_CLAIM_FOR_ID (err u103004))
(define-constant ERR_NOT_COOLED_DOWN (err u103005))
(define-constant ERR_ALREADY_FUNDED (err u103006))
(define-constant ERR_NOT_FUNDED (err u103007))

(define-constant share-base (pow u10 u8))
(define-constant bps-base (pow u10 u4))

(define-constant this-contract (as-contract tx-sender))
(define-constant reserve .test-reserve-hbtc-v3)
(define-constant sbtc-token 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token)
(define-constant fee-collector .test-fee-collector-hbtc-v3)

;;-------------------------------------
;; Maps
;;-------------------------------------

(define-map claims
  { 
    claim-id: uint
  }
  {
    user: principal,
    assets: uint,                                 ;; gross asset amount (includes fee)
    fee: uint,                                    ;; fee amount in asset
    ts: uint,                                     ;; timestamp in s claim after cooldown
    is-funded: bool,                              ;; true if the claim has been funded
  }
)

;;-------------------------------------
;; Getters
;;-------------------------------------

;; @desc - calculate how many shares (hBTC tokens) you'd get for a given asset amount
;; @param - assets: amount of underlying asset (sBTC) to convert
;; @return - number of shares (hBTC tokens) that would be minted
(define-read-only (convert-to-shares (assets uint))
  (/ (* assets share-base) (contract-call? .test-state-hbtc-v3 get-share-price))
)

;; @desc - calculate how many assets (sBTC) a given number of shares is worth
;; @param - shares: number of shares (hBTC tokens) to convert
;; @return - amount of underlying asset (sBTC) that would be received
(define-read-only (convert-to-assets (shares uint))
  (/ (* shares (contract-call? .test-state-hbtc-v3 get-share-price)) share-base)
)

(define-read-only (get-claim (id uint))
  (ok (unwrap! (map-get? claims { claim-id: id }) ERR_NO_CLAIM_FOR_ID))
)

(define-private (get-current-ts)
  (unwrap-panic (get-stacks-block-info? time (- stacks-block-height u1)))
)

;;-------------------------------------
;; User
;;-------------------------------------

;; @desc - deposit asset to mint shares
;; @param - asset: amount of asset to deposit (10**8)
;; @param - affiliate: affiliate of the deposit transaction (optional)
(define-public (deposit (assets uint) (affiliate (optional (buff 64))))
  (let (
    (state (contract-call? .test-state-hbtc-v3 get-deposit-state))
    (shares (/ (* assets share-base) (get share-price state)))
  )
    (asserts! (> assets u0) ERR_INVALID_AMOUNT)
    (try! (contract-call? .test-blacklist-vaults-v3 check-is-not-soft contract-caller))
    (try! (contract-call? .test-state-hbtc-v3 check-is-deposit-active))
    (asserts! (<= (+ (get total-assets state) assets) (get deposit-cap state)) ERR_DEPOSIT_CAP_EXCEEDED)
    (asserts! (>= assets (get min-amount state)) ERR_BELOW_MIN_AMOUNT)

    (try! (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token transfer assets contract-caller reserve none))
    (try! (contract-call? .test-state-hbtc-v3 update-state
      (list
        { type: "total-assets", amount: assets, is-add: true })
      none
      (some { amount: shares, is-add: true, user: contract-caller })))
    (print { action: "deposit", user: contract-caller, data: { assets: assets, shares: shares, affiliate: affiliate, total-assets: (get total-assets state) } })
    (ok shares)
  )
)

;; @desc - shared claim creation logic for both withdraw and redeem operations
;; @param - assets: total asset amount (including fees)
;; @param - shares: number of hBTC tokens to burn
(define-private (create-claim (assets uint) (shares uint) (exit-fee uint) (cooldown uint))
  (let (
    (new-claim-id (try! (contract-call? .test-state-hbtc-v3 increment-claim-id)))
    (fee (/ (* assets exit-fee) bps-base))
    (assets-net (- assets fee))
    (ts (+ (get-current-ts) cooldown))
  )
    (map-set claims { claim-id: new-claim-id } 
      {
        user: contract-caller,
        assets: assets,
        fee: fee,
        ts: ts,
        is-funded: false
      }
    )
    (try! (contract-call? .test-state-hbtc-v3 update-state 
      (list 
        { type: "pending-claims", amount: assets, is-add: true })
      none
      (some { amount: shares, is-add: false, user: contract-caller })))
    (print { action: "create-claim", user: contract-caller, data: { claim-id: new-claim-id, shares: shares, assets: assets, fee: fee, cooldown: cooldown, ts: ts } })
    (ok new-claim-id)
  )
)

;; @desc - creates a claim to withdraw asset after cooldown period has passed
;; @param - assets: gross amount of sBTC tokens to withdraw including fees (10**8)
;; @param - is-express: whether the claim is express
(define-public (init-withdraw (assets uint) (is-express bool))
  (let (
    (state (contract-call? .test-state-hbtc-v3 get-withdraw-state contract-caller is-express))
    (shares (/ (* assets share-base) (get share-price state)))
  )
    (asserts! (> assets u0) ERR_INVALID_AMOUNT)
    (try! (contract-call? .test-blacklist-vaults-v3 check-is-not-soft contract-caller))
    (try! (contract-call? .test-state-hbtc-v3 check-is-withdraw-active))

    (let ((claim-id (try! (create-claim assets shares (get exit-fee state) (get cooldown state)))))
      (print { action: "init-withdraw", user: contract-caller, data: { claim-id: claim-id, assets: assets, shares: shares, is-express: is-express } })
      (ok claim-id)
    )
  )
)

;; @desc - creates a claim to redeem shares for assets after cooldown period has passed
;; @param - shares: number of HBTC tokens (shares) to redeem (10**8)
;; @param - is-express: whether the claim is express
(define-public (init-redeem (shares uint) (is-express bool))
  (let (
    (state (contract-call? .test-state-hbtc-v3 get-withdraw-state contract-caller is-express))
    (assets (/ (* shares (get share-price state)) share-base))
  )
    (asserts! (> shares u0) ERR_INVALID_AMOUNT)
    (try! (contract-call? .test-blacklist-vaults-v3 check-is-not-soft contract-caller))
    (try! (contract-call? .test-state-hbtc-v3 check-is-withdraw-active))

    (let ((claim-id (try! (create-claim assets shares (get exit-fee state) (get cooldown state)))))
      (print { action: "init-redeem", user: contract-caller, data: { claim-id: claim-id, assets: assets, shares: shares, is-express: is-express } })
      (ok claim-id)
    )
  )
)

;; @desc - executes a claim for each claim-id in the list
;; @param - entries: list of claim-ids
(define-public (withdraw-many (entries (list 1000 uint)))
  (fold withdraw-iter entries (ok u0))
)

(define-private (withdraw-iter (claim-id uint) (prev (response uint uint)))
  (match prev
    acc 
      (match (withdraw claim-id)
        assets (ok (+ acc assets))
        error (err error)
      )
    error (err error)
  )
)

;; @desc - transfers asset to user after cooldown window has passed
;; @param - claim-id: uint id of the claim
(define-public (withdraw (claim-id uint))
  (let (
    (current-claim (try! (get-claim claim-id)))
    (assets (get assets current-claim))
    (fee (get fee current-claim))
    (user (get user current-claim))
    (assets-net (- assets fee))
  )
    (try! (contract-call? .test-state-hbtc-v3 check-is-withdraw-active))
    (asserts! (>= (get-current-ts) (get ts current-claim)) ERR_NOT_COOLED_DOWN)
    (asserts! (get is-funded current-claim) ERR_NOT_FUNDED)
    (try! (as-contract (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token transfer assets-net this-contract user none)))
    (if (> fee u0)
      (try! (as-contract (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token transfer fee this-contract fee-collector none)))
      true
    )
    (print { action: "withdraw", user: contract-caller, data: { claim-id: claim-id, assets: assets, fee: fee, user: user, fee-address: fee-collector } })
    (map-delete claims { claim-id: claim-id })
    (ok assets-net)
  )
)

;;-------------------------------------
;; Protocol
;;-------------------------------------

(define-public (fund-claim-many (claim-ids (list 1000 uint)))
  (fold fund-claim-iter claim-ids (ok true))
)

(define-private (fund-claim-iter (claim-id uint) (prev (response bool uint)))
  (match prev
    success (fund-claim claim-id)
    error (err error)
  )
)

;; @desc - called by the protocol to fund a claim 
;; @param - claim-id: claim id to fund
(define-public (fund-claim (claim-id uint))
  (let (
    (claim (try! (get-claim claim-id)))
    (assets (get assets claim))
    (is-cooled-down (>= (get-current-ts) (get ts claim)))
    (is-manager (get manager (contract-call? .test-hq-vaults-v3 get-keeper contract-caller)))
  )
    (asserts! (not (get is-funded claim)) ERR_ALREADY_FUNDED)
    (if is-manager true (asserts! is-cooled-down ERR_NOT_COOLED_DOWN)) ;; if the caller is a manager, skip the cooldown check

    (try! (contract-call? .test-reserve-hbtc-v3 transfer sbtc-token assets this-contract))
    (try! (contract-call? .test-state-hbtc-v3 update-state 
      (list
        { type: "total-assets", amount: assets, is-add: false }
        { type: "pending-claims", amount: assets, is-add: false })
      none
      none))
    (map-set claims { claim-id: claim-id } (merge claim { is-funded: true }))
    (print { action: "fund-claim", user: contract-caller, is-manager: is-manager, data: { claim-id: claim-id, claim: (try! (get-claim claim-id)) } })
    (ok true)
  )
)