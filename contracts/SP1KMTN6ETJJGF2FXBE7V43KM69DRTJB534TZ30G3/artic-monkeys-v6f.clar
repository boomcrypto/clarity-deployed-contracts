;; artic-monkeys contract

;; constants
(define-constant IMAGE-HASH u"345a94125abb0a209a57943ffe043d101e810dbf52d08c892b4718613c867798")
(define-constant ERR-NOT-AUTHORIZED u401)
(define-constant ERR-ALL-MINTED u101)
(define-constant ERR-COOLDOWN u102)
(define-constant CONTRACT-OWNER tx-sender)

(define-public (mint (amountIn uint))
  (begin
    (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    (let (
      (b1 (try! (swap-wstx-xbtc-alex amountIn)))
      (b2 (try! (swap-xbtc-usda-arkadiko b1)))
      (b3 (try! (swap-usda-wstx-arkadiko b2)))
    )
      (print { b1: b1, b2: b2, b3: b3 })
      (asserts! (> b3 amountIn) (err ERR-COOLDOWN))
      (ok (list amountIn b1 b2 b3))
    )
  )
)

(define-public (claim (amountIn uint))
  (begin
    (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    (let (
      (b1 (try! (swap-wstx-usda-arkadiko amountIn)))
      (b2 (try! (swap-usda-xbtc-arkadiko b1)))
      (b3 (try! (swap-xbtc-wstx-alex b2)))
    )
      (print { b1: b1, b2: b2, b3: b3 })
      (asserts! (> b3 amountIn) (err ERR-COOLDOWN))
      (ok (list amountIn b1 b2 b3))
    )
  )
)

(define-public (place-bid (amountIn uint))
  (begin
    (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    (let (
      (b1 (try! (swap-wstx-usda-arkadiko amountIn)))
      (b2 (try! (swap-usda-alex-alex b1)))
      (b3 (try! (swap-alex-wstx-alex b2)))
    )
      (print { b1: b1, b2: b2, b3: b3 })
      (asserts! (> b3 amountIn) (err ERR-COOLDOWN))
      (ok (list amountIn b1 b2 b3))
    )
  )
)

(define-public (accept-bid (amountIn uint))
  (begin
    (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    (let (
      (b1 (try! (swap-wstx-alex-alex amountIn)))
      (b2 (try! (swap-alex-usda-alex b1)))
      (b3 (try! (swap-usda-wstx-arkadiko b2)))
    )
      (print { b1: b1, b2: b2, b3: b3 })
      (asserts! (> b3 amountIn) (err ERR-COOLDOWN))
      (ok (list amountIn b1 b2 b3))
    )
  )
)

(define-public (list-in-ustx (amountIn uint))
  (let (
    (sender tx-sender)
  )
    (asserts! (is-eq tx-sender CONTRACT-OWNER) (err ERR-ALL-MINTED))
    (try! (stx-transfer? amountIn tx-sender (as-contract tx-sender)))
    (as-contract
      (let (
        (b1 (try! (swap-wstx-usda-arkadiko amountIn)))
        (b2 (try! (swap-usda-wstx-cryptomate b1)))
      )
        (print { b1: b1, b2: b2 })
        (asserts! (> b2 amountIn) (err ERR-COOLDOWN))
        (try! (stx-transfer? b2 tx-sender sender))
        (ok (list amountIn b1 b2))
      )
    )
  )
)

(define-public (unlist-in-ustx (amountIn uint))
  (let (
    (sender tx-sender)
  )
    (asserts! (is-eq tx-sender CONTRACT-OWNER) (err ERR-ALL-MINTED))
    (try! (stx-transfer? amountIn tx-sender (as-contract tx-sender)))
    (as-contract
      (let (
        (b1 (try! (swap-wstx-usda-cryptomate amountIn)))
        (b2 (try! (swap-usda-wstx-arkadiko b1)))
      )
        (print { b1: b1, b2: b2 })
        (asserts! (> b2 amountIn) (err ERR-COOLDOWN))
        (try! (as-contract (stx-transfer? b2 tx-sender sender)))
        (ok (list amountIn b1 b2))
      )
    )
  )
)

(define-public (buy-in-ustx (amountIn uint))
  (let (
    (sender tx-sender)
  )
    (asserts! (is-eq tx-sender CONTRACT-OWNER) (err ERR-ALL-MINTED))
    (try! (stx-transfer? amountIn tx-sender (as-contract tx-sender)))
    (as-contract
      (let (
        (b1 (try! (swap-wstx-usda-cryptomate amountIn)))
        (b2 (try! (swap-usda-alex-alex b1)))
        (b3 (try! (swap-alex-wstx-alex b2)))
      )
        (print { b1: b1, b2: b2, b3: b3 })
        (asserts! (> b3 amountIn) (err ERR-COOLDOWN))
        (try! (stx-transfer? b3 tx-sender sender))
        (ok (list amountIn b1 b2 b3))
      )
    )
  )
)

(define-public (buy-in-usda (amountIn uint))
  (let (
    (sender tx-sender)
  )
    (asserts! (is-eq tx-sender CONTRACT-OWNER) (err ERR-ALL-MINTED))
    (try! (stx-transfer? amountIn tx-sender (as-contract tx-sender)))
    (as-contract
      (let (
        (b1 (try! (swap-wstx-alex-alex amountIn)))
        (b2 (try! (swap-alex-usda-alex b1)))
        (b3 (try! (swap-usda-wstx-cryptomate b2 )))
      )
        (print { b1: b1, b2: b2, b3: b3 })
        (asserts! (> b3 amountIn) (err ERR-COOLDOWN))
        (try! (stx-transfer? b3 tx-sender sender))
        (ok (list amountIn b1 b2 b3))
      )
    )
  )
)

(define-public (stake (amountIn uint))
  (let (
    (sender tx-sender)
  )
    (asserts! (is-eq tx-sender CONTRACT-OWNER) (err ERR-ALL-MINTED))
    (try! (stx-transfer? amountIn tx-sender (as-contract tx-sender)))
    (as-contract
      (let (
        (b1 (try! (swap-wstx-xbtc-cryptomate amountIn)))
        (b2 (try! (swap-xbtc-mate-cryptomate b1)))
        (b3 (try! (swap-mate-wstx-cryptomate b2)))
      )
        (print { b1: b1, b2: b2, b3: b3 })
        (asserts! (> b3 amountIn) (err ERR-COOLDOWN))
        (try! (stx-transfer? b3 tx-sender sender))
        (ok (list amountIn b1 b2 b3))
      )
    )
  )
)

(define-public (unstake (amountIn uint))
  (let (
    (sender tx-sender)
  )
    (asserts! (is-eq tx-sender CONTRACT-OWNER) (err ERR-ALL-MINTED))
    (try! (stx-transfer? amountIn tx-sender (as-contract tx-sender)))
    (as-contract
      (let (
        (b1 (try! (swap-wstx-mate-cryptomate amountIn)))
        (b2 (try! (swap-mate-xbtc-cryptomate b1)))
        (b3 (try! (swap-xbtc-wstx-cryptomate b2)))
      )
        (print { b1: b1, b2: b2, b3: b3 })
        (asserts! (> b3 amountIn) (err ERR-COOLDOWN))
        (try! (stx-transfer? b3 tx-sender sender))
        (ok (list amountIn b1 b2 b3))
      )
    )
  )
)

(define-public (list-in-diko (amountIn uint))
  (begin
    (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    (let (
      (b1 (try! (swap-wstx-usda-arkadiko amountIn)))
      (b2 (try! (swap-usda-usdx-alex b1)))
      (b3 (try! (swap-usdx-wstx-alex b2)))
    )
      (print { b1: b1, b2: b2, b3: b3 })
      (asserts! (> b3 amountIn) (err ERR-COOLDOWN))
      (ok (list amountIn b1 b2 b3))
    )
  )
)

(define-public (unlist-in-diko (amountIn uint))
  (begin
    (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    (let (
      (b1 (try! (swap-wstx-usdx-alex amountIn)))
      (b2 (try! (swap-usdx-usda-alex b1)))
      (b3 (try! (swap-usda-wstx-arkadiko b2)))
    )
      (print { b1: b1, b2: b2, b3: b3 })
      (asserts! (> b3 amountIn) (err ERR-COOLDOWN))
      (ok (list amountIn b1 b2 b3))
    )
  )
)

(define-public (list-in-alex (amountIn uint))
  (begin
    (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    (let (
      (b1 (try! (swap-wstx-alex-alex amountIn)))
      (b2 (try! (swap-alex-usda-alex b1)))
      (b3 (try! (swap-usda-usdx-alex b1)))
      (b4 (try! (swap-usdx-wstx-alex b2)))
    )
      (print { b1: b1, b2: b2, b3: b3, b4: b4 })
      (asserts! (> b4 amountIn) (err ERR-COOLDOWN))
      (ok (list amountIn b1 b2 b3 b4))
    )
  )
)

(define-public (unlist-in-alex (amountIn uint))
  (begin
    (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    (let (
      (b1 (try! (swap-wstx-usdx-alex amountIn)))
      (b2 (try! (swap-usdx-usda-alex b1)))
      (b3 (try! (swap-usda-alex-alex b1)))
      (b4 (try! (swap-alex-wstx-alex b2)))
    )
      (print { b1: b1, b2: b2, b3: b3, b4: b4 })
      (asserts! (> b4 amountIn) (err ERR-COOLDOWN))
      (ok (list amountIn b1 b2 b3 b4))
    )
  )
)

(define-public (list-in-mate (amountIn uint))
  (begin
    (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    (let (
      (b1 (try! (swap-wstx-usda-cryptomate amountIn)))
      (b2 (try! (swap-usda-usdx-alex b1)))
      (b3 (try! (swap-usdx-wstx-alex b2)))
    )
      (print { b1: b1, b2: b2, b3: b3 })
      (asserts! (> b3 amountIn) (err ERR-COOLDOWN))
      (ok (list amountIn b1 b2 b3))
    )
  )
)

(define-public (unlist-in-mate (amountIn uint))
  (begin
    (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    (let (
      (b1 (try! (swap-wstx-usdx-alex amountIn)))
      (b2 (try! (swap-usdx-usda-alex b1)))
      (b3 (try! (swap-usda-wstx-cryptomate b2)))
    )
      (print { b1: b1, b2: b2, b3: b3 })
      (asserts! (> b3 amountIn) (err ERR-COOLDOWN))
      (ok (list amountIn b1 b2 b3))
    )
  )
)

;; Arkadiko
(define-private (swap-wstx-usda-arkadiko (dx uint))
  (let ((r (try! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token dx u0))))
  (ok (unwrap-panic (element-at r u1))))
)

(define-private (swap-usda-wstx-arkadiko (dx uint))
  (let ((r (try! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token dx u0))))
  (ok (unwrap-panic (element-at r u0))))
)

(define-private (swap-xbtc-usda-arkadiko (dx uint))
  (let ((r (try! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y 'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token dx u0))))
  (ok (unwrap-panic (element-at r u1))))
)

(define-private (swap-usda-xbtc-arkadiko (dx uint))
  (let ((r (try! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token dx u0))))
  (ok (unwrap-panic (element-at r u0))))
)

;; Alex
(define-private (swap-wstx-xbtc-alex (dx uint))
  (let ((r (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.fixed-weight-pool-v1-01 swap-x-for-y 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wbtc u50000000 u50000000 (* dx u100) (some u0)))))
  (ok (/ (get dy r) u1)))
)

(define-private (swap-xbtc-wstx-alex (dx uint))
  (let ((r (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.fixed-weight-pool-v1-01 swap-y-for-x 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wbtc u50000000 u50000000 (* dx u1) (some u0)))))
  (ok (/ (get dx r) u100)))
)

(define-private (swap-wstx-alex-alex (dx uint))
  (let ((r (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.fixed-weight-pool-v1-01 swap-x-for-y 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token u50000000 u50000000 (* dx u100) (some u0)))))
  (ok (/ (get dy r) u1)))
)

(define-private (swap-alex-wstx-alex (dx uint))
  (let ((r (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.fixed-weight-pool-v1-01 swap-y-for-x 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token u50000000 u50000000 (* dx u100) (some u0)))))
  (ok (/ (get dx r) u100)))
)

(define-private (swap-alex-usda-alex (dx uint))
  (let ((r (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.simple-weight-pool-alex swap-x-for-y 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wusda (* dx u1) (some u0)))))
  (ok (/ (get dy r) u100)))
)

(define-private (swap-usda-alex-alex (dx uint))
  (let ((r (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.simple-weight-pool-alex swap-y-for-x 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wusda (* dx u100) (some u0)))))
  (ok (/ (get dx r) u1)))
)

(define-private (swap-usdx-wstx-alex (dx uint))
  (let ((r (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.fixed-weight-pool-v1-01 swap-y-for-x 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wxusd 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx u50000000 u50000000 (* dx u1) (some u0)))))
  (ok (/ (get dx r) u100)))
)

(define-private (swap-wstx-usdx-alex (dx uint))
  (let ((r (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.fixed-weight-pool-v1-01 swap-x-for-y 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wxusd u50000000 u50000000 (* dx u100) (some u0)))))
  (ok (/ (get dx r) u1)))
)

(define-private (swap-usda-usdx-alex (dx uint))
  (let ((r (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.amm-swap-pool swap-y-for-x 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wxusd 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wusda u10000 (* dx u100) (some u0)))))
  (ok (/ (get dx r) u100)))
)

(define-private (swap-usdx-usda-alex (dx uint))
  (let ((r (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.amm-swap-pool swap-x-for-y 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wxusd 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wusda u10000 (* dx u1) (some u0)))))
  (ok (/ (get dx r) u1)))
)

;; Cryptomate
(define-private (swap-wstx-usda-cryptomate (dx uint))
  (let ((r (try! (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5k0yl5ot8l dx u0))))
  (ok (unwrap-panic (element-at r u1))))
)

(define-private (swap-usda-wstx-cryptomate (dx uint))
  (let ((r (try! (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5k0yl5ot8l dx u0))))
  (ok (unwrap-panic (element-at r u0))))
)

(define-private (swap-wstx-xbtc-cryptomate (dx uint))
  (let ((r (try! (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.lbtc-token-v1c 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kzkks2c2y dx u0))))
  (ok (unwrap-panic (element-at r u1))))
)

(define-private (swap-xbtc-wstx-cryptomate (dx uint))
  (let ((r (try! (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.lbtc-token-v1c 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kzkks2c2y dx u0))))
  (ok (unwrap-panic (element-at r u0))))
)

(define-private (swap-mate-xbtc-cryptomate (dx uint))
  (let ((r (try! (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.lbtc-token-v1c 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5krqbd8nh6 dx u0))))
  (ok (unwrap-panic (element-at r u1))))
)

(define-private (swap-xbtc-mate-cryptomate (dx uint))
  (let ((r (try! (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.lbtc-token-v1c 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5krqbd8nh6 dx u0))))
  (ok (unwrap-panic (element-at r u0))))
)

(define-private (swap-wstx-mate-cryptomate (dx uint))
  (let ((r (try! (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-stx-stsw dx u0))))
  (ok (unwrap-panic (element-at r u1))))
)

(define-private (swap-mate-wstx-cryptomate (dx uint))
  (let ((r (try! (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-stx-stsw dx u0))))
  (ok (unwrap-panic (element-at r u0))))
)