;; === Error Constants ===
(define-constant ERR-NOT-AUTHORIZED u401)
(define-constant ERR-ALREADY-APPROVED u402)
(define-constant ERR-NOT-APPROVED u403)
(define-constant ERR-LIST-OVERFLOW u404)
(define-constant ERR-REFERRALS-PAUSED u405)
(define-constant ERR-NO-REWARD u406)
(define-constant ERR-MISSING-SPC-ID u407)
(define-constant ERR-NO-EXISTING-RECORD u408)
(define-constant ERR-REFERRAL-NOT-FOUND u409)
(define-constant ERR-SENDER-IS-REFERRAL u410)

;; === Admin and State Variables ===
(define-data-var admin principal tx-sender)
(define-data-var paused bool false)
(define-data-var approved-contracts (list 100 principal) (list ))
(define-data-var removing-contract principal tx-sender)

;; === Referral Rewards ===
(define-map referral-reward principal uint)
(define-map referral-bonus principal { reward: uint, expiration: uint })
(define-data-var spoint-referral-bonus uint u0)

;; === Helper Functions ===
(define-private (remove-contract-from-list (address principal))
  (not (is-eq address (var-get removing-contract))))

;; === Read-Only Functions ===
(define-read-only (get-spoint-referral-bonus-reward)
  (var-get spoint-referral-bonus))

(define-read-only (get-referral-reward (col principal))
  (default-to u0 (map-get? referral-reward col)))

(define-read-only (get-referral-reward-bonus (col principal))
  (let ((entry (default-to {expiration: u0, reward: u0} (map-get? referral-bonus col))))
    (if (<= tenure-height (get expiration entry))
        (get reward entry)
        u0)))

(define-read-only (get-tenure-height) tenure-height)

(define-read-only (get-contract-info)
  {
    contract-balance: (stx-get-balance (as-contract tx-sender)),
    admin: (var-get admin),
    paused: (var-get paused)
  })

(define-read-only (is-approved-contract (addr principal))
  (ok (is-some (index-of (var-get approved-contracts) addr))))

(define-read-only (get-approved-contracts)
  (ok (var-get approved-contracts)))

(define-read-only (get-total-reward (col principal))
  (+ (get-referral-reward col) (get-referral-reward-bonus col)))

;; === Public Functions ===
(define-public (set-spoint-referral-bonus-reward (bonus uint))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err ERR-NOT-AUTHORIZED))
    (var-set spoint-referral-bonus bonus)
    (ok true)))

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

(define-public (set-referral-reward (col principal) (reward uint))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err ERR-NOT-AUTHORIZED))
    (map-set referral-reward col reward)
    (ok true)))

(define-public (set-referral-bonus-reward (col principal) (bonus uint) (expiration uint))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err ERR-NOT-AUTHORIZED))
    (map-set referral-bonus col { reward: bonus, expiration: expiration })
    (ok true)))

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

(define-public (set-referrals-paused (pause bool))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err ERR-NOT-AUTHORIZED))
    (var-set paused pause)
    (ok true)))

(define-public (handout-referral-reward 
  (referral-code (string-ascii 30)) 
  (col principal)
  (qty uint)
  (spc_id (optional uint))
)
  (begin
    (asserts! (not (var-get paused)) (err ERR-REFERRALS-PAUSED))
    (asserts! (is-some (index-of (var-get approved-contracts) contract-caller)) (err ERR-NOT-APPROVED))
    (let (
      (some-ref-addr (unwrap! (contract-call? .balanced-harlequin-ocelot get-referral-address referral-code) (err ERR-REFERRAL-NOT-FOUND)))
      (base (get-referral-reward col))
      (bonus (get-referral-reward-bonus col))
      (spoint-bonus (var-get spoint-referral-bonus))
      (total-reward (* qty (+ base bonus)))
    )
      (asserts! (not (is-eq some-ref-addr tx-sender)) (err ERR-SENDER-IS-REFERRAL))
      (asserts! (> total-reward u0) (err ERR-NO-REWARD))
      (try! (as-contract (stx-transfer? total-reward (as-contract tx-sender) some-ref-addr)))
      (if (and (> spoint-bonus u0) (is-some spc_id))
        (try! (contract-call? .spoints collect (unwrap! spc_id (err ERR-MISSING-SPC-ID)) (* spoint-bonus qty)))
        true)
      (ok true))))