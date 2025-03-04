;; Offchain-signed oracle prices.
;;
;; TODO: fetch prices from pyth contracts (needs to check freshness)
;; TODO: weighted voting across multiple oracles
;; TODO: optionally smooth prices to discourage oracle manipulation
;; TODO: key rotation

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; errors
(define-constant err-permissions (err u500))
(define-constant err-price       (err u501))
(define-constant err-extraction  (err u502))
(define-constant err-invariants  (err u599))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; permissions
(define-private
  (INTERNAL)
  (begin
   (asserts! (is-eq contract-caller .gl-api) err-permissions)
   (ok true)))

(define-data-var deployer principal tx-sender)
(define-data-var extractor principal tx-sender)

(define-private (DEPLOYER)
  (ok (asserts! (is-eq tx-sender (var-get deployer)) err-permissions)))

(define-public (set-deployer (deployer_ principal))
 (begin
    (try! (DEPLOYER))
    (ok (var-set deployer deployer_))))

(define-public (set-extractor (extractor_ principal))
 (begin
    (try! (DEPLOYER))
    (ok (var-set extractor extractor_))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; state
(define-map prices
  uint ;;block
  uint ;;price
  )

(define-data-var TIMESTAMP uint u0)
(define-data-var DECIMALS uint u8)
(define-data-var FEED-ID (string-ascii 32) "BTC/USD")

(define-public (set-decimals (decimals_ uint))
  (begin
    (try! (DEPLOYER))
    (ok (var-set DECIMALS decimals_))))

(define-public (set-feed-id (feed-id_ (string-ascii 32)))
  (begin
    (try! (DEPLOYER))
    (ok (var-set FEED-ID feed-id_))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; price
(define-read-only (check-slippage (current uint) (desired uint) (slippage uint))
  (if (> current desired)
      (<= (- current desired) slippage)
      (<= (- desired current) slippage)))

(define-read-only (check-price (p uint))
  (> p u0))

(define-private (get-or-set-block-price (current uint))
  (let ((block-price (default-to u0 (map-get? prices stacks-block-height))))
    (if (is-eq block-price u0)
      (begin
        (map-set prices stacks-block-height current)
        current
      )
      block-price)))

(define-public
  (price
    (quote-decimals uint)
    (desired        uint)
    (slippage       uint)
    (ctx            { symbol: (string-ascii 32) }))

      (let ((price0     (try! (extract-price
                                quote-decimals
                                (get symbol ctx))))
            (price1     (get-or-set-block-price price0))
            (acceptable (check-slippage price1 desired slippage))
            (valid      (check-price price1))
            )
      (try! (INTERNAL))
      (asserts! acceptable err-price)
      (asserts! valid      err-price)
      (ok price1) ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-public
  (extract-price
    (qd         uint)
    (symbol     (string-ascii 32))
  )
  (let ((res   (unwrap-panic (contract-call? 'SP1G48FZ4Y7JY8G2Z0N51QTCYGBQ6F4J43J77BQC0.dia-oracle
                                        get-value
                                        symbol)))
        (price0 (get value res))
        (ts     (get timestamp res))
        (newer  (>= ts (var-get TIMESTAMP)))
        (pd     (var-get DECIMALS))
        (s      (>= pd qd))
        (n      (if s (- pd qd) (- qd pd)))
        (m      (pow u10 n))
        (price_ (if s (/ price0 m) (* price0 m)))
        )
    (asserts! newer err-extraction)
    (asserts! (is-eq symbol (var-get FEED-ID)) err-extraction)
    (var-set TIMESTAMP ts)
    (ok price_))
)

;;; eof
