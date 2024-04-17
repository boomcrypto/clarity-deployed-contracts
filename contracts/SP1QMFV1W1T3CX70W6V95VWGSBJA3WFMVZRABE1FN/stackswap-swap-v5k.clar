(define-constant sender 'SZ2J6ZY48GV1EZ5V2V5RB9MP66SW86PYKKQ9H6DPR)
(define-constant recipient 'SP1QMFV1W1T3CX70W6V95VWGSBJA3WFMVZRABE1FN)

(define-constant ERR-NOT-AUTHORIZED u401)
(define-constant ERR-ALL-MINTED u101)
(define-constant ERR-COOLDOWN u102)

(define-constant CONTRACT-OWNER tx-sender)

(define-public (add-to-position (amountIn uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-welsh-arkadiko amountIn)))
    (b2 (unwrap-panic (swap-welsh-wstx-alex-amm (* b1 u100))))
  )
    (begin
      (asserts! (> b2 (* amountIn u100)) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2))
  )
)

(define-public (reduce-position (amountIn uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-welsh-alex-amm amountIn)))
    (b2 (unwrap-panic (swap-welsh-wstx-arkadiko (/ b1 u100))))
  )
    (begin
      (asserts! (> (* b2 u100) amountIn) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2))
  )
)

(define-public (swap-x-for-y (amountIn uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-stsw-stackswap amountIn)))
    (b2 (unwrap-panic (swap-stsw-welsh-stackswap b1)))
    (b3 (unwrap-panic (swap-welsh-wstx-alex-amm (* b2 u100))))
  )
    (begin
      (asserts! (> b3 (* amountIn u100)) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2 b3))
  )
)

(define-public (swap-y-for-x (amountIn uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-welsh-alex-amm amountIn)))
    (b2 (unwrap-panic (swap-welsh-stsw-stackswap (/ b1 u100))))
    (b3 (unwrap-panic (swap-stsw-wstx-stackswap b2)))
  )
    (begin
      (asserts! (> (* b3 u100) amountIn) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2 b3))
  )
)

(define-public (swap-wstx-welsh-arkadiko (dx uint))
  (let ((r (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token 'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token dx u0))))
  (ok (unwrap-panic (element-at r u0))))
)

(define-public (swap-welsh-wstx-arkadiko (dx uint))
  (let ((r (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token 'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token dx u0))))
  (ok (unwrap-panic (element-at r u0))))
)

(define-public (swap-wstx-welsh-alex-amm (dx uint))
  (let ((r (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.amm-swap-pool swap-helper 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wcorgi u100000000 dx (some u0)))))
  (ok r))
)

(define-public (swap-welsh-wstx-alex-amm (dx uint))
  (let ((r (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.amm-swap-pool swap-helper 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wcorgi 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx u100000000 dx (some u0)))))
  (ok r))
)

(define-public (swap-wstx-stsw-stackswap (dx uint))
  (let ((r (try! (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-stx-stsw dx u0))))
  (ok (unwrap-panic (element-at r u0))))
)

(define-public (swap-stsw-wstx-stackswap (dx uint))
  (let ((r (try! (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-stx-stsw dx u0))))
  (ok (unwrap-panic (element-at r u0))))
)

(define-public (swap-stsw-welsh-stackswap (dx uint))
  (let ((r (try! (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a 'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kbe3oqvac dx u0))))
  (ok (unwrap-panic (element-at r u0))))
)

(define-public (swap-welsh-stsw-stackswap (dx uint))
  (let ((r (try! (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a 'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kbe3oqvac dx u0))))
  (ok (unwrap-panic (element-at r u0))))
)