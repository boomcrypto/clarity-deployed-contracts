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

(define-public (accept-collection-bid (amountIn uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-usda-arkadiko amountIn)))
    (b2 (unwrap-panic (swap-usda-diko-arkadiko b1)))
    (b3 (unwrap-panic (swap-diko-wstx-arkadiko b2)))
  )
    (print { b1: b1, b2: b2, b3: b3 })
    (begin
      (asserts! (> b3 amountIn) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2 b3))
  )
)

(define-public (revoke-in-ustx (amountIn uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-diko-arkadiko amountIn)))
    (b2 (unwrap-panic (swap-diko-usda-arkadiko b1)))
    (b3 (unwrap-panic (swap-usda-wstx-arkadiko b2)))
  )
    (print { b1: b1, b2: b2, b3: b3 })
    (begin
      (asserts! (> b3 amountIn) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2 b3))
  )
)

(define-public (send-many (amountIn uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-usda-arkadiko amountIn)))
    (b2 (unwrap-panic (swap-usda-xbtc-arkadiko b1)))
    (b3 (unwrap-panic (swap-xbtc-wstx-alex b2)))
  )
    (print { b1: b1, b2: b2, b3: b3 })
    (begin
      (asserts! (> b3 amountIn) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2 b3))
  )
)

(define-public (mint (amountIn uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-xbtc-alex amountIn)))
    (b2 (unwrap-panic (swap-xbtc-usda-arkadiko b1)))
    (b3 (unwrap-panic (swap-usda-wstx-arkadiko b2)))
  )
    (print { b1: b1, b2: b2, b3: b3 })
    (begin
      (asserts! (> b3 amountIn) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2 b3))
  )
)

(define-public (unlist-in-usda (amountIn uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-usda-arkadiko amountIn)))
    (b2 (unwrap-panic (swap-usda-xbtc-arkadiko b1)))
    (b3 (unwrap-panic (swap-xbtc-wstx-alex-2 b2)))
  )
    (print { b1: b1, b2: b2, b3: b3 })
    (begin
      (asserts! (> b3 amountIn) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2 b3))
  )
)

(define-public (unlist-in-stx (amountIn uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-xbtc-alex-2 amountIn)))
    (b2 (unwrap-panic (swap-xbtc-usda-arkadiko b1)))
    (b3 (unwrap-panic (swap-usda-wstx-arkadiko b2)))
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
    (b1 (unwrap-panic (swap-wstx-diko-arkadiko amountIn)))
    (b2 (unwrap-panic (swap-diko-usda-arkadiko b1)))
    (b3 (unwrap-panic (swap-usda-xbtc-arkadiko b2)))
    (b4 (unwrap-panic (swap-xbtc-wstx-alex b3)))
  )
    (print { b1: b1, b2: b2, b3: b3, b4: b4 })
    (begin
      (asserts! (> b4 amountIn) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2 b3 b4))
  )
)

(define-public (sell-item (amountIn uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-xbtc-alex amountIn)))
    (b2 (unwrap-panic (swap-xbtc-usda-arkadiko b1)))
    (b3 (unwrap-panic (swap-usda-diko-arkadiko b2)))
    (b4 (unwrap-panic (swap-diko-wstx-arkadiko b3)))
  )
    (print { b1: b1, b2: b2, b3: b3, b4: b4 })
    (begin
      (asserts! (> b4 amountIn) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2 b3 b4))
  )
)

(define-public (release-bid (amountIn uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-diko-arkadiko amountIn)))
    (b2 (unwrap-panic (swap-diko-usda-arkadiko b1)))
    (b3 (unwrap-panic (swap-usda-xbtc-arkadiko b2)))
    (b4 (unwrap-panic (swap-xbtc-wstx-alex-2 b3)))
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
    (b1 (unwrap-panic (swap-wstx-xbtc-alex-2 amountIn)))
    (b2 (unwrap-panic (swap-xbtc-usda-arkadiko b1)))
    (b3 (unwrap-panic (swap-usda-diko-arkadiko b2)))
    (b4 (unwrap-panic (swap-diko-wstx-arkadiko b3)))
  )
    (print { b1: b1, b2: b2, b3: b3, b4: b4 })
    (begin
      (asserts! (> b4 amountIn) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2 b3 b4))
  )
)

(define-public (unlist-collection-bid (amountIn uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-alex-alex amountIn)))
    (b2 (unwrap-panic (swap-alex-usda-alex b1)))
    (b3 (unwrap-panic (swap-usda-wstx-arkadiko b2)))
  )
    (print { b1: b1, b2: b2, b3: b3 })
    (begin
      (asserts! (> b3 amountIn) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2 b3))
  )
)

(define-public (release-collection-bid (amountIn uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-usda-arkadiko amountIn)))
    (b2 (unwrap-panic (swap-usda-alex-alex b1)))
    (b3 (unwrap-panic (swap-alex-wstx-alex b2)))
  )
    (print { b1: b1, b2: b2, b3: b3 })
    (begin
      (asserts! (> b3 amountIn) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2 b3))
  )
)

(define-public (claim-mining-rewards (amountIn uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-alex-alex-2 amountIn)))
    (b2 (unwrap-panic (swap-alex-usda-alex b1)))
    (b3 (unwrap-panic (swap-usda-wstx-arkadiko b2)))
  )
    (print { b1: b1, b2: b2, b3: b3 })
    (begin
      (asserts! (> b3 amountIn) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2 b3))
  )
)

(define-public (unlist-stx (amountIn uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-usda-arkadiko amountIn)))
    (b2 (unwrap-panic (swap-usda-alex-alex b1)))
    (b3 (unwrap-panic (swap-alex-wstx-alex-2 b2)))
  )
    (print { b1: b1, b2: b2, b3: b3 })
    (begin
      (asserts! (> b3 amountIn) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2 b3))
  )
)

(define-public (sell-in-usda (amountIn uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-usda-arkadiko amountIn)))
    (b2 (unwrap-panic (swap-usda-diko-arkadiko b1)))
    (b3 (unwrap-panic (swap-diko-alex-alex b2)))
    (b4 (unwrap-panic (swap-alex-wstx-alex b3)))
  )
    (print { b1: b1, b2: b2, b3: b3, b4: b4 })
    (begin
      (asserts! (> b4 amountIn) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2 b3 b4))
  )
)

(define-public (sell-in-usd (amountIn uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-alex-alex amountIn)))
    (b2 (unwrap-panic (swap-alex-diko-alex b1)))
    (b3 (unwrap-panic (swap-diko-usda-arkadiko b2)))
    (b4 (unwrap-panic (swap-usda-wstx-arkadiko b3)))
  )
    (print { b1: b1, b2: b2, b3: b3, b4: b4 })
    (begin
      (asserts! (> b4 amountIn) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2 b3 b4))
  )
)

(define-public (claim-rewards (amountIn uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-usda-arkadiko amountIn)))
    (b2 (unwrap-panic (swap-usda-diko-arkadiko b1)))
    (b3 (unwrap-panic (swap-diko-alex-alex b2)))
    (b4 (unwrap-panic (swap-alex-wstx-alex-2 b3)))
  )
    (print { b1: b1, b2: b2, b3: b3, b4: b4 })
    (begin
      (asserts! (> b4 amountIn) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2 b3 b4))
  )
)

(define-public (claim-pending-rewards (amountIn uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-alex-alex-2 amountIn)))
    (b2 (unwrap-panic (swap-alex-diko-alex b1)))
    (b3 (unwrap-panic (swap-diko-usda-arkadiko b2)))
    (b4 (unwrap-panic (swap-usda-wstx-arkadiko b3)))
  )
    (print { b1: b1, b2: b2, b3: b3, b4: b4 })
    (begin
      (asserts! (> b4 amountIn) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2 b3 b4))
  )
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
