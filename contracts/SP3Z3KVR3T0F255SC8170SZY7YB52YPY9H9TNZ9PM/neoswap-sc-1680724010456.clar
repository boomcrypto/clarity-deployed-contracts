;; multiway-swap
;; Contract to facilitate a multiway NFT swap.
;; Each of the parties involved has to call confirm-and-escrow to escrow their dues.
;; Once all parties confirmed, finalize has to be called to redistribute escrowed items.
;; At any point before the swap is finalized it can be canceled by a party involved, 
;; regardles of whether they already called confirm-and-escrow or not.

;; traders
(define-constant TRADER-1 'SP1Q6N226KFMA496MVWSB0VZC0T0R9FSKTYYYZ403)
(define-constant TRADER-2 'SP27E3TDKYNH3C11RBDFPD5WGR6FV0VN08RKX4D2N)
(define-constant TRADER-3 'SP2TW1D8YF5CE0NDP5VCR5NMTPHQ4PQR1KBB4NQ5Q)
(define-constant TRADER-4 'SP3P4E5DQBJXMQ6MY5CR67G8RT9C5E8D3JK80MMKH)

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

(define-constant NUM_TRADERS u4)

;; data maps and vars
(define-data-var swapState uint SWAP_STATE_ACTIVE)
(define-data-var confirmCount uint u0)

(define-map TraderState principal uint)

;; Set TraderState of each trader to TRADER_STATE_ACTIVE.
(map-set TraderState TRADER-1 TRADER_STATE_ACTIVE)
(map-set TraderState TRADER-2 TRADER_STATE_ACTIVE)
(map-set TraderState TRADER-3 TRADER_STATE_ACTIVE)
(map-set TraderState TRADER-4 TRADER_STATE_ACTIVE)

;; private functions
(define-private (deposit-escrow) 
    (begin
	(if (is-eq tx-sender TRADER-1)
            (begin
		(unwrap! (contract-call? 'SP12RGNJDCZ3AGVA0EM5W37FK46TMVN1859BFZ08K.bitcoin-chicks transfer u1061 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SPJJYJVZ4H7B34GG8D3SSN70WVWDYSHCC9E9ZV4V.bitcoin-toadz transfer u4447 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.dream-daruma transfer u2345 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
	    )
            true
        )
	(if (is-eq tx-sender TRADER-2)
            (begin
		(unwrap! (contract-call? 'SP1QZT85MFT8HBAG3XEK7K6QY4GGP3MSG5C3H9PQ1.bitcoin-bullfrogs-by-mr-wagmi transfer u2 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP1QZT85MFT8HBAG3XEK7K6QY4GGP3MSG5C3H9PQ1.bitcoin-bullfrogs-by-mr-wagmi transfer u410 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SPJJYJVZ4H7B34GG8D3SSN70WVWDYSHCC9E9ZV4V.bitcoin-toadz transfer u1110 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SPJJYJVZ4H7B34GG8D3SSN70WVWDYSHCC9E9ZV4V.bitcoin-toadz transfer u1782 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
	    )
            true
        )
	(if (is-eq tx-sender TRADER-3)
            (begin
		(unwrap! (stx-transfer? u4655000 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_STX))
		(unwrap! (contract-call? 'SP2J4TG4H9KYMTTG267KMR82JDM20WHET6XNR0PWQ.bitcoin-owlz transfer u1534 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP2J4TG4H9KYMTTG267KMR82JDM20WHET6XNR0PWQ.bitcoin-owlz transfer u1536 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SP1QZT85MFT8HBAG3XEK7K6QY4GGP3MSG5C3H9PQ1.bitcoin-bullfrogs-by-mr-wagmi transfer u140 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
		(unwrap! (contract-call? 'SPJJYJVZ4H7B34GG8D3SSN70WVWDYSHCC9E9ZV4V.bitcoin-toadz transfer u5878 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
	    )
            true
        )
	(if (is-eq tx-sender TRADER-4)
            (begin
		(unwrap! (contract-call? 'SP248HH800501WYSG7Z2SS1ZWHQW1GGH85ME34NT2.layer-v2-1 transfer u19661 tx-sender (as-contract tx-sender)) (err ERR_FAILED_TO_ESCROW_NFT))
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
	(unwrap-panic (as-contract (contract-call? 'SP1QZT85MFT8HBAG3XEK7K6QY4GGP3MSG5C3H9PQ1.bitcoin-bullfrogs-by-mr-wagmi transfer u140 tx-sender TRADER-1)))
	(unwrap-panic (as-contract (contract-call? 'SP2J4TG4H9KYMTTG267KMR82JDM20WHET6XNR0PWQ.bitcoin-owlz transfer u1534 tx-sender TRADER-2)))
	(unwrap-panic (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.dream-daruma transfer u2345 tx-sender TRADER-2)))
	(unwrap-panic (as-contract (contract-call? 'SP2J4TG4H9KYMTTG267KMR82JDM20WHET6XNR0PWQ.bitcoin-owlz transfer u1536 tx-sender TRADER-2)))
	(unwrap-panic (as-contract (contract-call? 'SP248HH800501WYSG7Z2SS1ZWHQW1GGH85ME34NT2.layer-v2-1 transfer u19661 tx-sender TRADER-3)))
	(unwrap-panic (as-contract (contract-call? 'SP1QZT85MFT8HBAG3XEK7K6QY4GGP3MSG5C3H9PQ1.bitcoin-bullfrogs-by-mr-wagmi transfer u2 tx-sender TRADER-3)))
	(unwrap-panic (as-contract (contract-call? 'SPJJYJVZ4H7B34GG8D3SSN70WVWDYSHCC9E9ZV4V.bitcoin-toadz transfer u1110 tx-sender TRADER-3)))
	(unwrap-panic (as-contract (contract-call? 'SP1QZT85MFT8HBAG3XEK7K6QY4GGP3MSG5C3H9PQ1.bitcoin-bullfrogs-by-mr-wagmi transfer u410 tx-sender TRADER-3)))
	(unwrap-panic (as-contract (contract-call? 'SPJJYJVZ4H7B34GG8D3SSN70WVWDYSHCC9E9ZV4V.bitcoin-toadz transfer u1782 tx-sender TRADER-3)))
	(unwrap-panic (as-contract (contract-call? 'SP12RGNJDCZ3AGVA0EM5W37FK46TMVN1859BFZ08K.bitcoin-chicks transfer u1061 tx-sender TRADER-3)))
	(unwrap-panic (as-contract (contract-call? 'SPJJYJVZ4H7B34GG8D3SSN70WVWDYSHCC9E9ZV4V.bitcoin-toadz transfer u5878 tx-sender TRADER-4)))
	(unwrap-panic (as-contract (contract-call? 'SPJJYJVZ4H7B34GG8D3SSN70WVWDYSHCC9E9ZV4V.bitcoin-toadz transfer u4447 tx-sender TRADER-4)))

	(unwrap-panic (as-contract (stx-transfer? u252000 tx-sender RECEIVER-1)))
	(unwrap-panic (as-contract (stx-transfer? u3075000 tx-sender TRADER-1)))
	(unwrap-panic (as-contract (stx-transfer? u328000 tx-sender TRADER-2)))
	(unwrap-panic (as-contract (stx-transfer? u1000000 tx-sender TRADER-4)))

        (var-set swapState SWAP_STATE_FINALIZED)
        (ok true)
    )
)

(define-private (return-escrow) 
    (begin 
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-1)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (contract-call? 'SP12RGNJDCZ3AGVA0EM5W37FK46TMVN1859BFZ08K.bitcoin-chicks transfer u1061 tx-sender TRADER-1)))
		(unwrap-panic (as-contract (contract-call? 'SPJJYJVZ4H7B34GG8D3SSN70WVWDYSHCC9E9ZV4V.bitcoin-toadz transfer u4447 tx-sender TRADER-1)))
		(unwrap-panic (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.dream-daruma transfer u2345 tx-sender TRADER-1)))
	    )
            true
        )
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-2)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (contract-call? 'SP1QZT85MFT8HBAG3XEK7K6QY4GGP3MSG5C3H9PQ1.bitcoin-bullfrogs-by-mr-wagmi transfer u2 tx-sender TRADER-2)))
		(unwrap-panic (as-contract (contract-call? 'SP1QZT85MFT8HBAG3XEK7K6QY4GGP3MSG5C3H9PQ1.bitcoin-bullfrogs-by-mr-wagmi transfer u410 tx-sender TRADER-2)))
		(unwrap-panic (as-contract (contract-call? 'SPJJYJVZ4H7B34GG8D3SSN70WVWDYSHCC9E9ZV4V.bitcoin-toadz transfer u1110 tx-sender TRADER-2)))
		(unwrap-panic (as-contract (contract-call? 'SPJJYJVZ4H7B34GG8D3SSN70WVWDYSHCC9E9ZV4V.bitcoin-toadz transfer u1782 tx-sender TRADER-2)))
	    )
            true
        )
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-3)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (stx-transfer? u4655000 tx-sender TRADER-3)))
		(unwrap-panic (as-contract (contract-call? 'SP2J4TG4H9KYMTTG267KMR82JDM20WHET6XNR0PWQ.bitcoin-owlz transfer u1534 tx-sender TRADER-3)))
		(unwrap-panic (as-contract (contract-call? 'SP2J4TG4H9KYMTTG267KMR82JDM20WHET6XNR0PWQ.bitcoin-owlz transfer u1536 tx-sender TRADER-3)))
		(unwrap-panic (as-contract (contract-call? 'SP1QZT85MFT8HBAG3XEK7K6QY4GGP3MSG5C3H9PQ1.bitcoin-bullfrogs-by-mr-wagmi transfer u140 tx-sender TRADER-3)))
		(unwrap-panic (as-contract (contract-call? 'SPJJYJVZ4H7B34GG8D3SSN70WVWDYSHCC9E9ZV4V.bitcoin-toadz transfer u5878 tx-sender TRADER-3)))
	    )
            true
        )
	(if (is-eq (default-to ERR_IS_NOT_TRADER (map-get? TraderState TRADER-4)) TRADER_STATE_CONFIRMED)
            (begin
		(unwrap-panic (as-contract (contract-call? 'SP248HH800501WYSG7Z2SS1ZWHQW1GGH85ME34NT2.layer-v2-1 transfer u19661 tx-sender TRADER-4)))
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
