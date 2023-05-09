(impl-trait .trait-ownable.ownable-trait)
(use-trait sip010-trait .trait-sip-010.sip-010-trait)
(define-constant err-unauthorised-caller (err u6000))
(define-constant err-unauthorised-sender (err u6001))
(define-constant err-unknown-request-id (err u6002))
(define-constant err-unauthorised-request (err u6003))
(define-constant err-amount-exceeds-balance (err u6004))
(define-constant err-invalid-grace-period (err u6005))
(define-constant err-unknown-asset-id (err u3501))
(define-data-var contract-owner principal tx-sender)
(define-map authorised-approvers principal bool)
(define-map authorised-exchanges principal bool)
(define-map user-balance 
	{
		user-id: uint,
		asset-id: uint
	}
	uint
)
(define-constant max-grace-period u1008)
(define-data-var request-grace-period uint u100)
(define-data-var request-nonce uint u0)
(define-map requests 
	uint
	{
		amount: uint,
		user-id: uint,
		asset-id: uint,
		asset: principal,
		request-block: uint,
		approved: bool,
		transferred-block: uint
	}
)
(define-public (set-request-grace-period (new-grace-period uint))
	(begin
		(try! (is-contract-owner))
		(asserts! (>= max-grace-period new-grace-period) err-invalid-grace-period)
		(ok (var-set request-grace-period new-grace-period))
	)
)
(define-read-only (get-request-grace-period)
	(ok (var-get request-grace-period))
)
(define-read-only (get-request-or-fail (request-id uint))
	(ok (unwrap! (map-get? requests request-id) err-unknown-request-id))
)
(define-private (is-contract-owner)
	(ok (asserts! (is-eq (var-get contract-owner) tx-sender) err-unauthorised-caller))
)
(define-public (set-contract-owner (new-owner principal))
	(begin
		(try! (is-contract-owner))
		(ok (var-set contract-owner new-owner))
	)
)
(define-read-only (get-contract-owner)
	(ok (var-get contract-owner))
)
(define-public (set-authorised-approver (authorised bool) (sender principal))
	(begin
		(try! (is-contract-owner))
		(ok (map-set authorised-approvers sender authorised))
	)
)
(define-private (is-authorised-approver)
	(ok (asserts! (default-to false (map-get? authorised-approvers tx-sender)) err-unauthorised-caller))
)
(define-public (approve-exchange (exchange principal) (approved bool))
	(begin
		(try! (is-contract-owner))
		(ok (map-set authorised-exchanges exchange approved))
	)
)
(define-read-only (is-approved-exchange (exchange principal))
	(default-to false (map-get? authorised-exchanges exchange))
)
(define-read-only (get-user-balance-or-default (user-id uint) (asset-id uint))
	(default-to u0 (map-get? user-balance { user-id: user-id, asset-id: asset-id }))
)
(define-public (transfer-in-many (user-id uint) (amounts (list 10 uint)) (asset-ids (list 10 uint)) (asset-traits (list 10 <sip010-trait>)))
	(ok 
		(map transfer-in 
			amounts
			(list user-id  user-id  user-id  user-id  user-id  user-id  user-id  user-id  user-id  user-id)
			asset-ids
			asset-traits
		)
	)
)
(define-public (transfer-in (amount uint) (user-id uint) (asset-id uint) (asset-trait <sip010-trait>))
	(begin 
		(asserts! (is-eq (try! (contract-call? .stxdx-registry asset-from-id-or-fail asset-id)) (contract-of asset-trait)) err-unknown-asset-id)
		(try! (contract-call? asset-trait transfer-fixed amount tx-sender (as-contract tx-sender) none))
		(map-set user-balance { user-id: user-id, asset-id: asset-id } (+ (get-user-balance-or-default user-id asset-id) amount))
		(print {type: "transfer_in", asset-id: asset-id, amount: amount, user-id: user-id, sender: tx-sender})
		(ok true)
	)
)
(define-public (request-transfer-out-many (user-id uint) (amounts (list 10 uint)) (asset-ids (list 10 uint)) (assets (list 10 principal)))
	(ok 
		(map request-transfer-out
			amounts
			(list user-id  user-id  user-id  user-id  user-id  user-id  user-id  user-id  user-id  user-id)
			asset-ids
			assets
		)
	)
)
(define-public (request-transfer-out (amount uint) (user-id uint) (asset-id uint) (asset principal))
	(let 
		(
			(user (try! (contract-call? .stxdx-registry user-from-id-or-fail user-id)))
			(request-id (+ (var-get request-nonce) u1))
		)
		(asserts! (is-eq (try! (contract-call? .stxdx-registry asset-from-id-or-fail asset-id)) asset) err-unknown-asset-id)
		(asserts! (is-eq tx-sender (get maker user)) err-unauthorised-caller)
		(asserts! (<= amount (get-user-balance-or-default user-id asset-id)) err-amount-exceeds-balance)
		(map-set requests request-id { 
			amount: amount, 
			user-id: user-id, 
			asset-id: asset-id, 
			asset: asset, 
			request-block: block-height, 
			approved: false, 
			transferred-block: u340282366920938463463374607431768211455 
		})
		(var-set request-nonce request-id)
		(print {type: "request_transfer_out", request-id: request-id, user-id: user-id, asset-id: asset-id, amount: amount})
		(ok request-id)
	)
)
(define-public (approve-transfer-out (request-id uint) (approved bool))
	(begin
		(asserts! (or (is-ok (is-authorised-approver)) (is-ok (is-contract-owner))) err-unauthorised-caller)
		(print {type: "approve_transfer_out", request-id: request-id, approved: approved})
		(ok (map-set requests request-id (merge (try! (get-request-or-fail request-id)) { approved: approved })))
	)
)
(define-public (approve-and-transfer-out (request-id uint) (asset-trait <sip010-trait>))
	(begin 
		(try! (approve-transfer-out request-id true))
		(transfer-out request-id asset-trait)
	)
)
(define-public (approve-and-transfer-out-many (asset-trait <sip010-trait>) (request-ids (list 200 uint)))
	(ok
		(map approve-and-transfer-out 
			request-ids
			(list 
			asset-trait	asset-trait	asset-trait	asset-trait	asset-trait	asset-trait	asset-trait	asset-trait	asset-trait	asset-trait
			asset-trait	asset-trait	asset-trait	asset-trait	asset-trait	asset-trait	asset-trait	asset-trait	asset-trait	asset-trait
			asset-trait	asset-trait	asset-trait	asset-trait	asset-trait	asset-trait	asset-trait	asset-trait	asset-trait	asset-trait
			asset-trait	asset-trait	asset-trait	asset-trait	asset-trait	asset-trait	asset-trait	asset-trait	asset-trait	asset-trait
			asset-trait	asset-trait	asset-trait	asset-trait	asset-trait	asset-trait	asset-trait	asset-trait	asset-trait	asset-trait
			asset-trait	asset-trait	asset-trait	asset-trait	asset-trait	asset-trait	asset-trait	asset-trait	asset-trait	asset-trait
			asset-trait	asset-trait	asset-trait	asset-trait	asset-trait	asset-trait	asset-trait	asset-trait	asset-trait	asset-trait
			asset-trait	asset-trait	asset-trait	asset-trait	asset-trait	asset-trait	asset-trait	asset-trait	asset-trait	asset-trait
			asset-trait	asset-trait	asset-trait	asset-trait	asset-trait	asset-trait	asset-trait	asset-trait	asset-trait	asset-trait
			asset-trait	asset-trait	asset-trait	asset-trait	asset-trait	asset-trait	asset-trait	asset-trait	asset-trait	asset-trait
			asset-trait	asset-trait	asset-trait	asset-trait	asset-trait	asset-trait	asset-trait	asset-trait	asset-trait	asset-trait
			asset-trait	asset-trait	asset-trait	asset-trait	asset-trait	asset-trait	asset-trait	asset-trait	asset-trait	asset-trait
			asset-trait	asset-trait	asset-trait	asset-trait	asset-trait	asset-trait	asset-trait	asset-trait	asset-trait	asset-trait
			asset-trait	asset-trait	asset-trait	asset-trait	asset-trait	asset-trait	asset-trait	asset-trait	asset-trait	asset-trait
			asset-trait	asset-trait	asset-trait	asset-trait	asset-trait	asset-trait	asset-trait	asset-trait	asset-trait	asset-trait
			asset-trait	asset-trait	asset-trait	asset-trait	asset-trait	asset-trait	asset-trait	asset-trait	asset-trait	asset-trait
			asset-trait	asset-trait	asset-trait	asset-trait	asset-trait	asset-trait	asset-trait	asset-trait	asset-trait	asset-trait
			asset-trait	asset-trait	asset-trait	asset-trait	asset-trait	asset-trait	asset-trait	asset-trait	asset-trait	asset-trait
			asset-trait	asset-trait	asset-trait	asset-trait	asset-trait	asset-trait	asset-trait	asset-trait	asset-trait	asset-trait
			asset-trait	asset-trait	asset-trait	asset-trait	asset-trait	asset-trait	asset-trait	asset-trait	asset-trait	asset-trait
			)
		)
	)
)
(define-public (transfer-out (request-id uint) (asset-trait <sip010-trait>))
	(let 
		(
			(request (try! (get-request-or-fail request-id)))
			(user (try! (contract-call? .stxdx-registry user-from-id-or-fail (get user-id request))))
		)
		(asserts! (is-eq (get asset request) (contract-of asset-trait)) err-unknown-asset-id)		
		(asserts! (or (is-ok (is-authorised-approver)) (is-eq tx-sender (get maker user)) (is-ok (is-contract-owner))) err-unauthorised-caller)
		(asserts! (or (get approved request) (>= block-height (+ (get request-block request) (var-get request-grace-period)))) err-unauthorised-request)
		(asserts! (> (get transferred-block request) block-height) err-unauthorised-request)
		(asserts! (<= (get amount request) (get-user-balance-or-default (get user-id request) (get asset-id request))) err-amount-exceeds-balance) 
		
		(map-set user-balance { user-id: (get user-id request), asset-id: (get asset-id request) } (- (get-user-balance-or-default (get user-id request) (get asset-id request)) (get amount request)))	
		(map-set requests request-id (merge request { transferred-block: block-height }))		
		(as-contract (try! (contract-call? asset-trait transfer-fixed (get amount request) tx-sender (get maker user) none)))
		(print {type: "transfer_out", request-id: request-id, user-id: (get user-id request), asset-id: (get asset-id request), amount: (get amount request)})
		(ok true)		
	)
)	
(define-public (transfer (amount uint) (sender-id uint) (recipient-id uint) (asset-id uint))
	(let 
		(
			(sender (try! (contract-call? .stxdx-registry user-from-id-or-fail sender-id)))
		)
		(asserts! (or (is-approved-exchange contract-caller) (is-eq tx-sender (get maker sender))) err-unauthorised-caller)
		(asserts! (<= amount (get-user-balance-or-default sender-id asset-id)) err-amount-exceeds-balance)
		(map-set user-balance { user-id: sender-id, asset-id: asset-id } (- (get-user-balance-or-default sender-id asset-id) amount))
		(map-set user-balance { user-id: recipient-id, asset-id: asset-id } (+ (get-user-balance-or-default recipient-id asset-id) amount))
		(print {type: "internal_transfer", asset-id: asset-id, amount: amount, sender-id: sender-id, recipient-id: recipient-id})
		(ok true)
	)
)