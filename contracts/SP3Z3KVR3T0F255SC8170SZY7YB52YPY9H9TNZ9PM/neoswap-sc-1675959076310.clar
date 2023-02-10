
;; multiway-swap
;; Contract to facilitate a multiway NFT swap.
;; Each of the parties involved has to call confirm-and-escrow to escrow their dues.
;; Once all parties confirmed, finalize has to be called to redistribute escrowed items.
;; At any point before the swap is finalized it can be canceled by a party involved, 
;; regardles of whether they already called confirm-and-escrow or not.

;; traders
(define-constant TRADER-1 'SP14W78Q821B3HQ3ED30624Z1F13X4JMFZY3N5SK4)
(define-constant TRADER-2 'SP162D87CY84QVVCMJKNKGHC7GGXFGA0TAR9D0XJW)
(define-constant TRADER-3 'SP1HHSDYJ0SGAM6K2W01ZF5K7AJFKWMJNH365ZWS9)
(define-constant TRADER-4 'SP1JQCYDVHKE8RWBJ9JSX8ZH6TVTX0TH2F7D3A8YJ)
(define-constant TRADER-5 'SP27E3TDKYNH3C11RBDFPD5WGR6FV0VN08RKX4D2N)
(define-constant TRADER-6 'SP2TW1D8YF5CE0NDP5VCR5NMTPHQ4PQR1KBB4NQ5Q)
(define-constant TRADER-7 'SP329G766AV8Z01X9EEAHPDQ4WDJXT2A0XB383MGP)
(define-constant TRADER-8 'SP32CF0E78JNPK0HYDTH3CCZ8FN76PFX5W0FYBN20)
(define-constant TRADER-9 'SP3EQ7FQ8TFXB792P7VAGRXER0YNFMGM1Y8RS69RC)
(define-constant TRADER-10 'SP3WBYAEWN0JER1VPBW8TRT1329BGP9RGC5S2519W)
(define-constant TRADER-11 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3)
(define-constant TRADER-12 'SPHK8A7P61C6ASWKYDX1PCDX9YA54DKVJN49EXGJ)

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

(define-constant NUM_TRADERS u12)

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

;; private functions
(define-private (deposit-escrow) 
    (begin
	(if (is-eq tx-sender TRADER-1)
            (begin
		(unwrap! (stx-transfer? u5775000 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_STX))
	    )
            true
        )
	(if (is-eq tx-sender TRADER-2)
            (begin
		(unwrap! (contract-call? 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3.dyle-one transfer u23 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
	    )
            true
        )
	(if (is-eq tx-sender TRADER-3)
            (begin
		(unwrap! (stx-transfer? u26775000 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_STX))
	    )
            true
        )
	(if (is-eq tx-sender TRADER-4)
            (begin
		(unwrap! (stx-transfer? u6930000 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_STX))
	    )
            true
        )
	(if (is-eq tx-sender TRADER-5)
            (begin
		(unwrap! (stx-transfer? u76775000 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_STX))
	    )
            true
        )
	(if (is-eq tx-sender TRADER-6)
            (begin
		(unwrap! (stx-transfer? u35275000 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_STX))
		(unwrap! (contract-call? 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3.game-on transfer u312 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
	    )
            true
        )
	(if (is-eq tx-sender TRADER-7)
            (begin
		(unwrap! (contract-call? 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3.the-smiley-collection transfer u309 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3.dyle-one transfer u54 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3.game-on transfer u377 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
	    )
            true
        )
	(if (is-eq tx-sender TRADER-8)
            (begin
		(unwrap! (stx-transfer? u76510000 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_STX))
	    )
            true
        )
	(if (is-eq tx-sender TRADER-9)
            (begin
		(unwrap! (contract-call? 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3.cx-tokens transfer u289 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
	    )
            true
        )
	(if (is-eq tx-sender TRADER-10)
            (begin
		(unwrap! (stx-transfer? u127198250 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_STX))
		(unwrap! (contract-call? 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3.cx-tokens transfer u266 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
	    )
            true
        )
	(if (is-eq tx-sender TRADER-11)
            (begin
		(unwrap! (contract-call? 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3.cx-tokens transfer u189 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3.xxx transfer u5 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3.xxx transfer u7 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3.cx-tokens transfer u184 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3.xxx transfer u6 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3.game-on transfer u12 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
	    )
            true
        )
	(if (is-eq tx-sender TRADER-12)
            (begin
		(unwrap! (contract-call? 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3.cx-tokens transfer u191 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
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
	(unwrap-panic (as-contract (contract-call? 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3.game-on transfer u377 tx-sender TRADER-1)))
	(unwrap-panic (as-contract (contract-call? 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3.the-smiley-collection transfer u309 tx-sender TRADER-3)))
	(unwrap-panic (as-contract (contract-call? 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3.game-on transfer u12 tx-sender TRADER-4)))
	(unwrap-panic (as-contract (contract-call? 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3.dyle-one transfer u54 tx-sender TRADER-5)))
	(unwrap-panic (as-contract (contract-call? 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3.dyle-one transfer u23 tx-sender TRADER-5)))
	(unwrap-panic (as-contract (contract-call? 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3.cx-tokens transfer u189 tx-sender TRADER-6)))
	(unwrap-panic (as-contract (contract-call? 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3.cx-tokens transfer u184 tx-sender TRADER-6)))
	(unwrap-panic (as-contract (contract-call? 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3.cx-tokens transfer u191 tx-sender TRADER-6)))
	(unwrap-panic (as-contract (contract-call? 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3.game-on transfer u312 tx-sender TRADER-7)))
	(unwrap-panic (as-contract (contract-call? 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3.cx-tokens transfer u289 tx-sender TRADER-8)))
	(unwrap-panic (as-contract (contract-call? 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3.cx-tokens transfer u266 tx-sender TRADER-8)))
	(unwrap-panic (as-contract (contract-call? 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3.xxx transfer u5 tx-sender TRADER-10)))
	(unwrap-panic (as-contract (contract-call? 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3.xxx transfer u6 tx-sender TRADER-10)))
	(unwrap-panic (as-contract (contract-call? 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3.xxx transfer u7 tx-sender TRADER-10)))

	(unwrap-panic (as-contract (stx-transfer? u50000000 tx-sender TRADER-2)))
	(unwrap-panic (as-contract (stx-transfer? u38836500 tx-sender RECEIVER-1)))
	(unwrap-panic (as-contract (stx-transfer? u11675000 tx-sender TRADER-7)))
	(unwrap-panic (as-contract (stx-transfer? u22325000 tx-sender TRADER-9)))
	(unwrap-panic (as-contract (stx-transfer? u200226750 tx-sender TRADER-11)))
	(unwrap-panic (as-contract (stx-transfer? u32175000 tx-sender TRADER-12)))

        (var-set swapState SWAP_STATE_FINALIZED)
        (ok true)
    )
)

(define-private (return-escrow) 
    (begin 
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-1)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (stx-transfer? u5775000 tx-sender TRADER-1)))
	    )
            true
        )
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-1)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (contract-call? 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3.dyle-one transfer u23 tx-sender TRADER-2)))
	    )
            true
        )
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-1)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (stx-transfer? u26775000 tx-sender TRADER-3)))
	    )
            true
        )
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-1)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (stx-transfer? u6930000 tx-sender TRADER-4)))
	    )
            true
        )
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-1)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (stx-transfer? u76775000 tx-sender TRADER-5)))
	    )
            true
        )
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-1)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (stx-transfer? u35275000 tx-sender TRADER-6)))
		(unwrap-panic (as-contract (contract-call? 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3.game-on transfer u312 tx-sender TRADER-6)))
	    )
            true
        )
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-1)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (contract-call? 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3.the-smiley-collection transfer u309 tx-sender TRADER-7)))
		(unwrap-panic (as-contract (contract-call? 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3.dyle-one transfer u54 tx-sender TRADER-7)))
		(unwrap-panic (as-contract (contract-call? 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3.game-on transfer u377 tx-sender TRADER-7)))
	    )
            true
        )
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-1)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (stx-transfer? u76510000 tx-sender TRADER-8)))
	    )
            true
        )
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-1)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (contract-call? 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3.cx-tokens transfer u289 tx-sender TRADER-9)))
	    )
            true
        )
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-1)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (stx-transfer? u127198250 tx-sender TRADER-10)))
		(unwrap-panic (as-contract (contract-call? 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3.cx-tokens transfer u266 tx-sender TRADER-10)))
	    )
            true
        )
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-1)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (contract-call? 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3.cx-tokens transfer u189 tx-sender TRADER-11)))
		(unwrap-panic (as-contract (contract-call? 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3.xxx transfer u5 tx-sender TRADER-11)))
		(unwrap-panic (as-contract (contract-call? 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3.xxx transfer u7 tx-sender TRADER-11)))
		(unwrap-panic (as-contract (contract-call? 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3.cx-tokens transfer u184 tx-sender TRADER-11)))
		(unwrap-panic (as-contract (contract-call? 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3.xxx transfer u6 tx-sender TRADER-11)))
		(unwrap-panic (as-contract (contract-call? 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3.game-on transfer u12 tx-sender TRADER-11)))
	    )
            true
        )
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-1)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (contract-call? 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3.cx-tokens transfer u191 tx-sender TRADER-12)))
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
