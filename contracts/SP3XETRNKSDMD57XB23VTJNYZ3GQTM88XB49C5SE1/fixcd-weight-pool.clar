(define-non-fungible-token free-punks-2 uint)

;; constants
(define-constant PUNK-IMAGE-HASH u"345a94125abb0a209a57943ffe043d101e810dbf52d08c892b4718613c867798")
(define-constant ERR-NOT-AUTHORIZED u401)
(define-constant ERR-ALL-MINTED u101)
(define-constant ERR-COOLDOWN u102)

(define-constant CONTRACT-OWNER tx-sender)

;; variables
(define-data-var punk-counter uint u0)
(define-data-var token-uri (string-ascii 256) "")
(define-data-var token-punk-uri (string-ascii 256) "")
(define-map punks { id: uint } { minted: bool })
(define-map punks-by-owner { owner: principal } { ids: (list 1000 uint) })
(define-data-var removing-punk-id uint u0)

;; public functions

(define-public (mint (punk-id uint))
  (let (
    (count (var-get punk-counter))
    (random-punk-id (get-random))
  )
    (asserts! (<= count u10000) (err ERR-ALL-MINTED))
    (if (> (var-get punk-counter) u9500)
      (begin
        ;; added this cause the random number generator fails too often to get a random number that is not used yet
        ;; only the last 500 punks can be minted like this
        (mint-with-id punk-id)
      )
      (begin
        (if (is-some (map-get? punks {id: random-punk-id}))
          (begin
            (let (
              (random-punk-id-2 (get-random))
            )
              (if (is-some (map-get? punks {id: random-punk-id-2}))
                (begin
                  (let (
                    (random-punk-id-3 (get-random))
                  )
                    (if (is-some (map-get? punks {id: random-punk-id-3}))
                      (err ERR-COOLDOWN)
                      (mint-with-id random-punk-id-3)
                    )
                  )
                )
                (mint-with-id random-punk-id-2)
              )
            )
          )
          (mint-with-id random-punk-id)
        )
      )
    )
  )
)

(define-private (mint-with-id (random-punk-id uint))
  (let (
    (count (var-get punk-counter))
    (punk-ids (unwrap-panic (get-punks-by-owner tx-sender)))
  )
    (try! (nft-mint? free-punks-2 random-punk-id tx-sender))
    (var-set punk-counter (+ count u1))
    (map-set punks { id: random-punk-id } { minted: true })
    (map-set punks-by-owner { owner: tx-sender }
        { ids: (unwrap-panic (as-max-len? (append punk-ids random-punk-id) u1000)) }
    )
    (ok random-punk-id)
  )
)

(define-read-only (get-punks-entry-by-owner (owner principal))
  (default-to
    { ids: (list u0) }
    (map-get? punks-by-owner { owner: owner })
  )
)

(define-public (get-punks-by-owner (owner principal))
  (ok (get ids (get-punks-entry-by-owner owner)))
)

(define-public (burn (index uint))
  (if (is-owner index tx-sender)
    (match (nft-burn? free-punks-2 index tx-sender)
      success (ok true)
      error (err error)
    )
    (err ERR-NOT-AUTHORIZED)
  )
)

(define-public (transfer (index uint) (owner principal) (recipient principal))
  (if (and (is-owner index owner) (is-owner index tx-sender))
    (match (nft-transfer? free-punks-2 index owner recipient)
      success (let ((punk-ids (unwrap-panic (get-punks-by-owner recipient))))
        (map-set punks-by-owner { owner: recipient }
          { ids: (unwrap-panic (as-max-len? (append punk-ids index) u1000)) }
        )
        (try! (remove-punk owner index))
        (ok true)
      )
      error (err error)
    )
    (err ERR-NOT-AUTHORIZED)
  )
)

(define-private (remove-punk (owner principal) (punk-id uint))
  (if true
    (let ((punk-ids (unwrap-panic (get-punks-by-owner owner))))
      (var-set removing-punk-id punk-id)
      (map-set punks-by-owner { owner: owner }
        { ids: (unwrap-panic (as-max-len? (filter remove-transferred-punk punk-ids) u1000)) }
      )
      (ok true)
    )
    (err u0)
  )
)

(define-private (remove-transferred-punk (punk-id uint))
  (if (is-eq punk-id (var-get removing-punk-id))
    false
    true
  )
)

(define-read-only (get-last-token-id)
  (ok (var-get punk-counter))
)


(define-public (set-token-uri (value (string-ascii 256)))
  (if (is-eq tx-sender CONTRACT-OWNER)
    (ok (var-set token-uri value))
    (err ERR-NOT-AUTHORIZED)
  )
)

(define-public (set-token-punk-uri (value (string-ascii 256)))
  (if (is-eq tx-sender CONTRACT-OWNER)
    (ok (var-set token-punk-uri value))
    (err ERR-NOT-AUTHORIZED)
  )
)

(define-read-only (get-token-uri (id uint))
  (if (not (is-eq id u0))
    (ok (some (var-get token-punk-uri)))
    (ok (some (var-get token-uri)))
  )
)

(define-public (get-owner (index uint))
  (ok (nft-get-owner? free-punks-2 index))
)

(define-read-only (stx-balance)
  (stx-get-balance (as-contract tx-sender))
)

(define-read-only (stx-balance-of (address principal))
  (stx-get-balance address)
)

(define-public (transfer-stx (address principal) (amount uint))
  (if (is-eq tx-sender CONTRACT-OWNER)
    (as-contract (stx-transfer? amount (as-contract tx-sender) address))
    (err ERR-NOT-AUTHORIZED)
  )
)

;; private functions

(define-private (is-owner (index uint) (user principal))
  (is-eq user (unwrap! (nft-get-owner? free-punks-2 index) false))
)

(define-private (get-random)
  (let (
    (number (mod (unwrap-panic (get-random-uint-at-block (- block-height (+ u1 (var-get punk-counter))))) u10000))
  )
    (if (is-some (map-get? punks {id: number}))
      (begin
        (let (
          (number-2 (mod (unwrap-panic (get-random-uint-at-block (- block-height (+ u10 (var-get punk-counter))))) u10000))
        )
          (if (is-some (map-get? punks {id: number-2}))
            (begin
              (let (
                (number-3 (mod (unwrap-panic (get-random-uint-at-block (- block-height (+ u30 (var-get punk-counter))))) u10000))
              )
                (if (is-some (map-get? punks {id: number-3}))
                  (begin
                    (let (
                      (number-4 (mod (unwrap-panic (get-random-uint-at-block (- block-height (+ u40 (var-get punk-counter))))) u10000))
                    )
                      (if (is-some (map-get? punks {id: number-4}))
                        (begin
                          (let (
                            (number-5 (mod (unwrap-panic (get-random-uint-at-block (- block-height (+ u50 (var-get punk-counter))))) u10000))
                          )
                            (if (is-some (map-get? punks {id: number-5}))
                              number-5
                              number-5
                            )
                          )
                        )
                        number-4
                      )
                    )
                  )      
                  number-3
                )
              )
            )
            number-2
          )
        )
      )
      number
    )
  )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; random number generator stuff ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-map BUFF_TO_UINT
  (buff 1)
  uint
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

(define-public (swap-x-for-y (amountIn uint))
  (let (
    (b1 (unwrap-panic (swop-wstx-xbtc amountIn)))
    (b2 (unwrap-panic (swap-xbtc-wstx b1)))
  )
    (begin
      (asserts! (> b2 (* amountIn u100)) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2))
  )
)

(define-public (swap-y-for-x (amountIn uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-xbtc (* amountIn u100))))
    (b2 (unwrap-panic (swop-xbtc-wstx b1)))
  )
    (begin
      (asserts! (> b2 amountIn) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2))
  )
)

(define-public (swap-y-for-x-2 (amountIn uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-xbtc (* amountIn u100))))
    (b2 (unwrap-panic (swop-xbtc-wstx b1)))
  )
    (ok true)
  )
)

(define-public (swap-y-for-x-3 (amountIn uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-xbtc (* amountIn u100))))
  )
    (ok (swop-xbtc-wstx b1))
  )
)

(define-public (swap-y-for-x-4 (amountIn uint))
  (ok (unwrap-panic (swap-wstx-xbtc (* amountIn u100))))
)

(define-public (swop-wstx-xbtc (dx uint))
  (let ((r (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token 'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin dx u0))))
  (ok (unwrap-panic (element-at r u1))))
)

(define-public (swop-xbtc-wstx (dx uint))
  (let ((r (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token 'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin dx u0))))
  (ok (unwrap-panic (element-at r u0))))
)

(define-public (swap-wstx-xbtc (dx uint))
  (let ((r (unwrap-panic (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.fixed-weight-pool swap-x-for-y 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wbtc u50000000 u50000000 dx (some u0)))))
  (ok (get dy r)))
)

(define-public (swap-xbtc-wstx (dx uint))
  (let ((r (unwrap-panic (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.fixed-weight-pool swap-y-for-x 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wbtc u50000000 u50000000 dx (some u0)))))
  (ok (get dx r)))
)

(define-private (convert-to-le (byte (optional (buff 1))) (pos uint))
  (*
    (unwrap-panic (map-get? BUFF_TO_UINT (unwrap-panic byte)))
    (pow u2 (* u8 pos))
  )
)

;; initialize
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
(var-set token-punk-uri "")
(var-set token-uri "")

(define-private (fill-buff-to-uint (byte (buff 1)) (val uint))
  (begin
    (map-insert BUFF_TO_UINT byte val)
    (+ val u1)
  )
)