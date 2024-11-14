---
title: "Trait sft-test-2"
draft: true
---
```
(impl-trait .sft-traits.sip013-semi-fungible-token-trait)
(impl-trait .sft-traits.sip013-transfer-many-trait)

(define-constant contract-owner tx-sender)

(define-fungible-token wrapped-sip010-sft)
(define-non-fungible-token semi-fungible-token-id {token-id: uint, owner: principal})

(define-data-var token-name (string-ascii 32) "Corgi Soldier")
(define-data-var token-symbol (string-ascii 10) "cCS")
(define-data-var token-uri (string-ascii 80) "https://charisma.rocks/creatures/json/")

(define-map token-balances {token-id: uint, owner: principal} uint)
(define-map token-supplies uint uint)
(define-map token-decimals uint uint)
(define-map asset-contract-ids principal uint)
(define-map asset-contract-whitelist principal bool)
(define-data-var asset-contract-id-nonce uint u0)

(define-constant err-owner-only (err u100))
(define-constant err-not-whitelisted (err u101))
(define-constant err-insufficient-balance (err u1))
(define-constant err-invalid-sender (err u4))

(define-trait sip010-transferable-trait
	(
		(transfer (uint principal principal (optional (buff 34))) (response bool uint))
		(get-decimals () (response uint uint))
	)
)

(define-private (set-balance (token-id uint) (balance uint) (owner principal))
	(map-set token-balances {token-id: token-id, owner: owner} balance)
)

(define-private (get-balance-uint (token-id uint) (who principal))
	(default-to u0 (map-get? token-balances {token-id: token-id, owner: who}))
)

(define-read-only (get-balance (token-id uint) (who principal))
	(ok (get-balance-uint token-id who))
)

(define-read-only (get-overall-balance (who principal))
	(ok (ft-get-balance wrapped-sip010-sft who))
)

(define-read-only (get-total-supply (token-id uint))
	(ok (default-to u0 (map-get? token-supplies token-id)))
)

(define-read-only (get-overall-supply)
	(ok (ft-get-supply wrapped-sip010-sft))
)

(define-read-only (get-name)
	(ok (var-get token-name))
)

(define-read-only (get-symbol)
	(ok (var-get token-symbol))
)

(define-read-only (get-decimals (token-id uint))
	(ok (default-to u0 (map-get? token-decimals token-id)))
)

(define-read-only (get-token-uri (token-id uint))
  	(ok (some (concat (concat (var-get token-uri) "{id}") ".json")))
)

(define-public (transfer (token-id uint) (amount uint) (sender principal) (recipient principal))
	(let
		(
			(sender-balance (get-balance-uint token-id sender))
		)
		(asserts! (or (is-eq sender tx-sender) (is-eq sender contract-caller)) err-invalid-sender)
		(asserts! (<= amount sender-balance) err-insufficient-balance)
		(try! (ft-transfer? wrapped-sip010-sft amount sender recipient))
		(try! (tag-nft-token-id {token-id: token-id, owner: sender}))
		(try! (tag-nft-token-id {token-id: token-id, owner: recipient}))
		(set-balance token-id (- sender-balance amount) sender)
		(set-balance token-id (+ (get-balance-uint token-id recipient) amount) recipient)
		(print {type: "sft_transfer", token-id: token-id, amount: amount, sender: sender, recipient: recipient})
		(ok true)
	)
)

(define-public (transfer-memo (token-id uint) (amount uint) (sender principal) (recipient principal) (memo (buff 34)))
	(begin
		(try! (transfer token-id amount sender recipient))
		(print memo)
		(ok true)
	)
)

(define-private (transfer-many-iter (item {token-id: uint, amount: uint, sender: principal, recipient: principal}) (previous-response (response bool uint)))
	(match previous-response prev-ok (transfer (get token-id item) (get amount item) (get sender item) (get recipient item)) prev-err previous-response)
)

(define-public (transfer-many (transfers (list 200 {token-id: uint, amount: uint, sender: principal, recipient: principal})))
	(fold transfer-many-iter transfers (ok true))
)

(define-private (transfer-many-memo-iter (item {token-id: uint, amount: uint, sender: principal, recipient: principal, memo: (buff 34)}) (previous-response (response bool uint)))
	(match previous-response prev-ok (transfer-memo (get token-id item) (get amount item) (get sender item) (get recipient item) (get memo item)) prev-err previous-response)
)

(define-public (transfer-many-memo (transfers (list 200 {token-id: uint, amount: uint, sender: principal, recipient: principal, memo: (buff 34)})))
	(fold transfer-many-memo-iter transfers (ok true))
)

;; Wrapping and unwrapping logic

(define-read-only (get-asset-token-id (asset-contract principal))
	(map-get? asset-contract-ids asset-contract)
)

(define-public (get-or-create-asset-token-id (sip010-asset <sip010-transferable-trait>))
	(match (get-asset-token-id (contract-of sip010-asset))
		token-id (ok token-id)
		(let
			(
				(token-id (+ (var-get asset-contract-id-nonce) u1))
			)
			(asserts! (is-whitelisted (contract-of sip010-asset)) err-not-whitelisted)
			(map-set asset-contract-ids (contract-of sip010-asset) token-id)
			(map-set token-decimals token-id (match (contract-call? sip010-asset get-decimals) decimals decimals err u0))
			(var-set asset-contract-id-nonce token-id)
			(ok token-id)
		)
	)
)

(define-public (wrap (amount uint) (sip010-asset <sip010-transferable-trait>))
	(let
		(
			(token-id (try! (get-or-create-asset-token-id sip010-asset)))
		)
		(try! (contract-call? sip010-asset transfer amount tx-sender (as-contract tx-sender) none))
		(try! (ft-mint? wrapped-sip010-sft amount tx-sender))
		(try! (tag-nft-token-id {token-id: token-id, owner: tx-sender}))
		(set-balance token-id (+ (get-balance-uint token-id tx-sender) amount) tx-sender)
		(map-set token-supplies token-id (+ (unwrap-panic (get-total-supply token-id)) amount))
		(print {type: "sft_mint", token-id: token-id, amount: amount, recipient: tx-sender})
		(ok token-id)
	)
)

(define-public (unwrap (amount uint) (recipient principal) (sip010-asset <sip010-transferable-trait>))
	(let
		(
			(token-id (try! (get-or-create-asset-token-id sip010-asset)))
			(original-sender tx-sender)
			(sender-balance (get-balance-uint token-id tx-sender))
		)
		(asserts! (<= amount sender-balance) err-insufficient-balance)
		(try! (ft-burn? wrapped-sip010-sft amount original-sender))
		(try! (as-contract (contract-call? sip010-asset transfer amount tx-sender original-sender none)))
		(set-balance token-id (- sender-balance amount) original-sender)
		(map-set token-supplies token-id (- (unwrap-panic (get-total-supply token-id)) amount))
		(print {type: "sft_burn", token-id: token-id, amount: amount, sender: original-sender})
		(ok token-id)
	)
)

(define-private (tag-nft-token-id (nft-token-id {token-id: uint, owner: principal}))
	(begin
		(and
			(is-some (nft-get-owner? semi-fungible-token-id nft-token-id))
			(try! (nft-burn? semi-fungible-token-id nft-token-id (get owner nft-token-id)))
		)
		(nft-mint? semi-fungible-token-id nft-token-id (get owner nft-token-id))
	)
)

(define-read-only (is-whitelisted (asset-contract principal))
	(default-to false (map-get? asset-contract-whitelist asset-contract))
)

(define-public (set-whitelisted (asset-contract principal) (whitelisted bool))
	(begin
		(asserts! (is-eq contract-owner tx-sender) err-owner-only)
		(ok (map-set asset-contract-whitelist asset-contract whitelisted))
	)
)
```
