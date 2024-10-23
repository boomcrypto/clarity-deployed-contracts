(define-constant ERR-UNAUTHORIZED u1)
(define-constant ERR-YOU-POOR u2)
(define-fungible-token synthetic-stx)
(define-data-var token-uri (optional (string-utf8 256)) (some u"https://charisma.rocks/sip10/synthetic-stx/metadata.json"))
(impl-trait .dao-traits-v4.sip010-ft-trait)

;; --- Authorization checks

(define-private (is-dao-or-extension)
  (or (is-eq tx-sender 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master) (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master is-extension contract-caller))
)

;; SIP-010 Standard

(define-public (transfer (amount uint) (from principal) (to principal) (memo (optional (buff 34))))
  (begin
    (asserts! (is-eq from tx-sender) (err ERR-UNAUTHORIZED))
    (ft-transfer? synthetic-stx amount from to)
  )
)

(define-read-only (get-name)
  (ok "Synthetic STX")
)

(define-read-only (get-symbol)
  (ok "synSTX")
)

(define-read-only (get-decimals)
  (ok u6)
)

(define-read-only (get-balance (user principal))
  (ok (ft-get-balance synthetic-stx user))
)

(define-read-only (get-total-supply)
  (ok (ft-get-supply synthetic-stx))
)

(define-public (set-token-uri (value (string-utf8 256)))
  (if 
    (is-dao-or-extension) 
    (ok (var-set token-uri (some value))) 
    (err ERR-UNAUTHORIZED)
  )
)

(define-read-only (get-token-uri)
  (ok (var-get token-uri))
)

;; send-many

(define-public (send-many (recipients (list 200 { to: principal, amount: uint, memo: (optional (buff 34)) })))
  (fold check-err
    (map send-token recipients)
    (ok true)
  )
)

(define-private (check-err (result (response bool uint)) (prior (response bool uint)))
  (match prior ok-value result
               err-value (err err-value)
  )
)

(define-private (send-token (recipient { to: principal, amount: uint, memo: (optional (buff 34)) }))
  (send-token-with-memo (get amount recipient) (get to recipient) (get memo recipient))
)

(define-private (send-token-with-memo (amount uint) (to principal) (memo (optional (buff 34))))
  (let
    ((transferOk (try! (transfer amount tx-sender to memo))))
    (ok transferOk)
  )
)

(define-public (mint (amount uint) (recipient principal))
  (if 
    (is-dao-or-extension) 
    (ok (ft-mint? synthetic-stx amount recipient)) 
    (err ERR-UNAUTHORIZED)
  )
)

(define-public (burn (amount uint))
  (ft-burn? synthetic-stx amount tx-sender)
)