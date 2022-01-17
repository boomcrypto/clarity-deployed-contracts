(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

;; Non Fungible Token, using sip-009
(define-non-fungible-token test-nfts uint)

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
(define-constant MINT-LIMIT u100)

;; Internal variables
(define-data-var last-id uint u0)
(define-data-var uri-prefix (string-ascii 256) "")
(define-data-var cost-per-mint uint u45000000)
(define-data-var cost-per-mint-mia uint u3000)
(define-data-var commission-per-mint-mia uint u120)
(define-data-var cost-per-mint-nyc uint u3000)
(define-data-var commission-per-mint-nyc uint u120)
(define-data-var commission uint u400)
(define-data-var payout uint u0)
(define-data-var target-block uint u100)
(define-data-var metadata-frozen bool false)
(define-data-var ipfs-full-metadata (string-ascii 106) "https://byzantion.xyz/api/test_nfts/")
(define-data-var ipfs-root (string-ascii 93) "https://byzantion.xyz/api/test_nfts/")
(define-data-var artist-address principal 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C)
(define-data-var commission-address principal 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S)


(define-data-var minting-enabled bool true)

(define-public (claim)
  (mint tx-sender))

(define-public (claim-two)
  (begin
    (try! (mint tx-sender))
    (try! (mint tx-sender))
    (ok true)
  )
)

(define-public (claim-three)
  (begin
    (try! (mint tx-sender))
    (try! (mint tx-sender))
    (try! (mint tx-sender))
    (ok true)
  )
)

(define-public (claim-four)
  (begin
    (try! (mint tx-sender))
    (try! (mint tx-sender))
    (try! (mint tx-sender))
    (try! (mint tx-sender))
    (ok true)
  )
)

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

(define-public (claim-six)
  (begin
    (try! (mint tx-sender))
    (try! (mint tx-sender))
    (try! (mint tx-sender))
    (try! (mint tx-sender))
    (try! (mint tx-sender))
    (try! (mint tx-sender))
    (ok true)
  )
)

(define-public (claim-seven)
  (begin
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

(define-public (claim-eight)
  (begin
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

(define-public (claim-nine)
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

(define-public (claim-nyc)
  (mint-in-nyc tx-sender))

(define-public (claim-nyc-two)
  (begin
    (try! (mint-in-nyc tx-sender))
    (try! (mint-in-nyc tx-sender))
    (ok true)
  )
)

(define-public (claim-nyc-three)
  (begin
    (try! (mint-in-nyc tx-sender))
    (try! (mint-in-nyc tx-sender))
    (try! (mint-in-nyc tx-sender))
    (ok true)
  )
)

(define-public (claim-nyc-four)
  (begin
    (try! (mint-in-nyc tx-sender))
    (try! (mint-in-nyc tx-sender))
    (try! (mint-in-nyc tx-sender))
    (try! (mint-in-nyc tx-sender))
    (ok true)
  )
)

(define-public (claim-nyc-five)
  (begin
    (try! (mint-in-nyc tx-sender))
    (try! (mint-in-nyc tx-sender))
    (try! (mint-in-nyc tx-sender))
    (try! (mint-in-nyc tx-sender))
    (try! (mint-in-nyc tx-sender))
    (ok true)
  )
)

(define-public (claim-nyc-six)
  (begin
    (try! (mint-in-nyc tx-sender))
    (try! (mint-in-nyc tx-sender))
    (try! (mint-in-nyc tx-sender))
    (try! (mint-in-nyc tx-sender))
    (try! (mint-in-nyc tx-sender))
    (try! (mint-in-nyc tx-sender))
    (ok true)
  )
)

(define-public (claim-nyc-seven)
  (begin
    (try! (mint-in-nyc tx-sender))
    (try! (mint-in-nyc tx-sender))
    (try! (mint-in-nyc tx-sender))
    (try! (mint-in-nyc tx-sender))
    (try! (mint-in-nyc tx-sender))
    (try! (mint-in-nyc tx-sender))
    (try! (mint-in-nyc tx-sender))
    (ok true)
  )
)

(define-public (claim-nyc-eight)
  (begin
    (try! (mint-in-nyc tx-sender))
    (try! (mint-in-nyc tx-sender))
    (try! (mint-in-nyc tx-sender))
    (try! (mint-in-nyc tx-sender))
    (try! (mint-in-nyc tx-sender))
    (try! (mint-in-nyc tx-sender))
    (try! (mint-in-nyc tx-sender))
    (try! (mint-in-nyc tx-sender))
    (ok true)
  )
)

(define-public (claim-nyc-nine)
  (begin
    (try! (mint-in-nyc tx-sender))
    (try! (mint-in-nyc tx-sender))
    (try! (mint-in-nyc tx-sender))
    (try! (mint-in-nyc tx-sender))
    (try! (mint-in-nyc tx-sender))
    (try! (mint-in-nyc tx-sender))
    (try! (mint-in-nyc tx-sender))
    (try! (mint-in-nyc tx-sender))
    (try! (mint-in-nyc tx-sender))
    (ok true)
  )
)

(define-public (claim-nyc-ten)
  (begin
    (try! (mint-in-nyc tx-sender))
    (try! (mint-in-nyc tx-sender))
    (try! (mint-in-nyc tx-sender))
    (try! (mint-in-nyc tx-sender))
    (try! (mint-in-nyc tx-sender))
    (try! (mint-in-nyc tx-sender))
    (try! (mint-in-nyc tx-sender))
    (try! (mint-in-nyc tx-sender))
    (try! (mint-in-nyc tx-sender))
    (try! (mint-in-nyc tx-sender))
    (ok true)
  )
)

(define-public (claim-mia)
  (mint-in-mia tx-sender))

(define-public (claim-mia-two)
  (begin
    (try! (mint-in-mia tx-sender))
    (try! (mint-in-mia tx-sender))
    (ok true)
  )
)

(define-public (claim-mia-three)
  (begin
    (try! (mint-in-mia tx-sender))
    (try! (mint-in-mia tx-sender))
    (try! (mint-in-mia tx-sender))
    (ok true)
  )
)

(define-public (claim-mia-four)
  (begin
    (try! (mint-in-mia tx-sender))
    (try! (mint-in-mia tx-sender))
    (try! (mint-in-mia tx-sender))
    (try! (mint-in-mia tx-sender))
    (ok true)
  )
)

(define-public (claim-mia-five)
  (begin
    (try! (mint-in-mia tx-sender))
    (try! (mint-in-mia tx-sender))
    (try! (mint-in-mia tx-sender))
    (try! (mint-in-mia tx-sender))
    (try! (mint-in-mia tx-sender))
    (ok true)
  )
)

(define-public (claim-mia-six)
  (begin
    (try! (mint-in-mia tx-sender))
    (try! (mint-in-mia tx-sender))
    (try! (mint-in-mia tx-sender))
    (try! (mint-in-mia tx-sender))
    (try! (mint-in-mia tx-sender))
    (try! (mint-in-mia tx-sender))
    (ok true)
  )
)

(define-public (claim-mia-seven)
  (begin
    (try! (mint-in-mia tx-sender))
    (try! (mint-in-mia tx-sender))
    (try! (mint-in-mia tx-sender))
    (try! (mint-in-mia tx-sender))
    (try! (mint-in-mia tx-sender))
    (try! (mint-in-mia tx-sender))
    (try! (mint-in-mia tx-sender))
    (ok true)
  )
)

(define-public (claim-mia-eight)
  (begin
    (try! (mint-in-mia tx-sender))
    (try! (mint-in-mia tx-sender))
    (try! (mint-in-mia tx-sender))
    (try! (mint-in-mia tx-sender))
    (try! (mint-in-mia tx-sender))
    (try! (mint-in-mia tx-sender))
    (try! (mint-in-mia tx-sender))
    (try! (mint-in-mia tx-sender))
    (ok true)
  )
)

(define-public (claim-mia-nine)
  (begin
    (try! (mint-in-mia tx-sender))
    (try! (mint-in-mia tx-sender))
    (try! (mint-in-mia tx-sender))
    (try! (mint-in-mia tx-sender))
    (try! (mint-in-mia tx-sender))
    (try! (mint-in-mia tx-sender))
    (try! (mint-in-mia tx-sender))
    (try! (mint-in-mia tx-sender))
    (try! (mint-in-mia tx-sender))
    (ok true)
  )
)

(define-public (claim-mia-ten)
  (begin
    (try! (mint-in-mia tx-sender))
    (try! (mint-in-mia tx-sender))
    (try! (mint-in-mia tx-sender))
    (try! (mint-in-mia tx-sender))
    (try! (mint-in-mia tx-sender))
    (try! (mint-in-mia tx-sender))
    (try! (mint-in-mia tx-sender))
    (try! (mint-in-mia tx-sender))
    (try! (mint-in-mia tx-sender))
    (try! (mint-in-mia tx-sender))
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
            (try! (nft-mint? test-nfts next-id new-owner))
            (var-set last-id next-id)
            (try! (as-contract (stx-transfer? (/ (* (var-get cost-per-mint) (var-get commission)) u10000) (as-contract tx-sender) CONTRACT-OWNER)))
            (try! (as-contract (stx-transfer? (/ (* (var-get cost-per-mint) (var-get commission)) u10000) (as-contract tx-sender) (var-get commission-address))))
            (try! (as-contract (stx-transfer? (- (var-get cost-per-mint) (/ (* (var-get cost-per-mint) (var-get commission)) u10000)) (as-contract tx-sender) (var-get artist-address))))
            (ok next-id)
          ) 
          error (err error)
          )
          )
        )

  (define-private (mint-in-mia (new-owner principal))
  (let (
        (next-id (+ u1 (var-get last-id)))  
        (count (var-get last-id))
        (target (var-get target-block))
      )
      (asserts! (is-eq (var-get minting-enabled) true) ERR-MINT-NOT-ENABLED)
      (asserts! (< count MINT-LIMIT) (err ERR-ALL-MINTED))
      (asserts! (>= block-height target) ERR-NOT-MINT-TIME)
      (match (stx-transfer? (var-get cost-per-mint) tx-sender (as-contract tx-sender))
        ;; (match (unwrap! (contract-call? 'SP466FNC0P7JWTNM2R9T199QRZN1MYEDTAR0KP27.miamicoin-token transfer (var-get cost-per-mint-mia) tx-sender (as-contract tx-sender) (some 0x00)) (err u102))
          success (begin
            ;; (try! (as-contract (unwrap! (contract-call? 'SP466FNC0P7JWTNM2R9T199QRZN1MYEDTAR0KP27.miamicoin-token transfer (- (var-get cost-per-mint-mia) (* (var-get commission-per-mint-mia) u2)) (as-contract tx-sender) artist-address (some 0x00)) (err u102))))
            ;; (try! (as-contract (unwrap! (contract-call? 'SP466FNC0P7JWTNM2R9T199QRZN1MYEDTAR0KP27.miamicoin-token transfer (var-get commission-per-mint-mia) (as-contract tx-sender) CONTRACT-OWNER (some 0x00)) (err u102))))
            ;; (try! (as-contract (unwrap! (contract-call? 'SP466FNC0P7JWTNM2R9T199QRZN1MYEDTAR0KP27.miamicoin-token transfer (var-get commission-per-mint-mia) (as-contract tx-sender) (var-get commission-address) (some 0x00)) (err u102))))
            (try! (nft-mint? test-nfts next-id new-owner))
            (var-set last-id next-id)
            (ok next-id)
          ) 
          error (err error)
          )
          )
        )

(define-private (mint-in-nyc (new-owner principal))
  (let (
        (next-id (+ u1 (var-get last-id)))  
        (count (var-get last-id))
        (target (var-get target-block))
      )
      (asserts! (is-eq (var-get minting-enabled) true) ERR-MINT-NOT-ENABLED)
      (asserts! (< count MINT-LIMIT) (err ERR-ALL-MINTED))
      (asserts! (>= block-height target) ERR-NOT-MINT-TIME)
        (begin
            (try! (contract-call? 'SP2H8PY27SEZ03MWRKS5XABZYQN17ETGQS3527SA5.newyorkcitycoin-token transfer (- (var-get cost-per-mint-nyc) (* (var-get commission-per-mint-nyc) u2)) tx-sender (var-get artist-address) (some 0x00)))
            (try! (contract-call? 'SP2H8PY27SEZ03MWRKS5XABZYQN17ETGQS3527SA5.newyorkcitycoin-token transfer (var-get commission-per-mint-nyc) tx-sender CONTRACT-OWNER (some 0x00)))
            (try! (contract-call? 'SP2H8PY27SEZ03MWRKS5XABZYQN17ETGQS3527SA5.newyorkcitycoin-token transfer (var-get commission-per-mint-nyc) tx-sender (var-get commission-address) (some 0x00)))
            (mint-helper new-owner next-id))
          )
        )

(define-private (mint-helper (new-owner principal) (next-id uint))
    (match (nft-mint? test-nfts next-id new-owner)
            success
              (begin
                (var-set last-id next-id)
                (ok true))
            error (err error)))

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
(define-public (set-cost-per-mint-mia (value uint))
  (if (is-eq tx-sender CONTRACT-OWNER)
    (ok (var-set cost-per-mint-mia value))
    (err ERR-NOT-AUTHORIZED)
  )
)

;; Allows contract owner to change mint price
(define-public (set-commission-mia (value uint))
  (if (is-eq tx-sender CONTRACT-OWNER)
    (ok (var-set commission-per-mint-mia value))
    (err ERR-NOT-AUTHORIZED)
  )
)

;; Allows contract owner to change mint price
(define-public (set-cost-per-mint-nyc (value uint))
  (if (is-eq tx-sender CONTRACT-OWNER)
    (ok (var-set cost-per-mint-nyc value))
    (err ERR-NOT-AUTHORIZED)
  )
)

;; Allows contract owner to change mint price
(define-public (set-commission-nyc (value uint))
  (if (is-eq tx-sender CONTRACT-OWNER)
    (ok (var-set commission-per-mint-nyc value))
    (err ERR-NOT-AUTHORIZED)
  )
)

;; Allows contract owner to change artist address if need be
(define-public (set-artist-address (value principal))
  (if (is-eq tx-sender CONTRACT-OWNER)
    (ok (var-set artist-address value))
    (err ERR-NOT-AUTHORIZED)
  )
)

;; Allows contract owner to change artist address if need be
(define-public (set-mint-time (value uint))
  (if (is-eq tx-sender CONTRACT-OWNER)
    (ok (var-set target-block value))
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
      (match (nft-transfer? test-nfts token-id sender recipient)
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
  (ok (nft-get-owner? test-nfts token-id)))

;; Gets mint price
(define-read-only (get-mint-price)
  (ok (var-get cost-per-mint)))

;; Gets commission
(define-read-only (get-commission)
  (ok (/ (* (var-get cost-per-mint) (var-get commission)) u10000))
)

;; Gets artist address
(define-read-only (get-artist-address)
  (ok (var-get artist-address)))

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
    (ok (some (concat (var-get ipfs-root) (unwrap-panic (contract-call? .conversion lookup token-id)))))
    (ok (some (concat (var-get ipfs-root) (unwrap-panic (contract-call? .conversion-v2 lookup (- token-id u5001))))))
    )
)