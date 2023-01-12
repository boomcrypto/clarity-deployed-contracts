(define-constant contract-principal (as-contract tx-sender))

(define-constant err-forbidden (err u403))
(define-constant err-same-principal (err u508))
(define-constant err-bad-mint-status (err u600))
(define-constant err-sold-out (err u601))
(define-constant err-failed (err u602))
(define-constant err-no-claims (err u603))
(define-constant err-cannot-claim-future (err u604))

(define-constant block-height-increment u1)

(define-data-var mint-enabled bool false)
(define-data-var price-in-ustx uint u1130000000)
(define-data-var payment-recipient principal 'SP1YZSSPWJ5D3S1G48ZPW8NGXVG0K2TZJJXDM6N0Q)

(define-data-var lower-mint-id uint u0)
(define-data-var upper-mint-id uint u0)
(define-data-var last-transferred-id uint u0)
(define-data-var amount-available-for-purchase uint u0)

(define-map admins principal bool)
(define-map claim-triggers principal bool)
(map-set admins tx-sender true)
(map-set admins 'SP3K44BG6E9PC7SE5VZG97P25EP99ZTSQRP923A3B true)
(map-set admins 'SPRYDH1HN9X5JWGXQ5B534XEM61X75JVDEVE0NYK true)
(map-set admins 'SP9CZCK08XMEP1PX4YEWZGJ71YGZF3C68BX72BJS true)
(map-set claim-triggers 'SPCT8SFRA70FDGVDMS9FHP9HHCXE409Y7AD0VMAW true)

(define-map nft-claims {height: uint, buyer: principal} uint)
(define-map token-mapping uint uint)

(define-read-only (nfts-available)
	(var-get amount-available-for-purchase))

(define-read-only (get-nft-claims (height uint) (buyer principal))
	(default-to u0 (map-get? nft-claims {height: height, buyer: buyer})))

(define-read-only (get-vrf (height uint))
	(get-block-info? vrf-seed height))

(define-private (pick-next-random-token-id (lower-bound uint) (upper-bound uint) (height uint))
	(begin
		(asserts! (> upper-bound lower-bound) (some lower-bound))
		(let ((seed (sha256 (concat (unwrap! (get-vrf height) none) (sha256 (var-get last-transferred-id)))))
			(number (+
				(match (element-at seed u0) byte (unwrap-panic (index-of byte-list byte)) u0)
				(match (element-at seed u1) byte (* (unwrap-panic (index-of byte-list byte)) u256) u0)
				(match (element-at seed u2) byte (* (unwrap-panic (index-of byte-list byte)) u65536) u0))))
			(some (+ lower-bound (mod number (- upper-bound lower-bound)))))))

(define-public (buy (amount uint))
	(let ((available (var-get amount-available-for-purchase))
		(target-height (+ block-height block-height-increment)))
		(asserts! (var-get mint-enabled) err-bad-mint-status)
		(asserts! (>= available amount) err-sold-out)
		(var-set amount-available-for-purchase (- available amount))
		(map-set nft-claims {height: target-height, buyer: tx-sender} (+ (get-nft-claims target-height tx-sender) amount))
		(try! (stx-transfer? (* (var-get price-in-ustx) amount) tx-sender (var-get payment-recipient)))
		(print {buy: amount, height: target-height, buyer: tx-sender})
		(ok target-height)))

(define-public (claim (height uint))
	(claim-for height tx-sender))

(define-public (claim-for (height uint) (buyer principal))
	(let ((upper-bound (var-get upper-mint-id))
		(index (unwrap! (pick-next-random-token-id (var-get lower-mint-id) upper-bound height) err-cannot-claim-future))
		(transfer-id (default-to index (map-get? token-mapping index)))
		(claims (get-nft-claims height buyer)))
		(asserts! (or
			(is-eq buyer tx-sender)
			(default-to false (map-get? claim-triggers contract-caller))
			(default-to false (map-get? admins contract-caller)))
			err-forbidden)
		(asserts! (> claims u0) err-no-claims)
		(try! (contract-call? .ryder-nft transfer transfer-id contract-principal buyer))
		(map-set token-mapping index (default-to upper-bound (map-get? token-mapping upper-bound)))
		(var-set upper-mint-id (- upper-bound u1))
		(var-set last-transferred-id transfer-id)
		(map-set nft-claims {height: height, buyer: buyer} (- claims u1))
		(print {claim: transfer-id, height: height, buyer: buyer})
		(ok transfer-id)))

(define-public (claim-many (heights (list 20 uint)))
	(ok (map claim heights)))

(define-public (claim-many-for (heights (list 50 uint)) (buyers (list 50 principal)))
	(ok (map claim-for heights buyers)))

(define-read-only (get-upper-bound)
	(var-get upper-mint-id))

(define-read-only (get-price-in-ustx)
  (var-get price-in-ustx))

(define-read-only (get-mint-enabled)
	(var-get mint-enabled))

(define-read-only (get-payment-recipient)
  (var-get payment-recipient))

(define-read-only (is-admin  (account principal))
  (default-to false (map-get? admins account)))

;; admin function
(define-read-only (check-is-admin)
  (ok (asserts! (default-to false (map-get? admins contract-caller)) err-forbidden)))

(define-private (mint-to-contract-iter (c (buff 1)) (p (optional (response bool uint))))
	(some (contract-call? .ryder-nft mint contract-principal)))

(define-public (mint-to-contract (iterations (buff 200)))
	(begin
		(try! (check-is-admin))
		(asserts! (not (var-get mint-enabled)) err-bad-mint-status)
		(and (is-eq (var-get lower-mint-id) u0) 
			(var-set lower-mint-id (contract-call? .ryder-nft get-token-id-nonce)))
		(fold mint-to-contract-iter iterations none)
		(var-set upper-mint-id (- (contract-call? .ryder-nft get-token-id-nonce) u1))
		(ok (var-set amount-available-for-purchase (- (+ (var-get upper-mint-id) u1) (var-get lower-mint-id))))))

(define-public (set-mint-enabled (enabled bool))
	(begin
		(try! (check-is-admin))
		(ok (var-set mint-enabled enabled))))

(define-public (set-admin (new-admin principal) (value bool))
  (begin
    (try! (check-is-admin))
    (asserts! (not (is-eq tx-sender new-admin)) err-same-principal)
    (ok (map-set admins new-admin value))))

(define-public (set-claim-trigger (new-trigger principal) (value bool))
  (begin
    (try! (check-is-admin))
    (ok (map-set claim-triggers new-trigger value))))

(define-private (burn-top-iter (c (buff 1)) (data {i: uint, p: (response bool uint)}))
	(begin
		(unwrap! (get p data) data)
		{i: (- (get i data) u1), p: (as-contract (contract-call? .ryder-nft burn (get i data)))}))

;; once burn-top is used, mint-to-contract can never be used again
(define-public (burn-contract-tokens-top (iterations (buff 200)))
	(let ((valid-admin (try! (check-is-admin)))
		  (valid-length (asserts! (>= (var-get upper-mint-id) (len iterations)) err-bad-mint-status))
		  (result (fold burn-top-iter iterations {i: (var-get upper-mint-id), p: (ok true)})))
		(unwrap! (get p result) err-failed)
		(ok (var-set upper-mint-id (get i result)))))

(define-public (set-payment-recipient (recipient principal))
  (begin
    (try! (check-is-admin))
    (ok (var-set payment-recipient recipient))))

(define-public (set-price-in-ustx (price uint))
  (begin
    (try! (check-is-admin))
    (ok (var-set price-in-ustx price))))

(define-constant byte-list 0x000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f404142434445464748494a4b4c4d4e4f505152535455565758595a5b5c5d5e5f606162636465666768696a6b6c6d6e6f707172737475767778797a7b7c7d7e7f808182838485868788898a8b8c8d8e8f909192939495969798999a9b9c9d9e9fa0a1a2a3a4a5a6a7a8a9aaabacadaeafb0b1b2b3b4b5b6b7b8b9babbbcbdbebfc0c1c2c3c4c5c6c7c8c9cacbcccdcecfd0d1d2d3d4d5d6d7d8d9dadbdcdddedfe0e1e2e3e4e5e6e7e8e9eaebecedeeeff0f1f2f3f4f5f6f7f8f9fafbfcfdfeff)
