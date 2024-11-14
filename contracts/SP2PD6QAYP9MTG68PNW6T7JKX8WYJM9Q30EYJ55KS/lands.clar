(impl-trait 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.sft-traits.sip013-semi-fungible-token-trait)
(impl-trait 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.sft-traits.sip013-transfer-many-trait)

(use-trait sip010 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.dao-traits-v2.sip010-ft-trait)

(define-fungible-token lands)
(define-non-fungible-token land {land-id: uint, owner: principal})

(define-data-var land-uri (string-ascii 80) "https://charisma.rocks/lands/json/")

(define-map land-balances {land-id: uint, owner: principal} uint)
(define-map land-supplies uint uint)

(define-map asset-contract-ids principal uint)
(define-map id-asset-contracts uint principal)
(define-map asset-contract-whitelist principal bool)

(define-data-var nonce uint u0)

(define-map land-difficulty uint uint)

(define-constant err-unauthorized (err u100))
(define-constant err-not-whitelisted (err u101))
(define-constant err-insufficient-balance (err u1))
(define-constant err-invalid-sender (err u4))
(define-constant err-nothing-to-claim (err u3101))
(define-constant err-no-owners (err u102))

(define-map total-tapped-energy {land-id: uint, owner: principal} uint)
(define-map stored-energy {land-id: uint, owner: principal} uint)
(define-map last-update {land-id: uint, owner: principal} uint)


(define-read-only (is-dao-or-extension)
	(ok (asserts! (or (is-eq tx-sender 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master) (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master is-extension contract-caller)) err-unauthorized))
)

(define-private (set-balance (land-id uint) (balance uint) (user principal))
	(let 
		(
      (stored-out (store land-id user))
		)
		(map-set land-balances {land-id: land-id, owner: user} balance)
    (ok stored-out)
	)
)

(define-private (get-balance-uint (land-id uint) (user principal))
	(default-to u0 (map-get? land-balances {land-id: land-id, owner: user}))
)

(define-read-only (get-balance (land-id uint) (user principal))
	(ok (get-balance-uint land-id user))
)

(define-read-only (get-overall-balance (user principal))
	(ok (ft-get-balance lands user))
)

(define-private (get-total-supply-uint (land-id uint))
	(default-to u0 (map-get? land-supplies land-id))
)

(define-read-only (get-total-supply (land-id uint))
	(ok (get-total-supply-uint land-id))
)

(define-read-only (get-overall-supply)
	(ok (ft-get-supply lands))
)

(define-read-only (get-last-land-id)
  	(ok (var-get nonce))
)

(define-read-only (get-decimals (land-id uint))
	(ok u6)
)

(define-read-only (get-token-uri (land-id uint))
  (ok (some (concat (concat (var-get land-uri) "{id}") ".json")))
)

(define-public (transfer (land-id uint) (amount uint) (sender principal) (recipient principal))
	(let
		(
			(sender-balance (get-balance-uint land-id sender))
      (stored-out-sender (set-balance land-id (- sender-balance amount) sender))
      (stored-out-recipient (set-balance land-id (+ (get-balance-uint land-id recipient) amount) recipient))
		)
		(asserts! (or (is-eq sender tx-sender) (is-eq sender contract-caller)) err-invalid-sender)
		(asserts! (<= amount sender-balance) err-insufficient-balance)
		(try! (ft-transfer? lands amount sender recipient))
		(try! (tag-id {land-id: land-id, owner: sender}))
		(try! (tag-id {land-id: land-id, owner: recipient}))
		(print {type: "sft_transfer", token-id: land-id, amount: amount, sender: sender, recipient: recipient})
		(ok true)
	)
)

(define-public (transfer-memo (land-id uint) (amount uint) (sender principal) (recipient principal) (memo (buff 34)))
	(begin
		(try! (transfer land-id amount sender recipient))
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

(define-public (wrap (amount uint) (sip010-asset <sip010>))
	(let
		(
			(land-id (try! (get-or-create-land-id sip010-asset)))
      (stored-out (set-balance land-id (+ (get-balance-uint land-id tx-sender) amount) tx-sender))
		)
    (try! (is-dao-or-extension))
		(try! (contract-call? sip010-asset transfer amount tx-sender (as-contract tx-sender) none))
		(try! (ft-mint? lands amount tx-sender))
		(try! (tag-id {land-id: land-id, owner: tx-sender}))
		(map-set land-supplies land-id (+ (get-total-supply-uint land-id) amount))
		(print {type: "sft_mint", token-id: land-id, amount: amount, recipient: tx-sender})
    (ok stored-out)
	)
)

(define-public (unwrap (amount uint) (sip010-asset <sip010>))
	(let
		(
			(land-id (try! (get-or-create-land-id sip010-asset)))
			(original-sender tx-sender)
			(sender-balance (get-balance-uint land-id tx-sender))
      (stored-out (set-balance land-id (- sender-balance amount) original-sender))
		)
    (try! (is-dao-or-extension))
		(asserts! (<= amount sender-balance) err-insufficient-balance)
		(try! (ft-burn? lands amount original-sender))
		(try! (as-contract (contract-call? sip010-asset transfer amount tx-sender original-sender none)))
		(map-set land-supplies land-id (- (get-total-supply-uint land-id) amount))
		(print {type: "sft_burn", token-id: land-id, amount: amount, sender: original-sender})
    (ok stored-out)
	)
)

(define-read-only (get-land-id (asset-contract principal))
	(map-get? asset-contract-ids asset-contract)
)

(define-read-only (get-land-asset-contract (land-id uint))
	(map-get? id-asset-contracts land-id)
)

(define-read-only (get-land-difficulty (land-id uint))
	(default-to (pow u10 u6) (map-get? land-difficulty land-id))
)

(define-public (get-or-create-land-id (sip010-asset <sip010>))
	(begin
		(let
			(
				(land-id (+ (var-get nonce) u1))
			)
			(asserts! (is-whitelisted (contract-of sip010-asset)) err-not-whitelisted)
			(map-insert asset-contract-ids (contract-of sip010-asset) land-id)
			(map-insert id-asset-contracts land-id (contract-of sip010-asset))
			(var-set nonce land-id)
		)
		(contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.lands get-or-create-land-id sip010-asset)
	)
)

(define-private (tag-id (id {land-id: uint, owner: principal}))
	(begin
		(and
			(is-some (nft-get-owner? land id))
			(try! (nft-burn? land id (get owner id)))
		)
		(nft-mint? land id (get owner id))
	)
)

(define-read-only (is-whitelisted (asset-contract principal))
	(default-to false (map-get? asset-contract-whitelist asset-contract))
)

(define-public (set-whitelisted (asset-contract principal) (whitelisted bool))
	(begin
		(try! (is-dao-or-extension))
		(map-set asset-contract-whitelist asset-contract whitelisted)
		(contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.lands set-whitelisted asset-contract whitelisted)
	)
)

(define-public (set-land-difficulty (land-id uint) (new-difficulty uint))
	(begin
		(try! (is-dao-or-extension))
		(map-set land-difficulty land-id new-difficulty)
		(try! (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master set-extension 'SP33HDXRZDGBY4NSCMPZJ9FP9XMKANVJHFD44YPYK.honey-badger-city true))
		(contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.lands set-land-difficulty land-id new-difficulty)
	)
)

;; Energy logic

;; tap lands energy
(define-public (tap (land-id uint))
  (let
    (
      (untapped-energy (unwrap-panic (get-untapped-amount land-id tx-sender)))
      (land-amount (unwrap-panic (get-balance land-id tx-sender)))
      (previous-total-tapped-energy (get-total-tapped-energy land-id tx-sender))
      (new-total-tapped-energy (+ previous-total-tapped-energy untapped-energy))
      (tapped-out {type: "tap-energy", land-id: land-id, land-amount: land-amount, energy: untapped-energy})
    )
    (try! (is-dao-or-extension))
    (map-set stored-energy {land-id: land-id, owner: tx-sender} u0)
    (map-set last-update {land-id: land-id, owner: tx-sender} block-height)
    (map-set total-tapped-energy {land-id: land-id, owner: tx-sender} new-total-tapped-energy)
    (print tapped-out)
    (ok tapped-out)
  )
)

;; store lands energy
(define-private (store (land-id uint) (user principal))
  (let
    (
      (tapped-out (unwrap-panic (tap land-id)))
      (energy (get energy tapped-out))
      (stored-out {type: "store-energy", land-id: land-id, owner: user, stored-energy: energy})
    )
    (map-set stored-energy {land-id: land-id, owner: user} energy)
    (print stored-out)
    (ok stored-out)
  )
)

;; get untapped amount
(define-read-only (get-untapped-amount (land-id uint) (user principal))
  (let
    (
      (new-energy (get-new-energy land-id user))
      (previous-stored-energy (get-stored-energy land-id user))
      (untapped-energy (+ new-energy previous-stored-energy))
    )
    (ok untapped-energy)
  )
)

;; get stored energy default to 0
(define-read-only (get-stored-energy (land-id uint) (user principal))
  (default-to u0 (map-get? stored-energy {land-id: land-id, owner: user}))
)

;; get new energy
(define-read-only (get-new-energy (land-id uint) (user principal))
  (let
    (
      (energy-per-block (get-energy-per-block land-id user))
      (blocks-since-last-update (get-blocks-since-last-update land-id user))
    )
    (* blocks-since-last-update energy-per-block)
  )
)

;; get energy per block
(define-read-only (get-energy-per-block (land-id uint) (user principal))
  (let
    (
      (users-lands (unwrap-panic (get-balance land-id user)))
      (lands-difficulty (get-land-difficulty land-id))
    )
    (/ users-lands lands-difficulty)
  )
)

;; get blocks since last update
(define-read-only (get-blocks-since-last-update (land-id uint) (user principal))
  (let
    (
      (last-update-block (get-user-last-update land-id user))
    )
    (- block-height last-update-block)
  )
)

;; get user last update block
(define-read-only (get-user-last-update (land-id uint) (user principal))
  (default-to block-height (map-get? last-update {land-id: land-id, owner: user}))
)

;; get total tapped energy
(define-read-only (get-total-tapped-energy (land-id uint) (user principal))
  (default-to u0 (map-get? total-tapped-energy {land-id: land-id, owner: user}))
)

;; get blocks remaining to reach target energy
(define-read-only (blocks-to-target-energy (land-id uint) (user principal) (target-energy uint))
  (let
    (
      (current-energy (unwrap-panic (get-untapped-amount land-id user)))
      (energy-per-block (get-energy-per-block land-id user))
    )
    (if (>= current-energy target-energy)
      u0
      (/ (- target-energy current-energy) energy-per-block)
    )
  )
)