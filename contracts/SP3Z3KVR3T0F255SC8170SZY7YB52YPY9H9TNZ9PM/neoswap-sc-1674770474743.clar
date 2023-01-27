
;; multiway-swap
;; Contract to facilitate a multiway NFT swap.
;; Each of the parties involved has to call confirm-and-escrow to escrow their dues.
;; Once all parties confirmed, finalize has to be called to redistribute escrowed items.
;; At any point before the swap is finalized it can be canceled by a party involved, 
;; regardles of whether they already called confirm-and-escrow or not.

;; traders
(define-constant TRADER-1 'SP12VXAS7H2MT7R8116F4RA1FCS21DZ86B4DTN80J)
(define-constant TRADER-2 'SP1JQCYDVHKE8RWBJ9JSX8ZH6TVTX0TH2F7D3A8YJ)
(define-constant TRADER-3 'SP1KBVBP3AZP7YA968Y3G14A17P9XXFPBPEVF5EG9)
(define-constant TRADER-4 'SP1Q6N226KFMA496MVWSB0VZC0T0R9FSKTYYYZ403)
(define-constant TRADER-5 'SP1T07GK9H4M0WP4N1DSSA7NJ7GNTQZ0GBZM0GAR2)
(define-constant TRADER-6 'SP1XJ6GNTDVF6HR1VHPQDMFZJY87D9W6TGMH3QCP)
(define-constant TRADER-7 'SP1XY24C7AJ8XZ2QQ5BMD43YWJBYAM388G00P354V)
(define-constant TRADER-8 'SP27E3TDKYNH3C11RBDFPD5WGR6FV0VN08RKX4D2N)
(define-constant TRADER-9 'SP2HV9HYWZRAPTCC10VXCK72P3W4F9NDB8E1HBEZH)
(define-constant TRADER-10 'SP329G766AV8Z01X9EEAHPDQ4WDJXT2A0XB383MGP)
(define-constant TRADER-11 'SP32CF0E78JNPK0HYDTH3CCZ8FN76PFX5W0FYBN20)
(define-constant TRADER-12 'SP3C5JYPB8YE5H9WC2SM196RVJ0JXN2GHCWXJWSES)
(define-constant TRADER-13 'SP3QBRHQF4BN8HNNGFHCJMQZDB8V20BMGF2VS3MJ2)
(define-constant TRADER-14 'SP3R4NKXMGW6YXA44X2ESZPKJNV25X4ZN7DPW0RXR)
(define-constant TRADER-15 'SP779SC9CDWQVMTRXT0HZCEHSDBXCHNGG7BC1H9B)
(define-constant TRADER-16 'SPH9YG28V53YATFKTJHMDG19RRJT74YFNS2MYTGF)
(define-constant TRADER-17 'SPHK8A7P61C6ASWKYDX1PCDX9YA54DKVJN49EXGJ)
(define-constant TRADER-18 'SPJSCH3DDEJ8GQPGYZBHSB4F3HX5Q222CG89PSAB)
(define-constant TRADER-19 'SPM1Q7YG18378H6W254YN8PABEVRPT38ZCY01SJD)

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

(define-constant NUM_TRADERS u19)

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

;; private functions
(define-private (deposit-escrow) 
    (begin
	(if (is-eq tx-sender TRADER-1)
            (begin
		(unwrap! (contract-call? 'SPXG42Y7WDTMZF5MPV02C3AWY1VNP9FH9C23PRXH.Marbling transfer u1064 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
	    )
            true
        )
	(if (is-eq tx-sender TRADER-2)
            (begin
		(unwrap! (stx-transfer? u308120125 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_STX))
	    )
            true
        )
	(if (is-eq tx-sender TRADER-3)
            (begin
		(unwrap! (contract-call? 'SP2BE8TZATXEVPGZ8HAFZYE5GKZ02X0YDKAN7ZTGW.btc-sports-flags-nft transfer u1160 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.megapont-space-agency transfer u6152 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
	    )
            true
        )
	(if (is-eq tx-sender TRADER-4)
            (begin
		(unwrap! (contract-call? 'SP22GHCK5W3EK5VC1PEB3VVCBVFRQNTQXV9306QA0.bear-market-buddies transfer u647 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
	    )
            true
        )
	(if (is-eq tx-sender TRADER-5)
            (begin
		(unwrap! (stx-transfer? u150000000 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_STX))
	    )
            true
        )
	(if (is-eq tx-sender TRADER-6)
            (begin
		(unwrap! (stx-transfer? u7441000 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_STX))
	    )
            true
        )
	(if (is-eq tx-sender TRADER-7)
            (begin
		(unwrap! (contract-call? 'SP1XY24C7AJ8XZ2QQ5BMD43YWJBYAM388G00P354V.glitched transfer u2 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP1XY24C7AJ8XZ2QQ5BMD43YWJBYAM388G00P354V.glitched transfer u5 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
	    )
            true
        )
	(if (is-eq tx-sender TRADER-8)
            (begin
		(unwrap! (stx-transfer? u244481513 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_STX))
		(unwrap! (contract-call? 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.megapont-robot-component-nft transfer u49100 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
	    )
            true
        )
	(if (is-eq tx-sender TRADER-9)
            (begin
		(unwrap! (contract-call? 'SP22GHCK5W3EK5VC1PEB3VVCBVFRQNTQXV9306QA0.bear-market-buddies transfer u432 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP22GHCK5W3EK5VC1PEB3VVCBVFRQNTQXV9306QA0.bear-market-buddies transfer u422 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP22GHCK5W3EK5VC1PEB3VVCBVFRQNTQXV9306QA0.metacine transfer u270 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP22GHCK5W3EK5VC1PEB3VVCBVFRQNTQXV9306QA0.bear-market-buddies transfer u361 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP22GHCK5W3EK5VC1PEB3VVCBVFRQNTQXV9306QA0.bear-market-buddies transfer u433 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP22GHCK5W3EK5VC1PEB3VVCBVFRQNTQXV9306QA0.bear-market-buddies transfer u115 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
	    )
            true
        )
	(if (is-eq tx-sender TRADER-10)
            (begin
		(unwrap! (contract-call? 'SP2ABNX65BSKVM00ZQZ7K174DFV18CXVGGEMP7Y6X.weed-monsters transfer u114 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3.cx-tokens transfer u23 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP1D3Y8A2VVD2W98VFXCG5AXRYX5PJBBEMV1YPKF1.nonnish-grafters transfer u1316 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP2F2KH0RVX6GF1Y9FWMMSR9RHG0TW3NN72D724NX.the-purple-pill transfer u169 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3.game-on transfer u315 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3.the-smiley-collection transfer u107 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SPJSCH3DDEJ8GQPGYZBHSB4F3HX5Q222CG89PSAB.guest-wins transfer u1 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
	    )
            true
        )
	(if (is-eq tx-sender TRADER-11)
            (begin
		(unwrap! (stx-transfer? u140246138 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_STX))
	    )
            true
        )
	(if (is-eq tx-sender TRADER-12)
            (begin
		(unwrap! (stx-transfer? u52134063 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_STX))
	    )
            true
        )
	(if (is-eq tx-sender TRADER-13)
            (begin
		(unwrap! (stx-transfer? u48687500 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_STX))
	    )
            true
        )
	(if (is-eq tx-sender TRADER-14)
            (begin
		(unwrap! (contract-call? 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.megapont-space-agency transfer u3335 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP2QDMH88MEZ8FFAYHW4B0BTXJRTHX8XBD54FE7HJ.btc-pizza-day-porto-alegre transfer u106 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
	    )
            true
        )
	(if (is-eq tx-sender TRADER-15)
            (begin
		(unwrap! (contract-call? 'SP22GHCK5W3EK5VC1PEB3VVCBVFRQNTQXV9306QA0.metacine transfer u168 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP22GHCK5W3EK5VC1PEB3VVCBVFRQNTQXV9306QA0.bear-market-buddies transfer u187 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
	    )
            true
        )
	(if (is-eq tx-sender TRADER-16)
            (begin
		(unwrap! (contract-call? 'SPH9YG28V53YATFKTJHMDG19RRJT74YFNS2MYTGF.jackob-nft transfer u43 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SPH9YG28V53YATFKTJHMDG19RRJT74YFNS2MYTGF.jackob-nft transfer u53 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SPH9YG28V53YATFKTJHMDG19RRJT74YFNS2MYTGF.jackob-nft transfer u42 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SPH9YG28V53YATFKTJHMDG19RRJT74YFNS2MYTGF.jackob-nft transfer u54 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
	    )
            true
        )
	(if (is-eq tx-sender TRADER-17)
            (begin
		(unwrap! (stx-transfer? u136591125 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_STX))
	    )
            true
        )
	(if (is-eq tx-sender TRADER-18)
            (begin
		(unwrap! (contract-call? 'SP22GHCK5W3EK5VC1PEB3VVCBVFRQNTQXV9306QA0.metacine transfer u97 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP22GHCK5W3EK5VC1PEB3VVCBVFRQNTQXV9306QA0.metacine transfer u88 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP22GHCK5W3EK5VC1PEB3VVCBVFRQNTQXV9306QA0.metacine transfer u74 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
	    )
            true
        )
	(if (is-eq tx-sender TRADER-19)
            (begin
		(unwrap! (contract-call? 'SP22GHCK5W3EK5VC1PEB3VVCBVFRQNTQXV9306QA0.metacine transfer u314 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP22GHCK5W3EK5VC1PEB3VVCBVFRQNTQXV9306QA0.bear-market-buddies transfer u271 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP22GHCK5W3EK5VC1PEB3VVCBVFRQNTQXV9306QA0.bear-market-buddies transfer u558 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP22GHCK5W3EK5VC1PEB3VVCBVFRQNTQXV9306QA0.bear-market-buddies transfer u285 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP22GHCK5W3EK5VC1PEB3VVCBVFRQNTQXV9306QA0.metacine transfer u370 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP22GHCK5W3EK5VC1PEB3VVCBVFRQNTQXV9306QA0.metacine transfer u106 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP22GHCK5W3EK5VC1PEB3VVCBVFRQNTQXV9306QA0.bear-market-buddies transfer u731 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
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
	(unwrap-panic (as-contract (contract-call? 'SP22GHCK5W3EK5VC1PEB3VVCBVFRQNTQXV9306QA0.metacine transfer u97 tx-sender TRADER-2)))
	(unwrap-panic (as-contract (contract-call? 'SP22GHCK5W3EK5VC1PEB3VVCBVFRQNTQXV9306QA0.bear-market-buddies transfer u558 tx-sender TRADER-2)))
	(unwrap-panic (as-contract (contract-call? 'SP22GHCK5W3EK5VC1PEB3VVCBVFRQNTQXV9306QA0.bear-market-buddies transfer u731 tx-sender TRADER-2)))
	(unwrap-panic (as-contract (contract-call? 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3.game-on transfer u315 tx-sender TRADER-2)))
	(unwrap-panic (as-contract (contract-call? 'SP22GHCK5W3EK5VC1PEB3VVCBVFRQNTQXV9306QA0.bear-market-buddies transfer u285 tx-sender TRADER-2)))
	(unwrap-panic (as-contract (contract-call? 'SP22GHCK5W3EK5VC1PEB3VVCBVFRQNTQXV9306QA0.bear-market-buddies transfer u432 tx-sender TRADER-2)))
	(unwrap-panic (as-contract (contract-call? 'SP22GHCK5W3EK5VC1PEB3VVCBVFRQNTQXV9306QA0.bear-market-buddies transfer u361 tx-sender TRADER-2)))
	(unwrap-panic (as-contract (contract-call? 'SP22GHCK5W3EK5VC1PEB3VVCBVFRQNTQXV9306QA0.metacine transfer u106 tx-sender TRADER-2)))
	(unwrap-panic (as-contract (contract-call? 'SPJSCH3DDEJ8GQPGYZBHSB4F3HX5Q222CG89PSAB.guest-wins transfer u1 tx-sender TRADER-3)))
	(unwrap-panic (as-contract (contract-call? 'SPH9YG28V53YATFKTJHMDG19RRJT74YFNS2MYTGF.jackob-nft transfer u43 tx-sender TRADER-4)))
	(unwrap-panic (as-contract (contract-call? 'SPH9YG28V53YATFKTJHMDG19RRJT74YFNS2MYTGF.jackob-nft transfer u53 tx-sender TRADER-4)))
	(unwrap-panic (as-contract (contract-call? 'SPH9YG28V53YATFKTJHMDG19RRJT74YFNS2MYTGF.jackob-nft transfer u42 tx-sender TRADER-4)))
	(unwrap-panic (as-contract (contract-call? 'SPH9YG28V53YATFKTJHMDG19RRJT74YFNS2MYTGF.jackob-nft transfer u54 tx-sender TRADER-4)))
	(unwrap-panic (as-contract (contract-call? 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.megapont-space-agency transfer u3335 tx-sender TRADER-5)))
	(unwrap-panic (as-contract (contract-call? 'SPXG42Y7WDTMZF5MPV02C3AWY1VNP9FH9C23PRXH.Marbling transfer u1064 tx-sender TRADER-6)))
	(unwrap-panic (as-contract (contract-call? 'SP22GHCK5W3EK5VC1PEB3VVCBVFRQNTQXV9306QA0.bear-market-buddies transfer u647 tx-sender TRADER-8)))
	(unwrap-panic (as-contract (contract-call? 'SP1XY24C7AJ8XZ2QQ5BMD43YWJBYAM388G00P354V.glitched transfer u2 tx-sender TRADER-8)))
	(unwrap-panic (as-contract (contract-call? 'SP22GHCK5W3EK5VC1PEB3VVCBVFRQNTQXV9306QA0.bear-market-buddies transfer u115 tx-sender TRADER-8)))
	(unwrap-panic (as-contract (contract-call? 'SP1XY24C7AJ8XZ2QQ5BMD43YWJBYAM388G00P354V.glitched transfer u5 tx-sender TRADER-8)))
	(unwrap-panic (as-contract (contract-call? 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.megapont-space-agency transfer u6152 tx-sender TRADER-8)))
	(unwrap-panic (as-contract (contract-call? 'SP22GHCK5W3EK5VC1PEB3VVCBVFRQNTQXV9306QA0.bear-market-buddies transfer u187 tx-sender TRADER-8)))
	(unwrap-panic (as-contract (contract-call? 'SP22GHCK5W3EK5VC1PEB3VVCBVFRQNTQXV9306QA0.metacine transfer u370 tx-sender TRADER-11)))
	(unwrap-panic (as-contract (contract-call? 'SP22GHCK5W3EK5VC1PEB3VVCBVFRQNTQXV9306QA0.bear-market-buddies transfer u422 tx-sender TRADER-11)))
	(unwrap-panic (as-contract (contract-call? 'SP1D3Y8A2VVD2W98VFXCG5AXRYX5PJBBEMV1YPKF1.nonnish-grafters transfer u1316 tx-sender TRADER-11)))
	(unwrap-panic (as-contract (contract-call? 'SP22GHCK5W3EK5VC1PEB3VVCBVFRQNTQXV9306QA0.bear-market-buddies transfer u433 tx-sender TRADER-11)))
	(unwrap-panic (as-contract (contract-call? 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3.cx-tokens transfer u23 tx-sender TRADER-11)))
	(unwrap-panic (as-contract (contract-call? 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.megapont-robot-component-nft transfer u49100 tx-sender TRADER-11)))
	(unwrap-panic (as-contract (contract-call? 'SP22GHCK5W3EK5VC1PEB3VVCBVFRQNTQXV9306QA0.bear-market-buddies transfer u271 tx-sender TRADER-12)))
	(unwrap-panic (as-contract (contract-call? 'SP22GHCK5W3EK5VC1PEB3VVCBVFRQNTQXV9306QA0.metacine transfer u270 tx-sender TRADER-13)))
	(unwrap-panic (as-contract (contract-call? 'SP2F2KH0RVX6GF1Y9FWMMSR9RHG0TW3NN72D724NX.the-purple-pill transfer u169 tx-sender TRADER-14)))
	(unwrap-panic (as-contract (contract-call? 'SP2QDMH88MEZ8FFAYHW4B0BTXJRTHX8XBD54FE7HJ.btc-pizza-day-porto-alegre transfer u106 tx-sender TRADER-15)))
	(unwrap-panic (as-contract (contract-call? 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3.the-smiley-collection transfer u107 tx-sender TRADER-17)))
	(unwrap-panic (as-contract (contract-call? 'SP22GHCK5W3EK5VC1PEB3VVCBVFRQNTQXV9306QA0.metacine transfer u314 tx-sender TRADER-17)))
	(unwrap-panic (as-contract (contract-call? 'SP22GHCK5W3EK5VC1PEB3VVCBVFRQNTQXV9306QA0.metacine transfer u74 tx-sender TRADER-17)))
	(unwrap-panic (as-contract (contract-call? 'SP2BE8TZATXEVPGZ8HAFZYE5GKZ02X0YDKAN7ZTGW.btc-sports-flags-nft transfer u1160 tx-sender TRADER-17)))
	(unwrap-panic (as-contract (contract-call? 'SP2ABNX65BSKVM00ZQZ7K174DFV18CXVGGEMP7Y6X.weed-monsters transfer u114 tx-sender TRADER-17)))
	(unwrap-panic (as-contract (contract-call? 'SP22GHCK5W3EK5VC1PEB3VVCBVFRQNTQXV9306QA0.metacine transfer u168 tx-sender TRADER-17)))
	(unwrap-panic (as-contract (contract-call? 'SP22GHCK5W3EK5VC1PEB3VVCBVFRQNTQXV9306QA0.metacine transfer u88 tx-sender TRADER-19)))

	(unwrap-panic (as-contract (stx-transfer? u7441000 tx-sender TRADER-1)))
	(unwrap-panic (as-contract (stx-transfer? u27372500 tx-sender TRADER-3)))
	(unwrap-panic (as-contract (stx-transfer? u44586902 tx-sender RECEIVER-1)))
	(unwrap-panic (as-contract (stx-transfer? u1900000 tx-sender TRADER-4)))
	(unwrap-panic (as-contract (stx-transfer? u20000000 tx-sender TRADER-7)))
	(unwrap-panic (as-contract (stx-transfer? u263752125 tx-sender TRADER-9)))
	(unwrap-panic (as-contract (stx-transfer? u71838000 tx-sender TRADER-10)))
	(unwrap-panic (as-contract (stx-transfer? u147925000 tx-sender TRADER-14)))
	(unwrap-panic (as-contract (stx-transfer? u113562500 tx-sender TRADER-15)))
	(unwrap-panic (as-contract (stx-transfer? u80000000 tx-sender TRADER-16)))
	(unwrap-panic (as-contract (stx-transfer? u75372375 tx-sender TRADER-18)))
	(unwrap-panic (as-contract (stx-transfer? u233951062 tx-sender TRADER-19)))

        (var-set swapState SWAP_STATE_FINALIZED)
        (ok true)
    )
)

(define-private (return-escrow) 
    (begin 
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-1)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (contract-call? 'SPXG42Y7WDTMZF5MPV02C3AWY1VNP9FH9C23PRXH.Marbling transfer u1064 tx-sender TRADER-1)))
	    )
            true
        )
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-1)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (stx-transfer? u308120125 tx-sender TRADER-2)))
	    )
            true
        )
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-1)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (contract-call? 'SP2BE8TZATXEVPGZ8HAFZYE5GKZ02X0YDKAN7ZTGW.btc-sports-flags-nft transfer u1160 tx-sender TRADER-3)))
		(unwrap-panic (as-contract (contract-call? 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.megapont-space-agency transfer u6152 tx-sender TRADER-3)))
	    )
            true
        )
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-1)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (contract-call? 'SP22GHCK5W3EK5VC1PEB3VVCBVFRQNTQXV9306QA0.bear-market-buddies transfer u647 tx-sender TRADER-4)))
	    )
            true
        )
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-1)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (stx-transfer? u150000000 tx-sender TRADER-5)))
	    )
            true
        )
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-1)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (stx-transfer? u7441000 tx-sender TRADER-6)))
	    )
            true
        )
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-1)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (contract-call? 'SP1XY24C7AJ8XZ2QQ5BMD43YWJBYAM388G00P354V.glitched transfer u2 tx-sender TRADER-7)))
		(unwrap-panic (as-contract (contract-call? 'SP1XY24C7AJ8XZ2QQ5BMD43YWJBYAM388G00P354V.glitched transfer u5 tx-sender TRADER-7)))
	    )
            true
        )
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-1)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (stx-transfer? u244481513 tx-sender TRADER-8)))
		(unwrap-panic (as-contract (contract-call? 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.megapont-robot-component-nft transfer u49100 tx-sender TRADER-8)))
	    )
            true
        )
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-1)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (contract-call? 'SP22GHCK5W3EK5VC1PEB3VVCBVFRQNTQXV9306QA0.bear-market-buddies transfer u432 tx-sender TRADER-9)))
		(unwrap-panic (as-contract (contract-call? 'SP22GHCK5W3EK5VC1PEB3VVCBVFRQNTQXV9306QA0.bear-market-buddies transfer u422 tx-sender TRADER-9)))
		(unwrap-panic (as-contract (contract-call? 'SP22GHCK5W3EK5VC1PEB3VVCBVFRQNTQXV9306QA0.metacine transfer u270 tx-sender TRADER-9)))
		(unwrap-panic (as-contract (contract-call? 'SP22GHCK5W3EK5VC1PEB3VVCBVFRQNTQXV9306QA0.bear-market-buddies transfer u361 tx-sender TRADER-9)))
		(unwrap-panic (as-contract (contract-call? 'SP22GHCK5W3EK5VC1PEB3VVCBVFRQNTQXV9306QA0.bear-market-buddies transfer u433 tx-sender TRADER-9)))
		(unwrap-panic (as-contract (contract-call? 'SP22GHCK5W3EK5VC1PEB3VVCBVFRQNTQXV9306QA0.bear-market-buddies transfer u115 tx-sender TRADER-9)))
	    )
            true
        )
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-1)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (contract-call? 'SP2ABNX65BSKVM00ZQZ7K174DFV18CXVGGEMP7Y6X.weed-monsters transfer u114 tx-sender TRADER-10)))
		(unwrap-panic (as-contract (contract-call? 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3.cx-tokens transfer u23 tx-sender TRADER-10)))
		(unwrap-panic (as-contract (contract-call? 'SP1D3Y8A2VVD2W98VFXCG5AXRYX5PJBBEMV1YPKF1.nonnish-grafters transfer u1316 tx-sender TRADER-10)))
		(unwrap-panic (as-contract (contract-call? 'SP2F2KH0RVX6GF1Y9FWMMSR9RHG0TW3NN72D724NX.the-purple-pill transfer u169 tx-sender TRADER-10)))
		(unwrap-panic (as-contract (contract-call? 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3.game-on transfer u315 tx-sender TRADER-10)))
		(unwrap-panic (as-contract (contract-call? 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3.the-smiley-collection transfer u107 tx-sender TRADER-10)))
		(unwrap-panic (as-contract (contract-call? 'SPJSCH3DDEJ8GQPGYZBHSB4F3HX5Q222CG89PSAB.guest-wins transfer u1 tx-sender TRADER-10)))
	    )
            true
        )
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-1)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (stx-transfer? u140246138 tx-sender TRADER-11)))
	    )
            true
        )
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-1)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (stx-transfer? u52134063 tx-sender TRADER-12)))
	    )
            true
        )
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-1)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (stx-transfer? u48687500 tx-sender TRADER-13)))
	    )
            true
        )
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-1)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (contract-call? 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.megapont-space-agency transfer u3335 tx-sender TRADER-14)))
		(unwrap-panic (as-contract (contract-call? 'SP2QDMH88MEZ8FFAYHW4B0BTXJRTHX8XBD54FE7HJ.btc-pizza-day-porto-alegre transfer u106 tx-sender TRADER-14)))
	    )
            true
        )
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-1)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (contract-call? 'SP22GHCK5W3EK5VC1PEB3VVCBVFRQNTQXV9306QA0.metacine transfer u168 tx-sender TRADER-15)))
		(unwrap-panic (as-contract (contract-call? 'SP22GHCK5W3EK5VC1PEB3VVCBVFRQNTQXV9306QA0.bear-market-buddies transfer u187 tx-sender TRADER-15)))
	    )
            true
        )
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-1)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (contract-call? 'SPH9YG28V53YATFKTJHMDG19RRJT74YFNS2MYTGF.jackob-nft transfer u43 tx-sender TRADER-16)))
		(unwrap-panic (as-contract (contract-call? 'SPH9YG28V53YATFKTJHMDG19RRJT74YFNS2MYTGF.jackob-nft transfer u53 tx-sender TRADER-16)))
		(unwrap-panic (as-contract (contract-call? 'SPH9YG28V53YATFKTJHMDG19RRJT74YFNS2MYTGF.jackob-nft transfer u42 tx-sender TRADER-16)))
		(unwrap-panic (as-contract (contract-call? 'SPH9YG28V53YATFKTJHMDG19RRJT74YFNS2MYTGF.jackob-nft transfer u54 tx-sender TRADER-16)))
	    )
            true
        )
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-1)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (stx-transfer? u136591125 tx-sender TRADER-17)))
	    )
            true
        )
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-1)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (contract-call? 'SP22GHCK5W3EK5VC1PEB3VVCBVFRQNTQXV9306QA0.metacine transfer u97 tx-sender TRADER-18)))
		(unwrap-panic (as-contract (contract-call? 'SP22GHCK5W3EK5VC1PEB3VVCBVFRQNTQXV9306QA0.metacine transfer u88 tx-sender TRADER-18)))
		(unwrap-panic (as-contract (contract-call? 'SP22GHCK5W3EK5VC1PEB3VVCBVFRQNTQXV9306QA0.metacine transfer u74 tx-sender TRADER-18)))
	    )
            true
        )
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-1)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (contract-call? 'SP22GHCK5W3EK5VC1PEB3VVCBVFRQNTQXV9306QA0.metacine transfer u314 tx-sender TRADER-19)))
		(unwrap-panic (as-contract (contract-call? 'SP22GHCK5W3EK5VC1PEB3VVCBVFRQNTQXV9306QA0.bear-market-buddies transfer u271 tx-sender TRADER-19)))
		(unwrap-panic (as-contract (contract-call? 'SP22GHCK5W3EK5VC1PEB3VVCBVFRQNTQXV9306QA0.bear-market-buddies transfer u558 tx-sender TRADER-19)))
		(unwrap-panic (as-contract (contract-call? 'SP22GHCK5W3EK5VC1PEB3VVCBVFRQNTQXV9306QA0.bear-market-buddies transfer u285 tx-sender TRADER-19)))
		(unwrap-panic (as-contract (contract-call? 'SP22GHCK5W3EK5VC1PEB3VVCBVFRQNTQXV9306QA0.metacine transfer u370 tx-sender TRADER-19)))
		(unwrap-panic (as-contract (contract-call? 'SP22GHCK5W3EK5VC1PEB3VVCBVFRQNTQXV9306QA0.metacine transfer u106 tx-sender TRADER-19)))
		(unwrap-panic (as-contract (contract-call? 'SP22GHCK5W3EK5VC1PEB3VVCBVFRQNTQXV9306QA0.bear-market-buddies transfer u731 tx-sender TRADER-19)))
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
