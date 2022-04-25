(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

;; Non Fungible Token, using sip-009
(define-non-fungible-token Bitcoin-GOATs uint)

;; Storage
(define-map tokens-count principal uint)

;; Constants
(define-constant ERR-GOATS-MINTED-OUT u101)
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED u401)
(define-constant ERR-MINT-NOT-ENABLED (err u1004))
(define-constant ERR-METADATA-FROZEN (err u505))
(define-constant GOATS-LIMIT u200)

;;collection image .png SHA-256
(define-constant collection-proof-hash "fb5039abd714b32c000651f032586f14bddae71e74ed2e89fbe7f33d9a4223b4")

;;full metadata .json SHA-256
(define-constant metadata-proof-hash "22d58960bfddfa9fbc2c1641e49601b1b429c40ba9d95ffd77e56a703368979f")

;; Internal variables
(define-data-var last-id uint u0)
(define-data-var commission uint u500)
(define-data-var commission-sp uint u500)
(define-data-var ipfs-full-metadata (string-ascii 109) "ipfs://QmW8QEB7eBB9YvVU4fhN2EQy4hj4d88E9vYqd1d4YAEFJ3/full_metadata.json")
(define-data-var ipfs-root (string-ascii 77) "ipfs://QmW8QEB7eBB9YvVU4fhN2EQy4hj4d88E9vYqd1d4YAEFJ3/")
(define-data-var minting-enabled bool false)
(define-data-var metadata-frozen bool false)
;;Cost per mint in STX
(define-data-var cost-per-mint uint u66660000)
;;Cost per mint in SPAGHETTI
(define-data-var cost-per-mint-sp uint u1000000000)
;;Marketplace address
(define-data-var commission-address principal 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S)
(define-data-var commission-sp-address principal 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S)

;;SpaghettiPunk address 1
(define-data-var artist-address-sp principal 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH)
;;SpaghettiPunk address 1
(define-data-var artist-address-one principal 'SP2H3TTG3MQK9CEF59S7VQ86H4FX9CH596ZXSE2EK)
(define-data-var artist-payout-one uint u3400)
;;SpaghettiPunk address 2
(define-data-var artist-address-two principal 'SP3Y5WK0G9GMXS4YRNW9SSVEET0WFJM37X2SBEW99)
(define-data-var artist-payout-two uint u3300)
;;SpaghettiPunk address 3
(define-data-var artist-address-three principal 'SP217FZ8AZYTGPKMERWZ6FYRAK4ZZ6YHMJ7XQXGEV)
(define-data-var artist-payout-three uint u3300)

;; Gets the amount of tokens owned by the specified address.
(define-private (balance-of (account principal))
  (default-to u0 (map-get? tokens-count account))
)

;; Internal - Register token
(define-private (mint (new-owner principal))
  (let (
        (next-id (+ u1 (var-get last-id)))  
        (count (var-get last-id))
        (minted (if (is-some (map-get? tokens-count tx-sender)) (unwrap-panic (map-get? tokens-count tx-sender)) u0))
      )
      (asserts! (is-eq (var-get minting-enabled) true) ERR-MINT-NOT-ENABLED)
      (asserts! (< count GOATS-LIMIT) (err ERR-GOATS-MINTED-OUT))
      (asserts! (< minted u2) ERR-MINT-NOT-ENABLED)
        (match (stx-transfer? (var-get cost-per-mint) tx-sender (as-contract tx-sender))
          success (begin
            (try! (nft-mint? Bitcoin-GOATs next-id new-owner))
            (var-set last-id next-id)
            (map-set tokens-count tx-sender (+ u1 minted ))
            (try! (as-contract (stx-transfer? (/ (* (var-get cost-per-mint) (var-get commission)) u10000) (as-contract tx-sender) (var-get commission-address))))
            (try! (as-contract (stx-transfer? (/ (* (- (var-get cost-per-mint) (/ (* (var-get cost-per-mint) (var-get commission)) u10000)) (var-get artist-payout-one)) u10000) (as-contract tx-sender) (var-get artist-address-one))))
            (try! (as-contract (stx-transfer? (/ (* (- (var-get cost-per-mint) (/ (* (var-get cost-per-mint) (var-get commission)) u10000)) (var-get artist-payout-two)) u10000) (as-contract tx-sender) (var-get artist-address-two))))
            (try! (as-contract (stx-transfer? (/ (* (- (var-get cost-per-mint) (/ (* (var-get cost-per-mint) (var-get commission)) u10000)) (var-get artist-payout-three)) u10000) (as-contract tx-sender) (var-get artist-address-three))))
            (ok next-id)
          ) 
          error (err error)
          )
          )
)

(define-private (mint-in-sp (new-owner principal))
  (let (
        (next-id (+ u1 (var-get last-id)))  
        (count (var-get last-id))
        (minted (if (is-some (map-get? tokens-count tx-sender)) (unwrap-panic (map-get? tokens-count tx-sender)) u0))
      )
      (asserts! (is-eq (var-get minting-enabled) true) ERR-MINT-NOT-ENABLED)
      (asserts! (< count GOATS-LIMIT) (err ERR-GOATS-MINTED-OUT))
      (asserts! (< minted u2) ERR-MINT-NOT-ENABLED)
      (match (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.spaghetti transfer (var-get cost-per-mint-sp) tx-sender (as-contract tx-sender) (some 0x00))
          success (begin
            (print "start sp transfer")
            (try! (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.spaghetti transfer (/ (* (var-get  cost-per-mint-sp) (var-get commission-sp)) u10000) (as-contract tx-sender) (var-get commission-sp-address) (some 0x00))))
            (try! (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.spaghetti transfer (- (var-get cost-per-mint-sp) (/ (* (var-get cost-per-mint-sp) (var-get commission-sp)) u10000)) (as-contract tx-sender) (var-get artist-address-sp) (some 0x00))))
            (print "goat sp mint")
            (try! (nft-mint? Bitcoin-GOATs next-id new-owner))
            (var-set last-id next-id)
            (map-set tokens-count tx-sender (+ u1 minted ))
            (ok next-id)
          ) 
          error (err error)
          )
  )
)

;; Public functions

(define-public (claim-in-stx)
  (mint tx-sender)
)

(define-public (claim-two-in-stx)
  (begin
    (try! (mint tx-sender))
    (try! (mint tx-sender))
    (ok true)
  )
)

(define-public (claim-in-sp)
  (mint-in-sp tx-sender)
)

(define-public (claim-two-in-sp)
  (begin
    (try! (mint-in-sp tx-sender))
    (try! (mint-in-sp tx-sender))
    (ok true)
  )
)

;; Transfers tokens to a specified principal.
(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (if (and
        (is-eq tx-sender sender))
      ;; Make sure to replace MY-OWN-NFT
      (match (nft-transfer? Bitcoin-GOATs token-id sender recipient)
        success (ok success)
        error (err error))
      (err u500))
)
;; Set cost per mint in stx
(define-public (set-cost-per-mint (value uint))
  (if (is-eq tx-sender CONTRACT-OWNER)
    (ok (var-set cost-per-mint value))
    (err ERR-NOT-AUTHORIZED)
  )
)

;; Set cost per mint in SPAGHETTI
(define-public (set-cost-per-mint-sp (value uint))
  (if (is-eq tx-sender CONTRACT-OWNER)
    (ok (var-set cost-per-mint-sp value))
    (err ERR-NOT-AUTHORIZED)
  )
)

;; Allows contract owner to change commission price
(define-public (set-commission (value uint))
  (if (is-eq tx-sender CONTRACT-OWNER)
    (ok (var-set commission value))
    (err ERR-NOT-AUTHORIZED)
  )
)

;; Allows contract owner to change commission in SPAGHETTI if need be
(define-public (set-commission-sp (value uint))
  (if (is-eq tx-sender CONTRACT-OWNER)
    (ok (var-set commission-sp value))
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

;; Allows contract owner to change commission SPAGHETTI address if need be
(define-public (set-commission-sp-address (value principal))
  (if (is-eq tx-sender CONTRACT-OWNER)
    (ok (var-set commission-sp-address value))
    (err ERR-NOT-AUTHORIZED)
  )
)

;; Allows contract owner to change artist address if need be
(define-public (set-artist-address-sp (value principal))
  (if (is-eq tx-sender CONTRACT-OWNER)
    (ok (var-set artist-address-sp value))
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

(define-public (set-root-uri (single-uri (string-ascii 77)))
  (begin
          (asserts! (is-eq (var-get metadata-frozen) false) ERR-METADATA-FROZEN)
          (asserts! (is-eq tx-sender CONTRACT-OWNER) (err ERR-NOT-AUTHORIZED))
          (var-set ipfs-root single-uri)
          (ok true)
      )
)

(define-public (set-full-uri (full-uri (string-ascii 109)))
  (begin
          (asserts! (is-eq (var-get metadata-frozen) false) ERR-METADATA-FROZEN)
          (asserts! (is-eq tx-sender CONTRACT-OWNER) (err ERR-NOT-AUTHORIZED))
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

;; Transfers stx from contract to contract owner
(define-public (transfer-stx (address principal) (amount uint))
  (if (is-eq tx-sender CONTRACT-OWNER)
    (as-contract (stx-transfer? amount (as-contract tx-sender) address))
    (err ERR-NOT-AUTHORIZED)
  )
)

;; Transfers SPAGHETTI from contract to contract owner
(define-public (transfer-sp (address principal) (amount uint))
  (if (is-eq tx-sender CONTRACT-OWNER)
    (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.spaghetti transfer amount (as-contract tx-sender) address (some 0x00)))
    (err ERR-NOT-AUTHORIZED)
  )
)

;; Gets the owner of the specified token ID.
(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? Bitcoin-GOATs token-id)))

;; Gets mint price
(define-read-only (get-mint-price)
  (ok (var-get cost-per-mint)))

;; Gets mint price in SPAGHETTI
(define-read-only (get-mint-sp-price)
  (ok (var-get cost-per-mint-sp)))

;; Gets commission
(define-read-only (get-commission)
  (ok (/ (* (var-get cost-per-mint) (var-get commission)) u10000))
)
;; Gets commission-sp
(define-read-only (get-commission-sp)
  (ok (/ (* (var-get cost-per-mint-sp) (var-get commission-sp)) u10000))
)

;; Gets artist address
(define-read-only (get-artist-address-sp)
  (ok (var-get artist-address-sp)))

(define-read-only (get-artist-address-one)
  (ok (var-get artist-address-one)))

(define-read-only (get-artist-address-two)
  (ok (var-get artist-address-two)))

(define-read-only (get-artist-address-three)
  (ok (var-get artist-address-three)))

(define-read-only (get-last-token-id)
  (ok (var-get last-id)))

(define-read-only (get-contract-metadata)
  (ok (some (var-get ipfs-full-metadata)))
)

(define-read-only (get-token-uri (token-id uint))
    (ok (some (concat (concat (var-get ipfs-root) (unwrap-panic (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.conversion lookup token-id))) ".json")))
)