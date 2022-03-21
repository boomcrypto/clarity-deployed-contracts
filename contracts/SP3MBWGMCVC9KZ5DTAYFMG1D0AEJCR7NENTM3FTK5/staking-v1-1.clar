;; @contract Staking
;; @version 1

(impl-trait .staking-trait-v1-1.staking-trait)

(use-trait staking-distributor-trait .staking-distributor-trait-v1-1.staking-distributor-trait)
(use-trait treasury-trait .treasury-trait-v1-1.treasury-trait)

;; ------------------------------------------
;; Constants
;; ------------------------------------------

(define-constant ERR-NOT-AUTHORIZED u3003001)

(define-constant ERR-CONTRACT-DISABLED u3001001)

(define-constant ERR-WRONG-DISTRIBUTOR u3002001)

;; ------------------------------------------
;; Variables
;; ------------------------------------------

(define-data-var active-staking-distributor principal .staking-distributor-v1-1)

(define-data-var contract-owner principal tx-sender)
(define-data-var contract-is-enabled bool true)

(define-data-var epoch-length uint u999999999)
(define-data-var epoch-number uint u0)
(define-data-var epoch-end-block uint u999999999)
(define-data-var epoch-distribute uint u0)

;; ------------------------------------------
;; Maps
;; ------------------------------------------

(define-map warmup-info
  { staker: principal }
  {
    deposit: uint,
    fragments: uint,
    expiry: uint,
  }
)

;; ------------------------------------------
;; Var & Map Helpers
;; ------------------------------------------

(define-read-only (get-contract-is-enabled)
  (var-get contract-is-enabled)
)

(define-read-only (get-active-staking-distributor)
  (var-get active-staking-distributor)
)

(define-read-only (get-epoch-length)
  (var-get epoch-length)
)

(define-read-only (get-epoch-number)
  (var-get epoch-number)
)

(define-read-only (get-epoch-end-block)
  (var-get epoch-end-block)
)

(define-read-only (get-epoch-distribute)
  (var-get epoch-distribute)
)

(define-read-only (get-epoch-info)
  (ok {
    epoch-length: (var-get epoch-length),
    epoch-number: (var-get epoch-number),
    epoch-end-block: (var-get epoch-end-block),
    epoch-distribute: (var-get epoch-distribute),
  })
)

(define-read-only (get-warmup-info (staker principal))
  (default-to
    {
      deposit: u0,
      fragments: u0,
      expiry: u0
    }
    (map-get? warmup-info { staker: staker })
  )
)

;; ---------------------------------------------------------
;; Staking
;; ---------------------------------------------------------

(define-public (stake (distributor <staking-distributor-trait>) (treasury <treasury-trait>) (amount uint))
  (let (
    (staker tx-sender)
  )
    (asserts! (var-get contract-is-enabled) (err ERR-CONTRACT-DISABLED))

    ;; Rebase
    (unwrap-panic (rebase distributor treasury))

    ;; Transfer from user
    (try! (contract-call? .lydian-token transfer amount staker (as-contract tx-sender) none))

    ;; Tranfer to user
    (try! (as-contract (contract-call? .staked-lydian-token transfer amount (as-contract tx-sender) staker none)))

    (ok amount)
  )
)

(define-public (unstake (distributor <staking-distributor-trait>) (treasury <treasury-trait>) (amount uint))
  (let (
    (staker tx-sender)

    ;; Rebase
    (rebase-result (rebase distributor treasury))
  )
    (asserts! (var-get contract-is-enabled) (err ERR-CONTRACT-DISABLED))

    ;; Transfer from user
    (try! (contract-call? .staked-lydian-token transfer amount staker (as-contract tx-sender) none))

    ;; Tranfer to user
    (try! (as-contract (contract-call? .lydian-token transfer amount (as-contract tx-sender) staker none)))

    (ok amount)
  )
)

;; ---------------------------------------------------------
;; Warmup
;; ---------------------------------------------------------

(define-public (warmup (staker principal) (amount uint) (warmup-period uint))
  (let (
    (current-warmup-info (get-warmup-info staker))

    (fragments-per-token (contract-call? .staked-lydian-token get-fragments-per-token))
    (fragments-for-amount (* fragments-per-token amount))

    (new-deposit (+ (get deposit current-warmup-info) amount))
    (new-fragments (+ (get fragments current-warmup-info) fragments-for-amount))
    (new-expiry (+ (var-get epoch-number) warmup-period))

  )
    (asserts! (var-get contract-is-enabled) (err ERR-CONTRACT-DISABLED))

    (map-set warmup-info { staker: staker } { deposit: new-deposit, fragments: new-fragments, expiry: new-expiry })
    (ok amount)
  )
)

(define-public (claim)
  (let (
    (staker tx-sender)
    (current-warmup-info (get-warmup-info staker))

    (fragments-per-token (contract-call? .staked-lydian-token get-fragments-per-token))
    (amount (/ (get fragments current-warmup-info) fragments-per-token))
  )
    (asserts! (var-get contract-is-enabled) (err ERR-CONTRACT-DISABLED))

    (if (>= (var-get epoch-number) (get expiry current-warmup-info))
      (begin
        ;; Remove warmup info
        (map-set warmup-info { staker: staker } { deposit: u0, fragments: u0, expiry: u0 })

        ;; Tranfer to user
        (try! (as-contract (contract-call? .staked-lydian-token transfer amount (as-contract tx-sender) staker none)))

        (ok amount)
      )
      (ok u0)
    )
  )
)

;; ---------------------------------------------------------
;; Rebase
;; ---------------------------------------------------------

(define-public (rebase (distributor <staking-distributor-trait>) (treasury <treasury-trait>))
  (if (<= (var-get epoch-end-block) block-height)
    (begin
      (asserts! (var-get contract-is-enabled) (err ERR-CONTRACT-DISABLED))
      (asserts! (is-eq (contract-of distributor) (var-get active-staking-distributor)) (err ERR-WRONG-DISTRIBUTOR))

      ;; Rebase sLDN
      (unwrap-panic (as-contract (contract-call? .staked-lydian-token rebase (var-get epoch-distribute))))

      ;; Update epoch end block
      (var-set epoch-end-block (+ (var-get epoch-end-block) (var-get epoch-length)))

      ;; Update epoch number
      (var-set epoch-number (+ (var-get epoch-number) u1))

      ;; Get new rewards from distributor
      (try! (as-contract (contract-call? distributor distribute treasury)))

      ;; Update epoch distribute
      (var-set epoch-distribute (unwrap-panic (get-next-epoch-distribute)))

      (ok (var-get epoch-distribute))
    )
    (ok u0)
  )
)

(define-read-only (get-next-epoch-distribute)
  (let (
      (contract-balance (unwrap-panic (contract-call? .lydian-token get-balance (as-contract tx-sender))))
      (circulating-supply (unwrap-panic (contract-call? .staked-lydian-token get-circulating-supply)))
    )
      (if (<= contract-balance circulating-supply)
        (ok u0)
        (ok (- contract-balance circulating-supply))
      )
    )
)

;; ---------------------------------------------------------
;; Admin
;; ---------------------------------------------------------

(define-public (set-epoch-info (length uint) (end-block uint))
  (begin
    (asserts! (is-eq tx-sender .lydian-dao) (err ERR-NOT-AUTHORIZED))
    (var-set epoch-length length)
    (var-set epoch-end-block end-block)
    (ok true)
  )
)

(define-public (set-active-staking-distributor (distributor principal))
  (begin
    (asserts! (is-eq tx-sender .lydian-dao) (err ERR-NOT-AUTHORIZED))
    (var-set active-staking-distributor distributor)
    (ok true)
  )
)

(define-public (set-contract-is-enabled (enabled bool))
  (begin
    (asserts! (is-eq tx-sender .lydian-dao) (err ERR-NOT-AUTHORIZED))
    (var-set contract-is-enabled enabled)
    (ok true)
  )
)

(define-public (migrate-funds (recipient principal))
  (let (
    (ldn-balance (unwrap-panic (contract-call? .lydian-token get-balance (as-contract tx-sender))))
    (sldn-balance (unwrap-panic (contract-call? .staked-lydian-token get-balance (as-contract tx-sender))))
  )
    (asserts! (is-eq tx-sender .lydian-dao) (err ERR-NOT-AUTHORIZED))
    
    ;; Transfer LDN
    (if (> ldn-balance u0)
      (try! (as-contract (contract-call? .lydian-token transfer ldn-balance (as-contract tx-sender) recipient none)))
      true
    )

    ;; Transfer sLDN
    (if (> sldn-balance u0)
      (try! (as-contract (contract-call? .staked-lydian-token transfer sldn-balance (as-contract tx-sender) recipient none)))
      true
    )

    (ok true)
  )
)
