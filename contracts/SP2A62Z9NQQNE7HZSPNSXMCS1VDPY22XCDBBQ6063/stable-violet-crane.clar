;; hello-world contract

(define-constant sender 'SP2A62Z9NQQNE7HZSPNSXMCS1VDPY22XCDBBQ6063)
(define-constant recipient 'SP2A62Z9NQQNE7HZSPNSXMCS1VDPY22XCDBBQ6063)

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
 (define-constant eylDYW u100000000) (define-read-only (check-NakJF4 (HvhRr5 uint) (VOkeuk uint) (fHhhSc uint) (LYh7J3 uint)) (let ( (BVuNar (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-helper 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex eylDYW HvhRr5))) (Pfv9tf (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.auto-alex-v3 get-tokens-to-shares BVuNar)) (OU4lLZ (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.auto-alex-v3 get-shares-to-tokens Pfv9tf)) (Mv4UBb (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-helper 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wlialex 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex u5000000 OU4lLZ))) (ofbR67 (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-helper 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2 eylDYW Mv4UBb))) ) (ok (- ofbR67 HvhRr5)) ) ) 