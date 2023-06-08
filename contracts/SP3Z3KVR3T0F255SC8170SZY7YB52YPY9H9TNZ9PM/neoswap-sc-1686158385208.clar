;; multiway-swap
;; Contract to facilitate a multiway NFT swap.
;; Each of the parties involved has to call confirm-and-escrow to escrow their dues.
;; Once all parties confirmed, finalize has to be called to redistribute escrowed items.
;; At any point before the swap is finalized it can be canceled by a party involved, 
;; regardles of whether they already called confirm-and-escrow or not.
;; Room: https://neoswap.xyz/rooms/uBSRJpq0DEHEfUO98Uw1
;; SwapId: 2etnzEv9FCd66awJ3865

;; traders
(define-constant TRADER-1 'SP1Q6N226KFMA496MVWSB0VZC0T0R9FSKTYYYZ403)

;; receivers
(define-constant RECEIVER-1 'SP2DZRMEHYF67812RDH1BG6V3SB0VF84YCDQQ9QK4)


;; constants
(define-constant ERR_ESCROW_NOT_FILLED u401)
(define-constant ERR_SWAP_FINALIZED u402)
(define-constant ERR_RELEASING_ESCROW_FAILED u491)
(define-constant ERR_SWAP_CANCELED u499)

(define-constant ERR_IS_NOT_ADMIN u409)
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

(define-constant NUM_TRADERS u1)

(define-constant DEPLOYER tx-sender)

;; data maps and vars
(define-data-var swapState uint SWAP_STATE_ACTIVE)
(define-data-var confirmCount uint u0)

(define-map TraderState principal uint)

;; Set TraderState of each trader to TRADER_STATE_ACTIVE.
(map-set TraderState TRADER-1 TRADER_STATE_ACTIVE)

;; private functions
(define-private (deposit-escrow) 
    (begin
	(if (is-eq tx-sender TRADER-1)
            (begin
		(unwrap! (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.rehab-resort transfer u291 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.rehab-resort transfer u292 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP28JPAHN4H9A531AGJ9M455ZC4GEYK6VFKVGHXG6.elpepe transfer u59 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP3EB7YHV5NERS2HMCGSGKNMN0BEH52W9H7YE4T9C.mendaxx-ai-world transfer u10 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP1D3Y8A2VVD2W98VFXCG5AXRYX5PJBBEMV1YPKF1.nonnish-grafters transfer u87 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP3273YEPG4QZWX0ENQ98FBT1N2Y06XW820STP7NN.stacks-seductress-series-1 transfer u1 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP19WKA4H1ZVCWRCY82SPGJHJ3GXD02D60YQT7Y7H.web3-fortune-crystals transfer u13 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP19WKA4H1ZVCWRCY82SPGJHJ3GXD02D60YQT7Y7H.web3-fortune-crystals transfer u2 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP176ZMV706NZGDDX8VSQRGMB7QN33BBDVZ6BMNHD.project-indigo-act1 transfer u1772 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SPP28QCMZ51GVN9933VFH9TXKQ3XCT4WE5A07533.warrior-pigeons transfer u39 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SPP28QCMZ51GVN9933VFH9TXKQ3XCT4WE5A07533.warrior-pigeons transfer u41 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SPM1Q7YG18378H6W254YN8PABEVRPT38ZCY01SJD.fireflywash-dosed-butterflies transfer u31 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP19WKA4H1ZVCWRCY82SPGJHJ3GXD02D60YQT7Y7H.fox-finds-clothes-and-shares transfer u9 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP12VXAS7H2MT7R8116F4RA1FCS21DZ86B4DTN80J.neoswap-anthem-team-edition transfer u4 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP1XJ6GNTDVF6HR1VHPQDMFZJY87D9W6TGMH3QCP.amahle transfer u10 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP2QDMH88MEZ8FFAYHW4B0BTXJRTHX8XBD54FE7HJ.were-mint-to-be transfer u346 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP3273YEPG4QZWX0ENQ98FBT1N2Y06XW820STP7NN.straight-outta-lightroom transfer u5 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP3EHPZ4WHQEKS97JEREXT511T2YEJ5Y9EJP7WNBX.stacks-bears transfer u18 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SPGGAEQWA7Y9HRZY5T0XJCEYEZ28J6RKCCC1HP9M.purple-smoke-sessions-iii-worry-nft transfer u9 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SPJPTE6B8CBQH8VWGYHE4871VXBEKFMC96WSJ9J4.dollicon-avatars-stacks transfer u9 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SPK9KP81Q281Q84SPGAMK8J12X2AQQJGT0XFPPCX.ordinally-people transfer u4 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
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
	(unwrap-panic (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.rehab-resort transfer u291 tx-sender RECEIVER-1)))
	(unwrap-panic (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.rehab-resort transfer u292 tx-sender RECEIVER-1)))
	(unwrap-panic (as-contract (contract-call? 'SP28JPAHN4H9A531AGJ9M455ZC4GEYK6VFKVGHXG6.elpepe transfer u59 tx-sender RECEIVER-1)))
	(unwrap-panic (as-contract (contract-call? 'SP3EB7YHV5NERS2HMCGSGKNMN0BEH52W9H7YE4T9C.mendaxx-ai-world transfer u10 tx-sender RECEIVER-1)))
	(unwrap-panic (as-contract (contract-call? 'SP1D3Y8A2VVD2W98VFXCG5AXRYX5PJBBEMV1YPKF1.nonnish-grafters transfer u87 tx-sender RECEIVER-1)))
	(unwrap-panic (as-contract (contract-call? 'SP3273YEPG4QZWX0ENQ98FBT1N2Y06XW820STP7NN.stacks-seductress-series-1 transfer u1 tx-sender RECEIVER-1)))
	(unwrap-panic (as-contract (contract-call? 'SP19WKA4H1ZVCWRCY82SPGJHJ3GXD02D60YQT7Y7H.web3-fortune-crystals transfer u13 tx-sender RECEIVER-1)))
	(unwrap-panic (as-contract (contract-call? 'SP19WKA4H1ZVCWRCY82SPGJHJ3GXD02D60YQT7Y7H.web3-fortune-crystals transfer u2 tx-sender RECEIVER-1)))
	(unwrap-panic (as-contract (contract-call? 'SP176ZMV706NZGDDX8VSQRGMB7QN33BBDVZ6BMNHD.project-indigo-act1 transfer u1772 tx-sender RECEIVER-1)))
	(unwrap-panic (as-contract (contract-call? 'SPP28QCMZ51GVN9933VFH9TXKQ3XCT4WE5A07533.warrior-pigeons transfer u39 tx-sender RECEIVER-1)))
	(unwrap-panic (as-contract (contract-call? 'SPP28QCMZ51GVN9933VFH9TXKQ3XCT4WE5A07533.warrior-pigeons transfer u41 tx-sender RECEIVER-1)))
	(unwrap-panic (as-contract (contract-call? 'SPM1Q7YG18378H6W254YN8PABEVRPT38ZCY01SJD.fireflywash-dosed-butterflies transfer u31 tx-sender RECEIVER-1)))
	(unwrap-panic (as-contract (contract-call? 'SP19WKA4H1ZVCWRCY82SPGJHJ3GXD02D60YQT7Y7H.fox-finds-clothes-and-shares transfer u9 tx-sender RECEIVER-1)))
	(unwrap-panic (as-contract (contract-call? 'SP12VXAS7H2MT7R8116F4RA1FCS21DZ86B4DTN80J.neoswap-anthem-team-edition transfer u4 tx-sender RECEIVER-1)))
	(unwrap-panic (as-contract (contract-call? 'SP1XJ6GNTDVF6HR1VHPQDMFZJY87D9W6TGMH3QCP.amahle transfer u10 tx-sender RECEIVER-1)))
	(unwrap-panic (as-contract (contract-call? 'SP2QDMH88MEZ8FFAYHW4B0BTXJRTHX8XBD54FE7HJ.were-mint-to-be transfer u346 tx-sender RECEIVER-1)))
	(unwrap-panic (as-contract (contract-call? 'SP3273YEPG4QZWX0ENQ98FBT1N2Y06XW820STP7NN.straight-outta-lightroom transfer u5 tx-sender RECEIVER-1)))
	(unwrap-panic (as-contract (contract-call? 'SP3EHPZ4WHQEKS97JEREXT511T2YEJ5Y9EJP7WNBX.stacks-bears transfer u18 tx-sender RECEIVER-1)))
	(unwrap-panic (as-contract (contract-call? 'SPGGAEQWA7Y9HRZY5T0XJCEYEZ28J6RKCCC1HP9M.purple-smoke-sessions-iii-worry-nft transfer u9 tx-sender RECEIVER-1)))
	(unwrap-panic (as-contract (contract-call? 'SPJPTE6B8CBQH8VWGYHE4871VXBEKFMC96WSJ9J4.dollicon-avatars-stacks transfer u9 tx-sender RECEIVER-1)))
	(unwrap-panic (as-contract (contract-call? 'SPK9KP81Q281Q84SPGAMK8J12X2AQQJGT0XFPPCX.ordinally-people transfer u4 tx-sender RECEIVER-1)))


        (var-set swapState SWAP_STATE_FINALIZED)
        (ok true)
    )
)

(define-private (return-escrow) 
    (begin 
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-1)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.rehab-resort transfer u291 tx-sender TRADER-1)))
		(unwrap-panic (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.rehab-resort transfer u292 tx-sender TRADER-1)))
		(unwrap-panic (as-contract (contract-call? 'SP28JPAHN4H9A531AGJ9M455ZC4GEYK6VFKVGHXG6.elpepe transfer u59 tx-sender TRADER-1)))
		(unwrap-panic (as-contract (contract-call? 'SP3EB7YHV5NERS2HMCGSGKNMN0BEH52W9H7YE4T9C.mendaxx-ai-world transfer u10 tx-sender TRADER-1)))
		(unwrap-panic (as-contract (contract-call? 'SP1D3Y8A2VVD2W98VFXCG5AXRYX5PJBBEMV1YPKF1.nonnish-grafters transfer u87 tx-sender TRADER-1)))
		(unwrap-panic (as-contract (contract-call? 'SP3273YEPG4QZWX0ENQ98FBT1N2Y06XW820STP7NN.stacks-seductress-series-1 transfer u1 tx-sender TRADER-1)))
		(unwrap-panic (as-contract (contract-call? 'SP19WKA4H1ZVCWRCY82SPGJHJ3GXD02D60YQT7Y7H.web3-fortune-crystals transfer u13 tx-sender TRADER-1)))
		(unwrap-panic (as-contract (contract-call? 'SP19WKA4H1ZVCWRCY82SPGJHJ3GXD02D60YQT7Y7H.web3-fortune-crystals transfer u2 tx-sender TRADER-1)))
		(unwrap-panic (as-contract (contract-call? 'SP176ZMV706NZGDDX8VSQRGMB7QN33BBDVZ6BMNHD.project-indigo-act1 transfer u1772 tx-sender TRADER-1)))
		(unwrap-panic (as-contract (contract-call? 'SPP28QCMZ51GVN9933VFH9TXKQ3XCT4WE5A07533.warrior-pigeons transfer u39 tx-sender TRADER-1)))
		(unwrap-panic (as-contract (contract-call? 'SPP28QCMZ51GVN9933VFH9TXKQ3XCT4WE5A07533.warrior-pigeons transfer u41 tx-sender TRADER-1)))
		(unwrap-panic (as-contract (contract-call? 'SPM1Q7YG18378H6W254YN8PABEVRPT38ZCY01SJD.fireflywash-dosed-butterflies transfer u31 tx-sender TRADER-1)))
		(unwrap-panic (as-contract (contract-call? 'SP19WKA4H1ZVCWRCY82SPGJHJ3GXD02D60YQT7Y7H.fox-finds-clothes-and-shares transfer u9 tx-sender TRADER-1)))
		(unwrap-panic (as-contract (contract-call? 'SP12VXAS7H2MT7R8116F4RA1FCS21DZ86B4DTN80J.neoswap-anthem-team-edition transfer u4 tx-sender TRADER-1)))
		(unwrap-panic (as-contract (contract-call? 'SP1XJ6GNTDVF6HR1VHPQDMFZJY87D9W6TGMH3QCP.amahle transfer u10 tx-sender TRADER-1)))
		(unwrap-panic (as-contract (contract-call? 'SP2QDMH88MEZ8FFAYHW4B0BTXJRTHX8XBD54FE7HJ.were-mint-to-be transfer u346 tx-sender TRADER-1)))
		(unwrap-panic (as-contract (contract-call? 'SP3273YEPG4QZWX0ENQ98FBT1N2Y06XW820STP7NN.straight-outta-lightroom transfer u5 tx-sender TRADER-1)))
		(unwrap-panic (as-contract (contract-call? 'SP3EHPZ4WHQEKS97JEREXT511T2YEJ5Y9EJP7WNBX.stacks-bears transfer u18 tx-sender TRADER-1)))
		(unwrap-panic (as-contract (contract-call? 'SPGGAEQWA7Y9HRZY5T0XJCEYEZ28J6RKCCC1HP9M.purple-smoke-sessions-iii-worry-nft transfer u9 tx-sender TRADER-1)))
		(unwrap-panic (as-contract (contract-call? 'SPJPTE6B8CBQH8VWGYHE4871VXBEKFMC96WSJ9J4.dollicon-avatars-stacks transfer u9 tx-sender TRADER-1)))
		(unwrap-panic (as-contract (contract-call? 'SPK9KP81Q281Q84SPGAMK8J12X2AQQJGT0XFPPCX.ordinally-people transfer u4 tx-sender TRADER-1)))
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

(define-public (admin-cancel) 
    (begin
        (asserts! (is-eq tx-sender DEPLOYER) (err ERR_IS_NOT_ADMIN))
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
