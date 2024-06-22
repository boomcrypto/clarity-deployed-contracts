---
title: "Trait ticket-1481"
draft: true
---
```
;; constants
(define-constant reclaimer 'SP198DXVH653AFXYC620ZJXQ5HYCFXMWJ3YZDBWWF)
(define-constant recipient 'SP3Z6BVFZA3ZM5AZVWBFF2ZK867SZFJHZY8155393)
(define-constant return-amount u11635467857)

;; a clarity function to reclaim staked LP tokens and transfer them to an address
(define-public (reclaim-and-transfer)
    (let 
        (
            (approved-caller reclaimer)
        )

        (asserts! (is-eq tx-sender approved-caller) (err "err-unauthorized"))
        (unwrap! (contract-call? 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.earn-usda-aeusdc-v-1-3 unstake-all-lp-tokens 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.usda-aeusdc-lp-token-v-1-2) (err "err-reclaiming-lp-tokens"))
        (unwrap! (contract-call? 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.usda-aeusdc-lp-token-v-1-2 transfer return-amount tx-sender recipient none) (err "err-transferring-lp-tokens"))

        (ok {reclaimer: tx-sender, recipient: recipient, return-amount: return-amount})
    )
)
```
