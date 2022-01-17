;; Mint Fungible Tokens via Dapparatus with max supply sent to minter
(define-constant minter 'SP1TA84JTP4YRFWBK7PYKBA33H3YB60XP654RAR7M)
(define-fungible-token Obelisk u42000000)
(ft-mint? Obelisk u42000000 minter)

(define-public (get-name)
    (ok "Obelisk"))

(define-public (get-symbol)
    (ok "OBL"))

(define-public (get-decimals)
    (ok u4))

(define-public (get-balance-of (user principal))
    (ok (ft-get-balance Obelisk user)))

(define-public (get-token-uri)
    (ok none))

(define-public (transfer (to principal) (amount uint))
  (if
    (> (ft-get-balance Obelisk tx-sender) u0)
    (ft-transfer? Obelisk amount tx-sender to)
    (err u0)))