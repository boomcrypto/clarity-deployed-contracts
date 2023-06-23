;; extend up to 30 FAST pool users every stacking cycle
(impl-trait 'SP3C0TCQS0C0YY8E0V3EJ7V4X9571885D44M8EFWF.arkadiko-automation-trait-v1.automation-trait)

(define-map commits uint uint)
(define-data-var users (list 30 principal) (list))

(define-constant deployer tx-sender)
(define-constant pox-info (unwrap-panic (contract-call? 'SP000000000000000000002Q6VF78.pox-3 get-pox-info)))
(define-constant cycle-length (get reward-cycle-length pox-info))
(define-constant half-cycle-length (/ (get reward-cycle-length pox-info) u2))
(define-constant first-burnchain-block-height (get first-burnchain-block-height pox-info))

(define-read-only (burn-height-to-reward-cycle (height uint))
    (/ (- height first-burnchain-block-height) cycle-length))

;; What's the block height at the start of a given reward cycle?
(define-read-only (reward-cycle-to-burn-height (cycle uint))
    (+ first-burnchain-block-height (* cycle cycle-length)))

;; What's the current PoX reward cycle?
(define-read-only (current-pox-reward-cycle)
    (burn-height-to-reward-cycle burn-block-height))

(define-public (initialize)
  (ok true)
)

(define-read-only (check-job)
  (let ((reward-cycle (current-pox-reward-cycle))
        (start-of-cycle (reward-cycle-to-burn-height reward-cycle)))
    ;; only run job after half of the cycle
    (asserts! (> burn-block-height (+ half-cycle-length start-of-cycle)) (ok false))
    ;; only run job for at least 1 user
    (asserts! (> (len (var-get users)) u0) (ok false))
    ;; only run job once per cycle
    (ok (is-none (map-get? commits (+ u1 reward-cycle))))))

(define-public (run-job)
  (let ((next-cycle (+ u1 (current-pox-reward-cycle))))
    (asserts! (unwrap-panic (check-job)) (ok false))
    (map-insert commits next-cycle block-height)
    (try! (contract-call? .pox-fast-pool-v2 delegate-stack-stx-many (var-get users)))
    (ok true)))

(define-read-only (get-commit (reward-cycle uint))
    (map-get? commits reward-cycle))

(define-public (set-users (new-users (list 30 principal)))
  (begin
    (asserts! (is-eq tx-sender deployer) (err u401))
    (ok (var-set users new-users))))
