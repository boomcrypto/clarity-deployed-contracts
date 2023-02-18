;; Title: CCD002 Treasury
;; Version: 1.0.0
;; Summary: A treasury contract that can manage STX, SIP-009 NFTs, and SIP-010 FTs.
;; Description: An extension contract that holds assets on behalf of the DAO. SIP-009 and SIP-010 assets must be allowed before they are supported. Deposits can be made by anyone either by transferring to the contract or using a deposit function below. Withdrawals are restricted to the DAO through either extensions or proposals.

;; TRAITS

(impl-trait .extension-trait.extension-trait)
(impl-trait .stacking-trait.stacking-trait)
(impl-trait .ccd002-trait.ccd002-treasury-trait)
(use-trait ft-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)
(use-trait nft-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

;; CONSTANTS

(define-constant ERR_UNAUTHORIZED (err u2000))
(define-constant ERR_UNKNOWN_ASSSET (err u2001))
(define-constant TREASURY (as-contract tx-sender))

;; DATA MAPS

(define-map AllowedAssets principal bool)

;; PUBLIC FUNCTIONS

(define-public (is-dao-or-extension)
  (ok (asserts! (or (is-eq tx-sender .base-dao)
    (contract-call? .base-dao is-extension contract-caller)) ERR_UNAUTHORIZED
  ))
)

(define-public (callback (sender principal) (memo (buff 34)))
  (ok true)
)

(define-public (set-allowed (token principal) (enabled bool))
  (begin
    (try! (is-dao-or-extension))
    (print {
      event: "allow-asset",
      enabled: enabled,
      token: token
    })
    (ok (map-set AllowedAssets token enabled))
  )
)

(define-public (set-allowed-list (allowList (list 100 {token: principal, enabled: bool})))
  (begin
    (try! (is-dao-or-extension))
    (ok (map set-allowed-iter allowList))
  )
)

(define-public (deposit-stx (amount uint))
  (begin
    (print {
      event: "deposit-stx",
      amount: amount,
      caller: contract-caller,
      recipient: TREASURY,
      sender: tx-sender
    })
    (stx-transfer? amount tx-sender TREASURY)
  )
)

(define-public (deposit-ft (ft <ft-trait>) (amount uint))
  (begin
    (asserts! (is-allowed (contract-of ft)) ERR_UNKNOWN_ASSSET)
    (print {
      event: "deposit-ft",
      amount: amount,
      assetContract: (contract-of ft),
      caller: contract-caller,
      recipient: TREASURY,
      sender: tx-sender
    })
    (contract-call? ft transfer amount tx-sender TREASURY none)
  )
)

(define-public (deposit-nft (nft <nft-trait>) (id uint))
  (begin
    (asserts! (is-allowed (contract-of nft)) ERR_UNKNOWN_ASSSET)
    (print {
      event: "deposit-nft",
      assetContract: (contract-of nft),
      caller: contract-caller,
      recipient: TREASURY,
      sender: tx-sender,
      tokenId: id,
    })
    (contract-call? nft transfer id tx-sender TREASURY)
  )
)

(define-public (withdraw-stx (amount uint) (recipient principal))
  (begin
    (try! (is-dao-or-extension))
    (print {
      event: "withdraw-stx",
      amount: amount,
      caller: contract-caller,
      recipient: recipient,
      sender: tx-sender
    })
    (as-contract (stx-transfer? amount TREASURY recipient))
  )
)

(define-public (withdraw-ft (ft <ft-trait>) (amount uint) (recipient principal))
  (begin
    (try! (is-dao-or-extension))
    (asserts! (is-allowed (contract-of ft)) ERR_UNKNOWN_ASSSET)
    (print {
      event: "withdraw-ft",
      assetContract: (contract-of ft),
      caller: contract-caller,
      recipient: recipient,
      sender: tx-sender
    })
    (as-contract (contract-call? ft transfer amount TREASURY recipient none))
  )
)

(define-public (withdraw-nft (nft <nft-trait>) (id uint) (recipient principal))
  (begin
    (try! (is-dao-or-extension))
    (asserts! (is-allowed (contract-of nft)) ERR_UNKNOWN_ASSSET)
    (print {
      event: "withdraw-nft",
      assetContract: (contract-of nft),
      caller: contract-caller,
      recipient: recipient,
      sender: tx-sender,
      tokenId: id
    })
    (as-contract (contract-call? nft transfer id TREASURY recipient))
  )
)

(define-public (delegate-stx (maxAmount uint) (to principal))
  (begin
    (try! (is-dao-or-extension))
    (print {
      event: "delegate-stx",
      amount: maxAmount,
      caller: contract-caller,
      delegate: to,
      sender: tx-sender
    })
    (match (as-contract (contract-call? 'SP000000000000000000002Q6VF78.pox delegate-stx maxAmount to none none))
      success (ok success)
      err (err (to-uint err))
    )
  )
)

(define-public (revoke-delegate-stx)
  (begin
    (try! (is-dao-or-extension))
    (print {
      event: "revoke-delegate-stx",
      caller: contract-caller,
      sender: tx-sender
    })
    (match (as-contract (contract-call? 'SP000000000000000000002Q6VF78.pox revoke-delegate-stx))
      success (ok success)
      err (err (to-uint err))
    )
  )
)

;; READ ONLY FUNCTIONS

(define-read-only (is-allowed (assetContract principal))
  (default-to false (get-allowed-asset assetContract))
)

(define-read-only (get-allowed-asset (assetContract principal))
  (map-get? AllowedAssets assetContract)
)

(define-read-only (get-balance-stx)
  (stx-get-balance TREASURY)
)

;; PRIVATE FUNCTIONS

(define-private (set-allowed-iter (item {token: principal, enabled: bool}))
  (begin
    (print {
      event: "allow-asset",
      enabled: (get enabled item),
      token: (get token item)
    })
    (map-set AllowedAssets (get token item) (get enabled item))
  )
)
