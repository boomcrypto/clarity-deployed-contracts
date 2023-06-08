;; multiway-swap
;; Contract to facilitate a multiway NFT swap.
;; Each of the parties involved has to call confirm-and-escrow to escrow their dues.
;; Once all parties confirmed, finalize has to be called to redistribute escrowed items.
;; At any point before the swap is finalized it can be canceled by a party involved, 
;; regardles of whether they already called confirm-and-escrow or not.
;; Room: https://neoswap.xyz/rooms/hw4qPf5q2EaHexXJAUhs
;; SwapId: g0raYIul0p8lujsRzGCB

;; traders
(define-constant TRADER-1 'SP1Q6N226KFMA496MVWSB0VZC0T0R9FSKTYYYZ403)

;; receivers
(define-constant RECEIVER-1 'SP2PFPYHZCRACHWM8WEXD96SXYWX0KND015TNGGJ1)


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
		(unwrap! (contract-call? 'SP1QZT85MFT8HBAG3XEK7K6QY4GGP3MSG5C3H9PQ1.bitcoin-bullfrogs-by-mr-wagmi transfer u43 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP2J4TG4H9KYMTTG267KMR82JDM20WHET6XNR0PWQ.bitcoin-owlz transfer u1801 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP1MX3R99FENJJJVKW27DSA6X2M6SDSVJH4Y0HE23.pepepunks-unicorn-edition transfer u32 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP1691VGPP73NJ4QXQWZQX1779SCGH257CZV9TY00.women-power transfer u31 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.belles-witches transfer u4279 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.belles-witches transfer u4459 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.belles-witches transfer u4870 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.belles-witches transfer u841 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP34V64PNDN1535R0DP60EBSXASJHKJ5NH8JPHBQH.pixel-nodes transfer u166 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.rehab-resort transfer u189 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP33SE5XKAY043VN4ZNYCZB7G7AQ2QT1K9K3J70Z2.anime-contest-2021 transfer u31 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP28JPAHN4H9A531AGJ9M455ZC4GEYK6VFKVGHXG6.elpepe transfer u38 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP28JPAHN4H9A531AGJ9M455ZC4GEYK6VFKVGHXG6.elpepe transfer u41 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP34V64PNDN1535R0DP60EBSXASJHKJ5NH8JPHBQH.mini-nodes transfer u26 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP19WKA4H1ZVCWRCY82SPGJHJ3GXD02D60YQT7Y7H.web3-fortune-crystals transfer u12 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP19WKA4H1ZVCWRCY82SPGJHJ3GXD02D60YQT7Y7H.web3-fortune-crystals transfer u4 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP7HFEF6RVMEYAFW23GMHBXHPQ17BPKPTF9475Z9.clown-world transfer u27 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP1GWHGESCF29TV10Q6X0VZYWH4QJ6CM9NK6DSH9J.peach-flowers transfer u24 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP229FR0MTFR0PX83YS9P5KEHAFPPKTXPG04RKP7T.afro-sisters transfer u63 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP1G6NBZ22B184MM26QY1DVH657K8KP01GW8RDRM1.citybulls-nft transfer u62 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP162D87CY84QVVCMJKNKGHC7GGXFGA0TAR9D0XJW.melophonic-entertainment transfer u8 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
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
	(unwrap-panic (as-contract (contract-call? 'SP1QZT85MFT8HBAG3XEK7K6QY4GGP3MSG5C3H9PQ1.bitcoin-bullfrogs-by-mr-wagmi transfer u43 tx-sender RECEIVER-1)))
	(unwrap-panic (as-contract (contract-call? 'SP2J4TG4H9KYMTTG267KMR82JDM20WHET6XNR0PWQ.bitcoin-owlz transfer u1801 tx-sender RECEIVER-1)))
	(unwrap-panic (as-contract (contract-call? 'SP1MX3R99FENJJJVKW27DSA6X2M6SDSVJH4Y0HE23.pepepunks-unicorn-edition transfer u32 tx-sender RECEIVER-1)))
	(unwrap-panic (as-contract (contract-call? 'SP1691VGPP73NJ4QXQWZQX1779SCGH257CZV9TY00.women-power transfer u31 tx-sender RECEIVER-1)))
	(unwrap-panic (as-contract (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.belles-witches transfer u4279 tx-sender RECEIVER-1)))
	(unwrap-panic (as-contract (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.belles-witches transfer u4459 tx-sender RECEIVER-1)))
	(unwrap-panic (as-contract (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.belles-witches transfer u4870 tx-sender RECEIVER-1)))
	(unwrap-panic (as-contract (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.belles-witches transfer u841 tx-sender RECEIVER-1)))
	(unwrap-panic (as-contract (contract-call? 'SP34V64PNDN1535R0DP60EBSXASJHKJ5NH8JPHBQH.pixel-nodes transfer u166 tx-sender RECEIVER-1)))
	(unwrap-panic (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.rehab-resort transfer u189 tx-sender RECEIVER-1)))
	(unwrap-panic (as-contract (contract-call? 'SP33SE5XKAY043VN4ZNYCZB7G7AQ2QT1K9K3J70Z2.anime-contest-2021 transfer u31 tx-sender RECEIVER-1)))
	(unwrap-panic (as-contract (contract-call? 'SP28JPAHN4H9A531AGJ9M455ZC4GEYK6VFKVGHXG6.elpepe transfer u38 tx-sender RECEIVER-1)))
	(unwrap-panic (as-contract (contract-call? 'SP28JPAHN4H9A531AGJ9M455ZC4GEYK6VFKVGHXG6.elpepe transfer u41 tx-sender RECEIVER-1)))
	(unwrap-panic (as-contract (contract-call? 'SP34V64PNDN1535R0DP60EBSXASJHKJ5NH8JPHBQH.mini-nodes transfer u26 tx-sender RECEIVER-1)))
	(unwrap-panic (as-contract (contract-call? 'SP19WKA4H1ZVCWRCY82SPGJHJ3GXD02D60YQT7Y7H.web3-fortune-crystals transfer u12 tx-sender RECEIVER-1)))
	(unwrap-panic (as-contract (contract-call? 'SP19WKA4H1ZVCWRCY82SPGJHJ3GXD02D60YQT7Y7H.web3-fortune-crystals transfer u4 tx-sender RECEIVER-1)))
	(unwrap-panic (as-contract (contract-call? 'SP7HFEF6RVMEYAFW23GMHBXHPQ17BPKPTF9475Z9.clown-world transfer u27 tx-sender RECEIVER-1)))
	(unwrap-panic (as-contract (contract-call? 'SP1GWHGESCF29TV10Q6X0VZYWH4QJ6CM9NK6DSH9J.peach-flowers transfer u24 tx-sender RECEIVER-1)))
	(unwrap-panic (as-contract (contract-call? 'SP229FR0MTFR0PX83YS9P5KEHAFPPKTXPG04RKP7T.afro-sisters transfer u63 tx-sender RECEIVER-1)))
	(unwrap-panic (as-contract (contract-call? 'SP1G6NBZ22B184MM26QY1DVH657K8KP01GW8RDRM1.citybulls-nft transfer u62 tx-sender RECEIVER-1)))
	(unwrap-panic (as-contract (contract-call? 'SP162D87CY84QVVCMJKNKGHC7GGXFGA0TAR9D0XJW.melophonic-entertainment transfer u8 tx-sender RECEIVER-1)))


        (var-set swapState SWAP_STATE_FINALIZED)
        (ok true)
    )
)

(define-private (return-escrow) 
    (begin 
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-1)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (contract-call? 'SP1QZT85MFT8HBAG3XEK7K6QY4GGP3MSG5C3H9PQ1.bitcoin-bullfrogs-by-mr-wagmi transfer u43 tx-sender TRADER-1)))
		(unwrap-panic (as-contract (contract-call? 'SP2J4TG4H9KYMTTG267KMR82JDM20WHET6XNR0PWQ.bitcoin-owlz transfer u1801 tx-sender TRADER-1)))
		(unwrap-panic (as-contract (contract-call? 'SP1MX3R99FENJJJVKW27DSA6X2M6SDSVJH4Y0HE23.pepepunks-unicorn-edition transfer u32 tx-sender TRADER-1)))
		(unwrap-panic (as-contract (contract-call? 'SP1691VGPP73NJ4QXQWZQX1779SCGH257CZV9TY00.women-power transfer u31 tx-sender TRADER-1)))
		(unwrap-panic (as-contract (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.belles-witches transfer u4279 tx-sender TRADER-1)))
		(unwrap-panic (as-contract (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.belles-witches transfer u4459 tx-sender TRADER-1)))
		(unwrap-panic (as-contract (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.belles-witches transfer u4870 tx-sender TRADER-1)))
		(unwrap-panic (as-contract (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.belles-witches transfer u841 tx-sender TRADER-1)))
		(unwrap-panic (as-contract (contract-call? 'SP34V64PNDN1535R0DP60EBSXASJHKJ5NH8JPHBQH.pixel-nodes transfer u166 tx-sender TRADER-1)))
		(unwrap-panic (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.rehab-resort transfer u189 tx-sender TRADER-1)))
		(unwrap-panic (as-contract (contract-call? 'SP33SE5XKAY043VN4ZNYCZB7G7AQ2QT1K9K3J70Z2.anime-contest-2021 transfer u31 tx-sender TRADER-1)))
		(unwrap-panic (as-contract (contract-call? 'SP28JPAHN4H9A531AGJ9M455ZC4GEYK6VFKVGHXG6.elpepe transfer u38 tx-sender TRADER-1)))
		(unwrap-panic (as-contract (contract-call? 'SP28JPAHN4H9A531AGJ9M455ZC4GEYK6VFKVGHXG6.elpepe transfer u41 tx-sender TRADER-1)))
		(unwrap-panic (as-contract (contract-call? 'SP34V64PNDN1535R0DP60EBSXASJHKJ5NH8JPHBQH.mini-nodes transfer u26 tx-sender TRADER-1)))
		(unwrap-panic (as-contract (contract-call? 'SP19WKA4H1ZVCWRCY82SPGJHJ3GXD02D60YQT7Y7H.web3-fortune-crystals transfer u12 tx-sender TRADER-1)))
		(unwrap-panic (as-contract (contract-call? 'SP19WKA4H1ZVCWRCY82SPGJHJ3GXD02D60YQT7Y7H.web3-fortune-crystals transfer u4 tx-sender TRADER-1)))
		(unwrap-panic (as-contract (contract-call? 'SP7HFEF6RVMEYAFW23GMHBXHPQ17BPKPTF9475Z9.clown-world transfer u27 tx-sender TRADER-1)))
		(unwrap-panic (as-contract (contract-call? 'SP1GWHGESCF29TV10Q6X0VZYWH4QJ6CM9NK6DSH9J.peach-flowers transfer u24 tx-sender TRADER-1)))
		(unwrap-panic (as-contract (contract-call? 'SP229FR0MTFR0PX83YS9P5KEHAFPPKTXPG04RKP7T.afro-sisters transfer u63 tx-sender TRADER-1)))
		(unwrap-panic (as-contract (contract-call? 'SP1G6NBZ22B184MM26QY1DVH657K8KP01GW8RDRM1.citybulls-nft transfer u62 tx-sender TRADER-1)))
		(unwrap-panic (as-contract (contract-call? 'SP162D87CY84QVVCMJKNKGHC7GGXFGA0TAR9D0XJW.melophonic-entertainment transfer u8 tx-sender TRADER-1)))
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
