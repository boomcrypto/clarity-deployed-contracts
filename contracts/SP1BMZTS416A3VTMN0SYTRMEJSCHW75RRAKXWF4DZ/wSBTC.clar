;; stx10 token wrapper(https://stacksinscription.com/#/stx10)

(define-fungible-token wSBTC)
(define-constant TICK_NAME "sbtc")
(define-constant TOKEN_NAME "Wrapped sbtc Token")
(define-constant TOKEN_SYMBOL "wSBTC")

;;; Template area ;;;
(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(define-constant ERR_NO_AUTHORITY u10001)
(define-constant ERR_BALANCE_UNENOUGH u10002)
(define-constant ERR_INVALID_AMOUNT u10003)

(define-constant DECIMAL u6)
(define-constant ONE_COIN (pow u10 DECIMAL))

(define-read-only (get-total-supply)
  (ok (ft-get-supply wSBTC))
)

(define-read-only (get-name)
  (ok TOKEN_NAME)
)

(define-read-only (get-symbol)
  (ok TOKEN_SYMBOL)
)

(define-read-only (get-decimals)
  (ok DECIMAL)
)

(define-read-only (get-balance (address principal))
  (ok (ft-get-balance wSBTC address))
)

(define-read-only (get-token-uri)
  (ok (some u"https://ipfs.io/ipfs/QmQpXS4SPXprPdFc2LFoJzwajkGNS1iPFidTfBCnvNkytd"))
)

(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (if (is-eq tx-sender sender)
    (begin
      (try! (ft-transfer? wSBTC amount sender recipient))
      (print {
        type: "transfer",
        tick: TICK_NAME,
        sender: sender,
        recipient: recipient,
        amount: amount,
        memo: memo,
      })
      (ok true)
    )
    (err ERR_NO_AUTHORITY)
  )
)

(define-read-only (get_summary (address principal))
  {
    info: (contract-call? .inscription get_stx10_info_by_tick TICK_NAME),
    stx10_balance: (contract-call? .inscription get_stx10_balance TICK_NAME address),
    sip10_balance: (ft-get-balance wSBTC address),
  }
)

(define-public (wrap (amount uint))
  (let
    (
      (sender tx-sender)
      (stx10_balance (contract-call? .inscription get_stx10_balance TICK_NAME sender))
      (payload (contract-call? .inscription get_stx10_transfer_payload TICK_NAME amount))
    )
    (asserts! (>= stx10_balance amount) (err ERR_BALANCE_UNENOUGH))
    (print {
      type: "wrap",
      tick: TICK_NAME,
      sender: tx-sender,
      amount: amount,
    })
    (try! (contract-call? .inscription inscribe_transfer_stx10 payload (as-contract tx-sender) TICK_NAME amount))
    (ft-mint? wSBTC (* amount ONE_COIN) sender)
  )
)

(define-public (unwrap (amount uint))
  (let
    (
      (sender tx-sender)
      (payload (contract-call? .inscription get_stx10_transfer_payload TICK_NAME amount))
    )
    (asserts! (and (> amount u0) (<= (* amount ONE_COIN) (unwrap-panic (get-balance sender)))) (err ERR_INVALID_AMOUNT))
    (try! (ft-burn? wSBTC (* amount ONE_COIN) sender))
    (print {
      type: "unwrap",
      tick: TICK_NAME,
      sender: sender,
      amount: amount,
    })
    (as-contract (contract-call? .inscription inscribe_transfer_stx10 payload sender TICK_NAME amount))
  )
)
