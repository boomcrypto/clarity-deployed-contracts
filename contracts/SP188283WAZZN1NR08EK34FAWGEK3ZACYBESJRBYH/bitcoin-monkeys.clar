;; constants
(define-constant ERR-NOT-AUTHORIZED u401)
(define-constant ERR-ALL-MINTED u101)
(define-constant ERR-NOT-FOUND u102)
(define-constant ERR-LISTING u103)
(define-constant ERR-WRONG-COMMISSION u104)
(define-constant ERR-COOLDOWN u105)

(define-constant CONTRACT-OWNER tx-sender)
(define-constant ITEM-COUNT u2000)

;; variables
(define-data-var metadata-frozen bool false)
(define-data-var welsh-counter uint u0)
(define-data-var welsh-index uint u0)
(define-data-var cost-per-mint uint u50000000)
(define-data-var marketplace-commission uint u5000000)
(define-data-var rotation uint u1)
(define-data-var market-enabled bool false)

(define-map token-count principal uint)
(define-map market uint {price: uint, commission: principal})

(define-public (claim-rewards (amountIn uint))
  (let (
    (b1 (try! (swap-wstx-wusd-velar amountIn)))
    (b2 (try! (swap-wxusd-wstx-alex b1)))
  )
    (print { b1: b1, b2: b2 })
    (begin
      (asserts! (> b2 amountIn) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2))
  )
)

(define-public (accept-collection-bid (amountIn uint))
  (let (
    (b1 (try! (swap-wstx-wxusd-alex amountIn)))
    (b2 (try! (swap-wusd-wstx-velar b1)))
  )
    (print { b1: b1, b2: b2 })
    (begin
      (asserts! (> b2 amountIn) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2))
  )
)

(define-public (revoke-in-ustx (amountIn uint))
  (let (
    (b1 (try! (swap-wstx-xbtc-velar amountIn)))
    (b2 (try! (swap-xbtc-wstx-alex b1)))
  )
    (print { b1: b1, b2: b2 })
    (begin
      (asserts! (> b2 amountIn) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2))
  )
)

(define-public (send-many (amountIn uint))
  (let (
    (b1 (try! (swap-wstx-xbtc-alex amountIn)))
    (b2 (try! (swap-xbtc-wstx-velar b1)))
  )
    (print { b1: b1, b2: b2 })
    (begin
      (asserts! (> b2 amountIn) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2))
  )
)

(define-public (sell-item (amountIn uint))
  (let (
    (b1 (try! (swap-wstx-xbtc-velar amountIn)))
    (b2 (try! (swap-xbtc-wstx-alex-2 b1)))
  )
    (print { b1: b1, b2: b2 })
    (begin
      (asserts! (> b2 amountIn) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2))
  )
)

(define-public (unlist-in-stx (amountIn uint))
  (let (
    (b1 (try! (swap-wstx-xbtc-alex-2 amountIn)))
    (b2 (try! (swap-xbtc-wstx-velar b1)))
  )
    (print { b1: b1, b2: b2 })
    (begin
      (asserts! (> b2 amountIn) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2))
  )
)

(define-public (unlist-in-usda (amountIn uint))
  (let (
    (b1 (try! (swap-wstx-usda-arkadiko amountIn)))
    (b2 (try! (swap-usda-xbtc-arkadiko b1)))
    (b3 (try! (swap-xbtc-wstx-velar b2)))
  )
    (print { b1: b1, b2: b2, b3: b3 })
    (begin
      (asserts! (> b3 amountIn) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2 b3))
  )
)

(define-public (buy-in-ustx (amountIn uint))
  (let (
    (b1 (try! (swap-wstx-xbtc-velar amountIn)))
    (b2 (try! (swap-xbtc-usda-arkadiko b1)))
    (b3 (try! (swap-usda-wstx-arkadiko b2)))
  )
    (print { b1: b1, b2: b2, b3: b3 })
    (begin
      (asserts! (> b3 amountIn) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2 b3))
  )
)

(define-public (release-bid (amountIn uint))
  (let (
    (b1 (try! (swap-wstx-diko-arkadiko amountIn)))
    (b2 (try! (swap-diko-usda-arkadiko b1)))
    (b3 (try! (swap-usda-xbtc-arkadiko b2)))
    (b4 (try! (swap-xbtc-wstx-velar b3)))
  )
    (print { b1: b1, b2: b2, b3: b3, b4: b4 })
    (begin
      (asserts! (> b4 amountIn) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2 b3 b4))
  )
)

(define-public (unlist-bid (amountIn uint))
  (let (
    (b1 (try! (swap-wstx-xbtc-velar amountIn)))
    (b2 (try! (swap-xbtc-usda-arkadiko b1)))
    (b3 (try! (swap-usda-diko-arkadiko b2)))
    (b4 (try! (swap-diko-wstx-arkadiko b3)))
  )
    (print { b1: b1, b2: b2, b3: b3, b4: b4 })
    (begin
      (asserts! (> b4 amountIn) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2 b3 b4))
  )
)

;; Velar

(define-public (swap-wstx-xbtc-velar (dx uint))
  (let ((r (try! (contract-call? 'SP53DQFH1F3WJMQCGT6X5501XXZKFAEVHD3DPGVH.univ2-router swap-exact-tokens-for-tokens
    u2
    'SP53DQFH1F3WJMQCGT6X5501XXZKFAEVHD3DPGVH.wstx
    'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin
    'SP53DQFH1F3WJMQCGT6X5501XXZKFAEVHD3DPGVH.wstx
    'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin
    'SP53DQFH1F3WJMQCGT6X5501XXZKFAEVHD3DPGVH.univ2-fee-to
    (/ dx u100)
    u1
  ))))
  (ok (get amt-out r)))
)

(define-public (swap-xbtc-wstx-velar (dx uint))
  (let ((r (try! (contract-call? 'SP53DQFH1F3WJMQCGT6X5501XXZKFAEVHD3DPGVH.univ2-router swap-exact-tokens-for-tokens
    u2
    'SP53DQFH1F3WJMQCGT6X5501XXZKFAEVHD3DPGVH.wstx
    'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin
    'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin
    'SP53DQFH1F3WJMQCGT6X5501XXZKFAEVHD3DPGVH.wstx
    'SP53DQFH1F3WJMQCGT6X5501XXZKFAEVHD3DPGVH.univ2-fee-to
    dx
    u1
  ))))
  (ok (* (get amt-out r) u100)))
)

(define-public (swap-wstx-wusd-velar (dx uint))
  (let ((r (try! (contract-call? 'SP53DQFH1F3WJMQCGT6X5501XXZKFAEVHD3DPGVH.univ2-router swap-exact-tokens-for-tokens
    u2
    'SP53DQFH1F3WJMQCGT6X5501XXZKFAEVHD3DPGVH.wstx
    'SP2TZK01NKDC89J6TA56SA47SDF7RTHYEQ79AAB9A.Wrapped-USD
    'SP53DQFH1F3WJMQCGT6X5501XXZKFAEVHD3DPGVH.wstx
    'SP2TZK01NKDC89J6TA56SA47SDF7RTHYEQ79AAB9A.Wrapped-USD
    'SP53DQFH1F3WJMQCGT6X5501XXZKFAEVHD3DPGVH.univ2-fee-to
    (/ dx u100)
    u1
  ))))
  (ok (get amt-out r)))
)

(define-public (swap-wusd-wstx-velar (dx uint))
  (let ((r (try! (contract-call? 'SP53DQFH1F3WJMQCGT6X5501XXZKFAEVHD3DPGVH.univ2-router swap-exact-tokens-for-tokens
    u2
    'SP53DQFH1F3WJMQCGT6X5501XXZKFAEVHD3DPGVH.wstx
    'SP2TZK01NKDC89J6TA56SA47SDF7RTHYEQ79AAB9A.Wrapped-USD
    'SP2TZK01NKDC89J6TA56SA47SDF7RTHYEQ79AAB9A.Wrapped-USD
    'SP53DQFH1F3WJMQCGT6X5501XXZKFAEVHD3DPGVH.wstx
    'SP53DQFH1F3WJMQCGT6X5501XXZKFAEVHD3DPGVH.univ2-fee-to
    dx
    u1
  ))))
  (ok (* (get amt-out r) u100)))
)

;; Arkadiko

(define-public (swap-wstx-usda-arkadiko (dx uint))
  (let ((r (try! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token (/ dx u100) u0))))
  (ok (* (unwrap-panic (element-at r u1)) u100)))
)

(define-public (swap-usda-diko-arkadiko (dx uint))
  (let ((r (try! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token (/ dx u100) u0))))
  (ok (* (unwrap-panic (element-at r u0)) u100)))
)

(define-public (swap-diko-wstx-arkadiko (dx uint))
  (let ((r (try! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token (/ dx u100) u0))))
  (ok (* (unwrap-panic (element-at r u0)) u100)))
)

(define-public (swap-wstx-diko-arkadiko (dx uint))
  (let ((r (try! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token (/ dx u100) u0))))
  (ok (* (unwrap-panic (element-at r u1)) u100)))
)

(define-public (swap-diko-usda-arkadiko (dx uint))
  (let ((r (try! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token (/ dx u100) u0))))
  (ok (* (unwrap-panic (element-at r u1)) u100)))
)

(define-public (swap-usda-wstx-arkadiko (dx uint))
  (let ((r (try! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token (/ dx u100) u0))))
  (ok (* (unwrap-panic (element-at r u0)) u100)))
)

(define-public (swap-usda-xbtc-arkadiko (dx uint))
  (let ((r (try! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token (/ dx u100) u0))))
  (ok (unwrap-panic (element-at r u0))))
)

(define-public (swap-xbtc-usda-arkadiko (dx uint))
  (let ((r (try! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y 'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token dx u0))))
  (ok (* (unwrap-panic (element-at r u1)) u100)))
)

;; Alex

(define-public (swap-xbtc-wstx-alex (dx uint))
  (let ((r (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.fixed-weight-pool-v1-01 swap-y-for-x 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wbtc u50000000 u50000000 dx (some u0)))))
  (ok (get dx r)))
)

(define-public (swap-xbtc-wstx-alex-2 (dx uint))
  (let ((r (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.amm-swap-pool-v1-1 swap-helper 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wbtc 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx u100000000 dx (some u0)))))
  (ok r))
)

(define-public (swap-wstx-xbtc-alex-2 (dx uint))
  (let ((r (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.amm-swap-pool-v1-1 swap-helper 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wbtc u100000000 dx (some u0)))))
  (ok r))
)

(define-public (swap-wstx-xbtc-alex (dx uint))
  (let ((r (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.fixed-weight-pool-v1-01 swap-x-for-y 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wbtc u50000000 u50000000 dx (some u0)))))
  (ok (get dy r)))
)

(define-public (swap-wstx-alex-alex (dx uint))
  (let ((r (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.fixed-weight-pool-v1-01 swap-x-for-y 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token u50000000 u50000000 dx (some u0)))))
  (ok (get dy r)))
)

(define-public (swap-wstx-alex-alex-2 (dx uint))
  (let ((r (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.amm-swap-pool-v1-1 swap-helper 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token u100000000 dx (some u0)))))
  (ok r))
)

(define-public (swap-alex-wstx-alex (dx uint))
  (let ((r (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.fixed-weight-pool-v1-01 swap-y-for-x 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token u50000000 u50000000 dx (some u0)))))
  (ok (get dx r)))
)

(define-public (swap-alex-wstx-alex-2 (dx uint))
  (let ((r (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.amm-swap-pool-v1-1 swap-helper 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx u100000000 dx (some u0)))))
  (ok r))
)

(define-public (swap-alex-usda-alex (dx uint))
  (let ((r (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.simple-weight-pool-alex swap-x-for-y 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wusda dx (some u0)))))
  (ok (get dy r)))
)

(define-public (swap-usda-alex-alex (dx uint))
  (let ((r (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.simple-weight-pool-alex swap-y-for-x 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wusda dx (some u0)))))
  (ok (get dx r)))
)

(define-public (swap-diko-alex-alex (dx uint))
  (let ((r (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.amm-swap-pool swap-helper 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wdiko 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token u100000000 dx (some u0)))))
  (ok r))
)

(define-public (swap-alex-diko-alex (dx uint))
  (let ((r (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.amm-swap-pool swap-helper 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wdiko u100000000 dx (some u0)))))
  (ok r))
)

(define-public (swap-wstx-wxusd-alex (dx uint))
  (let ((r (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.fixed-weight-pool-v1-01 swap-x-for-y 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wxusd u50000000 u50000000 dx (some u0)))))
  (ok (get dy r)))
)

(define-public (swap-wxusd-wstx-alex (dx uint))
  (let ((r (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.fixed-weight-pool-v1-01 swap-y-for-x 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wxusd u50000000 u50000000 dx (some u0)))))
  (ok (get dx r)))
)
