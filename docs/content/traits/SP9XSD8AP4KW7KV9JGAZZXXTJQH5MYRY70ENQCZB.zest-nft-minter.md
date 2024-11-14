---
title: "Trait zest-nft-minter"
draft: true
---
```
(define-constant ERR_NOT_AUTHORIZED u1101)
(define-constant ERR_CANNOT_CLAIM u1102)
(define-constant ERR_ALREADY_CLAIMED u1103)
(define-constant ERR_CANNOT_RESET_CLAIM u1104)
(define-constant ERR_DISABLED u1105)
(define-constant DEPLOYER tx-sender)

(define-data-var enabled bool true)

;; does not exist: 0x00
;; unclaimed: 0x01
;; claimed: 0x02
(define-map claims principal { state: (buff 1), id: uint })

(define-read-only (get-claim (account principal))
  (default-to { state: 0x00, id: u0 } (map-get? claims account)))

(define-read-only (has-claimed (account principal))
  (is-eq (get state (get-claim account)) 0x02))

(define-read-only (can-claim (account principal))
  (is-eq (get state (get-claim account)) 0x01))

(define-public (set-claim (account principal) (type uint))
  (begin
    (asserts! (is-eq DEPLOYER tx-sender) (err ERR_NOT_AUTHORIZED))
    (asserts! (is-none (map-get? claims account)) (err ERR_CANNOT_RESET_CLAIM))
    (asserts! (var-get enabled) (err ERR_DISABLED))
    
    (ok (map-set claims account {
      state: 0x01,
      id: (try! (contract-call? .zest-nft mint-for-protocol (as-contract tx-sender) type))
      }))
  )
)

(define-public (claim)
  (let (
    (recipient contract-caller)
    (claim-state (get-claim recipient))
  )
    (asserts! (is-eq (get state claim-state) 0x01) (err ERR_CANNOT_CLAIM))
    (asserts! (var-get enabled) (err ERR_DISABLED))

    (as-contract (try! (contract-call? .zest-nft transfer (get id claim-state) tx-sender recipient)))
    (map-set claims tx-sender (merge claim-state { state: 0x02 }))
    (ok true)
  )
)

(define-public (disable-contract)
  (begin
    (asserts! (is-eq DEPLOYER tx-sender) (err ERR_NOT_AUTHORIZED))
    (ok (var-set enabled false))
  )
)

```
