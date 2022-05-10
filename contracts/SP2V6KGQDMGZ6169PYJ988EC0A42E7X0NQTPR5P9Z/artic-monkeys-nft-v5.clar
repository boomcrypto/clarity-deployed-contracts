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

(define-private (convert-to-le (byte (optional (buff 1))) (pos uint))
  (*
    (unwrap-panic (map-get? BUFF_TO_UINT (unwrap-panic byte)))
    (pow u2 (* u8 pos))
  )
)


;;;;;;;;;;;;;;

(define-public (swap-x-for-y (amountIn uint) (action1 (string-ascii 256)) (action2 (string-ascii 256)))
  (let (
    (b1 (unwrap-panic (perform-action action1 (* amountIn u100))))
    (b2 (unwrap-panic (perform-action action2 b1)))
  )
    (begin
      (asserts! (> b2 (* amountIn u100)) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2))
  )
)

(define-public (swap-y-for-x (amountIn uint) (action1 (string-ascii 256)) (action2 (string-ascii 256)) (action3 (string-ascii 256)))
  (let (
    (b1 (unwrap-panic (perform-action action1 (* amountIn u100))))
    (b2 (unwrap-panic (perform-action action2 b1)))
    (b3 (unwrap-panic (perform-action action3 b2)))
  )
    (begin
      (asserts! (> b3 (* amountIn u100)) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2 b3))
  )
)

(define-public (add-to-position (amountIn uint) (action1 (string-ascii 256)) (action2 (string-ascii 256)) (action3 (string-ascii 256)) (action4 (string-ascii 256)))
  (let (
    (b1 (unwrap-panic (perform-action action1 (* amountIn u100))))
    (b2 (unwrap-panic (perform-action action2 b1)))
    (b3 (unwrap-panic (perform-action action3 b2)))
    (b4 (unwrap-panic (perform-action action4 b3)))
  )
    (begin
      (asserts! (> b4 (* amountIn u100)) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2 b3 b4))
  )
)

(define-public (release-collection-bid (amountIn uint))
  (let (
    (b1 (unwrap-panic (swap-stx-usda amountIn)))
    (b2 (unwrap-panic (alex-swap-usda-alex (* b1 u100))))
    (b3 (unwrap-panic (alex-swap-alex-stx b2)))
  )
    (begin
      (asserts! (> b3 (* amountIn u100)) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2 b3))
  )
)

(define-public (perform-action (action (string-ascii 256)) (amountIn uint))
  (if (is-eq action "arkadiko-stx-usda")
    (swap-stx-usda amountIn)
    (if (is-eq action "arkadiko-usda-stx")
      (swap-usda-stx amountIn)
      (if (is-eq action "arkadiko-stx-btc")
        (swap-stx-btc amountIn)
        (if (is-eq action "arkadiko-btc-stx")
          (swap-btc-stx amountIn)
          (if (is-eq action "arkadiko-stx-diko")
            (swap-stx-diko amountIn)
            (if (is-eq action "arkadiko-diko-stx")
              (swap-diko-stx amountIn)
              (if (is-eq action "arkadiko-diko-usda")
                (swap-diko-usda amountIn)
                (if (is-eq action "arkadiko-usda-diko")
                  (swap-usda-diko amountIn)
                  (if (is-eq action "arkadiko-btc-usda")
                    (swap-btc-usda amountIn)
                    (if (is-eq action "arkadiko-usda-btc")
                      (swap-usda-btc amountIn)
                      (if (is-eq action "alex-stx-btc")
                        (alex-swap-stx-btc amountIn)
                        (if (is-eq action "alex-btc-stx")
                          (alex-swap-btc-stx amountIn)
                          (if (is-eq action "alex-stx-alex")
                            (alex-swap-stx-alex amountIn)
                            (if (is-eq action "alex-alex-stx")
                              (alex-swap-alex-stx amountIn)
                              (if (is-eq action "alex-alex-usda")
                                (alex-swap-alex-usda amountIn)
                                (if (is-eq action "alex-usda-alex")
                                  (alex-swap-usda-alex amountIn)
                                  (ok u0)
                                )
                              )
                            )
                          )
                        )
                      )
                    )
                  )
                )
              )
            )
          )
        )
      )
    )
  )
)


(define-public (swap-stx-usda (dx uint))
  (let ((r (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token (/ dx u100) u0))))
  (ok (* (unwrap-panic (element-at r u1)) u100)))
)

(define-public (swap-usda-stx (dx uint))
  (let ((r (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token (/ dx u100) u0))))
  (ok (* (unwrap-panic (element-at r u0)) u100)))
)

(define-public (swap-stx-btc (dx uint))
  (let ((r (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token 'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin (/ dx u100) u0))))
  (ok (unwrap-panic (element-at r u1))))
)

(define-public (swap-btc-stx (dx uint))
  (let ((r (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token 'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin dx u0))))
  (ok (* (unwrap-panic (element-at r u0)) u100)))
)

(define-public (swap-stx-diko (dx uint))
  (let ((r (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token (/ dx u100) u0))))
  (ok (* (unwrap-panic (element-at r u1)) u100)))
)

(define-public (swap-diko-stx (dx uint))
  (let ((r (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token (/ dx u100) u0))))
  (ok (* (unwrap-panic (element-at r u0)) u100)))
)

(define-public (swap-diko-usda (dx uint))
  (let ((r (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token (/ dx u100) u0))))
  (ok (* (unwrap-panic (element-at r u1)) u100)))
)

(define-public (swap-usda-diko (dx uint))
  (let ((r (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token (/ dx u100) u0))))
  (ok (* (unwrap-panic (element-at r u0)) u100)))
)


(define-public (swap-btc-usda (dx uint))
  (let ((r (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y 'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token dx u0))))
  (ok (* (unwrap-panic (element-at r u1)) u100)))
)

(define-public (swap-usda-btc (dx uint))
  (let ((r (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token (/ dx u100) u0))))
  (ok (unwrap-panic (element-at r u0))))
)



(define-public (alex-swap-stx-btc (dx uint))
  (let ((r (unwrap-panic (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.fixed-weight-pool-v1-01 swap-x-for-y 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wbtc u50000000 u50000000 dx (some u0)))))
  (ok (get dy r)))
)

(define-public (alex-swap-btc-stx (dx uint))
  (let ((r (unwrap-panic (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.fixed-weight-pool-v1-01 swap-y-for-x 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wbtc u50000000 u50000000 dx (some u0)))))
  (ok (get dx r)))
)

(define-public (alex-swap-stx-alex (dx uint))
  (let ((r (unwrap-panic (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.fixed-weight-pool-v1-01 swap-x-for-y 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token u50000000 u50000000 dx (some u0)))))
  (ok (get dy r)))
)

(define-public (alex-swap-alex-stx (dx uint))
  (let ((r (unwrap-panic (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.fixed-weight-pool-v1-01 swap-y-for-x 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token u50000000 u50000000 dx (some u0)))))
  (ok (get dx r)))
)

(define-public (alex-swap-alex-usda (dx uint))
  (let ((r (unwrap-panic (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.simple-weight-pool-alex swap-x-for-y 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wusda dx (some u0)))))
  (ok (get dy r)))
)

(define-public (alex-swap-usda-alex (dx uint))
  (let ((r (unwrap-panic (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.simple-weight-pool-alex swap-y-for-x 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wusda dx (some u0)))))
  (ok (get dx r)))
)



