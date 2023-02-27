;; multiway-swap
;; Contract to facilitate a multiway NFT swap.
;; Each of the parties involved has to call confirm-and-escrow to escrow their dues.
;; Once all parties confirmed, finalize has to be called to redistribute escrowed items.
;; At any point before the swap is finalized it can be canceled by a party involved, 
;; regardles of whether they already called confirm-and-escrow or not.

;; traders
(define-constant TRADER-1 'SP14W78Q821B3HQ3ED30624Z1F13X4JMFZY3N5SK4)
(define-constant TRADER-2 'SP1Q6N226KFMA496MVWSB0VZC0T0R9FSKTYYYZ403)
(define-constant TRADER-3 'SP1S6FB10478Z9SGPYEPWGWJ8E1PH4SNANKRE5R0S)
(define-constant TRADER-4 'SP2NM9ZX3A1NWJN5Q8X97RTC0AMG4FHBWSCZSYRPV)
(define-constant TRADER-5 'SP2NS78688FKS2G8ENV9B4HC4QR3Z3DNX21CRDFDQ)
(define-constant TRADER-6 'SP2TW1D8YF5CE0NDP5VCR5NMTPHQ4PQR1KBB4NQ5Q)
(define-constant TRADER-7 'SP2V3FAF7MRQR2JA55MGFMQF7Y8JXFDJH4064XB0Z)
(define-constant TRADER-8 'SP3GP5KQDA8N1FVFDDZAJD0PRKQFE3TYNJ6VRDMSP)
(define-constant TRADER-9 'SP3PES8N30VBEWHR988KX3YNW062TEGR343FHBKAC)
(define-constant TRADER-10 'SPHK8A7P61C6ASWKYDX1PCDX9YA54DKVJN49EXGJ)
(define-constant TRADER-11 'SPMB00CAGKF8VF1H7WGE9A6HHPWGN6QAQMDN2D69)
(define-constant TRADER-12 'SPT73FASVANAV58RVK2BRZP9CJEXYYDYAMV276N3)
(define-constant TRADER-13 'SPVGT0Y4MERPS6BFGP9VHSJ5P3CWGJ4P2ZG55TBY)
(define-constant TRADER-14 'SPYDDR28BCV1CZY11N2YAW16ZW9NZK53VCN3CZEQ)

;; receivers
(define-constant RECEIVER-1 'SP1PJ0M4N981B47GT6KERPKHN1APJH2T5NWZSV7GS)


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

(define-constant NUM_TRADERS u14)

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

;; private functions
(define-private (deposit-escrow) 
    (begin
	(if (is-eq tx-sender TRADER-1)
            (begin
		(unwrap! (contract-call? 'SP8CZNESYSP7XAWX8QA4WV23VT2D9MC8SAZAERR0.stacks-dev transfer u12 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP8CZNESYSP7XAWX8QA4WV23VT2D9MC8SAZAERR0.stacksdev-v2 transfer u13 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP14W78Q821B3HQ3ED30624Z1F13X4JMFZY3N5SK4.buddy2023 transfer u1 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP2NS78688FKS2G8ENV9B4HC4QR3Z3DNX21CRDFDQ.loobles transfer u179 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP8CZNESYSP7XAWX8QA4WV23VT2D9MC8SAZAERR0.stacks-dev transfer u7 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP8CZNESYSP7XAWX8QA4WV23VT2D9MC8SAZAERR0.stacks-dev transfer u6 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP2NS78688FKS2G8ENV9B4HC4QR3Z3DNX21CRDFDQ.loobles transfer u76 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
	    )
            true
        )
	(if (is-eq tx-sender TRADER-2)
            (begin
		(unwrap! (contract-call? 'SP2NS78688FKS2G8ENV9B4HC4QR3Z3DNX21CRDFDQ.loobles transfer u199 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP2NS78688FKS2G8ENV9B4HC4QR3Z3DNX21CRDFDQ.loobles transfer u74 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
	    )
            true
        )
	(if (is-eq tx-sender TRADER-3)
            (begin
		(unwrap! (contract-call? 'SP2NS78688FKS2G8ENV9B4HC4QR3Z3DNX21CRDFDQ.loobles transfer u186 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
	    )
            true
        )
	(if (is-eq tx-sender TRADER-4)
            (begin
		(unwrap! (stx-transfer? u10000000 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_STX))
	    )
            true
        )
	(if (is-eq tx-sender TRADER-5)
            (begin
		(unwrap! (contract-call? 'SP2NS78688FKS2G8ENV9B4HC4QR3Z3DNX21CRDFDQ.loobles transfer u196 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP2NS78688FKS2G8ENV9B4HC4QR3Z3DNX21CRDFDQ.loobles transfer u198 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP2NS78688FKS2G8ENV9B4HC4QR3Z3DNX21CRDFDQ.loobles transfer u183 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP2NS78688FKS2G8ENV9B4HC4QR3Z3DNX21CRDFDQ.loobles transfer u205 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP2NS78688FKS2G8ENV9B4HC4QR3Z3DNX21CRDFDQ.loobles transfer u232 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP2NS78688FKS2G8ENV9B4HC4QR3Z3DNX21CRDFDQ.loobles transfer u292 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
	    )
            true
        )
	(if (is-eq tx-sender TRADER-6)
            (begin
		(unwrap! (contract-call? 'SP2ABNX65BSKVM00ZQZ7K174DFV18CXVGGEMP7Y6X.weed-monsters transfer u9 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP3EB7YHV5NERS2HMCGSGKNMN0BEH52W9H7YE4T9C.dawn-of-the-planet-of-checks transfer u2 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP2NS78688FKS2G8ENV9B4HC4QR3Z3DNX21CRDFDQ.loobles transfer u10 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP1QZT85MFT8HBAG3XEK7K6QY4GGP3MSG5C3H9PQ1.bitcoin-bullfrogs-by-mr-wagmi transfer u39 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
	    )
            true
        )
	(if (is-eq tx-sender TRADER-7)
            (begin
		(unwrap! (contract-call? 'SPJPTE6B8CBQH8VWGYHE4871VXBEKFMC96WSJ9J4.dollicon-avatars-stacks transfer u9 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
	    )
            true
        )
	(if (is-eq tx-sender TRADER-8)
            (begin
		(unwrap! (contract-call? 'SP2NS78688FKS2G8ENV9B4HC4QR3Z3DNX21CRDFDQ.loobles transfer u145 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP2NS78688FKS2G8ENV9B4HC4QR3Z3DNX21CRDFDQ.loobles transfer u144 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
	    )
            true
        )
	(if (is-eq tx-sender TRADER-9)
            (begin
		(unwrap! (contract-call? 'SP2NS78688FKS2G8ENV9B4HC4QR3Z3DNX21CRDFDQ.loobles transfer u207 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
	    )
            true
        )
	(if (is-eq tx-sender TRADER-10)
            (begin
		(unwrap! (stx-transfer? u1989000 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_STX))
	    )
            true
        )
	(if (is-eq tx-sender TRADER-11)
            (begin
		(unwrap! (contract-call? 'SP2NS78688FKS2G8ENV9B4HC4QR3Z3DNX21CRDFDQ.loobles transfer u154 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP2NS78688FKS2G8ENV9B4HC4QR3Z3DNX21CRDFDQ.loobles transfer u197 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
	    )
            true
        )
	(if (is-eq tx-sender TRADER-12)
            (begin
		(unwrap! (stx-transfer? u3676000 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_STX))
	    )
            true
        )
	(if (is-eq tx-sender TRADER-13)
            (begin
		(unwrap! (stx-transfer? u714083000 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_STX))
	    )
            true
        )
	(if (is-eq tx-sender TRADER-14)
            (begin
		(unwrap! (contract-call? 'SP2NS78688FKS2G8ENV9B4HC4QR3Z3DNX21CRDFDQ.loobles transfer u161 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
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
	(unwrap-panic (as-contract (contract-call? 'SP1QZT85MFT8HBAG3XEK7K6QY4GGP3MSG5C3H9PQ1.bitcoin-bullfrogs-by-mr-wagmi transfer u39 tx-sender TRADER-4)))
	(unwrap-panic (as-contract (contract-call? 'SPJPTE6B8CBQH8VWGYHE4871VXBEKFMC96WSJ9J4.dollicon-avatars-stacks transfer u9 tx-sender TRADER-10)))
	(unwrap-panic (as-contract (contract-call? 'SP2NS78688FKS2G8ENV9B4HC4QR3Z3DNX21CRDFDQ.loobles transfer u186 tx-sender TRADER-10)))
	(unwrap-panic (as-contract (contract-call? 'SP2NS78688FKS2G8ENV9B4HC4QR3Z3DNX21CRDFDQ.loobles transfer u232 tx-sender TRADER-12)))
	(unwrap-panic (as-contract (contract-call? 'SP2NS78688FKS2G8ENV9B4HC4QR3Z3DNX21CRDFDQ.loobles transfer u74 tx-sender TRADER-13)))
	(unwrap-panic (as-contract (contract-call? 'SP2NS78688FKS2G8ENV9B4HC4QR3Z3DNX21CRDFDQ.loobles transfer u207 tx-sender TRADER-13)))
	(unwrap-panic (as-contract (contract-call? 'SP2NS78688FKS2G8ENV9B4HC4QR3Z3DNX21CRDFDQ.loobles transfer u196 tx-sender TRADER-13)))
	(unwrap-panic (as-contract (contract-call? 'SP8CZNESYSP7XAWX8QA4WV23VT2D9MC8SAZAERR0.stacks-dev transfer u6 tx-sender TRADER-13)))
	(unwrap-panic (as-contract (contract-call? 'SP2NS78688FKS2G8ENV9B4HC4QR3Z3DNX21CRDFDQ.loobles transfer u183 tx-sender TRADER-13)))
	(unwrap-panic (as-contract (contract-call? 'SP2NS78688FKS2G8ENV9B4HC4QR3Z3DNX21CRDFDQ.loobles transfer u145 tx-sender TRADER-13)))
	(unwrap-panic (as-contract (contract-call? 'SP2NS78688FKS2G8ENV9B4HC4QR3Z3DNX21CRDFDQ.loobles transfer u154 tx-sender TRADER-13)))
	(unwrap-panic (as-contract (contract-call? 'SP3EB7YHV5NERS2HMCGSGKNMN0BEH52W9H7YE4T9C.dawn-of-the-planet-of-checks transfer u2 tx-sender TRADER-13)))
	(unwrap-panic (as-contract (contract-call? 'SP2NS78688FKS2G8ENV9B4HC4QR3Z3DNX21CRDFDQ.loobles transfer u161 tx-sender TRADER-13)))
	(unwrap-panic (as-contract (contract-call? 'SP8CZNESYSP7XAWX8QA4WV23VT2D9MC8SAZAERR0.stacksdev-v2 transfer u13 tx-sender TRADER-13)))
	(unwrap-panic (as-contract (contract-call? 'SP2NS78688FKS2G8ENV9B4HC4QR3Z3DNX21CRDFDQ.loobles transfer u10 tx-sender TRADER-13)))
	(unwrap-panic (as-contract (contract-call? 'SP8CZNESYSP7XAWX8QA4WV23VT2D9MC8SAZAERR0.stacks-dev transfer u12 tx-sender TRADER-13)))
	(unwrap-panic (as-contract (contract-call? 'SP2NS78688FKS2G8ENV9B4HC4QR3Z3DNX21CRDFDQ.loobles transfer u205 tx-sender TRADER-13)))
	(unwrap-panic (as-contract (contract-call? 'SP2NS78688FKS2G8ENV9B4HC4QR3Z3DNX21CRDFDQ.loobles transfer u292 tx-sender TRADER-13)))
	(unwrap-panic (as-contract (contract-call? 'SP2NS78688FKS2G8ENV9B4HC4QR3Z3DNX21CRDFDQ.loobles transfer u76 tx-sender TRADER-13)))
	(unwrap-panic (as-contract (contract-call? 'SP2NS78688FKS2G8ENV9B4HC4QR3Z3DNX21CRDFDQ.loobles transfer u199 tx-sender TRADER-13)))
	(unwrap-panic (as-contract (contract-call? 'SP2ABNX65BSKVM00ZQZ7K174DFV18CXVGGEMP7Y6X.weed-monsters transfer u9 tx-sender TRADER-13)))
	(unwrap-panic (as-contract (contract-call? 'SP2NS78688FKS2G8ENV9B4HC4QR3Z3DNX21CRDFDQ.loobles transfer u179 tx-sender TRADER-13)))
	(unwrap-panic (as-contract (contract-call? 'SP2NS78688FKS2G8ENV9B4HC4QR3Z3DNX21CRDFDQ.loobles transfer u197 tx-sender TRADER-13)))
	(unwrap-panic (as-contract (contract-call? 'SP2NS78688FKS2G8ENV9B4HC4QR3Z3DNX21CRDFDQ.loobles transfer u198 tx-sender TRADER-13)))
	(unwrap-panic (as-contract (contract-call? 'SP14W78Q821B3HQ3ED30624Z1F13X4JMFZY3N5SK4.buddy2023 transfer u1 tx-sender TRADER-13)))
	(unwrap-panic (as-contract (contract-call? 'SP8CZNESYSP7XAWX8QA4WV23VT2D9MC8SAZAERR0.stacks-dev transfer u7 tx-sender TRADER-13)))
	(unwrap-panic (as-contract (contract-call? 'SP2NS78688FKS2G8ENV9B4HC4QR3Z3DNX21CRDFDQ.loobles transfer u144 tx-sender TRADER-13)))

	(unwrap-panic (as-contract (stx-transfer? u343092000 tx-sender TRADER-1)))
	(unwrap-panic (as-contract (stx-transfer? u4444000 tx-sender RECEIVER-1)))
	(unwrap-panic (as-contract (stx-transfer? u40000000 tx-sender TRADER-2)))
	(unwrap-panic (as-contract (stx-transfer? u1800000 tx-sender TRADER-3)))
	(unwrap-panic (as-contract (stx-transfer? u46830000 tx-sender TRADER-5)))
	(unwrap-panic (as-contract (stx-transfer? u55887000 tx-sender TRADER-6)))
	(unwrap-panic (as-contract (stx-transfer? u1000 tx-sender TRADER-7)))
	(unwrap-panic (as-contract (stx-transfer? u180000000 tx-sender TRADER-8)))
	(unwrap-panic (as-contract (stx-transfer? u30001000 tx-sender TRADER-9)))
	(unwrap-panic (as-contract (stx-transfer? u19750000 tx-sender TRADER-11)))
	(unwrap-panic (as-contract (stx-transfer? u7943000 tx-sender TRADER-14)))

        (var-set swapState SWAP_STATE_FINALIZED)
        (ok true)
    )
)

(define-private (return-escrow) 
    (begin 
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-1)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (contract-call? 'SP8CZNESYSP7XAWX8QA4WV23VT2D9MC8SAZAERR0.stacks-dev transfer u12 tx-sender TRADER-1)))
		(unwrap-panic (as-contract (contract-call? 'SP8CZNESYSP7XAWX8QA4WV23VT2D9MC8SAZAERR0.stacksdev-v2 transfer u13 tx-sender TRADER-1)))
		(unwrap-panic (as-contract (contract-call? 'SP14W78Q821B3HQ3ED30624Z1F13X4JMFZY3N5SK4.buddy2023 transfer u1 tx-sender TRADER-1)))
		(unwrap-panic (as-contract (contract-call? 'SP2NS78688FKS2G8ENV9B4HC4QR3Z3DNX21CRDFDQ.loobles transfer u179 tx-sender TRADER-1)))
		(unwrap-panic (as-contract (contract-call? 'SP8CZNESYSP7XAWX8QA4WV23VT2D9MC8SAZAERR0.stacks-dev transfer u7 tx-sender TRADER-1)))
		(unwrap-panic (as-contract (contract-call? 'SP8CZNESYSP7XAWX8QA4WV23VT2D9MC8SAZAERR0.stacks-dev transfer u6 tx-sender TRADER-1)))
		(unwrap-panic (as-contract (contract-call? 'SP2NS78688FKS2G8ENV9B4HC4QR3Z3DNX21CRDFDQ.loobles transfer u76 tx-sender TRADER-1)))
	    )
            true
        )
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-2)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (contract-call? 'SP2NS78688FKS2G8ENV9B4HC4QR3Z3DNX21CRDFDQ.loobles transfer u199 tx-sender TRADER-2)))
		(unwrap-panic (as-contract (contract-call? 'SP2NS78688FKS2G8ENV9B4HC4QR3Z3DNX21CRDFDQ.loobles transfer u74 tx-sender TRADER-2)))
	    )
            true
        )
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-3)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (contract-call? 'SP2NS78688FKS2G8ENV9B4HC4QR3Z3DNX21CRDFDQ.loobles transfer u186 tx-sender TRADER-3)))
	    )
            true
        )
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-4)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (stx-transfer? u10000000 tx-sender TRADER-4)))
	    )
            true
        )
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-5)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (contract-call? 'SP2NS78688FKS2G8ENV9B4HC4QR3Z3DNX21CRDFDQ.loobles transfer u196 tx-sender TRADER-5)))
		(unwrap-panic (as-contract (contract-call? 'SP2NS78688FKS2G8ENV9B4HC4QR3Z3DNX21CRDFDQ.loobles transfer u198 tx-sender TRADER-5)))
		(unwrap-panic (as-contract (contract-call? 'SP2NS78688FKS2G8ENV9B4HC4QR3Z3DNX21CRDFDQ.loobles transfer u183 tx-sender TRADER-5)))
		(unwrap-panic (as-contract (contract-call? 'SP2NS78688FKS2G8ENV9B4HC4QR3Z3DNX21CRDFDQ.loobles transfer u205 tx-sender TRADER-5)))
		(unwrap-panic (as-contract (contract-call? 'SP2NS78688FKS2G8ENV9B4HC4QR3Z3DNX21CRDFDQ.loobles transfer u232 tx-sender TRADER-5)))
		(unwrap-panic (as-contract (contract-call? 'SP2NS78688FKS2G8ENV9B4HC4QR3Z3DNX21CRDFDQ.loobles transfer u292 tx-sender TRADER-5)))
	    )
            true
        )
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-6)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (contract-call? 'SP2ABNX65BSKVM00ZQZ7K174DFV18CXVGGEMP7Y6X.weed-monsters transfer u9 tx-sender TRADER-6)))
		(unwrap-panic (as-contract (contract-call? 'SP3EB7YHV5NERS2HMCGSGKNMN0BEH52W9H7YE4T9C.dawn-of-the-planet-of-checks transfer u2 tx-sender TRADER-6)))
		(unwrap-panic (as-contract (contract-call? 'SP2NS78688FKS2G8ENV9B4HC4QR3Z3DNX21CRDFDQ.loobles transfer u10 tx-sender TRADER-6)))
		(unwrap-panic (as-contract (contract-call? 'SP1QZT85MFT8HBAG3XEK7K6QY4GGP3MSG5C3H9PQ1.bitcoin-bullfrogs-by-mr-wagmi transfer u39 tx-sender TRADER-6)))
	    )
            true
        )
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-7)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (contract-call? 'SPJPTE6B8CBQH8VWGYHE4871VXBEKFMC96WSJ9J4.dollicon-avatars-stacks transfer u9 tx-sender TRADER-7)))
	    )
            true
        )
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-8)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (contract-call? 'SP2NS78688FKS2G8ENV9B4HC4QR3Z3DNX21CRDFDQ.loobles transfer u145 tx-sender TRADER-8)))
		(unwrap-panic (as-contract (contract-call? 'SP2NS78688FKS2G8ENV9B4HC4QR3Z3DNX21CRDFDQ.loobles transfer u144 tx-sender TRADER-8)))
	    )
            true
        )
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-9)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (contract-call? 'SP2NS78688FKS2G8ENV9B4HC4QR3Z3DNX21CRDFDQ.loobles transfer u207 tx-sender TRADER-9)))
	    )
            true
        )
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-10)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (stx-transfer? u1989000 tx-sender TRADER-10)))
	    )
            true
        )
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-11)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (contract-call? 'SP2NS78688FKS2G8ENV9B4HC4QR3Z3DNX21CRDFDQ.loobles transfer u154 tx-sender TRADER-11)))
		(unwrap-panic (as-contract (contract-call? 'SP2NS78688FKS2G8ENV9B4HC4QR3Z3DNX21CRDFDQ.loobles transfer u197 tx-sender TRADER-11)))
	    )
            true
        )
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-12)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (stx-transfer? u3676000 tx-sender TRADER-12)))
	    )
            true
        )
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-13)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (stx-transfer? u714083000 tx-sender TRADER-13)))
	    )
            true
        )
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-14)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (contract-call? 'SP2NS78688FKS2G8ENV9B4HC4QR3Z3DNX21CRDFDQ.loobles transfer u161 tx-sender TRADER-14)))
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
