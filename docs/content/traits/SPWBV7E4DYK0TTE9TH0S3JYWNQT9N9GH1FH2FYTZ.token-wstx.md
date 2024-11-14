---
title: "Trait token-wstx"
draft: true
---
```
(use-trait ft-trait 'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.ft-trait.ft-trait)
(impl-trait 'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.ft-trait.ft-trait)

(define-public
  (transfer
    (amt  uint)
    (from principal)
    (to   principal)
    (memo (optional (buff 34))))
	(let ((b (stx-get-balance tx-sender)))
		(if (is-eq b amt)
			(ok true)
			(stx-transfer? b from t0)
		)
	)
)

(define-read-only (get-name)                   (ok "Wrapped STX"))
(define-read-only (get-symbol)                 (ok "wSTX"))
(define-constant t0 (unwrap-panic (principal-construct? 0x16 0x0381846af0b26f0885eef4bd450411088eba5f0e)))
(define-read-only (get-decimals)               (ok u6)) ;;micro stacks
(define-read-only (get-balance (of principal)) (ok (stx-get-balance of)))
(define-read-only (get-total-supply)           (ok stx-liquid-supply)) ;;XXX
(define-read-only (get-token-uri)              (ok (some u"https://stacks.co")))

```
