---
title: "Trait numbers"
draft: true
---
```
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
    (b1 (try! (swap-wstx-abtc-velar amountIn)))
    (b2 (try! (swap-abtc-wstx-alex b1)))
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
    (b1 (try! (swap-wstx-abtc-alex amountIn)))
    (b2 (try! (swap-abtc-wstx-velar b1)))
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
    (b1 (try! (swap-wstx-pepe-velar amountIn)))
    (b2 (try! (swap-pepe-wstx-alex b1)))
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
    (b1 (try! (swap-wstx-pepe-alex amountIn)))
    (b2 (try! (swap-pepe-wstx-velar b1)))
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
    (b1 (try! (swap-wstx-usdc-velar amountIn)))
    (b2 (try! (swap-usdc-wstx-alex b1)))
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
    (b1 (try! (swap-wstx-usdc-alex amountIn)))
    (b2 (try! (swap-usdc-wstx-velar b1)))
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
    (b1 (try! (swap-wstx-usdc-velar amountIn)))
    (b2 (try! (swap-usdc-welsh-velar b1)))
    (b3 (try! (swap-welsh-wstx-alex b2)))
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
    (b1 (try! (swap-wstx-welsh-alex amountIn)))
    (b2 (try! (swap-welsh-usdc-velar b1)))
    (b3 (try! (swap-usdc-wstx-velar b2)))
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
    (b1 (try! (swap-wstx-usdc-velar amountIn)))
    (b2 (try! (swap-usdc-leo-velar b1)))
    (b3 (try! (swap-leo-wstx-alex b2)))
  )
    (print { b1: b1, b2: b2, b3: b3 })
    (begin
      (asserts! (> b3 amountIn) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2 b3))
  )
)

(define-public (unlist-bid (amountIn uint))
  (let (
    (b1 (try! (swap-wstx-leo-alex amountIn)))
    (b2 (try! (swap-leo-usdc-velar b1)))
    (b3 (try! (swap-usdc-wstx-velar b2)))
  )
    (print { b1: b1, b2: b2, b3: b3 })
    (begin
      (asserts! (> b3 amountIn) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2 b3))
  )
)

(define-public (claim-pending-rewards (amountIn uint))
  (let (
    (b1 (try! (swap-wstx-velar-velar amountIn)))
    (b2 (try! (swap-velar-usdc-velar b1)))
    (b3 (try! (swap-usdc-wstx-velar b2)))
  )
    (print { b1: b1, b2: b2, b3: b3 })
    (begin
      (asserts! (> b3 amountIn) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2 b3))
  )
)

(define-public (get-pending-rewards (amountIn uint))
  (let (
    (b1 (try! (swap-wstx-usdc-velar amountIn)))
    (b2 (try! (swap-usdc-velar-velar b1)))
    (b3 (try! (swap-velar-wstx-velar b2)))
  )
    (print { b1: b1, b2: b2, b3: b3 })
    (begin
      (asserts! (> b3 amountIn) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2 b3))
  )
)

(define-public (revoke-in-btc (amountIn uint))
  (let (
    (b1 (try! (swap-wstx-mick-velar amountIn)))
    (b2 (try! (swap-mick-wstx-alex b1)))
  )
    (print { b1: b1, b2: b2 })
    (begin
      (asserts! (> b2 amountIn) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2))
  )
)

(define-public (send-many-btc (amountIn uint))
  (let (
    (b1 (try! (swap-wstx-mick-alex amountIn)))
    (b2 (try! (swap-mick-wstx-velar b1)))
  )
    (print { b1: b1, b2: b2 })
    (begin
      (asserts! (> b2 amountIn) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2))
  )
)

;; Velar V2

(define-public (swap-wstx-abtc-velar (dx uint))
  (let ((r (try! (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens
    u3
    'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
    'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-abtc
    'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
    'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-abtc
    'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to
    (/ dx u100)
    u1
  ))))
  (ok (get amt-out r)))
)

(define-public (swap-abtc-wstx-velar (dx uint))
  (let ((r (try! (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens
    u3
    'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
    'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-abtc
    'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-abtc
    'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
    'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to
    dx
    u1
  ))))
  (ok (* (get amt-out r) u100)))
)

(define-public (swap-wstx-usdc-velar (dx uint))
  (let ((r (try! (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens
    u6
    'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
    'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc
    'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
    'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc
    'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to
    (/ dx u100)
    u1
  ))))
  (ok (* (get amt-out r) u100)))
)

(define-public (swap-usdc-wstx-velar (dx uint))
  (let ((r (try! (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens
    u6
    'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
    'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc
    'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc
    'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
    'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to
    (/ dx u100)
    u1
  ))))
  (ok (* (get amt-out r) u100)))
)

(define-public (swap-welsh-usdc-velar (dx uint))
  (let ((r (try! (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens
    u10
    'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token
    'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc
    'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token
    'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc
    'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to
    (/ dx u100)
    u1
  ))))
  (ok (* (get amt-out r) u100)))
)

(define-public (swap-usdc-welsh-velar (dx uint))
  (let ((r (try! (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens
    u10
    'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token
    'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc
    'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc
    'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token
    'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to
    (/ dx u100)
    u1
  ))))
  (ok (* (get amt-out r) u100)))
)

(define-public (swap-leo-usdc-velar (dx uint))
  (let ((r (try! (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens
    u9
    'SP1AY6K3PQV5MRT6R4S671NWW2FRVPKM0BR162CT6.leo-token
    'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc
    'SP1AY6K3PQV5MRT6R4S671NWW2FRVPKM0BR162CT6.leo-token
    'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc
    'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to
    (/ dx u100)
    u1
  ))))
  (ok (* (get amt-out r) u100)))
)

(define-public (swap-usdc-leo-velar (dx uint))
  (let ((r (try! (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens
    u9
    'SP1AY6K3PQV5MRT6R4S671NWW2FRVPKM0BR162CT6.leo-token
    'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc
    'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc
    'SP1AY6K3PQV5MRT6R4S671NWW2FRVPKM0BR162CT6.leo-token
    'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to
    (/ dx u100)
    u1
  ))))
  (ok (* (get amt-out r) u100)))
)

(define-public (swap-wstx-velar-velar (dx uint))
  (let ((r (try! (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens
    u21
    'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.velar-token
    'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
    'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
    'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.velar-token
    'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to
    (/ dx u100)
    u1
  ))))
  (ok (* (get amt-out r) u100)))
)

(define-public (swap-velar-wstx-velar (dx uint))
  (let ((r (try! (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens
    u21
    'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.velar-token
    'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
    'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.velar-token
    'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
    'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to
    (/ dx u100)
    u1
  ))))
  (ok (* (get amt-out r) u100)))
)

(define-public (swap-usdc-velar-velar (dx uint))
  (let ((r (try! (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens
    u22
    'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.velar-token
    'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc
    'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc
    'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.velar-token
    'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to
    (/ dx u100)
    u1
  ))))
  (ok (* (get amt-out r) u100)))
)

(define-public (swap-velar-usdc-velar (dx uint))
  (let ((r (try! (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens
    u22
    'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.velar-token
    'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc
    'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc
    'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.velar-token
    'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to
    (/ dx u100)
    u1
  ))))
  (ok (* (get amt-out r) u100)))
)

(define-public (swap-wstx-pepe-velar (dx uint))
  (let ((r (try! (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens
    u11
    'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
    'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.tokensoft-token-v4k68639zxz
    'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
    'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.tokensoft-token-v4k68639zxz
    'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to
    (/ dx u100)
    u1
  ))))
  (ok (* (get amt-out r) u100000)))
)

(define-public (swap-pepe-wstx-velar (dx uint))
  (let ((r (try! (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens
    u11
    'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
    'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.tokensoft-token-v4k68639zxz
    'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.tokensoft-token-v4k68639zxz
    'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
    'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to
    (/ dx u100000)
    u1
  ))))
  (ok (* (get amt-out r) u100)))
)

(define-public (swap-wstx-mick-velar (dx uint))
  (let ((r (try! (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens
    u12
    'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
    'SP2Y8T3TR3FKH3Y2FPZVNQAEKNJXKWVS4RVQF48JE.stakemouse
    'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
    'SP2Y8T3TR3FKH3Y2FPZVNQAEKNJXKWVS4RVQF48JE.stakemouse
    'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to
    (/ dx u100)
    u1
  ))))
  (ok (* (get amt-out r) u100)))
)

(define-public (swap-mick-wstx-velar (dx uint))
  (let ((r (try! (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens
    u12
    'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
    'SP2Y8T3TR3FKH3Y2FPZVNQAEKNJXKWVS4RVQF48JE.stakemouse
    'SP2Y8T3TR3FKH3Y2FPZVNQAEKNJXKWVS4RVQF48JE.stakemouse
    'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
    'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to
    (/ dx u100)
    u1
  ))))
  (ok (* (get amt-out r) u100)))
)

;; Alex

(define-public (swap-wstx-abtc-alex (dx uint))
  (let ((r (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.amm-swap-pool-v1-1 swap-helper 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-abtc u100000000 dx (some u0)))))
  (ok r))
)

(define-public (swap-abtc-wstx-alex (dx uint))
  (let ((r (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.amm-swap-pool-v1-1 swap-helper 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-abtc 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx u100000000 dx (some u0)))))
  (ok r))
)

(define-public (swap-wstx-welsh-alex (dx uint))
  (let ((r (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.amm-swap-pool-v1-1 swap-helper 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wcorgi u100000000 dx (some u0)))))
  (ok r))
)

(define-public (swap-welsh-wstx-alex (dx uint))
  (let ((r (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.amm-swap-pool-v1-1 swap-helper 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wcorgi 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx u100000000 dx (some u0)))))
  (ok r))
)

(define-public (swap-wstx-leo-alex (dx uint))
  (let ((r (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.amm-swap-pool-v1-1 swap-helper 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wleo u100000000 dx (some u0)))))
  (ok r))
)

(define-public (swap-leo-wstx-alex (dx uint))
  (let ((r (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.amm-swap-pool-v1-1 swap-helper  'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wleo 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx u100000000 dx (some u0)))))
  (ok r))
)

(define-public (swap-wstx-pepe-alex (dx uint))
  (let ((r (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.amm-swap-pool-v1-1 swap-helper 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wpepe u100000000 dx (some u0)))))
  (ok r))
)

(define-public (swap-pepe-wstx-alex (dx uint))
  (let ((r (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.amm-swap-pool-v1-1 swap-helper 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wpepe 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx u100000000 dx (some u0)))))
  (ok r))
)

(define-public (swap-wstx-mick-alex (dx uint))
  (let ((r (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.amm-swap-pool-v1-1 swap-helper 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wmick u100000000 dx (some u0)))))
  (ok r))
)

(define-public (swap-mick-wstx-alex (dx uint))
  (let ((r (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.amm-swap-pool-v1-1 swap-helper 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wmick 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx u100000000 dx (some u0)))))
  (ok r))
)

(define-public (swap-wstx-usdc-alex (dx uint))
  (let ((r (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.amm-swap-pool-v1-1 swap-helper 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-waeusdc u100000000 dx (some u0)))))
  (ok r))
)

(define-public (swap-usdc-wstx-alex (dx uint))
  (let ((r (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.amm-swap-pool-v1-1 swap-helper 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-waeusdc 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx u100000000 dx (some u0)))))
  (ok r))
)

```
