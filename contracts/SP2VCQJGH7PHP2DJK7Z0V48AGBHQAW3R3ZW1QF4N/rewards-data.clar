(define-constant ERR_UNAUTHORIZED (err u7003))

(define-map user-program-index { who: principal, asset: principal, reward-asset: principal } uint)
(define-public (set-user-program-index (who principal) (asset principal) (reward-asset principal) (index uint))
  (begin
    (try! (is-approved-contract contract-caller))
    (print { type: "set-user-program-index", payload: { key: { who: who, asset: asset, reward-asset: reward-asset }, data: index } })
    (ok (map-set user-program-index { who: who, asset: asset, reward-asset: reward-asset } index))))
(define-public (get-user-program-index (who principal) (asset principal) (reward-asset principal))
    (ok (map-get? user-program-index { who: who, asset: asset, reward-asset: reward-asset })))
(define-read-only (get-user-program-index-read (who principal) (asset principal) (reward-asset principal))
    (map-get? user-program-index { who: who, asset: asset, reward-asset: reward-asset }))

(define-map price principal uint)
(define-public (set-price (asset principal) (new-price uint))
  (begin
    (try! (is-approved-contract contract-caller))
    (print { type: "set-price", payload: { key: asset, data: new-price } })
    (ok (map-set price asset new-price))))
(define-public (get-price (asset principal))
    (ok (map-get? price asset)))
(define-read-only (get-price-read (asset principal))
    (map-get? price asset))


(define-map reward-program-income { supplied-asset: principal, reward-asset: principal } {
    last-updated-block: uint,
    last-liquidity-cumulative-index: uint,
    liquidity-rate: uint
})
(define-public (set-reward-program-income (supplied-asset principal) (reward-asset principal) (new-income {
    last-updated-block: uint,
    last-liquidity-cumulative-index: uint,
    liquidity-rate: uint
}))
  (begin
    (try! (is-approved-contract contract-caller))
    (print { type: "set-reward-program-income", payload: { key: { supplied-asset: supplied-asset, reward-asset: reward-asset }, data: new-income } })
    (ok (map-set reward-program-income { supplied-asset: supplied-asset, reward-asset: reward-asset } new-income))))
(define-public (get-reward-program-income (supplied-asset principal) (reward-asset principal))
    (ok (map-get? reward-program-income { supplied-asset: supplied-asset, reward-asset: reward-asset })))
(define-read-only (get-reward-program-income-read (supplied-asset principal) (reward-asset principal))
    (map-get? reward-program-income { supplied-asset: supplied-asset, reward-asset: reward-asset }))

(define-map asset-precision principal uint)
(define-public (set-asset-precision (asset principal) (new-precision uint))
  (begin
    (try! (is-approved-contract contract-caller))
    (print { type: "set-asset-precision", payload: { key: asset, data: new-precision } })
    (ok (map-set asset-precision asset new-precision))))
(define-public (get-asset-precision (asset principal))
    (ok (map-get? asset-precision asset)))
(define-read-only (get-asset-precision-read (asset principal))
    (map-get? asset-precision asset))

(define-data-var rewards-contract principal .incentives)
(define-public (set-rewards-contract (contract principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR_UNAUTHORIZED)
    (print { type: "set-rewards-contract", payload: contract })
    (ok (var-set rewards-contract contract))))
(define-public (get-rewards-contract)
  (ok (var-get rewards-contract)))
(define-read-only (get-rewards-contract-read)
  (var-get rewards-contract))

;; -- ownable-trait --
(define-data-var contract-owner principal tx-sender)
(define-public (set-contract-owner (owner principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR_UNAUTHORIZED)
    (print { type: "set-contract-owner-pool-reserve-data", payload: owner })
    (ok (var-set contract-owner owner))))

(define-public (get-contract-owner)
  (ok (var-get contract-owner)))
(define-read-only (get-contract-owner-read)
  (var-get contract-owner))

(define-read-only (is-contract-owner (caller principal))
  (is-eq caller (var-get contract-owner)))

;; -- permissions
(define-map approved-contracts principal bool)

(define-public (set-approved-contract (contract principal) (enabled bool))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR_UNAUTHORIZED)
    (ok (map-set approved-contracts contract enabled))))

(define-public (delete-approved-contract (contract principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR_UNAUTHORIZED)
    (ok (map-delete approved-contracts contract))))

(define-read-only (is-approved-contract (contract principal))
  (if (default-to false (map-get? approved-contracts contract))
    (ok true)
    ERR_UNAUTHORIZED))
