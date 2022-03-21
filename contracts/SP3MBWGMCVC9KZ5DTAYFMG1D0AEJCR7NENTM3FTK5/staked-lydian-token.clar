;; @contract Staked Lydian SIP-010
;; @version 1

(impl-trait .sip-010-trait-ft-standard.sip-010-trait)

(define-fungible-token staked-lydian)

;; ------------------------------------------
;; Constants
;; ------------------------------------------

(define-constant ERR-NOT-AUTHORIZED u1203001)

(define-constant ERR-CONTRACT-DISABLED u1201001)

(define-constant ERR-WRONG-STAKING u1202001)
(define-constant ERR-WRONG-TREASURY u1202002)

(define-constant ERR-DEBT u1200002)

(define-constant TOTAL-FRAGMENTS u1000000000000000000000000000)

;; ------------------------------------------
;; Variables
;; ------------------------------------------

(define-data-var token-uri (string-utf8 256) u"")
(define-data-var contract-owner principal tx-sender)
(define-data-var contract-is-enabled bool true)

(define-data-var active-staking principal .staking-v1-1)
(define-data-var active-treasury principal .treasury-v1-1)

(define-data-var index uint u0)
(define-data-var fragments-per-token uint u0)

;; ------------------------------------------
;; Maps
;; ------------------------------------------

(define-map account-fragments
  { account: principal }
  {
    fragments: uint
  }
)

(define-map debt-balances
  { account: principal }
  {
    debt: uint
  }
)

;; ------------------------------------------
;; Var & Map Helpers
;; ------------------------------------------

(define-read-only (get-contract-is-enabled)
  (var-get contract-is-enabled)
)

(define-read-only (get-active-staking)
  (var-get active-staking)
)

(define-read-only (get-active-treasury)
  (var-get active-treasury)
)

(define-read-only (get-index)
  (/ (var-get index) (var-get fragments-per-token))
)

(define-read-only (get-fragments-per-token)
  (var-get fragments-per-token)
)

(define-read-only (get-account-fragments (account principal))
  (default-to
    {
      fragments: u0,
    }
    (map-get? account-fragments { account: account })
  )
)

(define-read-only (get-debt-balance (account principal))
  (default-to
    {
      debt: u0,
    }
    (map-get? debt-balances { account: account })
  )
)

;; ---------------------------------------------------------
;; SIP-10 Functions
;; ---------------------------------------------------------

(define-read-only (get-total-supply)
  (ok (ft-get-supply staked-lydian))
)

(define-read-only (get-name)
  (ok "Staked Lydian Token")
)

(define-read-only (get-symbol)
  (ok "sLDN")
)

(define-read-only (get-decimals)
  (ok u6)
)

(define-read-only (get-balance (account principal))
  (ok (ft-get-balance staked-lydian account))
)

(define-public (set-token-uri (value (string-utf8 256)))
  (if (is-eq tx-sender .lydian-dao)
    (ok (var-set token-uri value))
    (err ERR-NOT-AUTHORIZED)
  )
)

(define-read-only (get-token-uri)
  (ok (some (var-get token-uri)))
)

(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (let (
    (fragments-to-transfer (* amount (var-get fragments-per-token)))

    (sender-fragments (get fragments (get-account-fragments sender)))
    (recipient-fragments (get fragments (get-account-fragments recipient)))

    (new-sender-fragments (- sender-fragments fragments-to-transfer))
    (new-recipient-fragments (+ recipient-fragments fragments-to-transfer))

    (current-sender-balance (unwrap-panic (get-balance sender)))
    (new-sender-balance (- current-sender-balance amount))
    (sender-debt (get debt (get-debt-balance sender)))
  )
    (asserts! (var-get contract-is-enabled) (err ERR-CONTRACT-DISABLED))
    (asserts! (is-eq tx-sender sender) (err ERR-NOT-AUTHORIZED))
    (asserts! (>= new-sender-balance sender-debt) (err ERR-DEBT))

    (try! (match (ft-transfer? staked-lydian amount sender recipient)
      response (begin
        (print memo)
        (ok response)
      )
      error (err error)
    ))
    
    (map-set account-fragments { account: sender } { fragments: new-sender-fragments })
    (map-set account-fragments { account: recipient } { fragments: new-recipient-fragments })

    (ok true)
  )
)

;; ---------------------------------------------------------
;; Rebase
;; ---------------------------------------------------------

(define-public (rebase (profit uint))
  (let (
    (rebase-amount (unwrap-panic (get-rebase-amount profit)))
    (new-total-supply (+ (unwrap-panic (get-total-supply)) rebase-amount))
    (new-fragments-per-token (/ TOTAL-FRAGMENTS new-total-supply))

    (staking-fragments (get fragments (get-account-fragments (var-get active-staking))))
    (current-staking-tokens (/ staking-fragments (var-get fragments-per-token)))
    (new-staking-tokens (/ staking-fragments new-fragments-per-token))
    (rebase-amount-staking (- new-staking-tokens current-staking-tokens))
    (rebase-amount-users (- rebase-amount rebase-amount-staking))
  )
    (asserts! (var-get contract-is-enabled) (err ERR-CONTRACT-DISABLED))
    (asserts! (is-eq contract-caller (var-get active-staking)) (err ERR-WRONG-STAKING))

    (if (is-eq rebase-amount u0)
      true
      (begin
        (if (is-eq rebase-amount-staking u0)
          true
          (try! (ft-mint? staked-lydian rebase-amount-staking (var-get active-staking)))
        )
        (if (is-eq rebase-amount-users u0)
          true
          (try! (ft-mint? staked-lydian rebase-amount-users (as-contract tx-sender)))
        )
      )
    )

    (var-set fragments-per-token new-fragments-per-token)
    (ok new-total-supply)  
  )
)

(define-public (claim-rebase)
  (let (
    (account tx-sender)
    (diff (unwrap-panic (get-claim-rebase account)))
  )
    (asserts! (var-get contract-is-enabled) (err ERR-CONTRACT-DISABLED))
    (if (is-eq diff u0)
      true
      (try! (match (ft-transfer? staked-lydian diff (as-contract tx-sender) account)
        response (begin
          (print "claim-rebase")
          (ok response)
        )
        error (err error)
      ))
    )
    (ok diff)
  )
)

;; ---------------------------------------------------------
;; Debt
;; ---------------------------------------------------------

(define-public (change-debt (amount uint) (debtor principal) (add bool))
  (let (
    (current-debt (get debt (get-debt-balance debtor)))
  )
    (asserts! (var-get contract-is-enabled) (err ERR-CONTRACT-DISABLED))
    (asserts! (is-eq contract-caller (var-get active-treasury)) (err ERR-WRONG-TREASURY))
    (if add
      (begin
        (map-set debt-balances { account: debtor } { debt: (+ current-debt amount) })
        (ok (+ current-debt amount))
      )
      (begin
        (map-set debt-balances { account: debtor } { debt: (- current-debt amount) })
        (ok (- current-debt amount))
      )
    )
  )
)

(define-read-only (get-available-debt (debtor principal))
  (let (
    (current-debt (get debt (get-debt-balance debtor)))
    (current-balance (unwrap-panic (get-balance debtor)))
  )
    (ok (- current-balance current-debt))
  )
)

;; ---------------------------------------------------------
;; Getters
;; ---------------------------------------------------------

(define-read-only (get-circulating-supply)
  (let (
    (current-total-supply (unwrap-panic (get-total-supply)))
    (staking-balance (unwrap-panic (get-balance (var-get active-staking))))
  )
    (ok (- current-total-supply staking-balance))
  )
)

(define-public (get-claim-rebase (account principal))
  (let (
    (fragments (get fragments (get-account-fragments account)))
    (new-balance (/ fragments (var-get fragments-per-token)))
    (current-balance (unwrap-panic (get-balance account)))
    (diff (- new-balance current-balance))
  )
    (ok diff)
  )
)

(define-read-only (get-rebase-amount (profit uint))
 (let (
    (circulating-supply (unwrap-panic (get-circulating-supply)))
    (current-total-supply (unwrap-panic (get-total-supply)))
  )
    (if (is-eq profit u0)
      (ok u0)
      (if (is-eq circulating-supply u0)
        (ok profit)
        (ok (/ (* profit current-total-supply) circulating-supply))
      )
    )
  )
)

;; ---------------------------------------------------------
;; Admin
;; ---------------------------------------------------------

(define-public (set-active-staking (staking principal))
  (begin
    (asserts! (is-eq tx-sender .lydian-dao) (err ERR-NOT-AUTHORIZED))

    (var-set active-staking staking)
    (ok true)
  )
)

(define-public (set-active-treasury (treasury principal))
  (begin
    (asserts! (is-eq tx-sender .lydian-dao) (err ERR-NOT-AUTHORIZED))

    (var-set active-treasury treasury)
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
    (sldn-balance (unwrap-panic (get-balance (as-contract tx-sender))))
  )
    (asserts! (is-eq tx-sender .lydian-dao) (err ERR-NOT-AUTHORIZED))
    
    ;; Transfer sLDN
    (if (> sldn-balance u0)
      (try! (as-contract (transfer sldn-balance (as-contract tx-sender) recipient none)))
      true
    )

    (ok true)
  )
)

;; ---------------------------------------------------------
;; Mint / Burn
;; ---------------------------------------------------------

(define-public (mint (recipient principal) (amount uint))
  (let (
    (fragments-to-add (* (var-get fragments-per-token) amount))
    (recipient-fragments (get fragments (get-account-fragments recipient)))
    (new-recipient-fragments (+ recipient-fragments fragments-to-add))
  )
    (asserts! (is-eq tx-sender .lydian-dao) (err  ERR-NOT-AUTHORIZED))
    (map-set account-fragments { account: recipient } { fragments: new-recipient-fragments })
    (ft-mint? staked-lydian amount recipient)
  )
)

(define-public (burn (recipient principal) (amount uint))
  (let (
    (fragments-to-remove (* (var-get fragments-per-token) amount))
    (recipient-fragments (get fragments (get-account-fragments recipient)))
    (new-recipient-fragments (- recipient-fragments fragments-to-remove))

    (current-balance (unwrap-panic (get-balance recipient)))
    (current-debt (get debt (get-debt-balance recipient)))
  )
    (asserts!
      (or
        (is-eq tx-sender .lydian-dao)
        (is-eq contract-caller recipient)
      )
      (err ERR-NOT-AUTHORIZED)
    )
    (asserts! (>= (- current-balance current-debt) amount) (err ERR-DEBT))
    (map-set account-fragments { account: recipient } { fragments: new-recipient-fragments })
    (ft-burn? staked-lydian amount recipient)
  )
)

;; ---------------------------------------------------------
;; Init
;; ---------------------------------------------------------

(let (
  (initial-fragments u5000000000000)
  (new-fragments-per-token (/ TOTAL-FRAGMENTS initial-fragments))
)
  (try! (ft-mint? staked-lydian initial-fragments (var-get active-staking)))
  (var-set fragments-per-token new-fragments-per-token)
  (var-set index (* new-fragments-per-token u1000000))

  (map-set account-fragments { account: (var-get active-staking) } { fragments: TOTAL-FRAGMENTS })
)
