
;; constants
(define-constant IMAGE-HASH u"345a94125abb0a209a57943ffe043d101e810dbf52d08c892b4718613c867798")
(define-constant ERR-NOT-AUTHORIZED u401)
(define-constant ERR-ALL-MINTED u101)
(define-constant ERR-COOLDOWN u102)
(define-constant CONTRACT-OWNER tx-sender)

(define-public (a16 (a uint) (b uint) (c uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-xbtc-alex (* b u100))))
    (b2 (unwrap-panic (swap-xbtc-wstx-arkadiko b1)))
  )
    (print { b1: b1, b2: b2 })
    (begin
      (asserts! (> b2 b) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list b b1 b2))
  )
)

(define-public (a15 (a uint) (b uint) (c uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-xbtc-arkadiko b)))
    (b2 (unwrap-panic (swap-xbtc-wstx-alex b1)))
  )
    (print { b1: b1, b2: b2 })
    (begin
      (asserts! (> b2 (* b u100)) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list b b1 (/ b2 u100)))
  )
)

(define-public (a3 (a uint) (b uint) (c uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-diko-arkadiko b)))
    (b2 (unwrap-panic (swap-diko-usda-arkadiko b1)))
    (b3 (unwrap-panic (swap-usda-wstx-arkadiko b2)))
  )
    (print { b1: b1, b2: b2, b3: b3 })
    (begin
      (asserts! (> b3 b) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list b b1 b2 b3))
  )
)

(define-public (a5 (a uint) (b uint) (c uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-xbtc-arkadiko b)))
    (b2 (unwrap-panic (swap-xbtc-usda-arkadiko b1)))
    (b3 (unwrap-panic (swap-usda-wstx-arkadiko b2)))
  )
    (print { b1: b1, b2: b2, b3: b3 })
    (begin
      (asserts! (> b3 b) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list b b1 b2 b3))
  )
)

(define-public (a38 (a uint) (b uint) (c uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-xbtc-alex (* b u100))))
    (b2 (unwrap-panic (swap-xbtc-usda-arkadiko b1)))
    (b3 (unwrap-panic (swap-usda-wstx-arkadiko b2)))
  )
    (print { b1: b1, b2: b2, b3: b3 })
    (begin
      (asserts! (> b3 b) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list b b1 b2 b3))
  )
)

(define-public (a10 (a uint) (b uint) (c uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-xbtc-alex-2 (* b u100))))
    (b2 (unwrap-panic (swap-xbtc-usda-arkadiko b1)))
    (b3 (unwrap-panic (swap-usda-wstx-arkadiko b2)))
  )
    (print { b1: b1, b2: b2, b3: b3 })
    (begin
      (asserts! (> b3 b) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list b b1 b2 b3))
  )
)

(define-public (a4 (a uint) (b uint) (c uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-usda-arkadiko b)))
    (b2 (unwrap-panic (swap-usda-xbtc-arkadiko b1)))
    (b3 (unwrap-panic (swap-xbtc-wstx-arkadiko b2)))
  )
    (print { b1: b1, b2: b2, b3: b3 })
    (begin
      (asserts! (> b3 b) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list b b1 b2 b3))
  )
)

(define-public (a9 (a uint) (b uint) (c uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-usda-arkadiko b)))
    (b2 (unwrap-panic (swap-usda-xbtc-arkadiko b1)))
    (b3 (unwrap-panic (swap-xbtc-wstx-alex b2)))
  )
    (print { b1: b1, b2: b2, b3: b3 })
    (begin
      (asserts! (> b3 (* b u100)) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list b b1 b2 (/ b3 u100)))
  )
)

(define-public (a8 (a uint) (b uint) (c uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-usda-arkadiko b)))
    (b2 (unwrap-panic (swap-usda-xbtc-arkadiko b1)))
    (b3 (unwrap-panic (swap-xbtc-wstx-alex-2 b2)))
  )
    (print { b1: b1, b2: b2, b3: b3 })
    (begin
      (asserts! (> b3 (* b u100)) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list b b1 b2 (/ b3 u100)))
  )
)

(define-public (a2 (a uint) (b uint) (c uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-usda-arkadiko b)))
    (b2 (unwrap-panic (swap-usda-diko-arkadiko b1)))
    (b3 (unwrap-panic (swap-diko-wstx-arkadiko b2)))
  )
    (print { b1: b1, b2: b2, b3: b3 })
    (begin
      (asserts! (> b3 b) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list b b1 b2 b3))
  )
)

(define-public (a12 (a uint) (b uint) (c uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-diko-arkadiko b)))
    (b2 (unwrap-panic (swap-diko-usda-arkadiko b1)))
    (b3 (unwrap-panic (swap-usda-xbtc-arkadiko b2)))
    (b4 (unwrap-panic (swap-xbtc-wstx-alex b3)))
  )
    (print { b1: b1, b2: b2, b3: b3, b4: b4 })
    (begin
      (asserts! (> b4 (* b u100)) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list b b1 b2 b3 (/ b4 u100)))
  )
)

(define-public (a11 (a uint) (b uint) (c uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-diko-arkadiko b)))
    (b2 (unwrap-panic (swap-diko-usda-arkadiko b1)))
    (b3 (unwrap-panic (swap-usda-xbtc-arkadiko b2)))
    (b4 (unwrap-panic (swap-xbtc-wstx-alex-2 b3)))
  )
    (print { b1: b1, b2: b2, b3: b3, b4: b4 })
    (begin
      (asserts! (> b4 (* b u100)) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list b b1 b2 b3 (/ b4 u100)))
  )
)

(define-public (a6 (a uint) (b uint) (c uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-diko-arkadiko b)))
    (b2 (unwrap-panic (swap-diko-usda-arkadiko b1)))
    (b3 (unwrap-panic (swap-usda-xbtc-arkadiko b2)))
    (b4 (unwrap-panic (swap-xbtc-wstx-arkadiko b3)))
  )
    (print { b1: b1, b2: b2, b3: b3, b4: b4 })
    (begin
      (asserts! (> b4 b) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list b b1 b2 b3 b4))
  )
)

(define-public (a7 (a uint) (b uint) (c uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-xbtc-arkadiko b)))
    (b2 (unwrap-panic (swap-xbtc-usda-arkadiko b1)))
    (b3 (unwrap-panic (swap-usda-diko-arkadiko b2)))
    (b4 (unwrap-panic (swap-diko-wstx-arkadiko b3)))
  )
    (print { b1: b1, b2: b2, b3: b3, b4: b4 })
    (begin
      (asserts! (> b4 b) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list b b1 b2 b3 b4))
  )
)

(define-public (a14 (a uint) (b uint) (c uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-xbtc-alex (* b u100))))
    (b2 (unwrap-panic (swap-xbtc-usda-arkadiko b1)))
    (b3 (unwrap-panic (swap-usda-diko-arkadiko b2)))
    (b4 (unwrap-panic (swap-diko-wstx-arkadiko b3)))
  )
    (print { b1: b1, b2: b2, b3: b3, b4: b4 })
    (begin
      (asserts! (> b4 b) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list b b1 b2 b3 b4))
  )
)

(define-public (a13 (a uint) (b uint) (c uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-xbtc-alex-2 (* b u100))))
    (b2 (unwrap-panic (swap-xbtc-usda-arkadiko b1)))
    (b3 (unwrap-panic (swap-usda-diko-arkadiko b2)))
    (b4 (unwrap-panic (swap-diko-wstx-arkadiko b3)))
  )
    (print { b1: b1, b2: b2, b3: b3, b4: b4 })
    (begin
      (asserts! (> b4 b) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list b b1 b2 b3 b4))
  )
)

(define-public (a20 (a uint) (b uint) (c uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-usda-arkadiko b)))
    (b2 (unwrap-panic (swap-usda-alex-alex (* b1 u100))))
    (b3 (unwrap-panic (swap-alex-wstx-alex b2)))
  )
    (print { b1: b1, b2: b2, b3: b3 })
    (begin
      (asserts! (> b3 (* b u100)) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list b b1 b2 (/ b3 u100)))
  )
)

(define-public (a19 (a uint) (b uint) (c uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-usda-arkadiko b)))
    (b2 (unwrap-panic (swap-usda-alex-alex (* b1 u100))))
    (b3 (unwrap-panic (swap-alex-wstx-alex-2 b2)))
  )
    (print { b1: b1, b2: b2, b3: b3 })
    (begin
      (asserts! (> b3 (* b u100)) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list b b1 b2 (/ b3 u100)))
  )
)

(define-public (a18 (a uint) (b uint) (c uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-alex-alex (* b u100))))
    (b2 (unwrap-panic (swap-alex-usda-alex b1)))
    (b3 (unwrap-panic (swap-usda-wstx-arkadiko (/ b2 u100))))
  )
    (print { b1: b1, b2: b2, b3: b3 })
    (begin
      (asserts! (> b3 b) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list b b1 b2 b3))
  )
)

(define-public (a17 (a uint) (b uint) (c uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-alex-alex-2 (* b u100))))
    (b2 (unwrap-panic (swap-alex-usda-alex b1)))
    (b3 (unwrap-panic (swap-usda-wstx-arkadiko (/ b2 u100))))
  )
    (print { b1: b1, b2: b2, b3: b3 })
    (begin
      (asserts! (> b3 b) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list b b1 b2 b3))
  )
)

(define-public (a31 (a uint) (b uint) (c uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-usda-arkadiko b)))
    (b2 (unwrap-panic (swap-usda-wstx-cryptomate b1)))
  )
    (print { b1: b1, b2: b2 })
    (begin
      (asserts! (> b2 b) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list b b1 b2))
  )
)

(define-public (ua32 (a uint) (b uint) (c uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-usda-cryptomate b)))
    (b2 (unwrap-panic (swap-usda-wstx-arkadiko b1)))
  )
    (print { b1: b1, b2: b2 })
    (begin
      (asserts! (> b2 b) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list b b1 b2))
  )
)

(define-public (a33 (a uint) (b uint) (c uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-usda-cryptomate b)))
    (b2 (unwrap-panic (swap-usda-alex-alex (* b1 u100))))
    (b3 (unwrap-panic (swap-alex-wstx-alex b2)))
  )
    (print { b1: b1, b2: b2, b3: b3 })
    (begin
      (asserts! (> b3 (* b u100)) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list b b1 b2 (/ b3 u100)))
  )
)

(define-public (a34 (a uint) (b uint) (c uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-alex-alex (* b u100))))
    (b2 (unwrap-panic (swap-alex-usda-alex b1)))
    (b3 (unwrap-panic (swap-usda-wstx-cryptomate (/ b2 u100))))
  )
    (print { b1: b1, b2: b2, b3: b3 })
    (begin
      (asserts! (> b3 b) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list b b1 b2 b3))
  )
)

(define-public (a1 (a uint) (b uint) (c uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-xbtc-alex (* b u100))))
    (b2 (unwrap-panic (swap-xbtc-wstx-cryptomate b1)))
  )
    (print { b1: b1, b2: b2 })
    (begin
      (asserts! (> b2 b) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list b b1 b2))
  )
)

(define-public (a37 (a uint) (b uint) (c uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-xbtc-cryptomate b)))
    (b2 (unwrap-panic (swap-xbtc-wstx-alex b1)))
  )
    (print { b1: b1, b2: b2 })
    (begin
      (asserts! (> b2 (* b u100)) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list b b1 b2))
  )
)

(define-public (a35 (a uint) (b uint) (c uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-xbtc-arkadiko b)))
    (b2 (unwrap-panic (swap-xbtc-wstx-cryptomate b1)))
  )
    (print { b1: b1, b2: b2 })
    (begin
      (asserts! (> b2 b) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list b b1 b2))
  )
)

(define-public (a36 (a uint) (b uint) (c uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-xbtc-cryptomate b)))
    (b2 (unwrap-panic (swap-xbtc-wstx-arkadiko b1)))
  )
    (print { b1: b1, b2: b2 })
    (begin
      (asserts! (> b2 b) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list b b1 b2))
  )
)

(define-public (a26 (a uint) (b uint) (c uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-usda-arkadiko b)))
    (b2 (unwrap-panic (swap-usda-wxusd-alex (* b1 u100))))
    (b3 (unwrap-panic (swap-wxusd-wstx-alex b2)))
  )
    (print { b1: b1, b2: b2, b3: b3 })
    (begin
      (asserts! (> b3 (* b u100)) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list b b1 b2 (/ b3 u100)))
  )
)

(define-public (a21 (a uint) (b uint) (c uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-wxusd-alex (* b u100))))
    (b2 (unwrap-panic (swap-wxusd-usda-alex b1)))
    (b3 (unwrap-panic (swap-usda-wstx-arkadiko (/ b2 u100))))
  )
    (print { b1: b1, b2: b2, b3: b3 })
    (begin
      (asserts! (> b3 b) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list b b1 b2 b3))
  )
)

(define-public (a25 (a uint) (b uint) (c uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-alex-alex (* b u100))))
    (b2 (unwrap-panic (swap-alex-usda-alex b1)))
    (b3 (unwrap-panic (swap-usda-wxusd-alex b2)))
    (b4 (unwrap-panic (swap-wxusd-wstx-alex b3)))
  )
    (print { b1: b1, b2: b2, b3: b3, b4: b4 })
    (begin
      (asserts! (> b4 (* b u100)) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list b b1 b2 b3 (/ b4 u100)))
  )
)

(define-public (a22 (a uint) (b uint) (c uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-alex-alex-2 (* b u100))))
    (b2 (unwrap-panic (swap-alex-usda-alex b1)))
    (b3 (unwrap-panic (swap-usda-wxusd-alex b2)))
    (b4 (unwrap-panic (swap-wxusd-wstx-alex b3)))
  )
    (print { b1: b1, b2: b2, b3: b3, b4: b4 })
    (begin
      (asserts! (> b4 (* b u100)) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list b b1 b2 b3 (/ b4 u100)))
  )
)

(define-public (a24 (a uint) (b uint) (c uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-wxusd-alex (* b u100))))
    (b2 (unwrap-panic (swap-wxusd-usda-alex b1)))
    (b3 (unwrap-panic (swap-usda-alex-alex b2)))
    (b4 (unwrap-panic (swap-alex-wstx-alex b3)))
  )
    (print { b1: b1, b2: b2, b3: b3, b4: b4 })
    (begin
      (asserts! (> b4 (* b u100)) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list b b1 b2 b3 (/ b4 u100)))
  )
)

(define-public (a23 (a uint) (b uint) (c uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-wxusd-alex (* b u100))))
    (b2 (unwrap-panic (swap-wxusd-usda-alex b1)))
    (b3 (unwrap-panic (swap-usda-alex-alex b2)))
    (b4 (unwrap-panic (swap-alex-wstx-alex-2 b3)))
  )
    (print { b1: b1, b2: b2, b3: b3, b4: b4 })
    (begin
      (asserts! (> b4 (* b u100)) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list b b1 b2 b3 (/ b4 u100)))
  )
)

(define-public (a28 (a uint) (b uint) (c uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-usda-arkadiko b)))
    (b2 (unwrap-panic (swap-usda-diko-arkadiko b1)))
    (b3 (unwrap-panic (swap-diko-alex-alex (* b2 u100))))
    (b4 (unwrap-panic (swap-alex-wstx-alex b3)))
  )
    (print { b1: b1, b2: b2, b3: b3, b4: b4 })
    (begin
      (asserts! (> b4 (* b u100)) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list b b1 b2 b3 (/ b4 u100)))
  )
)

(define-public (a27 (a uint) (b uint) (c uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-usda-arkadiko b)))
    (b2 (unwrap-panic (swap-usda-diko-arkadiko b1)))
    (b3 (unwrap-panic (swap-diko-alex-alex (* b2 u100))))
    (b4 (unwrap-panic (swap-alex-wstx-alex-2 b3)))
  )
    (print { b1: b1, b2: b2, b3: b3, b4: b4 })
    (begin
      (asserts! (> b4 (* b u100)) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list b b1 b2 b3 (/ b4 u100)))
  )
)

(define-public (a30 (a uint) (b uint) (c uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-alex-alex (* b u100))))
    (b2 (unwrap-panic (swap-alex-diko-alex b1)))
    (b3 (unwrap-panic (swap-diko-usda-arkadiko (/ b2 u100))))
    (b4 (unwrap-panic (swap-usda-wstx-arkadiko b3)))
  )
    (print { b1: b1, b2: b2, b3: b3, b4: b4 })
    (begin
      (asserts! (> b4 b) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list b b1 b2 b3 b4))
  )
)

(define-public (a29 (a uint) (b uint) (c uint))
  (let (
    (b1 (unwrap-panic (swap-wstx-alex-alex-2 (* b u100))))
    (b2 (unwrap-panic (swap-alex-diko-alex b1)))
    (b3 (unwrap-panic (swap-diko-usda-arkadiko (/ b2 u100))))
    (b4 (unwrap-panic (swap-usda-wstx-arkadiko b3)))
  )
    (print { b1: b1, b2: b2, b3: b3, b4: b4 })
    (begin
      (asserts! (> b4 b) (err ERR-COOLDOWN))
      (asserts! (is-eq CONTRACT-OWNER tx-sender) (err ERR-ALL-MINTED))
    )
    (ok (list b b1 b2 b3 b4))
  )
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

;; Cryptomate
(define-public (swap-wstx-usda-cryptomate (dx uint))
  (let ((r (try! (contract-call? 'SP32NTG209B861QBHF4TH0C86QB0A12TY2F16WHMY.cryptomate-swap swap-x-for-y 'SP32NTG209B861QBHF4TH0C86QB0A12TY2F16WHMY.wstx-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token 'SP32NTG209B861QBHF4TH0C86QB0A12TY2F16WHMY.liquidity-token3 dx u0))))
  (ok (unwrap-panic (element-at r u1))))
)

(define-public (swap-usda-wstx-cryptomate (dx uint))
  (let ((r (try! (contract-call? 'SP32NTG209B861QBHF4TH0C86QB0A12TY2F16WHMY.cryptomate-swap swap-y-for-x 'SP32NTG209B861QBHF4TH0C86QB0A12TY2F16WHMY.wstx-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token 'SP32NTG209B861QBHF4TH0C86QB0A12TY2F16WHMY.liquidity-token3 dx u0))))
  (ok (unwrap-panic (element-at r u0))))
)

(define-public (swap-wstx-xbtc-cryptomate (dx uint))
  (let ((r (try! (contract-call? 'SP32NTG209B861QBHF4TH0C86QB0A12TY2F16WHMY.cryptomate-swap swap-x-for-y 'SP32NTG209B861QBHF4TH0C86QB0A12TY2F16WHMY.wstx-token 'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin 'SP32NTG209B861QBHF4TH0C86QB0A12TY2F16WHMY.liquidity-token5 dx u0))))
  (ok (unwrap-panic (element-at r u1))))
)

(define-public (swap-xbtc-wstx-cryptomate (dx uint))
  (let ((r (try! (contract-call? 'SP32NTG209B861QBHF4TH0C86QB0A12TY2F16WHMY.cryptomate-swap swap-y-for-x 'SP32NTG209B861QBHF4TH0C86QB0A12TY2F16WHMY.wstx-token 'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin 'SP32NTG209B861QBHF4TH0C86QB0A12TY2F16WHMY.liquidity-token5 dx u0))))
  (ok (unwrap-panic (element-at r u0))))
)