---
title: "Trait ZADAO-token-whitelist-v1"
draft: true
---
```

;; title: token-wl by Zero Authority DAO 
;; version:
;; summary:
;; description:

;; traits
;;

;; token definitions
;;

;; constants
;;
(define-constant ERR_UNAUTHORIZED (err u401))
;; data vars
;;
(define-data-var contract-owner principal tx-sender)

;; data maps
;;
(define-map wl-token principal bool)

;; public functions
;;

;; #[allow(unchecked_data)]
(define-public (set-token-wl (token-id principal) (state bool)) 
    (begin 
        (asserts! (is-eq tx-sender (var-get contract-owner)) ERR_UNAUTHORIZED)
        (ok (map-set wl-token token-id state))
    )
) 

(define-public (wl-many-tokens (token-id (list 200 {token-id: principal, state: bool})))
    (begin 
        (asserts! (is-eq tx-sender (var-get contract-owner)) ERR_UNAUTHORIZED)
        (map iter-wl-tokens token-id)
        (ok true))
)

(define-private (iter-wl-tokens (token {token-id: principal, state: bool}))
        (map-set wl-token (get token-id token) (get state token)))

;; read only functions
;;
(define-read-only (get-token-wl (token-id principal))
    ;; #[allow(unchecked_data)]
    (ok (is-token-enabled token-id))
)
;; private functions
;;

(define-read-only (is-token-enabled (token-id principal))
    (default-to false (map-get? wl-token token-id)))

(map-insert wl-token 'SP32AEEF6WW5Y0NMJ1S8SBSZDAY8R5J32NBZFPKKZ.wstx true)
(map-insert wl-token 'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token true)
(map-insert wl-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token true)
(map-insert wl-token 'SP1JFFSYTSH7VBM54K29ZFS9H4SVB67EA8VT2MYJ9.gus-token true)
(map-insert wl-token 'SP1AY6K3PQV5MRT6R4S671NWW2FRVPKM0BR162CT6.leo-token true)
(map-insert wl-token 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.mega true)
(map-insert wl-token 'SP32AEEF6WW5Y0NMJ1S8SBSZDAY8R5J32NBZFPKKZ.nope true)
(map-insert wl-token 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-abtc true)
(map-insert wl-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token true)
(map-insert wl-token 'SP2C1WREHGM75C7TGFAEJPFKTFTEGZKF6DFT6E2GE.kangaroo true)
(map-insert wl-token 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token true)
(map-insert wl-token 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc true)
(map-insert wl-token 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.auto-alex-v2 true)
(map-insert wl-token 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token true)
(map-insert wl-token 'SP6P4EJF0VG8V0RB3TQQKJBHDQKEF6NVRD1KZE3C.satoshibles true)
(map-insert wl-token 'SPN5AKG35QZSK2M8GAMR4AFX45659RJHDW353HSG.usdh-token-v1 true)
(map-insert wl-token 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.megapont-ape-club-mint true)
(map-insert wl-token 'SP000000000000000000002Q6VF78.bns true)
(map-insert wl-token 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.bitcoin-birds true)
(map-insert wl-token 'SP3QSAJQ4EA8WXEDSRRKMZZ29NH91VZ6C5X88FGZQ.crashpunks-v2 true)
(map-insert wl-token 'SP176ZMV706NZGDDX8VSQRGMB7QN33BBDVZ6BMNHD.project-indigo-act1 true)
(map-insert wl-token 'SP2X0TZ59D5SZ8ACQ6YMCHHNR2ZN51Z32E2CJ173.the-explorer-guild true)
(map-insert wl-token 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.bitcoin-monkeys true)
(map-insert wl-token 'SPV8C2N59MA417HYQNG6372GCV0SEQE01EV4Z1RQ.stacks-invaders-v0 true)
```
