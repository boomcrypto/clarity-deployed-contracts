
(use-trait nft-trait .sip009-nft-trait.sip009-nft-trait)
(use-trait ft-trait .sip010-ft-trait.sip010-ft-trait)

(define-constant contract-owner tx-sender)
(define-constant dummy-token .dummy-token)

;; listing errors
(define-constant err-expiry-in-past (err u1000))
(define-constant err-price-zero (err u1001))
(define-constant err-minimum-commission (err u1002))
(define-constant err-maximum-commission (err u1003))
(define-constant err-listings-frozen (err u1004))

;; cancelling and fulfiling errors
(define-constant err-unknown-listing (err u2000))
(define-constant err-unauthorised (err u2001))
(define-constant err-listing-expired (err u2002))
(define-constant err-nft-asset-mismatch (err u2003))
(define-constant err-payment-asset-mismatch (err u2004))
(define-constant err-maker-taker-equal (err u2005))
(define-constant err-unintended-taker (err u2006))
(define-constant err-asset-contract-not-whitelisted (err u2007))
(define-constant err-payment-contract-not-whitelisted (err u2008))
(define-constant err-unlistings-frozen (err u2009))
(define-constant err-buy-frozen (err u2010))


(define-map listings
	uint
	{
		maker: principal,
		taker: (optional principal),
		token-id: uint,
		nft-asset-contract: principal,
		expiry: uint,
		price: uint,
		commission: uint,
		payment-asset-contract: (optional principal)
	}
)

(define-map whitelisted-asset-contracts principal bool)
(define-map whitelisted-royalty-contracts principal { royalty-address: principal, royalty-percent: uint})

(define-data-var listing-nonce uint u0)
(define-data-var minimum-commission uint u100) ;; 1%
(define-data-var maximum-commission uint u5000) ;; 50%
(define-data-var minimum-listing-price uint u1000000) ;; 1 STX

(define-data-var listings-frozen bool false) 
(define-data-var unlistings-frozen bool false)
(define-data-var buy-frozen bool false) 
(define-data-var commission-owner principal 'SPEAKQCRSV4NDSNCEB3YXMMRHEMCSKR676GEFZE7)


(define-read-only (is-whitelisted (asset-contract principal))
	(default-to false (map-get? whitelisted-asset-contracts asset-contract))
)

(define-public (set-whitelisted (asset-contract principal) (whitelisted bool))
	(begin
		(asserts! (is-eq contract-owner tx-sender) err-unauthorised)
		(ok (map-set whitelisted-asset-contracts asset-contract whitelisted))
	)
)

(define-private (transfer-nft (token-contract <nft-trait>) (token-id uint) (sender principal) (recipient principal))
	(contract-call? token-contract transfer token-id sender recipient)
)

(define-private (transfer-ft (token-contract <ft-trait>) (amount uint) (sender principal) (recipient principal))
	(contract-call? token-contract transfer amount sender recipient none)
)

(define-public (list-asset (nft-asset-contract <nft-trait>) (nft-asset {taker: (optional principal), token-id: uint, expiry: uint, price: uint, commission: uint, payment-asset-contract: (optional principal)}))
	(let (
		(listing-id (var-get listing-nonce))
		(commission (get commission nft-asset))
		(royalty (get-royalty (contract-of nft-asset-contract)))
		)

		(asserts! (is-eq false (var-get listings-frozen)) err-listings-frozen)
		(asserts! (is-whitelisted (contract-of nft-asset-contract)) err-asset-contract-not-whitelisted)
		(asserts! (> (get expiry nft-asset) block-height) err-expiry-in-past)
		(asserts! (> (get price nft-asset) u0) err-price-zero)
		(asserts! (>= commission (var-get minimum-commission))  err-minimum-commission)
		(asserts! (< commission (var-get maximum-commission)) err-maximum-commission)
		(asserts! (match (get payment-asset-contract nft-asset) payment-asset (is-whitelisted payment-asset) true) err-payment-contract-not-whitelisted)
		(try! (transfer-nft nft-asset-contract (get token-id nft-asset) tx-sender (as-contract tx-sender)))
		(map-set listings listing-id (merge {maker: tx-sender, nft-asset-contract: (contract-of nft-asset-contract)} nft-asset))
		(var-set listing-nonce (+ listing-id u1))
		(ok listing-id)
	)
)

(define-read-only (get-listing (listing-id uint))
	(map-get? listings listing-id)
)

(define-public (cancel-listing (listing-id uint) (nft-asset-contract <nft-trait>))
	(let (
		(listing (unwrap! (map-get? listings listing-id) err-unknown-listing))
		(maker (get maker listing))
		)
		(asserts! (is-eq false (var-get unlistings-frozen))  err-unlistings-frozen)
		(asserts! (is-eq maker tx-sender) err-unauthorised)
		(asserts! (is-eq (get nft-asset-contract listing) (contract-of nft-asset-contract)) err-nft-asset-mismatch)
		(map-delete listings listing-id)
		(as-contract (transfer-nft nft-asset-contract (get token-id listing) tx-sender maker))
	)
)

(define-public (admin-cancel-listing (listing-id uint) (nft-asset-contract <nft-trait>))
  (let (
		(listing (unwrap! (map-get? listings listing-id) err-unknown-listing))
		(maker (get maker listing))
		)
		(asserts! (is-eq contract-owner tx-sender) err-unauthorised)
		(asserts! (is-eq (get nft-asset-contract listing) (contract-of nft-asset-contract)) err-nft-asset-mismatch)
		(map-delete listings listing-id)
		(as-contract (transfer-nft nft-asset-contract (get token-id listing) tx-sender maker))
	)
)

(define-private (assert-can-fulfil (nft-asset-contract principal) (payment-asset-contract (optional principal)) (listing {maker: principal, taker: (optional principal), token-id: uint, nft-asset-contract: principal, expiry: uint, price: uint, commission: uint,  payment-asset-contract: (optional principal)}))
	(begin
		(asserts! (not (is-eq (get maker listing) tx-sender)) err-maker-taker-equal)
		(asserts! (match (get taker listing) intended-taker (is-eq intended-taker tx-sender) true) err-unintended-taker)
		(asserts! (< block-height (get expiry listing)) err-listing-expired)
		(asserts! (is-eq (get nft-asset-contract listing) nft-asset-contract) err-nft-asset-mismatch)
		(asserts! (is-eq (get payment-asset-contract listing) payment-asset-contract) err-payment-asset-mismatch)
		(ok true)
	)
)

(define-public (fulfil-listing-stx (listing-id uint) (nft-asset-contract <nft-trait>))
	(let (
		(listing (unwrap! (map-get? listings listing-id) err-unknown-listing))
		(taker tx-sender)
		(maker (get maker listing)) 
		(price (get price listing)) 
		(commission-amount (/ (* price (get commission listing)) u10000)) 
		(royalty (get-royalty (contract-of nft-asset-contract)))
		(royalty-amount (/ (* price (get royalty-percent royalty)) u10000))
		(royalty-address (get royalty-address royalty))
		(to-owner-amount (- (- price commission-amount) royalty-amount))
		)

		(asserts! (is-eq false (var-get buy-frozen))  err-buy-frozen)
		(try! (assert-can-fulfil (contract-of nft-asset-contract) none listing))
		(try! (as-contract (transfer-nft nft-asset-contract (get token-id listing) tx-sender taker)))
		(try! (stx-transfer? to-owner-amount taker (get maker listing)))
		(try! (stx-transfer? commission-amount taker (var-get commission-owner)))
		(if (> royalty-amount u0) 
			(try! (stx-transfer? royalty-amount taker royalty-address))
			false)
		
		(map-delete listings listing-id)
		(ok { maker: maker, listing-id: listing-id, amount: price })
	)
)

(define-public (fulfil-listing-ft (listing-id uint) (nft-asset-contract <nft-trait>) (payment-asset-contract <ft-trait>))
	(let (
		(listing (unwrap! (map-get? listings listing-id) err-unknown-listing))
		(taker tx-sender)
		(maker (get maker listing)) 
		(price (get price listing)) 
		(commission-amount (/ (* price (get commission listing)) u10000)) 
		(royalty (get-royalty (contract-of nft-asset-contract)))
		(royalty-amount (/ (* price (get royalty-percent royalty)) u10000))
		(royalty-address (get royalty-address royalty))
		(to-owner-amount (- (- price commission-amount) royalty-amount))
		)

		(asserts! (is-eq false (var-get buy-frozen)) err-buy-frozen)
		(try! (assert-can-fulfil (contract-of nft-asset-contract) (some (contract-of payment-asset-contract)) listing))
		(try! (as-contract (transfer-nft nft-asset-contract (get token-id listing) tx-sender taker)))
		(try! (transfer-ft payment-asset-contract to-owner-amount taker (get maker listing)))
		(try! (transfer-ft payment-asset-contract commission-amount taker (var-get commission-owner)))
		(if (> royalty-amount u0) 
			(try! (transfer-ft payment-asset-contract royalty-amount taker royalty-address))
			false)
		(map-delete listings listing-id)
		(ok { maker: maker, listing-id: listing-id, amount: price })
	)
)


;; when payment-asset-contract is dummy-token, pay with STX. otherwise, pay with Fungible token.
(define-public
	(buy-from-cart-2
		(listing-id uint) (nft-asset-contract <nft-trait>) (payment-asset-contract <ft-trait>)
		(listing-id-2 uint) (nft-asset-contract-2 <nft-trait>) (payment-asset-contract-2 <ft-trait>)
		
	)
	(let (
		(result1 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract)) (fulfil-listing-stx listing-id nft-asset-contract) (fulfil-listing-ft listing-id nft-asset-contract payment-asset-contract))))
		(result2 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-2)) (fulfil-listing-stx listing-id-2 nft-asset-contract-2) (fulfil-listing-ft listing-id-2 nft-asset-contract-2 payment-asset-contract-2))))
		)

		(ok (list result1 result2))
	)
	
)


(define-public
	(buy-from-cart-3
		(listing-id uint) (nft-asset-contract <nft-trait>) (payment-asset-contract <ft-trait>)
		(listing-id-2 uint) (nft-asset-contract-2 <nft-trait>) (payment-asset-contract-2 <ft-trait>)
		(listing-id-3 uint) (nft-asset-contract-3 <nft-trait>) (payment-asset-contract-3 <ft-trait>)
		
	)
	(let (
		(result1 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract)) (fulfil-listing-stx listing-id nft-asset-contract) (fulfil-listing-ft listing-id nft-asset-contract payment-asset-contract))))
		(result2 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-2)) (fulfil-listing-stx listing-id-2 nft-asset-contract-2) (fulfil-listing-ft listing-id-2 nft-asset-contract-2 payment-asset-contract-2))))
		(result3 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-3)) (fulfil-listing-stx listing-id-3 nft-asset-contract-3) (fulfil-listing-ft listing-id-3 nft-asset-contract-3 payment-asset-contract-3))))
		)

		(ok (list result1 result2 result3))
	)
)

(define-public
	(buy-from-cart-4
		(listing-id uint) (nft-asset-contract <nft-trait>) (payment-asset-contract <ft-trait>)
		(listing-id-2 uint) (nft-asset-contract-2 <nft-trait>) (payment-asset-contract-2 <ft-trait>)
		(listing-id-3 uint) (nft-asset-contract-3 <nft-trait>) (payment-asset-contract-3 <ft-trait>)
		(listing-id-4 uint) (nft-asset-contract-4 <nft-trait>) (payment-asset-contract-4 <ft-trait>)
		
	)
	(let (
		(result1 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract)) (fulfil-listing-stx listing-id nft-asset-contract) (fulfil-listing-ft listing-id nft-asset-contract payment-asset-contract))))
		(result2 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-2)) (fulfil-listing-stx listing-id-2 nft-asset-contract-2) (fulfil-listing-ft listing-id-2 nft-asset-contract-2 payment-asset-contract-2))))
		(result3 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-3)) (fulfil-listing-stx listing-id-3 nft-asset-contract-3) (fulfil-listing-ft listing-id-3 nft-asset-contract-3 payment-asset-contract-3))))
		(result4 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-4)) (fulfil-listing-stx listing-id-4 nft-asset-contract-4) (fulfil-listing-ft listing-id-4 nft-asset-contract-4 payment-asset-contract-4))))
		)

		(ok (list result1 result2 result3 result4))
	)
)

(define-public
	(buy-from-cart-5
		(listing-id uint) (nft-asset-contract <nft-trait>) (payment-asset-contract <ft-trait>)
		(listing-id-2 uint) (nft-asset-contract-2 <nft-trait>) (payment-asset-contract-2 <ft-trait>)
		(listing-id-3 uint) (nft-asset-contract-3 <nft-trait>) (payment-asset-contract-3 <ft-trait>)
		(listing-id-4 uint) (nft-asset-contract-4 <nft-trait>) (payment-asset-contract-4 <ft-trait>)
		(listing-id-5 uint) (nft-asset-contract-5 <nft-trait>) (payment-asset-contract-5 <ft-trait>)
		
	)
	(let (
		(result1 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract)) (fulfil-listing-stx listing-id nft-asset-contract) (fulfil-listing-ft listing-id nft-asset-contract payment-asset-contract))))
		(result2 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-2)) (fulfil-listing-stx listing-id-2 nft-asset-contract-2) (fulfil-listing-ft listing-id-2 nft-asset-contract-2 payment-asset-contract-2))))
		(result3 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-3)) (fulfil-listing-stx listing-id-3 nft-asset-contract-3) (fulfil-listing-ft listing-id-3 nft-asset-contract-3 payment-asset-contract-3))))
		(result4 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-4)) (fulfil-listing-stx listing-id-4 nft-asset-contract-4) (fulfil-listing-ft listing-id-4 nft-asset-contract-4 payment-asset-contract-4))))
		(result5 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-5)) (fulfil-listing-stx listing-id-5 nft-asset-contract-5) (fulfil-listing-ft listing-id-5 nft-asset-contract-5 payment-asset-contract-5))))
		)

		(ok (list result1 result2 result3 result4 result5))
	)
)

(define-public
	(buy-from-cart-6
		(listing-id uint) (nft-asset-contract <nft-trait>) (payment-asset-contract <ft-trait>)
		(listing-id-2 uint) (nft-asset-contract-2 <nft-trait>) (payment-asset-contract-2 <ft-trait>)
		(listing-id-3 uint) (nft-asset-contract-3 <nft-trait>) (payment-asset-contract-3 <ft-trait>)
		(listing-id-4 uint) (nft-asset-contract-4 <nft-trait>) (payment-asset-contract-4 <ft-trait>)
		(listing-id-5 uint) (nft-asset-contract-5 <nft-trait>) (payment-asset-contract-5 <ft-trait>)
		(listing-id-6 uint) (nft-asset-contract-6 <nft-trait>) (payment-asset-contract-6 <ft-trait>)
		
	)
	(let (
		(result1 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract)) (fulfil-listing-stx listing-id nft-asset-contract) (fulfil-listing-ft listing-id nft-asset-contract payment-asset-contract))))
		(result2 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-2)) (fulfil-listing-stx listing-id-2 nft-asset-contract-2) (fulfil-listing-ft listing-id-2 nft-asset-contract-2 payment-asset-contract-2))))
		(result3 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-3)) (fulfil-listing-stx listing-id-3 nft-asset-contract-3) (fulfil-listing-ft listing-id-3 nft-asset-contract-3 payment-asset-contract-3))))
		(result4 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-4)) (fulfil-listing-stx listing-id-4 nft-asset-contract-4) (fulfil-listing-ft listing-id-4 nft-asset-contract-4 payment-asset-contract-4))))
		(result5 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-5)) (fulfil-listing-stx listing-id-5 nft-asset-contract-5) (fulfil-listing-ft listing-id-5 nft-asset-contract-5 payment-asset-contract-5))))
		(result6 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-6)) (fulfil-listing-stx listing-id-6 nft-asset-contract-6) (fulfil-listing-ft listing-id-6 nft-asset-contract-6 payment-asset-contract-6))))
		)

		(ok (list result1 result2 result3 result4 result5 result6))
	)
)

(define-public
	(buy-from-cart-7
		(listing-id uint) (nft-asset-contract <nft-trait>) (payment-asset-contract <ft-trait>)
		(listing-id-2 uint) (nft-asset-contract-2 <nft-trait>) (payment-asset-contract-2 <ft-trait>)
		(listing-id-3 uint) (nft-asset-contract-3 <nft-trait>) (payment-asset-contract-3 <ft-trait>)
		(listing-id-4 uint) (nft-asset-contract-4 <nft-trait>) (payment-asset-contract-4 <ft-trait>)
		(listing-id-5 uint) (nft-asset-contract-5 <nft-trait>) (payment-asset-contract-5 <ft-trait>)
		(listing-id-6 uint) (nft-asset-contract-6 <nft-trait>) (payment-asset-contract-6 <ft-trait>)
		(listing-id-7 uint) (nft-asset-contract-7 <nft-trait>) (payment-asset-contract-7 <ft-trait>)
		
	)
	(let (
		(result1 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract)) (fulfil-listing-stx listing-id nft-asset-contract) (fulfil-listing-ft listing-id nft-asset-contract payment-asset-contract))))
		(result2 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-2)) (fulfil-listing-stx listing-id-2 nft-asset-contract-2) (fulfil-listing-ft listing-id-2 nft-asset-contract-2 payment-asset-contract-2))))
		(result3 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-3)) (fulfil-listing-stx listing-id-3 nft-asset-contract-3) (fulfil-listing-ft listing-id-3 nft-asset-contract-3 payment-asset-contract-3))))
		(result4 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-4)) (fulfil-listing-stx listing-id-4 nft-asset-contract-4) (fulfil-listing-ft listing-id-4 nft-asset-contract-4 payment-asset-contract-4))))
		(result5 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-5)) (fulfil-listing-stx listing-id-5 nft-asset-contract-5) (fulfil-listing-ft listing-id-5 nft-asset-contract-5 payment-asset-contract-5))))
		(result6 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-6)) (fulfil-listing-stx listing-id-6 nft-asset-contract-6) (fulfil-listing-ft listing-id-6 nft-asset-contract-6 payment-asset-contract-6))))
		(result7 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-7)) (fulfil-listing-stx listing-id-7 nft-asset-contract-7) (fulfil-listing-ft listing-id-7 nft-asset-contract-7 payment-asset-contract-7))))
		)

		(ok (list result1 result2 result3 result4 result5 result6 result7))
	)
)

(define-public
	(buy-from-cart-8
		(listing-id uint) (nft-asset-contract <nft-trait>) (payment-asset-contract <ft-trait>)
		(listing-id-2 uint) (nft-asset-contract-2 <nft-trait>) (payment-asset-contract-2 <ft-trait>)
		(listing-id-3 uint) (nft-asset-contract-3 <nft-trait>) (payment-asset-contract-3 <ft-trait>)
		(listing-id-4 uint) (nft-asset-contract-4 <nft-trait>) (payment-asset-contract-4 <ft-trait>)
		(listing-id-5 uint) (nft-asset-contract-5 <nft-trait>) (payment-asset-contract-5 <ft-trait>)
		(listing-id-6 uint) (nft-asset-contract-6 <nft-trait>) (payment-asset-contract-6 <ft-trait>)
		(listing-id-7 uint) (nft-asset-contract-7 <nft-trait>) (payment-asset-contract-7 <ft-trait>)
		(listing-id-8 uint) (nft-asset-contract-8 <nft-trait>) (payment-asset-contract-8 <ft-trait>)
		
	)
	(let (
		(result1 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract)) (fulfil-listing-stx listing-id nft-asset-contract) (fulfil-listing-ft listing-id nft-asset-contract payment-asset-contract))))
		(result2 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-2)) (fulfil-listing-stx listing-id-2 nft-asset-contract-2) (fulfil-listing-ft listing-id-2 nft-asset-contract-2 payment-asset-contract-2))))
		(result3 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-3)) (fulfil-listing-stx listing-id-3 nft-asset-contract-3) (fulfil-listing-ft listing-id-3 nft-asset-contract-3 payment-asset-contract-3))))
		(result4 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-4)) (fulfil-listing-stx listing-id-4 nft-asset-contract-4) (fulfil-listing-ft listing-id-4 nft-asset-contract-4 payment-asset-contract-4))))
		(result5 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-5)) (fulfil-listing-stx listing-id-5 nft-asset-contract-5) (fulfil-listing-ft listing-id-5 nft-asset-contract-5 payment-asset-contract-5))))
		(result6 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-6)) (fulfil-listing-stx listing-id-6 nft-asset-contract-6) (fulfil-listing-ft listing-id-6 nft-asset-contract-6 payment-asset-contract-6))))
		(result7 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-7)) (fulfil-listing-stx listing-id-7 nft-asset-contract-7) (fulfil-listing-ft listing-id-7 nft-asset-contract-7 payment-asset-contract-7))))
		(result8 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-8)) (fulfil-listing-stx listing-id-8 nft-asset-contract-8) (fulfil-listing-ft listing-id-8 nft-asset-contract-8 payment-asset-contract-8))))
		)

		(ok (list result1 result2 result3 result4 result5 result6 result7 result8))
	)
)

(define-public
	(buy-from-cart-9
		(listing-id uint) (nft-asset-contract <nft-trait>) (payment-asset-contract <ft-trait>)
		(listing-id-2 uint) (nft-asset-contract-2 <nft-trait>) (payment-asset-contract-2 <ft-trait>)
		(listing-id-3 uint) (nft-asset-contract-3 <nft-trait>) (payment-asset-contract-3 <ft-trait>)
		(listing-id-4 uint) (nft-asset-contract-4 <nft-trait>) (payment-asset-contract-4 <ft-trait>)
		(listing-id-5 uint) (nft-asset-contract-5 <nft-trait>) (payment-asset-contract-5 <ft-trait>)
		(listing-id-6 uint) (nft-asset-contract-6 <nft-trait>) (payment-asset-contract-6 <ft-trait>)
		(listing-id-7 uint) (nft-asset-contract-7 <nft-trait>) (payment-asset-contract-7 <ft-trait>)
		(listing-id-8 uint) (nft-asset-contract-8 <nft-trait>) (payment-asset-contract-8 <ft-trait>)
		(listing-id-9 uint) (nft-asset-contract-9 <nft-trait>) (payment-asset-contract-9 <ft-trait>)
		
	)
	(let (
		(result1 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract)) (fulfil-listing-stx listing-id nft-asset-contract) (fulfil-listing-ft listing-id nft-asset-contract payment-asset-contract))))
		(result2 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-2)) (fulfil-listing-stx listing-id-2 nft-asset-contract-2) (fulfil-listing-ft listing-id-2 nft-asset-contract-2 payment-asset-contract-2))))
		(result3 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-3)) (fulfil-listing-stx listing-id-3 nft-asset-contract-3) (fulfil-listing-ft listing-id-3 nft-asset-contract-3 payment-asset-contract-3))))
		(result4 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-4)) (fulfil-listing-stx listing-id-4 nft-asset-contract-4) (fulfil-listing-ft listing-id-4 nft-asset-contract-4 payment-asset-contract-4))))
		(result5 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-5)) (fulfil-listing-stx listing-id-5 nft-asset-contract-5) (fulfil-listing-ft listing-id-5 nft-asset-contract-5 payment-asset-contract-5))))
		(result6 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-6)) (fulfil-listing-stx listing-id-6 nft-asset-contract-6) (fulfil-listing-ft listing-id-6 nft-asset-contract-6 payment-asset-contract-6))))
		(result7 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-7)) (fulfil-listing-stx listing-id-7 nft-asset-contract-7) (fulfil-listing-ft listing-id-7 nft-asset-contract-7 payment-asset-contract-7))))
		(result8 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-8)) (fulfil-listing-stx listing-id-8 nft-asset-contract-8) (fulfil-listing-ft listing-id-8 nft-asset-contract-8 payment-asset-contract-8))))
		(result9 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-9)) (fulfil-listing-stx listing-id-9 nft-asset-contract-9) (fulfil-listing-ft listing-id-9 nft-asset-contract-9 payment-asset-contract-9))))
		)

		(ok (list result1 result2 result3 result4 result5 result6 result7 result8 result9))
	)
)

(define-public
	(buy-from-cart-10
		(listing-id uint) (nft-asset-contract <nft-trait>) (payment-asset-contract <ft-trait>)
		(listing-id-2 uint) (nft-asset-contract-2 <nft-trait>) (payment-asset-contract-2 <ft-trait>)
		(listing-id-3 uint) (nft-asset-contract-3 <nft-trait>) (payment-asset-contract-3 <ft-trait>)
		(listing-id-4 uint) (nft-asset-contract-4 <nft-trait>) (payment-asset-contract-4 <ft-trait>)
		(listing-id-5 uint) (nft-asset-contract-5 <nft-trait>) (payment-asset-contract-5 <ft-trait>)
		(listing-id-6 uint) (nft-asset-contract-6 <nft-trait>) (payment-asset-contract-6 <ft-trait>)
		(listing-id-7 uint) (nft-asset-contract-7 <nft-trait>) (payment-asset-contract-7 <ft-trait>)
		(listing-id-8 uint) (nft-asset-contract-8 <nft-trait>) (payment-asset-contract-8 <ft-trait>)
		(listing-id-9 uint) (nft-asset-contract-9 <nft-trait>) (payment-asset-contract-9 <ft-trait>)
		(listing-id-10 uint) (nft-asset-contract-10 <nft-trait>) (payment-asset-contract-10 <ft-trait>)
		
	)
	(let (
		(result1 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract)) (fulfil-listing-stx listing-id nft-asset-contract) (fulfil-listing-ft listing-id nft-asset-contract payment-asset-contract))))
		(result2 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-2)) (fulfil-listing-stx listing-id-2 nft-asset-contract-2) (fulfil-listing-ft listing-id-2 nft-asset-contract-2 payment-asset-contract-2))))
		(result3 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-3)) (fulfil-listing-stx listing-id-3 nft-asset-contract-3) (fulfil-listing-ft listing-id-3 nft-asset-contract-3 payment-asset-contract-3))))
		(result4 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-4)) (fulfil-listing-stx listing-id-4 nft-asset-contract-4) (fulfil-listing-ft listing-id-4 nft-asset-contract-4 payment-asset-contract-4))))
		(result5 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-5)) (fulfil-listing-stx listing-id-5 nft-asset-contract-5) (fulfil-listing-ft listing-id-5 nft-asset-contract-5 payment-asset-contract-5))))
		(result6 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-6)) (fulfil-listing-stx listing-id-6 nft-asset-contract-6) (fulfil-listing-ft listing-id-6 nft-asset-contract-6 payment-asset-contract-6))))
		(result7 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-7)) (fulfil-listing-stx listing-id-7 nft-asset-contract-7) (fulfil-listing-ft listing-id-7 nft-asset-contract-7 payment-asset-contract-7))))
		(result8 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-8)) (fulfil-listing-stx listing-id-8 nft-asset-contract-8) (fulfil-listing-ft listing-id-8 nft-asset-contract-8 payment-asset-contract-8))))
		(result9 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-9)) (fulfil-listing-stx listing-id-9 nft-asset-contract-9) (fulfil-listing-ft listing-id-9 nft-asset-contract-9 payment-asset-contract-9))))
		(result10 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-10)) (fulfil-listing-stx listing-id-10 nft-asset-contract-10) (fulfil-listing-ft listing-id-10 nft-asset-contract-10 payment-asset-contract-10))))
		)

		(ok (list result1 result2 result3 result4 result5 result6 result7 result8 result9 result10))
	)
)

(define-public
	(buy-from-cart-11
		(listing-id uint) (nft-asset-contract <nft-trait>) (payment-asset-contract <ft-trait>)
		(listing-id-2 uint) (nft-asset-contract-2 <nft-trait>) (payment-asset-contract-2 <ft-trait>)
		(listing-id-3 uint) (nft-asset-contract-3 <nft-trait>) (payment-asset-contract-3 <ft-trait>)
		(listing-id-4 uint) (nft-asset-contract-4 <nft-trait>) (payment-asset-contract-4 <ft-trait>)
		(listing-id-5 uint) (nft-asset-contract-5 <nft-trait>) (payment-asset-contract-5 <ft-trait>)
		(listing-id-6 uint) (nft-asset-contract-6 <nft-trait>) (payment-asset-contract-6 <ft-trait>)
		(listing-id-7 uint) (nft-asset-contract-7 <nft-trait>) (payment-asset-contract-7 <ft-trait>)
		(listing-id-8 uint) (nft-asset-contract-8 <nft-trait>) (payment-asset-contract-8 <ft-trait>)
		(listing-id-9 uint) (nft-asset-contract-9 <nft-trait>) (payment-asset-contract-9 <ft-trait>)
		(listing-id-10 uint) (nft-asset-contract-10 <nft-trait>) (payment-asset-contract-10 <ft-trait>)
		(listing-id-11 uint) (nft-asset-contract-11 <nft-trait>) (payment-asset-contract-11 <ft-trait>)
		
	)
	(let (
		(result1 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract)) (fulfil-listing-stx listing-id nft-asset-contract) (fulfil-listing-ft listing-id nft-asset-contract payment-asset-contract))))
		(result2 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-2)) (fulfil-listing-stx listing-id-2 nft-asset-contract-2) (fulfil-listing-ft listing-id-2 nft-asset-contract-2 payment-asset-contract-2))))
		(result3 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-3)) (fulfil-listing-stx listing-id-3 nft-asset-contract-3) (fulfil-listing-ft listing-id-3 nft-asset-contract-3 payment-asset-contract-3))))
		(result4 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-4)) (fulfil-listing-stx listing-id-4 nft-asset-contract-4) (fulfil-listing-ft listing-id-4 nft-asset-contract-4 payment-asset-contract-4))))
		(result5 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-5)) (fulfil-listing-stx listing-id-5 nft-asset-contract-5) (fulfil-listing-ft listing-id-5 nft-asset-contract-5 payment-asset-contract-5))))
		(result6 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-6)) (fulfil-listing-stx listing-id-6 nft-asset-contract-6) (fulfil-listing-ft listing-id-6 nft-asset-contract-6 payment-asset-contract-6))))
		(result7 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-7)) (fulfil-listing-stx listing-id-7 nft-asset-contract-7) (fulfil-listing-ft listing-id-7 nft-asset-contract-7 payment-asset-contract-7))))
		(result8 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-8)) (fulfil-listing-stx listing-id-8 nft-asset-contract-8) (fulfil-listing-ft listing-id-8 nft-asset-contract-8 payment-asset-contract-8))))
		(result9 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-9)) (fulfil-listing-stx listing-id-9 nft-asset-contract-9) (fulfil-listing-ft listing-id-9 nft-asset-contract-9 payment-asset-contract-9))))
		(result10 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-10)) (fulfil-listing-stx listing-id-10 nft-asset-contract-10) (fulfil-listing-ft listing-id-10 nft-asset-contract-10 payment-asset-contract-10))))
		(result11 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-11)) (fulfil-listing-stx listing-id-11 nft-asset-contract-11) (fulfil-listing-ft listing-id-11 nft-asset-contract-11 payment-asset-contract-11))))
		)

		(ok (list result1 result2 result3 result4 result5 result6 result7 result8 result9 result10 result11))
	)
)

(define-public
	(buy-from-cart-12
		(listing-id uint) (nft-asset-contract <nft-trait>) (payment-asset-contract <ft-trait>)
		(listing-id-2 uint) (nft-asset-contract-2 <nft-trait>) (payment-asset-contract-2 <ft-trait>)
		(listing-id-3 uint) (nft-asset-contract-3 <nft-trait>) (payment-asset-contract-3 <ft-trait>)
		(listing-id-4 uint) (nft-asset-contract-4 <nft-trait>) (payment-asset-contract-4 <ft-trait>)
		(listing-id-5 uint) (nft-asset-contract-5 <nft-trait>) (payment-asset-contract-5 <ft-trait>)
		(listing-id-6 uint) (nft-asset-contract-6 <nft-trait>) (payment-asset-contract-6 <ft-trait>)
		(listing-id-7 uint) (nft-asset-contract-7 <nft-trait>) (payment-asset-contract-7 <ft-trait>)
		(listing-id-8 uint) (nft-asset-contract-8 <nft-trait>) (payment-asset-contract-8 <ft-trait>)
		(listing-id-9 uint) (nft-asset-contract-9 <nft-trait>) (payment-asset-contract-9 <ft-trait>)
		(listing-id-10 uint) (nft-asset-contract-10 <nft-trait>) (payment-asset-contract-10 <ft-trait>)
		(listing-id-11 uint) (nft-asset-contract-11 <nft-trait>) (payment-asset-contract-11 <ft-trait>)
		(listing-id-12 uint) (nft-asset-contract-12 <nft-trait>) (payment-asset-contract-12 <ft-trait>)
		
	)
	(let (
		(result1 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract)) (fulfil-listing-stx listing-id nft-asset-contract) (fulfil-listing-ft listing-id nft-asset-contract payment-asset-contract))))
		(result2 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-2)) (fulfil-listing-stx listing-id-2 nft-asset-contract-2) (fulfil-listing-ft listing-id-2 nft-asset-contract-2 payment-asset-contract-2))))
		(result3 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-3)) (fulfil-listing-stx listing-id-3 nft-asset-contract-3) (fulfil-listing-ft listing-id-3 nft-asset-contract-3 payment-asset-contract-3))))
		(result4 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-4)) (fulfil-listing-stx listing-id-4 nft-asset-contract-4) (fulfil-listing-ft listing-id-4 nft-asset-contract-4 payment-asset-contract-4))))
		(result5 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-5)) (fulfil-listing-stx listing-id-5 nft-asset-contract-5) (fulfil-listing-ft listing-id-5 nft-asset-contract-5 payment-asset-contract-5))))
		(result6 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-6)) (fulfil-listing-stx listing-id-6 nft-asset-contract-6) (fulfil-listing-ft listing-id-6 nft-asset-contract-6 payment-asset-contract-6))))
		(result7 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-7)) (fulfil-listing-stx listing-id-7 nft-asset-contract-7) (fulfil-listing-ft listing-id-7 nft-asset-contract-7 payment-asset-contract-7))))
		(result8 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-8)) (fulfil-listing-stx listing-id-8 nft-asset-contract-8) (fulfil-listing-ft listing-id-8 nft-asset-contract-8 payment-asset-contract-8))))
		(result9 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-9)) (fulfil-listing-stx listing-id-9 nft-asset-contract-9) (fulfil-listing-ft listing-id-9 nft-asset-contract-9 payment-asset-contract-9))))
		(result10 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-10)) (fulfil-listing-stx listing-id-10 nft-asset-contract-10) (fulfil-listing-ft listing-id-10 nft-asset-contract-10 payment-asset-contract-10))))
		(result11 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-11)) (fulfil-listing-stx listing-id-11 nft-asset-contract-11) (fulfil-listing-ft listing-id-11 nft-asset-contract-11 payment-asset-contract-11))))
		(result12 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-12)) (fulfil-listing-stx listing-id-12 nft-asset-contract-12) (fulfil-listing-ft listing-id-12 nft-asset-contract-12 payment-asset-contract-12))))
		)

		(ok (list result1 result2 result3 result4 result5 result6 result7 result8 result9 result10 result11 result12))
	)
)

(define-public
	(buy-from-cart-13
		(listing-id uint) (nft-asset-contract <nft-trait>) (payment-asset-contract <ft-trait>)
		(listing-id-2 uint) (nft-asset-contract-2 <nft-trait>) (payment-asset-contract-2 <ft-trait>)
		(listing-id-3 uint) (nft-asset-contract-3 <nft-trait>) (payment-asset-contract-3 <ft-trait>)
		(listing-id-4 uint) (nft-asset-contract-4 <nft-trait>) (payment-asset-contract-4 <ft-trait>)
		(listing-id-5 uint) (nft-asset-contract-5 <nft-trait>) (payment-asset-contract-5 <ft-trait>)
		(listing-id-6 uint) (nft-asset-contract-6 <nft-trait>) (payment-asset-contract-6 <ft-trait>)
		(listing-id-7 uint) (nft-asset-contract-7 <nft-trait>) (payment-asset-contract-7 <ft-trait>)
		(listing-id-8 uint) (nft-asset-contract-8 <nft-trait>) (payment-asset-contract-8 <ft-trait>)
		(listing-id-9 uint) (nft-asset-contract-9 <nft-trait>) (payment-asset-contract-9 <ft-trait>)
		(listing-id-10 uint) (nft-asset-contract-10 <nft-trait>) (payment-asset-contract-10 <ft-trait>)
		(listing-id-11 uint) (nft-asset-contract-11 <nft-trait>) (payment-asset-contract-11 <ft-trait>)
		(listing-id-12 uint) (nft-asset-contract-12 <nft-trait>) (payment-asset-contract-12 <ft-trait>)
		(listing-id-13 uint) (nft-asset-contract-13 <nft-trait>) (payment-asset-contract-13 <ft-trait>)
		
	)
	(let (
		(result1 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract)) (fulfil-listing-stx listing-id nft-asset-contract) (fulfil-listing-ft listing-id nft-asset-contract payment-asset-contract))))
		(result2 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-2)) (fulfil-listing-stx listing-id-2 nft-asset-contract-2) (fulfil-listing-ft listing-id-2 nft-asset-contract-2 payment-asset-contract-2))))
		(result3 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-3)) (fulfil-listing-stx listing-id-3 nft-asset-contract-3) (fulfil-listing-ft listing-id-3 nft-asset-contract-3 payment-asset-contract-3))))
		(result4 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-4)) (fulfil-listing-stx listing-id-4 nft-asset-contract-4) (fulfil-listing-ft listing-id-4 nft-asset-contract-4 payment-asset-contract-4))))
		(result5 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-5)) (fulfil-listing-stx listing-id-5 nft-asset-contract-5) (fulfil-listing-ft listing-id-5 nft-asset-contract-5 payment-asset-contract-5))))
		(result6 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-6)) (fulfil-listing-stx listing-id-6 nft-asset-contract-6) (fulfil-listing-ft listing-id-6 nft-asset-contract-6 payment-asset-contract-6))))
		(result7 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-7)) (fulfil-listing-stx listing-id-7 nft-asset-contract-7) (fulfil-listing-ft listing-id-7 nft-asset-contract-7 payment-asset-contract-7))))
		(result8 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-8)) (fulfil-listing-stx listing-id-8 nft-asset-contract-8) (fulfil-listing-ft listing-id-8 nft-asset-contract-8 payment-asset-contract-8))))
		(result9 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-9)) (fulfil-listing-stx listing-id-9 nft-asset-contract-9) (fulfil-listing-ft listing-id-9 nft-asset-contract-9 payment-asset-contract-9))))
		(result10 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-10)) (fulfil-listing-stx listing-id-10 nft-asset-contract-10) (fulfil-listing-ft listing-id-10 nft-asset-contract-10 payment-asset-contract-10))))
		(result11 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-11)) (fulfil-listing-stx listing-id-11 nft-asset-contract-11) (fulfil-listing-ft listing-id-11 nft-asset-contract-11 payment-asset-contract-11))))
		(result12 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-12)) (fulfil-listing-stx listing-id-12 nft-asset-contract-12) (fulfil-listing-ft listing-id-12 nft-asset-contract-12 payment-asset-contract-12))))
		(result13 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-13)) (fulfil-listing-stx listing-id-13 nft-asset-contract-13) (fulfil-listing-ft listing-id-13 nft-asset-contract-13 payment-asset-contract-13))))
		)

		(ok (list result1 result2 result3 result4 result5 result6 result7 result8 result9 result10 result11 result12 result13))
	)
)

(define-public
	(buy-from-cart-14
		(listing-id uint) (nft-asset-contract <nft-trait>) (payment-asset-contract <ft-trait>)
		(listing-id-2 uint) (nft-asset-contract-2 <nft-trait>) (payment-asset-contract-2 <ft-trait>)
		(listing-id-3 uint) (nft-asset-contract-3 <nft-trait>) (payment-asset-contract-3 <ft-trait>)
		(listing-id-4 uint) (nft-asset-contract-4 <nft-trait>) (payment-asset-contract-4 <ft-trait>)
		(listing-id-5 uint) (nft-asset-contract-5 <nft-trait>) (payment-asset-contract-5 <ft-trait>)
		(listing-id-6 uint) (nft-asset-contract-6 <nft-trait>) (payment-asset-contract-6 <ft-trait>)
		(listing-id-7 uint) (nft-asset-contract-7 <nft-trait>) (payment-asset-contract-7 <ft-trait>)
		(listing-id-8 uint) (nft-asset-contract-8 <nft-trait>) (payment-asset-contract-8 <ft-trait>)
		(listing-id-9 uint) (nft-asset-contract-9 <nft-trait>) (payment-asset-contract-9 <ft-trait>)
		(listing-id-10 uint) (nft-asset-contract-10 <nft-trait>) (payment-asset-contract-10 <ft-trait>)
		(listing-id-11 uint) (nft-asset-contract-11 <nft-trait>) (payment-asset-contract-11 <ft-trait>)
		(listing-id-12 uint) (nft-asset-contract-12 <nft-trait>) (payment-asset-contract-12 <ft-trait>)
		(listing-id-13 uint) (nft-asset-contract-13 <nft-trait>) (payment-asset-contract-13 <ft-trait>)
		(listing-id-14 uint) (nft-asset-contract-14 <nft-trait>) (payment-asset-contract-14 <ft-trait>)
		
	)
	(let (
		(result1 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract)) (fulfil-listing-stx listing-id nft-asset-contract) (fulfil-listing-ft listing-id nft-asset-contract payment-asset-contract))))
		(result2 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-2)) (fulfil-listing-stx listing-id-2 nft-asset-contract-2) (fulfil-listing-ft listing-id-2 nft-asset-contract-2 payment-asset-contract-2))))
		(result3 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-3)) (fulfil-listing-stx listing-id-3 nft-asset-contract-3) (fulfil-listing-ft listing-id-3 nft-asset-contract-3 payment-asset-contract-3))))
		(result4 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-4)) (fulfil-listing-stx listing-id-4 nft-asset-contract-4) (fulfil-listing-ft listing-id-4 nft-asset-contract-4 payment-asset-contract-4))))
		(result5 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-5)) (fulfil-listing-stx listing-id-5 nft-asset-contract-5) (fulfil-listing-ft listing-id-5 nft-asset-contract-5 payment-asset-contract-5))))
		(result6 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-6)) (fulfil-listing-stx listing-id-6 nft-asset-contract-6) (fulfil-listing-ft listing-id-6 nft-asset-contract-6 payment-asset-contract-6))))
		(result7 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-7)) (fulfil-listing-stx listing-id-7 nft-asset-contract-7) (fulfil-listing-ft listing-id-7 nft-asset-contract-7 payment-asset-contract-7))))
		(result8 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-8)) (fulfil-listing-stx listing-id-8 nft-asset-contract-8) (fulfil-listing-ft listing-id-8 nft-asset-contract-8 payment-asset-contract-8))))
		(result9 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-9)) (fulfil-listing-stx listing-id-9 nft-asset-contract-9) (fulfil-listing-ft listing-id-9 nft-asset-contract-9 payment-asset-contract-9))))
		(result10 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-10)) (fulfil-listing-stx listing-id-10 nft-asset-contract-10) (fulfil-listing-ft listing-id-10 nft-asset-contract-10 payment-asset-contract-10))))
		(result11 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-11)) (fulfil-listing-stx listing-id-11 nft-asset-contract-11) (fulfil-listing-ft listing-id-11 nft-asset-contract-11 payment-asset-contract-11))))
		(result12 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-12)) (fulfil-listing-stx listing-id-12 nft-asset-contract-12) (fulfil-listing-ft listing-id-12 nft-asset-contract-12 payment-asset-contract-12))))
		(result13 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-13)) (fulfil-listing-stx listing-id-13 nft-asset-contract-13) (fulfil-listing-ft listing-id-13 nft-asset-contract-13 payment-asset-contract-13))))
		(result14 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-14)) (fulfil-listing-stx listing-id-14 nft-asset-contract-14) (fulfil-listing-ft listing-id-14 nft-asset-contract-14 payment-asset-contract-14))))
		)

		(ok (list result1 result2 result3 result4 result5 result6 result7 result8 result9 result10 result11 result12 result13 result14))
	)
)

(define-public
	(buy-from-cart-15
		(listing-id uint) (nft-asset-contract <nft-trait>) (payment-asset-contract <ft-trait>)
		(listing-id-2 uint) (nft-asset-contract-2 <nft-trait>) (payment-asset-contract-2 <ft-trait>)
		(listing-id-3 uint) (nft-asset-contract-3 <nft-trait>) (payment-asset-contract-3 <ft-trait>)
		(listing-id-4 uint) (nft-asset-contract-4 <nft-trait>) (payment-asset-contract-4 <ft-trait>)
		(listing-id-5 uint) (nft-asset-contract-5 <nft-trait>) (payment-asset-contract-5 <ft-trait>)
		(listing-id-6 uint) (nft-asset-contract-6 <nft-trait>) (payment-asset-contract-6 <ft-trait>)
		(listing-id-7 uint) (nft-asset-contract-7 <nft-trait>) (payment-asset-contract-7 <ft-trait>)
		(listing-id-8 uint) (nft-asset-contract-8 <nft-trait>) (payment-asset-contract-8 <ft-trait>)
		(listing-id-9 uint) (nft-asset-contract-9 <nft-trait>) (payment-asset-contract-9 <ft-trait>)
		(listing-id-10 uint) (nft-asset-contract-10 <nft-trait>) (payment-asset-contract-10 <ft-trait>)
		(listing-id-11 uint) (nft-asset-contract-11 <nft-trait>) (payment-asset-contract-11 <ft-trait>)
		(listing-id-12 uint) (nft-asset-contract-12 <nft-trait>) (payment-asset-contract-12 <ft-trait>)
		(listing-id-13 uint) (nft-asset-contract-13 <nft-trait>) (payment-asset-contract-13 <ft-trait>)
		(listing-id-14 uint) (nft-asset-contract-14 <nft-trait>) (payment-asset-contract-14 <ft-trait>)
		(listing-id-15 uint) (nft-asset-contract-15 <nft-trait>) (payment-asset-contract-15 <ft-trait>)
		
	)
	(let (
		(result1 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract)) (fulfil-listing-stx listing-id nft-asset-contract) (fulfil-listing-ft listing-id nft-asset-contract payment-asset-contract))))
		(result2 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-2)) (fulfil-listing-stx listing-id-2 nft-asset-contract-2) (fulfil-listing-ft listing-id-2 nft-asset-contract-2 payment-asset-contract-2))))
		(result3 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-3)) (fulfil-listing-stx listing-id-3 nft-asset-contract-3) (fulfil-listing-ft listing-id-3 nft-asset-contract-3 payment-asset-contract-3))))
		(result4 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-4)) (fulfil-listing-stx listing-id-4 nft-asset-contract-4) (fulfil-listing-ft listing-id-4 nft-asset-contract-4 payment-asset-contract-4))))
		(result5 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-5)) (fulfil-listing-stx listing-id-5 nft-asset-contract-5) (fulfil-listing-ft listing-id-5 nft-asset-contract-5 payment-asset-contract-5))))
		(result6 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-6)) (fulfil-listing-stx listing-id-6 nft-asset-contract-6) (fulfil-listing-ft listing-id-6 nft-asset-contract-6 payment-asset-contract-6))))
		(result7 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-7)) (fulfil-listing-stx listing-id-7 nft-asset-contract-7) (fulfil-listing-ft listing-id-7 nft-asset-contract-7 payment-asset-contract-7))))
		(result8 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-8)) (fulfil-listing-stx listing-id-8 nft-asset-contract-8) (fulfil-listing-ft listing-id-8 nft-asset-contract-8 payment-asset-contract-8))))
		(result9 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-9)) (fulfil-listing-stx listing-id-9 nft-asset-contract-9) (fulfil-listing-ft listing-id-9 nft-asset-contract-9 payment-asset-contract-9))))
		(result10 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-10)) (fulfil-listing-stx listing-id-10 nft-asset-contract-10) (fulfil-listing-ft listing-id-10 nft-asset-contract-10 payment-asset-contract-10))))
		(result11 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-11)) (fulfil-listing-stx listing-id-11 nft-asset-contract-11) (fulfil-listing-ft listing-id-11 nft-asset-contract-11 payment-asset-contract-11))))
		(result12 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-12)) (fulfil-listing-stx listing-id-12 nft-asset-contract-12) (fulfil-listing-ft listing-id-12 nft-asset-contract-12 payment-asset-contract-12))))
		(result13 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-13)) (fulfil-listing-stx listing-id-13 nft-asset-contract-13) (fulfil-listing-ft listing-id-13 nft-asset-contract-13 payment-asset-contract-13))))
		(result14 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-14)) (fulfil-listing-stx listing-id-14 nft-asset-contract-14) (fulfil-listing-ft listing-id-14 nft-asset-contract-14 payment-asset-contract-14))))
		(result15 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-15)) (fulfil-listing-stx listing-id-15 nft-asset-contract-15) (fulfil-listing-ft listing-id-15 nft-asset-contract-15 payment-asset-contract-15))))
		)

		(ok (list result1 result2 result3 result4 result5 result6 result7 result8 result9 result10 result11 result12 result13 result14 result15))
	)
)

(define-public
	(buy-from-cart-16
		(listing-id uint) (nft-asset-contract <nft-trait>) (payment-asset-contract <ft-trait>)
		(listing-id-2 uint) (nft-asset-contract-2 <nft-trait>) (payment-asset-contract-2 <ft-trait>)
		(listing-id-3 uint) (nft-asset-contract-3 <nft-trait>) (payment-asset-contract-3 <ft-trait>)
		(listing-id-4 uint) (nft-asset-contract-4 <nft-trait>) (payment-asset-contract-4 <ft-trait>)
		(listing-id-5 uint) (nft-asset-contract-5 <nft-trait>) (payment-asset-contract-5 <ft-trait>)
		(listing-id-6 uint) (nft-asset-contract-6 <nft-trait>) (payment-asset-contract-6 <ft-trait>)
		(listing-id-7 uint) (nft-asset-contract-7 <nft-trait>) (payment-asset-contract-7 <ft-trait>)
		(listing-id-8 uint) (nft-asset-contract-8 <nft-trait>) (payment-asset-contract-8 <ft-trait>)
		(listing-id-9 uint) (nft-asset-contract-9 <nft-trait>) (payment-asset-contract-9 <ft-trait>)
		(listing-id-10 uint) (nft-asset-contract-10 <nft-trait>) (payment-asset-contract-10 <ft-trait>)
		(listing-id-11 uint) (nft-asset-contract-11 <nft-trait>) (payment-asset-contract-11 <ft-trait>)
		(listing-id-12 uint) (nft-asset-contract-12 <nft-trait>) (payment-asset-contract-12 <ft-trait>)
		(listing-id-13 uint) (nft-asset-contract-13 <nft-trait>) (payment-asset-contract-13 <ft-trait>)
		(listing-id-14 uint) (nft-asset-contract-14 <nft-trait>) (payment-asset-contract-14 <ft-trait>)
		(listing-id-15 uint) (nft-asset-contract-15 <nft-trait>) (payment-asset-contract-15 <ft-trait>)
		(listing-id-16 uint) (nft-asset-contract-16 <nft-trait>) (payment-asset-contract-16 <ft-trait>)
		
	)
	(let (
		(result1 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract)) (fulfil-listing-stx listing-id nft-asset-contract) (fulfil-listing-ft listing-id nft-asset-contract payment-asset-contract))))
		(result2 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-2)) (fulfil-listing-stx listing-id-2 nft-asset-contract-2) (fulfil-listing-ft listing-id-2 nft-asset-contract-2 payment-asset-contract-2))))
		(result3 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-3)) (fulfil-listing-stx listing-id-3 nft-asset-contract-3) (fulfil-listing-ft listing-id-3 nft-asset-contract-3 payment-asset-contract-3))))
		(result4 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-4)) (fulfil-listing-stx listing-id-4 nft-asset-contract-4) (fulfil-listing-ft listing-id-4 nft-asset-contract-4 payment-asset-contract-4))))
		(result5 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-5)) (fulfil-listing-stx listing-id-5 nft-asset-contract-5) (fulfil-listing-ft listing-id-5 nft-asset-contract-5 payment-asset-contract-5))))
		(result6 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-6)) (fulfil-listing-stx listing-id-6 nft-asset-contract-6) (fulfil-listing-ft listing-id-6 nft-asset-contract-6 payment-asset-contract-6))))
		(result7 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-7)) (fulfil-listing-stx listing-id-7 nft-asset-contract-7) (fulfil-listing-ft listing-id-7 nft-asset-contract-7 payment-asset-contract-7))))
		(result8 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-8)) (fulfil-listing-stx listing-id-8 nft-asset-contract-8) (fulfil-listing-ft listing-id-8 nft-asset-contract-8 payment-asset-contract-8))))
		(result9 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-9)) (fulfil-listing-stx listing-id-9 nft-asset-contract-9) (fulfil-listing-ft listing-id-9 nft-asset-contract-9 payment-asset-contract-9))))
		(result10 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-10)) (fulfil-listing-stx listing-id-10 nft-asset-contract-10) (fulfil-listing-ft listing-id-10 nft-asset-contract-10 payment-asset-contract-10))))
		(result11 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-11)) (fulfil-listing-stx listing-id-11 nft-asset-contract-11) (fulfil-listing-ft listing-id-11 nft-asset-contract-11 payment-asset-contract-11))))
		(result12 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-12)) (fulfil-listing-stx listing-id-12 nft-asset-contract-12) (fulfil-listing-ft listing-id-12 nft-asset-contract-12 payment-asset-contract-12))))
		(result13 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-13)) (fulfil-listing-stx listing-id-13 nft-asset-contract-13) (fulfil-listing-ft listing-id-13 nft-asset-contract-13 payment-asset-contract-13))))
		(result14 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-14)) (fulfil-listing-stx listing-id-14 nft-asset-contract-14) (fulfil-listing-ft listing-id-14 nft-asset-contract-14 payment-asset-contract-14))))
		(result15 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-15)) (fulfil-listing-stx listing-id-15 nft-asset-contract-15) (fulfil-listing-ft listing-id-15 nft-asset-contract-15 payment-asset-contract-15))))
		(result16 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-16)) (fulfil-listing-stx listing-id-16 nft-asset-contract-16) (fulfil-listing-ft listing-id-16 nft-asset-contract-16 payment-asset-contract-16))))
		)

		(ok (list result1 result2 result3 result4 result5 result6 result7 result8 result9 result10 result11 result12 result13 result14 result15 result16))
	)
)

(define-public
	(buy-from-cart-17
		(listing-id uint) (nft-asset-contract <nft-trait>) (payment-asset-contract <ft-trait>)
		(listing-id-2 uint) (nft-asset-contract-2 <nft-trait>) (payment-asset-contract-2 <ft-trait>)
		(listing-id-3 uint) (nft-asset-contract-3 <nft-trait>) (payment-asset-contract-3 <ft-trait>)
		(listing-id-4 uint) (nft-asset-contract-4 <nft-trait>) (payment-asset-contract-4 <ft-trait>)
		(listing-id-5 uint) (nft-asset-contract-5 <nft-trait>) (payment-asset-contract-5 <ft-trait>)
		(listing-id-6 uint) (nft-asset-contract-6 <nft-trait>) (payment-asset-contract-6 <ft-trait>)
		(listing-id-7 uint) (nft-asset-contract-7 <nft-trait>) (payment-asset-contract-7 <ft-trait>)
		(listing-id-8 uint) (nft-asset-contract-8 <nft-trait>) (payment-asset-contract-8 <ft-trait>)
		(listing-id-9 uint) (nft-asset-contract-9 <nft-trait>) (payment-asset-contract-9 <ft-trait>)
		(listing-id-10 uint) (nft-asset-contract-10 <nft-trait>) (payment-asset-contract-10 <ft-trait>)
		(listing-id-11 uint) (nft-asset-contract-11 <nft-trait>) (payment-asset-contract-11 <ft-trait>)
		(listing-id-12 uint) (nft-asset-contract-12 <nft-trait>) (payment-asset-contract-12 <ft-trait>)
		(listing-id-13 uint) (nft-asset-contract-13 <nft-trait>) (payment-asset-contract-13 <ft-trait>)
		(listing-id-14 uint) (nft-asset-contract-14 <nft-trait>) (payment-asset-contract-14 <ft-trait>)
		(listing-id-15 uint) (nft-asset-contract-15 <nft-trait>) (payment-asset-contract-15 <ft-trait>)
		(listing-id-16 uint) (nft-asset-contract-16 <nft-trait>) (payment-asset-contract-16 <ft-trait>)
		(listing-id-17 uint) (nft-asset-contract-17 <nft-trait>) (payment-asset-contract-17 <ft-trait>)
		
	)
	(let (
		(result1 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract)) (fulfil-listing-stx listing-id nft-asset-contract) (fulfil-listing-ft listing-id nft-asset-contract payment-asset-contract))))
		(result2 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-2)) (fulfil-listing-stx listing-id-2 nft-asset-contract-2) (fulfil-listing-ft listing-id-2 nft-asset-contract-2 payment-asset-contract-2))))
		(result3 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-3)) (fulfil-listing-stx listing-id-3 nft-asset-contract-3) (fulfil-listing-ft listing-id-3 nft-asset-contract-3 payment-asset-contract-3))))
		(result4 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-4)) (fulfil-listing-stx listing-id-4 nft-asset-contract-4) (fulfil-listing-ft listing-id-4 nft-asset-contract-4 payment-asset-contract-4))))
		(result5 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-5)) (fulfil-listing-stx listing-id-5 nft-asset-contract-5) (fulfil-listing-ft listing-id-5 nft-asset-contract-5 payment-asset-contract-5))))
		(result6 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-6)) (fulfil-listing-stx listing-id-6 nft-asset-contract-6) (fulfil-listing-ft listing-id-6 nft-asset-contract-6 payment-asset-contract-6))))
		(result7 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-7)) (fulfil-listing-stx listing-id-7 nft-asset-contract-7) (fulfil-listing-ft listing-id-7 nft-asset-contract-7 payment-asset-contract-7))))
		(result8 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-8)) (fulfil-listing-stx listing-id-8 nft-asset-contract-8) (fulfil-listing-ft listing-id-8 nft-asset-contract-8 payment-asset-contract-8))))
		(result9 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-9)) (fulfil-listing-stx listing-id-9 nft-asset-contract-9) (fulfil-listing-ft listing-id-9 nft-asset-contract-9 payment-asset-contract-9))))
		(result10 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-10)) (fulfil-listing-stx listing-id-10 nft-asset-contract-10) (fulfil-listing-ft listing-id-10 nft-asset-contract-10 payment-asset-contract-10))))
		(result11 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-11)) (fulfil-listing-stx listing-id-11 nft-asset-contract-11) (fulfil-listing-ft listing-id-11 nft-asset-contract-11 payment-asset-contract-11))))
		(result12 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-12)) (fulfil-listing-stx listing-id-12 nft-asset-contract-12) (fulfil-listing-ft listing-id-12 nft-asset-contract-12 payment-asset-contract-12))))
		(result13 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-13)) (fulfil-listing-stx listing-id-13 nft-asset-contract-13) (fulfil-listing-ft listing-id-13 nft-asset-contract-13 payment-asset-contract-13))))
		(result14 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-14)) (fulfil-listing-stx listing-id-14 nft-asset-contract-14) (fulfil-listing-ft listing-id-14 nft-asset-contract-14 payment-asset-contract-14))))
		(result15 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-15)) (fulfil-listing-stx listing-id-15 nft-asset-contract-15) (fulfil-listing-ft listing-id-15 nft-asset-contract-15 payment-asset-contract-15))))
		(result16 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-16)) (fulfil-listing-stx listing-id-16 nft-asset-contract-16) (fulfil-listing-ft listing-id-16 nft-asset-contract-16 payment-asset-contract-16))))
		(result17 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-17)) (fulfil-listing-stx listing-id-17 nft-asset-contract-17) (fulfil-listing-ft listing-id-17 nft-asset-contract-17 payment-asset-contract-17))))
		)

		(ok (list result1 result2 result3 result4 result5 result6 result7 result8 result9 result10 result11 result12 result13 result14 result15 result16 result17))
	)
)

(define-public
	(buy-from-cart-18
		(listing-id uint) (nft-asset-contract <nft-trait>) (payment-asset-contract <ft-trait>)
		(listing-id-2 uint) (nft-asset-contract-2 <nft-trait>) (payment-asset-contract-2 <ft-trait>)
		(listing-id-3 uint) (nft-asset-contract-3 <nft-trait>) (payment-asset-contract-3 <ft-trait>)
		(listing-id-4 uint) (nft-asset-contract-4 <nft-trait>) (payment-asset-contract-4 <ft-trait>)
		(listing-id-5 uint) (nft-asset-contract-5 <nft-trait>) (payment-asset-contract-5 <ft-trait>)
		(listing-id-6 uint) (nft-asset-contract-6 <nft-trait>) (payment-asset-contract-6 <ft-trait>)
		(listing-id-7 uint) (nft-asset-contract-7 <nft-trait>) (payment-asset-contract-7 <ft-trait>)
		(listing-id-8 uint) (nft-asset-contract-8 <nft-trait>) (payment-asset-contract-8 <ft-trait>)
		(listing-id-9 uint) (nft-asset-contract-9 <nft-trait>) (payment-asset-contract-9 <ft-trait>)
		(listing-id-10 uint) (nft-asset-contract-10 <nft-trait>) (payment-asset-contract-10 <ft-trait>)
		(listing-id-11 uint) (nft-asset-contract-11 <nft-trait>) (payment-asset-contract-11 <ft-trait>)
		(listing-id-12 uint) (nft-asset-contract-12 <nft-trait>) (payment-asset-contract-12 <ft-trait>)
		(listing-id-13 uint) (nft-asset-contract-13 <nft-trait>) (payment-asset-contract-13 <ft-trait>)
		(listing-id-14 uint) (nft-asset-contract-14 <nft-trait>) (payment-asset-contract-14 <ft-trait>)
		(listing-id-15 uint) (nft-asset-contract-15 <nft-trait>) (payment-asset-contract-15 <ft-trait>)
		(listing-id-16 uint) (nft-asset-contract-16 <nft-trait>) (payment-asset-contract-16 <ft-trait>)
		(listing-id-17 uint) (nft-asset-contract-17 <nft-trait>) (payment-asset-contract-17 <ft-trait>)
		(listing-id-18 uint) (nft-asset-contract-18 <nft-trait>) (payment-asset-contract-18 <ft-trait>)
		
	)
	(let (
		(result1 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract)) (fulfil-listing-stx listing-id nft-asset-contract) (fulfil-listing-ft listing-id nft-asset-contract payment-asset-contract))))
		(result2 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-2)) (fulfil-listing-stx listing-id-2 nft-asset-contract-2) (fulfil-listing-ft listing-id-2 nft-asset-contract-2 payment-asset-contract-2))))
		(result3 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-3)) (fulfil-listing-stx listing-id-3 nft-asset-contract-3) (fulfil-listing-ft listing-id-3 nft-asset-contract-3 payment-asset-contract-3))))
		(result4 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-4)) (fulfil-listing-stx listing-id-4 nft-asset-contract-4) (fulfil-listing-ft listing-id-4 nft-asset-contract-4 payment-asset-contract-4))))
		(result5 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-5)) (fulfil-listing-stx listing-id-5 nft-asset-contract-5) (fulfil-listing-ft listing-id-5 nft-asset-contract-5 payment-asset-contract-5))))
		(result6 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-6)) (fulfil-listing-stx listing-id-6 nft-asset-contract-6) (fulfil-listing-ft listing-id-6 nft-asset-contract-6 payment-asset-contract-6))))
		(result7 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-7)) (fulfil-listing-stx listing-id-7 nft-asset-contract-7) (fulfil-listing-ft listing-id-7 nft-asset-contract-7 payment-asset-contract-7))))
		(result8 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-8)) (fulfil-listing-stx listing-id-8 nft-asset-contract-8) (fulfil-listing-ft listing-id-8 nft-asset-contract-8 payment-asset-contract-8))))
		(result9 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-9)) (fulfil-listing-stx listing-id-9 nft-asset-contract-9) (fulfil-listing-ft listing-id-9 nft-asset-contract-9 payment-asset-contract-9))))
		(result10 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-10)) (fulfil-listing-stx listing-id-10 nft-asset-contract-10) (fulfil-listing-ft listing-id-10 nft-asset-contract-10 payment-asset-contract-10))))
		(result11 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-11)) (fulfil-listing-stx listing-id-11 nft-asset-contract-11) (fulfil-listing-ft listing-id-11 nft-asset-contract-11 payment-asset-contract-11))))
		(result12 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-12)) (fulfil-listing-stx listing-id-12 nft-asset-contract-12) (fulfil-listing-ft listing-id-12 nft-asset-contract-12 payment-asset-contract-12))))
		(result13 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-13)) (fulfil-listing-stx listing-id-13 nft-asset-contract-13) (fulfil-listing-ft listing-id-13 nft-asset-contract-13 payment-asset-contract-13))))
		(result14 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-14)) (fulfil-listing-stx listing-id-14 nft-asset-contract-14) (fulfil-listing-ft listing-id-14 nft-asset-contract-14 payment-asset-contract-14))))
		(result15 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-15)) (fulfil-listing-stx listing-id-15 nft-asset-contract-15) (fulfil-listing-ft listing-id-15 nft-asset-contract-15 payment-asset-contract-15))))
		(result16 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-16)) (fulfil-listing-stx listing-id-16 nft-asset-contract-16) (fulfil-listing-ft listing-id-16 nft-asset-contract-16 payment-asset-contract-16))))
		(result17 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-17)) (fulfil-listing-stx listing-id-17 nft-asset-contract-17) (fulfil-listing-ft listing-id-17 nft-asset-contract-17 payment-asset-contract-17))))
		(result18 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-18)) (fulfil-listing-stx listing-id-18 nft-asset-contract-18) (fulfil-listing-ft listing-id-18 nft-asset-contract-18 payment-asset-contract-18))))
		)

		(ok (list result1 result2 result3 result4 result5 result6 result7 result8 result9 result10 result11 result12 result13 result14 result15 result16 result17 result18))
	)
)

(define-public
	(buy-from-cart-19
		(listing-id uint) (nft-asset-contract <nft-trait>) (payment-asset-contract <ft-trait>)
		(listing-id-2 uint) (nft-asset-contract-2 <nft-trait>) (payment-asset-contract-2 <ft-trait>)
		(listing-id-3 uint) (nft-asset-contract-3 <nft-trait>) (payment-asset-contract-3 <ft-trait>)
		(listing-id-4 uint) (nft-asset-contract-4 <nft-trait>) (payment-asset-contract-4 <ft-trait>)
		(listing-id-5 uint) (nft-asset-contract-5 <nft-trait>) (payment-asset-contract-5 <ft-trait>)
		(listing-id-6 uint) (nft-asset-contract-6 <nft-trait>) (payment-asset-contract-6 <ft-trait>)
		(listing-id-7 uint) (nft-asset-contract-7 <nft-trait>) (payment-asset-contract-7 <ft-trait>)
		(listing-id-8 uint) (nft-asset-contract-8 <nft-trait>) (payment-asset-contract-8 <ft-trait>)
		(listing-id-9 uint) (nft-asset-contract-9 <nft-trait>) (payment-asset-contract-9 <ft-trait>)
		(listing-id-10 uint) (nft-asset-contract-10 <nft-trait>) (payment-asset-contract-10 <ft-trait>)
		(listing-id-11 uint) (nft-asset-contract-11 <nft-trait>) (payment-asset-contract-11 <ft-trait>)
		(listing-id-12 uint) (nft-asset-contract-12 <nft-trait>) (payment-asset-contract-12 <ft-trait>)
		(listing-id-13 uint) (nft-asset-contract-13 <nft-trait>) (payment-asset-contract-13 <ft-trait>)
		(listing-id-14 uint) (nft-asset-contract-14 <nft-trait>) (payment-asset-contract-14 <ft-trait>)
		(listing-id-15 uint) (nft-asset-contract-15 <nft-trait>) (payment-asset-contract-15 <ft-trait>)
		(listing-id-16 uint) (nft-asset-contract-16 <nft-trait>) (payment-asset-contract-16 <ft-trait>)
		(listing-id-17 uint) (nft-asset-contract-17 <nft-trait>) (payment-asset-contract-17 <ft-trait>)
		(listing-id-18 uint) (nft-asset-contract-18 <nft-trait>) (payment-asset-contract-18 <ft-trait>)
		(listing-id-19 uint) (nft-asset-contract-19 <nft-trait>) (payment-asset-contract-19 <ft-trait>)
		
	)
	(let (
		(result1 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract)) (fulfil-listing-stx listing-id nft-asset-contract) (fulfil-listing-ft listing-id nft-asset-contract payment-asset-contract))))
		(result2 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-2)) (fulfil-listing-stx listing-id-2 nft-asset-contract-2) (fulfil-listing-ft listing-id-2 nft-asset-contract-2 payment-asset-contract-2))))
		(result3 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-3)) (fulfil-listing-stx listing-id-3 nft-asset-contract-3) (fulfil-listing-ft listing-id-3 nft-asset-contract-3 payment-asset-contract-3))))
		(result4 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-4)) (fulfil-listing-stx listing-id-4 nft-asset-contract-4) (fulfil-listing-ft listing-id-4 nft-asset-contract-4 payment-asset-contract-4))))
		(result5 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-5)) (fulfil-listing-stx listing-id-5 nft-asset-contract-5) (fulfil-listing-ft listing-id-5 nft-asset-contract-5 payment-asset-contract-5))))
		(result6 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-6)) (fulfil-listing-stx listing-id-6 nft-asset-contract-6) (fulfil-listing-ft listing-id-6 nft-asset-contract-6 payment-asset-contract-6))))
		(result7 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-7)) (fulfil-listing-stx listing-id-7 nft-asset-contract-7) (fulfil-listing-ft listing-id-7 nft-asset-contract-7 payment-asset-contract-7))))
		(result8 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-8)) (fulfil-listing-stx listing-id-8 nft-asset-contract-8) (fulfil-listing-ft listing-id-8 nft-asset-contract-8 payment-asset-contract-8))))
		(result9 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-9)) (fulfil-listing-stx listing-id-9 nft-asset-contract-9) (fulfil-listing-ft listing-id-9 nft-asset-contract-9 payment-asset-contract-9))))
		(result10 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-10)) (fulfil-listing-stx listing-id-10 nft-asset-contract-10) (fulfil-listing-ft listing-id-10 nft-asset-contract-10 payment-asset-contract-10))))
		(result11 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-11)) (fulfil-listing-stx listing-id-11 nft-asset-contract-11) (fulfil-listing-ft listing-id-11 nft-asset-contract-11 payment-asset-contract-11))))
		(result12 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-12)) (fulfil-listing-stx listing-id-12 nft-asset-contract-12) (fulfil-listing-ft listing-id-12 nft-asset-contract-12 payment-asset-contract-12))))
		(result13 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-13)) (fulfil-listing-stx listing-id-13 nft-asset-contract-13) (fulfil-listing-ft listing-id-13 nft-asset-contract-13 payment-asset-contract-13))))
		(result14 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-14)) (fulfil-listing-stx listing-id-14 nft-asset-contract-14) (fulfil-listing-ft listing-id-14 nft-asset-contract-14 payment-asset-contract-14))))
		(result15 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-15)) (fulfil-listing-stx listing-id-15 nft-asset-contract-15) (fulfil-listing-ft listing-id-15 nft-asset-contract-15 payment-asset-contract-15))))
		(result16 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-16)) (fulfil-listing-stx listing-id-16 nft-asset-contract-16) (fulfil-listing-ft listing-id-16 nft-asset-contract-16 payment-asset-contract-16))))
		(result17 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-17)) (fulfil-listing-stx listing-id-17 nft-asset-contract-17) (fulfil-listing-ft listing-id-17 nft-asset-contract-17 payment-asset-contract-17))))
		(result18 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-18)) (fulfil-listing-stx listing-id-18 nft-asset-contract-18) (fulfil-listing-ft listing-id-18 nft-asset-contract-18 payment-asset-contract-18))))
		(result19 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-19)) (fulfil-listing-stx listing-id-19 nft-asset-contract-19) (fulfil-listing-ft listing-id-19 nft-asset-contract-19 payment-asset-contract-19))))
		)

		(ok (list result1 result2 result3 result4 result5 result6 result7 result8 result9 result10 result11 result12 result13 result14 result15 result16 result17 result18 result19))
	)
)

(define-public
	(buy-from-cart-20
		(listing-id uint) (nft-asset-contract <nft-trait>) (payment-asset-contract <ft-trait>)
		(listing-id-2 uint) (nft-asset-contract-2 <nft-trait>) (payment-asset-contract-2 <ft-trait>)
		(listing-id-3 uint) (nft-asset-contract-3 <nft-trait>) (payment-asset-contract-3 <ft-trait>)
		(listing-id-4 uint) (nft-asset-contract-4 <nft-trait>) (payment-asset-contract-4 <ft-trait>)
		(listing-id-5 uint) (nft-asset-contract-5 <nft-trait>) (payment-asset-contract-5 <ft-trait>)
		(listing-id-6 uint) (nft-asset-contract-6 <nft-trait>) (payment-asset-contract-6 <ft-trait>)
		(listing-id-7 uint) (nft-asset-contract-7 <nft-trait>) (payment-asset-contract-7 <ft-trait>)
		(listing-id-8 uint) (nft-asset-contract-8 <nft-trait>) (payment-asset-contract-8 <ft-trait>)
		(listing-id-9 uint) (nft-asset-contract-9 <nft-trait>) (payment-asset-contract-9 <ft-trait>)
		(listing-id-10 uint) (nft-asset-contract-10 <nft-trait>) (payment-asset-contract-10 <ft-trait>)
		(listing-id-11 uint) (nft-asset-contract-11 <nft-trait>) (payment-asset-contract-11 <ft-trait>)
		(listing-id-12 uint) (nft-asset-contract-12 <nft-trait>) (payment-asset-contract-12 <ft-trait>)
		(listing-id-13 uint) (nft-asset-contract-13 <nft-trait>) (payment-asset-contract-13 <ft-trait>)
		(listing-id-14 uint) (nft-asset-contract-14 <nft-trait>) (payment-asset-contract-14 <ft-trait>)
		(listing-id-15 uint) (nft-asset-contract-15 <nft-trait>) (payment-asset-contract-15 <ft-trait>)
		(listing-id-16 uint) (nft-asset-contract-16 <nft-trait>) (payment-asset-contract-16 <ft-trait>)
		(listing-id-17 uint) (nft-asset-contract-17 <nft-trait>) (payment-asset-contract-17 <ft-trait>)
		(listing-id-18 uint) (nft-asset-contract-18 <nft-trait>) (payment-asset-contract-18 <ft-trait>)
		(listing-id-19 uint) (nft-asset-contract-19 <nft-trait>) (payment-asset-contract-19 <ft-trait>)
		(listing-id-20 uint) (nft-asset-contract-20 <nft-trait>) (payment-asset-contract-20 <ft-trait>)
		
	)
	(let (
		(result1 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract)) (fulfil-listing-stx listing-id nft-asset-contract) (fulfil-listing-ft listing-id nft-asset-contract payment-asset-contract))))
		(result2 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-2)) (fulfil-listing-stx listing-id-2 nft-asset-contract-2) (fulfil-listing-ft listing-id-2 nft-asset-contract-2 payment-asset-contract-2))))
		(result3 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-3)) (fulfil-listing-stx listing-id-3 nft-asset-contract-3) (fulfil-listing-ft listing-id-3 nft-asset-contract-3 payment-asset-contract-3))))
		(result4 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-4)) (fulfil-listing-stx listing-id-4 nft-asset-contract-4) (fulfil-listing-ft listing-id-4 nft-asset-contract-4 payment-asset-contract-4))))
		(result5 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-5)) (fulfil-listing-stx listing-id-5 nft-asset-contract-5) (fulfil-listing-ft listing-id-5 nft-asset-contract-5 payment-asset-contract-5))))
		(result6 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-6)) (fulfil-listing-stx listing-id-6 nft-asset-contract-6) (fulfil-listing-ft listing-id-6 nft-asset-contract-6 payment-asset-contract-6))))
		(result7 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-7)) (fulfil-listing-stx listing-id-7 nft-asset-contract-7) (fulfil-listing-ft listing-id-7 nft-asset-contract-7 payment-asset-contract-7))))
		(result8 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-8)) (fulfil-listing-stx listing-id-8 nft-asset-contract-8) (fulfil-listing-ft listing-id-8 nft-asset-contract-8 payment-asset-contract-8))))
		(result9 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-9)) (fulfil-listing-stx listing-id-9 nft-asset-contract-9) (fulfil-listing-ft listing-id-9 nft-asset-contract-9 payment-asset-contract-9))))
		(result10 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-10)) (fulfil-listing-stx listing-id-10 nft-asset-contract-10) (fulfil-listing-ft listing-id-10 nft-asset-contract-10 payment-asset-contract-10))))
		(result11 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-11)) (fulfil-listing-stx listing-id-11 nft-asset-contract-11) (fulfil-listing-ft listing-id-11 nft-asset-contract-11 payment-asset-contract-11))))
		(result12 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-12)) (fulfil-listing-stx listing-id-12 nft-asset-contract-12) (fulfil-listing-ft listing-id-12 nft-asset-contract-12 payment-asset-contract-12))))
		(result13 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-13)) (fulfil-listing-stx listing-id-13 nft-asset-contract-13) (fulfil-listing-ft listing-id-13 nft-asset-contract-13 payment-asset-contract-13))))
		(result14 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-14)) (fulfil-listing-stx listing-id-14 nft-asset-contract-14) (fulfil-listing-ft listing-id-14 nft-asset-contract-14 payment-asset-contract-14))))
		(result15 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-15)) (fulfil-listing-stx listing-id-15 nft-asset-contract-15) (fulfil-listing-ft listing-id-15 nft-asset-contract-15 payment-asset-contract-15))))
		(result16 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-16)) (fulfil-listing-stx listing-id-16 nft-asset-contract-16) (fulfil-listing-ft listing-id-16 nft-asset-contract-16 payment-asset-contract-16))))
		(result17 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-17)) (fulfil-listing-stx listing-id-17 nft-asset-contract-17) (fulfil-listing-ft listing-id-17 nft-asset-contract-17 payment-asset-contract-17))))
		(result18 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-18)) (fulfil-listing-stx listing-id-18 nft-asset-contract-18) (fulfil-listing-ft listing-id-18 nft-asset-contract-18 payment-asset-contract-18))))
		(result19 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-19)) (fulfil-listing-stx listing-id-19 nft-asset-contract-19) (fulfil-listing-ft listing-id-19 nft-asset-contract-19 payment-asset-contract-19))))
		(result20 (unwrap-panic (if (is-eq dummy-token (contract-of payment-asset-contract-20)) (fulfil-listing-stx listing-id-20 nft-asset-contract-20) (fulfil-listing-ft listing-id-20 nft-asset-contract-20 payment-asset-contract-20))))
		)

		(ok (list result1 result2 result3 result4 result5 result6 result7 result8 result9 result10 result11 result12 result13 result14 result15 result16 result17 result18 result19 result20))
	)
)

(define-read-only (get-royalty-amount (contract principal))
  (match (map-get? whitelisted-royalty-contracts contract)
    royalty-data
    (get royalty-percent royalty-data)
    u0)
)

(define-private (get-royalty (contract principal))
  (match (map-get? whitelisted-royalty-contracts contract)
    royalty-data
    royalty-data
    {royalty-address: contract-owner, royalty-percent: u0})
)

(define-public (set-royalty (contract principal) (address principal) (percent uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) (err err-unauthorised))
    (ok (map-set whitelisted-royalty-contracts contract {royalty-address: address, royalty-percent: percent}))
  )
)

(define-public (set-minimum-commission (commission uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) (err err-unauthorised))
    (ok (var-set minimum-commission commission))
  )
)

(define-public (set-commission-owner (comm-owner principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) (err err-unauthorised))
    (ok (var-set commission-owner comm-owner))
  )
)

(define-public (set-minimum-listing-price (price uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) (err err-unauthorised))
    (ok (var-set minimum-listing-price price))
  )
)

(define-public (set-listings-frozen (frozen bool))
  (begin
    (asserts! (is-eq tx-sender contract-owner) (err err-unauthorised))
    (ok (var-set listings-frozen frozen))
  )
)

(define-public (set-unlistings-frozen (frozen bool))
  (begin
    (asserts! (is-eq tx-sender contract-owner) (err err-unauthorised))
    (ok (var-set unlistings-frozen frozen))
  )
)

(define-public (set-buy-frozen (frozen bool))
  (begin
    (asserts! (is-eq tx-sender contract-owner) (err err-unauthorised))
    (ok (var-set buy-frozen frozen))
  )
)

;; local
;; (try! (set-whitelisted .adult-nft true))
;; (try! (set-whitelisted .kids-nft true))
;; (try! (set-whitelisted .ballen-token true))

;; testnet
;; (try! (set-whitelisted .kids-nft true))
;; (try! (set-whitelisted .baby-nft true))
;; (try! (set-whitelisted .level-token true))

;; (try! (set-royalty .kids-nft 'ST2G273RQ9M48R0GHK1J1QGXPXWERXB4H8Y552E7G u500))
;; (try! (set-royalty .baby-nft 'ST2G273RQ9M48R0GHK1J1QGXPXWERXB4H8Y552E7G u250))

;; mainnet
(try! (set-whitelisted 'SP176ZMV706NZGDDX8VSQRGMB7QN33BBDVZ6BMNHD.project-indigo-act1 true))
(try! (set-whitelisted 'SP125J1ADVYWGWB9NQRCVGKYAG73R17ZNMV17XEJ7.mutant-monkeys true))
(try! (set-whitelisted 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.bitcoin-monkeys true))
(try! (set-whitelisted 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.hback-whales-nft true))
(try! (set-whitelisted 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.steady-lads true))
(try! (set-whitelisted 'SP2X0TZ59D5SZ8ACQ6YMCHHNR2ZN51Z32E2CJ173.the-explorer-guild true))
(try! (set-whitelisted 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.megapont-ape-club true))
(try! (set-whitelisted 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.megapont-robot-nft true))
(try! (set-whitelisted 'SPXG42Y7WDTMZF5MPV02C3AWY1VNP9FH9C23PRXH.Marbling true))

(try! (set-royalty 'SPXG42Y7WDTMZF5MPV02C3AWY1VNP9FH9C23PRXH.Marbling 'SP14R048JMWRK7WHXNWZVW878B67YV14JJRBBMK8B u500))