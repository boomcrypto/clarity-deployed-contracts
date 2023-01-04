
;; TRAITS

(impl-trait 'SPX9XMC02T56N9PRXV4AM9TS88MMQ6A1Z3375MHD.extension-trait.extension-trait)

;; CONSTANTS

(use-trait sip9 'SPX9XMC02T56N9PRXV4AM9TS88MMQ6A1Z3375MHD.sip9-trait.sip9-trait)
(use-trait sip10 'SPX9XMC02T56N9PRXV4AM9TS88MMQ6A1Z3375MHD.sip10-trait.sip10-trait)

(define-constant ERR_UNAUTHORIZED (err u2000))
(define-constant ERR_ASSET_NOT_ALLOWED (err u2001))
(define-constant TREASURY (as-contract tx-sender))

;; DATA MAPS AND VARS

(define-map AllowedAssets
  principal ;; token contract
  bool      ;; enabled
)

;; Authorization Check

(define-public (is-dao-or-extension)
  (ok (asserts!
    (or
      (is-eq tx-sender 'SPFP7J5S351CGCPBS2BX06HRF0WF3BYKQEZCGBW5.wooden-purple-turtle)
      (contract-call? 'SPFP7J5S351CGCPBS2BX06HRF0WF3BYKQEZCGBW5.wooden-purple-turtle is-extension contract-caller))
    ERR_UNAUTHORIZED
  ))
)

;; Internal DAO functions

(define-public (set-allowed (token principal) (enabled bool))
  (begin
    (try! (is-dao-or-extension))
    (print {
      event: "allow-asset",
      token: token,
      enabled: enabled
    })
    (ok (map-set AllowedAssets token enabled))
  )
)

(define-private (set-allowed-iter (item {token: principal, enabled: bool}))
  (begin
    (print {
      event: "allow-asset",
      token: (get token item),
      enabled: (get enabled item)
    })
    (map-set AllowedAssets (get token item) (get enabled item))
  )
)

(define-public (set-allowed-list (allowList (list 100 {token: principal, enabled: bool})))
  (begin
    (try! (is-dao-or-extension))
    (ok (map set-allowed-iter allowList))
  )
)

;; Deposit functions

(define-public (deposit-stx (amount uint))
  (begin
    (try! (stx-transfer? amount tx-sender TREASURY))
    (print {
      event: "deposit-stx",
      amount: amount,
      caller: contract-caller,
      sender: tx-sender,
      recipient: TREASURY
    })
    (ok true)
  )
)

(define-public (deposit-ft (ft <sip10>) (amount uint))
  (begin
    (asserts! (is-allowed (contract-of ft)) ERR_ASSET_NOT_ALLOWED)
    (try! (contract-call? ft transfer amount tx-sender TREASURY none))
    (print {
      event: "deposit-ft",
      amount: amount,
      assetContract: (contract-of ft),
      caller: contract-caller,
      sender: tx-sender,
      recipient: TREASURY
    })
    (ok true)
  )
)

(define-public (deposit-nft (nft <sip9>) (id uint))
  (begin
    (asserts! (is-allowed (contract-of nft)) ERR_ASSET_NOT_ALLOWED)
    (try! (contract-call? nft transfer id tx-sender TREASURY))
    (print {
      event: "deposit-nft",
      assetContract: (contract-of nft),
      tokenId: id,
      caller: contract-caller,
      sender: tx-sender,
      recipient: TREASURY
    })
    (ok true)
  )
)

;; Withdraw functions

(define-public (withdraw-stx (amount uint) (recipient principal))
  (begin
    (try! (is-dao-or-extension))
    (try! (as-contract (stx-transfer? amount TREASURY recipient)))
    (print {
      event: "withdraw-stx",
      amount: amount,
      caller: contract-caller,
      sender: tx-sender,
      recipient: recipient
    })
    (ok true)
  )
)

(define-public (withdraw-ft (ft <sip10>) (amount uint) (recipient principal))
  (begin
    (try! (is-dao-or-extension))
    (asserts! (is-allowed (contract-of ft)) ERR_ASSET_NOT_ALLOWED)
    (try! (as-contract (contract-call? ft transfer amount TREASURY recipient none)))
    (print {
      event: "withdraw-ft",
      assetContract: (contract-of ft),
      caller: contract-caller,
      sender: tx-sender,
      recipient: recipient
    })
    (ok true)
  )
)

(define-public (withdraw-nft (nft <sip9>) (id uint) (recipient principal))
  (begin
    (try! (is-dao-or-extension))
    (asserts! (is-allowed (contract-of nft)) ERR_ASSET_NOT_ALLOWED)
    (try! (as-contract (contract-call? nft transfer id TREASURY recipient)))
    (print {
      event: "withdraw-nft",
      assetContract: (contract-of nft),
      tokenId: id,
      caller: contract-caller,
      sender: tx-sender,
      recipient: recipient
    })
    (ok true)
  )
)

(define-public (withdraw-many-stx (payload (list 200 { amount: uint, recipient: principal, memo: (optional (buff 34)) })))
  (begin
    (try! (is-dao-or-extension))
    (as-contract (fold withdraw-many-stx-iter payload (ok true)))
  )
)

(define-public (withdraw-many-nft (payload (list 200 { tokenId: uint, recipient: principal })) (asset <sip9>))
  (begin
    (try! (is-dao-or-extension))
    (ok (as-contract (fold withdraw-many-nft-iter payload asset)))
  )
)

(define-public (withdraw-many-ft (payload (list 200 { amount: uint, recipient: principal, memo: (optional (buff 34)) })) (asset <sip10>))
  (begin
    (try! (is-dao-or-extension))
    (ok (as-contract (fold withdraw-many-ft-iter payload asset)))
  )
)

(define-private (withdraw-many-stx-iter (data { amount: uint, recipient: principal, memo: (optional (buff 34)) }) (previousResult (response bool uint)))
  (begin
    (try! previousResult)
    (match (get memo data) with-memo (print with-memo) 0x)
    (print { event: "withdraw-stx", amount: (get amount data), recipient: (get recipient data), memo: (if (is-none (get memo data)) none (some (get memo data))), caller: tx-sender })
    (stx-transfer? (get amount data) TREASURY (get recipient data))
  )
)

(define-private (withdraw-many-nft-iter (data { tokenId: uint, recipient: principal }) (asset <sip9>))
  (begin
    (unwrap-panic (contract-call? asset transfer (get tokenId data) tx-sender (get recipient data)))
    asset
  )
)

(define-private (withdraw-many-ft-iter (data { amount: uint, recipient: principal, memo: (optional (buff 34)) }) (asset <sip10>))
  (begin
    (unwrap-panic (contract-call? asset transfer (get amount data) tx-sender (get recipient data) (get memo data)))
    asset
  )
)

;; Read only functions

(define-read-only (is-allowed (assetContract principal))
  (default-to false (get-allowed-asset assetContract))
)

(define-read-only (get-allowed-asset (assetContract principal))
  (map-get? AllowedAssets assetContract)
)

(define-read-only (get-balance-stx)
  (stx-get-balance TREASURY)
)

;; Extension callback

(define-public (callback (sender principal) (memo (buff 34)))
  (ok true)
)
