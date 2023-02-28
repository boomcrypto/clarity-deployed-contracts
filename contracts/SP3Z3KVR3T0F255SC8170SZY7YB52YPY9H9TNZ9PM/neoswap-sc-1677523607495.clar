;; multiway-swap
;; Contract to facilitate a multiway NFT swap.
;; Each of the parties involved has to call confirm-and-escrow to escrow their dues.
;; Once all parties confirmed, finalize has to be called to redistribute escrowed items.
;; At any point before the swap is finalized it can be canceled by a party involved, 
;; regardles of whether they already called confirm-and-escrow or not.

;; traders
(define-constant TRADER-1 'SP12VXAS7H2MT7R8116F4RA1FCS21DZ86B4DTN80J)
(define-constant TRADER-2 'SP1335DXY4JFH44F47CHNM9E5D7430762C5FA0SCX)
(define-constant TRADER-3 'SP14NSM2BAB9MGMYNXJB93NY4EF4NFRW3G3EFBZDX)
(define-constant TRADER-4 'SP197GMEG6WGBRDTCTGGWMRA1G77E65TRXWYKGCT7)
(define-constant TRADER-5 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH)
(define-constant TRADER-6 'SP1FJN5P7V9W2K96VN7YWGH7VP36RB5K5JW1R9HF7)
(define-constant TRADER-7 'SP1FW0F2ZYZHXT1BVV8HX8ZXG3MRM0ZVH73QE9VSV)
(define-constant TRADER-8 'SP1HHSDYJ0SGAM6K2W01ZF5K7AJFKWMJNH365ZWS9)
(define-constant TRADER-9 'SP1JCPNPAMAQJ364AFHPTW3HY7X0HYZ3TJ0ZDGWZH)
(define-constant TRADER-10 'SP1JQCYDVHKE8RWBJ9JSX8ZH6TVTX0TH2F7D3A8YJ)
(define-constant TRADER-11 'SP1Q6N226KFMA496MVWSB0VZC0T0R9FSKTYYYZ403)
(define-constant TRADER-12 'SP1T7VV0H6TWC3B834XG62VAPXHP3245VJSCDGX0K)
(define-constant TRADER-13 'SP27E3TDKYNH3C11RBDFPD5WGR6FV0VN08RKX4D2N)
(define-constant TRADER-14 'SP28NCDY6V4T7NJBMYGTJ55NHMXMC0GG806JW1ZTB)
(define-constant TRADER-15 'SP2NM9ZX3A1NWJN5Q8X97RTC0AMG4FHBWSCZSYRPV)
(define-constant TRADER-16 'SP364J7EDJXRE1FPDZDABP9M58HPY4G88BFCP2HD0)
(define-constant TRADER-17 'SP3BTPH354JEM3E8AYAHQS9SWJ591TJQYD9QK0MCF)
(define-constant TRADER-18 'SP3P4E5DQBJXMQ6MY5CR67G8RT9C5E8D3JK80MMKH)
(define-constant TRADER-19 'SP3WWZT5N7DVHQV71EADFFM9TQCSA6MZJDB9H3M0T)
(define-constant TRADER-20 'SP89GR14YXT07494HRWRHEQ8MDMQ3D231V2QPH1S)
(define-constant TRADER-21 'SPCV4DY5FJZCY5TYX3EQ61HDR9MVH9R39YJ35CH7)
(define-constant TRADER-22 'SPHK8A7P61C6ASWKYDX1PCDX9YA54DKVJN49EXGJ)
(define-constant TRADER-23 'SPP4RMFNQ3KTMA2SVRMT98C5FV2S8KK72BR11ED9)

;; receivers


;; constants
(define-constant ERR_ESCROW_NOT_FILLED u401)
(define-constant ERR_SWAP_FINALIZED u402)
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

(define-constant NUM_TRADERS u23)

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
(map-set TraderState TRADER-22 TRADER_STATE_ACTIVE)
(map-set TraderState TRADER-23 TRADER_STATE_ACTIVE)

;; private functions
(define-private (deposit-escrow) 
    (begin
	(if (is-eq tx-sender TRADER-1)
            (begin
		(unwrap! (contract-call? 'SP364J7EDJXRE1FPDZDABP9M58HPY4G88BFCP2HD0.the-girl-from-stacks transfer u53 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.blocksurvey transfer u104 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP22GHCK5W3EK5VC1PEB3VVCBVFRQNTQXV9306QA0.metacine transfer u304 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP364J7EDJXRE1FPDZDABP9M58HPY4G88BFCP2HD0.the-girl-from-stacks transfer u2 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP2HV9HYWZRAPTCC10VXCK72P3W4F9NDB8E1HBEZH.verified-pepe-checks-edition transfer u95 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP3252T1HMQHZTA9S22WZ2HZMKC4CVH965SHSERTH.the-guests-woymuls transfer u50 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
	    )
            true
        )
	(if (is-eq tx-sender TRADER-2)
            (begin
		(unwrap! (contract-call? 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.btc-sports-og-soccer transfer u29 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP2P6KSAJ4JVV8PFSNKJ9BNG5PEPR4RT71VXZHWBK.tiger-force transfer u1024 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP2N3BAG4GBF8NHRPH6AY4YYH1SP6NK5TGCY7RDFA.stacks-mfers transfer u1081 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.hback-whales-nft transfer u1477 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
	    )
            true
        )
	(if (is-eq tx-sender TRADER-3)
            (begin
		(unwrap! (stx-transfer? u1100000 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_STX))
	    )
            true
        )
	(if (is-eq tx-sender TRADER-4)
            (begin
		(unwrap! (stx-transfer? u13000000 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_STX))
	    )
            true
        )
	(if (is-eq tx-sender TRADER-5)
            (begin
		(unwrap! (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-bitcoin-bears transfer u142 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
	    )
            true
        )
	(if (is-eq tx-sender TRADER-6)
            (begin
		(unwrap! (contract-call? 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.nfts-for-peace transfer u199 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
	    )
            true
        )
	(if (is-eq tx-sender TRADER-7)
            (begin
		(unwrap! (stx-transfer? u139500000 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_STX))
	    )
            true
        )
	(if (is-eq tx-sender TRADER-8)
            (begin
		(unwrap! (stx-transfer? u60000000 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_STX))
	    )
            true
        )
	(if (is-eq tx-sender TRADER-9)
            (begin
		(unwrap! (contract-call? 'SP6P4EJF0VG8V0RB3TQQKJBHDQKEF6NVRD1KZE3C.satoshibles transfer u4351 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP6P4EJF0VG8V0RB3TQQKJBHDQKEF6NVRD1KZE3C.monster-satoshibles transfer u4580 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP6P4EJF0VG8V0RB3TQQKJBHDQKEF6NVRD1KZE3C.monster-satoshibles transfer u4567 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP6P4EJF0VG8V0RB3TQQKJBHDQKEF6NVRD1KZE3C.monster-satoshibles transfer u4240 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP6P4EJF0VG8V0RB3TQQKJBHDQKEF6NVRD1KZE3C.monster-satoshibles transfer u4574 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
	    )
            true
        )
	(if (is-eq tx-sender TRADER-10)
            (begin
		(unwrap! (stx-transfer? u80000000 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_STX))
	    )
            true
        )
	(if (is-eq tx-sender TRADER-11)
            (begin
		(unwrap! (stx-transfer? u5100000 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_STX))
	    )
            true
        )
	(if (is-eq tx-sender TRADER-12)
            (begin
		(unwrap! (contract-call? 'SPWGSV28BN5QMQ618CZAPDD18XPSN6EK776CDS84.magic-sound transfer u78 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SPJJYJVZ4H7B34GG8D3SSN70WVWDYSHCC9E9ZV4V.bitcoin-toadz transfer u2582 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SPDKRP4ESV0037MT3SX0WE817WVR9EQ9A0JBVRP4.atlantic-dolphins transfer u20 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
	    )
            true
        )
	(if (is-eq tx-sender TRADER-13)
            (begin
		(unwrap! (stx-transfer? u258900000 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_STX))
		(unwrap! (contract-call? 'SPM1Q7YG18378H6W254YN8PABEVRPT38ZCY01SJD.stxphotography-one-life transfer u18 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP1XJ6GNTDVF6HR1VHPQDMFZJY87D9W6TGMH3QCP.passion-of-christ transfer u5 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP3273YEPG4QZWX0ENQ98FBT1N2Y06XW820STP7NN.straight-outta-lightroom transfer u5 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP3273YEPG4QZWX0ENQ98FBT1N2Y06XW820STP7NN.straight-outta-lightroom transfer u8 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP3EB7YHV5NERS2HMCGSGKNMN0BEH52W9H7YE4T9C.mendaxx-ai-world transfer u1 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SPM1Q7YG18378H6W254YN8PABEVRPT38ZCY01SJD.stxphotography-one-life transfer u20 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP2R2AN769WEF2BRB8N4M42K4YFZ297FNTK1HCDY4.art-according-to-ai transfer u5 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
	    )
            true
        )
	(if (is-eq tx-sender TRADER-14)
            (begin
		(unwrap! (contract-call? 'SP3WFDD787ES26F96H67T7CNC6D8QZ9X6KM5YBVJK.punk-skull transfer u10 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP3WNCSE4PYGS5Y8VSYM9P68RFVS5Z30G3QF7T8ZB.zumbies-and-gublins transfer u74 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
	    )
            true
        )
	(if (is-eq tx-sender TRADER-15)
            (begin
		(unwrap! (stx-transfer? u119000000 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_STX))
	    )
            true
        )
	(if (is-eq tx-sender TRADER-16)
            (begin
		(unwrap! (stx-transfer? u432000000 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_STX))
	    )
            true
        )
	(if (is-eq tx-sender TRADER-17)
            (begin
		(unwrap! (stx-transfer? u175000000 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_STX))
	    )
            true
        )
	(if (is-eq tx-sender TRADER-18)
            (begin
		(unwrap! (stx-transfer? u52500000 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_STX))
	    )
            true
        )
	(if (is-eq tx-sender TRADER-19)
            (begin
		(unwrap! (stx-transfer? u8000000 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_STX))
	    )
            true
        )
	(if (is-eq tx-sender TRADER-20)
            (begin
		(unwrap! (contract-call? 'SP248HH800501WYSG7Z2SS1ZWHQW1GGH85ME34NT2.layer-v2-1 transfer u19661 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.genesis-64 transfer u19 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
	    )
            true
        )
	(if (is-eq tx-sender TRADER-21)
            (begin
		(unwrap! (stx-transfer? u26000000 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_STX))
	    )
            true
        )
	(if (is-eq tx-sender TRADER-22)
            (begin
		(unwrap! (stx-transfer? u200000 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_STX))
	    )
            true
        )
	(if (is-eq tx-sender TRADER-23)
            (begin
		(unwrap! (stx-transfer? u50000000 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_STX))
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
	(unwrap-panic (as-contract (contract-call? 'SP3WNCSE4PYGS5Y8VSYM9P68RFVS5Z30G3QF7T8ZB.zumbies-and-gublins transfer u74 tx-sender TRADER-3)))
	(unwrap-panic (as-contract (contract-call? 'SP2N3BAG4GBF8NHRPH6AY4YYH1SP6NK5TGCY7RDFA.stacks-mfers transfer u1081 tx-sender TRADER-4)))
	(unwrap-panic (as-contract (contract-call? 'SP1XJ6GNTDVF6HR1VHPQDMFZJY87D9W6TGMH3QCP.passion-of-christ transfer u5 tx-sender TRADER-7)))
	(unwrap-panic (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.hback-whales-nft transfer u1477 tx-sender TRADER-7)))
	(unwrap-panic (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-bitcoin-bears transfer u142 tx-sender TRADER-7)))
	(unwrap-panic (as-contract (contract-call? 'SP3EB7YHV5NERS2HMCGSGKNMN0BEH52W9H7YE4T9C.mendaxx-ai-world transfer u1 tx-sender TRADER-7)))
	(unwrap-panic (as-contract (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.genesis-64 transfer u19 tx-sender TRADER-8)))
	(unwrap-panic (as-contract (contract-call? 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.btc-sports-og-soccer transfer u29 tx-sender TRADER-10)))
	(unwrap-panic (as-contract (contract-call? 'SP22GHCK5W3EK5VC1PEB3VVCBVFRQNTQXV9306QA0.metacine transfer u304 tx-sender TRADER-10)))
	(unwrap-panic (as-contract (contract-call? 'SP3273YEPG4QZWX0ENQ98FBT1N2Y06XW820STP7NN.straight-outta-lightroom transfer u5 tx-sender TRADER-11)))
	(unwrap-panic (as-contract (contract-call? 'SP6P4EJF0VG8V0RB3TQQKJBHDQKEF6NVRD1KZE3C.monster-satoshibles transfer u4580 tx-sender TRADER-13)))
	(unwrap-panic (as-contract (contract-call? 'SP2P6KSAJ4JVV8PFSNKJ9BNG5PEPR4RT71VXZHWBK.tiger-force transfer u1024 tx-sender TRADER-13)))
	(unwrap-panic (as-contract (contract-call? 'SP6P4EJF0VG8V0RB3TQQKJBHDQKEF6NVRD1KZE3C.monster-satoshibles transfer u4574 tx-sender TRADER-13)))
	(unwrap-panic (as-contract (contract-call? 'SP6P4EJF0VG8V0RB3TQQKJBHDQKEF6NVRD1KZE3C.monster-satoshibles transfer u4567 tx-sender TRADER-13)))
	(unwrap-panic (as-contract (contract-call? 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.blocksurvey transfer u104 tx-sender TRADER-15)))
	(unwrap-panic (as-contract (contract-call? 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.nfts-for-peace transfer u199 tx-sender TRADER-15)))
	(unwrap-panic (as-contract (contract-call? 'SP6P4EJF0VG8V0RB3TQQKJBHDQKEF6NVRD1KZE3C.satoshibles transfer u4351 tx-sender TRADER-16)))
	(unwrap-panic (as-contract (contract-call? 'SP364J7EDJXRE1FPDZDABP9M58HPY4G88BFCP2HD0.the-girl-from-stacks transfer u53 tx-sender TRADER-16)))
	(unwrap-panic (as-contract (contract-call? 'SP364J7EDJXRE1FPDZDABP9M58HPY4G88BFCP2HD0.the-girl-from-stacks transfer u2 tx-sender TRADER-16)))
	(unwrap-panic (as-contract (contract-call? 'SP6P4EJF0VG8V0RB3TQQKJBHDQKEF6NVRD1KZE3C.monster-satoshibles transfer u4240 tx-sender TRADER-17)))
	(unwrap-panic (as-contract (contract-call? 'SP3252T1HMQHZTA9S22WZ2HZMKC4CVH965SHSERTH.the-guests-woymuls transfer u50 tx-sender TRADER-17)))
	(unwrap-panic (as-contract (contract-call? 'SP248HH800501WYSG7Z2SS1ZWHQW1GGH85ME34NT2.layer-v2-1 transfer u19661 tx-sender TRADER-18)))
	(unwrap-panic (as-contract (contract-call? 'SPWGSV28BN5QMQ618CZAPDD18XPSN6EK776CDS84.magic-sound transfer u78 tx-sender TRADER-19)))
	(unwrap-panic (as-contract (contract-call? 'SPJJYJVZ4H7B34GG8D3SSN70WVWDYSHCC9E9ZV4V.bitcoin-toadz transfer u2582 tx-sender TRADER-19)))
	(unwrap-panic (as-contract (contract-call? 'SP2HV9HYWZRAPTCC10VXCK72P3W4F9NDB8E1HBEZH.verified-pepe-checks-edition transfer u95 tx-sender TRADER-21)))
	(unwrap-panic (as-contract (contract-call? 'SP3WFDD787ES26F96H67T7CNC6D8QZ9X6KM5YBVJK.punk-skull transfer u10 tx-sender TRADER-22)))
	(unwrap-panic (as-contract (contract-call? 'SPM1Q7YG18378H6W254YN8PABEVRPT38ZCY01SJD.stxphotography-one-life transfer u20 tx-sender TRADER-23)))
	(unwrap-panic (as-contract (contract-call? 'SP2R2AN769WEF2BRB8N4M42K4YFZ297FNTK1HCDY4.art-according-to-ai transfer u5 tx-sender TRADER-23)))
	(unwrap-panic (as-contract (contract-call? 'SPM1Q7YG18378H6W254YN8PABEVRPT38ZCY01SJD.stxphotography-one-life transfer u18 tx-sender TRADER-23)))
	(unwrap-panic (as-contract (contract-call? 'SPDKRP4ESV0037MT3SX0WE817WVR9EQ9A0JBVRP4.atlantic-dolphins transfer u20 tx-sender TRADER-23)))
	(unwrap-panic (as-contract (contract-call? 'SP3273YEPG4QZWX0ENQ98FBT1N2Y06XW820STP7NN.straight-outta-lightroom transfer u8 tx-sender TRADER-23)))

	(unwrap-panic (as-contract (stx-transfer? u233000000 tx-sender TRADER-1)))
	(unwrap-panic (as-contract (stx-transfer? u96500000 tx-sender TRADER-2)))
	(unwrap-panic (as-contract (stx-transfer? u120000000 tx-sender TRADER-5)))
	(unwrap-panic (as-contract (stx-transfer? u44000000 tx-sender TRADER-6)))
	(unwrap-panic (as-contract (stx-transfer? u780000000 tx-sender TRADER-9)))
	(unwrap-panic (as-contract (stx-transfer? u33000000 tx-sender TRADER-12)))
	(unwrap-panic (as-contract (stx-transfer? u1300000 tx-sender TRADER-14)))
	(unwrap-panic (as-contract (stx-transfer? u112500000 tx-sender TRADER-20)))

        (var-set swapState SWAP_STATE_FINALIZED)
        (ok true)
    )
)

(define-private (return-escrow) 
    (begin 
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-1)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (contract-call? 'SP364J7EDJXRE1FPDZDABP9M58HPY4G88BFCP2HD0.the-girl-from-stacks transfer u53 tx-sender TRADER-1)))
		(unwrap-panic (as-contract (contract-call? 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.blocksurvey transfer u104 tx-sender TRADER-1)))
		(unwrap-panic (as-contract (contract-call? 'SP22GHCK5W3EK5VC1PEB3VVCBVFRQNTQXV9306QA0.metacine transfer u304 tx-sender TRADER-1)))
		(unwrap-panic (as-contract (contract-call? 'SP364J7EDJXRE1FPDZDABP9M58HPY4G88BFCP2HD0.the-girl-from-stacks transfer u2 tx-sender TRADER-1)))
		(unwrap-panic (as-contract (contract-call? 'SP2HV9HYWZRAPTCC10VXCK72P3W4F9NDB8E1HBEZH.verified-pepe-checks-edition transfer u95 tx-sender TRADER-1)))
		(unwrap-panic (as-contract (contract-call? 'SP3252T1HMQHZTA9S22WZ2HZMKC4CVH965SHSERTH.the-guests-woymuls transfer u50 tx-sender TRADER-1)))
	    )
            true
        )
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-2)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (contract-call? 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.btc-sports-og-soccer transfer u29 tx-sender TRADER-2)))
		(unwrap-panic (as-contract (contract-call? 'SP2P6KSAJ4JVV8PFSNKJ9BNG5PEPR4RT71VXZHWBK.tiger-force transfer u1024 tx-sender TRADER-2)))
		(unwrap-panic (as-contract (contract-call? 'SP2N3BAG4GBF8NHRPH6AY4YYH1SP6NK5TGCY7RDFA.stacks-mfers transfer u1081 tx-sender TRADER-2)))
		(unwrap-panic (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.hback-whales-nft transfer u1477 tx-sender TRADER-2)))
	    )
            true
        )
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-3)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (stx-transfer? u1100000 tx-sender TRADER-3)))
	    )
            true
        )
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-4)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (stx-transfer? u13000000 tx-sender TRADER-4)))
	    )
            true
        )
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-5)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-bitcoin-bears transfer u142 tx-sender TRADER-5)))
	    )
            true
        )
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-6)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (contract-call? 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.nfts-for-peace transfer u199 tx-sender TRADER-6)))
	    )
            true
        )
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-7)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (stx-transfer? u139500000 tx-sender TRADER-7)))
	    )
            true
        )
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-8)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (stx-transfer? u60000000 tx-sender TRADER-8)))
	    )
            true
        )
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-9)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (contract-call? 'SP6P4EJF0VG8V0RB3TQQKJBHDQKEF6NVRD1KZE3C.satoshibles transfer u4351 tx-sender TRADER-9)))
		(unwrap-panic (as-contract (contract-call? 'SP6P4EJF0VG8V0RB3TQQKJBHDQKEF6NVRD1KZE3C.monster-satoshibles transfer u4580 tx-sender TRADER-9)))
		(unwrap-panic (as-contract (contract-call? 'SP6P4EJF0VG8V0RB3TQQKJBHDQKEF6NVRD1KZE3C.monster-satoshibles transfer u4567 tx-sender TRADER-9)))
		(unwrap-panic (as-contract (contract-call? 'SP6P4EJF0VG8V0RB3TQQKJBHDQKEF6NVRD1KZE3C.monster-satoshibles transfer u4240 tx-sender TRADER-9)))
		(unwrap-panic (as-contract (contract-call? 'SP6P4EJF0VG8V0RB3TQQKJBHDQKEF6NVRD1KZE3C.monster-satoshibles transfer u4574 tx-sender TRADER-9)))
	    )
            true
        )
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-10)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (stx-transfer? u80000000 tx-sender TRADER-10)))
	    )
            true
        )
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-11)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (stx-transfer? u5100000 tx-sender TRADER-11)))
	    )
            true
        )
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-12)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (contract-call? 'SPWGSV28BN5QMQ618CZAPDD18XPSN6EK776CDS84.magic-sound transfer u78 tx-sender TRADER-12)))
		(unwrap-panic (as-contract (contract-call? 'SPJJYJVZ4H7B34GG8D3SSN70WVWDYSHCC9E9ZV4V.bitcoin-toadz transfer u2582 tx-sender TRADER-12)))
		(unwrap-panic (as-contract (contract-call? 'SPDKRP4ESV0037MT3SX0WE817WVR9EQ9A0JBVRP4.atlantic-dolphins transfer u20 tx-sender TRADER-12)))
	    )
            true
        )
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-13)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (stx-transfer? u258900000 tx-sender TRADER-13)))
		(unwrap-panic (as-contract (contract-call? 'SPM1Q7YG18378H6W254YN8PABEVRPT38ZCY01SJD.stxphotography-one-life transfer u18 tx-sender TRADER-13)))
		(unwrap-panic (as-contract (contract-call? 'SP1XJ6GNTDVF6HR1VHPQDMFZJY87D9W6TGMH3QCP.passion-of-christ transfer u5 tx-sender TRADER-13)))
		(unwrap-panic (as-contract (contract-call? 'SP3273YEPG4QZWX0ENQ98FBT1N2Y06XW820STP7NN.straight-outta-lightroom transfer u5 tx-sender TRADER-13)))
		(unwrap-panic (as-contract (contract-call? 'SP3273YEPG4QZWX0ENQ98FBT1N2Y06XW820STP7NN.straight-outta-lightroom transfer u8 tx-sender TRADER-13)))
		(unwrap-panic (as-contract (contract-call? 'SP3EB7YHV5NERS2HMCGSGKNMN0BEH52W9H7YE4T9C.mendaxx-ai-world transfer u1 tx-sender TRADER-13)))
		(unwrap-panic (as-contract (contract-call? 'SPM1Q7YG18378H6W254YN8PABEVRPT38ZCY01SJD.stxphotography-one-life transfer u20 tx-sender TRADER-13)))
		(unwrap-panic (as-contract (contract-call? 'SP2R2AN769WEF2BRB8N4M42K4YFZ297FNTK1HCDY4.art-according-to-ai transfer u5 tx-sender TRADER-13)))
	    )
            true
        )
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-14)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (contract-call? 'SP3WFDD787ES26F96H67T7CNC6D8QZ9X6KM5YBVJK.punk-skull transfer u10 tx-sender TRADER-14)))
		(unwrap-panic (as-contract (contract-call? 'SP3WNCSE4PYGS5Y8VSYM9P68RFVS5Z30G3QF7T8ZB.zumbies-and-gublins transfer u74 tx-sender TRADER-14)))
	    )
            true
        )
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-15)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (stx-transfer? u119000000 tx-sender TRADER-15)))
	    )
            true
        )
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-16)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (stx-transfer? u432000000 tx-sender TRADER-16)))
	    )
            true
        )
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-17)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (stx-transfer? u175000000 tx-sender TRADER-17)))
	    )
            true
        )
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-18)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (stx-transfer? u52500000 tx-sender TRADER-18)))
	    )
            true
        )
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-19)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (stx-transfer? u8000000 tx-sender TRADER-19)))
	    )
            true
        )
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-20)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (contract-call? 'SP248HH800501WYSG7Z2SS1ZWHQW1GGH85ME34NT2.layer-v2-1 transfer u19661 tx-sender TRADER-20)))
		(unwrap-panic (as-contract (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.genesis-64 transfer u19 tx-sender TRADER-20)))
	    )
            true
        )
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-21)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (stx-transfer? u26000000 tx-sender TRADER-21)))
	    )
            true
        )
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-22)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (stx-transfer? u200000 tx-sender TRADER-22)))
	    )
            true
        )
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-23)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (stx-transfer? u50000000 tx-sender TRADER-23)))
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

        (asserts! (not (is-eq (var-get swapState) SWAP_STATE_FINALIZED)) (err ERR_SWAP_FINALIZED))
        (asserts! (not (is-eq (var-get swapState) SWAP_STATE_CANCELED)) (err ERR_SWAP_CANCELED))
        (asserts! (not (is-eq trState TRADER_STATE_CONFIRMED)) (err ERR_CALLER_ALREADY_ESCROWED))
        (try! (deposit-escrow))
        (ok true)
    )
)

(define-public (cancel) 
    (begin
        (unwrap! (map-get? TraderState tx-sender) (err ERR_IS_NOT_TRADER))
        (asserts! (not (is-eq (var-get swapState) SWAP_STATE_FINALIZED)) (err ERR_SWAP_FINALIZED))
        (asserts! (not (is-eq (var-get swapState) SWAP_STATE_CANCELED)) (err ERR_SWAP_CANCELED))
        (unwrap! (return-escrow) (err ERR_RELEASING_ESCROW_FAILED))
        (ok true)
    )
)

(define-public (finalize) 
    (begin
        (asserts! (not (is-eq (var-get swapState) SWAP_STATE_ACTIVE)) (err ERR_ESCROW_NOT_FILLED))
        (asserts! (not (is-eq (var-get swapState) SWAP_STATE_FINALIZED)) (err ERR_SWAP_FINALIZED))
        (asserts! (not (is-eq (var-get swapState) SWAP_STATE_CANCELED)) (err ERR_SWAP_CANCELED))
        (unwrap! (release-escrow) (err ERR_RELEASING_ESCROW_FAILED))
        (ok true)
    )
)
