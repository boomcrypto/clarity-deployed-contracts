;; Trubit Domino
(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token trubit-domino uint)

;; Constants
(define-constant err-no-more-nfts u300)
(define-constant err-invalid-user u500)
(define-constant err-mint u600)

(define-constant COMM1 u1000)
(define-constant COMM2 u9000)

(define-constant COMM_ADDR1 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S)
(define-constant COMM_ADDR2 'SPM6EH61Y123Q9HMN48JQTRDQMWF7DTWB6HBC98W)

(define-constant DEPLOYER tx-sender)
;; Internal variables
(define-data-var mint-limit uint u250)
(define-data-var last-id uint u1)
(define-data-var total-price uint u100000000)
(define-data-var the-mint principal tx-sender)
(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/QmRbfZga4wWbhpyYM4X7biLasMk2zynyKBu54V4emdjAsF/")
(define-data-var ipfs-change-enabled bool true)

(define-private (mint-many (orders (list 10 bool)))
  (let (
      (last-nft-id (var-get last-id))
      (enabled (asserts! (<= last-nft-id (var-get mint-limit)) (err err-no-more-nfts)))
      (id-reached (fold mint-many-iter orders last-nft-id))
      (price (* (var-get total-price) (- id-reached last-nft-id)))
      (commission1 (/ (* price COMM1) u10000))
      (commission2 (/ (* price COMM2) u10000))
    )
    (if (is-eq tx-sender DEPLOYER)
      (var-set last-id id-reached)
      (begin
        (var-set last-id id-reached)
        (try! (stx-transfer? commission1 tx-sender COMM_ADDR1))
        (try! (stx-transfer? commission2 tx-sender COMM_ADDR2))
      )
    )
    (ok id-reached)
  )
)

(define-private (mint-many-iter (ignore bool) (next-id uint))
  (if (<= next-id (var-get mint-limit))
    (begin
      (unwrap! (nft-mint? trubit-domino next-id tx-sender) next-id)
      (+ next-id u1)
    )
    next-id
  )
)

(define-public (mint (orders (list 10 bool)))
  (begin
    (asserts! (is-eq contract-caller (var-get the-mint)) (err err-invalid-user))
    (mint-many orders)
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

(define-public (set-mint-addr (mint-addr principal))
  (begin
    (asserts! (is-eq tx-sender (var-get the-mint)) (err err-invalid-user))
    (ok (var-set the-mint mint-addr))
  )
)

(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) (err err-invalid-user))
    (nft-transfer? trubit-domino token-id sender recipient)
  )
)

;; read-only functions
(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? trubit-domino token-id)))

(define-read-only (get-last-token-id)
  (ok (- (var-get last-id) u1)))

(define-read-only (get-token-uri (token-id uint))
    (ok (some (concat (concat (var-get ipfs-root) "{id}") ".json"))))