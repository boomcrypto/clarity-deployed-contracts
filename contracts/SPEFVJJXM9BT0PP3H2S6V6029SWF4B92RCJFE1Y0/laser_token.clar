;; Laser token (visit https://onedotbtcus.bitbucket.io/ or 1.btc.us)

(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(define-constant ERR_NO_AUTHORITY u8001)
(define-constant ERR_CANNOT_BUY_NOW u8002)
(define-constant ERR_EXCEED_MAX_SUPPLY u8003)

(define-constant OWNER tx-sender)
(define-constant MAX_SUPPLY u21000000)
(define-constant MINT_AWARD u800)
(define-constant PRESERVE_SUPPLY (* u6400 MINT_AWARD))

(define-fungible-token LASER)

(define-data-var m_price uint u10) ;; 1 STX =  10 LASER
(define-data-var m_buy_switch bool false)
(define-data-var m_nft_contract (optional principal) none)

(define-read-only (get-balance (owner principal))
  (ok (ft-get-balance LASER owner))
)

(define-read-only (get-total-supply)
  (ok (ft-get-supply LASER))
)

(define-read-only (get-name)
  (ok "Laser Token")
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
    (err u4))
)

(define-public (burn (count uint))
  (ft-burn? LASER count tx-sender)
)

(define-public (get-token-uri)
  (ok (some u"https://ipfs.io/ipfs/QmXn7gUC1yJMqbPUp9CiDLD7AA8RTaZ95me6pWE5p6JWNa"))
)

(define-public (set_price (price uint))
  (ok (and (is-eq tx-sender OWNER) (var-set m_price price)))
)

(define-public (set_buy_switch (buy_switch bool))
  (ok (and (is-eq tx-sender OWNER) (var-set m_buy_switch buy_switch)))
)

(define-read-only (get_summary (player (optional principal)))
  {
    buy_switch: (var-get m_buy_switch),
    price: (var-get m_price),
    supply: (ft-get-supply LASER),
    balance: (if (is-none player) u0 (ft-get-balance LASER (unwrap-panic player))),
  }
)

(define-public (buy (count uint))
  (let
    (
      (cost (/ (* count u1000000) (var-get m_price)))
    )
    (asserts! (var-get m_buy_switch) (err ERR_CANNOT_BUY_NOW))
    (asserts! (<= (+ (ft-get-supply LASER) PRESERVE_SUPPLY count) MAX_SUPPLY) (err ERR_EXCEED_MAX_SUPPLY))
    (try! (stx-transfer? cost tx-sender OWNER))
    (try! (ft-mint? LASER count tx-sender))
    (ok true)
  )
)

(define-public (set_nft_contract (nft_contract principal))
  (begin
    (asserts! (is-eq tx-sender OWNER) (err ERR_NO_AUTHORITY))
    (ok (and (is-none (var-get m_nft_contract)) (var-set m_nft_contract (some nft_contract))))
  )
)

(define-public (reward_minter (receiver principal))
  (begin
    (asserts! (is-eq contract-caller (unwrap-panic (var-get m_nft_contract))) (err ERR_NO_AUTHORITY))
    (ft-mint? LASER MINT_AWARD receiver)
  )
)

(ft-mint? LASER u50 OWNER)
