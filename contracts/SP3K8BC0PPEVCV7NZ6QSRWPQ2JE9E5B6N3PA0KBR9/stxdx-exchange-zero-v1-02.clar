(impl-trait .trait-ownable.ownable-trait)
(define-constant err-unauthorised-sender (err u3000))
(define-constant err-maker-asset-mismatch (err u3001))
(define-constant err-taker-asset-mismatch (err u3002))
(define-constant err-asset-data-mismatch (err u3003))
(define-constant err-left-order-expired (err u3005))
(define-constant err-right-order-expired (err u3006))
(define-constant err-left-authorisation-failed (err u3007))
(define-constant err-right-authorisation-failed (err u3008))
(define-constant err-maximum-fill-reached (err u3009))
(define-constant err-maker-not-tx-sender (err u3010))
(define-constant err-invalid-timestamp (err u3011))
(define-constant err-unknown-asset-id (err u3501))
(define-constant err-unauthorised-caller (err u4000))
(define-constant err-asset-data-too-long (err u5003))
(define-constant err-sender-fee-payment-failed (err u5007))
(define-constant err-asset-contract-call-failed (err u5008))
(define-constant err-stop-not-triggered (err u5009))
(define-constant err-invalid-order-type (err u5010))
(define-constant err-cancel-authorisation-failed (err u5011))
(define-constant err-paused (err u5012))
(define-constant err-left-sender-fee (err u5013))
(define-constant err-right-sender-fee (err u5014))
(define-constant err-untrusted-oracle (err u6000))
(define-constant err-no-oracle-data (err u6001))
(define-constant structured-data-prefix 0x534950303138)
(define-constant message-domain-mainnet 0xa2a2221ace8a76ed4729b2838098dd80712796258c80e454c818590c2e26333f)
(define-constant message-domain-testnet 0xced498e8ba3e44d9752ebdd05c2a064cadc411fad5ff1b1d5204857f105f495b)
(define-constant type-order-vanilla u0)
(define-constant type-order-fok u1)
(define-constant type-order-ioc u2)
(define-constant ONE_8 u100000000)
(define-constant MAX_UINT u340282366920938463463374607431768211455)
(define-data-var contract-owner principal tx-sender)
(define-data-var fee-address principal tx-sender)
(define-data-var is-paused bool false)
(define-map authorised-senders principal bool)
(define-map trusted-oracles (buff 33) bool)
(define-map oracle-symbols uint (buff 32))
(define-map triggered-orders (buff 32) { triggered: bool, timestamp: uint })
(define-data-var default-maker-fee uint u1000000)
(define-data-var default-taker-fee uint u1000000)
(define-map user-fee uint { maker-fee: uint, taker-fee: uint })
(define-read-only (message-domain)
	(if (is-eq chain-id u1)
		message-domain-mainnet
		message-domain-testnet
	)
)
(define-read-only (get-default-maker-fee)
	(var-get default-maker-fee)
)
(define-read-only (get-default-taker-fee)
	(var-get default-taker-fee)
)
(define-read-only (get-maker-fee (user-id uint))
	(match (map-get? user-fee user-id)
		fee 
		(get maker-fee fee)
		(var-get default-maker-fee)
	)
)
(define-read-only (get-taker-fee (user-id uint))
	(match (map-get? user-fee user-id)
		fee 
		(get taker-fee fee)
		(var-get default-taker-fee)
	)
)
(define-read-only (get-maker-fee-by-address (user principal))
	(match (contract-call? .stxdx-registry get-user-id user)
		user-id
		(get-maker-fee user-id)
		(var-get default-maker-fee)
	)
)
(define-read-only (get-taker-fee-by-address (user principal))
	(match (contract-call? .stxdx-registry get-user-id user)
		user-id
		(get-taker-fee user-id)
		(var-get default-taker-fee)
	)
)
(define-read-only (get-paused)
  (var-get is-paused)
)
(define-read-only (is-trusted-oracle (pubkey (buff 33)))
	(default-to false (map-get? trusted-oracles pubkey))
)
(define-read-only (get-oracle-symbol-or-fail (asset-id uint))
	(ok (unwrap! (map-get? oracle-symbols asset-id) err-unknown-asset-id))
)
(define-read-only (is-order-triggered (order-hash (buff 32)))
	(match (map-get? triggered-orders order-hash)
		value
		(get triggered value)
		false
	)
)
(define-read-only (get-triggered-orders-or-default (order-hash (buff 32)))
	(default-to { triggered: false, timestamp: MAX_UINT } (map-get? triggered-orders order-hash))
)
(define-read-only (hash-cancel-order (order-hash (buff 32)))
	(sha256 (default-to 0x (to-consensus-buff? { hash: order-hash, cancel: true })))
)
(define-read-only (get-contract-owner)
	(ok (var-get contract-owner))
)
(define-read-only (get-fee-address)
	(var-get fee-address)
)
(define-read-only (hash-order
	(order
		{
		sender: uint,
		sender-fee: uint,
		maker: uint,
		maker-asset: uint,
		taker-asset: uint,
		maker-asset-data: uint,
		taker-asset-data: uint,
		maximum-fill: uint,
		expiration-height: uint,
		salt: uint,
		risk: bool,
		stop: uint,
		timestamp: uint,
		type: uint
		}
	)
	)
	(sha256 (default-to 0x (to-consensus-buff? order)))
)
(define-read-only (validate-match
	(left-order
		{
		sender: uint,
		sender-fee: uint,
		maker: uint,
		maker-asset: uint,
		taker-asset: uint,
		maker-asset-data: uint,
		taker-asset-data: uint,
		maximum-fill: uint,
		expiration-height: uint,
		salt: uint,
		risk: bool,
		stop: uint,
		timestamp: uint,
		type: uint
		}
	)
	(right-order
		{
		sender: uint,
		sender-fee: uint,
		maker: uint,
		maker-asset: uint,
		taker-asset: uint,
		maker-asset-data: uint,
		taker-asset-data: uint,
		maximum-fill: uint,
		expiration-height: uint,
		salt: uint,
		risk: bool,
		stop: uint,
		timestamp: uint,
		type: uint
		}
	)
	(left-signature (buff 65))
	(right-signature (buff 65))	
	(left-oracle-data (optional { timestamp: uint, value: uint, signature: (buff 65) }))
	(right-oracle-data (optional { timestamp: uint, value: uint, signature: (buff 65) }))	
	(fill (optional uint))
	)
	(let
		(
			(users (try! (contract-call? .stxdx-registry get-two-users-from-id-or-fail (get maker left-order) (get maker right-order))))
			(left-order-hash (hash-order left-order))
			(right-order-hash (hash-order right-order))
			(order-fills (contract-call? .stxdx-registry get-two-order-fills left-order-hash right-order-hash))
			(left-order-fill (get order-1 order-fills))
			(right-order-fill (get order-2 order-fills))
			(fillable (min (- (get maximum-fill left-order) left-order-fill) (- (get maximum-fill right-order) right-order-fill)))
			(left-sender-fee (get-maker-fee (get maker left-order)))
			(right-sender-fee (get-taker-fee (get maker right-order)))
		)
		(try! (is-authorised-sender))
		;; there are more fills to do
		(match fill value (asserts! (>= fillable value) err-maximum-fill-reached) (asserts! (> fillable u0) err-maximum-fill-reached))		
		;; both orders are not expired
		(asserts! (< block-height (get expiration-height left-order)) err-left-order-expired)
		(asserts! (< block-height (get expiration-height right-order)) err-right-order-expired)				
		;; assets to be exchanged match
		(asserts! (is-eq (get maker-asset left-order) (get taker-asset right-order)) err-maker-asset-mismatch)
		(asserts! (is-eq (get taker-asset left-order) (get maker-asset right-order)) err-taker-asset-mismatch)
		;; asserts fee locked >= fee to be paid
		(asserts! (>= (get sender-fee left-order) left-sender-fee) err-left-sender-fee)
		(asserts! (>= (get sender-fee right-order) right-sender-fee) err-right-sender-fee)
		;; one side matches and the taker of the other side is smaller than maker.
		;; so that maker gives at most maker-asset-data, and taker takes at least taker-asset-data
		(asserts! 
			(or 
				(and
					(is-eq (get maker-asset-data left-order) (get taker-asset-data right-order))
					(<= (get taker-asset-data left-order) (get maker-asset-data right-order))				
				)				
				(and
					(is-eq (get taker-asset-data left-order) (get maker-asset-data right-order))
					(>= (get maker-asset-data left-order) (get taker-asset-data right-order))
				)
			)
			err-asset-data-mismatch
		)
		;; stop limit order
		(if (and (or (is-order-triggered left-order-hash) (is-eq (get stop left-order) u0)) (or (is-order-triggered right-order-hash) (is-eq (get stop right-order) u0)))
			(asserts! 
				(<= 
					(if (is-order-triggered left-order-hash)
						(get timestamp (get-triggered-orders-or-default left-order-hash))
						(get timestamp left-order)
					)	
					(if (is-order-triggered right-order-hash) 
						(get timestamp (get-triggered-orders-or-default right-order-hash))
						(get timestamp right-order)
					)
				) 
				err-invalid-timestamp
			) ;; left-order must be older than right-order
			(if (and (or (is-order-triggered left-order-hash) (is-eq (get stop left-order) u0)) (is-some right-oracle-data))
				(let
					(
						(oracle-data (unwrap! right-oracle-data err-no-oracle-data))
						(is-buy (is-some (map-get? oracle-symbols (get taker-asset right-order))))
						(symbol (try! (get-oracle-symbol-or-fail (if is-buy (get taker-asset right-order) (get maker-asset right-order)))))
						(signer (try! (contract-call? .redstone-verify recover-signer (get timestamp oracle-data) (list {value: (get value oracle-data), symbol: symbol}) (get signature oracle-data))))
					)
					(asserts! (is-trusted-oracle signer) err-untrusted-oracle)
					(asserts! (<= (get timestamp right-order) (get timestamp oracle-data)) err-invalid-timestamp)				
					(asserts! 
						(<= 
							(if (is-order-triggered left-order-hash)
								(get timestamp (get-triggered-orders-or-default left-order-hash))
								(get timestamp left-order)
							)
							(get timestamp oracle-data)
						)
						err-invalid-timestamp
					)
					(if (get risk right-order) ;; it is risk-mgmt stop limit, i.e. buy on the way up (to hedge sell) or sell on the way down (to hedge buy)
						(asserts! (if is-buy (>= (get value oracle-data) (get stop right-order)) (<= (get value oracle-data) (get stop right-order))) err-stop-not-triggered)
						(asserts! (if is-buy (<= (get value oracle-data) (get stop right-order)) (>= (get value oracle-data) (get stop right-order))) err-stop-not-triggered)
					)				
				)
				(if (and (is-some left-oracle-data) (or (is-order-triggered right-order-hash) (is-eq (get stop right-order) u0)))
					(let
						(
							(oracle-data (unwrap! left-oracle-data err-no-oracle-data))
							(is-buy (is-some (map-get? oracle-symbols (get taker-asset left-order))))
							(symbol (try! (get-oracle-symbol-or-fail (if is-buy (get taker-asset left-order) (get maker-asset left-order)))))
							(signer (try! (contract-call? .redstone-verify recover-signer (get timestamp oracle-data) (list {value: (get value oracle-data), symbol: symbol}) (get signature oracle-data))))
						)
						(asserts! (is-trusted-oracle signer) err-untrusted-oracle)
						(asserts! (<= (get timestamp left-order) (get timestamp oracle-data)) err-invalid-timestamp)				
						(asserts! 
							(<= 
								(get timestamp oracle-data) 
								(if (is-order-triggered right-order-hash)
									(get timestamp (get-triggered-orders-or-default right-order-hash))
									(get timestamp right-order)
							 	)
							) 
							err-invalid-timestamp
						)
						(if (get risk left-order) ;; it is risk-mgmt stop limit, i.e. buy on the way up (to hedge sell) or sell on the way down (to hedge buy)
							(asserts! (if is-buy (>= (get value oracle-data) (get stop left-order)) (<= (get value oracle-data) (get stop left-order))) err-stop-not-triggered)
							(asserts! (if is-buy (<= (get value oracle-data) (get stop left-order)) (>= (get value oracle-data) (get stop left-order))) err-stop-not-triggered)
						)				
					)
					(let 
						(							
							(left-data (unwrap! left-oracle-data err-no-oracle-data))
							(left-buy (is-some (map-get? oracle-symbols (get taker-asset left-order))))							
							(symbol (try! (get-oracle-symbol-or-fail (if left-buy (get taker-asset left-order) (get maker-asset left-order)))))
							(left-signer (try! (contract-call? .redstone-verify recover-signer (get timestamp left-data) (list {value: (get value left-data), symbol: symbol}) (get signature left-data))))							
							(right-data (unwrap! right-oracle-data err-no-oracle-data))							
							(right-buy (not left-buy))
							(right-signer (try! (contract-call? .redstone-verify recover-signer (get timestamp right-data) (list {value: (get value right-data), symbol: symbol}) (get signature right-data))))							
						)
						(asserts! (and (is-trusted-oracle left-signer) (is-trusted-oracle right-signer)) err-untrusted-oracle)
						(asserts! (and (<= (get timestamp left-order) (get timestamp left-data)) (<= (get timestamp right-order) (get timestamp right-data))) err-invalid-timestamp)				
						(asserts! (<= (get timestamp left-data) (get timestamp right-data)) err-invalid-timestamp)
						(if (get risk left-order) ;; it is risk-mgmt stop limit, i.e. buy on the way up (to hedge sell) or sell on the way down (to hedge buy)
							(asserts! (if left-buy (>= (get value left-data) (get stop left-order)) (<= (get value left-data) (get stop left-order))) err-stop-not-triggered)
							(asserts! (if left-buy (<= (get value left-data) (get stop left-order)) (>= (get value left-data) (get stop left-order))) err-stop-not-triggered)
						)	
						(if (get risk right-order) ;; it is risk-mgmt stop limit, i.e. buy on the way up (to hedge sell) or sell on the way down (to hedge buy)
							(asserts! (if right-buy (>= (get value right-data) (get stop right-order)) (<= (get value right-data) (get stop right-order))) err-stop-not-triggered)
							(asserts! (if right-buy (<= (get value right-data) (get stop right-order)) (>= (get value right-data) (get stop right-order))) err-stop-not-triggered)
						)											
					)
				)
			)
		)	
	
		(asserts! (validate-authorisation left-order-fill (get maker (get user-1 users)) (get pub-key (get user-1 users)) left-order-hash left-signature) err-left-authorisation-failed)
		(asserts! (validate-authorisation right-order-fill (get maker (get user-2 users))  (get pub-key (get user-2 users)) right-order-hash right-signature) err-right-authorisation-failed)
		(ok
			{
			left-order-hash: left-order-hash,
			right-order-hash: right-order-hash,
			left-order-fill: left-order-fill,
			right-order-fill: right-order-fill,
			fillable: fillable,
			left-order-make: (get maker-asset-data left-order), ;; execution is always done at left order's price
			right-order-make: (get taker-asset-data left-order), ;; execution is always done at left order's price
			left-sender-fee: left-sender-fee,
			right-sender-fee: right-sender-fee
			}
		)
	)
)
(define-public (set-default-maker-fee (new-maker-fee uint))
	(begin 
		(try! (is-contract-owner))
		(ok (var-set default-maker-fee new-maker-fee))
	)
)
(define-public (set-default-taker-fee (new-taker-fee uint))
	(begin 
		(try! (is-contract-owner))
		(ok (var-set default-taker-fee new-taker-fee))
	)
)
(define-public (set-fee (user-id uint) (maker-fee uint) (taker-fee uint))
	(begin 
		(try! (is-contract-owner))
		(ok (map-set user-fee user-id { maker-fee: maker-fee, taker-fee: taker-fee }))
	)
)
(define-public (set-fee-by-address (user principal) (maker-fee uint) (taker-fee uint))
	(set-fee (try! (contract-call? .stxdx-registry get-user-id-or-fail user)) maker-fee taker-fee)
)
(define-public (set-paused (paused bool))
  (begin
    (try! (is-contract-owner))
    (ok (var-set is-paused paused))
  )
)
(define-public (set-trusted-oracle (pubkey (buff 33)) (trusted bool))
	(begin
		(try! (is-contract-owner))
		(ok (map-set trusted-oracles pubkey trusted))
	)
)
(define-public (set-oracle-symbol (asset-id uint) (symbol (buff 32)))
	(begin 
		(try! (is-contract-owner))
		(ok (map-set oracle-symbols asset-id symbol))
	)
)
(define-public (remove-oracle-symbol (asset-id uint))
	(begin 
		(try! (is-contract-owner))
		(ok (map-delete oracle-symbols asset-id))
	)
)
(define-public (set-contract-owner (new-owner principal))
	(begin
		(try! (is-contract-owner))
		(ok (var-set contract-owner new-owner))
	)
)
(define-public (set-fee-address (new-fee-address principal))
	(begin
		(try! (is-contract-owner))
		(ok (var-set fee-address new-fee-address))
	)
)
(define-public (set-authorised-sender (authorised bool) (sender principal))
	(begin
		(try! (is-contract-owner))
		(ok (map-set authorised-senders sender authorised))
	)
)
(define-public (cancel-order 
	(order
		{
		sender: uint,
		sender-fee: uint,
		maker: uint,
		maker-asset: uint,
		taker-asset: uint,
		maker-asset-data: uint,
		taker-asset-data: uint,
		maximum-fill: uint,
		expiration-height: uint,
		salt: uint,
		risk: bool,
		stop: uint,
		timestamp: uint,
		type: uint
		}
	)
	(signature (buff 65)))
	(let 
		(
			(order-hash (hash-order order))
			(cancel-hash (hash-cancel-order order-hash))
			(pub-key (get pub-key (try! (contract-call? .stxdx-registry user-from-id-or-fail (get maker order)))))
		)
		(try! (is-authorised-sender))	
		(asserts! 
			(or
				(is-eq type-order-fok (get type order))
				(is-eq type-order-ioc (get type order))
				(is-eq (secp256k1-recover? (sha256 (concat structured-data-prefix (concat (message-domain) cancel-hash))) signature) (ok pub-key))
			) 
			err-cancel-authorisation-failed
		)
		;; cancel means no more fill, so setting its fill to maximum-fill achieve it.
		(contract-call? .stxdx-registry set-order-fill order-hash (get maximum-fill order))	
	)
)
(define-public (cancel-order-many
	(cancel-order-list
		(list 200
			{ 
				order: { sender: uint, sender-fee: uint, maker: uint, maker-asset: uint, taker-asset: uint, maker-asset-data: uint, taker-asset-data: uint, maximum-fill: uint, expiration-height: uint, salt: uint, risk: bool, stop: uint, timestamp: uint, type: uint },
				signature: (buff 65)
			}		
		) 
	))
	(ok (map cancel-order-iter cancel-order-list))
)
(define-public (approve-order
	(order
		{
		sender: uint,
		sender-fee: uint,
		maker: uint,
		maker-asset: uint,
		taker-asset: uint,
		maker-asset-data: uint,
		taker-asset-data: uint,
		maximum-fill: uint,
		expiration-height: uint,
		salt: uint,
		risk: bool,
		stop: uint,
		timestamp: uint,
		type: uint
		}
	)
	)
	(begin
		(asserts! (not (var-get is-paused)) err-paused)
		(asserts! (is-eq (try! (contract-call? .stxdx-registry user-maker-from-id-or-fail (get maker order))) tx-sender) err-maker-not-tx-sender)
		(contract-call? .stxdx-registry set-order-approval (hash-order order) true)
	)
)
(define-public (match-orders
	(left-order
		{
		sender: uint,
		sender-fee: uint,
		maker: uint,
		maker-asset: uint,
		taker-asset: uint,
		maker-asset-data: uint,
		taker-asset-data: uint,
		maximum-fill: uint,
		expiration-height: uint,
		salt: uint,
		risk: bool,
		stop: uint,
		timestamp: uint,
		type: uint
		}
	)
	(right-order
		{
		sender: uint,
		sender-fee: uint,
		maker: uint,
		maker-asset: uint,
		taker-asset: uint,
		maker-asset-data: uint,
		taker-asset-data: uint,
		maximum-fill: uint,
		expiration-height: uint,
		salt: uint,
		risk: bool,
		stop: uint,
		timestamp: uint,
		type: uint
		}
	)
	(left-signature (buff 65))
	(right-signature (buff 65))
	(left-oracle-data (optional { timestamp: uint, value: uint, signature: (buff 65) }))
	(right-oracle-data (optional { timestamp: uint, value: uint, signature: (buff 65) }))
	(fill (optional uint))
	)
	(let
		(
			(validation-data (try! (validate-match left-order right-order left-signature right-signature left-oracle-data right-oracle-data fill)))
			(fillable (match fill value value (get fillable validation-data)))
			(left-order-make (get left-order-make validation-data))
			(right-order-make (get right-order-make validation-data))
			(left-sender-fee (get left-sender-fee validation-data))
			(right-sender-fee (get right-sender-fee validation-data))
		)
		(asserts! (not (var-get is-paused)) err-paused)
		(and 
			(not (is-order-triggered (get left-order-hash validation-data)))
			(map-set triggered-orders 
				(get left-order-hash validation-data)
				{
					triggered: true,
					timestamp: (match left-oracle-data value (get timestamp value) (get timestamp left-order))
				}
			)
		)
		(and
			(not (is-order-triggered (get right-order-hash validation-data)))
			(map-set triggered-orders 
				(get right-order-hash validation-data)
				{
					triggered: true,
					timestamp: (match right-oracle-data value (get timestamp value) (get timestamp right-order))
				}
			)
		)	
		(try! (settle-order left-order (* fillable left-order-make) (get maker right-order) left-sender-fee))
		(try! (settle-order right-order (* fillable right-order-make) (get maker left-order) right-sender-fee))
		(try! (contract-call? .stxdx-registry set-two-order-fills (get left-order-hash validation-data) (+ (get left-order-fill validation-data) fillable) (get right-order-hash validation-data) (+ (get right-order-fill validation-data) fillable)))
		(ok 
			{ 
			fillable: fillable, 
			left-order-make: left-order-make, 
			right-order-make: right-order-make,
			left-sender-fee: left-sender-fee,
			right-sender-fee: right-sender-fee
			}
		)
	)
)
(define-private (cancel-order-iter 
	(one-cancel-order
		{ 
			order: { sender: uint, sender-fee: uint, maker: uint, maker-asset: uint, taker-asset: uint, maker-asset-data: uint, taker-asset-data: uint, maximum-fill: uint, expiration-height: uint, salt: uint, risk: bool, stop: uint, timestamp: uint, type: uint },
			signature: (buff 65)
		}
	))
	(cancel-order (get order one-cancel-order) (get signature one-cancel-order))
)
(define-private (is-contract-owner)
	(ok (asserts! (is-eq (var-get contract-owner) tx-sender) err-unauthorised-caller))
)
(define-private (is-authorised-sender)
	(ok (asserts! (default-to false (map-get? authorised-senders contract-caller)) err-unauthorised-sender))
)
(define-private (validate-authorisation (fills uint) (maker principal) (pub-key (buff 33)) (hash (buff 32)) (signature (buff 65)))
	(begin
		(or
			(> fills u0)
			(is-eq maker tx-sender)
			(and (is-eq (len signature) u0) (contract-call? .stxdx-registry get-order-approval maker hash))
			(is-eq (secp256k1-recover? (sha256 (concat structured-data-prefix (concat (message-domain) hash))) signature) (ok pub-key))
		)
	)
)
(define-private (settle-order
	(order
		{
		sender: uint,
		sender-fee: uint,
		maker: uint,
		maker-asset: uint,
		taker-asset: uint,
		maker-asset-data: uint,
		taker-asset-data: uint,
		maximum-fill: uint,
		expiration-height: uint,
		salt: uint,
		risk: bool,
		stop: uint,
		timestamp: uint,
		type: uint
		}
	)
	(amount uint)
	(taker uint)
	(fee uint)
	)
	(begin
		(as-contract (unwrap! (contract-call? .stxdx-wallet-zero transfer amount (get maker order) taker (get maker-asset order)) err-asset-contract-call-failed))
		(let 
			(
				(fee-address-id (try! (contract-call? .stxdx-registry get-user-id-or-fail (var-get fee-address))))
			)
			(and
				(> fee u0)
				(as-contract (unwrap! (contract-call? .stxdx-wallet-zero transfer (mul-down fee amount) (get maker order) fee-address-id (get maker-asset order)) err-sender-fee-payment-failed))
			)
		)
		(ok true)
	)
)
(define-private (min (a uint) (b uint))
	(if (< a b) a b)
)
(define-read-only (mul-down (a uint) (b uint))
    (/ (* a b) ONE_8)
)
(define-private (max (a uint) (b uint))
  (if (<= a b) b a)
)