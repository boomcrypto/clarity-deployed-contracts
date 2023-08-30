(define-constant err-forbidden (err u403))
(define-constant err-not-found (err u404))
(define-constant err-too-early (err u500))
(define-constant err-insufficient-funds (err u501))
(define-constant err-insufficient-rewards (err u502))
(define-constant err-unexpected (err u999))

(define-constant pox-info (unwrap-panic (contract-call? 'SP000000000000000000002Q6VF78.pox-3 get-pox-info)))
(define-data-var rewards-admin principal tx-sender)
(define-data-var reward-balance uint u0)
(define-data-var last-reward-id uint u0)

(define-map rewards uint {
  cycle: uint,
  amount-ustx: uint,
  total-stacked: uint})

(define-map unspent-amounts-ustx uint uint)

(define-map distributions {cycle: uint, user: principal} uint)

(define-data-var ctx-reward {
  cycle: uint,
  reward-id: uint,
  amount-ustx: uint,
  total-stacked: uint,
  id-header-hash: (buff 32)}
  {cycle: u0, reward-id: u0, amount-ustx: u0, total-stacked: u0, id-header-hash: 0x})
(define-data-var ctx-unspent-amount-ustx uint u0)

(define-public (distribute-rewards-many (users (list 200 principal)) (reward-id uint))
  (let ((unspent (unwrap! (map-get? unspent-amounts-ustx reward-id) err-not-found)))
    (try! (set-ctx-reward reward-id))
    (match (fold distribute-reward-internal users (ok unspent))
      success
        (begin
          (map-set unspent-amounts-ustx reward-id success)
          (ok true))
      error (err error))))


(define-public (distribute-rewards (user principal) (reward-id uint))
  (let ((unspent (unwrap! (map-get? unspent-amounts-ustx reward-id) err-not-found)))
    (try! (set-ctx-reward reward-id))
    (match (distribute-reward-internal user (ok unspent))
      success
        (begin
          (map-set unspent-amounts-ustx reward-id success)
          (ok true))
      error (err error))))

;; distribute a share of the current reward slice to the user
(define-private (distribute-reward-internal (user principal) (unspent-result (response uint uint)))
  (match unspent-result
    unspent
    ;; distribute up to unspent rewards
    (let (
      (reward (var-get ctx-reward))
      (cycle (get cycle reward))
      (received-rewards (map-get? distributions {cycle: cycle, user: user}))
      (id-header-hash (get id-header-hash reward))
      (user-stacked (get-user-stacked user id-header-hash))
      (share-ustx (calculate-share
                      (get amount-ustx reward)
                      user-stacked
                      (get total-stacked reward)))
      (current-reward-balance (var-get reward-balance)))
      ;; if the user already received rewards, just continue
      (asserts! (is-none received-rewards) (ok unspent))
      ;; check that there is enough stx to transfer
      (asserts! (>= unspent share-ustx) err-insufficient-funds)
      (asserts! (>= current-reward-balance share-ustx) err-insufficient-rewards)
      (if (> share-ustx u0)
        (begin
          (try! (as-contract (stx-transfer-memo? share-ustx tx-sender user 0x72657761726473)))
          (var-set reward-balance (- (var-get reward-balance) share-ustx))
          (ok (- unspent share-ustx)))
        (ok unspent)))
    error-unspent (err error-unspent)))



(define-private (add-rewards (amount uint) (cycle uint))
  (let ((reserved-balance (var-get reward-balance))
    (new-reserved-balance (+ reserved-balance amount))
    (balance (as-contract (stx-get-balance tx-sender)))
    (reward-id (+ (var-get last-reward-id) u1))
    (total-stacked (unwrap! (get-total-stacked cycle) err-not-found)))
    ;; rewards can only be added after the end of the cycle
    (asserts! (> burn-block-height (+ (get first-burnchain-block-height pox-info) (* (get reward-cycle-length pox-info) (+ cycle u1)))) err-too-early)
    ;; amount must be less or equal than the unallocated balance
    (asserts! (<= new-reserved-balance balance) err-insufficient-funds)
    (var-set reward-balance new-reserved-balance)
    (var-set last-reward-id reward-id)
    (map-set unspent-amounts-ustx reward-id amount)
    (asserts!
      (map-insert rewards reward-id
        {cycle: cycle, amount-ustx: amount, total-stacked: total-stacked}) err-unexpected)
    (ok reward-id)
  ))

(define-private (remove-all-rewards (reward-id uint))
  (let (
      (reserved-reward-balance (var-get reward-balance))
      (reward-details (unwrap! (map-get? rewards reward-id) err-not-found))
      (unspent-ustx (unwrap! (map-get? unspent-amounts-ustx reward-id) err-not-found)))
    (asserts! (>= reserved-reward-balance unspent-ustx) err-unexpected)
    (var-set reward-balance (- reserved-reward-balance unspent-ustx))
    (map-delete rewards reward-id)
    (map-delete unspent-amounts-ustx reward-id)
    (ok true)))

;; used during reward distribution to improve performance
(define-private (set-ctx-reward (reward-id uint))
  (let (
    (reward-details (unwrap! (map-get? rewards reward-id) err-not-found))
    (last-commit (unwrap! (contract-call? .pox-fast-pool-v2 get-last-aggregation (get cycle reward-details)) err-not-found))
    (id-header-hash (unwrap! (get-block-info? id-header-hash last-commit) err-not-found)))
  (var-set ctx-reward (merge {id-header-hash: id-header-hash, reward-id: reward-id}
    reward-details))
  (ok true)))

;;
;; Reward admin functions
;;

;; Security method: reward admin can withdraw STX from the contract unconditionally
(define-public (withdraw-stx (amount uint))
  (let ((reward-admin tx-sender))
    (asserts! (is-rewards-admin) err-forbidden)
    (as-contract (stx-transfer? amount tx-sender reward-admin))))

;; Method 1: reward admin deposits STX
(define-public (deposit-rewards (amount uint) (cycle uint))
  (begin
    (asserts! (is-rewards-admin) err-forbidden)
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
    (add-rewards amount cycle)))

(define-public (withdraw-rewards (amount uint) (reward-id uint))
  (begin
    (try! (withdraw-stx amount))
    (remove-all-rewards reward-id)))

;; Method 2: wrapped rewards are send to pool directly and
;; allocated by the reward admin to the cycle
(define-public (allocate-funds (amount uint) (cycle uint))
  (begin
    (asserts! (is-rewards-admin) err-forbidden)
    (add-rewards amount cycle)))

(define-public (desallocate-funds (reward-id uint))
  (begin
    (asserts! (is-rewards-admin) err-forbidden)
    (remove-all-rewards reward-id)))

;; Change admin
(define-public (set-rewards-admin (new-admin principal))
  (begin
    (asserts! (is-rewards-admin) err-forbidden)
    (ok (var-set rewards-admin new-admin))))

;;
;;  Read-only functions
;;

(define-read-only (get-user-stacked (user principal) (id-header-hash (buff 32)))
  (get locked (at-block id-header-hash (stx-account user))))

(define-read-only (calculate-share (total-reward-amount-ustx uint)
                    (user-stacked uint)
                    (total-stacked uint))
  (/ (* total-reward-amount-ustx user-stacked) total-stacked))

(define-read-only (get-total-stacked (cycle-id uint))
  (let (
      (reward-set-index (unwrap! (contract-call? .pox-fast-pool-v2 get-pox-addr-index cycle-id) err-not-found)))
    (ok (get total-ustx (unwrap!
      (contract-call? 'SP000000000000000000002Q6VF78.pox-3
        get-reward-set-pox-address
        cycle-id reward-set-index) err-not-found)))))

(define-read-only (is-rewards-admin)
  (is-eq contract-caller (var-get rewards-admin)))

(define-read-only (get-total-reward-balance)
  (var-get reward-balance))

(define-read-only (get-unspent-balance (reward-id uint))
  (map-get? unspent-amounts-ustx reward-id))

(define-read-only (get-reward-details (reward-id uint))
  (map-get? rewards reward-id))

(define-read-only (get-last-reward-id)
  (var-get last-reward-id))

(define-read-only (get-distribution (cycle uint) (user principal))
  (map-get? distributions {cycle: cycle, user: user}))
