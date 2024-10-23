(define-constant ERR-OUT-OF-BOUNDS u4) ;; (err u1) -- sender does not have enough balance to transfer (err u2) -- sender and recipient are the same principal (err u3) -- amount to send is non-positive
(define-constant ERR_TX_VALUE_TOO_SMALL (err u5))
(define-constant ERR_TX_NOT_FOR_RECEIVER (err u6))
(define-constant ERR_ALREADY_DONE (err u7))
(define-constant ERR_NO_STX_RECEIVER (err u8))
(define-constant ERR_BTC_TX_ALREADY_USED (err u9)) ;; this needs to be used to prevent double claiming?
(define-constant ERR_IN_COOLDOWN (err u10))
(define-constant ERR_ALREADY_RESERVED (err u11))
(define-constant ERR_INVALID_STX_SENDER (err u12))
(define-constant ERR_INVALID_ID (err u13))
(define-constant ERR_FORBIDDEN (err u14))
(define-constant ERR_NOT_PRICED (err u15))
(define-constant ERR_NO_BTC_RECEIVER (err u16)) ;; this
(define-constant ERR_NO_SUCH_OFFER (err u17))
(define-constant ERR_USTX (err u18))
(define-constant ERR_SATS (err u19))
(define-constant ERR_PREMIUM (err u20))
(define-constant ERR_INVALID_STX_RECEIVER (err u22))
(define-constant ERR_OFFER_ALREADY_EXISTS (err u23)) ;; one offer at a time
(define-constant ERR_INVALID_OFFER (err u24))
(define-constant ERR_PROOF_FALSE (err u25))
(define-constant ERR_RESERVATION_EXPIRED (err u26))
(define-constant ERR_NOT_RESERVED (err u27))
(define-constant ERR_SAME_SENDER_RECEIVER (err u28))
(define-constant ERR_NATIVE_FAILURE (err u99)) ;; this is not necessary?
(define-constant nexus (as-contract tx-sender))
(define-constant expiry u100)
(define-constant cooldown u6)

(define-map swaps uint {sats: (optional uint), btc-receiver: (optional (buff 40)), stx-sender: principal, ustx: uint, stx-receiver: (optional principal), when: uint, expired-height: (optional uint), done: bool, premium: (optional uint), ask-priced: bool})
(define-map swap-offers {stx-receiver: principal, swap-id: (optional uint)} ;; allows a stx-receiver to do an offer per swap-id and 1 without swap-id
  {stx-sender: (optional principal), ustx: uint, sats: uint, premium: uint})
;; (define-map submitted-btc-txs (buff 128) uint)  ;; map between accepted btc txs and swap ids

(define-data-var next-id uint u0)

(define-read-only (read-uint32 (ctx { txbuff: (buff 4096), index: uint}))
		(let ((data (get txbuff ctx))
					(base (get index ctx)))
				(ok {uint32: (buff-to-uint-le (unwrap-panic (as-max-len? (unwrap! (slice? data base (+ base u4)) (err ERR-OUT-OF-BOUNDS)) u4))),
						 ctx: { txbuff: data, index: (+ u4 base)}})))

(define-private (find-out (entry {scriptPubKey: (buff 128), value: (buff 8)}) (result {pubscriptkey: (buff 40), out: (optional {scriptPubKey: (buff 128), value: uint})}))
  (if (is-eq (get scriptPubKey entry) (get pubscriptkey result))
    (merge result {out: (some {scriptPubKey: (get scriptPubKey entry), value: (get uint32 (unwrap-panic (read-uint32 {txbuff: (get value entry), index: u0})))})})
    result))

(define-public (get-out-value (tx {
    version: (buff 4),
    ins: (list 8
      {outpoint: {hash: (buff 32), index: (buff 4)}, scriptSig: (buff 256), sequence: (buff 4)}),
    outs: (list 8
      {value: (buff 8), scriptPubKey: (buff 128)}),
    locktime: (buff 4)}) (pubscriptkey (buff 40)))
    (ok (fold find-out (get outs tx) {pubscriptkey: pubscriptkey, out: none})))

(define-public (collateralize-stx (ustx uint) (btc-receiver (optional (buff 40))))
  (let ((id (var-get next-id)))
    (print 
      {
        type: "collateralize-stx",
        id: id,
        ustx: ustx,
        stxSender: tx-sender,
        btcReceiver: btc-receiver,
        done: false,
        askPriced: false,
        sats: none,
        premium: none,
        stxReceiver: none,
        when: burn-block-height,
        fees: "zero",
      }
    )
    (asserts! (map-insert swaps id
      {sats: none, btc-receiver: btc-receiver, ustx: ustx, stx-receiver: none,
        stx-sender: tx-sender, when: burn-block-height, expired-height: none, done: false, premium: none, ask-priced: false}) ERR_INVALID_ID)
    (var-set next-id (+ id u1))
    (match (stx-transfer? ustx tx-sender (as-contract tx-sender)) ;; memo?
      success (ok id)
      error (err (* error u1000)))))

(define-public (make-ask (id uint) (sats uint) (btc-receiver (buff 40)) (stx-receiver (optional principal)) (premium uint))
  (let ((swap (unwrap! (map-get? swaps id) ERR_INVALID_ID)))
    (asserts! (is-eq tx-sender (get stx-sender swap)) ERR_INVALID_STX_SENDER)
    (asserts! (not (get done swap)) ERR_ALREADY_DONE)
    (match (get expired-height swap)
            some-height (asserts! (>= burn-block-height some-height) ERR_ALREADY_RESERVED) 
            true) ;; no cool down so make sure ulterior func cool down
    (print 
      {
        type: "make-ask",
        id: id,
        sats: (some sats),
        btcReceiver: (some btc-receiver),
        stxReceiver: stx-receiver,
        premium: (some premium),
        askPriced: true,
      }
    )
    (ok (map-set swaps id (merge swap {
      sats: (some sats), 
      btc-receiver: (some btc-receiver), 
      stx-receiver: stx-receiver,
      premium: (some premium), 
      ask-priced: true})))))

(define-public (collateralize-and-make-ask
  (ustx uint) 
  (btc-receiver (buff 40)) 
  (sats uint)
  (stx-receiver (optional principal))
  (premium uint))
  (let 
    ((swap-id (try! (collateralize-stx ustx (some btc-receiver)))))
    (try! (make-ask swap-id sats btc-receiver stx-receiver premium))
    (print   
      {
        type: "collateralize-and-make-ask",
        id: swap-id,
        ustx: ustx,
        stxSender: tx-sender,
        done: false,
        when: burn-block-height,
        fees: "zero",
        sats: (some sats),
        btcReceiver: (some btc-receiver),
        stxReceiver: stx-receiver,
        premium: (some premium),
        askPriced: true,
      }
    )
    (ok swap-id)))

(define-public (take-ask (id uint)) ;; BTC sender accepts the initial offer of STX sender
  (let ((swap (unwrap! (map-get? swaps id) ERR_INVALID_ID))
    (premium (unwrap! (get premium swap) ERR_PREMIUM))
    (stx-receiver (default-to tx-sender (get stx-receiver swap))))
    (asserts! (is-eq tx-sender stx-receiver) ERR_INVALID_STX_RECEIVER)
    (asserts! (get ask-priced swap) ERR_NOT_PRICED)
    (asserts! (not (is-eq tx-sender (get stx-sender swap))) ERR_SAME_SENDER_RECEIVER) 
    (asserts! (not (get done swap)) ERR_ALREADY_DONE)
    (match (get expired-height swap)
            some-height (asserts! (>= burn-block-height some-height) ERR_ALREADY_RESERVED) 
            true)
    (print 
      {
        type: "take-ask",
        id: id,
        stxReceiver: (some tx-sender),
        expiredHeight: (some (+ burn-block-height expiry)),
        when: burn-block-height,
      }
    )
    (and (> premium u0) (try! (contract-call? .usda-token transfer premium tx-sender (get stx-sender swap) (some 0x707265746D69756D))))
    (ok (map-set swaps id (merge swap {stx-receiver: (some tx-sender), expired-height: (some (+ burn-block-height expiry)), when: burn-block-height}))))) ;; expiration kicks in

(define-public (make-bid
  (id (optional uint))
  (stx-sender (optional principal))
  (ustx (optional uint))
  (sats uint)
  (premium uint)) ;; allowing the BTC sender to initiate swap offers - without a swap-id
  (begin
    (asserts! (is-none (get-bid tx-sender id)) ERR_OFFER_ALREADY_EXISTS)
    (asserts! (> sats u0) ERR_INVALID_OFFER)
    (match id
      some-id 
        (let ((swap (unwrap! (map-get? swaps some-id) ERR_INVALID_ID))
              (swap-ustx  (get ustx swap)))
          (asserts! (not (get done swap)) ERR_ALREADY_DONE) ;; ability to make a bid even when the swap is reserved
          (and (> premium u0) (try! (contract-call? .usda-token transfer premium tx-sender nexus (some 0x707265746D69756D))))
          (print 
            {
              type: "make-bid",
              id: id,
              stxReceiver: tx-sender,
              stxSender: stx-sender,
              ustx: swap-ustx,
              sats: sats,
              premium: premium,
            }
          )
          (ok (map-set swap-offers 
            { stx-receiver: tx-sender, swap-id: (some some-id) }
            { stx-sender: (some (get stx-sender swap)),
              ustx: swap-ustx,
              sats: sats,
              premium: premium })))
      (begin
        (asserts! (and (is-some ustx) (> (unwrap-panic ustx) u0)) ERR_INVALID_OFFER)
        (and (> premium u0) (try! (contract-call? .usda-token transfer premium tx-sender nexus (some 0x707265746D69756D))))
        (print 
          {
            type: "make-bid",
            id: none,
            stxReceiver: tx-sender,
            stxSender: stx-sender,
            ustx: (unwrap-panic ustx),
            sats: sats,
            premium: premium,
          }
        )
        (ok (map-set swap-offers 
          { stx-receiver: tx-sender, swap-id: none }
          { stx-sender: stx-sender,
            ustx: (unwrap-panic ustx),
            sats: sats,
            premium: premium }))))))

(define-public (take-bid (id uint) (offer-swap-id (optional uint)) (sats uint) (premium uint) (stx-receiver principal))
  (let ((swap (unwrap! (map-get? swaps id) ERR_INVALID_ID))
        (offer (unwrap! (get-bid stx-receiver offer-swap-id) ERR_NO_SUCH_OFFER))
        (premium-offer (get premium offer))
        (sats-offer (get sats offer))
        (offer-stx-sender (default-to tx-sender (get stx-sender offer))))
    (asserts! (is-eq tx-sender (get stx-sender swap)) ERR_INVALID_STX_SENDER)
    (asserts! (is-eq tx-sender offer-stx-sender) ERR_INVALID_STX_SENDER) ;; important (not redundant and by transitivity...)
    (asserts! (not (is-eq tx-sender stx-receiver)) ERR_SAME_SENDER_RECEIVER) ;; Corrected: bid taker cannot be bid creator
    (asserts! (is-eq (get ustx offer) (get ustx swap)) ERR_USTX)
    (asserts! (is-eq sats-offer sats) ERR_SATS) ;; user agrees to sats-offer
    (asserts! (is-eq premium-offer premium) ERR_PREMIUM) ;; user agrees to premium offer (not the swap)
    (asserts! (not (get done swap)) ERR_ALREADY_DONE)
    (match (get expired-height swap)
            some-height (asserts! (>= burn-block-height some-height) ERR_ALREADY_RESERVED) 
            true) ;; taking bid forbidden before expiration
    (and (> premium u0) (try! (as-contract (contract-call? .usda-token transfer premium tx-sender (get stx-sender swap) (some 0x707265746D69756D))))) ;; nexus releases premium
    (map-delete swap-offers {stx-receiver: stx-receiver, swap-id: offer-swap-id })
    (print 
      {
        type: "take-bid",
        id: id,
        stxReceiver: (some stx-receiver),
        expiredHeight: (some (+ burn-block-height expiry)),
        sats: (some sats),
        premium: (some premium),
        when: burn-block-height,
      }
    )
    (ok (map-set swaps id (merge swap {
      stx-receiver: (some stx-receiver),
      expired-height: (some (+ burn-block-height expiry)),
      sats: (some sats),
      premium: (some premium),
      when: burn-block-height 
    }))))) ;; expiration kicks in

(define-public (cancel-bid (offer-swap-id (optional uint)))
  (let ((offer (unwrap! (get-bid tx-sender offer-swap-id) ERR_NO_SUCH_OFFER))
        (premium (get premium offer))
        (offerer tx-sender))
    (and (> premium u0) (as-contract (try! (contract-call? .usda-token transfer premium tx-sender offerer (some 0x707265746D69756D)))))
    (map-delete swap-offers {stx-receiver: tx-sender, swap-id: offer-swap-id })
    (print
      {
        type: "cancel-bid",
        swapId: offer-swap-id,
        stxReceiver: tx-sender,
      }
    )
    (ok true)))

(define-public (cancel-ask (id uint))
  (let ((swap (unwrap! (map-get? swaps id) ERR_INVALID_ID)))
    (asserts! (is-eq tx-sender (get stx-sender swap)) ERR_INVALID_STX_SENDER)
    (match (get expired-height swap)
            some-height (asserts! (>= burn-block-height some-height) ERR_ALREADY_RESERVED) 
            true) 
    (asserts! (not (get done swap)) ERR_ALREADY_DONE)
    (print 
      {
        type: "cancel-ask",
        id: id,
        askPriced: false,
      }
    )
    (ok (map-set swaps id (merge swap {
      ask-priced: false
    })))))

(define-public (claim-collateral (id uint))
  (let ((swap (unwrap! (map-get? swaps id) ERR_INVALID_ID))
        (stx-sender (get stx-sender swap)))
    (asserts! (is-eq tx-sender stx-sender) ERR_INVALID_STX_SENDER)
    (match (get expired-height swap)
            some-height (asserts! (>= burn-block-height some-height) ERR_ALREADY_RESERVED) ;; expired
            true) ;; or not reserved 
    (asserts! (not (get done swap)) ERR_ALREADY_DONE)   
    (try! (as-contract (stx-transfer? (get ustx swap) tx-sender stx-sender)))
    (print 
      {
        type: "claim-collateral",
        id: id,
        done: true,
      }
    )
    (ok (map-set swaps id (merge swap {done: true}))))
)

;; (define-public (submit-swap 
;;     (id uint)
;;     (height uint)
;;     (blockheader (buff 32))
;;     (tx {version: (buff 4),
;;       ins: (list 8
;;         {outpoint: {hash: (buff 32), index: (buff 4)}, scriptSig: (buff 256), sequence: (buff 4)}),
;;       outs: (list 8
;;         {value: (buff 8), scriptPubKey: (buff 128)}),
;;       locktime: (buff 4)}) 
;;     (proof { tx-index: uint, hashes: (list 12 (buff 32)), tree-depth: uint })
;;     (fees <fees-trait>)) ;; any user can submit a tx that contains the swap
;;   (let ((swap (unwrap! (map-get? swaps id) ERR_INVALID_ID))
;;         (tx-buff (contract-call? 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.clarity-bitcoin-helper concat-tx tx))
;;         (stx-receiver (unwrap! (get stx-receiver swap) ERR_NO_STX_RECEIVER))
;;         (btc-receiver (unwrap! (get btc-receiver swap) ERR_NO_BTC_RECEIVER)))
;;       (asserts! (> burn-block-height (+ (get when swap) cooldown)) ERR_IN_COOLDOWN)
;;       (match (get expired-height swap)
;;               some-height (asserts! (< burn-block-height some-height) ERR_RESERVATION_EXPIRED) ;; not expired
;;               (asserts! false ERR_NOT_RESERVED)) ;; needs to be reserved
;;       (asserts! (is-eq tx-sender stx-receiver) ERR_INVALID_STX_RECEIVER)     
;;       (asserts! (is-eq fees .zero) ERR_INVALID_FEE_CONTRACT)
;;       (asserts! (not (get done swap)) ERR_ALREADY_DONE)
;;       (try! (contract-call? fees pay-fees (get ustx swap)))
;;       (match (contract-call? 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.clarity-bitcoin-lib-v5 was-tx-mined-compact
;;                 height tx-buff blockheader proof )
;;         result
;;           (let
;;             (
;;               ;; (result-is-true (asserts! result ERR_PROOF_FALSE))
;;               (sats (unwrap! (get sats swap) ERR_NOT_PRICED))
              
;;               )
;;             (asserts! (is-none (map-get? submitted-btc-txs result)) ERR_BTC_TX_ALREADY_USED)
;;             (match (get out (unwrap! (get-out-value tx btc-receiver) ERR_NATIVE_FAILURE))
;;               out (if (>= (get value out) sats)
;;                 (begin
;;                       (map-set swaps id (merge swap {done: true}))
;;                       (map-set submitted-btc-txs result id)
;;                       (as-contract (stx-transfer? (get ustx swap) tx-sender (unwrap! (get stx-receiver swap) ERR_NO_STX_RECEIVER))))
;;                 ERR_TX_VALUE_TOO_SMALL)
;;             ERR_TX_NOT_FOR_RECEIVER))
;;         error (err (* error u1000)))))

;; (define-public (submit-swap-segwit
;;     (id uint)
;;     (height uint)
;;     (wtx {version: (buff 4),
;;       ins: (list 8
;;         {outpoint: {hash: (buff 32), index: (buff 4)}, scriptSig: (buff 256), sequence: (buff 4)}),
;;       outs: (list 8
;;         {value: (buff 8), scriptPubKey: (buff 128)}),
;;       locktime: (buff 4)})
;;     (witness-data (buff 1650))
;;     (header (buff 80))
;;     (tx-index uint)
;;     (tree-depth uint)
;;     (wproof (list 14 (buff 32)))
;;     (witness-merkle-root (buff 32))
;;     (witness-reserved-value (buff 32))
;;     (ctx (buff 1024))
;;     (cproof (list 14 (buff 32)))
;;     (fees <fees-trait>))
;;   (let ((swap (unwrap! (map-get? swaps id) ERR_INVALID_ID))
;;         (stx-receiver (unwrap! (get stx-receiver swap) ERR_NO_STX_RECEIVER))
;;         (btc-receiver (unwrap! (get btc-receiver swap) ERR_NO_BTC_RECEIVER))
;;         (sats (unwrap! (get sats swap) ERR_NOT_PRICED))
;;         (tx-buff (contract-call? .clarity-bitcoin-helper-wtx concat-wtx wtx witness-data)))
;;       (asserts! (> burn-block-height (+ (get when swap) cooldown)) ERR_IN_COOLDOWN) 
;;       (asserts! (is-eq tx-sender stx-receiver) ERR_INVALID_STX_RECEIVER)
;;       (asserts! (not (get done swap)) ERR_ALREADY_DONE)
;;       (match (get expired-height swap)
;;               some-height (asserts! (< burn-block-height some-height) ERR_RESERVATION_EXPIRED) ;; not expired
;;               (asserts! false ERR_NOT_RESERVED)) ;; needs to be reserved
;;       (asserts! (is-eq fees .zero) ERR_INVALID_FEE_CONTRACT)
;;       (try! (contract-call? fees pay-fees (get ustx swap)))
;;       (match (contract-call? 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.clarity-bitcoin-lib-v5 was-segwit-tx-mined-compact
;;                 height tx-buff header tx-index tree-depth wproof witness-merkle-root witness-reserved-value ctx cproof )
;;         result
;;           (begin
;;             ;; (asserts! result ERR_PROOF_FALSE)
;;             (asserts! (is-none (map-get? submitted-btc-txs result)) ERR_BTC_TX_ALREADY_USED)
;;             (match (get out (unwrap! (get-out-value wtx btc-receiver) ERR_NATIVE_FAILURE))
;;               out (if (>= (get value out) sats)
;;                 (begin
;;                       (map-set swaps id (merge swap {done: true}))
;;                       (map-set submitted-btc-txs result id)
;;                       (as-contract (stx-transfer? (get ustx swap) tx-sender (unwrap! (get stx-receiver swap) ERR_NO_STX_RECEIVER))))
;;                 ERR_TX_VALUE_TOO_SMALL)
;;             ERR_TX_NOT_FOR_RECEIVER))
;;         error (err (* error u1000)))))

(define-read-only (get-swap (id uint)) ;; read-only function to get swap details by id
  (match (map-get? swaps id)
    swap (ok swap)
    (err ERR_INVALID_ID)))

(define-read-only (get-bid (stx-receiver principal) (id (optional uint)))
  (map-get? swap-offers {stx-receiver: stx-receiver, swap-id: id}))

  (define-public (simulate-swap
    (id uint))
  (let ((swap (unwrap! (map-get? swaps id) ERR_INVALID_ID))
        (stx-sender (get stx-sender swap))
        (stx-receiver (unwrap! (get stx-receiver swap) ERR_NO_STX_RECEIVER))
        (btc-receiver (unwrap! (get btc-receiver swap) ERR_NO_BTC_RECEIVER))
        (sats (unwrap! (get sats swap) ERR_NOT_PRICED)))
      (asserts! (> burn-block-height (+ (get when swap) cooldown)) ERR_IN_COOLDOWN) 
      (asserts! (is-eq tx-sender stx-receiver) ERR_INVALID_STX_RECEIVER)
      (asserts! (not (get done swap)) ERR_ALREADY_DONE)
      (match (get expired-height swap)
              some-height (asserts! (< burn-block-height some-height) ERR_RESERVATION_EXPIRED) ;; not expired
              (asserts! false ERR_NOT_RESERVED)) ;; needs to be reserved
      (print 
        {
          type: "simulate-swap",
          id: id,
          done: true,
        }
      )
      (match (contract-call? .sbtc transfer sats tx-sender stx-sender (some 0x707265746D69756D))
        result
                (begin
                      (map-set swaps id (merge swap {done: true}))  
                      (as-contract (stx-transfer? (get ustx swap) tx-sender (unwrap! (get stx-receiver swap) ERR_NO_STX_RECEIVER))))
        error (err (* error u1000)))))