(impl-trait .oracle-trait-vpv-15.oracle-trait)
(use-trait registry-trait .registry-trait-vpv-15.registry-trait)

(define-constant ERR_NO_ORACLE_PRICE (err u700))
(define-constant ERR_STALE_ORACLE_PRICE (err u701))
(define-constant ERR_PRICE_OUT_OF_RANGE (err u702))
(define-constant ERR_INVALID_FEED_ID (err u703))
(define-constant ERR_INVALID_PRICE_EXPO (err u704))

(define-constant ONE-8 u100000000)

(define-constant default-price (to-int (* u70000 ONE-8)))
(define-constant default-conf (* u50 ONE-8))


(define-constant PYTH_BTC_PRICE_FEED_ID 0xe62df6c8b4a85fe1a67db44dc12de5db330f7ac66b72dc658afedf0f4a415b43)
(define-constant EXPECTED_BTC_PRICE_EXPO -8)


;; Using local prices here instead of going to storage contract
(define-map prices (buff 32) {
  price: int,
  conf: uint,
  expo: int,
  ema-price: int,
  ema-conf: uint,
  publish-time: uint,
  prev-publish-time: uint,
  price-identifier: (buff 32)
})

(define-public (set-price (price int) (conf uint) (expo int))
  (let
    (
	  (current-block-timestamp (unwrap-panic (get-stacks-block-info? time (- stacks-block-height u1))))	
	  (token-info (unwrap-panic (map-get? prices PYTH_BTC_PRICE_FEED_ID)))
	  (prev-publish-time (get publish-time token-info))
	)
	(map-set prices
	  PYTH_BTC_PRICE_FEED_ID
	  {
		price: price,
		conf: conf,
		expo: expo,
		ema-price: price,
		ema-conf: conf,
		publish-time: current-block-timestamp,
		prev-publish-time: prev-publish-time,
		price-identifier: PYTH_BTC_PRICE_FEED_ID
	  }
	)
	(ok true)
  )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; oracle-trait BEGIN
;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-public (get-price (price-feed-bytes (optional (buff 8192))) (registry <registry-trait>))
    (let 
        (
            (valid-registry (try! (contract-call? .controller-vpv-15 check-approved-contract "registry" (contract-of registry))))
			(oracle-stale-threshold-seconds (try! (contract-call? registry get-oracle-stale-threshold-seconds)))
			(oracle-allowable-price-deviation (try! (contract-call? registry get-oracle-allowable-price-deviation)))
			(stored-price-info (unwrap-panic (get-and-verify-stored-price oracle-stale-threshold-seconds oracle-allowable-price-deviation)))
        )

		(if (get valid stored-price-info)
			(begin
				(print
					{
						price-info:
							{
								price-identifier: (get price-identifier (get pyth-record stored-price-info)),
								price: (get price stored-price-info),
								publish-time: (get publish-time (get pyth-record stored-price-info)),
								using-stored: true
							}
					}
				)
				(ok (get price stored-price-info))
			)
			(let 
				(
					(decoded-price-info (unwrap-panic (verify-and-update-given-price price-feed-bytes oracle-stale-threshold-seconds oracle-allowable-price-deviation)))
				)
				(if (get valid decoded-price-info)
					(begin
						(print
							{
								price-info:
									{
										price-identifier: (get price-identifier (get pyth-record decoded-price-info)),
										price: (get price decoded-price-info),
										publish-time: (get publish-time (get pyth-record decoded-price-info)),
										using-stored: false
									}
							}
						)
						(ok (get price decoded-price-info))
					)
					(err (get err decoded-price-info))
				)
			)
		)
    )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; oracle-trait END
;;;;;;;;;;;;;;;;;;;;;;;;;;;


(define-read-only (get-and-verify-stored-price (oracle-stale-threshold-seconds uint) (oracle-allowable-price-deviation uint))
  (let 
    (
	  (pyth-record (unwrap! (map-get? prices PYTH_BTC_PRICE_FEED_ID) ERR_NO_ORACLE_PRICE))	
	  (decoded-price (decode-and-verify-price (merge pyth-record {price-identifier: PYTH_BTC_PRICE_FEED_ID}) oracle-stale-threshold-seconds oracle-allowable-price-deviation))
    )
	(match decoded-price
      ok-value (ok { valid: true, price: ok-value, pyth-record: pyth-record, err: u0 })
      err-value (ok { valid: false, price: u0, pyth-record: pyth-record, err: err-value })
    )
  )
)

(define-public (verify-and-update-given-price (price-feed-bytes (optional (buff 8192))) (oracle-stale-threshold-seconds uint) (oracle-allowable-price-deviation uint))
  (let 
    (
		(pyth-record-stale (unwrap! (map-get? prices PYTH_BTC_PRICE_FEED_ID) ERR_NO_ORACLE_PRICE))
		(pyth-record (merge pyth-record-stale {publish-time: (unwrap-panic (get-stacks-block-info? time (- stacks-block-height u1)))}))
		(decoded-price (decode-and-verify-price pyth-record oracle-stale-threshold-seconds oracle-allowable-price-deviation))
    )
	(match decoded-price
      ok-value (ok { valid: true, price: ok-value, pyth-record: pyth-record, err: u0 })
      err-value (ok { valid: false, price: u0, pyth-record: pyth-record, err: err-value })
    )
  )
)

(define-private (decode-and-verify-price (pyth-record 
  {conf: uint, ema-conf: uint, ema-price: int, expo: int, prev-publish-time: uint, price: int, price-identifier: (buff 32), publish-time: uint}
) (oracle-stale-threshold-seconds uint) (oracle-allowable-price-deviation uint)) 
  (let 
    (
	  (feed-id (get price-identifier pyth-record))
      (publish-time (get publish-time pyth-record))
      (exponent (get expo pyth-record))
	  (expected-exponent (asserts! (is-eq exponent EXPECTED_BTC_PRICE_EXPO) ERR_INVALID_PRICE_EXPO))
      (price (convert-to-fixed-8 (get price pyth-record) exponent))
      (price-conf (convert-to-fixed-8 (to-int (get conf pyth-record)) exponent))
    )
	(asserts! (is-eq feed-id PYTH_BTC_PRICE_FEED_ID) ERR_INVALID_FEED_ID)
    (try! (is-current publish-time oracle-stale-threshold-seconds))
    (try! (check-confidence price price-conf oracle-allowable-price-deviation))
    (ok price)
))

(define-private (check-confidence (price uint) (conf uint) (oracle-allowable-price-deviation uint))
  (begin
	(asserts! (and (> price u0) (< (div conf price) oracle-allowable-price-deviation)) ERR_PRICE_OUT_OF_RANGE)
	(ok true)
  )
)

(define-private (is-current (publish-time uint) (oracle-stale-threshold-seconds uint))
  (let 
    (
	  (current-stacks-block-ts-seconds (unwrap-panic (get-stacks-block-info? time (- stacks-block-height u1))))
	)
  	(asserts! (>= (+ publish-time oracle-stale-threshold-seconds) current-stacks-block-ts-seconds) ERR_STALE_ORACLE_PRICE)
	(ok true)
  )
)

;; if the integer represenation is 10^expo, convert to 8 decimal places
(define-read-only (convert-to-fixed-8 (price int) (expo int))
    (to-uint (* price (pow 10 (+ expo 8)))))

(define-read-only (div (x uint) (y uint))
  (/ (+ (* x ONE-8) (/ y u2)) y))

  (map-set prices
	PYTH_BTC_PRICE_FEED_ID
	(tuple (price-identifier PYTH_BTC_PRICE_FEED_ID) (conf default-conf) (ema-conf default-conf) (ema-price default-price) (expo -8) (prev-publish-time (unwrap-panic (get-stacks-block-info? time (- stacks-block-height u1)))) (price default-price) (publish-time (unwrap-panic (get-stacks-block-info? time (- stacks-block-height u1))) ))
)
