---
title: "Trait geniusai-treasury"
draft: true
---
```
;; title: aibtcdev-treasury
;; version: 1.0.0
;; summary: An extension that manages STX, SIP-009 NFTs, and SIP-010 FTs.

;; traits
;;
(impl-trait 'SP29CK9990DQGE9RGTT1VEQTTYH8KY4E3JE5XP4EC.aibtcdev-dao-traits-v1.extension)
(impl-trait 'SP29CK9990DQGE9RGTT1VEQTTYH8KY4E3JE5XP4EC.aibtcdev-dao-traits-v1.treasury)

(use-trait ft-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)
(use-trait nft-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

;; constants
;;

(define-constant ERR_UNAUTHORIZED (err u6000))
(define-constant ERR_UNKNOWN_ASSSET (err u6001))
(define-constant TREASURY (as-contract tx-sender))

;; data maps
;;

(define-map AllowedAssets principal bool)

;; public functions
;;

(define-public (callback (sender principal) (memo (buff 34)))
  (ok true)
)

;; add or update an asset to the allowed list
(define-public (allow-asset (token principal) (enabled bool))
  (begin
    (try! (is-dao-or-extension))
    (print {
      notification: "allow-asset",
      payload: {
        enabled: enabled,
        token: token
      }
    })
    (ok (map-set AllowedAssets token enabled))
  )
)

;; add or update a list of assets to the allowed list
(define-public (allow-assets (allowList (list 100 {token: principal, enabled: bool})))
  (begin
    (try! (is-dao-or-extension))
    (ok (map allow-assets-iter allowList))
  )
)

;; deposit STX to the treasury
(define-public (deposit-stx (amount uint))
  (begin
    (print {
      notification: "deposit-stx",
      payload: {
        amount: amount,
        caller: contract-caller,
        recipient: TREASURY,
        sender: tx-sender
      }
    })
    (stx-transfer? amount tx-sender TREASURY)
  )
)

;; deposit FT to the treasury
(define-public (deposit-ft (ft <ft-trait>) (amount uint))
  (begin
    (asserts! (is-allowed-asset (contract-of ft)) ERR_UNKNOWN_ASSSET)
    (print {
      notification: "deposit-ft",
      payload: {
        amount: amount,
        assetContract: (contract-of ft),
        caller: contract-caller,
        recipient: TREASURY,
        sender: tx-sender
      }
    })
    (contract-call? ft transfer amount tx-sender TREASURY none)
  )
)

;; deposit NFT to the treasury
(define-public (deposit-nft (nft <nft-trait>) (id uint))
  (begin
    (asserts! (is-allowed-asset (contract-of nft)) ERR_UNKNOWN_ASSSET)
    (print {
      notification: "deposit-nft",
      payload: {
        assetContract: (contract-of nft),
        caller: contract-caller,
        recipient: TREASURY,
        sender: tx-sender,
        tokenId: id
      }
    })
    (contract-call? nft transfer id tx-sender TREASURY)
  )
)

;; withdraw STX from the treasury
(define-public (withdraw-stx (amount uint) (recipient principal))
  (begin
    (try! (is-dao-or-extension))
    (print {
      notification: "withdraw-stx",
      payload: {
        amount: amount,
        caller: contract-caller,
        recipient: recipient,
        sender: tx-sender
      }
    })
    (as-contract (stx-transfer? amount TREASURY recipient))
  )
)

;; withdraw FT from the treasury
(define-public (withdraw-ft (ft <ft-trait>) (amount uint) (recipient principal))
  (begin
    (try! (is-dao-or-extension))
    (asserts! (is-allowed-asset (contract-of ft)) ERR_UNKNOWN_ASSSET)
    (print {
      notification: "withdraw-ft",
      payload: {
        assetContract: (contract-of ft),
        caller: contract-caller,
        recipient: recipient,
        sender: tx-sender
      }
    })
    (as-contract (contract-call? ft transfer amount TREASURY recipient none))
  )
)

;; withdraw NFT from the treasury
(define-public (withdraw-nft (nft <nft-trait>) (id uint) (recipient principal))
  (begin
    (try! (is-dao-or-extension))
    (asserts! (is-allowed-asset (contract-of nft)) ERR_UNKNOWN_ASSSET)
    (print {
      notification: "withdraw-nft",
      payload: {
        assetContract: (contract-of nft),
        caller: contract-caller,
        recipient: recipient,
        sender: tx-sender,
        tokenId: id
      }
    })
    (as-contract (contract-call? nft transfer id TREASURY recipient))
  )
)

;; delegate STX for stacking
(define-public (delegate-stx (maxAmount uint) (to principal))
  (begin
    (try! (is-dao-or-extension))
    (print {
      notification: "delegate-stx",
      payload: {
        amount: maxAmount,
        caller: contract-caller,
        delegate: to,
        sender: tx-sender
      }
    })
    (match (as-contract (contract-call? 'SP000000000000000000002Q6VF78.pox-4 delegate-stx maxAmount to none none))
      success (ok success)
      err (err (to-uint err))
    )
  )
)

;; revoke STX delegation, STX unlocks after cycle ends
(define-public (revoke-delegate-stx)
  (begin
    (try! (is-dao-or-extension))
    (print {
      notification: "revoke-delegate-stx",
      payload: {
        caller: contract-caller,
        sender: tx-sender
      }
    })
    (match (as-contract (contract-call? 'SP000000000000000000002Q6VF78.pox-4 revoke-delegate-stx))
      success (begin (print success) (ok true))
      err (err (to-uint err))
    )
  )
)

;; read only functions
;;

(define-read-only (is-allowed-asset (assetContract principal))
  (default-to false (get-allowed-asset assetContract))
)

(define-read-only (get-allowed-asset (assetContract principal))
  (map-get? AllowedAssets assetContract)
)

;; private functions
;;

(define-private (is-dao-or-extension)
  (ok (asserts! (or (is-eq tx-sender 'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.geniusai-base-dao)
    (contract-call? 'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.geniusai-base-dao is-extension contract-caller)) ERR_UNAUTHORIZED
  ))
)

(define-private (allow-assets-iter (item {token: principal, enabled: bool}))
  (begin
    (print {
      notification: "allow-asset",
      payload: {
        enabled: (get enabled item),
        token: (get token item)
      }
    })
    (map-set AllowedAssets (get token item) (get enabled item))
  )
)


```
