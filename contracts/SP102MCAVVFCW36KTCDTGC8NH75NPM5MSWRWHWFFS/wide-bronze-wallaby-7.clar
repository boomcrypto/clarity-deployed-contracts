;; (impl-trait 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.oracle-trait.oracle-trait)
(use-trait ft 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.ft-trait.ft-trait)

(define-constant err-unauthorized (err u6000))
(define-constant err-stale-price (err u6001))
(define-constant err-price-feed-id (err u6002))
(define-constant err-price-out-of-range (err u6003))

(define-constant btc-price-feed-id 0xe62df6c8b4a85fe1a67db44dc12de5db330f7ac66b72dc658afedf0f4a415b43)
(define-constant stx-price-feed-id 0xec7a775f46379b5e943c3526b1c8d54cd49749176b0b98e02dde68d1bd335c17)
(define-constant usdc-price-feed-id 0xeaa020c61cc479712813461ce153894a96a6c00b21ed0cfc2798d1f9a9e9c94a)

(define-constant ststx-contract 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token)
(define-constant wstx-contract 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.wstx)
(define-constant sbtc-contract 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token)
(define-constant usdc-contract 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc)

(define-constant stx-den u1000000)
(define-constant one-8 u100000000)
(define-constant deployer tx-sender)

(define-data-var stale-price-threshold uint u120)

(define-map assets principal {
    price-feed-id: (buff 32),
    sigma-mu: uint,
})


(define-read-only (get-price (token principal))
  (let (
    (price-feed (unwrap! (map-get? assets token) err-price-feed-id))
    (price-feed-id (get price-feed-id price-feed))
    (sigma-mu (get sigma-mu price-feed))
    (oracle-data (try! (contract-call? 'SP3R4F6C1J3JQWWCVZ3S7FRRYPMYG6ZW6RZK31FXY.pyth-storage-v3 get-price price-feed-id)))
    (expo (get expo oracle-data))
    (price (convert-to-fixed-8 (get price oracle-data) expo))
    (conf (convert-to-fixed-8 (to-int (get conf oracle-data)) expo))
  )
    (is-eq token ststx-contract)
    ;; (if (is-eq token ststx-contract)
    ;;   (ok (try! (convert-stx-to-ststx-read price)))
      (ok price)
    ;; )
  )
)

(define-private (convert-stx-to-ststx (stx-price uint))
  (let (
    (ratio
      (try!
        (contract-call? 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.data-core-v2
          get-stx-per-ststx
          'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.reserve-v1
        )
      )
    )
  )
    (ok (/ (* stx-price ratio) stx-den))
  )
)

(define-read-only (convert-stx-to-ststx-read (stx-price uint))
  (let (
    (total-stx-amount (unwrap-panic (contract-call? 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.reserve-v1 get-total-stx)))
    (ststxbtc-supply (unwrap-panic (contract-call? 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststxbtc-token get-total-supply)))
    (stx-for-ststx (- total-stx-amount ststxbtc-supply))
    (ratio (contract-call? 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.data-core-v2 get-stx-per-ststx-helper stx-for-ststx))
  )
    (ok (/ (* stx-price ratio) stx-den))
  )
)

(define-read-only (get-stale-price-threshold)
    (var-get stale-price-threshold))

(define-public (set-stale-price-threshold (threshold uint))
    (begin
        (asserts! (is-eq tx-sender deployer) err-unauthorized)
        (ok (var-set stale-price-threshold threshold))
    )
)

(define-public (set-asset (token principal) (data { price-feed-id: (buff 32), sigma-mu: uint }))
    (begin
        (asserts! (is-eq tx-sender deployer) err-unauthorized)
        (ok (map-set assets token data))
    )
)


;; if the integer represenation is 10^expo, convert to 8 decimal places
(define-read-only (convert-to-fixed-8 (price int) (expo int))
    (to-uint (* price (pow 10 (+ expo 8)))))

(define-read-only (div (x uint) (y uint))
  (/ (+ (* x one-8) (/ y u2)) y))


;; sigma/mu of 0.5%
(map-set assets sbtc-contract { price-feed-id: btc-price-feed-id, sigma-mu: u500000 })
;; 0.5%
(map-set assets wstx-contract { price-feed-id: stx-price-feed-id, sigma-mu: u500000 })
(map-set assets ststx-contract { price-feed-id: stx-price-feed-id, sigma-mu: u500000 })
;; 0.1%
(map-set assets usdc-contract { price-feed-id: usdc-price-feed-id, sigma-mu: u100000 })
