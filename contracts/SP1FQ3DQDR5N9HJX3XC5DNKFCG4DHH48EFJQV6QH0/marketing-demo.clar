(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
(define-constant err-not-token-owner (err u401))
(define-constant err-not-deployer (err u402))
(define-constant DEPLOYER tx-sender)

(define-data-var nextId uint u1)
(define-data-var url (string-ascii 256) "https://pdakhjpwkuwtadzmpnjm.supabase.co/storage/v1/object/public/uri/marketing-demo.json")

(define-non-fungible-token marketing-demo uint)

(define-read-only (get-last-token-id) (ok (- (var-get nextId) u1)))
(define-read-only (get-token-uri (id uint)) (ok (some (var-get url) )))
(define-read-only (get-owner (id uint)) (ok (nft-get-owner? marketing-demo id)))

(define-public (transfer (id uint) (from principal) (to principal))
    (begin
        (asserts! (is-eq tx-sender from) err-not-token-owner)
        (nft-transfer? marketing-demo id from to)
    )
)

(define-public (burn (id uint) (from principal))
  (if (or (is-eq from tx-sender) (is-eq from contract-caller))
    (nft-burn? marketing-demo id from)
    (err u401)
  )
)

(define-public (mint (to principal))
  (let ((id (var-get nextId)))
    (asserts! (is-eq DEPLOYER tx-sender) err-not-deployer)
    (var-set nextId (+ id u1))
    (nft-mint? marketing-demo id to)
  )
)

(define-public (set-url (new (string-ascii 256)))
  (if (is-eq DEPLOYER tx-sender)
    (ok (var-set url new))
    (err u401)
  )
)

(define-public (airdrop (l1 (list 5000 principal)) (l2 (list 5000 principal)) (l3 (list 4995 principal)))
  (if (is-eq DEPLOYER tx-sender)
    (ok (var-set nextId (fold drop l3 (fold drop l2 (fold drop l1 (var-get nextId))))))
    (err u401)
  )
)

(define-private (drop (to principal) (id uint))
  (begin (is-err (nft-mint? marketing-demo id to)) (+ id u1))
)