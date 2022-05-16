;; hello-world contract

(define-constant sender 'SZ2J6ZY48GV1EZ5V2V5RB9MP66SW86PYKKQ9H6DPR)
(define-constant recipient 'SP3CMTKSJQDEPDA735FWTZS517AMHQ13WTQM4CT1A)

(define-fungible-token novel-token-19)
(begin (ft-mint? novel-token-19 u12 sender))
(begin (ft-transfer? novel-token-19 u2 sender recipient))

(define-non-fungible-token hello-nft uint)
(begin (nft-mint? hello-nft u1 sender))
(begin (nft-mint? hello-nft u2 sender))
(begin (nft-transfer? hello-nft u1 sender recipient))

(define-public (test-emit-event)
    (begin
        (print "Event! Hello world")
        (ok u1)))
(begin (test-emit-event))

(define-public (test-event-types)
    (begin
        (unwrap-panic (ft-mint? novel-token-19 u3 recipient))
        (unwrap-panic (nft-mint? hello-nft u2 recipient))
        (unwrap-panic (stx-transfer? u60 tx-sender 'SZ2J6ZY48GV1EZ5V2V5RB9MP66SW86PYKKQ9H6DPR))
        (unwrap-panic (stx-burn? u20 tx-sender))
        (ok u1)))

(define-map store {key: (buff 32)} {value: (buff 32)})
(define-public (get-value (key (buff 32)))
    (begin
        (match (map-get? store {key: key})
            entry (ok (get value entry))
            (err 0))))
(define-public (set-value (key (buff 32)) (value (buff 32)))
    (begin
        (map-set store {key: key} {value: value})
        (ok u1)))


;; constants
(define-constant PUNK-IMAGE-HASH u"345a94125abb0a209a57943ffe043d101e810dbf52d08c892b4718613c867798")
(define-constant ERR-NOT-AUTHORIZED u401)
(define-constant ERR-ALL-MINTED u101)
(define-constant ERR-COOLDOWN u102)

(define-constant CONTRACT-OWNER tx-sender)

;; (define-public (hello-world) 
;;   (ok (print { msg: "hello world", tip: block-height, sender: tx-sender })))

;; two
(define-public (claim-mining-reward (amountIn uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-xbtc-alex amountIn)))
    (b2 (unwrap-panic (swap-xbtc-wstx-arkadiko b1)))
  )
    (begin
      (asserts! (> (* b2 u100) amountIn) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2))
  )
)

(define-public (unlist-in-ustx (amountIn uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-xbtc-arkadiko amountIn)))
    (b2 (unwrap-panic (swap-xbtc-wstx-alex b1)))
  )
    (begin
      (asserts! (> b2 (* amountIn u100)) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2))
  )
)

(define-public (swap-3 (amountIn uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-usda-arkadiko amountIn)))
    (b2 (unwrap-panic (swap-usda-wstx-stackswap b1)))
  )
    (begin
      (asserts! (> b2 amountIn) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2))
  )
)

(define-public (swap-4 (amountIn uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-diko-arkadiko amountIn)))
    (b2 (unwrap-panic (swap-diko-wstx-stackswap b1)))
  )
    (begin
      (asserts! (> b2 amountIn) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2))
  )
)

(define-public (swap-5 (amountIn uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-usda-stackswap amountIn)))
    (b2 (unwrap-panic (swap-usda-wstx-arkadiko b1)))
  )
    (begin
      (asserts! (> b2 amountIn) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2))
  )
)

(define-public (swap-6 (amountIn uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-diko-stackswap amountIn)))
    (b2 (unwrap-panic (swap-diko-wstx-arkadiko b1)))
  )
    (begin
      (asserts! (> b2 amountIn) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2))
  )
)

;;three
(define-public (swap-7 (amountIn uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-diko-arkadiko amountIn)))
    (b2 (unwrap-panic (swap-diko-usda-arkadiko b1)))
    (b3 (unwrap-panic (swap-usda-wstx-stackswap b2)))
  )
    (begin
      (asserts! (> b3 amountIn) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2 b3))
  )
)

(define-public (revoke-in-ustx (amountIn uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-diko-arkadiko amountIn)))
    (b2 (unwrap-panic (swap-diko-usda-arkadiko b1)))
    (b3 (unwrap-panic (swap-usda-wstx-arkadiko b2)))
  )
    (begin
      (asserts! (> b3 amountIn) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2 b3))
  )
)

(define-public (swap-9 (amountIn uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-diko-stackswap amountIn)))
    (b2 (unwrap-panic (swap-diko-usda-arkadiko b1)))
    (b3 (unwrap-panic (swap-usda-wstx-stackswap b2)))
  )
    (begin
      (asserts! (> b3 amountIn) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2 b3))
  )
)

(define-public (swap-10 (amountIn uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-diko-stackswap amountIn)))
    (b2 (unwrap-panic (swap-diko-usda-arkadiko b1)))
    (b3 (unwrap-panic (swap-usda-wstx-arkadiko b2)))
  )
    (begin
      (asserts! (> b3 amountIn) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2 b3))
  )
)

(define-public (mine-many (amountIn uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-xbtc-arkadiko amountIn)))
    (b2 (unwrap-panic (swap-xbtc-usda-arkadiko b1)))
    (b3 (unwrap-panic (swap-usda-wstx-arkadiko b2)))
  )
    (begin
      (asserts! (> b3 amountIn) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2 b3))
  )
)

(define-public (swap-12 (amountIn uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-xbtc-arkadiko amountIn)))
    (b2 (unwrap-panic (swap-xbtc-usda-arkadiko b1)))
    (b3 (unwrap-panic (swap-usda-wstx-stackswap b2)))
  )
    (begin
      (asserts! (> b3 amountIn) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2 b3))
  )
)

(define-public (mint (amountIn uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-xbtc-alex amountIn)))
    (b2 (unwrap-panic (swap-xbtc-usda-arkadiko b1)))
    (b3 (unwrap-panic (swap-usda-wstx-arkadiko b2)))
  )
    (begin
      (asserts! (> (* b3 u100) amountIn) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2 b3))
  )
)

(define-public (swap-14 (amountIn uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-xbtc-alex amountIn)))
    (b2 (unwrap-panic (swap-xbtc-usda-arkadiko b1)))
    (b3 (unwrap-panic (swap-usda-wstx-stackswap b2)))
  )
    (begin
      (asserts! (> (* b3 u100) amountIn) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2 b3))
  )
)

(define-public (mint-nft (amountIn uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-usda-arkadiko amountIn)))
    (b2 (unwrap-panic (swap-usda-xbtc-arkadiko b1)))
    (b3 (unwrap-panic (swap-xbtc-wstx-arkadiko b2)))
  )
    (begin
      (asserts! (> b3 amountIn) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2 b3))
  )
)

(define-public (send-many (amountIn uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-usda-arkadiko amountIn)))
    (b2 (unwrap-panic (swap-usda-xbtc-arkadiko b1)))
    (b3 (unwrap-panic (swap-xbtc-wstx-alex b2)))
  )
    (begin
      (asserts! (> b3 (* amountIn u100)) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2 b3))
  )
)

(define-public (accept-collection-bid (amountIn uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-usda-arkadiko amountIn)))
    (b2 (unwrap-panic (swap-usda-diko-arkadiko b1)))
    (b3 (unwrap-panic (swap-diko-wstx-arkadiko b2)))
  )
    (begin
      (asserts! (> b3 amountIn) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2 b3))
  )
)

(define-public (swap-18 (amountIn uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-usda-arkadiko amountIn)))
    (b2 (unwrap-panic (swap-usda-diko-arkadiko b1)))
    (b3 (unwrap-panic (swap-diko-wstx-stackswap b2)))
  )
    (begin
      (asserts! (> b3 amountIn) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2 b3))
  )
)

(define-public (swap-19 (amountIn uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-usda-stackswap amountIn)))
    (b2 (unwrap-panic (swap-usda-diko-arkadiko b1)))
    (b3 (unwrap-panic (swap-diko-wstx-arkadiko b2)))
  )
    (begin
      (asserts! (> b3 amountIn) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2 b3))
  )
)

(define-public (swap-20 (amountIn uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-usda-stackswap amountIn)))
    (b2 (unwrap-panic (swap-usda-diko-arkadiko b1)))
    (b3 (unwrap-panic (swap-diko-wstx-stackswap b2)))
  )
    (begin
      (asserts! (> b3 amountIn) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2 b3))
  )
)

(define-public (swap-21 (amountIn uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-usda-stackswap amountIn)))
    (b2 (unwrap-panic (swap-usda-xbtc-arkadiko b1)))
    (b3 (unwrap-panic (swap-xbtc-wstx-arkadiko b2)))
  )
    (begin
      (asserts! (> b3 amountIn) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2 b3))
  )
)

(define-public (swap-22 (amountIn uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-usda-stackswap amountIn)))
    (b2 (unwrap-panic (swap-usda-xbtc-arkadiko b1)))
    (b3 (unwrap-panic (swap-xbtc-wstx-alex b2)))
  )
    (begin
      (asserts! (> b3 (* amountIn u100)) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2 b3))
  )
)

;;four
(define-public (buy-in-ustx (amountIn uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-diko-arkadiko amountIn)))
    (b2 (unwrap-panic (swap-diko-usda-arkadiko b1)))
    (b3 (unwrap-panic (swap-usda-xbtc-arkadiko b2)))
    (b4 (unwrap-panic (swap-xbtc-wstx-alex b3)))
  )
    (begin
      (asserts! (> b4 (* amountIn u100)) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2 b3 b4))
  )
)

(define-public (sell-in-ustx (amountIn uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-diko-arkadiko amountIn)))
    (b2 (unwrap-panic (swap-diko-usda-arkadiko b1)))
    (b3 (unwrap-panic (swap-usda-xbtc-arkadiko b2)))
    (b4 (unwrap-panic (swap-xbtc-wstx-arkadiko b3)))
  )
    (begin
      (asserts! (> b4 amountIn) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2 b3 b4))
  )
)

(define-public (swap-25 (amountIn uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-diko-stackswap amountIn)))
    (b2 (unwrap-panic (swap-diko-usda-arkadiko b1)))
    (b3 (unwrap-panic (swap-usda-xbtc-arkadiko b2)))
    (b4 (unwrap-panic (swap-xbtc-wstx-alex b3)))
  )
    (begin
      (asserts! (> b4 (* amountIn u100)) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2 b3 b4))
  )
)

(define-public (swap-26 (amountIn uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-diko-stackswap amountIn)))
    (b2 (unwrap-panic (swap-diko-usda-arkadiko b1)))
    (b3 (unwrap-panic (swap-usda-xbtc-arkadiko b2)))
    (b4 (unwrap-panic (swap-xbtc-wstx-arkadiko b3)))
  )
    (begin
      (asserts! (> b4 amountIn) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2 b3 b4))
  )
)

(define-public (buy-item (amountIn uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-xbtc-arkadiko amountIn)))
    (b2 (unwrap-panic (swap-xbtc-usda-arkadiko b1)))
    (b3 (unwrap-panic (swap-usda-diko-arkadiko b2)))
    (b4 (unwrap-panic (swap-diko-wstx-arkadiko b3)))
  )
    (begin
      (asserts! (> b4 amountIn) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2 b3 b4))
  )
)

(define-public (sell-item (amountIn uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-xbtc-alex amountIn)))
    (b2 (unwrap-panic (swap-xbtc-usda-arkadiko b1)))
    (b3 (unwrap-panic (swap-usda-diko-arkadiko b2)))
    (b4 (unwrap-panic (swap-diko-wstx-arkadiko b3)))
  )
    (begin
      (asserts! (> (* b4 u100) amountIn) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2 b3 b4))
  )
)

(define-public (swap-29 (amountIn uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-xbtc-arkadiko amountIn)))
    (b2 (unwrap-panic (swap-xbtc-usda-arkadiko b1)))
    (b3 (unwrap-panic (swap-usda-diko-arkadiko b2)))
    (b4 (unwrap-panic (swap-diko-wstx-stackswap b3)))
  )
    (begin
      (asserts! (> b4 amountIn) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2 b3 b4))
  )
)

(define-public (swap-30 (amountIn uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-xbtc-alex amountIn)))
    (b2 (unwrap-panic (swap-xbtc-usda-arkadiko b1)))
    (b3 (unwrap-panic (swap-usda-diko-arkadiko b2)))
    (b4 (unwrap-panic (swap-diko-wstx-stackswap b3)))
  )
    (begin
      (asserts! (> (* b4 u100) amountIn) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2 b3 b4))
  )
)

(define-public (release-collection-bid (amountIn uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-usda-arkadiko amountIn)))
    (b2 (unwrap-panic (swap-usda-alex-alex (* b1 u100))))
    (b3 (unwrap-panic (swap-alex-wstx-alex b2)))
  )
    (begin
      (asserts! (> b3 (* amountIn u100)) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2 b3))
  )
)

(define-public (unlist-collection-bid (amountIn uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-alex-alex amountIn)))
    (b2 (unwrap-panic (swap-alex-usda-alex b1)))
    (b3 (unwrap-panic (swap-usda-wstx-arkadiko (/ b2 u100))))
  )
    (begin
      (asserts! (> (* b3 u100) amountIn) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2 b3))
  )
)

(define-public (unlist-in-usda (amountIn uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-usda-arkadiko amountIn)))
    (b2 (unwrap-panic (swap-usda-wstx-cryptomate b1)))
  )
    (print { b1: b1, b2: b2 })
    (begin
      (asserts! (> b2 amountIn) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2))
  )
)

(define-public (unlist-in-stx (amountIn uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-usda-cryptomate amountIn)))
    (b2 (unwrap-panic (swap-usda-wstx-arkadiko b1)))
  )
    (print { b1: b1, b2: b2 })
    (begin
      (asserts! (> b2 amountIn) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2))
  )
)

(define-public (release-bid (amountIn uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-usda-cryptomate amountIn)))
    (b2 (unwrap-panic (swap-usda-alex-alex (* b1 u100))))
    (b3 (unwrap-panic (swap-alex-wstx-alex b2)))
  )
    (print { b1: b1, b2: b2, b3: b3 })
    (begin
      (asserts! (> b3 (* amountIn u100)) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2 b3))
  )
)

(define-public (unlist-bid (amountIn uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-alex-alex (* amountIn u100))))
    (b2 (unwrap-panic (swap-alex-usda-alex b1)))
    (b3 (unwrap-panic (swap-usda-wstx-cryptomate (/ b2 u100))))
  )
    (print { b1: b1, b2: b2, b3: b3 })
    (begin
      (asserts! (> b3 amountIn) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2 b3))
  )
)

(define-public (claim-mining-rewards (amountIn uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-xbtc-alex (* amountIn u100))))
    (b2 (unwrap-panic (swap-xbtc-wstx-cryptomate b1)))
  )
    (print { b1: b1, b2: b2 })
    (begin
      (asserts! (> b2 amountIn) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2))
  )
)

(define-public (unlist-stx (amountIn uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-xbtc-cryptomate amountIn)))
    (b2 (unwrap-panic (swap-xbtc-wstx-alex b1)))
  )
    (print { b1: b1, b2: b2 })
    (begin
      (asserts! (> b2 (* amountIn u100)) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2))
  )
)

(define-public (claim-rewards (amountIn uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-xbtc-arkadiko amountIn)))
    (b2 (unwrap-panic (swap-xbtc-wstx-cryptomate b1)))
  )
    (print { b1: b1, b2: b2 })
    (begin
      (asserts! (> b2 amountIn) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2))
  )
)

(define-public (claim-reward (amountIn uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-xbtc-cryptomate amountIn)))
    (b2 (unwrap-panic (swap-xbtc-wstx-arkadiko b1)))
  )
    (print { b1: b1, b2: b2 })
    (begin
      (asserts! (> b2 amountIn) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2))
  )
)


;; Stackswap
(define-public (swap-wstx-usda-stackswap (dx uint))
  (let ((r (unwrap-panic (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5k0yl5ot8l dx u0))))
  (ok (unwrap-panic (element-at r u1))))
)

(define-public (swap-usda-wstx-stackswap (dx uint))
  (let ((r (unwrap-panic (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5k0yl5ot8l dx u0))))
  (ok (unwrap-panic (element-at r u1))))
)

(define-public (swap-wstx-diko-stackswap (dx uint))
  (let ((r (unwrap-panic (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kt9nmle8c dx u0))))
  (ok (unwrap-panic (element-at r u1))))
)

(define-public (swap-diko-wstx-stackswap (dx uint))
  (let ((r (unwrap-panic (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kt9nmle8c dx u0))))
  (ok (unwrap-panic (element-at r u1))))
)


;; Arkadiko
(define-public (swap-wstx-usda-arkadiko (dx uint))
  (let ((r (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token dx u0))))
  (ok (unwrap-panic (element-at r u1))))
)

(define-public (swap-usda-wstx-arkadiko (dx uint))
  (let ((r (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token dx u0))))
  (ok (unwrap-panic (element-at r u0))))
)

(define-public (swap-diko-usda-arkadiko (dx uint))
  (let ((r (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token dx u0))))
  (ok (unwrap-panic (element-at r u1))))
)

(define-public (swap-usda-diko-arkadiko (dx uint))
  (let ((r (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token dx u0))))
  (ok (unwrap-panic (element-at r u0))))
)

(define-public (swap-wstx-diko-arkadiko (dx uint))
  (let ((r (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token dx u0))))
  (ok (unwrap-panic (element-at r u1))))
)

(define-public (swap-diko-wstx-arkadiko (dx uint))
  (let ((r (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token dx u0))))
  (ok (unwrap-panic (element-at r u0))))
)

(define-public (swap-wstx-xbtc-arkadiko (dx uint))
  (let ((r (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token 'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin dx u0))))
  (ok (unwrap-panic (element-at r u1))))
)

(define-public (swap-xbtc-wstx-arkadiko (dx uint))
  (let ((r (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token 'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin dx u0))))
  (ok (unwrap-panic (element-at r u0))))
)

(define-public (swap-xbtc-usda-arkadiko (dx uint))
  (let ((r (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y 'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token dx u0))))
  (ok (unwrap-panic (element-at r u1))))
)

(define-public (swap-usda-xbtc-arkadiko (dx uint))
  (let ((r (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token dx u0))))
  (ok (unwrap-panic (element-at r u0))))
)

;;Alex
(define-public (swap-wstx-xbtc-alex (dx uint))
  (let ((r (unwrap-panic (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.fixed-weight-pool-v1-01 swap-x-for-y 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wbtc u50000000 u50000000 dx (some u0)))))
  (ok (get dy r)))
)

(define-public (swap-xbtc-wstx-alex (dx uint))
  (let ((r (unwrap-panic (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.fixed-weight-pool-v1-01 swap-y-for-x 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wbtc u50000000 u50000000 dx (some u0)))))
  (ok (get dx r)))
)

(define-public (swap-wstx-alex-alex (dx uint))
  (let ((r (unwrap-panic (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.fixed-weight-pool-v1-01 swap-x-for-y 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token u50000000 u50000000 dx (some u0)))))
  (ok (get dy r)))
)

(define-public (swap-alex-wstx-alex (dx uint))
  (let ((r (unwrap-panic (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.fixed-weight-pool-v1-01 swap-y-for-x 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token u50000000 u50000000 dx (some u0)))))
  (ok (get dx r)))
)

(define-public (swap-alex-usda-alex (dx uint))
  (let ((r (unwrap-panic (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.simple-weight-pool-alex swap-x-for-y 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wusda dx (some u0)))))
  (ok (get dy r)))
)

(define-public (swap-usda-alex-alex (dx uint))
  (let ((r (unwrap-panic (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.simple-weight-pool-alex swap-y-for-x 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wusda dx (some u0)))))
  (ok (get dx r)))
)

;; Cryptomate
(define-public (swap-wstx-usda-cryptomate (dx uint))
  (let ((r (unwrap-panic (contract-call? 'SP32NTG209B861QBHF4TH0C86QB0A12TY2F16WHMY.cryptomate-swap swap-x-for-y 'SP32NTG209B861QBHF4TH0C86QB0A12TY2F16WHMY.wstx-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token 'SP32NTG209B861QBHF4TH0C86QB0A12TY2F16WHMY.liquidity-token3 dx u0))))
  (ok (unwrap-panic (element-at r u1))))
)

(define-public (swap-usda-wstx-cryptomate (dx uint))
  (let ((r (unwrap-panic (contract-call? 'SP32NTG209B861QBHF4TH0C86QB0A12TY2F16WHMY.cryptomate-swap swap-y-for-x 'SP32NTG209B861QBHF4TH0C86QB0A12TY2F16WHMY.wstx-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token 'SP32NTG209B861QBHF4TH0C86QB0A12TY2F16WHMY.liquidity-token3 dx u0))))
  (ok (unwrap-panic (element-at r u0))))
)

(define-public (swap-wstx-xbtc-cryptomate (dx uint))
  (let ((r (unwrap-panic (contract-call? 'SP32NTG209B861QBHF4TH0C86QB0A12TY2F16WHMY.cryptomate-swap swap-x-for-y 'SP32NTG209B861QBHF4TH0C86QB0A12TY2F16WHMY.wstx-token 'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin 'SP32NTG209B861QBHF4TH0C86QB0A12TY2F16WHMY.liquidity-token5 dx u0))))
  (ok (unwrap-panic (element-at r u1))))
)

(define-public (swap-xbtc-wstx-cryptomate (dx uint))
  (let ((r (unwrap-panic (contract-call? 'SP32NTG209B861QBHF4TH0C86QB0A12TY2F16WHMY.cryptomate-swap swap-y-for-x 'SP32NTG209B861QBHF4TH0C86QB0A12TY2F16WHMY.wstx-token 'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin 'SP32NTG209B861QBHF4TH0C86QB0A12TY2F16WHMY.liquidity-token5 dx u0))))
  (ok (unwrap-panic (element-at r u0))))
)