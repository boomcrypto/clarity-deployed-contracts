;; (impl-trait 'ST1NXBK3K5YYMD6FD41MVNP3JS1GABZ8TRVX023PT.sip-010-trait-ft-standard.sip-010-trait)
(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)
;; Poolmind Arbitrage Fund
;;
;; A Clarity smart contract for a pooled crypto arbitrage fund.
;; Users deposit STX into the contract and receive "PoolMind" (PLMD) tokens,
;; which represent their proportional stake in the fund's Net Asset Value (NAV).
;; These shares can be redeemed at any time for the corresponding amount of STX based on the current NAV.
;;
;; Features:
;; - Deposit STX to mint PoolMind tokens.
;; - Withdraw STX by burning PoolMind tokens.
;; - Admin-controlled NAV updates to reflect fund performance.
;; - Custom SIP-010 Fungible Token with optional transferability.
;; - Configurable entry and exit fees.
;; - Emergency controls for pausing contract activity.
;; - Historical NAV tracking and event emissions for transparency.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; 1. Constants, Errors, and Data Storage
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; --- Constants ---
(define-constant CONTRACT_OWNER tx-sender)
(define-constant TOKEN_PRECISION u1000000) ;; Corresponds to 6 decimals
;; --- Error Codes ---
(define-constant ERR_NOT_AUTHORIZED u101)
(define-constant ERR_PAUSED u102)
(define-constant ERR_TRANSFERS_DISABLED u103)
(define-constant ERR_INSUFFICIENT_BALANCE u104)
(define-constant ERR_ZERO_DEPOSIT u105)
(define-constant ERR_ZERO_WITHDRAWAL u106)
(define-constant ERR_NAV_NOT_POSITIVE u107)
(define-constant ERR_SELF_TRANSFER u108)
(define-constant ERR_INSUFFICIENT_STX_BALANCE u109)
;; --- Data Variables ---
(define-data-var admin-address principal CONTRACT_OWNER)
(define-data-var is-paused bool false)
(define-data-var are-tokens-transferable bool false)
(define-data-var net-asset-value uint u1000000) ;; NAV in uSTX per full PoolMind token (default to 1.000000 STX)
(define-data-var entry-fee-rate uint u5) ;; 0.5% (5 per 1000)
(define-data-var exit-fee-rate uint u5) ;; 0.5% (5 per 1000)
(define-data-var nav-history-id uint u0)
;; --- Fungible Token (SIP-010) ---
(define-fungible-token PoolMind)
;; --- Data Maps ---
(define-map nav-history
  uint
  {
    nav: uint,
    timestamp: uint,
  }
)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; 2. PoolMind (PLMD) Fungible Token (Custom SIP-010 Implementation)
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; @desc Transfers PoolMind tokens from the sender to a recipient.
;; @param amount The amount of tokens to transfer.
;; @param sender The principal sending the tokens.
;; @param recipient The principal receiving the tokens.
;; @param memo An optional buffer for a memo.
;; @returns (response bool)
(define-public (transfer
    (amount uint)
    (sender principal)
    (recipient principal)
    (memo (optional (buff 34)))
  )
  (begin
    (asserts! (var-get are-tokens-transferable) (err ERR_TRANSFERS_DISABLED))
    (asserts! (is-eq tx-sender sender) (err ERR_NOT_AUTHORIZED))
    (asserts! (not (is-eq sender recipient)) (err ERR_SELF_TRANSFER))
    (try! (ft-transfer? PoolMind amount sender recipient))
    (print {
      topic: "ft_transfer_event",
      amount: amount,
      sender: sender,
      recipient: recipient,
      memo: memo,
    })
    (ok true)
  )
)

;; --- SIP-010 Read-Only Functions ---
;; @desc Gets the name of the fungible token.
;; @returns (response string)
(define-read-only (get-name)
  (ok "PoolMind")
)

;; @desc Gets the symbol of the fungible token.
;; @returns (response string)
(define-read-only (get-symbol)
  (ok "PLMD")
)

;; @desc Gets the number of decimals for the token.
;; @returns (response uint)
(define-read-only (get-decimals)
  (ok u6)
)

;; @desc Gets the token balance of a specified owner.
;; @param owner The principal address to query.
;; @returns (response uint)
(define-read-only (get-balance (owner principal))
  (ok (ft-get-balance PoolMind owner))
)

;; @desc Gets the total supply of the token.
;; @returns (response uint)
(define-read-only (get-total-supply)
  (ok (ft-get-supply PoolMind))
)

;; @desc Gets the URI for the token's metadata.
;; @returns (response (optional (string-utf8 256)))
(define-read-only (get-token-uri)
  (ok (some u"https://poolmind.finance/token-metadata.json"))
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; 3. Admin Functions
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; @desc Sets the contract's admin address. Only callable by the contract owner.
;; @param new-admin The principal address of the new admin.
;; @returns (response bool)
(define-public (set-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) (err ERR_NOT_AUTHORIZED))
    (var-set admin-address new-admin)
    (ok true)
  )
)

;; @desc Pauses or unpauses the contract's core functions (deposit/withdraw).
;; @param paused A boolean indicating whether to pause (true) or unpause (false).
;; @returns (response bool)
(define-public (set-paused (paused bool))
  (begin
    (asserts! (is-eq tx-sender (var-get admin-address)) (err ERR_NOT_AUTHORIZED))
    (var-set is-paused paused)
    (ok true)
  )
)

;; @desc Enables or disables the transferability of PoolMind tokens.
;; @param transferable A boolean indicating whether tokens can be transferred.
;; @returns (response bool)
(define-public (set-token-transferable (transferable bool))
  (begin
    (asserts! (is-eq tx-sender (var-get admin-address)) (err ERR_NOT_AUTHORIZED))
    (var-set are-tokens-transferable transferable)
    (ok true)
  )
)

;; @desc Sets the entry fee rate for deposits.
;; @param rate The new fee rate (e.g., u5 for 0.5%).
;; @returns (response bool)
(define-public (set-entry-fee-rate (rate uint))
  (begin
    (asserts! (is-eq tx-sender (var-get admin-address)) (err ERR_NOT_AUTHORIZED))
    (var-set entry-fee-rate rate)
    (ok true)
  )
)

;; @desc Sets the exit fee rate for withdrawals.
;; @param rate The new fee rate (e.g., u5 for 0.5%).
;; @returns (response bool)
(define-public (set-exit-fee-rate (rate uint))
  (begin
    (asserts! (is-eq tx-sender (var-get admin-address)) (err ERR_NOT_AUTHORIZED))
    (var-set exit-fee-rate rate)
    (ok true)
  )
)

;; @desc Updates the Net Asset Value (NAV) of the pool.
;; @param new-nav The new NAV value in uSTX per share.
;; @returns (response bool)
(define-public (update-nav (new-nav uint))
  (begin
    (asserts! (is-eq tx-sender (var-get admin-address)) (err ERR_NOT_AUTHORIZED))
    (let (
        (current-id (var-get nav-history-id))
        (current-nav (var-get net-asset-value))
      )
      ;; Store old NAV in history, if it's not the very first setting.
      (if (> current-nav u0)
        (map-set nav-history current-id {
          nav: current-nav,
          timestamp: stacks-block-height,
        })
        (map-set nav-history current-id {
          nav: new-nav,
          timestamp: stacks-block-height,
        })
      )
      (var-set nav-history-id (+ current-id u1))
      ;; Set new NAV
      (var-set net-asset-value new-nav)
      (print {
        topic: "nav-update",
        old-nav: current-nav,
        new-nav: new-nav,
        updater: tx-sender,
      })
      (ok true)
    )
  )
)

;; @desc Allows the admin to withdraw STX from the contract to fund arbitrage trades.
;;       This is intended for moving capital to external exchanges.
;; @param amount The amount of uSTX to withdraw.
;; @returns (response bool)
(define-public (withdraw-to-admin (amount uint))
  (begin
    (asserts! (is-eq tx-sender (var-get admin-address)) (err ERR_NOT_AUTHORIZED))
    (asserts! (>= (stx-get-balance (as-contract tx-sender)) amount)
      (err ERR_INSUFFICIENT_STX_BALANCE)
    )
    (try! (as-contract (stx-transfer? amount tx-sender (var-get admin-address))))
    (print {
      topic: "admin-withdrawal",
      amount: amount,
      recipient: (var-get admin-address),
    })
    (ok true)
  )
)

;; @desc Allows the admin to deposit STX into the contract, typically as returned profits.
;;       This action increases the pool's STX balance without minting any shares.
;; @param amount-stx The amount of uSTX to deposit.
;; @returns (response bool)
(define-public (admin-deposit (amount-stx uint))
  (begin
    (asserts! (is-eq tx-sender (var-get admin-address)) (err ERR_NOT_AUTHORIZED))
    (try! (stx-transfer? amount-stx tx-sender (as-contract tx-sender)))
    (print {
      topic: "admin-deposit",
      depositor: tx-sender,
      amount-stx: amount-stx,
    })
    (ok true)
  )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; 4. Public User Functions
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; @desc Allows a user to deposit STX and receive PoolMind tokens in return.
;; @param amount-stx The amount of uSTX to deposit.
;; @returns (response uint) The amount of PoolMind tokens minted.
(define-public (deposit (amount-stx uint))
  (begin
    (asserts! (not (var-get is-paused)) (err ERR_PAUSED))
    (asserts! (> amount-stx u0) (err ERR_ZERO_DEPOSIT))
    (let ((nav (var-get net-asset-value)))
      (asserts! (> nav u0) (err ERR_NAV_NOT_POSITIVE))
      ;; Calculate fee
      (let (
          (fee (/ (* amount-stx (var-get entry-fee-rate)) u1000))
          (net-amount-stx (- amount-stx fee))
        )
        ;; Transfer STX from user to this contract
        (try! (stx-transfer? net-amount-stx tx-sender (as-contract tx-sender)))
        (print {
          topic: "deposit",
          depositor: tx-sender,
          stx-amount: amount-stx,
          net-stx-amount: net-amount-stx,
        })
        (try! (stx-transfer? fee tx-sender (var-get admin-address)))
        (print {
          topic: "admin-fee-transfer",
          admin: (var-get admin-address),
          fee: fee,
        })
        (let ((shares-to-mint (/ (* net-amount-stx TOKEN_PRECISION) nav)))
          (try! (ft-mint? PoolMind shares-to-mint tx-sender))
          (print {
            topic: "mint",
            depositor: tx-sender,
            stx-amount: net-amount-stx,
            shares-minted: shares-to-mint,
          })
          (ok shares-to-mint)
        )
      )
    )
  )
)

;; @desc Allows a user to burn PoolMind tokens and withdraw a proportional amount of STX.
;; @param amount-shares The amount of PoolMind tokens to burn.
;; @returns (response uint) The amount of uSTX sent to the user.
(define-public (withdraw (amount-shares uint))
  (begin
    (asserts! (not (var-get is-paused)) (err ERR_PAUSED))
    (asserts! (> amount-shares u0) (err ERR_ZERO_WITHDRAWAL))
    (asserts! (>= (ft-get-balance PoolMind tx-sender) amount-shares)
      (err ERR_INSUFFICIENT_BALANCE)
    )
    ;; Burn shares first to follow checks-effects-interactions pattern
    (try! (ft-burn? PoolMind amount-shares tx-sender))
    (let (
        (nav (var-get net-asset-value))
        (stx-value (/ (* amount-shares nav) TOKEN_PRECISION))
        (fee (/ (* stx-value (var-get exit-fee-rate)) u1000))
        (net-stx-to-send (- stx-value fee))
        (recipient tx-sender)
      )
      ;; Send STX from contract to user

      (try! (as-contract (stx-transfer? net-stx-to-send tx-sender recipient)))
      (print {
        topic: "withdraw",
        withdrawer: tx-sender,
        stx-amount: net-stx-to-send,
        shares-burned: amount-shares,
      })
      (ok net-stx-to-send)
    )
  )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; 5. Public Read-Only Functions
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; @desc Gets the current Net Asset Value (NAV).
;; @returns (response uint)
(define-read-only (get-nav)
  (ok (var-get net-asset-value))
)

;; @desc Retrieves a historical NAV record by its ID.
;; @param id The ID of the historical NAV entry.
;; @returns (optional {nav: uint, timestamp: uint})
(define-read-only (get-nav-history-by-id (id uint))
  (map-get? nav-history id)
)

;; @desc Retrieves key contract state variables.
;; @returns (response object) An object containing various state metrics.
(define-read-only (get-contract-state)
  (ok {
    admin: (var-get admin-address),
    paused: (var-get is-paused),
    transferable: (var-get are-tokens-transferable),
    nav: (var-get net-asset-value),
    entry-fee: (var-get entry-fee-rate),
    exit-fee: (var-get exit-fee-rate),
    stx-balance: (stx-get-balance (as-contract tx-sender)),
  })
)
