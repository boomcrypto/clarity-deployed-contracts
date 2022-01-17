(define-constant ERR-TEST u40401)
(define-data-var contract-owner principal tx-sender)

(define-data-var counter int 0)
(define-data-var counter2 int 0)

(define-public (say-hi)
  (ok "hello world")
)

(define-read-only (echo-number (val int))
  (ok val)
)

(define-read-only (get-counter)
  (ok (var-get counter))
)

(define-public (increment)
  (begin
    (var-set counter (+ (var-get counter) 1))
    (ok (var-get counter))
  )
)

(define-public (decrement)
  (begin
    (var-set counter (- (var-get counter) 1))
    (ok (var-get counter))
  )
)

(define-read-only (get-counter-2)
  (ok (var-get counter2))
)

(define-public (increment-2)
  (begin
    (var-set counter2 (+ (var-get counter) 1))
    (ok (var-get counter2))
  )
)

(define-public (decrement-2)
  (begin
    (var-set counter2 (- (var-get counter) 1))
    (ok (var-get counter2))
  )
)

(define-public (swap-wstx-usda (dx uint))
  (let ((r (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token dx u0))))
  (ok (unwrap-panic (element-at r u1))))
)

(define-public (swap-usda-wstx (dx uint))
  (let ((r (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token dx u0))))
  (ok (unwrap-panic (element-at r u0))))
)

(define-public (swap-diko-usda (dx uint))
  (let ((r (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token dx u0))))
  (ok (unwrap-panic (element-at r u1))))
)

(define-public (swap-usda-diko (dx uint))
  (let ((r (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token dx u0))))
  (ok (unwrap-panic (element-at r u0))))
)

(define-public (swap-wstx-diko (dx uint))
  (let ((r (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token dx u0))))
  (ok (unwrap-panic (element-at r u1))))
)

(define-public (swap-diko-wstx (dx uint))
  (let ((r (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token dx u0))))
  (ok (unwrap-panic (element-at r u0))))
)

(define-public (swap-wstx-xbtc (dx uint))
  (let ((r (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token 'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin dx u0))))
  (ok (unwrap-panic (element-at r u1))))
)

(define-public (swap-xbtc-wstx (dx uint))
  (let ((r (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token 'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin dx u0))))
  (ok (unwrap-panic (element-at r u0))))
)

(define-public (swap-xbtc-usda (dx uint))
  (let ((r (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y 'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token dx u0))))
  (ok (unwrap-panic (element-at r u1))))
)

(define-public (swap-usda-xbtc (dx uint))
  (let ((r (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token dx u0))))
  (ok (unwrap-panic (element-at r u0))))
)

