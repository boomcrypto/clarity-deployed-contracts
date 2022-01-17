;;(impl-trait 'SP000000000000000000002Q6VF78.pool-registry.pox-trait))
(define-constant err-missing-user-pox-addr u100)
(define-constant err-map-set-failed u101)
(define-constant err-pox-failed u102)
(define-constant err-delegate-below-minimum u103)
(define-constant err-missing-user u104)
(define-constant err-non-positive-amount u105)

(define-map user-data principal {pox-addr: (tuple (hashbytes (buff 20)) (version (buff 1))), cycle: uint, locking-period: uint})
(define-map stackers-by-start-cycle {reward-cycle: uint, index: uint}
  (list 30 {lock-amount: uint, stacker: principal, unlock-burn-height: uint, pox-addr: (tuple (hashbytes (buff 20)) (version (buff 1))), cycle: uint, locking-period: uint}))
(define-map stackers-by-start-cycle-len uint uint)
(define-map totals-by-start-cycle uint uint)

;; Backport of .pox's burn-height-to-reward-cycle
(define-private (burn-height-to-reward-cycle (height uint))
    (let (
        (pox-info (unwrap-panic (contract-call? 'SP000000000000000000002Q6VF78.pox get-pox-info)))
    )
    (/ (- height (get first-burnchain-block-height pox-info)) (get reward-cycle-length pox-info)))
)

;; Backport of .pox's reward-cycle-to-burn-height
(define-private (reward-cycle-to-burn-height (cycle uint))
    (let (
        (pox-info (unwrap-panic (contract-call? 'SP000000000000000000002Q6VF78.pox get-pox-info)))
    )
    (+ (get first-burnchain-block-height pox-info) (* cycle (get reward-cycle-length pox-info))))
)

;; What's the current PoX reward cycle?
(define-private (current-pox-reward-cycle)
    (burn-height-to-reward-cycle burn-block-height))


(define-private (pox-get-stacker-info (user principal))
   (contract-call? 'SP000000000000000000002Q6VF78.pox get-stacker-info user))

(define-private (pox-delegate-stx (amount-ustx uint) (delegate-to principal) (until-burn-ht (optional uint)))
  (if (> amount-ustx u100)
    (let ((result-revoke (contract-call? 'SP000000000000000000002Q6VF78.pox revoke-delegate-stx)))
      (match (contract-call? 'SP000000000000000000002Q6VF78.pox delegate-stx amount-ustx delegate-to until-burn-ht none)
        success (ok success)
        error (err {kind: "delegate-stx-failed", code: (to-uint error)})
      ))
    (err {kind: "permission-denied", code: err-delegate-below-minimum})))

(define-private (min (amount-1 uint) (amount-2 uint))
  (if (< amount-1 amount-2)
    amount-1
    amount-2))

(define-private (asserts-panic (value bool))
  (unwrap-panic (if value (some true) none)))

(define-private (merge-details (stacker {lock-amount: uint, stacker: principal, unlock-burn-height: uint}) (user {pox-addr: (tuple (hashbytes (buff 20)) (version (buff 1))), cycle: uint, locking-period: uint}))
  {lock-amount: (get lock-amount stacker),
  stacker: (get stacker stacker),
  unlock-burn-height: (get unlock-burn-height stacker),
  pox-addr: (get pox-addr user),
  cycle: (get cycle user),
  locking-period: (get locking-period user)})

(define-private (insert-in-new-list (reward-cycle uint) (last-index uint) (details {lock-amount: uint, stacker: principal, unlock-burn-height: uint, pox-addr: (tuple (hashbytes (buff 20)) (version (buff 1))), cycle: uint, locking-period: uint}))
  (let ((index (+ last-index u1)))
    (asserts-panic (map-insert stackers-by-start-cycle (print {reward-cycle: reward-cycle, index: index}) (list details)))
    (asserts-panic (map-set stackers-by-start-cycle-len reward-cycle index))))

(define-private (map-set-details (details {lock-amount: uint, stacker: principal, unlock-burn-height: uint, pox-addr: (tuple (hashbytes (buff 20)) (version (buff 1))), cycle: uint, locking-period: uint}))
  (let ((reward-cycle (+ (burn-height-to-reward-cycle burn-block-height) u1)))
    (let ((last-index (get-status-list-length reward-cycle)))
      (match (map-get? stackers-by-start-cycle {reward-cycle: reward-cycle, index: last-index})
        stackers (match (as-max-len? (append stackers details) u30)
                new-list (map-set stackers-by-start-cycle (print {reward-cycle: reward-cycle, index: last-index}) new-list)
                (insert-in-new-list reward-cycle last-index details))
        (map-insert stackers-by-start-cycle (print {reward-cycle: reward-cycle, index: last-index}) (list details)))
      (map-set totals-by-start-cycle reward-cycle (+ (get-total reward-cycle) (get lock-amount details))))))

(define-private (pox-delegate-stack-stx (details {user: principal, amount-ustx: uint})
                  (context (tuple
                      (pox-address (tuple (hashbytes (buff 20)) (version (buff 1))))
                      (start-burn-ht uint)
                      (lock-period uint)
                      (result (list 30 (response (tuple (lock-amount uint) (stacker principal) (unlock-burn-height uint)) (tuple (kind (string-ascii 32)) (code uint))))))))
  (let ((user (get user details)))
    (let ((pox-address (get pox-address context))
        (start-burn-ht (get start-burn-ht context))
        (lock-period (get lock-period context))
        (amount-ustx (min (get amount-ustx details) (stx-get-balance user))))
      (let ((stack-result
        (if (> amount-ustx u0)
          (match (map-get? user-data user)
            user-details
              (match (contract-call? 'SP000000000000000000002Q6VF78.pox delegate-stack-stx
                          user amount-ustx
                          pox-address start-burn-ht lock-period)
                stacker-details  (begin
                              (map-set-details (merge-details stacker-details user-details))
                              (ok stacker-details))
                error (err {kind: "native-function-failed", code: (to-uint error)}))
            (err {kind: "user-not-found", code: err-missing-user}))
          (err {kind: "invalid-amount", code: err-non-positive-amount}))))
        {pox-address: pox-address,
          start-burn-ht: start-burn-ht,
          lock-period: lock-period,
          result: (unwrap-panic (as-max-len? (append (get result context) stack-result) u30))}))))

(define-public (delegate-stx (amount-ustx uint) (delegate-to principal) (until-burn-ht (optional uint))
              (pool-pox-addr (optional (tuple (hashbytes (buff 20)) (version (buff 1)))))
              (user-pox-addr (tuple (hashbytes (buff 20)) (version (buff 1))))
              (locking-period uint))
  (begin
    (asserts! (map-set user-data tx-sender
                {pox-addr: user-pox-addr, cycle: (current-pox-reward-cycle), locking-period: locking-period})
      (err {kind: "map-fn-failed", code: err-map-set-failed}))
    (pox-delegate-stx amount-ustx delegate-to until-burn-ht)))



(define-public (delegate-stack-stx (users (list 30 (tuple
                                      (user principal)
                                      (amount-ustx uint))))
                                    (pox-address { version: (buff 1), hashbytes: (buff 20) })
                                    (start-burn-ht uint)
                                    (lock-period uint))
    (let ((stack-result (get result (fold pox-delegate-stack-stx users {start-burn-ht: start-burn-ht, pox-address: pox-address, lock-period: lock-period, result: (list)}))))
      (ok stack-result)))


(define-read-only (get-status (user principal))
  (match (pox-get-stacker-info user)
    stacker-info  (match (map-get? user-data user)
      user-info (ok {stacker-info: stacker-info, user-info: user-info, total: (get-total (get first-reward-cycle stacker-info))})
      (err {kind: "no-user-info"}))
    (err {kind: "no-stacker-info"})))

(define-read-only (get-status-list-length (reward-cycle uint))
  (default-to u0 (map-get? stackers-by-start-cycle-len reward-cycle))
)

(define-read-only (get-status-list (reward-cycle uint) (index uint))
  {total: (get-total reward-cycle),
  status-list: (map-get? stackers-by-start-cycle {reward-cycle: reward-cycle, index: index})}
)

(define-read-only (get-total (reward-cycle uint))
  (default-to u0 (map-get? totals-by-start-cycle reward-cycle))
)
