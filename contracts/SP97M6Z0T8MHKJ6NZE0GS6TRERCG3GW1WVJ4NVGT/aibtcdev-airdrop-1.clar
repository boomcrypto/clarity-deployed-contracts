(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-constant DEPLOYER tx-sender)

(define-data-var nextId uint u1)
(define-data-var url (string-ascii 256) "https://nft-ad-1.aibtc.dev/aibtcdev-1.json")

(define-non-fungible-token aibtcdev-1 uint)

(define-read-only (get-last-token-id) (ok (- (var-get nextId) u1)))
(define-read-only (get-token-uri (id uint)) (ok (some (var-get url) )))
(define-read-only (get-owner (id uint)) (ok (nft-get-owner? aibtcdev-1 id)))

(define-public (transfer (id uint) (from principal) (to principal))
  (if (or (is-eq from tx-sender) (is-eq from contract-caller))
    (nft-transfer? aibtcdev-1 id from to)
    (err u4)
  )
)

(define-public (burn (id uint) (from principal))
  (if (or (is-eq from tx-sender) (is-eq from contract-caller))
    (nft-burn? aibtcdev-1 id from)
    (err u4)
  )
)

(define-public (mint (to principal))
  (let ((id (var-get nextId)))
    (asserts! (is-eq DEPLOYER (get-standard-caller)) (err u401))
    (var-set nextId (+ id u1))
    (nft-mint? aibtcdev-1 id to)
  )
)

(define-public (set-url (new (string-ascii 256)))
  (if (is-eq DEPLOYER (get-standard-caller))
    (ok (var-set url new))
    (err u401)
  )
)

(define-public (airdrop (l1 (list 5000 principal)) (l2 (list 5000 principal)) (l3 (list 4995 principal)))
  (if (is-eq DEPLOYER (get-standard-caller))
    (ok (var-set nextId (fold drop l3 (fold drop l2 (fold drop l1 (var-get nextId))))))
    (err u401)
  )
)

(define-private (drop (to principal) (id uint))
  (begin (is-err (nft-mint? aibtcdev-1 id to)) (+ id u1))
)

(define-read-only (get-standard-caller)
  (let ((d (unwrap-panic (principal-destruct? contract-caller))))
    (unwrap-panic (principal-construct? (get version d) (get hash-bytes d)))
  )
)
