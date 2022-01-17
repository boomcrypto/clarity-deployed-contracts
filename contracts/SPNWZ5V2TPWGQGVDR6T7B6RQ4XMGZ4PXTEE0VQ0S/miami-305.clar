;; 305
(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

;; Non Fungible Token, using sip-009
(define-non-fungible-token miami-305 uint)

;; Constants
(define-constant err-no-more-nfts u300)
(define-constant err-invalid-user u500)
(define-constant err-mint u600)

(define-constant COMM1 u700)
(define-constant COMM2 u300)

(define-constant DEPLOYER tx-sender)
(define-constant COMM_ADDR1 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S)
(define-constant COMM_ADDR2 'SP1XPG9QFX5M95G36SGN9R8YJ4KJ0JB7ZXNH892N6)

;; Internal variables
(define-data-var mint-limit uint u305)
(define-data-var last-id uint u1)
(define-data-var coin-price uint u30500)
(define-data-var stx-price uint u305000000)
(define-data-var artist-address principal 'SP36MS1XN52WCJGZTMT12XBH19PQ0EH2HH3JEFRQ3)
(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/QmYdYF6fGo7BpTmWFNnXeYdxECFPV3NYczFc8UpSnZSJc8/")
(define-data-var ipfs-change-enabled bool true)

(define-private (mint-many (orders (list 10 bool)) (is-stx bool) (total-price uint))
  (let (
      (last-nft-id (var-get last-id))
      (enabled (asserts! (<= last-nft-id (var-get mint-limit)) (err err-no-more-nfts)))
      (art-addr (var-get artist-address))
      (id-reached (fold mint-many-iter orders last-nft-id))
      (price (* total-price (- id-reached last-nft-id)))
      (total-commission1 (/ (* price COMM1) u10000))
      (total-commission2 (/ (* price COMM2) u10000))
      (total-artist (- price (+ total-commission1 total-commission2)))
    )
    (if (or (is-eq tx-sender art-addr) (is-eq tx-sender COMM_ADDR1))
      (var-set last-id id-reached)
      (begin
        (var-set last-id id-reached)
        (try! (transfer-funds is-stx price))
      )
    )
    (ok id-reached)
  )
)

(define-private (transfer-funds (is-stx bool) (price uint))
   (let (
      (art-addr (var-get artist-address))
      (total-commission1 (/ (* price COMM1) u10000))
      (total-commission2 (/ (* price COMM2) u10000))
      (total-artist (- price (+ total-commission1 total-commission2)))
    )
    (if is-stx
        (begin
            (try! (stx-transfer? total-artist tx-sender art-addr))
            (try! (stx-transfer? total-commission1 tx-sender COMM_ADDR1))
            (try! (stx-transfer? total-commission2 tx-sender COMM_ADDR2)))
        (begin
            (try! (contract-call? 'SP466FNC0P7JWTNM2R9T199QRZN1MYEDTAR0KP27.miamicoin-token transfer total-artist tx-sender art-addr none))
            (try! (contract-call? 'SP466FNC0P7JWTNM2R9T199QRZN1MYEDTAR0KP27.miamicoin-token transfer total-commission1 tx-sender COMM_ADDR1 none))
            (try! (contract-call? 'SP466FNC0P7JWTNM2R9T199QRZN1MYEDTAR0KP27.miamicoin-token transfer total-commission2 tx-sender COMM_ADDR2 none)))
    )
    (ok true)
  )
)

(define-private (mint-many-iter (ignore bool) (next-id uint))
  (if (<= next-id (var-get mint-limit))
    (begin
      (unwrap! (nft-mint? miami-305 next-id tx-sender) next-id)
      (+ next-id u1)
    )
    next-id
  )
)

(define-public (claim)
  (mint-many (list true) true (var-get stx-price))
)

(define-public (claim-five)
  (mint-many (list true true true true true) true (var-get stx-price))
)

(define-public (claim-ten)
  (mint-many (list true true true true true true true true true true) true (var-get stx-price))
)

(define-public (claim-coin)
  (mint-many (list true) false (var-get coin-price))
)

(define-public (claim-five-coin)
  (mint-many (list true true true true true) false (var-get coin-price))
)

(define-public (claim-ten-coin)
  (mint-many (list true true true true true true true true true true) false (var-get coin-price))
)

(define-public (set-artist-address (address principal))
  (begin
    (asserts! (is-eq tx-sender DEPLOYER) (err err-invalid-user))
    (ok (var-set artist-address address))
  )
)

(define-public (set-coin-price (price uint))
  (begin
    (asserts! (is-eq tx-sender DEPLOYER) (err err-invalid-user))
    (ok (var-set coin-price price))
  )
)

(define-public (set-stx-price (price uint))
  (begin
    (asserts! (is-eq tx-sender DEPLOYER) (err err-invalid-user))
    (ok (var-set stx-price price))
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
    (nft-transfer? miami-305 token-id sender recipient)
  )
)

;; read-only functions
(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? miami-305 token-id)))

(define-read-only (get-last-token-id)
  (ok (- (var-get last-id) u1)))

(define-read-only (get-token-uri (token-id uint))
    (ok (some (concat (concat (var-get ipfs-root) "{id}") ".json"))))
