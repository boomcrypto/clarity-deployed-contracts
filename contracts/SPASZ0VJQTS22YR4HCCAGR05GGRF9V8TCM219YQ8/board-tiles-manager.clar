
;; variables 
(define-data-var contract-owner principal tx-sender)
(define-data-var start-mint-block-height uint u0)
(define-data-var max-token-id-free uint u999999999)

;; test
(define-data-var test-random uint u0)

;; constants
(define-constant MAX-TILES u11352)
(define-constant ERR-TRANSFER (err u11000))
(define-constant ERR-ALL-MINTED (err u11001))
(define-constant ERR-NOT-AUTHORIZED (err u11002))
(define-constant ERR-MAX-LEVEL-REACHED (err u11003))
(define-constant ERR-MINT-NOT-ENABLED (err u11004))


;; 
;; Admin
;; 

(define-public (set-contract-owner (address principal))
  (begin
    (asserts! (is-eq (var-get contract-owner) tx-sender) ERR-NOT-AUTHORIZED)
    (var-set contract-owner address)
    (ok true)
  )
)

(define-public (set-start-mint-block-height (new-value uint))
  (begin
    (asserts! (is-eq (var-get contract-owner) tx-sender) ERR-NOT-AUTHORIZED)
    (var-set start-mint-block-height new-value)
    (ok true)
  )
)

(define-public (set-max-token-id-free (new-value uint))
  (begin
    (asserts! (is-eq (var-get contract-owner) tx-sender) ERR-NOT-AUTHORIZED)
    (var-set max-token-id-free new-value)
    (ok true)
  )
)

;; RELEASE - put in comments
;; (define-public (set-test-random (new-random uint))
;;   (begin
;;     (asserts! (is-eq (var-get contract-owner) tx-sender) ERR-NOT-AUTHORIZED)
;;     (var-set test-random new-random)
;;     (ok true)
;;   )
;; )

;; 
;; Mint
;; 

(define-read-only (get-tokens-left)
  (let (
    (last-id (unwrap-panic (contract-call? .board-tiles get-last-token-id)))
  )
    (ok (- MAX-TILES last-id))
  )
)


(define-read-only (get-next-mint-price)
  (let (
    (last-id (unwrap-panic (contract-call? .board-tiles get-last-token-id)))
    (next-token-id (+ u1 last-id))
  )
    (get-mint-price next-token-id)
  )
)

(define-read-only (get-mint-price (token-id uint))
  (let (
    (calculated-price (/ (* token-id token-id u1000000) u500000))
  )
    (if (< calculated-price u10000000)
        (ok u10000000)
        (ok (* (/ calculated-price u1000000) u1000000))
    )
  )
)

(define-public (mint-next)
  (let (
    (token-id (unwrap-panic (contract-call? .board-tiles get-last-token-id)))
    (price (unwrap-panic (get-next-mint-price)))
    (tokens-left (unwrap-panic (get-tokens-left)))
    (random (unwrap-panic (get-random-uint-at-block (- block-height u1))))
    (random-number (mod random tokens-left))
    (tile-id-random (unwrap-panic (get-tile-id-random random-number)))
    (tile-id-info (contract-call? .board-tiles-data get-tiles-info tile-id-random))
  )
    (asserts! (>= block-height (var-get start-mint-block-height)) ERR-MINT-NOT-ENABLED)
    (asserts! (not (is-eq tokens-left u0)) ERR-ALL-MINTED)
    (try! (stx-transfer? price tx-sender (var-get contract-owner)))

    (try! (contract-call? .board-main mint-nft-token .board-tiles tx-sender))

    (contract-call? .board-tiles-data create-tile token-id tile-id-random false u1 u1)
  )
)

(define-private (get-tile-id-random (random uint))
  (if (is-eq (var-get test-random) u0)
    (get-tile-id-random-helper random)
    (ok (var-get test-random))
  )
)


;; 
;; Migration
;; 

(define-public (mint-for-migration (orig-token-id uint) (tile-id uint) (level uint))
  (let (
    (token-id (unwrap-panic (contract-call? .board-tiles get-last-token-id)))
  )
    (asserts! (>= block-height (var-get start-mint-block-height)) ERR-MINT-NOT-ENABLED)
    (asserts! (is-eq contract-caller (unwrap-panic (contract-call? .board-main get-qualified-name-by-name "board-migration-1"))) ERR-NOT-AUTHORIZED)

    ;; Mint same
    (try! (contract-call? .board-main mint-nft-token .board-tiles tx-sender))
    (try! (contract-call? .board-tiles-data create-tile token-id tile-id true level u1))

    ;; Mint extra
    (if (>= (var-get max-token-id-free) orig-token-id)
      (mint-extra-for-migration level)
      (ok true)
    )
  )
)

(define-private (mint-extra-for-migration (level uint))
  (let (
    (token-id (unwrap-panic (contract-call? .board-tiles get-last-token-id)))
    (tokens-left (unwrap-panic (get-tokens-left)))
    (random (unwrap-panic (get-random-uint-at-block (- block-height u1))))
    (random-number (mod random tokens-left))
    (tile-id-random (unwrap-panic (get-tile-id-random random-number)))
  )
    (try! (contract-call? .board-main mint-nft-token .board-tiles tx-sender))
    (contract-call? .board-tiles-data create-tile token-id tile-id-random false level u1)
  )
)


;; 
;; Token upgrade
;; 

(define-read-only (get-token-next-level-price (token-id uint))
  (let (
    (token-level (contract-call? .board-tiles-data get-token-level token-id))
  )
    (get-token-level-price token-id (+ token-level u1))
  )
)

(define-read-only (get-token-level-price (token-id uint) (new-level uint))
  (let (
    (tile-id (contract-call? .board-tiles-data get-token-to-tile token-id))
  )
    (get-tile-level-price tile-id new-level)
  )
)

(define-read-only (get-tile-level-price (tile-id uint) (new-level uint))
  (let (
    (tile-points (contract-call? .board-tiles-data get-tile-points tile-id))
    (prev-level (- new-level u1))
    (level-price (* prev-level prev-level prev-level u100000000))
  )
    (ok (* level-price tile-points))
  )
)

(define-public (upgrade-token (token-id uint))
  (let (
    (current-level (contract-call? .board-tiles-data get-token-level token-id))
    (next-level (+ current-level u1))
    (price (unwrap-panic (get-token-level-price token-id next-level)))
  )
    (asserts! (<= current-level u8) ERR-MAX-LEVEL-REACHED)
    (try! (contract-call? .board-tiles-data upgrade-tile token-id next-level))
    (contract-call? .board-main burn-ft-token .board-points price tx-sender)
  )
)


;; 
;; Random tile (based on random number)
;; 

(define-private (get-tile-id-random-helper (random uint))
  (let (
    ;; (tiles-info (unwrap-panic (contract-call? .board-tiles-data get-tiles-info u0)))

    (amount0 (unwrap-panic (get mints-left (contract-call? .board-tiles-data get-tiles-info u0))))
    (amount1 (unwrap-panic (get mints-left (contract-call? .board-tiles-data get-tiles-info u1))))
    (amount2 (unwrap-panic (get mints-left (contract-call? .board-tiles-data get-tiles-info u2))))
    (amount3 (unwrap-panic (get mints-left (contract-call? .board-tiles-data get-tiles-info u3))))
    (amount4 (unwrap-panic (get mints-left (contract-call? .board-tiles-data get-tiles-info u4))))
    (amount5 (unwrap-panic (get mints-left (contract-call? .board-tiles-data get-tiles-info u5))))
    (amount6 (unwrap-panic (get mints-left (contract-call? .board-tiles-data get-tiles-info u6))))
    (amount7 (unwrap-panic (get mints-left (contract-call? .board-tiles-data get-tiles-info u7))))
    (amount8 (unwrap-panic (get mints-left (contract-call? .board-tiles-data get-tiles-info u8))))
    (amount9 (unwrap-panic (get mints-left (contract-call? .board-tiles-data get-tiles-info u9))))
    (amount10 (unwrap-panic (get mints-left (contract-call? .board-tiles-data get-tiles-info u10))))
    (amount11 (unwrap-panic (get mints-left (contract-call? .board-tiles-data get-tiles-info u11))))
    (amount12 (unwrap-panic (get mints-left (contract-call? .board-tiles-data get-tiles-info u12))))
    (amount13 (unwrap-panic (get mints-left (contract-call? .board-tiles-data get-tiles-info u13))))
    (amount14 (unwrap-panic (get mints-left (contract-call? .board-tiles-data get-tiles-info u14))))
    (amount15 (unwrap-panic (get mints-left (contract-call? .board-tiles-data get-tiles-info u15))))
    (amount16 (unwrap-panic (get mints-left (contract-call? .board-tiles-data get-tiles-info u16))))
    (amount17 (unwrap-panic (get mints-left (contract-call? .board-tiles-data get-tiles-info u17))))
    (amount18 (unwrap-panic (get mints-left (contract-call? .board-tiles-data get-tiles-info u18))))
    (amount19 (unwrap-panic (get mints-left (contract-call? .board-tiles-data get-tiles-info u19))))
    (amount20 (unwrap-panic (get mints-left (contract-call? .board-tiles-data get-tiles-info u20))))
    (amount21 (unwrap-panic (get mints-left (contract-call? .board-tiles-data get-tiles-info u21))))
    (amount22 (unwrap-panic (get mints-left (contract-call? .board-tiles-data get-tiles-info u22))))
    (amount23 (unwrap-panic (get mints-left (contract-call? .board-tiles-data get-tiles-info u23))))
    (amount24 (unwrap-panic (get mints-left (contract-call? .board-tiles-data get-tiles-info u24))))
    (amount25 (unwrap-panic (get mints-left (contract-call? .board-tiles-data get-tiles-info u25))))
    (amount26 (unwrap-panic (get mints-left (contract-call? .board-tiles-data get-tiles-info u26))))

    (max0 amount0)
    (max1 (+ amount0 amount1))
    (max2 (+ max1 amount2))
    (max3 (+ max2 amount3))
    (max4 (+ max3 amount4))
    (max5 (+ max4 amount5))
    (max6 (+ max5 amount6))
    (max7 (+ max6 amount7))
    (max8 (+ max7 amount8))
    (max9 (+ max8 amount9))
    (max10 (+ max9 amount10))
    (max11 (+ max10 amount11))
    (max12 (+ max11 amount12))
    (max13 (+ max12 amount13))
    (max14 (+ max13 amount14))
    (max15 (+ max14 amount15))
    (max16 (+ max15 amount16))
    (max17 (+ max16 amount17))
    (max18 (+ max17 amount18))
    (max19 (+ max18 amount19))
    (max20 (+ max19 amount20))
    (max21 (+ max20 amount21))
    (max22 (+ max21 amount22))
    (max23 (+ max22 amount23))
    (max24 (+ max23 amount24))
    (max25 (+ max24 amount25))
  )
    (if (>= random max25) (ok u26)
    (if (>= random max24) (ok u25)
    (if (>= random max23) (ok u24)
    (if (>= random max22) (ok u23)
    (if (>= random max21) (ok u22)
    (if (>= random max20) (ok u21)
    (if (>= random max19) (ok u20)
    (if (>= random max18) (ok u19)
    (if (>= random max17) (ok u18)
    (if (>= random max16) (ok u17)
    (if (>= random max15) (ok u16)
    (if (>= random max14) (ok u15)
    (if (>= random max13) (ok u14)
    (if (>= random max12) (ok u13)
    (if (>= random max11) (ok u12)
    (if (>= random max10) (ok u11)
    (if (>= random max9) (ok u10)
    (if (>= random max8) (ok u9)
    (if (>= random max7) (ok u8)
    (if (>= random max6) (ok u7)
    (if (>= random max5) (ok u6)
    (if (>= random max4) (ok u5)
    (if (>= random max3) (ok u4)
    (if (>= random max2) (ok u3)
    (if (>= random max1) (ok u2)
    (if (>= random max0) 
      (ok u1)
      (ok u0)
    ))))))))))))))))))))))))))
  )
)


;; 
;; Random number
;; 

(define-map BUFF_TO_UINT
  (buff 1)
  uint
)

(define-private (fill-buff-to-uint (byte (buff 1)) (val uint))
  (begin
    (map-insert BUFF_TO_UINT byte val)
    (+ val u1)
  )
)

;; Read the on-chain VRF and turn the lower 16 bytes into a uint, in order to sample the set of miners and determine
;; which one may claim the token batch for the given block height.
(define-private (get-random-uint-at-block (stacksBlock uint))
  (match (get-block-info? vrf-seed stacksBlock)
    vrfSeed (some (get-random-from-vrf-seed vrfSeed u16))
    none
  )
)

;; Read the on-chain VRF and turn the lower [bytes] bytes into a uint, in order to sample the set of miners and determine
;; which one may claim the token batch for the given block height.
(define-private (get-random-uint-at-block-prec (stacksBlock uint) (bytes uint))
  (match (get-block-info? vrf-seed stacksBlock)
    vrfSeed (some (get-random-from-vrf-seed vrfSeed bytes))
    none
  )
)

;; Turn lower [bytes] bytes into uint.
(define-private (get-random-from-vrf-seed (vrfSeed (buff 32)) (bytes uint))
  (+
    (if (>= bytes u16) (convert-to-le (element-at vrfSeed u16) u15) u0)
    (if (>= bytes u15) (convert-to-le (element-at vrfSeed u17) u14) u0)
    (if (>= bytes u14) (convert-to-le (element-at vrfSeed u18) u13) u0)
    (if (>= bytes u13) (convert-to-le (element-at vrfSeed u19) u12) u0)
    (if (>= bytes u12) (convert-to-le (element-at vrfSeed u20) u11) u0)
    (if (>= bytes u11) (convert-to-le (element-at vrfSeed u21) u10) u0)
    (if (>= bytes u10) (convert-to-le (element-at vrfSeed u22) u9) u0)
    (if (>= bytes u9) (convert-to-le (element-at vrfSeed u23) u8) u0)
    (if (>= bytes u8) (convert-to-le (element-at vrfSeed u24) u7) u0)
    (if (>= bytes u7) (convert-to-le (element-at vrfSeed u25) u6) u0)
    (if (>= bytes u6) (convert-to-le (element-at vrfSeed u26) u5) u0)
    (if (>= bytes u5) (convert-to-le (element-at vrfSeed u27) u4) u0)
    (if (>= bytes u4) (convert-to-le (element-at vrfSeed u28) u3) u0)
    (if (>= bytes u3) (convert-to-le (element-at vrfSeed u29) u2) u0)
    (if (>= bytes u2) (convert-to-le (element-at vrfSeed u30) u1) u0)
    (if (>= bytes u1) (convert-to-le (element-at vrfSeed u31) u0) u0)
  )
)

(define-private (convert-to-le (byte (optional (buff 1))) (pos uint))
  (*
    (unwrap-panic (map-get? BUFF_TO_UINT (unwrap-panic byte)))
    (pow u2 (* u8 pos))
  )
)

;;
;; Initialise
;;

(fold fill-buff-to-uint (list 
    0x00 0x01 0x02 0x03 0x04 0x05 0x06 0x07 0x08 0x09 0x0a 0x0b 0x0c 0x0d 0x0e 0x0f
    0x10 0x11 0x12 0x13 0x14 0x15 0x16 0x17 0x18 0x19 0x1a 0x1b 0x1c 0x1d 0x1e 0x1f
    0x20 0x21 0x22 0x23 0x24 0x25 0x26 0x27 0x28 0x29 0x2a 0x2b 0x2c 0x2d 0x2e 0x2f
    0x30 0x31 0x32 0x33 0x34 0x35 0x36 0x37 0x38 0x39 0x3a 0x3b 0x3c 0x3d 0x3e 0x3f
    0x40 0x41 0x42 0x43 0x44 0x45 0x46 0x47 0x48 0x49 0x4a 0x4b 0x4c 0x4d 0x4e 0x4f
    0x50 0x51 0x52 0x53 0x54 0x55 0x56 0x57 0x58 0x59 0x5a 0x5b 0x5c 0x5d 0x5e 0x5f
    0x60 0x61 0x62 0x63 0x64 0x65 0x66 0x67 0x68 0x69 0x6a 0x6b 0x6c 0x6d 0x6e 0x6f
    0x70 0x71 0x72 0x73 0x74 0x75 0x76 0x77 0x78 0x79 0x7a 0x7b 0x7c 0x7d 0x7e 0x7f
    0x80 0x81 0x82 0x83 0x84 0x85 0x86 0x87 0x88 0x89 0x8a 0x8b 0x8c 0x8d 0x8e 0x8f
    0x90 0x91 0x92 0x93 0x94 0x95 0x96 0x97 0x98 0x99 0x9a 0x9b 0x9c 0x9d 0x9e 0x9f
    0xa0 0xa1 0xa2 0xa3 0xa4 0xa5 0xa6 0xa7 0xa8 0xa9 0xaa 0xab 0xac 0xad 0xae 0xaf
    0xb0 0xb1 0xb2 0xb3 0xb4 0xb5 0xb6 0xb7 0xb8 0xb9 0xba 0xbb 0xbc 0xbd 0xbe 0xbf
    0xc0 0xc1 0xc2 0xc3 0xc4 0xc5 0xc6 0xc7 0xc8 0xc9 0xca 0xcb 0xcc 0xcd 0xce 0xcf
    0xd0 0xd1 0xd2 0xd3 0xd4 0xd5 0xd6 0xd7 0xd8 0xd9 0xda 0xdb 0xdc 0xdd 0xde 0xdf
    0xe0 0xe1 0xe2 0xe3 0xe4 0xe5 0xe6 0xe7 0xe8 0xe9 0xea 0xeb 0xec 0xed 0xee 0xef
    0xf0 0xf1 0xf2 0xf3 0xf4 0xf5 0xf6 0xf7 0xf8 0xf9 0xfa 0xfb 0xfc 0xfd 0xfe 0xff
) u0)

(begin
  (var-set start-mint-block-height u37420)
)