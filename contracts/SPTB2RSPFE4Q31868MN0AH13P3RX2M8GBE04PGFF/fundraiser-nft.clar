;; title: fundraiser-nft
;; version: 1.0
;; summary: A non-fungible token contract for fundraising
(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token fundraiser-nft uint)

(define-constant ERR-PERMISSION-DENIED (err u1100))
(define-constant ERR-NOT-TOKEN-OWNER (err u1101))
(define-constant ERR-TOKEN-NOT-EXIST (err u1102))
(define-constant ERR-PRECONDITION (err u1103))

(define-data-var base-uri (string-ascii 120) "https://boostaid.net/api/v1/nft/fundraiser/")

(define-data-var last-token-id uint u0)
(define-map data
    uint
    {
        metadata: (string-ascii 100),
		meta-type: uint,
		prositive-votes: uint,
		negative-votes: uint,
		prositive-points: uint,
		negative-points: uint,
    }
)

(define-map contract-managers principal bool)
(map-set contract-managers tx-sender true)

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
	(ok (nft-get-owner? fundraiser-nft token-id))
)

(define-public (transfer (token-id uint) (sender principal) (recipient principal))
	(begin
		(asserts! (is-eq tx-sender sender) ERR-NOT-TOKEN-OWNER)
		(asserts! (<= token-id (var-get last-token-id)) ERR-TOKEN-NOT-EXIST)
		(try! (contract-call? .treasury pay-tax u1))
		(nft-transfer? fundraiser-nft token-id sender recipient)
	)
)

(define-public (mint (recipient principal) (m-type uint) (m-data (string-ascii 100)))
	(let
		(
			(token-id (+ (var-get last-token-id) u1))
		)
		(try! (contract-call? .treasury pay-tax u0))
		(try! (nft-mint? fundraiser-nft token-id recipient))
		(map-set data token-id {
			metadata: m-data,
			meta-type: m-type,
			prositive-votes: u0,
			negative-votes: u0,
			prositive-points: u0,
			negative-points: u0
			})
		(var-set last-token-id token-id)
		(ok token-id)
	)
)

(define-public (update-data (token-id uint) (m-type uint) (m-data (string-ascii 100)))
	(begin 
		(asserts! (<= token-id (var-get last-token-id)) ERR-TOKEN-NOT-EXIST)
		(asserts! (is-eq tx-sender (unwrap-panic (unwrap-panic (get-owner token-id)))) ERR-PERMISSION-DENIED)
		(try! (contract-call? .treasury pay-tax u2))
		(let (
				(d (unwrap-panic (map-get? data token-id)))
			)
			(map-set data token-id {
				metadata: m-data,
				meta-type: m-type,
				prositive-votes: (get prositive-votes d),
				negative-votes: (get negative-votes d),
				prositive-points: (get prositive-points d),
				negative-points: (get negative-points d)
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

(define-read-only (get-metadata (token-id uint))
	(begin
		(asserts! (<= token-id (var-get last-token-id)) ERR-TOKEN-NOT-EXIST)
		(ok (map-get? data token-id))
	)
)

(define-public (add-positive-vote (token-id uint) (points uint))
	(begin
		(asserts! (> points u0) ERR-PRECONDITION)
		(asserts! (<= token-id (var-get last-token-id)) ERR-TOKEN-NOT-EXIST)
		(asserts! (is-contract-manager) ERR-PERMISSION-DENIED)
		(let (
				(d (unwrap-panic (map-get? data token-id)))
			)
			(map-set data token-id {
				metadata: (get metadata d),
				meta-type: (get meta-type d),
				prositive-votes: (+ (get prositive-votes d) u1),
				negative-votes: (get negative-votes d),
				prositive-points: (+ (get prositive-points d) points),
				negative-points: (get negative-points d)
				})
			(ok true)
		)
	)
)

(define-public (add-negative-vote (token-id uint) (points uint))
	(begin
		(asserts! (> points u0) ERR-PRECONDITION)
		(asserts! (<= token-id (var-get last-token-id)) ERR-TOKEN-NOT-EXIST)
		(asserts! (is-contract-manager) ERR-PERMISSION-DENIED)
		(let (
				(d (unwrap-panic (map-get? data token-id)))
			)
			(map-set data token-id {
				metadata: (get metadata d),
				meta-type: (get meta-type d),
				prositive-votes: (get prositive-votes d),
				negative-votes: (+ (get negative-votes d) u1),
				prositive-points: (get prositive-points d),
				negative-points: (+ (get negative-points d) points)
				})
			(ok true)
		)
	)
)

(define-public (swap-vote-to-negative (token-id uint) (points uint))
	(begin
		(asserts! (> points u0) ERR-PRECONDITION)
		(asserts! (<= token-id (var-get last-token-id)) ERR-TOKEN-NOT-EXIST)
		(asserts! (is-contract-manager) ERR-PERMISSION-DENIED)
		(let (
				(d (unwrap-panic (map-get? data token-id)))
			)
			(map-set data token-id {
				metadata: (get metadata d),
				meta-type: (get meta-type d),
				prositive-votes: (- (get prositive-votes d) u1),
				negative-votes: (+ (get negative-votes d) u1),
				prositive-points: (- (get prositive-points d) points),
				negative-points: (+ (get negative-points d) points)
				})
			(ok true)
		)
	)
)

(define-public (swap-vote-to-positive (token-id uint) (points uint))
	(begin
		(asserts! (> points u0) ERR-PRECONDITION)
		(asserts! (<= token-id (var-get last-token-id)) ERR-TOKEN-NOT-EXIST)
		(asserts! (is-contract-manager) ERR-PERMISSION-DENIED)
		(let (
				(d (unwrap-panic (map-get? data token-id)))
			)
			(map-set data token-id {
				metadata: (get metadata d),
				meta-type: (get meta-type d),
				prositive-votes: (+ (get prositive-votes d) u1),
				negative-votes: (- (get negative-votes d) u1),
				prositive-points: (+ (get prositive-points d) points),
				negative-points: (- (get negative-points d) points)
				})
			(ok true)
		)
	)
)