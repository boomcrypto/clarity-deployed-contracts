;; sample
(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token sample uint)

;; Constants
(define-constant err-mint u100)
(define-constant err-mint-not-active u200)
(define-constant err-no-more-nfts u300)
(define-constant err-invalid-user u500)
(define-constant CONTRACT-OWNER tx-sender)

(define-data-var commission-address principal 'SP3ZJP253DENMN3CQFEQSPZWY7DK35EH3SEH0J8PK)
(define-data-var artist-address principal 'SP3S21WY0A8YQK9MSHVW4E4YYTSE696MSHKR6YTAN)

;; Internal variables
(define-data-var mint-limit uint u2500)
(define-data-var commission uint u1000)
(define-data-var last-id uint u201)
(define-data-var mint-price uint u50000000)
(define-data-var mint-price-mia uint u10000)
(define-data-var mint-price-nyc uint u5400)
(define-data-var the-mint principal tx-sender)
(define-data-var ipfs-full (string-ascii 84) "ipfs://QmcqdRZ77vsxpHo4CK7jv4Qe3KkBHaP6Tbfvhme4ouMnZm/sample_")
(define-data-var ipfs-root (string-ascii 80) "ipfs://QmcqdRZ77vsxpHo4CK7jv4Qe3KkBHaP6Tbfvhme4ouMnZm/sample_")
(define-data-var ipfs-change-enabled bool true)
(define-data-var mint-status bool true)

;;STX Minter
(define-private (mint-many (orders (list 10 bool)) (currency (string-ascii 3)))
  (let (
      (last-nft-id (var-get last-id))
      (enabled (asserts! (<= last-nft-id (var-get mint-limit)) (err err-no-more-nfts)))
      (id-reached (fold mint-many-iter orders last-nft-id))
      (price (* (var-get mint-price) (- id-reached last-nft-id)))
      (price-mia (* (var-get mint-price-mia) (- id-reached last-nft-id)))
      (price-nyc (* (var-get mint-price-nyc) (- id-reached last-nft-id)))
      (payout (- price (/ (* price (var-get commission)) u10000)))
      (payout-mia (- price-mia (/ (* price-mia (var-get commission)) u10000)))
      (payout-nyc (- price-nyc (/ (* price-nyc (var-get commission)) u10000)))
      (commission1 (/ (* price (/ (var-get commission) u2)) u10000))
      (commission2 (/ (* price (/ (var-get commission) u2)) u10000))
      (commission1-mia (/ (* price-mia (/ (var-get commission) u2)) u10000))
      (commission2-mia (/ (* price-mia (/ (var-get commission) u2)) u10000))
      (commission1-nyc (/ (* price-nyc (/ (var-get commission) u2)) u10000))
      (commission2-nyc (/ (* price-nyc (/ (var-get commission) u2)) u10000))
    )
      (begin
        (var-set last-id id-reached)
        (if (is-eq currency "stx")
            (begin
                (print "mint in stx")
                (try! (stx-transfer? commission1 tx-sender CONTRACT-OWNER))
                (try! (stx-transfer? commission2 tx-sender (var-get commission-address)))
                (try! (stx-transfer? payout tx-sender (var-get artist-address)))
            )
            (if (is-eq currency "mia")
                (begin
                    (print "mint in mia")
                    (try! (contract-call? 'SP466FNC0P7JWTNM2R9T199QRZN1MYEDTAR0KP27.miamicoin-token transfer payout-mia tx-sender (var-get artist-address) (some 0x00)))
                    (try! (contract-call? 'SP466FNC0P7JWTNM2R9T199QRZN1MYEDTAR0KP27.miamicoin-token transfer commission1-mia tx-sender CONTRACT-OWNER (some 0x00)))
                    (try! (contract-call? 'SP466FNC0P7JWTNM2R9T199QRZN1MYEDTAR0KP27.miamicoin-token transfer commission2-mia tx-sender (var-get commission-address) (some 0x00)))
                )
                (begin
                    (print "mint in nyc")
                    (try! (contract-call? 'SP2H8PY27SEZ03MWRKS5XABZYQN17ETGQS3527SA5.newyorkcitycoin-token transfer payout-nyc tx-sender (var-get artist-address) (some 0x00)))
                    (try! (contract-call? 'SP2H8PY27SEZ03MWRKS5XABZYQN17ETGQS3527SA5.newyorkcitycoin-token transfer commission1-nyc tx-sender CONTRACT-OWNER (some 0x00)))
                    (try! (contract-call? 'SP2H8PY27SEZ03MWRKS5XABZYQN17ETGQS3527SA5.newyorkcitycoin-token transfer commission2-nyc tx-sender (var-get commission-address) (some 0x00)))
                )
            )
        )
      )
    (ok id-reached)
  )
)

(define-private (mint-many-iter (ignore bool) (next-id uint))
  (if (<= next-id (var-get mint-limit))
    (begin
      (unwrap! (nft-mint? sample next-id tx-sender) next-id)
      (+ next-id u1)
    )
    next-id
  )
)

(define-public (mint (orders (list 10 bool)) (currency (string-ascii 3)))
  (begin
    (asserts! (is-eq (var-get mint-status) true) (err err-mint-not-active))
    (asserts! (or (is-eq contract-caller (var-get the-mint)) (is-eq tx-sender CONTRACT-OWNER)) (err err-invalid-user))
    (mint-many orders currency)
  )
)

;; Allows contract owner to change commission address if need be
(define-public (set-commission-address (value principal))
  (if (is-eq tx-sender CONTRACT-OWNER)
    (ok (var-set commission-address value))
    (err err-invalid-user)
  )
)

;; Allows contract owner to change artist address if need be
(define-public (set-artist-address (value principal))
  (if (is-eq tx-sender CONTRACT-OWNER)
    (ok (var-set artist-address value))
    (err err-invalid-user)
  )
)

(define-public (set-commission (amount uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) (err err-invalid-user))
    (ok (var-set commission amount))
  )
)

(define-public (set-price (price uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) (err err-invalid-user))
    (ok (var-set mint-price price))
  )
)

(define-public (set-mia-price (price uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) (err err-invalid-user))
    (ok (var-set mint-price-mia price))
  )
)

(define-public (set-nyc-price (price uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) (err err-invalid-user))
    (ok (var-set mint-price-nyc price))
  )
)

(define-public (set-ipfs-full (new-ipfs-full (string-ascii 84)))
  (begin
    (asserts! (and (var-get ipfs-change-enabled) (is-eq tx-sender CONTRACT-OWNER)) (err err-invalid-user))
    (ok (var-set ipfs-full new-ipfs-full))
  )
)

(define-public (set-ipfs-root (new-ipfs-root (string-ascii 80)))
  (begin
    (asserts! (and (var-get ipfs-change-enabled) (is-eq tx-sender CONTRACT-OWNER)) (err err-invalid-user))
    (ok (var-set ipfs-root new-ipfs-root))
  )
)

(define-public (freeze-ipfs-root)
  (begin
    (asserts! (and (var-get ipfs-change-enabled) (is-eq tx-sender CONTRACT-OWNER)) (err err-invalid-user))
    (ok (var-set ipfs-change-enabled false))
  )
)

(define-public (set-mint-status (status bool))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) (err err-invalid-user))
    (ok (var-set mint-status status))
  )
)

(define-public (set-mint-addr (mint-addr principal) (sender principal))
  (begin
    (asserts! (is-eq sender CONTRACT-OWNER) (err err-invalid-user))
    (asserts! (is-eq tx-sender (var-get the-mint)) (err err-invalid-user))
    (ok (var-set the-mint mint-addr))
  )
)

(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) (err err-invalid-user))
    (nft-transfer? sample token-id sender recipient)
  )
)

;; read-only functions
(define-read-only (get-mint-price)
  (ok (var-get mint-price)))

(define-read-only (get-mint-price-mia)
  (ok (var-get mint-price-mia)))

(define-read-only (get-mint-price-nyc)
  (ok (var-get mint-price-nyc)))

(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? sample token-id)))

(define-read-only (get-last-token-id)
  (ok (- (var-get last-id) u1)))

(define-read-only (get-token-uri (token-id uint))
  (if (< token-id u5001)
    (ok (some (concat (concat (var-get ipfs-root) (unwrap-panic (contract-call? .conversion lookup token-id))) ".json")))
    (ok (some (concat (concat (var-get ipfs-root) (unwrap-panic (contract-call? .conversion-v2 lookup (- token-id u5001)))) ".json")))
    )
)

(begin
    (try! (nft-mint? sample u1 (var-get artist-address)))
    (try! (nft-mint? sample u2 (var-get artist-address)))
    (try! (nft-mint? sample u3 (var-get artist-address)))
    (try! (nft-mint? sample u4 (var-get artist-address)))
    (try! (nft-mint? sample u5 (var-get artist-address)))
    (ok true)
)