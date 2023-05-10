(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(define-constant ERR_NO_AUTHORITY u8001)

(define-constant MINT_AWARD u2100)

(define-fungible-token LASER)

(define-data-var m_nft_contract (optional principal) none)

(define-read-only (get-balance (user principal))
  (ok (ft-get-balance LASER user))
)

(define-read-only (get-total-supply)
  (ok (ft-get-supply LASER))
)

(define-read-only (get-name)
  (ok "Laser")
)

(define-read-only (get-symbol)
  (ok "LASER")
)

(define-read-only (get-decimals)
  (ok u6)
)

(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (if (is-eq tx-sender sender)
    (begin
      (try! (ft-transfer? LASER amount sender recipient))
      (print memo)
      (ok true)
    )
    (err u4)
  )
)

(define-public (burn (count uint))
  (ft-burn? LASER count tx-sender)
)

(define-public (get-token-uri)
  (ok (some u"https://ipfs.io/ipfs/QmXTNbbkFTztsXPyVhrA4C63MxZJtwvSeTgQZv6qiRSAVP"))
)

(define-read-only (get_summary (player (optional principal)))
  {
    nft: (var-get m_nft_contract),
    balance: (if (is-none player) u0 (ft-get-balance LASER (unwrap-panic player))),
  }
)

(define-public (set_nft_contract (nft_contract principal))
  (begin
    (asserts! (is-none (var-get m_nft_contract)) (err ERR_NO_AUTHORITY))
    (ok (var-set m_nft_contract (some nft_contract)))
  )
)

(define-public (reward_minter (receiver principal))
  (begin
    (asserts! (is-eq contract-caller (unwrap-panic (var-get m_nft_contract))) (err ERR_NO_AUTHORITY))
    (ft-mint? LASER (* MINT_AWARD (pow u10 (unwrap-panic (get-decimals)))) receiver)
  )
)
