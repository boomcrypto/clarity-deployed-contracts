;; traits

(define-trait sip-010-trait
  (
    (transfer (uint principal principal (optional (buff 34))) (response bool uint))
  )
)

;; errors
(define-constant err-unwrap (err u404))
(define-constant err-admin (err u401))
(define-constant err-amount (err u400))
(define-constant err-paused (err u503))
(define-constant err-transfer (err u888))

;; per-deploy-constants

(define-constant STAKING-TOKEN 'SP1W7FX8P1G721KQMQ2MA2G1G4WCVVPD9JZMGXK8R.wstx-aeusdc)
(define-constant REWARD-TOKEN 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc)

;; constants

(define-constant PRECISION u1000000000) ;; 10^9
(define-constant SECONDS_IN_YEAR u1000000)
(define-constant AVR_BLOCK_TIME u600) ;; 10m

;; state

(define-data-var admin principal tx-sender)
(define-data-var total-staked uint u0)
(define-data-var last-rewarded-block uint block-height)
(define-data-var cumulative-sum uint u0)
(define-data-var rate-percent uint u0)
(define-data-var paused bool false)

(define-map users
  principal
  {
    reward: uint,
    staked: uint,
    cumulative-sum: uint,
  }
)

;; read-only funcs

(define-read-only (get-total-staked) (var-get total-staked))

(define-read-only (get-last-rewarded-block) (var-get last-rewarded-block))

(define-read-only (get-rate) (var-get rate-percent))

(define-read-only (get-future-cummulative-sum)
  (if (or (<= (var-get total-staked) u0) (>= (var-get last-rewarded-block) block-height))
    (ok (var-get cumulative-sum))
    (ok 
      (+ 
        (/ 
          (* 
            (- 
              block-height 
              (var-get last-rewarded-block)
            ) 
            AVR_BLOCK_TIME
            (var-get rate-percent)
          )
          SECONDS_IN_YEAR
        )
        (var-get cumulative-sum)
      )
    )
  )
)

(define-read-only (calculate-cumulatives (user principal))
  (let (
    (user-reward (get reward (map-get? users user)))
    (user-staked (get staked (map-get? users user)))
    (user-cummulative (get cumulative-sum (map-get? users user)))
    (new-cummulative (unwrap! (get-future-cummulative-sum) (err err-unwrap)))
  )
    (ok
      {
        reward: 
          (+
            (/
              (* 
                (- new-cummulative (default-to u0 user-cummulative))
                (default-to u0 user-staked)
              )
              PRECISION
            )
            (default-to u0 user-reward)
          ),
        cummulative: new-cummulative
      }
    )
  )
)

(define-read-only (get-user-reward (user principal))
  (let (
    (datac (calculate-cumulatives user))
  )
    (ok datac)
  )
)

(define-read-only (get-user (user principal))
  (let (
    (user-info (default-to { reward: u0, staked: u0, cumulative-sum: u0 } (map-get? users user)))
    (cummulatives (unwrap! (calculate-cumulatives user) (err err-unwrap)))
  )
    (ok
      {
        reward: (get reward cummulatives),
        staked: (get staked user-info)
      }
    )
  )
)

;; private funcs

(define-private (update-cummulative-values (user principal)) 
  (let (
    (cummulatives (unwrap! (calculate-cumulatives user) (err err-unwrap)))
    (user-staked (get staked (map-get? users user)))
  )
    (var-set last-rewarded-block block-height)
    (var-set cumulative-sum (get cummulative cummulatives))
    (map-set users user
      {
        reward: (get reward cummulatives),
        staked: (default-to u0 user-staked),
        cumulative-sum: (get cummulative cummulatives),
      }
    )
    (ok true)
  )
)

(define-private (set-user-staked (user principal) (new-staked uint)) 
  (let (
    (user-info (default-to { reward: u0, staked: u0, cumulative-sum: u0 } (map-get? users user)))
  )
    (map-set users user
      {
        reward: (get reward user-info),
        staked: new-staked,
        cumulative-sum: (get cumulative-sum user-info),
      }
    )
    (ok true)
  )
)

(define-private (reset-user-reward (user principal)) 
  (let (
    (user-info (default-to { reward: u0, staked: u0, cumulative-sum: u0 } (map-get? users user)))
  )
    (map-set users user
      {
        reward: u0,
        staked: (get staked user-info),
        cumulative-sum: (get cumulative-sum user-info),
      }
    )
    (ok true)
  )
)

;; admin funcs

(define-public (update-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err err-admin))
    (var-set admin new-admin)
    (ok true)
  )
)

(define-public (update-rate (new-rate uint))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err err-admin))
    (var-set rate-percent new-rate)
    (ok true)
  )
)

(define-public (set-paused (new-paused bool))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err err-admin))
    (var-set paused new-paused)
    (ok true)
  )
)

(define-public (recover-reward (amt uint))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err err-admin))

    (unwrap! (transfer-helper REWARD-TOKEN amt contract-caller tx-sender) (err err-transfer))

    (ok true)
  )
)

(define-public (recover-body (amt uint))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err err-admin))

    (unwrap! (transfer-helper STAKING-TOKEN amt contract-caller tx-sender) (err err-transfer))

    (ok true)
  )
)

;;

(define-private (transfer-helper (token <sip-010-trait>) (amt uint) (from principal) (to principal))
  (ok (try! (as-contract (contract-call? token transfer amt from to none))))
)

;; public funcs

(define-public (stake (amt uint))
  (begin
    (asserts! (> amt u0) (err err-amount))
    (asserts! (not (var-get paused)) (err err-paused))

    (let (
      (user-staked (get staked (unwrap! (map-get? users tx-sender) (err err-unwrap))))
    )
      (unwrap! (transfer-helper STAKING-TOKEN amt tx-sender contract-caller) (err err-transfer))

      (unwrap! (update-cummulative-values tx-sender) (err err-unwrap))
      (var-set total-staked (+ amt (var-get total-staked)))
      (unwrap! (set-user-staked tx-sender (+ amt user-staked)) (err err-unwrap))

      (let (
        (event {
            type: "stake",
            user: tx-sender,
            amt: amt,
            block: block-height,
          })
        )
        (print event)
        (ok event)
      )
    )
  )
)

(define-public (withdraw (amt uint))
  (begin
    (asserts! (> amt u0) (err err-amount))
    (asserts! (not (var-get paused)) (err err-paused))

    (let (
      (user-staked (default-to u0 (get staked (map-get? users tx-sender))))
    )
      (asserts! (>= user-staked amt) (err err-amount))

      (unwrap! (update-cummulative-values tx-sender) (err err-unwrap))
      (var-set total-staked (- (var-get total-staked) amt))
      (unwrap! (set-user-staked tx-sender (- user-staked amt)) (err err-unwrap))

      (unwrap! (transfer-helper STAKING-TOKEN amt contract-caller tx-sender) (err err-transfer))

      (let (
        (event {
            type: "withdraw",
            user: tx-sender,
            amt: amt,
            block: block-height,
          })
        )
        (print event)
        (ok event)
      )
    )
  )
)

(define-public (claim)
  (begin
    (asserts! (not (var-get paused)) (err err-paused))
    (unwrap! (update-cummulative-values tx-sender) (err err-transfer))

    (let (
      (user      tx-sender)
      (amt (default-to u0 (get reward (map-get? users user))))
    )
      (asserts! (> amt u0) (err err-amount))

      (unwrap! (reset-user-reward tx-sender) (err err-transfer))

      (unwrap! (transfer-helper REWARD-TOKEN amt contract-caller tx-sender) (err err-transfer))

      (let (
        (event {
            type: "claim",
            user: user,
            amt: amt,
            block: block-height,
          })
        )
        (print event)
        (ok event)
      )
    )
  )
)
