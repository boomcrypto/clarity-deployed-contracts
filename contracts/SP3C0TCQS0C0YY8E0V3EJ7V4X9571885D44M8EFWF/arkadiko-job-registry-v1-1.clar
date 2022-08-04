;; Arkadiko Automate - Job Registry
;; Keeps track of DIKO balances of principals running registered jobs
;; Each time a job is ran, DIKO is debited from the principal's account
(impl-trait .arkadiko-job-registry-trait-v1.job-registry-trait)
(use-trait automation-trait .arkadiko-automation-trait-v1.automation-trait)
(use-trait cost-trait .arkadiko-job-cost-calculation-trait-v1.cost-calculation-trait)
(use-trait executor-trait .arkadiko-job-executor-trait-v1.job-executor-trait)

(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED u403)
(define-constant ERR-NOT-REGISTERED u404)
(define-constant ERR-CONTRACT-DISABLED u405)
(define-constant ERR-WITHDRAW-DISABLED u406)

(define-data-var last-job-id uint u0)
(define-data-var cost-contract principal .arkadiko-job-cost-calculation-v1-1)
(define-data-var executor-contract principal .arkadiko-job-executor-v1-1)
(define-data-var minimum-fee uint u1000) ;; 0.001 STX min fee
(define-data-var contract-enabled bool true)
(define-data-var withdraw-enabled bool true)

(define-map accounts { owner: principal } { diko: uint, stx: uint, jobs: (list 999 uint) })
(define-map jobs { job-id: uint } { enabled: bool, owner: principal, contract: principal, cost: uint, fee: uint, last-executed: uint, executions: uint })

(define-read-only (get-job-by-id (id uint))
  (default-to
    {
      enabled: false,
      owner: tx-sender,
      contract: tx-sender,
      cost: u0,
      fee: u0,
      last-executed: u0,
      executions: u0
    }
    (map-get? jobs { job-id: id })
  )
)

(define-read-only (get-account-by-owner (owner principal))
  (default-to
    {
      diko: u0,
      stx: u0,
      jobs: (list)
    }
    (map-get? accounts { owner: owner })
  )
)

(define-read-only (get-contract-info)
  {
    last-job-id: (var-get last-job-id),
    cost-contract: (var-get cost-contract),
    executor-contract: (var-get executor-contract),
    minimum-fee: (var-get minimum-fee),
    contract-enabled: (var-get contract-enabled),
    withdraw-enabled: (var-get withdraw-enabled)
  }
)

;; read-only function to check if we should run the job
(define-public (should-run (job-id uint) (job <automation-trait>))
  (let (
    (job-entry (get-job-by-id job-id))
  )
    (asserts! (var-get contract-enabled) (err ERR-CONTRACT-DISABLED))
    (asserts! (is-eq (contract-of job) (get contract job-entry)) (err ERR-NOT-REGISTERED))
    (asserts! (> (get cost job-entry) u0) (err ERR-NOT-REGISTERED))
    (asserts! (get enabled job-entry) (ok false))
    (asserts! (unwrap! (contract-call? job check-job) (ok false)) (ok false))
    (asserts! (>= (get diko (get-account-by-owner (get owner job-entry))) (get cost job-entry)) (ok false))
    (asserts! (>= (get stx (get-account-by-owner (get owner job-entry))) (get fee job-entry)) (ok false))

    (ok true)
  )
)

(define-public (register-job (contract principal) (fee uint) (used-cost-contract <cost-trait>))
  (let (
    (job-id (+ u1 (var-get last-job-id)))
    (cost (contract-call? used-cost-contract calculate-cost contract))
    (min-fee (max-of (var-get minimum-fee) fee))
    (account (get-account-by-owner tx-sender))
  )
    (asserts! (var-get contract-enabled) (err ERR-CONTRACT-DISABLED))
    (asserts! (is-eq (var-get cost-contract) (contract-of used-cost-contract)) (err ERR-NOT-AUTHORIZED))

    (map-set accounts { owner: tx-sender } (merge account { jobs: (unwrap-panic (as-max-len? (append (get jobs account) job-id) u999)) }))
    (map-set jobs { job-id: job-id } { enabled: true, owner: tx-sender, contract: contract, cost: (unwrap-panic cost), fee: min-fee, last-executed: u0, executions: u0 })
    (var-set last-job-id job-id)
    (ok true)
  )
)

(define-public (run-job (job-id uint) (job <automation-trait>) (executor <executor-trait>))
  (let (
    (job-entry (get-job-by-id job-id))
  )
    (asserts! (var-get contract-enabled) (err ERR-CONTRACT-DISABLED))
    (asserts! (is-eq (var-get executor-contract) (contract-of executor)) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-eq true (unwrap! (should-run job-id job) (ok false))) (ok false))

    (try! (contract-call? executor run job))
    (map-set jobs { job-id: job-id } (merge job-entry { last-executed: block-height, executions: (+ (get executions job-entry) u1) }))
    (debit-account job-id)
  )
)

(define-public (credit-account (owner principal) (diko-amount uint) (stx-amount uint))
  (let (
    (account (get-account-by-owner owner))
  )
    (asserts! (var-get contract-enabled) (err ERR-CONTRACT-DISABLED))
    (if (is-eq diko-amount u0)
      false
      (try! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token transfer diko-amount tx-sender (as-contract tx-sender) none))
    )
    (if (is-eq stx-amount u0)
      false
      (try! (stx-transfer? stx-amount tx-sender (as-contract tx-sender)))
    )

    (map-set accounts { owner: owner } (merge account { diko: (+ diko-amount (get diko account)), stx: (+ stx-amount (get stx account)) }))
    (ok true)
  )
)

(define-public (withdraw-account (diko-amount uint) (stx-amount uint))
  (let (
    (owner tx-sender)
    (account (get-account-by-owner owner))
  )
    (asserts! (var-get contract-enabled) (err ERR-CONTRACT-DISABLED))
    (asserts! (var-get withdraw-enabled) (err ERR-WITHDRAW-DISABLED))
    (asserts! (<= diko-amount (get diko account)) (err ERR-NOT-AUTHORIZED))
    (asserts! (<= stx-amount (get stx account)) (err ERR-NOT-AUTHORIZED))

    (if (is-eq diko-amount u0)
      false
      (try! (as-contract (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token transfer diko-amount tx-sender owner none)))
    )
    (if (is-eq stx-amount u0)
      false
      (try! (as-contract (stx-transfer? stx-amount tx-sender owner)))
    )

    (map-set accounts { owner: owner } (merge account { diko: (- (get diko account) diko-amount), stx: (- (get stx account) stx-amount) }))
    (ok true)
  )
)

(define-public (toggle-job-enabled (job-id uint))
  (let (
    (job-entry (get-job-by-id job-id))
  )
    (asserts!
      (or
        (is-eq tx-sender (get owner job-entry))
        (is-eq tx-sender CONTRACT-OWNER)
      )
      (err ERR-NOT-AUTHORIZED)
    )

    (map-set jobs { job-id: job-id } (merge job-entry { enabled: (not (get enabled job-entry)) }))
    (ok true)
  )
)

;;;;;;;;;;;;;;;;;;;;;;;;
;; private functions  ;;
;;;;;;;;;;;;;;;;;;;;;;;;

;; Debits DIKO from the principal's account
(define-private (debit-account (job-id uint))
  (let (
    (job-entry (get-job-by-id job-id))
    (account (get-account-by-owner (get owner job-entry)))
    (sender tx-sender)
  )
    (try! (as-contract (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token transfer (get cost job-entry) tx-sender sender none)))
    (try! (as-contract (stx-transfer? (get fee job-entry) tx-sender sender)))

    (map-set accounts 
      { owner: (get owner job-entry) } 
      (merge account { 
        diko: (- (get diko account) (get cost job-entry)), 
        stx: (- (get stx account) (get fee job-entry)) 
      })
    )

    (ok true)
  )
)

(define-private (max-of (a uint) (b uint))
  (if (> a b)
    a
    b
  )
)

;;;;;;;;;;;;;;;;;;;;;;;;
;; admin functions    ;;
;;;;;;;;;;;;;;;;;;;;;;;;

(define-public (set-cost-contract (contract principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) (err ERR-NOT-AUTHORIZED))

    (ok (var-set cost-contract contract))
  )
)

(define-public (set-minimum-fee (fee uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) (err ERR-NOT-AUTHORIZED))

    (ok (var-set minimum-fee fee))
  )
)

(define-public (set-contract-enabled (enabled bool))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) (err ERR-NOT-AUTHORIZED))

    (ok (var-set contract-enabled enabled))
  )
)

(define-public (set-withdraw-enabled (enabled bool))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) (err ERR-NOT-AUTHORIZED))

    (ok (var-set withdraw-enabled enabled))
  )
)
