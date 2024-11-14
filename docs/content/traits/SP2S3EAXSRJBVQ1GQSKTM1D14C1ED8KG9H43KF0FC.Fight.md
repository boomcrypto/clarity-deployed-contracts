---
title: "Trait Fight"
draft: true
---
```
;; $Fight (https://lasereye.vip/#/x/tokens)

(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(define-fungible-token Fight)

(define-constant MAX_SUPPLY u45000000000000)
(define-constant DECIMAL u0)
(define-constant ONE_COIN (pow u10 DECIMAL))
(define-constant AIRDROP_COUNT_PER_MEMBER (* u85000000000 ONE_COIN))

(define-data-var m_admin principal tx-sender)
(define-data-var m_name (string-ascii 32) "Fight")
(define-data-var m_symbol (string-ascii 32) "Fight!Fight!Fight!(lasereye.vip)")

(define-read-only (get-balance (user principal))
  (ok (ft-get-balance Fight user))
)

(define-read-only (get-total-supply)
  (ok (ft-get-supply Fight))
)

(define-read-only (get-name)
  (ok (var-get m_name))
)

(define-read-only (get-symbol)
  (ok (var-get m_symbol))
)

(define-read-only (get-decimals)
  (ok DECIMAL)
)

(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (if (is-eq tx-sender sender)
    (begin
      (try! (ft-transfer? Fight amount sender recipient))
      (print memo)
      (ok true)
    )
    (err u4)
  )
)

(define-public (burn (count uint))
  (ft-burn? Fight count tx-sender)
)

(define-public (get-token-uri)
  (ok (some u"https://ipfs.io/ipfs/QmTRbJVaY2eNqsaS11pdDtL9BHmsNVBKCVQNZu3y6xYVHf"))
)

(define-public (set-admin (admin principal))
  (ok (and
    (is-eq (var-get m_admin) tx-sender)
    (var-set m_admin admin)
  ))
)

(define-public (set-name (name (string-ascii 32)))
  (ok (and
    (is-eq (var-get m_admin) tx-sender)
    (var-set m_name name)
  ))
)

(define-public (set-symbol (symbol (string-ascii 32)))
  (ok (and
    (is-eq (var-get m_admin) tx-sender)
    (var-set m_symbol symbol)
  ))
)

(define-private (airdrop (tid uint))
  (match (contract-call? 'SP3XYJ8XFZYF7MD86QQ5EF8HBVHHZFFQ9HM6SPJNQ.laser-eyes-v5 get_player_by_id tid) user
    (is-ok (ft-mint? Fight AIRDROP_COUNT_PER_MEMBER user))
    false
  )
)

(map airdrop (list u1 u2 u3 u4 u5 u6 u7 u8 u9 u10 u11 u12 u13 u14 u15 u16 u17 u18 u19 u20 u21))
(ft-mint? Fight (- MAX_SUPPLY (* u21 AIRDROP_COUNT_PER_MEMBER)) tx-sender)

```
