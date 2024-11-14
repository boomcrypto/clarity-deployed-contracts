---
title: "Trait stacking-dao-cc-nft-minter"
draft: true
---
```
;; @contract Stacking DAO CC (NYC) NFT
;; @version 2
;;
;; Stacking DAO CC (NYC) NFT minter
;; 

;;-------------------------------------
;; Constants
;;-------------------------------------

(define-constant ERR_NOT_AUTHORIZED u1101)

;;-------------------------------------
;; Variables 
;;-------------------------------------

(define-data-var deployer principal tx-sender)

;;-------------------------------------
;; Set 
;;-------------------------------------

(define-public (set-deployer (new-deployer principal))
  (begin
    (asserts! (is-eq tx-sender (var-get deployer)) (err ERR_NOT_AUTHORIZED))

    (var-set deployer new-deployer)
    (ok true)
  )
)

;;-------------------------------------
;; Airdrop
;;-------------------------------------

(define-public (airdrop (info (tuple (recipient principal) (type uint))))
  (let (
    (recipient (get recipient info))
    (type (get type info))
  )
    (asserts! (is-eq tx-sender (var-get deployer)) (err ERR_NOT_AUTHORIZED))
    (try! (contract-call? .stacking-dao-cc-nft mint-for-protocol recipient type))
    (ok true)
  )
)

(define-public (airdrop-many (recipients (list 25 (tuple (recipient principal) (type uint)))))
  (begin
    (asserts! (is-eq tx-sender (var-get deployer)) (err ERR_NOT_AUTHORIZED))
    (ok (map airdrop recipients))
  )
)

```
