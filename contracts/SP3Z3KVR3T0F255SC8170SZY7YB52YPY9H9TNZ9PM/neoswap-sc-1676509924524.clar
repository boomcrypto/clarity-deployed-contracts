
;; multiway-swap
;; Contract to facilitate a multiway NFT swap.
;; Each of the parties involved has to call confirm-and-escrow to escrow their dues.
;; Once all parties confirmed, finalize has to be called to redistribute escrowed items.
;; At any point before the swap is finalized it can be canceled by a party involved, 
;; regardles of whether they already called confirm-and-escrow or not.

;; traders
(define-constant TRADER-1 'SP19WKA4H1ZVCWRCY82SPGJHJ3GXD02D60YQT7Y7H)
(define-constant TRADER-2 'SP25VWGTPR19E344S4ENTHQT8651216EPNABRYE51)
(define-constant TRADER-3 'SP27E3TDKYNH3C11RBDFPD5WGR6FV0VN08RKX4D2N)
(define-constant TRADER-4 'SP2TW1D8YF5CE0NDP5VCR5NMTPHQ4PQR1KBB4NQ5Q)
(define-constant TRADER-5 'SPMDGP7AP5JQTDYY83V0Q7JD3CM7YQRXQYWW3E54)
(define-constant TRADER-6 'SPP28QCMZ51GVN9933VFH9TXKQ3XCT4WE5A07533)

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

(define-constant NUM_TRADERS u6)

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

;; private functions
(define-private (deposit-escrow) 
    (begin
	(if (is-eq tx-sender TRADER-1)
            (begin
		(unwrap! (contract-call? 'SP19WKA4H1ZVCWRCY82SPGJHJ3GXD02D60YQT7Y7H.fox-finds-clothes-and-shares transfer u10 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
	    )
            true
        )
	(if (is-eq tx-sender TRADER-2)
            (begin
		(unwrap! (contract-call? 'SP3BS8RXKKAAM7HA76SFDKG4Q2YSG0X8K5K44XNDV.jelly-nft transfer u111 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP3BS8RXKKAAM7HA76SFDKG4Q2YSG0X8K5K44XNDV.jelly-nft transfer u116 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP3EB7YHV5NERS2HMCGSGKNMN0BEH52W9H7YE4T9C.btc-ghosts transfer u158 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP3EB7YHV5NERS2HMCGSGKNMN0BEH52W9H7YE4T9C.btc-ghosts transfer u159 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
	    )
            true
        )
	(if (is-eq tx-sender TRADER-3)
            (begin
		(unwrap! (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.belles-witches transfer u98 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
	    )
            true
        )
	(if (is-eq tx-sender TRADER-4)
            (begin
		(unwrap! (stx-transfer? u2627626 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_STX))
		(unwrap! (contract-call? 'SP3HDKJMJ9DASZBH69A5T5AZDJJWP3KRDSS36G09M.pixanime transfer u10 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SPEW1TZ7EF6EF27P5TD6X21CSGD87P13C6N1W8Z0.stacks-moonbirds transfer u489 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SPEW1TZ7EF6EF27P5TD6X21CSGD87P13C6N1W8Z0.stacks-moonbirds transfer u499 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
	    )
            true
        )
	(if (is-eq tx-sender TRADER-5)
            (begin
		(unwrap! (stx-transfer? u34828092 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_STX))
	    )
            true
        )
	(if (is-eq tx-sender TRADER-6)
            (begin
		(unwrap! (stx-transfer? u15289292 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_STX))
		(unwrap! (contract-call? 'SPEW1TZ7EF6EF27P5TD6X21CSGD87P13C6N1W8Z0.stacks-moonbirds transfer u631 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SPEW1TZ7EF6EF27P5TD6X21CSGD87P13C6N1W8Z0.stacks-moonbirds transfer u639 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SPEW1TZ7EF6EF27P5TD6X21CSGD87P13C6N1W8Z0.stacks-moonbirds transfer u634 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SPP28QCMZ51GVN9933VFH9TXKQ3XCT4WE5A07533.warrior-pigeons transfer u38 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SPEW1TZ7EF6EF27P5TD6X21CSGD87P13C6N1W8Z0.stacks-moonbirds transfer u633 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
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
	(unwrap-panic (as-contract (contract-call? 'SPEW1TZ7EF6EF27P5TD6X21CSGD87P13C6N1W8Z0.stacks-moonbirds transfer u634 tx-sender TRADER-1)))
	(unwrap-panic (as-contract (contract-call? 'SPEW1TZ7EF6EF27P5TD6X21CSGD87P13C6N1W8Z0.stacks-moonbirds transfer u633 tx-sender TRADER-1)))
	(unwrap-panic (as-contract (contract-call? 'SPEW1TZ7EF6EF27P5TD6X21CSGD87P13C6N1W8Z0.stacks-moonbirds transfer u499 tx-sender TRADER-1)))
	(unwrap-panic (as-contract (contract-call? 'SPEW1TZ7EF6EF27P5TD6X21CSGD87P13C6N1W8Z0.stacks-moonbirds transfer u639 tx-sender TRADER-1)))
	(unwrap-panic (as-contract (contract-call? 'SPEW1TZ7EF6EF27P5TD6X21CSGD87P13C6N1W8Z0.stacks-moonbirds transfer u489 tx-sender TRADER-1)))
	(unwrap-panic (as-contract (contract-call? 'SP3BS8RXKKAAM7HA76SFDKG4Q2YSG0X8K5K44XNDV.jelly-nft transfer u111 tx-sender TRADER-4)))
	(unwrap-panic (as-contract (contract-call? 'SP3EB7YHV5NERS2HMCGSGKNMN0BEH52W9H7YE4T9C.btc-ghosts transfer u158 tx-sender TRADER-4)))
	(unwrap-panic (as-contract (contract-call? 'SP3EB7YHV5NERS2HMCGSGKNMN0BEH52W9H7YE4T9C.btc-ghosts transfer u159 tx-sender TRADER-4)))
	(unwrap-panic (as-contract (contract-call? 'SPEW1TZ7EF6EF27P5TD6X21CSGD87P13C6N1W8Z0.stacks-moonbirds transfer u631 tx-sender TRADER-5)))
	(unwrap-panic (as-contract (contract-call? 'SPP28QCMZ51GVN9933VFH9TXKQ3XCT4WE5A07533.warrior-pigeons transfer u38 tx-sender TRADER-5)))
	(unwrap-panic (as-contract (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.belles-witches transfer u98 tx-sender TRADER-6)))
	(unwrap-panic (as-contract (contract-call? 'SP3HDKJMJ9DASZBH69A5T5AZDJJWP3KRDSS36G09M.pixanime transfer u10 tx-sender TRADER-6)))
	(unwrap-panic (as-contract (contract-call? 'SP3BS8RXKKAAM7HA76SFDKG4Q2YSG0X8K5K44XNDV.jelly-nft transfer u116 tx-sender TRADER-6)))
	(unwrap-panic (as-contract (contract-call? 'SP19WKA4H1ZVCWRCY82SPGJHJ3GXD02D60YQT7Y7H.fox-finds-clothes-and-shares transfer u10 tx-sender TRADER-6)))

	(unwrap-panic (as-contract (stx-transfer? u22719274 tx-sender TRADER-1)))
	(unwrap-panic (as-contract (stx-transfer? u6400736 tx-sender RECEIVER-1)))
	(unwrap-panic (as-contract (stx-transfer? u19625000 tx-sender TRADER-2)))
	(unwrap-panic (as-contract (stx-transfer? u4000000 tx-sender TRADER-3)))

        (var-set swapState SWAP_STATE_FINALIZED)
        (ok true)
    )
)

(define-private (return-escrow) 
    (begin 
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-1)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (contract-call? 'SP19WKA4H1ZVCWRCY82SPGJHJ3GXD02D60YQT7Y7H.fox-finds-clothes-and-shares transfer u10 tx-sender TRADER-1)))
	    )
            true
        )
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-1)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (contract-call? 'SP3BS8RXKKAAM7HA76SFDKG4Q2YSG0X8K5K44XNDV.jelly-nft transfer u111 tx-sender TRADER-2)))
		(unwrap-panic (as-contract (contract-call? 'SP3BS8RXKKAAM7HA76SFDKG4Q2YSG0X8K5K44XNDV.jelly-nft transfer u116 tx-sender TRADER-2)))
		(unwrap-panic (as-contract (contract-call? 'SP3EB7YHV5NERS2HMCGSGKNMN0BEH52W9H7YE4T9C.btc-ghosts transfer u158 tx-sender TRADER-2)))
		(unwrap-panic (as-contract (contract-call? 'SP3EB7YHV5NERS2HMCGSGKNMN0BEH52W9H7YE4T9C.btc-ghosts transfer u159 tx-sender TRADER-2)))
	    )
            true
        )
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-1)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.belles-witches transfer u98 tx-sender TRADER-3)))
	    )
            true
        )
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-1)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (stx-transfer? u2627626 tx-sender TRADER-4)))
		(unwrap-panic (as-contract (contract-call? 'SP3HDKJMJ9DASZBH69A5T5AZDJJWP3KRDSS36G09M.pixanime transfer u10 tx-sender TRADER-4)))
		(unwrap-panic (as-contract (contract-call? 'SPEW1TZ7EF6EF27P5TD6X21CSGD87P13C6N1W8Z0.stacks-moonbirds transfer u489 tx-sender TRADER-4)))
		(unwrap-panic (as-contract (contract-call? 'SPEW1TZ7EF6EF27P5TD6X21CSGD87P13C6N1W8Z0.stacks-moonbirds transfer u499 tx-sender TRADER-4)))
	    )
            true
        )
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-1)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (stx-transfer? u34828092 tx-sender TRADER-5)))
	    )
            true
        )
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-1)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (stx-transfer? u15289292 tx-sender TRADER-6)))
		(unwrap-panic (as-contract (contract-call? 'SPEW1TZ7EF6EF27P5TD6X21CSGD87P13C6N1W8Z0.stacks-moonbirds transfer u631 tx-sender TRADER-6)))
		(unwrap-panic (as-contract (contract-call? 'SPEW1TZ7EF6EF27P5TD6X21CSGD87P13C6N1W8Z0.stacks-moonbirds transfer u639 tx-sender TRADER-6)))
		(unwrap-panic (as-contract (contract-call? 'SPEW1TZ7EF6EF27P5TD6X21CSGD87P13C6N1W8Z0.stacks-moonbirds transfer u634 tx-sender TRADER-6)))
		(unwrap-panic (as-contract (contract-call? 'SPP28QCMZ51GVN9933VFH9TXKQ3XCT4WE5A07533.warrior-pigeons transfer u38 tx-sender TRADER-6)))
		(unwrap-panic (as-contract (contract-call? 'SPEW1TZ7EF6EF27P5TD6X21CSGD87P13C6N1W8Z0.stacks-moonbirds transfer u633 tx-sender TRADER-6)))
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
