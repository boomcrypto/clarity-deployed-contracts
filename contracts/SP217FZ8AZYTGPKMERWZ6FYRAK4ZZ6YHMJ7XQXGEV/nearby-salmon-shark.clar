(define-constant ERR-NOT-AUTHORIZED u401)
(define-constant ERR-ALREADY-APPROVED u402)
(define-constant ERR-NOT-APPROVED u403)
(define-constant ERR-LIST-OVERFLOW u404)
(define-constant ERR-REFERRALS-PAUSED u405)
;; End of Constants

(define-data-var admin principal tx-sender)

;; Paused flag for referral rewards
(define-data-var paused bool false)

;; Map: collection contract -> base reward in microstx
(define-map referral-reward principal uint)

;; Map: collection contract -> { reward: uint, expiration: uint } (bonus reward and expiration stacks-block-height)
(define-map referral-bonus principal { reward: uint, expiration: uint })

;; List of approved contracts
(define-data-var approved-contracts (list 100 principal) (list))
(define-data-var removing-contract principal tx-sender)

;; Helper function to filter out a contract from the list
(define-private (remove-contract-from-list (address principal))
  (not (is-eq address (var-get removing-contract))))

;; Map: referral code -> { total: uint, recipient: principal }
(define-map total-rewards (string-ascii 30) { total: uint, recipient: principal })

;; Spoint referral bonus (default u0)
(define-data-var spoint-referral-bonus uint u0)

;; Read-only: get spoint referral bonus
(define-read-only (get-spoint-referral-bonus)
  (var-get spoint-referral-bonus))

;; Admin-only: set spoint referral bonus
(define-public (set-spoint-referral-bonus (bonus uint))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err ERR-NOT-AUTHORIZED))
    (var-set spoint-referral-bonus bonus)
    (ok true)))

;; === Deposit and Withdraw STX ===

(define-public (deposit (amount uint))
  (begin
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
    (ok true)))

(define-public (admin-withdraw)
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err ERR-NOT-AUTHORIZED))
    (let ((balance (as-contract (stx-get-balance tx-sender))))
      (as-contract 
        (stx-transfer? balance tx-sender (var-get admin))))))

;; === Manage rewards for collections ===

(define-public (set-referral-reward (col principal) (reward uint))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err ERR-NOT-AUTHORIZED))
    (map-set referral-reward col reward)
    (ok true)))

(define-public (set-referral-bonus (col principal) (bonus uint) (expiration uint))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err ERR-NOT-AUTHORIZED))
    (map-set referral-bonus col { reward: bonus, expiration: expiration })
    (ok true)))

(define-read-only (get-referral-reward (col principal))
  (default-to u0 (map-get? referral-reward col)))

(define-read-only (get-referral-reward-bonus (col principal))
  (let ((bonus-entry (map-get? referral-bonus col)))
    (match bonus-entry some-entry
      (if (<= stacks-block-height (get expiration some-entry))
          (get reward some-entry)
          u0)
      u0)))

(define-read-only (get-contract-info)
  {
    contract-balance: (stx-get-balance (as-contract tx-sender)),
    admin: (var-get admin),
    paused: (var-get paused)
    })
;; === Manage contract approval ===

(define-public (approve-contract-address (addr principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-none (index-of (var-get approved-contracts) addr)) (err ERR-ALREADY-APPROVED))
    (ok (var-set approved-contracts
      (unwrap-panic (as-max-len? (append (var-get approved-contracts) addr) u100))))))

(define-public (remove-approved-contract-address (addr principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err ERR-NOT-AUTHORIZED))
    (var-set removing-contract addr)
    (ok (var-set approved-contracts (filter remove-contract-from-list (var-get approved-contracts))))))

(define-read-only (is-approved-contract (addr principal))
  (ok (is-some (index-of (var-get approved-contracts) addr))))

(define-read-only (get-approved-contracts)
  (ok (var-get approved-contracts)))

;; === Admin: Pause or unpause referral rewards ===
(define-public (set-referrals-paused (pause bool))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err ERR-NOT-AUTHORIZED))
    (var-set paused pause)
    (ok true)))

;; === Distribute referral rewards ===

(define-public (handout-referral-reward 
  (referral-code (string-ascii 30)) 
  (col principal)
  (qty uint)
  (spc_id (optional uint))
)
  (begin
    (asserts! (not (var-get paused)) (err ERR-REFERRALS-PAUSED))
    ;; Check if sender is approved
    (asserts! (is-some (index-of (var-get approved-contracts) tx-sender)) (err ERR-NOT-APPROVED))
    ;; Lookup address from code
    (let ((ref-addr-opt (contract-call? .modern-amethyst-albatross get-referral-address referral-code)))
      (match ref-addr-opt some-ref-addr
        (let (
          (base (get-referral-reward col))
          (bonus (get-referral-reward-bonus col))
          (spoint-bonus (var-get spoint-referral-bonus))
          (total-reward (* qty (+ base bonus)))
          (existing (map-get? total-rewards referral-code))
        )
          (asserts! (> total-reward u0) (err u100))
          (try! (as-contract (stx-transfer? total-reward (as-contract tx-sender) some-ref-addr)))
          ;; If spoint-bonus > 0 and spc_id is provided, call collect on spoints contract
          (if (and (> spoint-bonus u0) (is-some spc_id))
            (try! (contract-call? .spoints collect (unwrap! spc_id (err u998)) (* spoint-bonus qty)))
            true)
          ;; Update total-rewards
          (map-set total-rewards referral-code {
            total: (+ total-reward (if (is-some existing) (get total (unwrap! existing (err u999))) u0)),
            recipient: some-ref-addr
          })
          (print { action: "handout-referral-reward", code: referral-code, address: some-ref-addr, reward: total-reward })
          (ok true))
        (err u404)))))

(define-read-only (get-total-reward (code (string-ascii 30)))
  (let ((entry (map-get? total-rewards code)))
    (match entry some-entry (get total some-entry) u0)))