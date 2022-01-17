;; trubit-rose

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

;; Non Fungible Token, using sip-009
(define-non-fungible-token trubit-rose uint)

;; Constants
(define-constant err-no-more-nfts u300)
(define-constant err-invalid-user u500)
(define-constant err-mint u600)

(define-constant COMM u1000)

(define-constant DEPLOYER tx-sender)
(define-constant COMM_ADDR 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S)

;; Internal variables
(define-data-var mint-limit uint u21)
(define-data-var last-id uint u1)
(define-data-var total-price uint u500000000)
(define-data-var artist-address principal 'SPM6EH61Y123Q9HMN48JQTRDQMWF7DTWB6HBC98W)
(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/QmS8zYSch4dszTabpWeHtgJV5eiZaZJGeu6oQ6zLHbpkBw/")
(define-data-var ipfs-change-enabled bool true)

(define-private (mint-many (orders (list 10 bool)))
  (let (
      (last-nft-id (var-get last-id))
      (enabled (asserts! (<= last-nft-id (var-get mint-limit)) (err err-no-more-nfts)))
      (art-addr (var-get artist-address))
      (id-reached (fold mint-many-iter orders last-nft-id))
      (price (* (var-get total-price) (- id-reached last-nft-id)))
      (total-commission (/ (* price COMM) u10000))
      (total-artist (- price total-commission))
    )
    (if (or (is-eq tx-sender art-addr) (is-eq tx-sender COMM_ADDR))
      (var-set last-id id-reached)
      (begin
        (var-set last-id id-reached)
        (try! (stx-transfer? total-artist tx-sender (var-get artist-address)))
        (try! (stx-transfer? total-commission tx-sender COMM_ADDR))
      )
    )
    (ok last-nft-id)
  )
)

(define-private (mint-many-iter (ignore bool) (next-id uint))
  (if (<= next-id (var-get mint-limit))
    (begin
      (unwrap! (nft-mint? trubit-rose next-id tx-sender) next-id)
      (+ next-id u1)
    )
    next-id
  )
)

(define-public (claim)
  (mint-many (list true))
)

(define-public (claim-five)
  (mint-many (list true true true true true))
)

(define-public (claim-ten)
  (mint-many (list true true true true true true true true true true))
)

(define-public (set-artist-address (address principal))
  (begin
    (asserts! (is-eq tx-sender DEPLOYER) (err err-invalid-user))
    (ok (var-set artist-address address))
  )
)

(define-public (set-price (price uint))
  (begin
    (asserts! (is-eq tx-sender DEPLOYER) (err err-invalid-user))
    (ok (var-set total-price price))
  )
)

(define-public (set-ipfs-root (new-ipfs-root (string-ascii 80)))
  (begin
    (asserts! (and (var-get ipfs-change-enabled) (is-eq tx-sender DEPLOYER)) (err err-invalid-user))
    (ok (var-set ipfs-root new-ipfs-root))
  )
)

(define-public (freeze-ipfs-root)
  (begin
    (asserts! (and (var-get ipfs-change-enabled) (is-eq tx-sender DEPLOYER)) (err err-invalid-user))
    (ok (var-set ipfs-change-enabled false))
  )
)

(define-public (set-mint-limit (new-limit uint))
  (begin
    (asserts! (is-eq tx-sender DEPLOYER) (err err-invalid-user))
    (ok (var-set mint-limit new-limit))
  )
)

(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) (err err-invalid-user))
    (nft-transfer? trubit-rose token-id sender recipient)
  )
)

;; read-only functions
(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? trubit-rose token-id)))

(define-read-only (get-last-token-id)
  (ok (- (var-get last-id) u1)))

(define-read-only (get-token-uri (token-id uint))
    (ok (some (concat (concat (var-get ipfs-root) "{id}") ".json"))))
