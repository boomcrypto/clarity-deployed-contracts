;; title: promoter-nft
;; version: 1.0
;; summary: A non-fungible token contract for the Promoter NFT
;; description:
(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token promoter-nft uint)

(define-map contract-managers principal bool)

(define-constant ERR-PERMISSION-DENIED (err u1200))
(define-constant ERR-NOT-TOKEN-OWNER (err u1201))
(define-constant ERR-TOKEN-NOT-EXIST (err u1202))

(define-data-var last-token-id uint u0)
(define-data-var base-uri (string-ascii 120) "https://boostaid.net/api/v1/nft/promoter/")

(define-map data
	uint
	{
		metadata: (string-ascii 100),
		meta-type: uint,
		top-1: uint,
		top-2: uint,
		top-3: uint
	}
)

(define-read-only (is-contract-manager)
	(default-to false (map-get? contract-managers tx-sender)))

(define-public (add-contract-manager (contract principal))
    (begin 
        (asserts! (is-contract-manager) ERR-PERMISSION-DENIED)
        (map-set contract-managers contract true)
        (ok true)
    ))

(define-public (remove-contract-manager (contract principal))
    (begin 
        (asserts! (is-contract-manager) ERR-PERMISSION-DENIED)
        (map-delete contract-managers contract)
        (ok true)
    ))

(define-read-only (get-last-token-id)
	(ok (var-get last-token-id))
)

(define-read-only (get-token-uri (token-id uint))
	(if (> token-id (var-get last-token-id))
		(ok none)
		(ok (some (concat (var-get base-uri) (int-to-ascii token-id))))
	)
)

(define-read-only (get-owner (token-id uint))
	(ok (nft-get-owner? promoter-nft token-id))
)

(define-read-only (get-metadata (token-id uint))
	(begin
		(asserts! (<= token-id (var-get last-token-id)) ERR-TOKEN-NOT-EXIST)
		(ok (map-get? data token-id))
	)
)

(define-public (transfer (token-id uint) (sender principal) (recipient principal))
	(begin
		(asserts! (is-eq tx-sender sender) ERR-NOT-TOKEN-OWNER)
		(asserts! (<= token-id (var-get last-token-id)) ERR-TOKEN-NOT-EXIST)
		(try! (contract-call? .treasury pay-tax u4))
		(nft-transfer? promoter-nft token-id sender recipient)
	)
)

(define-public (mint (recipient principal) (m-type uint) (m-data (string-ascii 100)))
	(let
		(
			(token-id (+ (var-get last-token-id) u1))
		)
		(try! (contract-call? .treasury pay-tax u3))
		(try! (nft-mint? promoter-nft token-id recipient))
		(map-set data token-id {
			metadata: m-data,
			meta-type: m-type,
			top-1: u0,
			top-2: u0,
			top-3: u0
		})
		(var-set last-token-id token-id)
		(ok token-id)
	)
)

(define-public (update-data (token-id uint) (m-type uint) (m-data (string-ascii 100)))
	(begin 
		(asserts! (<= token-id (var-get last-token-id)) ERR-TOKEN-NOT-EXIST)
		(asserts! (is-eq tx-sender (unwrap-panic (unwrap-panic (get-owner token-id)))) ERR-PERMISSION-DENIED)
		(try! (contract-call? .treasury pay-tax u5))
		(let ((data-token (unwrap-panic (map-get? data token-id))))
			(merge data-token {
				metadata: m-data,
				meta-type: m-type
			})
			(ok true)
		)
	)
)

(define-public (update-base-uri (base-uri-new (string-ascii 120)))
	(begin
		(asserts! (is-contract-manager) ERR-PERMISSION-DENIED)
		(var-set base-uri base-uri-new)
		(ok true)
	)
)

(define-public (add-top-1 (token-id uint))
	(begin
		(asserts! (<= token-id (var-get last-token-id)) ERR-TOKEN-NOT-EXIST)
		(asserts! (is-contract-manager) ERR-PERMISSION-DENIED)
		(let (
				(data-token (unwrap-panic (map-get? data token-id)))
			)
			(map-set data token-id (merge data-token {
				top-1: (+ (get top-1 data-token) u1)
			}))
			(ok true))
	)
)

(define-public (add-top-2 (token-id uint)) 
	(begin
		(asserts! (<= token-id (var-get last-token-id)) ERR-TOKEN-NOT-EXIST)
		(asserts! (is-contract-manager) ERR-PERMISSION-DENIED)
		(let (
				(data-token (unwrap-panic (map-get? data token-id)))
			)
			(map-set data token-id (merge data-token {
				top-2: (+ (get top-2 data-token) u1)
			}))
			(ok true))
	)
)

(define-public (add-top-3 (token-id uint)) 
	(begin
		(asserts! (<= token-id (var-get last-token-id)) ERR-TOKEN-NOT-EXIST)
		(asserts! (is-contract-manager) ERR-PERMISSION-DENIED)
		(let (
				(data-token (unwrap-panic (map-get? data token-id)))
			)
			(map-set data token-id (merge data-token {
				top-3: (+ (get top-3 data-token) u1)
			}))
			(ok true))
	)
)

(define-public (add-no-ranked (token-id uint)) 
	(begin
		(asserts! (<= token-id (var-get last-token-id)) ERR-TOKEN-NOT-EXIST)
		(ok true)
	)
)

(map-set contract-managers .promoter-rank true)
(map-set contract-managers tx-sender true)