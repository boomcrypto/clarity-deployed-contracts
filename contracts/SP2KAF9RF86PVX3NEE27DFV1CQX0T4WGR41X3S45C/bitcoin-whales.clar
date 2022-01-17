(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

;; Non Fungible Token, using sip-009
(define-non-fungible-token bitcoin-whales uint)

;; Storage
(define-map tokens-count
  principal
  uint)

;; Constants
(define-constant ERR-ALL-MINTED u101)
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED u401)
(define-constant ERR-MINT-NOT-ENABLED (err u1004))
(define-constant ERR-NOT-MINT-TIME (err u1001))
(define-constant ERR-METADATA-FROZEN (err u505))
(define-constant MINT-LIMIT u300)

;; Internal variables
(define-data-var last-id uint u0)
(define-data-var uri-prefix (string-ascii 256) "")
(define-data-var cost-per-mint uint u25000000)
(define-data-var commission uint u750)
(define-data-var total-commission uint u1500)
(define-data-var payout uint u0)
(define-data-var target-block uint u39010)
(define-data-var ipfs-full-metadata (string-ascii 106) "ipfs://placeholder")
(define-data-var ipfs-root (string-ascii 93) "ipfs://placeholder")
(define-data-var commission-address principal 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S)
(define-data-var artist-address-one principal 'SP2H3TTG3MQK9CEF59S7VQ86H4FX9CH596ZXSE2EK)
(define-data-var artist-payout-one uint u4000)
(define-data-var artist-address-two principal 'SP3Y5WK0G9GMXS4YRNW9SSVEET0WFJM37X2SBEW99)
(define-data-var artist-payout-two uint u3300)
(define-data-var artist-address-three principal 'SP217FZ8AZYTGPKMERWZ6FYRAK4ZZ6YHMJ7XQXGEV)
(define-data-var artist-payout-three uint u2700)

(define-data-var minting-enabled bool true)
(define-data-var metadata-frozen bool false)

(define-public (claim)
  (mint tx-sender))

(define-public (claim-five)
  (begin
    (try! (mint tx-sender))
    (try! (mint tx-sender))
    (try! (mint tx-sender))
    (try! (mint tx-sender))
    (try! (mint tx-sender))
    (ok true)
  )
)

(define-public (claim-ten)
  (begin
    (try! (mint tx-sender))
    (try! (mint tx-sender))
    (try! (mint tx-sender))
    (try! (mint tx-sender))
    (try! (mint tx-sender))
    (try! (mint tx-sender))
    (try! (mint tx-sender))
    (try! (mint tx-sender))
    (try! (mint tx-sender))
    (try! (mint tx-sender))
    (ok true)
  )
)

;; Gets the amount of tokens owned by the specified address.
(define-private (balance-of (account principal))
  (default-to u0 (map-get? tokens-count account)))

;; Internal - Register token
(define-private (mint (new-owner principal))
  (let (
        (next-id (+ u1 (var-get last-id)))  
        (count (var-get last-id))
        (target (var-get target-block))
      )
      (asserts! (is-eq (var-get minting-enabled) true) ERR-MINT-NOT-ENABLED)
      (asserts! (< count MINT-LIMIT) (err ERR-ALL-MINTED))
      (asserts! (>= block-height target) ERR-NOT-MINT-TIME)
        (match (stx-transfer? (var-get cost-per-mint) tx-sender (as-contract tx-sender))
          success (begin
            (try! (nft-mint? bitcoin-whales next-id new-owner))
            (var-set last-id next-id)
            (try! (as-contract (stx-transfer? (/ (* (var-get cost-per-mint) (var-get commission)) u10000) (as-contract tx-sender) CONTRACT-OWNER)))
            (try! (as-contract (stx-transfer? (/ (* (var-get cost-per-mint) (var-get commission)) u10000) (as-contract tx-sender) (var-get commission-address))))
                        (try! (as-contract (stx-transfer? (/ (* (- (var-get cost-per-mint) (/ (* (var-get cost-per-mint) (var-get total-commission)) u10000)) (var-get artist-payout-one)) u10000) (as-contract tx-sender) (var-get artist-address-one))))
            (try! (as-contract (stx-transfer? (/ (* (- (var-get cost-per-mint) (/ (* (var-get cost-per-mint) (var-get total-commission)) u10000)) (var-get artist-payout-two)) u10000) (as-contract tx-sender) (var-get artist-address-two))))
            (try! (as-contract (stx-transfer? (/ (* (- (var-get cost-per-mint) (/ (* (var-get cost-per-mint) (var-get total-commission)) u10000)) (var-get artist-payout-three)) u10000) (as-contract tx-sender) (var-get artist-address-three))))
            (ok next-id)
          ) 
          error (err error)
          )
          )
        )

;; Public functions

;; Allows contract owner to change mint price
(define-public (set-cost-per-mint (value uint))
  (if (is-eq tx-sender CONTRACT-OWNER)
    (ok (var-set cost-per-mint value))
    (err ERR-NOT-AUTHORIZED)
  )
)

;; Allows contract owner to change mint price
(define-public (set-commission (value uint))
  (if (is-eq tx-sender CONTRACT-OWNER)
    (ok (var-set commission value))
    (err ERR-NOT-AUTHORIZED)
  )
)

;; Allows contract owner to change mint price
(define-public (set-target-block (value uint))
  (if (is-eq tx-sender CONTRACT-OWNER)
    (ok (var-set target-block value))
    (err ERR-NOT-AUTHORIZED)
  )
)

;; Allows contract owner to change commission address if need be
(define-public (set-commission-address (value principal))
  (if (is-eq tx-sender CONTRACT-OWNER)
    (ok (var-set commission-address value))
    (err ERR-NOT-AUTHORIZED)
  )
)

;; Allows contract owner to change artist address if need be
(define-public (set-artist-address-one (value principal))
  (if (is-eq tx-sender CONTRACT-OWNER)
    (ok (var-set artist-address-one value))
    (err ERR-NOT-AUTHORIZED)
  )
)

;; Allows contract owner to change artist address if need be
(define-public (set-artist-address-two (value principal))
  (if (is-eq tx-sender CONTRACT-OWNER)
    (ok (var-set artist-address-two value))
    (err ERR-NOT-AUTHORIZED)
  )
)

;; Allows contract owner to change artist address if need be
(define-public (set-artist-address-three (value principal))
  (if (is-eq tx-sender CONTRACT-OWNER)
    (ok (var-set artist-address-three value))
    (err ERR-NOT-AUTHORIZED)
  )
)

;; Turn minting on
(define-public (set-minting-enabled)
  (if (is-eq tx-sender CONTRACT-OWNER)
    (ok (var-set minting-enabled true))
    (err ERR-NOT-AUTHORIZED)
  )
)

;; Turn minting off
(define-public (set-minting-disabled)
  (if (is-eq tx-sender CONTRACT-OWNER)
    (ok (var-set minting-enabled false))
    (err ERR-NOT-AUTHORIZED)
  )
)

(define-public (set-root-uri (single-uri (string-ascii 93)))
  (begin
          (asserts! (is-eq (var-get metadata-frozen) false) ERR-METADATA-FROZEN)
          (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-MINT-NOT-ENABLED)
          (var-set ipfs-root single-uri)
          (ok true)
      )
)

(define-public (set-full-uri (full-uri (string-ascii 106)))
  (begin
          (asserts! (is-eq (var-get metadata-frozen) false) ERR-METADATA-FROZEN)
          (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-MINT-NOT-ENABLED)
          (var-set ipfs-full-metadata full-uri)
          (ok true)
  )
)


;; Freeze metadata
(define-public (freeze-metadata)
  (if (is-eq tx-sender CONTRACT-OWNER)
    (ok (var-set metadata-frozen true))
    (err ERR-NOT-AUTHORIZED)
  )
)


;; Transfers tokens to a specified principal.
(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (if (and
        (is-eq tx-sender sender))
      ;; Make sure to replace MY-OWN-NFT
      (match (nft-transfer? bitcoin-whales token-id sender recipient)
        success (ok success)
        error (err error))
      (err u500)))

;; Transfers stx from contract to contract owner
(define-public (transfer-stx (address principal) (amount uint))
  (if (is-eq tx-sender CONTRACT-OWNER)
    (as-contract (stx-transfer? amount (as-contract tx-sender) address))
    (err ERR-NOT-AUTHORIZED)
  )
)

;; Gets the owner of the specified token ID.
(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? bitcoin-whales token-id)))

;; Gets mint price
(define-read-only (get-mint-price)
  (ok (var-get cost-per-mint)))

;; Gets commission
(define-read-only (get-commission)
  (ok (/ (* (var-get cost-per-mint) (var-get commission)) u10000))
)

;; Gets artist address
(define-read-only (get-artist-address-one)
  (ok (var-get artist-address-one)))

(define-read-only (get-artist-address-two)
  (ok (var-get artist-address-two)))

(define-read-only (get-artist-address-three)
  (ok (var-get artist-address-three)))

;; Gets the owner of the specified token ID.
(define-read-only (get-last-token-id)
  (ok (var-get last-id)))

(define-read-only (get-contract-metadata)
  (ok (some (var-get ipfs-full-metadata)))
)

(define-read-only (get-target-block)
  (ok (var-get target-block))
)

(define-read-only (get-current-block)
  (ok block-height)
)

(define-read-only (get-token-uri (token-id uint))
  (if (< token-id u5001)
    (ok (some (concat (concat (var-get ipfs-root) (unwrap-panic (contract-call? .conversion lookup token-id))) ".json")))
    (ok (some (concat (concat (var-get ipfs-root) (unwrap-panic (contract-call? .conversion-v2 lookup (- token-id u5001)))) ".json")))
    )
)