
(define-constant ERR_NO_ORACLE_PRICE (err u700))
(define-constant ERR_STALE_ORACLE_PRICE (err u701))
(define-constant ERR_PRICE_OUT_OF_RANGE (err u702))

(define-constant ONE-8 u100000000)

(define-constant PYTH_BTC_PRICE_FEED_ID 0xe62df6c8b4a85fe1a67db44dc12de5db330f7ac66b72dc658afedf0f4a415b43)

;; Mainnet
(define-constant PYTH_ORACLE 'SP3R4F6C1J3JQWWCVZ3S7FRRYPMYG6ZW6RZK31FXY.pyth-oracle-v3)
(define-constant PYTH_STORAGE 'SP3R4F6C1J3JQWWCVZ3S7FRRYPMYG6ZW6RZK31FXY.pyth-storage-v3)
(define-constant PYTH_DECODER 'SP3R4F6C1J3JQWWCVZ3S7FRRYPMYG6ZW6RZK31FXY.pyth-pnau-decoder-v2)
(define-constant PYTH_WORMHOLE 'SP3R4F6C1J3JQWWCVZ3S7FRRYPMYG6ZW6RZK31FXY.wormhole-core-v3)

;; Testnet
;; (define-constant PYTH_ORACLE 'ST20M5GABDT6WYJHXBT5CDH4501V1Q65242SPRMXH.pyth-oracle-v3)
;; (define-constant PYTH_STORAGE 'ST20M5GABDT6WYJHXBT5CDH4501V1Q65242SPRMXH.pyth-storage-v3)
;; (define-constant PYTH_DECODER 'ST20M5GABDT6WYJHXBT5CDH4501V1Q65242SPRMXH.pyth-pnau-decoder-v2)
;; (define-constant PYTH_WORMHOLE 'ST20M5GABDT6WYJHXBT5CDH4501V1Q65242SPRMXH.wormhole-core-v3)

;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; oracle-trait BEGIN
;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-public (get-price (price-feed-bytes (optional (buff 8192))))
    (let 
        (
            (current-stacks-block-ts-seconds (unwrap-panic (get-stacks-block-info? time (- stacks-block-height u1))))
			(execution-plan
				{
					pyth-storage-contract: PYTH_STORAGE,
					pyth-decoder-contract: PYTH_DECODER,
					wormhole-core-contract: PYTH_WORMHOLE,
				}
			)
			(decoded-data
				(match price-feed-bytes value
					(element-at (try! (contract-call? PYTH_ORACLE decode-price-feeds value execution-plan)) u0)
					(some { conf: u0, ema-conf: u0, ema-price: 0, expo: -8, prev-publish-time: u0, price: (to-int (pow u10 u8)), price-identifier: 0x00, publish-time: (+ current-stacks-block-ts-seconds u1)})
				)
			)
			(feed-id (unwrap! (get price-identifier decoded-data) (err u990)))
			(valid-feed (asserts! (is-eq feed-id PYTH_BTC_PRICE_FEED_ID) ERR_NO_ORACLE_PRICE))	
			(expo (unwrap! (get expo decoded-data) (err u992)))
			(price (convert-to-fixed-8 (unwrap! (get price decoded-data) (err u991)) expo))
			(conf (convert-to-fixed-8 (to-int (unwrap! (get conf decoded-data) (err u993))) expo))
			(price-publish-ts-seconds (unwrap! (get publish-time decoded-data) (err u994)))
        )

		(ok price)
    )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; oracle-trait END
;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; if the integer represenation is 10^expo, convert to 8 decimal places
(define-read-only (convert-to-fixed-8 (price int) (expo int))
    (to-uint (* price (pow 10 (+ expo 8)))))

(define-read-only (div (x uint) (y uint))
  (/ (+ (* x ONE-8) (/ y u2)) y))
