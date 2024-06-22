;; test www
(define-constant owner tx-sender)
(define-constant ERR-MIN-FAILED u101)
(define-constant ERR-NOT-OWNER u200)






(define-public (swap (dx uint) (min uint)) 
  (let
    (
      (b1 (unwrap-panic (swap-wstx-usda-arkadiko dx)))
      (b2 (unwrap-panic (swap-usdc-usda-bitflow-v2 b1)))   
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