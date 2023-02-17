
;; multiway-swap
;; Contract to facilitate a multiway NFT swap.
;; Each of the parties involved has to call confirm-and-escrow to escrow their dues.
;; Once all parties confirmed, finalize has to be called to redistribute escrowed items.
;; At any point before the swap is finalized it can be canceled by a party involved, 
;; regardles of whether they already called confirm-and-escrow or not.

;; traders
(define-constant TRADER-1 'SP1DMPD0JNAVDRCTY17S2MNHX8F6502NB0Z25RVR)
(define-constant TRADER-2 'SP1HHSDYJ0SGAM6K2W01ZF5K7AJFKWMJNH365ZWS9)
(define-constant TRADER-3 'SP1JCPNPAMAQJ364AFHPTW3HY7X0HYZ3TJ0ZDGWZH)
(define-constant TRADER-4 'SP1Q6N226KFMA496MVWSB0VZC0T0R9FSKTYYYZ403)
(define-constant TRADER-5 'SP1T07GK9H4M0WP4N1DSSA7NJ7GNTQZ0GBZM0GAR2)
(define-constant TRADER-6 'SP27E3TDKYNH3C11RBDFPD5WGR6FV0VN08RKX4D2N)
(define-constant TRADER-7 'SP2S872HVH23Q1M1VQ6Z55VM11V8Z7YG8V3TZTR96)
(define-constant TRADER-8 'SP2TW1D8YF5CE0NDP5VCR5NMTPHQ4PQR1KBB4NQ5Q)
(define-constant TRADER-9 'SP3C5JYPB8YE5H9WC2SM196RVJ0JXN2GHCWXJWSES)
(define-constant TRADER-10 'SPK9KP81Q281Q84SPGAMK8J12X2AQQJGT0XFPPCX)

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

(define-constant NUM_TRADERS u10)

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

;; private functions
(define-private (deposit-escrow) 
    (begin
	(if (is-eq tx-sender TRADER-1)
            (begin
		(unwrap! (stx-transfer? u60000000 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_STX))
	    )
            true
        )
	(if (is-eq tx-sender TRADER-2)
            (begin
		(unwrap! (stx-transfer? u56000000 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_STX))
	    )
            true
        )
	(if (is-eq tx-sender TRADER-3)
            (begin
		(unwrap! (stx-transfer? u300000000 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_STX))
	    )
            true
        )
	(if (is-eq tx-sender TRADER-4)
            (begin
		(unwrap! (stx-transfer? u50000000 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_STX))
	    )
            true
        )
	(if (is-eq tx-sender TRADER-5)
            (begin
		(unwrap! (stx-transfer? u80000000 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_STX))
	    )
            true
        )
	(if (is-eq tx-sender TRADER-6)
            (begin
		(unwrap! (stx-transfer? u204000000 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_STX))
	    )
            true
        )
	(if (is-eq tx-sender TRADER-7)
            (begin
		(unwrap! (stx-transfer? u52500000 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_STX))
	    )
            true
        )
	(if (is-eq tx-sender TRADER-8)
            (begin
		(unwrap! (stx-transfer? u55000000 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_STX))
	    )
            true
        )
	(if (is-eq tx-sender TRADER-9)
            (begin
		(unwrap! (stx-transfer? u52500000 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_STX))
	    )
            true
        )
	(if (is-eq tx-sender TRADER-10)
            (begin
		(unwrap! (contract-call? 'SPK9KP81Q281Q84SPGAMK8J12X2AQQJGT0XFPPCX.ordinally-people transfer u6 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SPK9KP81Q281Q84SPGAMK8J12X2AQQJGT0XFPPCX.ordinally-people transfer u4 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SPK9KP81Q281Q84SPGAMK8J12X2AQQJGT0XFPPCX.ordinally-people transfer u1 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SPK9KP81Q281Q84SPGAMK8J12X2AQQJGT0XFPPCX.ordinally-people transfer u10 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SPK9KP81Q281Q84SPGAMK8J12X2AQQJGT0XFPPCX.ordinally-people transfer u7 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SPK9KP81Q281Q84SPGAMK8J12X2AQQJGT0XFPPCX.ordinally-people transfer u2 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SPK9KP81Q281Q84SPGAMK8J12X2AQQJGT0XFPPCX.ordinally-people transfer u9 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SPK9KP81Q281Q84SPGAMK8J12X2AQQJGT0XFPPCX.ordinally-people transfer u5 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SPK9KP81Q281Q84SPGAMK8J12X2AQQJGT0XFPPCX.ordinally-people transfer u3 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SPK9KP81Q281Q84SPGAMK8J12X2AQQJGT0XFPPCX.ordinally-people transfer u8 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
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
	(unwrap-panic (as-contract (contract-call? 'SPK9KP81Q281Q84SPGAMK8J12X2AQQJGT0XFPPCX.ordinally-people transfer u6 tx-sender TRADER-1)))
	(unwrap-panic (as-contract (contract-call? 'SPK9KP81Q281Q84SPGAMK8J12X2AQQJGT0XFPPCX.ordinally-people transfer u5 tx-sender TRADER-2)))
	(unwrap-panic (as-contract (contract-call? 'SPK9KP81Q281Q84SPGAMK8J12X2AQQJGT0XFPPCX.ordinally-people transfer u8 tx-sender TRADER-3)))
	(unwrap-panic (as-contract (contract-call? 'SPK9KP81Q281Q84SPGAMK8J12X2AQQJGT0XFPPCX.ordinally-people transfer u3 tx-sender TRADER-3)))
	(unwrap-panic (as-contract (contract-call? 'SPK9KP81Q281Q84SPGAMK8J12X2AQQJGT0XFPPCX.ordinally-people transfer u4 tx-sender TRADER-4)))
	(unwrap-panic (as-contract (contract-call? 'SPK9KP81Q281Q84SPGAMK8J12X2AQQJGT0XFPPCX.ordinally-people transfer u1 tx-sender TRADER-5)))
	(unwrap-panic (as-contract (contract-call? 'SPK9KP81Q281Q84SPGAMK8J12X2AQQJGT0XFPPCX.ordinally-people transfer u10 tx-sender TRADER-6)))
	(unwrap-panic (as-contract (contract-call? 'SPK9KP81Q281Q84SPGAMK8J12X2AQQJGT0XFPPCX.ordinally-people transfer u7 tx-sender TRADER-7)))
	(unwrap-panic (as-contract (contract-call? 'SPK9KP81Q281Q84SPGAMK8J12X2AQQJGT0XFPPCX.ordinally-people transfer u9 tx-sender TRADER-8)))
	(unwrap-panic (as-contract (contract-call? 'SPK9KP81Q281Q84SPGAMK8J12X2AQQJGT0XFPPCX.ordinally-people transfer u2 tx-sender TRADER-9)))

	(unwrap-panic (as-contract (stx-transfer? u40500000 tx-sender RECEIVER-1)))
	(unwrap-panic (as-contract (stx-transfer? u869500000 tx-sender TRADER-10)))

        (var-set swapState SWAP_STATE_FINALIZED)
        (ok true)
    )
)

(define-private (return-escrow) 
    (begin 
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-1)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (stx-transfer? u60000000 tx-sender TRADER-1)))
	    )
            true
        )
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-1)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (stx-transfer? u56000000 tx-sender TRADER-2)))
	    )
            true
        )
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-1)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (stx-transfer? u300000000 tx-sender TRADER-3)))
	    )
            true
        )
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-1)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (stx-transfer? u50000000 tx-sender TRADER-4)))
	    )
            true
        )
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-1)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (stx-transfer? u80000000 tx-sender TRADER-5)))
	    )
            true
        )
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-1)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (stx-transfer? u204000000 tx-sender TRADER-6)))
	    )
            true
        )
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-1)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (stx-transfer? u52500000 tx-sender TRADER-7)))
	    )
            true
        )
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-1)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (stx-transfer? u55000000 tx-sender TRADER-8)))
	    )
            true
        )
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-1)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (stx-transfer? u52500000 tx-sender TRADER-9)))
	    )
            true
        )
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-1)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (contract-call? 'SPK9KP81Q281Q84SPGAMK8J12X2AQQJGT0XFPPCX.ordinally-people transfer u6 tx-sender TRADER-10)))
		(unwrap-panic (as-contract (contract-call? 'SPK9KP81Q281Q84SPGAMK8J12X2AQQJGT0XFPPCX.ordinally-people transfer u4 tx-sender TRADER-10)))
		(unwrap-panic (as-contract (contract-call? 'SPK9KP81Q281Q84SPGAMK8J12X2AQQJGT0XFPPCX.ordinally-people transfer u1 tx-sender TRADER-10)))
		(unwrap-panic (as-contract (contract-call? 'SPK9KP81Q281Q84SPGAMK8J12X2AQQJGT0XFPPCX.ordinally-people transfer u10 tx-sender TRADER-10)))
		(unwrap-panic (as-contract (contract-call? 'SPK9KP81Q281Q84SPGAMK8J12X2AQQJGT0XFPPCX.ordinally-people transfer u7 tx-sender TRADER-10)))
		(unwrap-panic (as-contract (contract-call? 'SPK9KP81Q281Q84SPGAMK8J12X2AQQJGT0XFPPCX.ordinally-people transfer u2 tx-sender TRADER-10)))
		(unwrap-panic (as-contract (contract-call? 'SPK9KP81Q281Q84SPGAMK8J12X2AQQJGT0XFPPCX.ordinally-people transfer u9 tx-sender TRADER-10)))
		(unwrap-panic (as-contract (contract-call? 'SPK9KP81Q281Q84SPGAMK8J12X2AQQJGT0XFPPCX.ordinally-people transfer u5 tx-sender TRADER-10)))
		(unwrap-panic (as-contract (contract-call? 'SPK9KP81Q281Q84SPGAMK8J12X2AQQJGT0XFPPCX.ordinally-people transfer u3 tx-sender TRADER-10)))
		(unwrap-panic (as-contract (contract-call? 'SPK9KP81Q281Q84SPGAMK8J12X2AQQJGT0XFPPCX.ordinally-people transfer u8 tx-sender TRADER-10)))
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
