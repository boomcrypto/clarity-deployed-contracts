;; test www
(define-constant owner tx-sender)
(define-constant ERR-MIN-FAILED u101)
(define-constant ERR-NOT-OWNER u200)


















(define-public (swap-A-S (a0 uint))
(let ((sender tx-sender))
	(asserts! (is-eq tx-sender owner) (err u0))
	(try! (stx-transfer? a0 sender (as-contract tx-sender)))
	(as-contract
	(let (
	(b0 (try! (contract-call?
		'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y
		'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
		'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
		a0 u0)))
		(a1 (unwrap-panic (element-at b0 u1)))
	(b1 (try! (contract-call?
		'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x
		'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
		'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
		'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5k0yl5ot8l
		a1 u0)))
	(a2 (unwrap-panic (element-at b1 u0)))
	)
		(asserts! (> a2 a0) (err a2))
		(try! (stx-transfer? a2 tx-sender sender))
		(ok (list a0 a1 a2))
	))))










(define-public (swap-S-A (a0 uint))
(let ((sender tx-sender))
	(asserts! (is-eq tx-sender owner) (err u0))
	(try! (stx-transfer? a0 sender (as-contract tx-sender)))
	(as-contract
	(let (
	(b0 (try! (contract-call?
		'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y
		'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
		'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
    'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5k0yl5ot8l
		a0 u0)))
		(a1 (unwrap-panic (element-at b0 u0)))
	(b1 (try! (contract-call?
		'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x
		'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
		'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
		a1 u0)))
	(a2 (unwrap-panic (element-at b1 u1)))
	)
		(asserts! (> a2 a0) (err a2))
		(try! (stx-transfer? a2 tx-sender sender))
		(ok (list a0 a1 a2))
	))))









(define-public (swap-tokens (dx uint)) 
  (let
    (
      (b1 (unwrap-panic (swap-stx-welsh-velar dx)))
      (b2 (unwrap-panic (swap-welsh-wstx-arkadiko b1)))   
    )
    (begin 
      (asserts! (is-eq tx-sender owner) (err ERR-NOT-OWNER))
      (asserts! (> b2 dx) (err ERR-MIN-FAILED))
    )
    (ok (list b1 b2))
  )
)


(define-public (swap-tokens-for (dx uint)) 
  (let
    (
      (b1 (unwrap-panic (swap-wstx-welsh-arkadiko dx)))
      (b2 (unwrap-panic (swap-welsh-stx-velar b1)))   
    )
    (begin 
      (asserts! (is-eq tx-sender owner) (err ERR-NOT-OWNER))
      (asserts! (> b2 dx) (err ERR-MIN-FAILED))
    )
    (ok (list b1 b2))
  )
)





(define-public (swapper (dx uint) (min uint)) 
  (let
    (
      (b1 (unwrap-panic (swap-wstx-usda-arkadiko dx)))
      (b2 (unwrap-panic (swap-usda-usdc-bitflow-v4 b1)))   
    )
    (begin 
      (asserts! (is-eq tx-sender owner) (err ERR-NOT-OWNER))
      (asserts! (> b2 min) (err ERR-MIN-FAILED))
    )
    (ok b2)
  )
)

(define-public (swap (dx uint) (min uint)) 
  (let
    (
      (b1 (unwrap-panic (swap-wstx-usda-arkadiko dx)))
      (b2 (unwrap-panic (swap-usda-usdc-bitflow-v2 b1)))   
    )
    (begin 
      (asserts! (is-eq tx-sender owner) (err ERR-NOT-OWNER))
      (asserts! (> b2 min) (err ERR-MIN-FAILED))
    )
    (ok b2)
  )
)




(define-public (minter (dx uint) (min uint)) 
  (let
    (
      (b1 (unwrap-panic (swap-usdc-usda-bitflow-v4 dx)))
      (b2 (unwrap-panic (swap-usda-wstx-arkadiko b1)))   
    )
    (begin 
      (asserts! (is-eq tx-sender owner) (err ERR-NOT-OWNER))
      (asserts! (> b2 min) (err ERR-MIN-FAILED))
    )
    (ok b2)
  )
)

(define-public (mint (dx uint) (min uint)) 
  (let
    (
      (b1 (unwrap-panic (swap-usdc-usda-bitflow-v2 dx)))
      (b2 (unwrap-panic (swap-usda-wstx-arkadiko b1)))   
    )
    (begin 
      (asserts! (is-eq tx-sender owner) (err ERR-NOT-OWNER))
      (asserts! (> b2 min) (err ERR-MIN-FAILED))
    )
    (ok b2)
  )
)


(define-public (swap-y-for-x (dx uint)) 
  (let
    (
      (b1 (unwrap-panic (swap-usda-usdc-bitflow-v2 dx)))
      (b2 (unwrap-panic (swap-usdc-usda-bitflow-v4 b1)))   
    )
    (begin 
      (asserts! (is-eq tx-sender owner) (err ERR-NOT-OWNER))
      (asserts! (> b2 dx) (err ERR-MIN-FAILED))
    )
    (ok b2)
  )
)

(define-public (swap-v-to-v (dx uint)) 
  (let
    (
      (b1 (unwrap-panic (swap-usda-usdc-bitflow-v4 dx)))
      (b2 (unwrap-panic (swap-usdc-usda-bitflow-v2 b1)))   
    )
    (begin 
      (asserts! (is-eq tx-sender owner) (err ERR-NOT-OWNER))
      (asserts! (> b2 dx) (err ERR-MIN-FAILED))
    )
    (ok b2)
  )
)


(define-public (swap-x-for-y (dx uint) (min uint)) 
  (let
    (
      (b1 (unwrap-panic (swap-wstx-usda-arkadiko dx)))
      (b2 (unwrap-panic (swap-usda-usdc-bitflow-v2 b1)))
      (b3 (unwrap-panic (swap-usdc-usda-bitflow-v4 b2)))
      (b4 (unwrap-panic (swap-usda-wstx-arkadiko b3)))     
    )
    (begin 
      (asserts! (is-eq tx-sender owner) (err ERR-NOT-OWNER))
      (asserts! (> b4 min) (err ERR-MIN-FAILED))
    )
    (ok b4)
  )
)












































































































































































































































































































































































;; Arkadiko
(define-public (swap-wstx-usda-arkadiko (dx uint))
  (let ((r (try! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token dx u0))))
  (ok (unwrap-panic (element-at r u1))))
)

(define-public (swap-usda-wstx-arkadiko (dx uint))
  (let ((r (try! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token dx u0))))
  (ok (unwrap-panic (element-at r u0))))
)

(define-public (swap-diko-usda-arkadiko (dx uint))
  (let ((r (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token dx u0))))
  (ok (unwrap-panic (element-at r u1))))
)

(define-public (swap-usda-diko-arkadiko (dx uint))
  (let ((r (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token dx u0))))
  (ok (unwrap-panic (element-at r u0))))
)
(define-public (swap-wstx-diko-arkadiko (dx uint))
  (let ((r (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token dx u0))))
  (ok (unwrap-panic (element-at r u1))))
)

(define-public (swap-diko-wstx-arkadiko (dx uint))
  (let ((r (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token dx u0))))
  (ok (unwrap-panic (element-at r u0))))
)
(define-public (swap-wstx-xbtc-arkadiko (dx uint))
  (let ((r (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token 'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin dx u0))))
  (ok (unwrap-panic (element-at r u1))))
)

(define-public (swap-xbtc-wstx-arkadiko (dx uint))
  (let ((r (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token 'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin dx u0))))
  (ok (unwrap-panic (element-at r u0))))
)
(define-public (swap-xbtc-usda-arkadiko (dx uint))
  (let ((r (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y 'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token dx u0))))
  (ok (unwrap-panic (element-at r u1))))
)

(define-public (swap-usda-xbtc-arkadiko (dx uint))
  (let ((r (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token dx u0))))
  (ok (unwrap-panic (element-at r u0))))
)

(define-public (swap-wstx-welsh-arkadiko (dx uint))
  (let ((r (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token 'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token dx u0))))
  (ok (unwrap-panic (element-at r u1))))
)

(define-public (swap-welsh-wstx-arkadiko (dx uint))
  (let ((r (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token 'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token dx u0))))
  (ok (unwrap-panic (element-at r u0))))
)

;; Bitflow
(define-public (swap-usda-usdc-bitflow-v2 (dx uint))
  (let ((r (try! (contract-call? 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stableswap-usda-aeusdc-v-1-2 swap-x-for-y 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.usda-aeusdc-lp-token-v-1-2 dx u0))))
  (ok r))
)

(define-public (swap-usdc-usda-bitflow-v2 (dx uint))
  (let ((r (try! (contract-call? 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stableswap-usda-aeusdc-v-1-2 swap-y-for-x 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.usda-aeusdc-lp-token-v-1-2 dx u0))))
  (ok r))
)

(define-public (swap-usda-usdc-bitflow-v4 (dx uint))
  (let ((r (try! (contract-call? 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stableswap-usda-aeusdc-v-1-4 swap-x-for-y 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.usda-aeusdc-lp-token-v-1-4 dx u0))))
  (ok r))
)

(define-public (swap-usdc-usda-bitflow-v4 (dx uint))
  (let ((r (try! (contract-call? 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stableswap-usda-aeusdc-v-1-4 swap-y-for-x 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.usda-aeusdc-lp-token-v-1-4 dx u0))))
  (ok r))
)


;; velar
(define-public (swap-stx-welsh-velar (dx uint))
  (let ((r (try! (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens u27 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx 'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx 'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to dx u0))))
  (ok (get amt-out r)))
)

;; velar
(define-public (swap-welsh-stx-velar (dx uint))
  (let ((r (try! (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens u27 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx 'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token 'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to dx u0))))
  (ok (get amt-out r)))
)