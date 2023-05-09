(impl-trait .trait-ownable.ownable-trait)
(define-data-var contract-owner principal tx-sender)
(define-map authorised-senders principal bool)
(define-constant err-unauthorised-caller (err u7000))
(define-constant err-unauthorised-sender (err u7001))
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
(define-public (set-authorised-sender (authorised bool) (sender principal))
	(begin
		(try! (is-contract-owner))
		(ok (map-set authorised-senders sender authorised))
	)
)
(define-private (is-authorised-sender)
	(ok (asserts! (default-to false (map-get? authorised-senders contract-caller)) err-unauthorised-sender))
)
(define-public (match-orders
	(left-order { sender: uint, sender-fee: uint, maker: uint, maker-asset: uint, taker-asset: uint, maker-asset-data: uint, taker-asset-data: uint, maximum-fill: uint, expiration-height: uint, salt: uint, risk: bool, stop: uint, timestamp: uint, type: uint })
	(right-order { sender: uint, sender-fee: uint, maker: uint, maker-asset: uint, taker-asset: uint, maker-asset-data: uint, taker-asset-data: uint, maximum-fill: uint, expiration-height: uint, salt: uint, risk: bool, stop: uint, timestamp: uint, type: uint })
	(left-signature (buff 65))
	(right-signature (buff 65))
	(left-oracle-data (optional { timestamp: uint, value: uint, signature: (buff 65) }))
	(right-oracle-data (optional { timestamp: uint, value: uint, signature: (buff 65) }))		
	(fill (optional uint)))
	(begin
		(try! (is-authorised-sender))
		(as-contract (contract-call? .stxdx-exchange-zero match-orders left-order right-order left-signature right-signature left-oracle-data right-oracle-data fill))
	)
)
(define-private (match-orders-iter 
	(matched-orders
		{
			left-order: { sender: uint, sender-fee: uint, maker: uint, maker-asset: uint, taker-asset: uint, maker-asset-data: uint, taker-asset-data: uint, maximum-fill: uint, expiration-height: uint, salt: uint, risk: bool, stop: uint, timestamp: uint, type: uint },
			right-order: { sender: uint, sender-fee: uint, maker: uint, maker-asset: uint, taker-asset: uint, maker-asset-data: uint, taker-asset-data: uint, maximum-fill: uint, expiration-height: uint, salt: uint, risk: bool, stop: uint, timestamp: uint, type: uint },
			left-signature: (buff 65),
			right-signature: (buff 65),
			left-oracle-data: (optional { timestamp: uint, value: uint, signature: (buff 65) }),
			right-oracle-data: (optional { timestamp: uint, value: uint, signature: (buff 65) }), 
			fill: (optional uint)
		}
	))
	(as-contract (contract-call? .stxdx-exchange-zero match-orders (get left-order matched-orders) (get right-order matched-orders) (get left-signature matched-orders) (get right-signature matched-orders) (get left-oracle-data matched-orders) (get right-oracle-data matched-orders) (get fill matched-orders)))
)
(define-public (match-orders-many 
	(matched-orders-list
		(list 200 
			{
				left-order: { sender: uint, sender-fee: uint, maker: uint, maker-asset: uint, taker-asset: uint, maker-asset-data: uint, taker-asset-data: uint, maximum-fill: uint, expiration-height: uint, salt: uint, risk: bool, stop: uint, timestamp: uint, type: uint },
				right-order: { sender: uint, sender-fee: uint, maker: uint, maker-asset: uint, taker-asset: uint, maker-asset-data: uint, taker-asset-data: uint, maximum-fill: uint, expiration-height: uint, salt: uint, risk: bool, stop: uint, timestamp: uint, type: uint },
				left-signature: (buff 65),
				right-signature: (buff 65),
				left-oracle-data: (optional { timestamp: uint, value: uint, signature: (buff 65) }),
				right-oracle-data: (optional { timestamp: uint, value: uint, signature: (buff 65) }),				
				fill: (optional uint)
			}
		)
	))
	(begin
		(try! (is-authorised-sender))
		(ok (map match-orders-iter matched-orders-list))
	)
)