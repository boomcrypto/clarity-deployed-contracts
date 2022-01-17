;; HODL The Line
(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token HTL uint)

;; Constants
(define-constant err-no-more-nfts u300)
(define-constant err-invalid-user u500)
(define-constant err-mint u600)

(define-constant COMM1 u700)
(define-constant COMM2 u300)
(define-constant COMM3 u8250)
(define-constant COMM4 u750)

(define-constant COMM_ADDR1 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S)
(define-constant COMM_ADDR2 'SP1PPPCP0Q0GZK3H23JAZSG4TYGYHC3KP81ZHSS3J)
(define-constant COMM_ADDR3 'SPWRS7QKQ3D41MY7MDAY2ZB1XRP7BQ8RFJPCK755)
(define-constant COMM_ADDR4 'SP1N1PV6KA878YDS1V6081TZZ7MY4XTG4KC0P3PC8)

(define-constant DEPLOYER tx-sender)
;; Internal variables
(define-data-var mint-limit uint u300)
(define-data-var last-id uint u1)
(define-data-var total-price uint u50000000)
(define-data-var the-mint principal tx-sender)
(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/QmSs1fQTrRJwSDrqmVPKVq6cgn7grAASzMHJXLKqWyqAye/")
(define-data-var ipfs-change-enabled bool true)

(define-private (mint-many (orders (list 10 bool)))
  (let (
      (last-nft-id (var-get last-id))
      (enabled (asserts! (<= last-nft-id (var-get mint-limit)) (err err-no-more-nfts)))
      (id-reached (fold mint-many-iter orders last-nft-id))
      (price (* (var-get total-price) (- id-reached last-nft-id)))
      (commission1 (/ (* price COMM1) u10000))
      (commission2 (/ (* price COMM2) u10000))
      (commission3 (/ (* price COMM3) u10000))
      (commission4 (/ (* price COMM4) u10000))
    )
    (if (is-eq tx-sender DEPLOYER)
      (var-set last-id id-reached)
      (begin
        (var-set last-id id-reached)
        (try! (stx-transfer? commission1 tx-sender COMM_ADDR1))
        (try! (stx-transfer? commission2 tx-sender COMM_ADDR2))
        (try! (stx-transfer? commission3 tx-sender COMM_ADDR3))
        (try! (stx-transfer? commission4 tx-sender COMM_ADDR4))
      )
    )
    (ok id-reached)
  )
)

(define-private (mint-many-iter (ignore bool) (next-id uint))
  (if (<= next-id (var-get mint-limit))
    (begin
      (unwrap! (nft-mint? HTL next-id tx-sender) next-id)
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
    (nft-transfer? HTL token-id sender recipient)
  )
)

;; read-only functions
(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? HTL token-id)))

(define-read-only (get-last-token-id)
  (ok (- (var-get last-id) u1)))

(define-read-only (get-token-uri (token-id uint))
    (ok (some (concat (concat (var-get ipfs-root) "{id}") ".json"))))

