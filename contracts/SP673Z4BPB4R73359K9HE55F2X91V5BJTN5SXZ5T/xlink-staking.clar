;; SPDX-License-Identifier: BUSL-1.1

(use-trait ft-trait 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.trait-sip-010.sip-010-trait)

(define-constant err-not-authorised (err u1000))
(define-constant err-paused (err u1001))
(define-constant err-unknown-validator (err u1006))
(define-constant err-validator-already-registered (err u1008))
(define-constant err-hash-mismatch (err u1010))
(define-constant err-invalid-signature (err u1011))
(define-constant err-message-too-old (err u1012))
(define-constant err-invalid-block (err u1013))
(define-constant err-required-validators (err u1015))
(define-constant err-invalid-validator (err u1016))
(define-constant err-invalid-input (err u1017))
(define-constant err-token-mismatch (err u1018))
(define-constant err-invalid-amount (err u1019))
(define-constant err-update-failed (err u1020))
(define-constant err-duplicate-signatures (err u1021))

(define-constant MAX_UINT u340282366920938463463374607431768211455)
(define-constant ONE_8 u100000000)
(define-constant MAX_REQUIRED_VALIDATORS u20)

(define-constant structured-data-prefix 0x534950303138)
;; const domainHash = structuredDataHash(
;;   tupleCV({
;;     name: stringAsciiCV('Bitcoin Oracle'),
;;     version: stringAsciiCV('0.0.3'),
;;     'chain-id': uintCV(new StacksMainnet().chainId) | uintCV(new StacksMocknet().chainId),
;;   }),
;; );
(define-constant message-domain-main 0x89a7c46bfde2bbffaf08240dd538c0da498e3645d938655e214bd9d67437747a) ;;mainnet
(define-constant message-domain-test 0xe104d090220bc57abaadbad4b9349d344954fe4de833e73df2013d5236a2b9ec) ;; testnet

(define-data-var is-paused bool true)

(define-map approved-tokens principal bool)
(define-map user-shares { user: principal, token: principal } uint)
(define-map total-staked principal uint)
(define-map total-shares principal uint)

(define-map validator-registry principal { token: principal, pubkey: (buff 33) })
(define-data-var required-validators uint MAX_UINT)

(define-map accrued-rewards principal { amount: uint, update-block: uint })
(define-data-var block-threshold uint u0)
(define-map approved-updaters principal bool)

;; read-only calls

(define-read-only (is-dao-or-extension)
	(ok (asserts! (or (is-eq tx-sender 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.executor-dao) (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.executor-dao is-extension contract-caller)) err-not-authorised)))

(define-read-only (message-domain)
  (if (is-eq chain-id u1) message-domain-main message-domain-test))

(define-read-only (get-paused)
  (var-get is-paused))

(define-read-only (get-block-threshold)
	(var-get block-threshold))

(define-read-only (get-required-validators)
  (var-get required-validators))

(define-read-only (get-validator-or-fail (validator principal))
  (ok (unwrap! (map-get? validator-registry validator) err-unknown-validator)))	

(define-read-only (get-approved-token-or-default (token principal))
	(default-to false (map-get? approved-tokens token)))

(define-read-only (get-shares-or-default (user principal) (token principal))
	(default-to u0 (map-get? user-shares { user: user, token: token })))

(define-read-only (get-total-shares-or-default (token principal))
	(default-to u0 (map-get? total-shares token)))

(define-read-only (get-total-staked-or-default (token principal))
	(default-to u0 (map-get? total-staked token)))

(define-read-only (get-accrued-rewards-or-default (token principal))
	(default-to { amount: u0, update-block: u0 } (map-get? accrued-rewards token)))

(define-read-only (get-shares-given-amount (token principal) (amount uint))
	(let (
			(staked-total (get-total-staked-or-default token))
			(shares-total (get-total-shares-or-default token)))
		(if (or (is-eq staked-total u0) (is-eq shares-total staked-total))
			amount
			(div-down (mul-down amount shares-total) staked-total))))

(define-read-only (get-amount-given-shares (token principal) (shares uint))
	(let (
			(staked-total (get-total-staked-or-default token))
			(shares-total (get-total-shares-or-default token)))
		(if (or (is-eq staked-total u0) (is-eq shares-total staked-total))
			shares
			(div-down (mul-down shares staked-total) shares-total))))

(define-read-only (create-oracle-message (message { token: principal, accrued-rewards: uint, update-block: uint }))
	(ok (unwrap! (to-consensus-buff? message) err-invalid-input)))

(define-read-only (decode-oracle-message (message-buff (buff 128)))
	(ok (unwrap! (from-consensus-buff? { token: principal, accrued-rewards: uint, update-block: uint } message-buff) err-invalid-input)))

(define-read-only (hash-oracle-message (message { token: principal, accrued-rewards: uint, update-block: uint }))
	(ok (sha256 (try! (create-oracle-message message)))))

(define-read-only (validate-stake (token principal) (amount uint))
	(ok (asserts! (get-approved-token-or-default token) err-not-authorised)))
	
(define-read-only (validate-unstake (token principal) (amount uint))
	(let (
			(shares (get-shares-given-amount token amount)))
		(asserts! (not (get-paused)) err-paused)
		(asserts! (get-approved-token-or-default token) err-not-authorised)
		(asserts! (<= shares (get-shares-or-default tx-sender token)) err-invalid-amount)
		(asserts! (<= shares (get-total-shares-or-default token)) err-invalid-amount)
		(asserts! (<= amount (get-total-staked-or-default token)) err-invalid-amount)
		(ok shares)))

(define-read-only (get-approved-updater-or-default (updater principal))
	(default-to false (map-get? approved-updaters updater)))

;; governance calls

(define-public (set-approved-updater (updater principal) (approved bool))
  (begin
    (try! (is-dao-or-extension))
    (ok (map-set approved-updaters updater approved))))

(define-public (set-required-validators (required uint))
  (begin
    (try! (is-dao-or-extension))
    (ok (var-set required-validators required))))

(define-public (set-paused (paused bool))
  (begin
    (try! (is-dao-or-extension))
    (ok (var-set is-paused paused))))
	
(define-public (set-block-threshold (threshold uint))
	(begin 
		(try! (is-dao-or-extension))
		(ok (var-set block-threshold threshold))))

(define-public (set-accrued-rewards (token principal) (details { amount: uint, update-block: uint }))
	(begin
		(try! (is-dao-or-extension))
		(ok (map-set accrued-rewards token details))))

(define-public (set-approved-token (token principal) (approved bool))
	(begin
		(try! (is-dao-or-extension))
		(ok (map-set approved-tokens token approved))))

(define-public (add-validator (validator principal) (details { token: principal, pubkey: (buff 33) }))
	(begin
    (try! (is-dao-or-extension))
    (ok (asserts! (map-insert validator-registry validator details) err-validator-already-registered))))

(define-public (remove-validator (validator principal))
  (begin
    (try! (is-dao-or-extension))
    (ok (map-delete validator-registry validator))))

(define-public (withdraw (token-trait <ft-trait>) (amount uint))
	(let (
			(sender tx-sender)
			(token (contract-of token-trait))
			(check-amount (asserts! (<= amount (get-total-staked-or-default token)) err-invalid-amount))
			(updated-total-staked (- (get-total-staked-or-default token) amount)))
		(try! (is-dao-or-extension))
		(asserts! (get-approved-token-or-default token) err-not-authorised)
		(as-contract (try! (contract-call? token-trait transfer-fixed amount tx-sender sender none)))
		(asserts! (map-set total-staked token updated-total-staked) err-update-failed)
		(print { notification: "withdraw", payload: { token: token, amount: amount, updated-total-staked: updated-total-staked } })
		(ok true)))

;; public calls

(define-public (add-rewards
	(message { token: principal, accrued-rewards: uint, update-block: uint }) 
	(token-trait <ft-trait>)
	(signature-packs (list 100 { signer: principal, message-hash: (buff 32), signature: (buff 65) })))
	(let (
			(message-hash (try! (hash-oracle-message message)))
			(previous-accrued (get-accrued-rewards-or-default (get token message)))
			(check-accrued (asserts! (<= (get amount previous-accrued) (get accrued-rewards message)) err-invalid-amount))
			(delta (- (get accrued-rewards message) (get amount previous-accrued)))
			(updated-total-staked (+ (get-total-staked-or-default (get token message)) delta)))
		(asserts! (not (get-paused)) err-paused)
		(asserts! (or (get-approved-updater-or-default tx-sender) (is-ok (is-dao-or-extension))) err-not-authorised)
		(asserts! (get-approved-token-or-default (get token message)) err-not-authorised)
		(asserts! (is-eq (get token message) (contract-of token-trait)) err-token-mismatch)
		(asserts! (<= (get update-block message) stacks-block-height) err-invalid-block)
		(asserts! (>= (+ (get update-block message) (var-get block-threshold)) stacks-block-height) err-message-too-old)
    
		(asserts! (>= (len signature-packs) (get-required-validators)) err-required-validators)
		(asserts! (is-eq (len signature-packs) (len (fold remove-duplicate-iter signature-packs (list)))) err-duplicate-signatures)
    (try! (fold validate-signature-iter signature-packs (ok { message-hash: message-hash, token: (get token message) })))

		(and (> delta u0) (as-contract (try! (contract-call? token-trait mint-fixed delta tx-sender))))
		(asserts! (map-set accrued-rewards (get token message) { amount: (get accrued-rewards message), update-block: (get update-block message) }) err-update-failed)
		(asserts! (map-set total-staked (get token message) updated-total-staked) err-update-failed)
		(print { notification: "add-rewards", payload: (merge message { updated-total-staked: updated-total-staked }) })
		(ok true)))

;; priviliged calls

(define-public (stake 
	(token-trait <ft-trait>) (amount uint)
	(message { token: principal, accrued-rewards: uint, update-block: uint })
	(signature-packs (list 100 { signer: principal, message-hash: (buff 32), signature: (buff 65) })))	
	(let (
			(rebased (try! (add-rewards message token-trait signature-packs)))
			(token (contract-of token-trait))
			(shares (get-shares-given-amount token amount))
			(updated-shares (+ (get-shares-or-default tx-sender token) shares))
			(updated-total-shares (+ (get-total-shares-or-default token) shares))
			(updated-total-staked (+ (get-total-staked-or-default token) amount)))
		(try! (is-dao-or-extension))
		(try! (validate-stake token amount))
		(try! (contract-call? token-trait transfer-fixed amount tx-sender (as-contract tx-sender) none))
		(asserts! (map-set user-shares { user: tx-sender, token: token } updated-shares) err-update-failed)
		(asserts! (map-set total-shares token updated-total-shares) err-update-failed)
		(asserts! (map-set total-staked token updated-total-staked) err-update-failed)
		(print { notification: "stake", payload: { user: tx-sender, token: token, amount: amount, updated-shares: updated-shares, updated-total-shares: updated-total-shares, updated-total-staked: updated-total-staked }})
		(ok true)))

(define-public (unstake 
	(token-trait <ft-trait>) (amount uint)
	(message { token: principal, accrued-rewards: uint, update-block: uint })
	(signature-packs (list 100 { signer: principal, message-hash: (buff 32), signature: (buff 65) })))		
	(let (
			(rebased (try! (add-rewards message token-trait signature-packs)))
			(sender tx-sender)
			(token (contract-of token-trait))
			(shares (try! (validate-unstake token amount)))
			(updated-shares (- (get-shares-or-default sender token) shares))
			(updated-total-shares (- (get-total-shares-or-default token) shares))
			(updated-total-staked (- (get-total-staked-or-default token) amount)))
		(try! (is-dao-or-extension))
		(as-contract (try! (contract-call? token-trait transfer-fixed amount tx-sender sender none)))
		(asserts! (map-set user-shares { user: sender, token: token } updated-shares) err-update-failed)
		(asserts! (map-set total-shares token updated-total-shares) err-update-failed)
		(asserts! (map-set total-staked token updated-total-staked) err-update-failed)
		(print { notification: "unstake", payload: { user: sender, token: token, amount: amount, updated-shares: updated-shares, updated-total-shares: updated-total-shares }})
		(ok true)))

;; private calls

(define-private (validate-signature-iter 
  (signature-pack { signer: principal, message-hash: (buff 32), signature: (buff 65)}) 
  (previous-response (response { message-hash: (buff 32), token: principal } uint)))
  (match previous-response 
    prev-ok (match (validate-message (get message-hash prev-ok) (get token prev-ok) signature-pack) success (ok prev-ok) error (err error))
    prev-err previous-response))

(define-private (validate-message (message-hash (buff 32)) (token principal) (signature-pack { signer: principal, message-hash: (buff 32), signature: (buff 65)}))
  (let (
      (validator (try! (get-validator-or-fail (get signer signature-pack)))))
    (asserts! (is-eq message-hash (get message-hash signature-pack)) err-hash-mismatch)
    (asserts! (is-eq token (get token validator)) err-invalid-validator)
    (asserts! (is-eq (secp256k1-recover? (sha256 (concat structured-data-prefix (concat (message-domain) message-hash))) (get signature signature-pack)) (ok (get pubkey validator))) err-invalid-signature)
		(ok true)))

(define-private (mul-down (a uint) (b uint))
  (/ (* a b) ONE_8))

(define-private (div-down (a uint) (b uint))
  (if (is-eq a u0) u0 (/ (* a ONE_8) b)))

(define-private (max (a uint) (b uint))
  (if (<= a b) b a))

(define-private (remove-duplicate-iter (item { signer: principal, message-hash: (buff 32), signature: (buff 65)}) (acc (list 100 { signer: principal, message-hash: (buff 32), signature: (buff 65)})))
  (if (is-some (index-of? acc item)) acc (unwrap-panic (as-max-len? (append acc item) u100))))
