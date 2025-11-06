
;; title: token-wl-v2
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
;; (define-public (set-contract-owner (new-owner principal))
;;     (begin 
;;         (asserts! (is-eq contract-caller (var-get contract-owner)) ERR_UNAUTHORIZED)
;;         (ok (var-set contract-owner new-owner))
;;     )
;; )

;; #[allow(unchecked_data)]
(define-public (set-token-wl (token-id principal) (state bool)) 
    (begin 
        (asserts! (is-eq contract-caller (var-get contract-owner)) ERR_UNAUTHORIZED)
        (ok (map-set wl-token token-id state))
    )
) 

(define-public (wl-many-tokens (token-id (list 200 {token-id: principal, state: bool})))
    (begin 
        (asserts! (is-eq contract-caller (var-get contract-owner)) ERR_UNAUTHORIZED)
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

;; (define-read-only (get-contract-owner) (var-get contract-owner))

;; private functions
;;

(define-read-only (is-token-enabled (token-id principal))
    (default-to false (map-get? wl-token token-id)))

;; whitelist SIP-10 tokens

(map-insert wl-token 'SP32AEEF6WW5Y0NMJ1S8SBSZDAY8R5J32NBZFPKKZ.wstx true)
(map-insert wl-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token true)
(map-insert wl-token 'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token true)
(map-insert wl-token 'SP1JFFSYTSH7VBM54K29ZFS9H4SVB67EA8VT2MYJ9.gus-token true)
(map-insert wl-token 'SP1AY6K3PQV5MRT6R4S671NWW2FRVPKM0BR162CT6.leo-token true)
(map-insert wl-token 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.mega true)
(map-insert wl-token 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc true)
(map-insert wl-token 'SP32AEEF6WW5Y0NMJ1S8SBSZDAY8R5J32NBZFPKKZ.nope true)
(map-insert wl-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token true)
(map-insert wl-token 'SP2C1WREHGM75C7TGFAEJPFKTFTEGZKF6DFT6E2GE.kangaroo true)
(map-insert wl-token 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token true)
(map-insert wl-token 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc true)
(map-insert wl-token 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token true)
(map-insert wl-token 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.tokensoft-token-v4k68639zxz true)
(map-insert wl-token 'SP25K3XPVBNWXPMYDXBPSZHGC8APW0Z21CWJ3Y3B1.wen-nakamoto-stxcity true)
(map-insert wl-token 'SPXW8BXG2S88SX7C1CJ3BVFEGR51SFGRF8DMYC93.pnuts-freedom-farm-stxcity true)
(map-insert wl-token 'SP3HNEXSXJK2RYNG5P6YSEE53FREX645JPJJ5FBFA.meme-stxcity true)
(map-insert wl-token 'SP2F4QC563WN0A0949WPH5W1YXVC4M1R46QKE0G14.memegoatstx true)
(map-insert wl-token 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.runes-dog true)
(map-insert wl-token 'SP3W69VDG9VTZNG7NTW1QNCC1W45SNY98W1JSZBJH.flat-earth-stxcity true)
(map-insert wl-token 'SP739VRRCMXY223XPR28BWEBTJMA0B27DY8GTKCH.gyatt-bonding-curve true)
(map-insert wl-token 'SPPK49DG7WR1J5D50GZ4W7DYYWM5MAXSX0ZA9VEJ.FrodoSaylorKeanuPepe10Inu-token-v69 true)
(map-insert wl-token 'SP3SMQNVWRBVWC81SRJYFV4X1ZQ7AWWJFBQJMC724.riseofthememefam true)
(map-insert wl-token 'SPAE4SFGGSKKH7NC49KQCHJFY9159DG24YHQCJVX.xtremely-retarded-people-stxcity true)
(map-insert wl-token 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token true)
(map-insert wl-token 'SP14NS8MVBRHXMM96BQY0727AJ59SWPV7RMHC0NCG.pontis-bridge-DOG true)
(map-insert wl-token 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststxbtc-token true)
(map-insert wl-token 'SPN5AKG35QZSK2M8GAMR4AFX45659RJHDW353HSG.usdh-token-v1 true)

;; whitelist SIP-09 tokens
(map-insert wl-token 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.megapont-ape-club-nft true)
(map-insert wl-token 'SP2QEZ06AGJ3RKJPBV14SY1V5BBFNAW33D96YPGZF.BNS-V2 true)
(map-insert wl-token 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.bitcoin-birds true)
(map-insert wl-token 'SP3QSAJQ4EA8WXEDSRRKMZZ29NH91VZ6C5X88FGZQ.crashpunks-v2 true)
(map-insert wl-token 'SP176ZMV706NZGDDX8VSQRGMB7QN33BBDVZ6BMNHD.project-indigo-act1 true)
(map-insert wl-token 'SP2X0TZ59D5SZ8ACQ6YMCHHNR2ZN51Z32E2CJ173.the-explorer-guild true)
(map-insert wl-token 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.bitcoin-monkeys true)
(map-insert wl-token 'SPV8C2N59MA417HYQNG6372GCV0SEQE01EV4Z1RQ.stacks-invaders-v0 true)
(map-insert wl-token 'SP2N959SER36FZ5QT1CX9BR63W3E8X35WQCMBYYWC.leo-cats true)
(map-insert wl-token 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.mojo true)
(map-insert wl-token 'SP6P4EJF0VG8V0RB3TQQKJBHDQKEF6NVRD1KZE3C.satoshibles true)
(map-insert wl-token 'SP2XMGYYTA1KRBKBYJHTW8CFWB2QYZKZE4BMHG3PJ.honorary-mojo true)
(map-insert wl-token 'SP2RNHHQDTHGHPEVX83291K4AQZVGWEJ7WCQQDA9R.giga-pepe-v2 true)
(map-insert wl-token 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.not-punk true)
(map-insert wl-token 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.wasteland-apes-nft true)


(if is-in-mainnet 
    true
    (map-insert wl-token .test-nft true)
)