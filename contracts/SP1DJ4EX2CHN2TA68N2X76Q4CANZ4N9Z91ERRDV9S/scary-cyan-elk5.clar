
(define-constant ERR_MINIMUM_RECEIVED (err u6009))
(define-constant ERR_NOT_OWNER        (err u6001))

(define-constant owner tx-sender)


(define-public (C-A-st (dx uint) (min uint) (owner-address principal) (prev-owner principal)) 
  (begin
    (asserts! (is-eq tx-sender owner) ERR_NOT_OWNER)
    (asserts! (> dx u0) (err u6002))
    ;; (let
    ;;   (
    ;;     (a1 (try! (contract-call? 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stableswap-usda-aeusdc-v-1-4 swap-y-for-x 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.usda-aeusdc-lp-token-v-1-4 dx u0)))
    ;;     (res (try! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-vaults-manager-v1-2 redeem-vault 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-vaults-tokens-v1-1 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-vaults-data-v1-1 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-vaults-sorted-v1-1 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-vaults-pool-active-v1-1 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-vaults-helpers-v1-1 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-oracle-v2-3 owner-address 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token a1 prev-owner )))
    ;;     (received (get collateral-received res)) 
    ;;   )
    ;;   (asserts! (>= received min) ERR_MINIMUM_RECEIVED)
    ;;   (ok received)
    ;; )
    (ok min)
  )
)
