;; @contract Treasury
;; @version 1.1

(impl-trait .treasury-trait-v1-1.treasury-trait)
(use-trait ft-trait .sip-010-trait-ft-standard.sip-010-trait)
(use-trait value-calculator-trait .value-calculator-trait-v1-1.value-calculator-trait)

;; ------------------------------------------
;; Constants
;; ------------------------------------------

(define-constant ERR-NOT-AUTHORIZED u2003001)
(define-constant ERR-DEBTOR-NOT-AUTHORIZED u2003002)
(define-constant ERR-DEPOSITOR-NOT-AUTHORIZED u2003003)

(define-constant ERR-CONTRACT-DISABLED u2001001)

(define-constant ERR-WRONG-VALUE-CALCULATOR u2002001)

(define-constant ERR-RESERVE-TOKEN-NOT-ENABLED u2000001)
(define-constant ERR-INSUFFICIENT-RESERVES u2000002)
(define-constant ERR-EXCEED-DEBT-LIMIT u2000003)

;; ------------------------------------------
;; Variables
;; ------------------------------------------

(define-data-var contract-is-enabled bool true)

(define-data-var total-reserves uint u0)
(define-data-var total-debt uint u0)

;; ------------------------------------------
;; Maps
;; ------------------------------------------

(define-map minter-info
  { minter: principal }
  {
    enabled: bool
  }
)

(define-map debtor-info
  { 
    debtor: principal,
    token: principal
  }
  {
    enabled: bool
  }
)

(define-map depositor-info
  { 
    depositor: principal,
    token: principal
  }
  {
    enabled: bool
  }
)

(define-map reserve-tokens
  { token: principal }
  {
    enabled: bool,
    last-total-token-value: uint,
    liquidity-token: bool,
    value-calculator: principal
  }
)

;; ------------------------------------------
;; Var & Map Helpers
;; ------------------------------------------

(define-read-only (get-contract-is-enabled)
  (var-get contract-is-enabled)
)

(define-read-only (get-minter-info (minter principal))
  (default-to
    {
      enabled: false,
    }
    (map-get? minter-info { minter: minter })
  )
)

(define-read-only (get-debtor-info (debtor principal) (token principal))
  (default-to
    {
      enabled: false,
    }
    (map-get? debtor-info { debtor: debtor, token: token })
  )
)

(define-read-only (get-depositor-info (depositor principal) (token principal))
  (default-to
    {
      enabled: false,
    }
    (map-get? depositor-info { depositor: depositor, token: token })
  )
)

(define-read-only (get-total-reserves)
  (var-get total-reserves)
)

(define-read-only (get-total-debt)
  (var-get total-debt)
)

(define-read-only (get-reserve-token (token principal))
  (default-to
    {
      enabled: false,
      last-total-token-value: u0,
      liquidity-token: false,
      value-calculator: .treasury-v1-1
    }
    (map-get? reserve-tokens { token: token })
  )
)

;; ------------------------------------------
;; Mutative
;; ------------------------------------------

(define-public (mint (recipient principal) (amount uint))
  (let (
    (minter-enabled (get enabled (get-minter-info contract-caller)))

    (excess-reserves (unwrap-panic (get-excess-reserves)))
  )
    (asserts! (var-get contract-is-enabled) (err ERR-CONTRACT-DISABLED))
    (asserts! minter-enabled (err ERR-NOT-AUTHORIZED))
    (asserts! (<= amount excess-reserves) (err ERR-INSUFFICIENT-RESERVES))

    (contract-call? .lydian-token mint recipient amount)
  )
)

;; ------------------------------------------
;; Managerial
;; ------------------------------------------

(define-public (audit-reserve-token (token-trait <ft-trait>) (value-calculator <value-calculator-trait>))
  (let (
    (token-balance (unwrap-panic (contract-call? token-trait get-balance (as-contract tx-sender))))
    (token-value (unwrap-panic (get-token-value token-trait value-calculator token-balance)))

    (token (contract-of token-trait))
    (token-map (get-reserve-token (contract-of token-trait)))
    (token-last-total-value (get last-total-token-value token-map))

    (new-total-reserves (+ (- (var-get total-reserves) token-last-total-value) token-value))
  )
    (asserts! (get enabled token-map) (err ERR-RESERVE-TOKEN-NOT-ENABLED))
    (asserts! (is-eq (get value-calculator token-map) (contract-of value-calculator)) (err ERR-RESERVE-TOKEN-NOT-ENABLED))

    (map-set reserve-tokens { token: token } (merge token-map { last-total-token-value: token-value }))
    (var-set total-reserves new-total-reserves)

    (ok new-total-reserves)
  )
)

;; ------------------------------------------
;; Value
;; ------------------------------------------

(define-public (get-excess-reserves)
  (let (
    (total-supply (unwrap-panic (contract-call? .lydian-token get-total-supply)))
    (supply-min-debt (- total-supply (var-get total-debt)))
  )
    (if (>= (var-get total-reserves) supply-min-debt)
      (ok (- (var-get total-reserves) supply-min-debt))
      (ok u0)
    )
  )
)

(define-public (get-token-value (token-trait <ft-trait>) (value-calculator <value-calculator-trait>) (amount uint))
  (let (
    (token-map (get-reserve-token (contract-of token-trait)))
  )
    (if (and 
      (is-eq (contract-of value-calculator) (get value-calculator token-map))
      (get enabled token-map)
    )
      (contract-call? value-calculator get-valuation token-trait amount)
      (ok u0)
    )
  )
)

;; ------------------------------------------
;; Deposits
;; ------------------------------------------

(define-public (deposit (token-trait <ft-trait>) (value-calculator <value-calculator-trait>) (amount uint) (profit uint))
  (let (
    (depositor tx-sender)
    (token-map (get-reserve-token (contract-of token-trait)))
    (value (unwrap-panic (get-token-value token-trait value-calculator amount)))
    (value-min-profit (- value profit))

    (depositor-enabled (get enabled (get-depositor-info depositor (contract-of token-trait))))
  )
    (asserts! (var-get contract-is-enabled) (err ERR-CONTRACT-DISABLED))
    (asserts! depositor-enabled (err ERR-DEPOSITOR-NOT-AUTHORIZED))
    (asserts! (is-eq (contract-of value-calculator) (get value-calculator token-map)) (err ERR-WRONG-VALUE-CALCULATOR))

    (try! (contract-call? token-trait transfer amount depositor (as-contract tx-sender) none))

    (try! (as-contract (contract-call? .lydian-token mint depositor value-min-profit)))

    (try! (audit-reserve-token token-trait value-calculator))

    (ok amount)
  )
)

(define-public (withdraw (token-trait <ft-trait>) (value-calculator <value-calculator-trait>) (amount uint))
  (let (
    (depositor tx-sender)
    (token-map (get-reserve-token (contract-of token-trait)))
    (value (unwrap-panic (get-token-value token-trait value-calculator amount)))

    (depositor-enabled (get enabled (get-depositor-info depositor (contract-of token-trait))))
  )
    (asserts! (var-get contract-is-enabled) (err ERR-CONTRACT-DISABLED))
    (asserts! depositor-enabled (err ERR-DEPOSITOR-NOT-AUTHORIZED))
    (asserts! (is-eq (contract-of value-calculator) (get value-calculator token-map)) (err ERR-WRONG-VALUE-CALCULATOR))

    (try! (as-contract (contract-call? token-trait transfer amount (as-contract tx-sender) depositor none)))

    (try! (as-contract (contract-call? .lydian-token burn depositor value)))

    (try! (audit-reserve-token token-trait value-calculator))

    (ok amount)
  )
)

;; ------------------------------------------
;; Debt
;; ------------------------------------------

(define-public (incur-debt (token-trait <ft-trait>) (value-calculator <value-calculator-trait>) (amount uint))
  (let (
    (debtor tx-sender)
    (token-map (get-reserve-token (contract-of token-trait)))
    (value (unwrap-panic (get-token-value token-trait value-calculator amount)))
    (debtor-enabled (get enabled (get-debtor-info debtor (contract-of token-trait))))

    (available-debt (unwrap-panic (contract-call? .staked-lydian-token get-available-debt debtor)))
  )
    (asserts! (var-get contract-is-enabled) (err ERR-CONTRACT-DISABLED))
    (asserts! debtor-enabled (err ERR-DEBTOR-NOT-AUTHORIZED))
    (asserts! (>= available-debt value) (err ERR-EXCEED-DEBT-LIMIT))
    (asserts! (is-eq (contract-of value-calculator) (get value-calculator token-map)) (err ERR-WRONG-VALUE-CALCULATOR))

    (try! (as-contract (contract-call? .staked-lydian-token change-debt value debtor true)))

    (var-set total-debt (+ (var-get total-debt) value))

    (try! (as-contract (contract-call? token-trait transfer amount (as-contract tx-sender) debtor none)))

    (try! (audit-reserve-token token-trait value-calculator))

    (ok amount)
  )
)

(define-public (repay-debt (token-trait <ft-trait>) (value-calculator <value-calculator-trait>) (amount uint))
  (let (
    (debtor tx-sender)
    (token-map (get-reserve-token (contract-of token-trait)))
    (value (unwrap-panic (get-token-value token-trait value-calculator amount)))
    (debtor-enabled (get enabled (get-debtor-info debtor (contract-of token-trait))))
  )
    (asserts! (var-get contract-is-enabled) (err ERR-CONTRACT-DISABLED))
    (asserts! debtor-enabled (err ERR-DEBTOR-NOT-AUTHORIZED))
    (asserts! (is-eq (contract-of value-calculator) (get value-calculator token-map)) (err ERR-WRONG-VALUE-CALCULATOR))

    (try! (as-contract (contract-call? .staked-lydian-token change-debt value debtor false)))

    (var-set total-debt (- (var-get total-debt) value))

    (try! (contract-call? token-trait transfer amount debtor (as-contract tx-sender) none))

    (try! (audit-reserve-token token-trait value-calculator))

    (ok amount)
  )
)

;; ---------------------------------------------------------
;; Admin
;; ---------------------------------------------------------

(define-public (transfer-tokens (token <ft-trait>) (amount uint) (recipient principal) (value-calculator <value-calculator-trait>))
  (let (
    (token-map (get-reserve-token (contract-of token)))
  )
    (asserts! (is-eq tx-sender .lydian-dao) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-eq (contract-of value-calculator) (get value-calculator token-map)) (err ERR-WRONG-VALUE-CALCULATOR))

    (try! (audit-reserve-token token value-calculator))
    (try! (as-contract (contract-call? token transfer amount (as-contract tx-sender) recipient none)))
    (ok true)
  )
)

(define-public (enable-reserve-token (token-trait <ft-trait>) (liquidity-token bool) (value-calculator principal))
  (let (
    (token (contract-of token-trait))
    (token-map (get-reserve-token token))
  )
    (asserts! (is-eq tx-sender .lydian-dao) (err ERR-NOT-AUTHORIZED))

    (map-set reserve-tokens { token: token } (merge token-map { 
      enabled: true, 
      liquidity-token: liquidity-token, 
      value-calculator: value-calculator 
    }))
    (ok true)
  )
)

(define-public (disable-reserve-token (token-trait <ft-trait>))
  (let (
    (token (contract-of token-trait))
    (token-map (get-reserve-token token))
  )
    (asserts! (is-eq tx-sender .lydian-dao) (err ERR-NOT-AUTHORIZED))

    (map-set reserve-tokens { token: token } (merge token-map { enabled: false }))
    (ok true)
  )
)

(define-public (set-active-minter-info (minter principal) (enabled bool))
  (begin
    (asserts! (is-eq tx-sender .lydian-dao) (err ERR-NOT-AUTHORIZED))

    (map-set minter-info { minter: minter } { enabled: enabled })
    (ok true)
  )
)

(define-public (set-debtor-info (debtor principal) (token principal) (enabled bool))
  (begin
    (asserts! (is-eq tx-sender .lydian-dao) (err ERR-NOT-AUTHORIZED))

    (map-set debtor-info { debtor: debtor, token: token } { enabled: enabled })
    (ok true)
  )
)

(define-public (set-depositor-info (depositor principal) (token principal) (enabled bool))
  (begin
    (asserts! (is-eq tx-sender .lydian-dao) (err ERR-NOT-AUTHORIZED))

    (map-set depositor-info { depositor: depositor, token: token } { enabled: enabled })
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

(define-public (migrate-funds (token-trait <ft-trait>) (recipient principal))
  (let (
    (token-balance (unwrap-panic (contract-call? token-trait get-balance (as-contract tx-sender))))
  )
    (asserts! (is-eq tx-sender .lydian-dao) (err ERR-NOT-AUTHORIZED))
    
    ;; Transfer token
    (if (> token-balance u0)
      (try! (as-contract (contract-call? token-trait transfer token-balance (as-contract tx-sender) recipient none)))
      true
    )

    (ok true)
  )
)
