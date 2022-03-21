;; indigo-act1b-music

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

;; Non Fungible Token, using sip-009
(define-non-fungible-token indigo-act1b-music uint)

;; Constants
(define-constant err-no-more-nfts u300)
(define-constant err-invalid-user u500)
(define-constant err-mint u600)
(define-constant err-paused u700)

(define-constant COMM u1000)

(define-constant DEPLOYER tx-sender)
(define-constant COMM-ADDR-1 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S)
(define-constant COMM-ADDR-2 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C)

;; Internal variables
(define-data-var mint-limit uint u150)
(define-data-var last-id uint u1)
(define-data-var total-price uint u40000000)
(define-data-var artist-address principal 'SP364J7EDJXRE1FPDZDABP9M58HPY4G88BFCP2HD0)
(define-data-var secondary-artist-address principal 'SP1EV6DEGJYN4NC4GS94MTXKF8PAQ5ZNA4QHJ2VZ6)
(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/QmXve6VfyeZS2YBveCMcLV6pkcHdEALWJprjvzxg69PkxU/")
(define-data-var ipfs-change-enabled bool true)
(define-data-var mint-paused bool true)

(define-private (mint-many (orders (list 10 bool)))
  (let (
      (last-nft-id (var-get last-id))
      (enabled (asserts! (<= last-nft-id (var-get mint-limit)) (err err-no-more-nfts)))
      (art-addr (var-get artist-address))
      (id-reached (fold mint-many-iter orders last-nft-id))
      (price (* (var-get total-price) (- id-reached last-nft-id)))
      (total-commission (/ (* price COMM) u10000))
      (total-artist (/ (* price (- u10000 u100 COMM)) u10000))
      (total-secondary-artist (/ (* price u100) u10000))
    )
    (asserts! (or (is-eq false (var-get mint-paused)) (is-eq tx-sender COMM-ADDR-1)) (err err-paused))
    (if (or (is-eq tx-sender art-addr) (is-eq tx-sender COMM-ADDR-1))
      (var-set last-id id-reached)
      (begin
        (var-set last-id id-reached)
        (try! (stx-transfer? total-artist tx-sender (var-get artist-address)))
        (try! (stx-transfer? total-secondary-artist tx-sender (var-get secondary-artist-address)))
        (try! (stx-transfer? (/ total-commission u2) tx-sender COMM-ADDR-1))
        (try! (stx-transfer? (/ total-commission u2) tx-sender COMM-ADDR-2))
      )
    )
    (ok last-nft-id)
  )
)

(define-private (mint-many-iter (ignore bool) (next-id uint))
  (if (<= next-id (var-get mint-limit))
    (begin
      (unwrap! (nft-mint? indigo-act1b-music next-id tx-sender) next-id)
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
    (nft-transfer? indigo-act1b-music token-id sender recipient)
  )
)

(define-public (toggle-pause)
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender COMM-ADDR-1)) (err err-invalid-user))
    (ok (var-set mint-paused (not (var-get mint-paused))))))

;; read-only functions
(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? indigo-act1b-music token-id)))

(define-read-only (get-last-token-id)
  (ok (- (var-get last-id) u1)))

(define-read-only (get-token-uri (token-id uint))
    (ok (some (concat (concat (var-get ipfs-root) "{id}") ".json"))))

