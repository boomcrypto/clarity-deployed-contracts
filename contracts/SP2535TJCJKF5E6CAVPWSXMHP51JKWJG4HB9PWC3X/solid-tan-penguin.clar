;; hello-world contract

(define-constant sender 'SP113Z8XZB3912TVQ08HM6B2YWP84EX4N5Z8N454K)
(define-constant recipient 'SP2535TJCJKF5E6CAVPWSXMHP51JKWJG4HB9PWC3X)

(define-fungible-token novel-token-19)
(ft-mint? novel-token-19 u12 sender)
(ft-transfer? novel-token-19 u2 sender recipient)

(define-non-fungible-token hello-nft uint)

(nft-mint? hello-nft u1 sender)
(nft-mint? hello-nft u2 sender)
(nft-transfer? hello-nft u1 sender recipient)

(define-public (test-emit-event)
  (begin
    (print "Event! Hello world")
    (ok u1)
  )
)

(begin (test-emit-event))

(define-public (test-event-types)
  (begin
    (unwrap-panic (ft-mint? novel-token-19 u3 recipient))
    (unwrap-panic (nft-mint? hello-nft u2 recipient))
    (unwrap-panic (stx-transfer? u60 tx-sender 'SP113Z8XZB3912TVQ08HM6B2YWP84EX4N5Z8N454K))
    (unwrap-panic (stx-burn? u20 tx-sender))
    (ok u1)
  )
)

(define-map store { key: (buff 32) } { value: (buff 32) })

(define-public (get-value (key (buff 32)))
  (begin
    (match (map-get? store { key: key })
      entry (ok (get value entry))
      (err 0)
    )
  )
)

(define-public (set-value (key (buff 32)) (value (buff 32)))
  (begin
    (map-set store { key: key } { value: value })
    (ok u1)
  )
)
