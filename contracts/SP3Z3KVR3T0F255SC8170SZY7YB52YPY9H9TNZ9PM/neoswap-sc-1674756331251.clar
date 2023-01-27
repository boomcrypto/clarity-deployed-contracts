
;; multiway-swap
;; Contract to facilitate a multiway NFT swap.
;; Each of the parties involved has to call confirm-and-escrow to escrow their dues.
;; Once all parties confirmed, finalize has to be called to redistribute escrowed items.
;; At any point before the swap is finalized it can be canceled by a party involved, 
;; regardles of whether they already called confirm-and-escrow or not.

;; traders
(define-constant TRADER-1 'SP12VXAS7H2MT7R8116F4RA1FCS21DZ86B4DTN80J)
(define-constant TRADER-2 'SP19WKA4H1ZVCWRCY82SPGJHJ3GXD02D60YQT7Y7H)
(define-constant TRADER-3 'SP1Q6N226KFMA496MVWSB0VZC0T0R9FSKTYYYZ403)
(define-constant TRADER-4 'SP1SBTRXDJP4N825PY69B1MKTQ4MSPB0DW9JCQHKE)
(define-constant TRADER-5 'SP1XJ6GNTDVF6HR1VHPQDMFZJY87D9W6TGMH3QCP)
(define-constant TRADER-6 'SP28NCDY6V4T7NJBMYGTJ55NHMXMC0GG806JW1ZTB)
(define-constant TRADER-7 'SP2M63YGBZCTWBWBCG77RET0RMP42C08T73MKAPNP)
(define-constant TRADER-8 'SP2TW1D8YF5CE0NDP5VCR5NMTPHQ4PQR1KBB4NQ5Q)
(define-constant TRADER-9 'SP3C5JYPB8YE5H9WC2SM196RVJ0JXN2GHCWXJWSES)
(define-constant TRADER-10 'SP3P4E5DQBJXMQ6MY5CR67G8RT9C5E8D3JK80MMKH)
(define-constant TRADER-11 'SP5G3VY7MZT8BNB6FHXZE9JD4PPF8WRT3H6JSBWW)
(define-constant TRADER-12 'SPH9YG28V53YATFKTJHMDG19RRJT74YFNS2MYTGF)
(define-constant TRADER-13 'SPHK8A7P61C6ASWKYDX1PCDX9YA54DKVJN49EXGJ)
(define-constant TRADER-14 'SPN3Y24JD5B17DN9Y8AEQGQV4VVWA644ACXBE3XE)
(define-constant TRADER-15 'SPVDF4YJER5QZD2PEY7WEDY6ZX6EQ36V1WN5XME)

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

(define-constant NUM_TRADERS u15)

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

;; private functions
(define-private (deposit-escrow) 
    (begin
	(if (is-eq tx-sender TRADER-1)
            (begin
		(unwrap! (stx-transfer? u8000000 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_STX))
	    )
            true
        )
	(if (is-eq tx-sender TRADER-2)
            (begin
		(unwrap! (stx-transfer? u15087500 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_STX))
		(unwrap! (contract-call? 'SP187Y7NRSG3T9Z9WTSWNEN3XRV1YSJWS81C7JKV7.stacks-ninjas- transfer u93 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.wasteland-apes-nft transfer u4554 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
	    )
            true
        )
	(if (is-eq tx-sender TRADER-3)
            (begin
		(unwrap! (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.dream-daruma transfer u2384 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.dream-daruma transfer u2374 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
	    )
            true
        )
	(if (is-eq tx-sender TRADER-4)
            (begin
		(unwrap! (stx-transfer? u27812500 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_STX))
	    )
            true
        )
	(if (is-eq tx-sender TRADER-5)
            (begin
		(unwrap! (contract-call? 'SPQZF23W7SEYBFG5JQ496NMY0G7379SRYEDREMSV.Candy transfer u1645 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SPQZF23W7SEYBFG5JQ496NMY0G7379SRYEDREMSV.Candy transfer u1647 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP1FVFX8HQZPVHS2SBBRDGB8A1G8QCXHAMQAFQV0T.hallow-heads transfer u588 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SPFRNSJ3T6HSW1PJN2TAJZVKY3REYFCFDHETWJWG.stacks-punk-reloaded transfer u266 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.steady-lads-msa transfer u9050 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
	    )
            true
        )
	(if (is-eq tx-sender TRADER-6)
            (begin
		(unwrap! (contract-call? 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.citypacks-001 transfer u163 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP2XJBAZXVDT2WMFY82XGPX8Q64GF45CSX66Q32G4.bitcoin-nouns transfer u686 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
	    )
            true
        )
	(if (is-eq tx-sender TRADER-7)
            (begin
		(unwrap! (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.steady-lads transfer u4386 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.steady-lads-msa transfer u1812 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.steady-lads transfer u2661 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.steady-lads transfer u1812 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
	    )
            true
        )
	(if (is-eq tx-sender TRADER-8)
            (begin
		(unwrap! (stx-transfer? u5500000 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_STX))
		(unwrap! (contract-call? 'SP1QZT85MFT8HBAG3XEK7K6QY4GGP3MSG5C3H9PQ1.bitcoin-bullfrogs-by-mr-wagmi transfer u3 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP2ABNX65BSKVM00ZQZ7K174DFV18CXVGGEMP7Y6X.weed-monsters transfer u61 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
	    )
            true
        )
	(if (is-eq tx-sender TRADER-9)
            (begin
		(unwrap! (stx-transfer? u2000000 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_STX))
	    )
            true
        )
	(if (is-eq tx-sender TRADER-10)
            (begin
		(unwrap! (stx-transfer? u40962500 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_STX))
	    )
            true
        )
	(if (is-eq tx-sender TRADER-11)
            (begin
		(unwrap! (stx-transfer? u5200000 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_STX))
		(unwrap! (contract-call? 'SP2QDMH88MEZ8FFAYHW4B0BTXJRTHX8XBD54FE7HJ.btc-pizza-day-porto-alegre transfer u72 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP1MX3R99FENJJJVKW27DSA6X2M6SDSVJH4Y0HE23.pepepunks transfer u799 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.dream-daruma transfer u2380 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
	    )
            true
        )
	(if (is-eq tx-sender TRADER-12)
            (begin
		(unwrap! (contract-call? 'SP213KNHB5QD308TEESY1ZMX1BP8EZDPG4JWD0MEA.web4 transfer u8238 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
	    )
            true
        )
	(if (is-eq tx-sender TRADER-13)
            (begin
		(unwrap! (contract-call? 'SPYHY9MV6S08YJQVW0R400ADXZBBJ0GM096BMY34.liquidium-early-access-ticket transfer u17 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
	    )
            true
        )
	(if (is-eq tx-sender TRADER-14)
            (begin
		(unwrap! (contract-call? 'SPJJYJVZ4H7B34GG8D3SSN70WVWDYSHCC9E9ZV4V.bitcoin-toadz transfer u6899 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SPJJYJVZ4H7B34GG8D3SSN70WVWDYSHCC9E9ZV4V.bitcoin-toadz transfer u6877 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
	    )
            true
        )
	(if (is-eq tx-sender TRADER-15)
            (begin
		(unwrap! (contract-call? 'SPGGAEQWA7Y9HRZY5T0XJCEYEZ28J6RKCCC1HP9M.PaperPlanes transfer u110 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
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
	(unwrap-panic (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.steady-lads transfer u1812 tx-sender TRADER-1)))
	(unwrap-panic (as-contract (contract-call? 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.steady-lads-msa transfer u9050 tx-sender TRADER-2)))
	(unwrap-panic (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.dream-daruma transfer u2380 tx-sender TRADER-2)))
	(unwrap-panic (as-contract (contract-call? 'SPGGAEQWA7Y9HRZY5T0XJCEYEZ28J6RKCCC1HP9M.PaperPlanes transfer u110 tx-sender TRADER-2)))
	(unwrap-panic (as-contract (contract-call? 'SPJJYJVZ4H7B34GG8D3SSN70WVWDYSHCC9E9ZV4V.bitcoin-toadz transfer u6877 tx-sender TRADER-2)))
	(unwrap-panic (as-contract (contract-call? 'SP2QDMH88MEZ8FFAYHW4B0BTXJRTHX8XBD54FE7HJ.btc-pizza-day-porto-alegre transfer u72 tx-sender TRADER-2)))
	(unwrap-panic (as-contract (contract-call? 'SP1QZT85MFT8HBAG3XEK7K6QY4GGP3MSG5C3H9PQ1.bitcoin-bullfrogs-by-mr-wagmi transfer u3 tx-sender TRADER-2)))
	(unwrap-panic (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.wasteland-apes-nft transfer u4554 tx-sender TRADER-3)))
	(unwrap-panic (as-contract (contract-call? 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.citypacks-001 transfer u163 tx-sender TRADER-4)))
	(unwrap-panic (as-contract (contract-call? 'SPYHY9MV6S08YJQVW0R400ADXZBBJ0GM096BMY34.liquidium-early-access-ticket transfer u17 tx-sender TRADER-4)))
	(unwrap-panic (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.steady-lads transfer u2661 tx-sender TRADER-5)))
	(unwrap-panic (as-contract (contract-call? 'SP1FVFX8HQZPVHS2SBBRDGB8A1G8QCXHAMQAFQV0T.hallow-heads transfer u588 tx-sender TRADER-8)))
	(unwrap-panic (as-contract (contract-call? 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.steady-lads-msa transfer u1812 tx-sender TRADER-8)))
	(unwrap-panic (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.dream-daruma transfer u2384 tx-sender TRADER-8)))
	(unwrap-panic (as-contract (contract-call? 'SPJJYJVZ4H7B34GG8D3SSN70WVWDYSHCC9E9ZV4V.bitcoin-toadz transfer u6899 tx-sender TRADER-8)))
	(unwrap-panic (as-contract (contract-call? 'SPQZF23W7SEYBFG5JQ496NMY0G7379SRYEDREMSV.Candy transfer u1645 tx-sender TRADER-9)))
	(unwrap-panic (as-contract (contract-call? 'SPQZF23W7SEYBFG5JQ496NMY0G7379SRYEDREMSV.Candy transfer u1647 tx-sender TRADER-9)))
	(unwrap-panic (as-contract (contract-call? 'SPFRNSJ3T6HSW1PJN2TAJZVKY3REYFCFDHETWJWG.stacks-punk-reloaded transfer u266 tx-sender TRADER-10)))
	(unwrap-panic (as-contract (contract-call? 'SP187Y7NRSG3T9Z9WTSWNEN3XRV1YSJWS81C7JKV7.stacks-ninjas- transfer u93 tx-sender TRADER-10)))
	(unwrap-panic (as-contract (contract-call? 'SP2XJBAZXVDT2WMFY82XGPX8Q64GF45CSX66Q32G4.bitcoin-nouns transfer u686 tx-sender TRADER-10)))
	(unwrap-panic (as-contract (contract-call? 'SP1MX3R99FENJJJVKW27DSA6X2M6SDSVJH4Y0HE23.pepepunks transfer u799 tx-sender TRADER-10)))
	(unwrap-panic (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.dream-daruma transfer u2374 tx-sender TRADER-10)))
	(unwrap-panic (as-contract (contract-call? 'SP2ABNX65BSKVM00ZQZ7K174DFV18CXVGGEMP7Y6X.weed-monsters transfer u61 tx-sender TRADER-11)))
	(unwrap-panic (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.steady-lads transfer u4386 tx-sender TRADER-13)))
	(unwrap-panic (as-contract (contract-call? 'SP213KNHB5QD308TEESY1ZMX1BP8EZDPG4JWD0MEA.web4 transfer u8238 tx-sender TRADER-14)))

	(unwrap-panic (as-contract (stx-transfer? u3175000 tx-sender RECEIVER-1)))
	(unwrap-panic (as-contract (stx-transfer? u19575000 tx-sender TRADER-5)))
	(unwrap-panic (as-contract (stx-transfer? u29625000 tx-sender TRADER-6)))
	(unwrap-panic (as-contract (stx-transfer? u35000000 tx-sender TRADER-7)))
	(unwrap-panic (as-contract (stx-transfer? u3000000 tx-sender TRADER-12)))
	(unwrap-panic (as-contract (stx-transfer? u4187500 tx-sender TRADER-13)))
	(unwrap-panic (as-contract (stx-transfer? u2000000 tx-sender TRADER-14)))
	(unwrap-panic (as-contract (stx-transfer? u8000000 tx-sender TRADER-15)))

        (var-set swapState SWAP_STATE_FINALIZED)
        (ok true)
    )
)

(define-private (return-escrow) 
    (begin 
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-1)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (stx-transfer? u8000000 tx-sender TRADER-1)))
	    )
            true
        )
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-1)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (stx-transfer? u15087500 tx-sender TRADER-2)))
		(unwrap-panic (as-contract (contract-call? 'SP187Y7NRSG3T9Z9WTSWNEN3XRV1YSJWS81C7JKV7.stacks-ninjas- transfer u93 tx-sender TRADER-2)))
		(unwrap-panic (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.wasteland-apes-nft transfer u4554 tx-sender TRADER-2)))
	    )
            true
        )
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-1)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.dream-daruma transfer u2384 tx-sender TRADER-3)))
		(unwrap-panic (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.dream-daruma transfer u2374 tx-sender TRADER-3)))
	    )
            true
        )
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-1)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (stx-transfer? u27812500 tx-sender TRADER-4)))
	    )
            true
        )
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-1)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (contract-call? 'SPQZF23W7SEYBFG5JQ496NMY0G7379SRYEDREMSV.Candy transfer u1645 tx-sender TRADER-5)))
		(unwrap-panic (as-contract (contract-call? 'SPQZF23W7SEYBFG5JQ496NMY0G7379SRYEDREMSV.Candy transfer u1647 tx-sender TRADER-5)))
		(unwrap-panic (as-contract (contract-call? 'SP1FVFX8HQZPVHS2SBBRDGB8A1G8QCXHAMQAFQV0T.hallow-heads transfer u588 tx-sender TRADER-5)))
		(unwrap-panic (as-contract (contract-call? 'SPFRNSJ3T6HSW1PJN2TAJZVKY3REYFCFDHETWJWG.stacks-punk-reloaded transfer u266 tx-sender TRADER-5)))
		(unwrap-panic (as-contract (contract-call? 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.steady-lads-msa transfer u9050 tx-sender TRADER-5)))
	    )
            true
        )
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-1)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (contract-call? 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.citypacks-001 transfer u163 tx-sender TRADER-6)))
		(unwrap-panic (as-contract (contract-call? 'SP2XJBAZXVDT2WMFY82XGPX8Q64GF45CSX66Q32G4.bitcoin-nouns transfer u686 tx-sender TRADER-6)))
	    )
            true
        )
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-1)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.steady-lads transfer u4386 tx-sender TRADER-7)))
		(unwrap-panic (as-contract (contract-call? 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.steady-lads-msa transfer u1812 tx-sender TRADER-7)))
		(unwrap-panic (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.steady-lads transfer u2661 tx-sender TRADER-7)))
		(unwrap-panic (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.steady-lads transfer u1812 tx-sender TRADER-7)))
	    )
            true
        )
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-1)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (stx-transfer? u5500000 tx-sender TRADER-8)))
		(unwrap-panic (as-contract (contract-call? 'SP1QZT85MFT8HBAG3XEK7K6QY4GGP3MSG5C3H9PQ1.bitcoin-bullfrogs-by-mr-wagmi transfer u3 tx-sender TRADER-8)))
		(unwrap-panic (as-contract (contract-call? 'SP2ABNX65BSKVM00ZQZ7K174DFV18CXVGGEMP7Y6X.weed-monsters transfer u61 tx-sender TRADER-8)))
	    )
            true
        )
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-1)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (stx-transfer? u2000000 tx-sender TRADER-9)))
	    )
            true
        )
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-1)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (stx-transfer? u40962500 tx-sender TRADER-10)))
	    )
            true
        )
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-1)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (stx-transfer? u5200000 tx-sender TRADER-11)))
		(unwrap-panic (as-contract (contract-call? 'SP2QDMH88MEZ8FFAYHW4B0BTXJRTHX8XBD54FE7HJ.btc-pizza-day-porto-alegre transfer u72 tx-sender TRADER-11)))
		(unwrap-panic (as-contract (contract-call? 'SP1MX3R99FENJJJVKW27DSA6X2M6SDSVJH4Y0HE23.pepepunks transfer u799 tx-sender TRADER-11)))
		(unwrap-panic (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.dream-daruma transfer u2380 tx-sender TRADER-11)))
	    )
            true
        )
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-1)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (contract-call? 'SP213KNHB5QD308TEESY1ZMX1BP8EZDPG4JWD0MEA.web4 transfer u8238 tx-sender TRADER-12)))
	    )
            true
        )
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-1)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (contract-call? 'SPYHY9MV6S08YJQVW0R400ADXZBBJ0GM096BMY34.liquidium-early-access-ticket transfer u17 tx-sender TRADER-13)))
	    )
            true
        )
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-1)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (contract-call? 'SPJJYJVZ4H7B34GG8D3SSN70WVWDYSHCC9E9ZV4V.bitcoin-toadz transfer u6899 tx-sender TRADER-14)))
		(unwrap-panic (as-contract (contract-call? 'SPJJYJVZ4H7B34GG8D3SSN70WVWDYSHCC9E9ZV4V.bitcoin-toadz transfer u6877 tx-sender TRADER-14)))
	    )
            true
        )
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-1)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (contract-call? 'SPGGAEQWA7Y9HRZY5T0XJCEYEZ28J6RKCCC1HP9M.PaperPlanes transfer u110 tx-sender TRADER-15)))
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
