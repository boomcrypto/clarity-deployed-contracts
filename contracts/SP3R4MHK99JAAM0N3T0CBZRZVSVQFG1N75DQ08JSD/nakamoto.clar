;; stx10 token wrapper(https://stacksinscription.com/#/stx10)

(define-fungible-token nakamoto)
(define-constant TOKEN_SYMBOL "nakamoto")
(define-constant TICK_NAME "nakamoto")

;;; Template area
(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(define-constant ERR_NO_AUTHORITY u10001)
(define-constant ERR_INVALID_AMOUNT u10002)

(define-constant DECIMAL u6)
(define-constant ONE_COIN (pow u10 DECIMAL))

(define-read-only (get-total-supply)
  (ok (ft-get-supply nakamoto))
)

(define-read-only (get-name)
  (ok TOKEN_SYMBOL)
)

(define-read-only (get-symbol)
  (ok TOKEN_SYMBOL)
)

(define-read-only (get-decimals)
  (ok DECIMAL)
)

(define-read-only (get-balance (address principal))
  (ok (ft-get-balance nakamoto address))
)

(define-read-only (get-token-uri)
  (ok (some u"https://ipfs.io/ipfs/QmaT2x7Qvov7vLHgGkquHdL6qYKNc2Q1pne4kHyXK38cNh"))
)

(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (if (is-eq tx-sender sender)
    (begin
      (try! (ft-transfer? nakamoto amount sender recipient))
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
    info: (contract-call? 'SP1BMZTS416A3VTMN0SYTRMEJSCHW75RRAKXWF4DZ.inscription get_stx10_info_by_tick TICK_NAME),
    stx10_balance: (contract-call? 'SP1BMZTS416A3VTMN0SYTRMEJSCHW75RRAKXWF4DZ.inscription get_stx10_balance TICK_NAME address),
    sip10_balance: (ft-get-balance nakamoto address),
  }
)

(define-public (wrap (amount uint))
  (let
    (
      (sender tx-sender)
      (stx10_balance (contract-call? 'SP1BMZTS416A3VTMN0SYTRMEJSCHW75RRAKXWF4DZ.inscription get_stx10_balance TICK_NAME sender))
      (payload (contract-call? 'SP1BMZTS416A3VTMN0SYTRMEJSCHW75RRAKXWF4DZ.inscription get_stx10_transfer_payload TICK_NAME amount))
    )
    (asserts! (and (> amount u0) (>= stx10_balance amount)) (err ERR_INVALID_AMOUNT))
    (print {
      type: "wrap",
      tick: TICK_NAME,
      sender: sender,
      amount: amount,
    })
    (try! (contract-call? 'SP1BMZTS416A3VTMN0SYTRMEJSCHW75RRAKXWF4DZ.inscription inscribe_transfer_stx10 payload (as-contract tx-sender) TICK_NAME amount))
    (ft-mint? nakamoto (* amount ONE_COIN) sender)
  )
)

(define-public (unwrap (amount uint))
  (let
    (
      (sender tx-sender)
      (payload (contract-call? 'SP1BMZTS416A3VTMN0SYTRMEJSCHW75RRAKXWF4DZ.inscription get_stx10_transfer_payload TICK_NAME amount))
    )
    (asserts! (and (> amount u0) (<= (* amount ONE_COIN) (unwrap-panic (get-balance sender)))) (err ERR_INVALID_AMOUNT))
    (try! (ft-burn? nakamoto (* amount ONE_COIN) sender))
    (print {
      type: "unwrap",
      tick: TICK_NAME,
      sender: sender,
      amount: amount,
    })
    (as-contract (contract-call? 'SP1BMZTS416A3VTMN0SYTRMEJSCHW75RRAKXWF4DZ.inscription inscribe_transfer_stx10 payload sender TICK_NAME amount))
  )
)
