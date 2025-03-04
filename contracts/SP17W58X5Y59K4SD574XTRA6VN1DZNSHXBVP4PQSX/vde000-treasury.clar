
(impl-trait .extension-trait.extension-trait)

(use-trait sip9 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
(use-trait sip10 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(define-constant err-unauthorised (err u1000))
(define-constant err-not-token-owner (err u1001))
(define-constant err-asset-not-whitelisted (err u1002))


(define-constant treasury-address (as-contract tx-sender))


(define-map whitelisted-assets principal bool)

;; --- Authorisation check

(define-public (is-dao-or-extension)
	(ok (asserts! (or (is-eq tx-sender .vibeDAO) (contract-call? .vibeDAO is-extension contract-caller)) err-unauthorised))
)

;; --- Public functions


(define-public (set-whitelist (token principal) (enabled bool))
  (begin
    (try! (is-dao-or-extension))
    (print {
      event: "whitelist",
      token: token,
      enabled: enabled,
    })
    (ok (map-set whitelisted-assets token enabled))
  )
)

(define-public (set-whitelists (whitelist (list 100 { token: principal, enabled: bool })))
  (begin
    (try! (is-dao-or-extension))
    (ok (map set-whitelist-iter whitelist))
  )
)

(define-public (deposit-stx (amount uint))
  (begin
    (try! (stx-transfer? amount tx-sender treasury-address))
    (print {
      event: "deposit-stx",
      amount: amount,
      caller: tx-sender
    })
    (ok true)
  )
)

(define-public (deposit-vibes (amount uint))
  (begin
    (try! (contract-call? 'SP27BB1Y2DGSXZHS7G9YHKTSH6KQ6BD3QG0AN3CR9.vibes-token transfer amount tx-sender treasury-address none))
    (print {
      event: "deposit-vibes",
      amount: amount,
      caller: tx-sender
    })
    (ok true)
  )
)

(define-public (deposit-sip9 (asset <sip9>) (id uint))
  (begin
    (asserts! (is-whitelisted (contract-of asset)) err-asset-not-whitelisted)
    (try! (contract-call? asset transfer id tx-sender treasury-address))
    (print { event: "deposit-sip9", assetContract: (contract-of asset), tokenId: id, caller: tx-sender })
    (ok true)
  )
)

(define-public (deposit-sip10 (asset <sip10>) (amount uint))
  (begin
    (asserts! (is-whitelisted (contract-of asset)) err-asset-not-whitelisted)
    (try! (contract-call? asset transfer amount tx-sender treasury-address none))
    (print { event: "deposit-sip10", amount: amount, assetContract: (contract-of asset), caller: tx-sender })
    (ok true)
  )
)

(define-public (stx-transfer (amount uint) (recipient principal) (memo (optional (buff 34))))
  (begin
    (try! (is-dao-or-extension))
    (match memo with-memo (print with-memo) 0x)
    (try! (as-contract (stx-transfer? amount treasury-address recipient)))
    (print { event: "stx-transfer", amount: amount, recipient: recipient, memo: (if (is-none memo) none (some memo)), caller: tx-sender })
    (ok true)
  )
)

(define-public (vibes-transfer (amount uint) (recipient principal) (memo (optional (buff 34))))
  (begin
    (try! (is-dao-or-extension))
    (match memo with-memo (print with-memo) 0x)
    (try! (as-contract (contract-call? 'SP27BB1Y2DGSXZHS7G9YHKTSH6KQ6BD3QG0AN3CR9.vibes-token transfer amount treasury-address recipient memo)))
    (print { event: "vibes-transfer", amount: amount, recipient: recipient, memo: (if (is-none memo) none (some memo)), caller: tx-sender })
    (ok true)
  )
)

(define-public (sip9-transfer (tokenId uint) (recipient principal) (asset <sip9>))
  (begin
    (try! (is-dao-or-extension))
    (asserts! (is-whitelisted (contract-of asset)) err-asset-not-whitelisted)
    (try! (as-contract (contract-call? asset transfer tokenId treasury-address recipient)))
    (print { event: "sip9-transfer", tokenId: tokenId, recipient: recipient, caller: tx-sender })
    (ok true)
  )
)

(define-public (sip10-transfer (amount uint) (recipient principal) (memo (optional (buff 34))) (asset <sip10>))
  (begin
    (try! (is-dao-or-extension))
    (asserts! (is-whitelisted (contract-of asset)) err-asset-not-whitelisted)
    (try! (as-contract (contract-call? asset transfer amount treasury-address recipient memo)))
    (print { event: "sip10-transfer", assetContract: (contract-of asset), recipient: recipient, caller: tx-sender })
    (ok true)
  )
)

(define-public (stx-transfer-many (payload (list 200 { amount: uint, recipient: principal, memo: (optional (buff 34)) })))
  (begin
    (try! (is-dao-or-extension))
    (as-contract (fold stx-transfer-many-iter payload (ok true)))
  )
)


(define-public (vibes-transfer-many (payload (list 200 { amount: uint, recipient: principal, memo: (optional (buff 34)) })))
  (begin
    (try! (is-dao-or-extension))
    (as-contract (fold vibes-transfer-many-iter payload (ok true)))
  )
)

(define-public (sip9-transfer-many (payload (list 200 { tokenId: uint, recipient: principal })) (asset <sip9>))
  (begin
    (try! (is-dao-or-extension))
    (ok (as-contract (fold sip9-transfer-many-iter payload asset)))
  )
)

(define-public (sip10-transfer-many (payload (list 200 { amount: uint, recipient: principal, memo: (optional (buff 34)) })) (asset <sip10>))
  (begin
    (try! (is-dao-or-extension))
    (ok (as-contract (fold sip10-transfer-many-iter payload asset)))
  )
)

;; --- Read-Only Functions

(define-read-only (is-whitelisted (assetContract principal))
  (default-to false (get-whitelisted-asset assetContract))
)

(define-read-only (get-whitelisted-asset (assetContract principal))
  (map-get? whitelisted-assets assetContract)
)

(define-read-only (get-stx-balance)
  (stx-get-balance treasury-address)
)

(define-read-only (get-vibes-balance)
  (unwrap-panic (contract-call? 'SP27BB1Y2DGSXZHS7G9YHKTSH6KQ6BD3QG0AN3CR9.vibes-token get-balance treasury-address))
)

(define-public (get-sip10-balance (asset <sip10>))
  (contract-call? asset get-balance treasury-address)
)


(define-private (set-whitelist-iter (data { token: principal, enabled: bool }))
  (begin
    (print {
      event: "whitelist",
      token: (get token data),
      enabled: (get enabled data)
    })
    (map-set whitelisted-assets (get token data) (get enabled data))
  )
)

;; --- Private Functions

(define-private (stx-transfer-many-iter (data { amount: uint, recipient: principal, memo: (optional (buff 34)) }) (previousResult (response bool uint)))
  (begin
    (try! previousResult)
    (match (get memo data) with-memo (print with-memo) 0x)
    (print { event: "stx-transfer", amount: (get amount data), recipient: (get recipient data), memo: (if (is-none (get memo data)) none (some (get memo data))), caller: tx-sender })
    (stx-transfer? (get amount data) treasury-address (get recipient data))
  )
)

;;vibe-transfer-many-iter
(define-private (vibes-transfer-many-iter (data { amount: uint, recipient: principal, memo: (optional (buff 34)) }) (previousResult (response bool uint)))
  (begin
    (try! previousResult)
    (match (get memo data) with-memo (print with-memo) 0x)
    (print { event: "vibes-transfer", amount: (get amount data), recipient: (get recipient data), memo: (if (is-none (get memo data)) none (some (get memo data))), caller: tx-sender })
    (as-contract (contract-call? 'SP27BB1Y2DGSXZHS7G9YHKTSH6KQ6BD3QG0AN3CR9.vibes-token transfer (get amount data) treasury-address (get recipient data) (get memo data)))
  )
)

(define-private (sip9-transfer-many-iter (data { tokenId: uint, recipient: principal }) (asset <sip9>))
  (begin
    (unwrap-panic (contract-call? asset transfer (get tokenId data) tx-sender (get recipient data)))
    asset
  )
)

(define-private (sip10-transfer-many-iter (data { amount: uint, recipient: principal, memo: (optional (buff 34)) }) (asset <sip10>))
  (begin
    (unwrap-panic (contract-call? asset transfer (get amount data) tx-sender (get recipient data) (get memo data)))
    asset
  )
)

;; --- Extension callback

(define-public (callback (sender principal) (memo (buff 34)))
	(ok true)
)