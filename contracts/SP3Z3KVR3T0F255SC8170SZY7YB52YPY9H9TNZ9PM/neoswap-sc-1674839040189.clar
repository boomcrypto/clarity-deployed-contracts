
;; multiway-swap
;; Contract to facilitate a multiway NFT swap.
;; Each of the parties involved has to call confirm-and-escrow to escrow their dues.
;; Once all parties confirmed, finalize has to be called to redistribute escrowed items.
;; At any point before the swap is finalized it can be canceled by a party involved, 
;; regardles of whether they already called confirm-and-escrow or not.

;; traders
(define-constant TRADER-1 'SP14W78Q821B3HQ3ED30624Z1F13X4JMFZY3N5SK4)
(define-constant TRADER-2 'SP1F9156MENFJTEWE6WJPMVWFAHNGKGC7YJX6HK72)
(define-constant TRADER-3 'SP1HHSDYJ0SGAM6K2W01ZF5K7AJFKWMJNH365ZWS9)
(define-constant TRADER-4 'SP1JCPNPAMAQJ364AFHPTW3HY7X0HYZ3TJ0ZDGWZH)
(define-constant TRADER-5 'SP1Q6N226KFMA496MVWSB0VZC0T0R9FSKTYYYZ403)
(define-constant TRADER-6 'SP1RE17THZVB6ZS261EZX3BVW6J5GFXH67Z9DECJY)
(define-constant TRADER-7 'SP1T07GK9H4M0WP4N1DSSA7NJ7GNTQZ0GBZM0GAR2)
(define-constant TRADER-8 'SP1XJ6GNTDVF6HR1VHPQDMFZJY87D9W6TGMH3QCP)
(define-constant TRADER-9 'SP1XY24C7AJ8XZ2QQ5BMD43YWJBYAM388G00P354V)
(define-constant TRADER-10 'SP28NCDY6V4T7NJBMYGTJ55NHMXMC0GG806JW1ZTB)
(define-constant TRADER-11 'SP2RTAF93N1X140RJH9SD66V7EQAWRC7M0EC1ZYFE)
(define-constant TRADER-12 'SP38REZNW2QD8CSSQ3PZKWJZ84TTBTXDJDD20GKW4)
(define-constant TRADER-13 'SP3P4E5DQBJXMQ6MY5CR67G8RT9C5E8D3JK80MMKH)
(define-constant TRADER-14 'SP3TZ3BCB16A0W0PPFYMGTTWTT3DVWTQEP8DFRAG1)
(define-constant TRADER-15 'SP3WFDD787ES26F96H67T7CNC6D8QZ9X6KM5YBVJK)
(define-constant TRADER-16 'SP5G3VY7MZT8BNB6FHXZE9JD4PPF8WRT3H6JSBWW)
(define-constant TRADER-17 'SPHK8A7P61C6ASWKYDX1PCDX9YA54DKVJN49EXGJ)
(define-constant TRADER-18 'SPM1Q7YG18378H6W254YN8PABEVRPT38ZCY01SJD)
(define-constant TRADER-19 'SPQ60DRKYNQKDDEH85547FXJ8C4Q1JC0EXNA53PE)
(define-constant TRADER-20 'SPQDDZ17N21BWG06V2VDTC16A3J5Q9HZCQ9EEECX)
(define-constant TRADER-21 'SPV48Q8E5WP4TCQ63E9TV6KF9R4HP01Z8WS3FBTG)

;; receivers
(define-constant RECEIVER-1 'SP1PJ0M4N981B47GT6KERPKHN1APJH2T5NWZSV7GS)

;; constants
(define-constant ERR_ESCROW_NOT_FILLED u401)
(define-constant ERR_SWAP_FINAIZED u402)
(define-constant ERR_RELEASING_ESCROW_FAILED u491)
(define-constant ERR_SWAP_CANCELED u499)

(define-constant ERR_IS_NOT_TRADER u410)
(define-constant ERR_CALLER_ALREADY_ESCROWED u411)
(define-constant ERR_FAILED_TO_ESCROW_STX u412)
(define-constant ERR_FAILED_TO_ESCROW_NFT u413)

(define-constant SWAP_STATE_ACTIVE u100)
(define-constant SWAP_STATE_READY_TO_FINALIZE u101)
(define-constant SWAP_STATE_FINALIZED u102)
(define-constant SWAP_STATE_CANCELED u109)

(define-constant TRADER_STATE_ACTIVE u110)
(define-constant TRADER_STATE_CONFIRMED u111)
(define-constant TRADER_STATE_CANCELED u119)

(define-constant NUM_TRADERS u21)

;; data maps and vars
(define-data-var swapState uint SWAP_STATE_ACTIVE)
(define-data-var confirmCount uint u0)

(define-map TraderState principal uint)

;; Set TraderState of each trader to TRADER_STATE_ACTIVE.
(map-set TraderState TRADER-1 TRADER_STATE_ACTIVE)
(map-set TraderState TRADER-2 TRADER_STATE_ACTIVE)
(map-set TraderState TRADER-3 TRADER_STATE_ACTIVE)
(map-set TraderState TRADER-4 TRADER_STATE_ACTIVE)
(map-set TraderState TRADER-5 TRADER_STATE_ACTIVE)
(map-set TraderState TRADER-6 TRADER_STATE_ACTIVE)
(map-set TraderState TRADER-7 TRADER_STATE_ACTIVE)
(map-set TraderState TRADER-8 TRADER_STATE_ACTIVE)
(map-set TraderState TRADER-9 TRADER_STATE_ACTIVE)
(map-set TraderState TRADER-10 TRADER_STATE_ACTIVE)
(map-set TraderState TRADER-11 TRADER_STATE_ACTIVE)
(map-set TraderState TRADER-12 TRADER_STATE_ACTIVE)
(map-set TraderState TRADER-13 TRADER_STATE_ACTIVE)
(map-set TraderState TRADER-14 TRADER_STATE_ACTIVE)
(map-set TraderState TRADER-15 TRADER_STATE_ACTIVE)
(map-set TraderState TRADER-16 TRADER_STATE_ACTIVE)
(map-set TraderState TRADER-17 TRADER_STATE_ACTIVE)
(map-set TraderState TRADER-18 TRADER_STATE_ACTIVE)
(map-set TraderState TRADER-19 TRADER_STATE_ACTIVE)
(map-set TraderState TRADER-20 TRADER_STATE_ACTIVE)
(map-set TraderState TRADER-21 TRADER_STATE_ACTIVE)

;; private functions
(define-private (deposit-escrow) 
    (begin
	(if (is-eq tx-sender TRADER-1)
            (begin
		(unwrap! (contract-call? 'SP8CZNESYSP7XAWX8QA4WV23VT2D9MC8SAZAERR0.stacks-dev transfer u13 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
	    )
            true
        )
	(if (is-eq tx-sender TRADER-2)
            (begin
		(unwrap! (stx-transfer? u171625750 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_STX))
		(unwrap! (contract-call? 'SP6P4EJF0VG8V0RB3TQQKJBHDQKEF6NVRD1KZE3C.monster-satoshibles transfer u3137 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
	    )
            true
        )
	(if (is-eq tx-sender TRADER-3)
            (begin
		(unwrap! (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.stacks-punks-v3 transfer u2317 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP1D3Y8A2VVD2W98VFXCG5AXRYX5PJBBEMV1YPKF1.nonnish-grafters transfer u1827 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
	    )
            true
        )
	(if (is-eq tx-sender TRADER-4)
            (begin
		(unwrap! (stx-transfer? u270098063 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_STX))
		(unwrap! (contract-call? 'SP6P4EJF0VG8V0RB3TQQKJBHDQKEF6NVRD1KZE3C.monster-satoshibles transfer u2450 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP6P4EJF0VG8V0RB3TQQKJBHDQKEF6NVRD1KZE3C.monster-satoshibles transfer u2551 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP6P4EJF0VG8V0RB3TQQKJBHDQKEF6NVRD1KZE3C.monster-satoshibles transfer u2456 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
	    )
            true
        )
	(if (is-eq tx-sender TRADER-5)
            (begin
		(unwrap! (contract-call? 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.satoshis-team transfer u65 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.megapont-robot-component-nft transfer u42800 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
	    )
            true
        )
	(if (is-eq tx-sender TRADER-6)
            (begin
		(unwrap! (stx-transfer? u60660000 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_STX))
		(unwrap! (contract-call? 'SP6P4EJF0VG8V0RB3TQQKJBHDQKEF6NVRD1KZE3C.monster-satoshibles transfer u4407 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
	    )
            true
        )
	(if (is-eq tx-sender TRADER-7)
            (begin
		(unwrap! (contract-call? 'SP32AEEF6WW5Y0NMJ1S8SBSZDAY8R5J32NBZFPKKZ.free-punks-v0 transfer u1104 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
	    )
            true
        )
	(if (is-eq tx-sender TRADER-8)
            (begin
		(unwrap! (contract-call? 'SPYHY9MV6S08YJQVW0R400ADXZBBJ0GM096BMY34.liquidium-early-access-ticket transfer u5 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
	    )
            true
        )
	(if (is-eq tx-sender TRADER-9)
            (begin
		(unwrap! (contract-call? 'SP1XPG9QFX5M95G36SGN9R8YJ4KJ0JB7ZXNH892N6.consensus-2022 transfer u243 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
	    )
            true
        )
	(if (is-eq tx-sender TRADER-10)
            (begin
		(unwrap! (contract-call? 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.steady-lads-msa transfer u1362 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SPJJYJVZ4H7B34GG8D3SSN70WVWDYSHCC9E9ZV4V.bitcoin-toadz transfer u5434 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.megapont-space-agency transfer u4307 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
	    )
            true
        )
	(if (is-eq tx-sender TRADER-11)
            (begin
		(unwrap! (contract-call? 'SP1CSHTKVHMMQJ7PRQRFYW6SB4QAW6SR3XY2F81PA.crash-punks-boxes transfer u2452 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
	    )
            true
        )
	(if (is-eq tx-sender TRADER-12)
            (begin
		(unwrap! (stx-transfer? u25625000 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_STX))
	    )
            true
        )
	(if (is-eq tx-sender TRADER-13)
            (begin
		(unwrap! (stx-transfer? u10000000 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_STX))
	    )
            true
        )
	(if (is-eq tx-sender TRADER-14)
            (begin
		(unwrap! (stx-transfer? u312900000 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_STX))
	    )
            true
        )
	(if (is-eq tx-sender TRADER-15)
            (begin
		(unwrap! (contract-call? 'SP6P4EJF0VG8V0RB3TQQKJBHDQKEF6NVRD1KZE3C.monster-satoshibles transfer u4225 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
	    )
            true
        )
	(if (is-eq tx-sender TRADER-16)
            (begin
		(unwrap! (contract-call? 'SP3EB7YHV5NERS2HMCGSGKNMN0BEH52W9H7YE4T9C.pumpkin-heads transfer u66 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
	    )
            true
        )
	(if (is-eq tx-sender TRADER-17)
            (begin
		(unwrap! (contract-call? 'SP2KJB0E1X52J887QSVNSDF1TAWM4Y02TFW8XMVCC.pecco-bird-gank transfer u47 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3.game-on-coins transfer u58 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
	    )
            true
        )
	(if (is-eq tx-sender TRADER-18)
            (begin
		(unwrap! (contract-call? 'SP8N846PR1492HB2A08R5G96RYNKWRHDJDTBM227.luxury-cats transfer u7 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP28JPAHN4H9A531AGJ9M455ZC4GEYK6VFKVGHXG6.elpepe transfer u60 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP2BG645M86A45K524N6SHS43PXBMD456HCG1P11K.love-me-monk transfer u1 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP1XQW4W5FXJM63BJJ3QPN4DR5AXZS91476WNV76E.undead-fire-mages transfer u26 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.frontier transfer u104 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
	    )
            true
        )
	(if (is-eq tx-sender TRADER-19)
            (begin
		(unwrap! (contract-call? 'SP3K22XKPT9WJFCE957J94J6XXVZHP7747YNPDTFD.crash-punks-termination-shock transfer u123 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP6P4EJF0VG8V0RB3TQQKJBHDQKEF6NVRD1KZE3C.monster-satoshibles transfer u4040 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
	    )
            true
        )
	(if (is-eq tx-sender TRADER-20)
            (begin
		(unwrap! (contract-call? 'SP6P4EJF0VG8V0RB3TQQKJBHDQKEF6NVRD1KZE3C.monster-satoshibles transfer u718 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
	    )
            true
        )
	(if (is-eq tx-sender TRADER-21)
            (begin
		(unwrap! (stx-transfer? u13812500 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_STX))
	    )
            true
        )

        (map-set TraderState tx-sender TRADER_STATE_CONFIRMED)
        (unwrap-panic (update-swap-state))
        (ok true)
    )
)

(define-private (release-escrow) 
    (begin
	(unwrap-panic (as-contract (contract-call? 'SP6P4EJF0VG8V0RB3TQQKJBHDQKEF6NVRD1KZE3C.monster-satoshibles transfer u2551 tx-sender TRADER-2)))
	(unwrap-panic (as-contract (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.frontier transfer u104 tx-sender TRADER-2)))
	(unwrap-panic (as-contract (contract-call? 'SPJJYJVZ4H7B34GG8D3SSN70WVWDYSHCC9E9ZV4V.bitcoin-toadz transfer u5434 tx-sender TRADER-2)))
	(unwrap-panic (as-contract (contract-call? 'SP6P4EJF0VG8V0RB3TQQKJBHDQKEF6NVRD1KZE3C.monster-satoshibles transfer u4040 tx-sender TRADER-2)))
	(unwrap-panic (as-contract (contract-call? 'SP1D3Y8A2VVD2W98VFXCG5AXRYX5PJBBEMV1YPKF1.nonnish-grafters transfer u1827 tx-sender TRADER-2)))
	(unwrap-panic (as-contract (contract-call? 'SP3K22XKPT9WJFCE957J94J6XXVZHP7747YNPDTFD.crash-punks-termination-shock transfer u123 tx-sender TRADER-2)))
	(unwrap-panic (as-contract (contract-call? 'SP3EB7YHV5NERS2HMCGSGKNMN0BEH52W9H7YE4T9C.pumpkin-heads transfer u66 tx-sender TRADER-4)))
	(unwrap-panic (as-contract (contract-call? 'SP2KJB0E1X52J887QSVNSDF1TAWM4Y02TFW8XMVCC.pecco-bird-gank transfer u47 tx-sender TRADER-4)))
	(unwrap-panic (as-contract (contract-call? 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.megapont-space-agency transfer u4307 tx-sender TRADER-4)))
	(unwrap-panic (as-contract (contract-call? 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3.game-on-coins transfer u58 tx-sender TRADER-4)))
	(unwrap-panic (as-contract (contract-call? 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.steady-lads-msa transfer u1362 tx-sender TRADER-4)))
	(unwrap-panic (as-contract (contract-call? 'SP32AEEF6WW5Y0NMJ1S8SBSZDAY8R5J32NBZFPKKZ.free-punks-v0 transfer u1104 tx-sender TRADER-4)))
	(unwrap-panic (as-contract (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.stacks-punks-v3 transfer u2317 tx-sender TRADER-4)))
	(unwrap-panic (as-contract (contract-call? 'SP8CZNESYSP7XAWX8QA4WV23VT2D9MC8SAZAERR0.stacks-dev transfer u13 tx-sender TRADER-4)))
	(unwrap-panic (as-contract (contract-call? 'SP8N846PR1492HB2A08R5G96RYNKWRHDJDTBM227.luxury-cats transfer u7 tx-sender TRADER-4)))
	(unwrap-panic (as-contract (contract-call? 'SP2BG645M86A45K524N6SHS43PXBMD456HCG1P11K.love-me-monk transfer u1 tx-sender TRADER-5)))
	(unwrap-panic (as-contract (contract-call? 'SP6P4EJF0VG8V0RB3TQQKJBHDQKEF6NVRD1KZE3C.monster-satoshibles transfer u718 tx-sender TRADER-6)))
	(unwrap-panic (as-contract (contract-call? 'SP6P4EJF0VG8V0RB3TQQKJBHDQKEF6NVRD1KZE3C.monster-satoshibles transfer u2450 tx-sender TRADER-6)))
	(unwrap-panic (as-contract (contract-call? 'SP6P4EJF0VG8V0RB3TQQKJBHDQKEF6NVRD1KZE3C.monster-satoshibles transfer u2456 tx-sender TRADER-12)))
	(unwrap-panic (as-contract (contract-call? 'SP1XPG9QFX5M95G36SGN9R8YJ4KJ0JB7ZXNH892N6.consensus-2022 transfer u243 tx-sender TRADER-13)))
	(unwrap-panic (as-contract (contract-call? 'SP6P4EJF0VG8V0RB3TQQKJBHDQKEF6NVRD1KZE3C.monster-satoshibles transfer u4225 tx-sender TRADER-14)))
	(unwrap-panic (as-contract (contract-call? 'SP1CSHTKVHMMQJ7PRQRFYW6SB4QAW6SR3XY2F81PA.crash-punks-boxes transfer u2452 tx-sender TRADER-14)))
	(unwrap-panic (as-contract (contract-call? 'SP6P4EJF0VG8V0RB3TQQKJBHDQKEF6NVRD1KZE3C.monster-satoshibles transfer u4407 tx-sender TRADER-14)))
	(unwrap-panic (as-contract (contract-call? 'SP6P4EJF0VG8V0RB3TQQKJBHDQKEF6NVRD1KZE3C.monster-satoshibles transfer u3137 tx-sender TRADER-14)))
	(unwrap-panic (as-contract (contract-call? 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.satoshis-team transfer u65 tx-sender TRADER-16)))
	(unwrap-panic (as-contract (contract-call? 'SP28JPAHN4H9A531AGJ9M455ZC4GEYK6VFKVGHXG6.elpepe transfer u60 tx-sender TRADER-16)))
	(unwrap-panic (as-contract (contract-call? 'SP1XQW4W5FXJM63BJJ3QPN4DR5AXZS91476WNV76E.undead-fire-mages transfer u26 tx-sender TRADER-17)))
	(unwrap-panic (as-contract (contract-call? 'SPYHY9MV6S08YJQVW0R400ADXZBBJ0GM096BMY34.liquidium-early-access-ticket transfer u5 tx-sender TRADER-21)))
	(unwrap-panic (as-contract (contract-call? 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.megapont-robot-component-nft transfer u42800 tx-sender TRADER-21)))

	(unwrap-panic (as-contract (stx-transfer? u26014950 tx-sender TRADER-1)))
	(unwrap-panic (as-contract (stx-transfer? u60937500 tx-sender TRADER-3)))
	(unwrap-panic (as-contract (stx-transfer? u34831626 tx-sender RECEIVER-1)))
	(unwrap-panic (as-contract (stx-transfer? u1961000 tx-sender TRADER-5)))
	(unwrap-panic (as-contract (stx-transfer? u1945125 tx-sender TRADER-7)))
	(unwrap-panic (as-contract (stx-transfer? u12187500 tx-sender TRADER-8)))
	(unwrap-panic (as-contract (stx-transfer? u10000000 tx-sender TRADER-9)))
	(unwrap-panic (as-contract (stx-transfer? u202000000 tx-sender TRADER-10)))
	(unwrap-panic (as-contract (stx-transfer? u28000000 tx-sender TRADER-11)))
	(unwrap-panic (as-contract (stx-transfer? u150000000 tx-sender TRADER-15)))
	(unwrap-panic (as-contract (stx-transfer? u10299362 tx-sender TRADER-16)))
	(unwrap-panic (as-contract (stx-transfer? u76987500 tx-sender TRADER-17)))
	(unwrap-panic (as-contract (stx-transfer? u121425000 tx-sender TRADER-18)))
	(unwrap-panic (as-contract (stx-transfer? u72471750 tx-sender TRADER-19)))
	(unwrap-panic (as-contract (stx-transfer? u55660000 tx-sender TRADER-20)))

        (var-set swapState SWAP_STATE_FINALIZED)
        (ok true)
    )
)

(define-private (return-escrow) 
    (begin 
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-1)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (contract-call? 'SP8CZNESYSP7XAWX8QA4WV23VT2D9MC8SAZAERR0.stacks-dev transfer u13 tx-sender TRADER-1)))
	    )
            true
        )
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-1)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (stx-transfer? u171625750 tx-sender TRADER-2)))
		(unwrap-panic (as-contract (contract-call? 'SP6P4EJF0VG8V0RB3TQQKJBHDQKEF6NVRD1KZE3C.monster-satoshibles transfer u3137 tx-sender TRADER-2)))
	    )
            true
        )
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-1)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.stacks-punks-v3 transfer u2317 tx-sender TRADER-3)))
		(unwrap-panic (as-contract (contract-call? 'SP1D3Y8A2VVD2W98VFXCG5AXRYX5PJBBEMV1YPKF1.nonnish-grafters transfer u1827 tx-sender TRADER-3)))
	    )
            true
        )
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-1)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (stx-transfer? u270098063 tx-sender TRADER-4)))
		(unwrap-panic (as-contract (contract-call? 'SP6P4EJF0VG8V0RB3TQQKJBHDQKEF6NVRD1KZE3C.monster-satoshibles transfer u2450 tx-sender TRADER-4)))
		(unwrap-panic (as-contract (contract-call? 'SP6P4EJF0VG8V0RB3TQQKJBHDQKEF6NVRD1KZE3C.monster-satoshibles transfer u2551 tx-sender TRADER-4)))
		(unwrap-panic (as-contract (contract-call? 'SP6P4EJF0VG8V0RB3TQQKJBHDQKEF6NVRD1KZE3C.monster-satoshibles transfer u2456 tx-sender TRADER-4)))
	    )
            true
        )
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-1)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (contract-call? 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.satoshis-team transfer u65 tx-sender TRADER-5)))
		(unwrap-panic (as-contract (contract-call? 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.megapont-robot-component-nft transfer u42800 tx-sender TRADER-5)))
	    )
            true
        )
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-1)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (stx-transfer? u60660000 tx-sender TRADER-6)))
		(unwrap-panic (as-contract (contract-call? 'SP6P4EJF0VG8V0RB3TQQKJBHDQKEF6NVRD1KZE3C.monster-satoshibles transfer u4407 tx-sender TRADER-6)))
	    )
            true
        )
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-1)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (contract-call? 'SP32AEEF6WW5Y0NMJ1S8SBSZDAY8R5J32NBZFPKKZ.free-punks-v0 transfer u1104 tx-sender TRADER-7)))
	    )
            true
        )
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-1)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (contract-call? 'SPYHY9MV6S08YJQVW0R400ADXZBBJ0GM096BMY34.liquidium-early-access-ticket transfer u5 tx-sender TRADER-8)))
	    )
            true
        )
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-1)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (contract-call? 'SP1XPG9QFX5M95G36SGN9R8YJ4KJ0JB7ZXNH892N6.consensus-2022 transfer u243 tx-sender TRADER-9)))
	    )
            true
        )
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-1)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (contract-call? 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.steady-lads-msa transfer u1362 tx-sender TRADER-10)))
		(unwrap-panic (as-contract (contract-call? 'SPJJYJVZ4H7B34GG8D3SSN70WVWDYSHCC9E9ZV4V.bitcoin-toadz transfer u5434 tx-sender TRADER-10)))
		(unwrap-panic (as-contract (contract-call? 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.megapont-space-agency transfer u4307 tx-sender TRADER-10)))
	    )
            true
        )
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-1)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (contract-call? 'SP1CSHTKVHMMQJ7PRQRFYW6SB4QAW6SR3XY2F81PA.crash-punks-boxes transfer u2452 tx-sender TRADER-11)))
	    )
            true
        )
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-1)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (stx-transfer? u25625000 tx-sender TRADER-12)))
	    )
            true
        )
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-1)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (stx-transfer? u10000000 tx-sender TRADER-13)))
	    )
            true
        )
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-1)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (stx-transfer? u312900000 tx-sender TRADER-14)))
	    )
            true
        )
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-1)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (contract-call? 'SP6P4EJF0VG8V0RB3TQQKJBHDQKEF6NVRD1KZE3C.monster-satoshibles transfer u4225 tx-sender TRADER-15)))
	    )
            true
        )
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-1)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (contract-call? 'SP3EB7YHV5NERS2HMCGSGKNMN0BEH52W9H7YE4T9C.pumpkin-heads transfer u66 tx-sender TRADER-16)))
	    )
            true
        )
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-1)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (contract-call? 'SP2KJB0E1X52J887QSVNSDF1TAWM4Y02TFW8XMVCC.pecco-bird-gank transfer u47 tx-sender TRADER-17)))
		(unwrap-panic (as-contract (contract-call? 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3.game-on-coins transfer u58 tx-sender TRADER-17)))
	    )
            true
        )
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-1)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (contract-call? 'SP8N846PR1492HB2A08R5G96RYNKWRHDJDTBM227.luxury-cats transfer u7 tx-sender TRADER-18)))
		(unwrap-panic (as-contract (contract-call? 'SP28JPAHN4H9A531AGJ9M455ZC4GEYK6VFKVGHXG6.elpepe transfer u60 tx-sender TRADER-18)))
		(unwrap-panic (as-contract (contract-call? 'SP2BG645M86A45K524N6SHS43PXBMD456HCG1P11K.love-me-monk transfer u1 tx-sender TRADER-18)))
		(unwrap-panic (as-contract (contract-call? 'SP1XQW4W5FXJM63BJJ3QPN4DR5AXZS91476WNV76E.undead-fire-mages transfer u26 tx-sender TRADER-18)))
		(unwrap-panic (as-contract (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.frontier transfer u104 tx-sender TRADER-18)))
	    )
            true
        )
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-1)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (contract-call? 'SP3K22XKPT9WJFCE957J94J6XXVZHP7747YNPDTFD.crash-punks-termination-shock transfer u123 tx-sender TRADER-19)))
		(unwrap-panic (as-contract (contract-call? 'SP6P4EJF0VG8V0RB3TQQKJBHDQKEF6NVRD1KZE3C.monster-satoshibles transfer u4040 tx-sender TRADER-19)))
	    )
            true
        )
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-1)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (contract-call? 'SP6P4EJF0VG8V0RB3TQQKJBHDQKEF6NVRD1KZE3C.monster-satoshibles transfer u718 tx-sender TRADER-20)))
	    )
            true
        )
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-1)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (stx-transfer? u13812500 tx-sender TRADER-21)))
	    )
            true
        )

        (map-set TraderState tx-sender TRADER_STATE_CANCELED)
        (var-set swapState SWAP_STATE_CANCELED)
        (ok true)
    )
)

(define-private (update-swap-state) 
    (let 
        ((cfCount (+ (var-get confirmCount) u1)))

        (var-set confirmCount cfCount)
        (if 
            (is-eq cfCount NUM_TRADERS)
            (var-set swapState SWAP_STATE_READY_TO_FINALIZE)
            true
        )
        (ok true)
    )
)

;; public functions
(define-read-only (get-swap-state) 
  (ok (var-get swapState))
)

(define-read-only (get-trader-state (trader principal)) 
  (unwrap! (map-get? TraderState trader) ERR_IS_NOT_TRADER)
)

(define-public (confirm-and-escrow) 
    (let 
        ((trState (unwrap! (map-get? TraderState tx-sender) (err ERR_IS_NOT_TRADER))))

        (asserts! (not (is-eq (var-get swapState) SWAP_STATE_FINALIZED)) (err ERR_SWAP_FINAIZED))
        (asserts! (not (is-eq (var-get swapState) SWAP_STATE_CANCELED)) (err ERR_SWAP_CANCELED))
        (asserts! (not (is-eq trState TRADER_STATE_CONFIRMED)) (err ERR_CALLER_ALREADY_ESCROWED))
        (try! (deposit-escrow))
        (ok true)
    )
)

(define-public (cancel) 
    (begin
        (unwrap! (map-get? TraderState tx-sender) (err ERR_IS_NOT_TRADER))
        (asserts! (not (is-eq (var-get swapState) SWAP_STATE_FINALIZED)) (err ERR_SWAP_FINAIZED))
        (asserts! (not (is-eq (var-get swapState) SWAP_STATE_CANCELED)) (err ERR_SWAP_CANCELED))
        (unwrap! (return-escrow) (err ERR_RELEASING_ESCROW_FAILED))
        (ok true)
    )
)

(define-public (finalize) 
    (begin
        (asserts! (not (is-eq (var-get swapState) SWAP_STATE_ACTIVE)) (err ERR_ESCROW_NOT_FILLED))
        (asserts! (not (is-eq (var-get swapState) SWAP_STATE_FINALIZED)) (err ERR_SWAP_FINAIZED))
        (asserts! (not (is-eq (var-get swapState) SWAP_STATE_CANCELED)) (err ERR_SWAP_CANCELED))
        (unwrap! (release-escrow) (err ERR_RELEASING_ESCROW_FAILED))
        (ok true)
    )
)
