(impl-trait .sft-traits.sip013-semi-fungible-token-trait)
(impl-trait .sft-traits.sip013-transfer-many-trait)

(define-fungible-token creatures)
(define-non-fungible-token creature {creature-id: uint, owner: principal})

(define-data-var creature-uri (string-ascii 80) "https://charisma.rocks/creatures/json/")
(define-map creature-balances {creature-id: uint, owner: principal} uint)
(define-map creature-supplies uint uint)
(define-map asset-contract-ids principal uint)
(define-map asset-contract-whitelist principal bool)

(define-data-var nonce uint u0)

(define-map creature-costs uint uint)
(define-map creature-power uint uint)

;; Creature utilization
(define-map users-creatures-last-claim {creature-id: uint, owner: principal} uint)

(define-constant err-unauthorized (err u100))
(define-constant err-not-whitelisted (err u101))
(define-constant err-insufficient-balance (err u1))
(define-constant err-invalid-sender (err u4))
(define-constant err-nothing-to-claim (err u3101))

(define-trait sip010-transferable-trait
	(
		(transfer (uint principal principal (optional (buff 34))) (response bool uint))
		(get-decimals () (response uint uint))
	)
)

;; --- Authorization check

(define-read-only (is-dao-or-extension)
	(ok (asserts! (or (is-eq tx-sender 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master) (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master is-extension contract-caller)) err-unauthorized))
)

(define-private (set-balance (creature-id uint) (balance uint) (owner principal))
	(map-set creature-balances {creature-id: creature-id, owner: owner} balance)
)

(define-private (get-balance-uint (creature-id uint) (who principal))
	(default-to u0 (map-get? creature-balances {creature-id: creature-id, owner: who}))
)

(define-read-only (get-balance (creature-id uint) (who principal))
	(ok (get-balance-uint creature-id who))
)

(define-read-only (get-overall-balance (who principal))
	(ok (ft-get-balance creatures who))
)

(define-private (get-total-supply-uint (creature-id uint))
	(default-to u0 (map-get? creature-supplies creature-id))
)

(define-read-only (get-total-supply (creature-id uint))
	(ok (get-total-supply-uint creature-id))
)

(define-read-only (get-overall-supply)
	(ok (ft-get-supply creatures))
)

(define-read-only (get-decimals (creature-id uint))
	(ok u0)
)

(define-read-only (get-token-uri (creature-id uint))
  	(ok (some (concat (concat (var-get creature-uri) "{id}") ".json")))
)

(define-public (transfer (creature-id uint) (amount uint) (sender principal) (recipient principal))
	(let
		(
			(sender-balance (get-balance-uint creature-id sender))
		)
		(asserts! (or (is-eq sender tx-sender) (is-eq sender contract-caller)) err-invalid-sender)
		(asserts! (<= amount sender-balance) err-insufficient-balance)
		(try! (ft-transfer? creatures amount sender recipient))
		(try! (tag-id {creature-id: creature-id, owner: sender}))
		(try! (tag-id {creature-id: creature-id, owner: recipient}))
		(set-balance creature-id (- sender-balance amount) sender)
		(set-balance creature-id (+ (get-balance-uint creature-id recipient) amount) recipient)
		(print {type: "sft_transfer", token-id: creature-id, amount: amount, sender: sender, recipient: recipient})
		(ok true)
	)
)

(define-public (transfer-memo (creature-id uint) (amount uint) (sender principal) (recipient principal) (memo (buff 34)))
	(begin
		(try! (transfer creature-id amount sender recipient))
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

(define-read-only (get-creature-id (asset-contract principal))
	(map-get? asset-contract-ids asset-contract)
)

(define-read-only (get-creature-cost (creature-id uint))
	(default-to u0 (map-get? creature-costs creature-id))
)

(define-read-only (get-creature-power (creature-id uint))
	(default-to u0 (map-get? creature-power creature-id))
)

(define-public (get-or-create-creature-id (sip010-asset <sip010-transferable-trait>))
	(match (get-creature-id (contract-of sip010-asset))
		creature-id (ok creature-id)
		(let
			(
				(creature-id (+ (var-get nonce) u1))
			)
			(asserts! (is-whitelisted (contract-of sip010-asset)) err-not-whitelisted)
			(map-set asset-contract-ids (contract-of sip010-asset) creature-id)
			(var-set nonce creature-id)
			(ok creature-id)
		)
	)
)

(define-public (summon (amount uint) (sip010-asset <sip010-transferable-trait>))
	(let
		(
			(creature-id (try! (get-or-create-creature-id sip010-asset)))
			(creature-cost (get-creature-cost creature-id))
		)
		(asserts! (< u0 creature-cost) err-unauthorized)
		(try! (contract-call? sip010-asset transfer (* amount creature-cost) tx-sender (as-contract tx-sender) none))
		(try! (ft-mint? creatures amount tx-sender))
		(try! (tag-id {creature-id: creature-id, owner: tx-sender}))
		(set-balance creature-id (+ (get-balance-uint creature-id tx-sender) amount) tx-sender)
		(map-set creature-supplies creature-id (+ (get-total-supply-uint creature-id) amount))
		(print {type: "sft_mint", token-id: creature-id, amount: amount, recipient: tx-sender})
        (map-set users-creatures-last-claim {creature-id: creature-id, owner: tx-sender} block-height)
		(ok creature-id)
	)
)

(define-public (unsummon (amount uint) (sip010-asset <sip010-transferable-trait>))
	(let
		(
			(creature-id (try! (get-or-create-creature-id sip010-asset)))
			(original-sender tx-sender)
			(sender-balance (get-balance-uint creature-id tx-sender))
			(creature-cost (get-creature-cost creature-id))
		)
		(asserts! (<= amount sender-balance) err-insufficient-balance)
		(try! (ft-burn? creatures amount original-sender))
		(try! (as-contract (contract-call? sip010-asset transfer (* amount creature-cost) tx-sender original-sender none)))
		(set-balance creature-id (- sender-balance amount) original-sender)
		(map-set creature-supplies creature-id (- (get-total-supply-uint creature-id) amount))
		(print {type: "sft_burn", token-id: creature-id, amount: amount, sender: original-sender})
		(ok creature-id)
	)
)

(define-public (tap (creature-id uint))
    (let
        (
            (users-creatures (get-balance-uint creature-id tx-sender))
            (total-creatures (get-total-supply-uint creature-id))
            (last-claim (get-users-creatures-last-claim tx-sender creature-id))
            (blocks-since-last-claim (- block-height last-claim))
            (energy-amount (/ (* (* blocks-since-last-claim (get-creature-power creature-id)) users-creatures) total-creatures))
        )
        (asserts! (> energy-amount u0) err-nothing-to-claim)
        (map-set users-creatures-last-claim {creature-id: creature-id, owner: tx-sender} block-height)
		(ok energy-amount)
	
    )
)

(define-read-only (get-claimable-amount (creature-id uint))
	(let
		(
			(users-creatures (get-balance-uint creature-id tx-sender))
			(total-creatures (get-total-supply-uint creature-id))
			(last-claim (get-users-creatures-last-claim tx-sender creature-id))
			(blocks-since-last-claim (- block-height last-claim))
			(energy-amount (/ (* (* blocks-since-last-claim (get-creature-power creature-id)) users-creatures) total-creatures))
		)
		(ok energy-amount)
	)
)

(define-private (tag-id (id {creature-id: uint, owner: principal}))
	(begin
		(and
			(is-some (nft-get-owner? creature id))
			(try! (nft-burn? creature id (get owner id)))
		)
		(nft-mint? creature id (get owner id))
	)
)

(define-read-only (is-whitelisted (asset-contract principal))
	(default-to false (map-get? asset-contract-whitelist asset-contract))
)

(define-public (set-whitelisted (asset-contract principal) (whitelisted bool))
	(begin
        (try! (is-dao-or-extension))
		(ok (map-set asset-contract-whitelist asset-contract whitelisted))
	)
)

(define-read-only (get-users-creatures-last-claim (who principal) (creature-id uint))
	(default-to block-height (map-get? users-creatures-last-claim {creature-id: creature-id, owner: who}))
)

(define-public (set-creature-cost (creature-id uint) (new-cost uint))
	(begin
		(try! (is-dao-or-extension))
		(asserts! (is-eq u0 (get-creature-cost creature-id)) err-unauthorized)
		(ok (map-set creature-costs creature-id new-cost))
	)
)

(define-public (set-creature-power (creature-id uint) (new-power uint))
	(begin
		(try! (is-dao-or-extension))
		(ok (map-set creature-power creature-id new-power))
	)
)