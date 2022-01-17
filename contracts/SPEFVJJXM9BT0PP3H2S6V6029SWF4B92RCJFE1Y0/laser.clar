;; Laser eyes (visit 1.btc.us)

;; Implement the `ft-trait` trait defined in the `ft-trait` contract
(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(define-constant ERR_NO_AUTHORITY u1001)
(define-constant ERR_CANNOT_BUY_NOW u1002)
(define-constant ERR_EXCEED_MAX_SUPPLY u1003)

(define-constant OWNER tx-sender)
(define-constant MAX_SUPPLY u21000000)
(define-constant MINT_AWARD_FT u800)
(define-constant PRESERVE_SUPPLY (* u6400 MINT_AWARD_FT))

(define-fungible-token LASER)

(define-data-var m_price uint u10) ;; 1 STX =  10 LASER
(define-data-var m_buy_switch bool false)
(define-data-var m_master_contract (optional principal) none)

;; get the token balance of owner
(define-read-only (get-balance (owner principal))
  (ok (ft-get-balance LASER owner))
)

;; returns the total number of tokens
(define-read-only (get-total-supply)
  (ok (ft-get-supply LASER))
)

;; returns the token name
(define-read-only (get-name)
  (ok "LASER")
)

;; the symbol or "ticker" for this token
(define-read-only (get-symbol)
  (ok "laser")
)

;; the number of decimals used
(define-read-only (get-decimals)
  (ok u2)
)

;; Transfers tokens to a recipient
(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (if (is-eq tx-sender sender)
    (begin
      (try! (ft-transfer? LASER amount sender recipient))
      (print memo)
      (ok true)
    )
    (err u4))
)

(define-public (get-token-uri)
  (ok (some u"https://ipfs.io/ipfs/QmXWbuPG94iDT7FnnKqacmeTmEJupErWfZwoQXwSuj8jbU"))
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

(define-public (set_master_contract (contract_owner principal))
  (begin
    (asserts! (is-eq tx-sender OWNER) (err ERR_NO_AUTHORITY))
    (ok (and (is-none (var-get m_master_contract)) (var-set m_master_contract (some contract_owner))))
  )
)

(define-public (reward_minter)
  (begin
    (asserts! (is-eq contract-caller (unwrap-panic (var-get m_master_contract))) (err ERR_NO_AUTHORITY))
    (ft-mint? LASER MINT_AWARD_FT tx-sender)
  )
)

(ft-mint? LASER u50 OWNER)
