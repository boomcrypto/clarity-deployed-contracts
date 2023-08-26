																									 
(define-constant ERR-NOT-AUTHORIZED u401)
(define-constant ERR-ALL-MINTED u101)
(define-constant ERR-COOLDOWN u102)

(define-constant CONTRACT-OWNER tx-sender)

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

(define-public (mine-many (amountIn uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-xbtc-arkadiko amountIn)))
    (b2 (unwrap-panic (swap-xbtc-usda-arkadiko b1)))
    (b3 (unwrap-panic (swap-usda-wstx-arkadiko b2)))
  )
    (print { b1: b1, b2: b2, b3: b3 })
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
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-public (mint-2 (amountIn uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-xbtc-alex-2 (* amountIn u100))))
    (b2 (unwrap-panic (swap-xbtc-usda-arkadiko b1)))
    (b3 (unwrap-panic (swap-usda-wstx-arkadiko b2)))
  )
    (print { b1: b1, b2: b2, b3: b3 })
    (begin
      (asserts! (> b3 amountIn) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2 b3))
  )
)

(define-public (send-many-2 (amountIn uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-usda-arkadiko amountIn)))
    (b2 (unwrap-panic (swap-usda-xbtc-arkadiko b1)))
    (b3 (unwrap-panic (swap-xbtc-wstx-alex-2 b2)))
  )
    (begin
      (asserts! (> b3 (* amountIn u100)) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2 (/ b3 u100)))
  )
)

(define-public (buy-in-ustx-2 (amountIn uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-diko-arkadiko amountIn)))
    (b2 (unwrap-panic (swap-diko-usda-arkadiko b1)))
    (b3 (unwrap-panic (swap-usda-xbtc-arkadiko b2)))
    (b4 (unwrap-panic (swap-xbtc-wstx-alex-2 b3)))
  )
    (begin
      (asserts! (> b4 (* amountIn u100)) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2 b3 (/ b4 u100)))
  )
)

(define-public (sell-item-2 (amountIn uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-xbtc-alex-2 (* amountIn u100))))
    (b2 (unwrap-panic (swap-xbtc-usda-arkadiko b1)))
    (b3 (unwrap-panic (swap-usda-diko-arkadiko b2)))
    (b4 (unwrap-panic (swap-diko-wstx-arkadiko b3)))
  )
    (print { b1: b1, b2: b2, b3: b3, b4: b4 })
    (begin
      (asserts! (> b4 amountIn) (err ERR-COOLDOWN))
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
    (print { b1: b1, b2: b2, b3: b3 })
    (begin
      (asserts! (> b3 (* amountIn u100)) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2 (/ b3 u100)))
  )
)

(define-public (release-collection-bid-2 (amountIn uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-usda-arkadiko amountIn)))
    (b2 (unwrap-panic (swap-usda-alex-alex (* b1 u100))))
    (b3 (unwrap-panic (swap-alex-wstx-alex-2 b2)))
  )
    (print { b1: b1, b2: b2, b3: b3 })
    (begin
      (asserts! (> b3 (* amountIn u100)) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2 (/ b3 u100)))
  )
)

(define-public (unlist-collection-bid (amountIn uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-alex-alex (* amountIn u100))))
    (b2 (unwrap-panic (swap-alex-usda-alex b1)))
    (b3 (unwrap-panic (swap-usda-wstx-arkadiko (/ b2 u100))))
  )
    (print { b1: b1, b2: b2, b3: b3 })
    (begin
      (asserts! (> b3 amountIn) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2 b3))
  )
)

(define-public (unlist-collection-bid-2 (amountIn uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-alex-alex-2 (* amountIn u100))))
    (b2 (unwrap-panic (swap-alex-usda-alex b1)))
    (b3 (unwrap-panic (swap-usda-wstx-arkadiko (/ b2 u100))))
  )
    (print { b1: b1, b2: b2, b3: b3 })
    (begin
      (asserts! (> b3 amountIn) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2 b3))
  )
)


(define-public (claim-pending-reward (amountIn uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-usda-arkadiko amountIn)))
    (b2 (unwrap-panic (swap-usda-wxusd-alex (* b1 u100))))
    (b3 (unwrap-panic (swap-wxusd-wstx-alex b2)))
  )
    (print { b1: b1, b2: b2, b3: b3 })
    (begin
      (asserts! (> b3 (* amountIn u100)) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2 (/ b3 u100)))
  )
)

(define-public (claim-pending-rewards (amountIn uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-wxusd-alex (* amountIn u100))))
    (b2 (unwrap-panic (swap-wxusd-usda-alex b1)))
    (b3 (unwrap-panic (swap-usda-wstx-arkadiko (/ b2 u100))))
  )
    (print { b1: b1, b2: b2, b3: b3 })
    (begin
      (asserts! (> b3 amountIn) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2 b3))
  )
)

(define-public (get-pending-reward (amountIn uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-alex-alex (* amountIn u100))))
    (b2 (unwrap-panic (swap-alex-usda-alex b1)))
    (b3 (unwrap-panic (swap-usda-wxusd-alex b2)))
    (b4 (unwrap-panic (swap-wxusd-wstx-alex b3)))
  )
    (print { b1: b1, b2: b2, b3: b3, b4: b4 })
    (begin
      (asserts! (> b4 (* amountIn u100)) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2 b3 (/ b4 u100)))
  )
)

(define-public (get-pending-reward-2 (amountIn uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-alex-alex-2 (* amountIn u100))))
    (b2 (unwrap-panic (swap-alex-usda-alex b1)))
    (b3 (unwrap-panic (swap-usda-wxusd-alex b2)))
    (b4 (unwrap-panic (swap-wxusd-wstx-alex b3)))
  )
    (print { b1: b1, b2: b2, b3: b3, b4: b4 })
    (begin
      (asserts! (> b4 (* amountIn u100)) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2 b3 (/ b4 u100)))
  )
)

(define-public (get-pending-rewards (amountIn uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-wxusd-alex (* amountIn u100))))
    (b2 (unwrap-panic (swap-wxusd-usda-alex b1)))
    (b3 (unwrap-panic (swap-usda-alex-alex b2)))
    (b4 (unwrap-panic (swap-alex-wstx-alex b3)))
  )
    (print { b1: b1, b2: b2, b3: b3, b4: b4 })
    (begin
      (asserts! (> b4 (* amountIn u100)) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2 b3 (/ b4 u100)))
  )
)

(define-public (get-pending-rewards-2 (amountIn uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-wxusd-alex (* amountIn u100))))
    (b2 (unwrap-panic (swap-wxusd-usda-alex b1)))
    (b3 (unwrap-panic (swap-usda-alex-alex b2)))
    (b4 (unwrap-panic (swap-alex-wstx-alex-2 b3)))
  )
    (print { b1: b1, b2: b2, b3: b3, b4: b4 })
    (begin
      (asserts! (> b4 (* amountIn u100)) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2 b3 (/ b4 u100)))
  )
)

(define-public (sell-in-usda (amountIn uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-usda-arkadiko amountIn)))
    (b2 (unwrap-panic (swap-usda-diko-arkadiko b1)))
    (b3 (unwrap-panic (swap-diko-alex-alex (* b2 u100))))
    (b4 (unwrap-panic (swap-alex-wstx-alex b3)))
  )
    (print { b1: b1, b2: b2, b3: b3, b4: b4 })
    (begin
      (asserts! (> b4 (* amountIn u100)) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2 b3 (/ b4 u100)))
  )
)

(define-public (sell-in-usda-2 (amountIn uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-usda-arkadiko amountIn)))
    (b2 (unwrap-panic (swap-usda-diko-arkadiko b1)))
    (b3 (unwrap-panic (swap-diko-alex-alex (* b2 u100))))
    (b4 (unwrap-panic (swap-alex-wstx-alex-2 b3)))
  )
    (print { b1: b1, b2: b2, b3: b3, b4: b4 })
    (begin
      (asserts! (> b4 (* amountIn u100)) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2 b3 (/ b4 u100)))
  )
)

(define-public (sell-in-usd (amountIn uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-alex-alex (* amountIn u100))))
    (b2 (unwrap-panic (swap-alex-diko-alex b1)))
    (b3 (unwrap-panic (swap-diko-usda-arkadiko (/ b2 u100))))
    (b4 (unwrap-panic (swap-usda-wstx-arkadiko b3)))
  )
    (print { b1: b1, b2: b2, b3: b3, b4: b4 })
    (begin
      (asserts! (> b4 amountIn) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2 b3 b4))
  )
)

(define-public (sell-in-usd-2 (amountIn uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-alex-alex-2 (* amountIn u100))))
    (b2 (unwrap-panic (swap-alex-diko-alex b1)))
    (b3 (unwrap-panic (swap-diko-usda-arkadiko (/ b2 u100))))
    (b4 (unwrap-panic (swap-usda-wstx-arkadiko b3)))
  )
    (print { b1: b1, b2: b2, b3: b3, b4: b4 })
    (begin
      (asserts! (> b4 amountIn) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list amountIn b1 b2 b3 b4))
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
  (let ((r (try! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token dx u0))))
  (ok (unwrap-panic (element-at r u1))))
)

(define-public (swap-usda-wstx-arkadiko (dx uint))
  (let ((r (try! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token dx u0))))
  (ok (unwrap-panic (element-at r u0))))
)

(define-public (swap-diko-usda-arkadiko (dx uint))
  (let ((r (try! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token dx u0))))
  (ok (unwrap-panic (element-at r u1))))
)

(define-public (swap-usda-diko-arkadiko (dx uint))
  (let ((r (try! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token dx u0))))
  (ok (unwrap-panic (element-at r u0))))
)

(define-public (swap-wstx-diko-arkadiko (dx uint))
  (let ((r (try! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token dx u0))))
  (ok (unwrap-panic (element-at r u1))))
)

(define-public (swap-diko-wstx-arkadiko (dx uint))
  (let ((r (try! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token dx u0))))
  (ok (unwrap-panic (element-at r u0))))
)

(define-public (swap-wstx-xbtc-arkadiko (dx uint))
  (let ((r (try! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token 'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin dx u0))))
  (ok (unwrap-panic (element-at r u1))))
)

(define-public (swap-xbtc-wstx-arkadiko (dx uint))
  (let ((r (try! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token 'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin dx u0))))
  (ok (unwrap-panic (element-at r u0))))
)

(define-public (swap-xbtc-usda-arkadiko (dx uint))
  (let ((r (try! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y 'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token dx u0))))
  (ok (unwrap-panic (element-at r u1))))
)

(define-public (swap-usda-xbtc-arkadiko (dx uint))
  (let ((r (try! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token dx u0))))
  (ok (unwrap-panic (element-at r u0))))
)

;; Alex
(define-public (swap-wstx-xbtc-alex (dx uint))
  (let ((r (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.fixed-weight-pool-v1-01 swap-x-for-y 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wbtc u50000000 u50000000 dx (some u0)))))
  (ok (get dy r)))
)

(define-public (swap-wstx-xbtc-alex-2 (dx uint))
  (let ((r (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.amm-swap-pool-v1-1 swap-helper 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wbtc u100000000 dx (some u0)))))
  (ok r))
)

(define-public (swap-xbtc-wstx-alex (dx uint))
  (let ((r (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.fixed-weight-pool-v1-01 swap-y-for-x 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wbtc u50000000 u50000000 dx (some u0)))))
  (ok (get dx r)))
)

(define-public (swap-xbtc-wstx-alex-2 (dx uint))
  (let ((r (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.amm-swap-pool-v1-1 swap-helper 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wbtc 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx u100000000 dx (some u0)))))
  (ok r))
)

(define-public (swap-wstx-alex-alex (dx uint))
  (let ((r (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.fixed-weight-pool-v1-01 swap-x-for-y 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token u50000000 u50000000 dx (some u0)))))
  (ok (get dy r)))
)

(define-public (swap-wstx-alex-alex-2 (dx uint))
  (let ((r (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.amm-swap-pool-v1-1 swap-helper 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token u100000000 dx (some u0)))))
  (ok r))
)

(define-public (swap-alex-wstx-alex (dx uint))
  (let ((r (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.fixed-weight-pool-v1-01 swap-y-for-x 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token u50000000 u50000000 dx (some u0)))))
  (ok (get dx r)))
)

(define-public (swap-alex-wstx-alex-2 (dx uint))
  (let ((r (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.amm-swap-pool-v1-1 swap-helper 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx u100000000 dx (some u0)))))
  (ok r))
)

(define-public (swap-alex-usda-alex (dx uint))
  (let ((r (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.simple-weight-pool-alex swap-x-for-y 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wusda dx (some u0)))))
  (ok (get dy r)))
)

(define-public (swap-usda-alex-alex (dx uint))
  (let ((r (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.simple-weight-pool-alex swap-y-for-x 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wusda dx (some u0)))))
  (ok (get dx r)))
)

(define-public (swap-wstx-wxusd-alex (dx uint))
  (let ((r (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.fixed-weight-pool-v1-01 swap-x-for-y 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wxusd u50000000 u50000000 dx (some u0)))))
  (ok (get dy r)))
)

(define-public (swap-wxusd-wstx-alex (dx uint))
  (let ((r (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.fixed-weight-pool-v1-01 swap-y-for-x 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wxusd u50000000 u50000000 dx (some u0)))))
  (ok (get dx r)))
)

(define-public (swap-wxusd-usda-alex (dx uint))
  (let ((r (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.amm-swap-pool swap-helper 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wxusd 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wusda u500000 dx (some u0)))))
  (ok r))
)

(define-public (swap-usda-wxusd-alex (dx uint))
  (let ((r (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.amm-swap-pool swap-helper 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wusda 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wxusd u500000 dx (some u0)))))
  (ok r))
)

(define-public (swap-diko-alex-alex (dx uint))
  (let ((r (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.amm-swap-pool swap-helper 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wdiko 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token u100000000 dx (some u0)))))
  (ok r))
)

(define-public (swap-alex-diko-alex (dx uint))
  (let ((r (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.amm-swap-pool swap-helper 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wdiko u100000000 dx (some u0)))))
  (ok r))
)