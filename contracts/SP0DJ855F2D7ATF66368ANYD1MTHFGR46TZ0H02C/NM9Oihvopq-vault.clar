
	;; title: vault
	;; version: 0.0.1
	;; summary: Vault for storing collateral and constructing bond(s) to lend to protocol(s)
	;; description: Vault for storing collateral and constructing bond(s) to lend to protocol(s)
	
	;; traits
	;; mainnet - SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard
	;; testnet - ST2XX28V6YR45HZJ0D5990MRCBHMGC843GQQ12N1Q
	;; devnet - ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM
	(use-trait ft-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)
	;;
	
	;; constants
	(define-constant contract-owner tx-sender)
	;; mainnet - SP1X5C20QNS2RDPRWMXMHJVTGEH1KKSREH2Q6RBWN.sbtc
	;; testnet - ST2XX28V6YR45HZJ0D5990MRCBHMGC843GQQ12N1Q.sbtc-2
	;; devnet - ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.sbtc
	(define-constant collateral-asset-contract 'SP1X5C20QNS2RDPRWMXMHJVTGEH1KKSREH2Q6RBWN.sbtc)
	;; mainnet - SP1X5C20QNS2RDPRWMXMHJVTGEH1KKSREH2Q6RBWN
	;; testnet - ST2XX28V6YR45HZJ0D5990MRCBHMGC843GQQ12N1Q
	;; devnet - ST2JHG361ZXG51QTKY2NQCVBPPRRE2KZB1HR05NNC
	(define-constant tetris-principal 'SP1X5C20QNS2RDPRWMXMHJVTGEH1KKSREH2Q6RBWN)
	(define-constant dummy-principal 'ST1HTBVD3JG9C05J7HBJTHGR0GGW7KXW28M5JS8QE) ;;todo - how to have a zero address or something
	(define-constant dummy-position {
		id: u0,
		borrower: dummy-principal,
		collateralBalance: u0,
		state: u0,
		lender: dummy-principal,
		liquidator: dummy-principal,
		proofTxId: "",
		tetris: dummy-principal
	})
	(define-constant dummy-proof-tx-id "1D10T")
	
	;; errors
	(define-constant err-owner-only (err u100))
	(define-constant err-amount-not-gt-zero (err u102))
	(define-constant err-principal-network-mismatch (err u103))
	(define-constant err-invalid-position-id (err u104))
	(define-constant err-not-a-number (err u105))
	(define-constant err-not-enough-collateral (err u106))
	(define-constant err-vault-amount-must-gte-than-locked (err u107))
	(define-constant err-invalid-vault-state (err u108))
	(define-constant err-existing-vault-state (err u109))
	(define-constant err-invalid-collateral-state (err u110))
	(define-constant err-unauthorized-principal (err u111))
	(define-constant err-no-liquidator-defined (err u112))
	(define-constant err-no-proof-tx-defined (err u113))
	
	
	;; max positions for a vault
	(define-constant position-ids (list u1 u2 u3 u4 u5 u6 u7 u8 u9 u10))
	
	;; collateral states
	(define-constant collateral-state-open u200)
	(define-constant collateral-state-locked u201)
	(define-constant collateral-state-liquidated u202)
	(define-constant collateral-state-archived u203)
	
	;; vault states
	(define-constant vault-state-open u300)
	(define-constant vault-state-archived u301)
	
	;; data vars
	(define-data-var last-position-id uint u0)
	(define-data-var current-vault-state uint vault-state-open)
	(define-data-var tetris-proof (string-ascii 66) "") ;; todo - this is a replay-proof signature from tetris that the lender needs to validate
	
	
	;; data maps
	(define-map positions
		uint
		{
			id: uint,
			borrower: principal,
			collateralBalance: uint,
			state: uint,
			lender: principal,
			liquidator: principal,
			proofTxId: (string-ascii 66),
			tetris: principal
		}
	)
	;;
	
	;; public functions
	(define-public (deposit (amount uint))
		(let (
			(available-collateral-balance (unwrap! (get-available-collateral-balance) err-not-a-number))
			(event {type: "deposit_to_vault", amount: amount, sender: tx-sender, asset: collateral-asset-contract})
		)
	
			;; ownership check
			(asserts! (is-eq tx-sender contract-owner) err-owner-only)
	
			;; vault state
			(asserts! (is-eq (var-get current-vault-state) vault-state-open) err-invalid-vault-state)
	
			;; context state
			(asserts! (is-eq true (> amount u0)) err-amount-not-gt-zero)
			;; note - we may implement a max and or min deposit amount
	
			(try! (transfer-ft collateral-asset-contract amount tx-sender (as-contract tx-sender)))
			(print event)
			(ok true)
		)
	)
	
	(define-public (withdraw (amount uint))
		(let (
			(available-collateral-balance (unwrap! (get-available-collateral-balance) err-not-a-number))
			(event {type: "withdraw_from_vault", amount: amount, sender: tx-sender, asset: collateral-asset-contract})
		)
			;; ownership check
			(asserts! (is-eq tx-sender contract-owner) err-owner-only)
	
			;; vault check
			;; note - maybe we will allow withdrawal from a closed vault
			(asserts! (is-eq (var-get current-vault-state) vault-state-open) err-invalid-vault-state)
	
			;; context check
			(asserts! (is-eq true (> amount u0)) err-amount-not-gt-zero)
			(asserts! (is-eq true (>= available-collateral-balance amount)) err-not-enough-collateral)
	
			(try! (transfer-ft collateral-asset-contract amount (as-contract tx-sender) tx-sender))
			(print event)
			(ok true)
		)
	)
	
	(define-public (create-position (collateral-amount uint) (lender principal))
		(let (
			(position-id (+ (var-get last-position-id) u1))
			(available-collateral-balance (unwrap! (get-available-collateral-balance) err-not-a-number))
			(event {type: "create_position", sender: tx-sender, asset: collateral-asset-contract})
		)
	
			(asserts! (is-standard lender) err-principal-network-mismatch)
	
			;; ownership checks
			(asserts! (is-eq tx-sender contract-owner) err-owner-only)
	
			;; vault checks
			(asserts! (is-eq (var-get current-vault-state) vault-state-open) err-invalid-vault-state)
	
			;; context checks
			(asserts! (is-eq true (> collateral-amount u0)) err-amount-not-gt-zero)
			(asserts! (is-eq true (> position-id (var-get last-position-id))) err-invalid-position-id)
			(asserts! (is-eq true (<= position-id (len position-ids))) err-invalid-position-id)
			(asserts! (is-eq true (>= available-collateral-balance collateral-amount)) err-not-enough-collateral)
	
			(map-set positions position-id {
				id: position-id,
				borrower: tx-sender,
				collateralBalance: collateral-amount,
				state: collateral-state-open,
				lender: lender,
				liquidator: dummy-principal,
				proofTxId: dummy-proof-tx-id,
				tetris: tetris-principal
			})
			(var-set last-position-id position-id)
			(print event)
			(ok true)
		)
	)
	
	(define-public (add-to-position (position-id uint) (collateral-amount uint))
		(let (
			(position (unwrap! (map-get? positions position-id) err-invalid-position-id))
			(available-collateral-balance (unwrap! (get-available-collateral-balance) err-not-a-number))
			(event {type: "add_to_position", positionId: position-id, amount: collateral-amount, sender: tx-sender, asset: collateral-asset-contract})
		)
			;; ownership checks
			(asserts! (is-eq tx-sender contract-owner) err-owner-only) ;; only owner can call
	
			;; vault checks
			(asserts! (is-eq (var-get current-vault-state) vault-state-open) err-invalid-vault-state) ;; vault state must be open
	
			;; common position checks
			(asserts! (is-eq (get state position) collateral-state-open) err-invalid-collateral-state)
			(asserts! (is-eq tx-sender (get borrower position)) err-owner-only) ;; borrower must match position principal
			(asserts! (is-some (some position)) err-invalid-position-id) ;; position must exist
			(asserts! (is-eq true (<= position-id (var-get last-position-id))) err-invalid-position-id) ;; position must be within valid range
	
			;; specific context checks
			(asserts! (is-eq true (> collateral-amount u0)) err-amount-not-gt-zero)
			(asserts! (is-eq true (>= available-collateral-balance collateral-amount)) err-not-enough-collateral)
	
			(map-set positions position-id (merge position {collateralBalance: (+ (get collateralBalance position) collateral-amount)}))
			(print event)
			(ok true)
		)
	)
	
	(define-public (remove-from-position (position-id uint) (collateral-amount uint))
		(let (
			(position (unwrap! (map-get? positions position-id) err-invalid-position-id))
			(event {type: "remove_from_position", positionId: position-id, amount: collateral-amount, sender: tx-sender, asset: collateral-asset-contract})
		)
	
			;; ownership checks
			(asserts! (is-eq tx-sender contract-owner) err-owner-only) ;; only owner can call
	
			;; vault checks
			(asserts! (is-eq (var-get current-vault-state) vault-state-open) err-invalid-vault-state) ;; vault state must be open
	
			;; common position checks
			(asserts! (is-eq (get state position) collateral-state-open) err-invalid-collateral-state)
			(asserts! (is-eq tx-sender (get borrower position)) err-owner-only) ;; borrower must match position principal
			(asserts! (is-some (some position)) err-invalid-position-id) ;; position must exist
			(asserts! (is-eq true (<= position-id (var-get last-position-id))) err-invalid-position-id) ;; position must be within valid range
	
			;; specific context checks
			(asserts! (is-eq true (> collateral-amount u0)) err-amount-not-gt-zero)
			(asserts! (is-eq true (>= (get collateralBalance position) collateral-amount)) err-vault-amount-must-gte-than-locked)
			
			(map-set positions position-id (merge position {collateralBalance: (- (get collateralBalance position) collateral-amount)}))
			(print event)
			(ok true)
		)
	)
	
	(define-public (change-vault-state (new-state uint)) 
		(let (
			(event {type: "change_vault_state", sender: tx-sender, oldState: (var-get current-vault-state), newState: new-state })
		) 
	
			;; ownership check
			(asserts! (is-eq tx-sender contract-owner) err-owner-only)
			
			;; context check
			(asserts! (is-eq true (or (is-eq new-state vault-state-open) (is-eq new-state vault-state-archived))) err-invalid-vault-state)
			(asserts! (is-eq false (is-eq new-state (var-get current-vault-state))) err-existing-vault-state)
			
			(var-set current-vault-state new-state)
			(print event)
			(ok new-state)	
		)
	)
	
	(define-public (lock-position (position-id uint))
		(let (
			(position (unwrap! (map-get? positions position-id) err-invalid-position-id))
			(event {type: "lock_position", positionId: position-id, sender: tx-sender})
		)
			;; access checks
			(asserts! (is-eq true (is-eq tx-sender (get lender position))) err-unauthorized-principal)
	
			;; vault checks
			(asserts! (is-eq (var-get current-vault-state) vault-state-open) err-invalid-vault-state) ;; vault state must be open
	
			;; common position checks
			(asserts! (is-some (some position)) err-invalid-position-id) ;; position must exist
			(asserts! (is-eq true (<= position-id (var-get last-position-id))) err-invalid-position-id) ;; position must be within valid range
	
			;; specific context checks
			(asserts! (is-eq (get state position) collateral-state-open) err-invalid-collateral-state) ;; collateral state must be open
	
			(map-set positions position-id (merge position {state: collateral-state-locked}))
			(print event)
			(ok true)
		)
	)
	
	(define-public (liquidate-position (position-id uint) (liquidator principal) (proofTxId (string-ascii 66)))
		(let (
			(position (unwrap! (map-get? positions position-id) err-invalid-position-id))
			(event {type: "liquidate_position", positionId: position-id, sender: tx-sender, liquidator: liquidator, proofTxId: proofTxId})
		)
			;; access checks
			(asserts! (is-eq true (is-eq tx-sender (get lender position))) err-unauthorized-principal)
	
			;; vault checks
			(asserts! (is-eq (var-get current-vault-state) vault-state-open) err-invalid-vault-state) ;; vault state must be open
	
			;; common position checks
			(asserts! (is-some (some position)) err-invalid-position-id) ;; position must exist
			(asserts! (is-eq true (<= position-id (var-get last-position-id))) err-invalid-position-id) ;; position must be within valid range
	
			;; specific context checks
			(asserts! (is-eq (get state position) collateral-state-locked) err-invalid-collateral-state) ;; collateral state must be locked
	
			(map-set positions position-id (merge position {state: collateral-state-liquidated, liquidator: liquidator, proofTxId: proofTxId}))
			(print event)
			(ok true)
		)
	)
	
	(define-public (unlock-position (position-id uint) (proofTxId (string-ascii 66)))
		(let (
			(position (unwrap! (map-get? positions position-id) err-invalid-position-id))
			(event {type: "unlock_position", positionId: position-id, sender: tx-sender, proofTxId: proofTxId})
		)
			;; access checks
			(asserts! (is-eq true (is-eq tx-sender (get lender position))) err-unauthorized-principal)
	
			;; vault checks
			(asserts! (is-eq (var-get current-vault-state) vault-state-open) err-invalid-vault-state) ;; vault state must be open
	
			;; common position checks
			(asserts! (is-some (some position)) err-invalid-position-id) ;; position must exist
			(asserts! (is-eq true (<= position-id (var-get last-position-id))) err-invalid-position-id) ;; position must be within valid range
	
			;; specific context checks
			(asserts! (is-eq (get state position) collateral-state-locked) err-invalid-collateral-state) ;; collateral state must be locked
	
			(map-set positions position-id (merge position {state: collateral-state-open, proofTxId: proofTxId}))
			(print event)
			(ok true)
		)
	)
	
	(define-public (pay-liquidator (position-id uint)) 
		(let (
			(position (unwrap! (map-get? positions position-id) err-invalid-position-id))
			(event {type: "pay_liquidator", positionId: position-id, sender: tx-sender})
		)
			;; access checks
			(asserts! (is-eq true (is-eq tx-sender (get tetris position))) err-unauthorized-principal)
			(asserts! (is-eq true (is-eq tx-sender tetris-principal)) err-unauthorized-principal)
	
			;; vault checks
			(asserts! (is-eq (var-get current-vault-state) vault-state-open) err-invalid-vault-state)
	
			;; common position checks
			(asserts! (is-some (some position)) err-invalid-position-id) ;; position must exist
			(asserts! (is-eq true (<= position-id (var-get last-position-id))) err-invalid-position-id) ;; position must be within valid range
	
			;; specific context checks
			(asserts! (is-eq (get state position) collateral-state-liquidated) err-invalid-collateral-state)
			(asserts! (is-eq false (is-eq (get liquidator position) dummy-principal)) err-no-liquidator-defined)
			(asserts! (is-eq false (is-eq (get proofTxId position) dummy-proof-tx-id)) err-no-proof-tx-defined)
	
			(try! (transfer-ft collateral-asset-contract (get collateralBalance position) (as-contract tx-sender) (get liquidator position)))
			(map-set positions position-id (merge position {state: collateral-state-archived, collateralBalance: u0}))
			(print event)
			(ok true)
		)
	)
	
	(define-public (get-available-collateral-balance)
		(let (
			(vault-balance (unwrap! (balance-ft collateral-asset-contract (as-contract tx-sender)) err-not-a-number)) 
			(locked-balance (unwrap! (get-locked-collateral-balance) err-not-a-number))
		)
			(ok (if (>= vault-balance locked-balance) (- vault-balance locked-balance) u0))
		)
	)
	
	(define-public (get-borrower-position  (position-id uint))
	(let (
			(position (unwrap! (map-get? positions position-id) err-invalid-position-id))
		)
			(ok position)
		)
	)
	
	;; read only functions
	(define-read-only (get-position (position-id uint))
		(map-get? positions position-id)
	)
	
	(define-read-only (get-locked-collateral-balance)
		(let (
			(total (fold sum-position-locked-balances position-ids u0))
		) 
		(ok total)
		)
	)
	
	(define-read-only (get-vault-state)
		(var-get current-vault-state)
	)
	
	;; get position state
	(define-read-only (get-position-state (position-id uint))
		(let (
			(position (unwrap! (map-get? positions position-id) err-invalid-position-id))
		)
			(ok (get state position))
		)
	)
	;;
	
	;; private functions
	(define-private (transfer-ft (token-contract <ft-trait>) (amount uint) (sender principal) (recipient principal))
		(contract-call? token-contract transfer amount sender recipient none)
	)
	
	(define-private (balance-ft (token-contract <ft-trait>) (who principal))
		(contract-call? token-contract get-balance who)
	)
	
	(define-private (sum-position-locked-balances (addend uint) (sum uint))
		(let (
			(position (default-to dummy-position (map-get? positions addend)))
		)
			(+ (get collateralBalance position) sum)
		)
	)
	
	(define-private (common-add-remove-position-checks (position (tuple (borrower principal) (collateralBalance uint) (state uint) (id uint))))
		(begin 
			;; ownership checks
			(asserts! (is-eq tx-sender contract-owner) err-owner-only) ;; only owner can call
	
			;; vault checks
			(asserts! (is-eq (var-get current-vault-state) vault-state-open) err-invalid-vault-state) ;; vault state must be open
	
			;; common position checks
			(asserts! (is-eq (get state position) collateral-state-open) err-invalid-collateral-state)
			(asserts! (is-eq tx-sender (get borrower position)) err-owner-only) ;; borrower must match position principal
			(asserts! (is-some (some position)) err-invalid-position-id) ;; position must exist
			(asserts! (is-eq true (<= (get id position) (var-get last-position-id))) err-invalid-position-id) ;; position must be within valid range
			(ok true)
		)
	)	
