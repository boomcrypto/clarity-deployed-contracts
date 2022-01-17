(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(define-fungible-token wrapped-rewards)

(define-constant pool-scriptpubkey 0xa91413effebe0ea4bb45e35694f5a15bb5b96e851afb87)
(define-data-var reward-admin principal 'SP1K1A1PMGW2ZJCNF46NWZWHG8TS1D23EGH1KNK60)

(define-map rewards-by-tx (buff 1024) uint)
(define-map rewards-by-height uint {wrew: uint, ustx: uint})

(define-data-var last-price (tuple (amount uint) (height uint) (timestamp uint))
  {amount: u2813, height: u23481, timestamp: u1627462508})

;; total submitted btc rewards
(define-read-only (get-rewards-by-height (height uint))
  (ok (default-to {wrew: u0, ustx: u0} (map-get? rewards-by-height height))))

;; get the token balance of owner
(define-read-only (get-balance (owner principal))
  (ok (ft-get-balance wrapped-rewards owner)))

;; returns the total number of tokens
(define-read-only (get-total-supply)
  (ok (ft-get-supply wrapped-rewards)))

;; returns the token name
(define-read-only (get-name)
  (ok "Friedger Pool wrapped rewards"))

;; the symbol or "ticker" for this token
(define-read-only (get-symbol)
  (ok "FPWR"))

;; the number of decimals used
(define-read-only (get-decimals)
  (ok u8))

;; Transfers tokens to a recipient
(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (if (is-eq tx-sender sender)
    (begin
      (try! (ft-transfer? wrapped-rewards amount sender recipient))
      (print memo)
      (ok true)
    )
    (err u4)))

(define-public (get-token-uri)
  (ok (some u"https://pool.friedger.de/wrapped-rewards.json")))

;;
;; mint via btc transactions
;;

(define-private (map-update-rewards-by-height (height uint) (wrew-value uint) (ustx-value uint))
  (let ((rewards (map-get? rewards-by-height height)))
    (let ((wrew (default-to u0 (get wrew rewards)))
        (ustx (default-to u0 (get ustx rewards))))
      (map-set rewards-by-height height {wrew: (+ wrew-value wrew), ustx: (+ ustx-value ustx)}))))

(define-private (add-value (out {scriptPubKey: (buff 128), value: uint}) (result uint))
  (+ (get value out) result)
)

;; adds out entry to result list if the scriptPubKey matches,
;; also converts buff value to uint value
(define-private (find-outs (entry {scriptPubKey: (buff 128), value: (buff 8)}) (result (list 8 {scriptPubKey: (buff 128), value: uint})))
  (if (is-eq (get scriptPubKey entry) pool-scriptpubkey)
    (let ((value (get uint32 (unwrap-panic (contract-call? 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.clarity-bitcoin-lib-v1 read-uint32 {txbuff: (get value entry), index: u0})))))
      (unwrap-panic (as-max-len? (append result {scriptPubKey: (get scriptPubKey entry), value: value}) u8))
    )
    result))

(define-read-only (get-outs (tx {
    version: (buff 4),
    ins: (list 8
      {outpoint: {hash: (buff 32), index: (buff 4)}, scriptSig: (buff 256), sequence: (buff 4)}),
    outs: (list 8
      {value: (buff 8), scriptPubKey: (buff 128)}),
    locktime: (buff 4)}))
    (fold find-outs (get outs tx) (list)))

(define-read-only (get-tx-value (tx {
    version: (buff 4),
    ins: (list 8
      {outpoint: {hash: (buff 32), index: (buff 4)}, scriptSig: (buff 256), sequence: (buff 4)}),
    outs: (list 8
      {value: (buff 8), scriptPubKey: (buff 128)}),
    locktime: (buff 4)}))
    (fold add-value (get-outs tx) u0))

;; any user can submit a tx that contains a reward tx
(define-public (mint
    (block { version: (buff 4), parent: (buff 32), merkle-root: (buff 32), timestamp: (buff 4), nbits: (buff 4), nonce: (buff 4), height: uint })
    (tx {version: (buff 4),
      ins: (list 8
        {outpoint: {hash: (buff 32), index: (buff 4)}, scriptSig: (buff 256), sequence: (buff 4)}),
      outs: (list 8
        {value: (buff 8), scriptPubKey: (buff 128)}),
      locktime: (buff 4)})
    (proof { tx-index: uint, hashes: (list 12 (buff 32)), tree-depth: uint }))
  (let ((tx-buff (contract-call? 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.clarity-bitcoin-lib-v1 concat-tx tx)))
      (match (contract-call? 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.clarity-bitcoin-lib-v1 was-tx-mined block tx-buff proof)
        result (let ((value (get-tx-value tx))
                    (height (get height block)))
                (asserts! result ERR_VERIFICATION_FAILED)
                (asserts! (> value u0) ERR_TX_IGNORED)
                (asserts! (map-insert rewards-by-tx tx-buff value) ERR_ALREADY_DONE)
                (let ((ustx (* value (get-price height))))
                  (asserts! (map-update-rewards-by-height height value ustx) ERR_NATIVE_FAILURE)
                  (match (ft-mint? wrapped-rewards value (var-get reward-admin))
                    success (ok {value: value, ustx: ustx})
                    error (err (* error u2000)))))
        error (err (* error u1000)))))

(define-public (update-reward-admin (new-admin principal))
  (if (is-eq tx-sender (var-get reward-admin))
    (ok (var-set reward-admin new-admin))
    (err u403)))

;; price BTC/STX
(define-private (oracle-get-price)
  (contract-call? 'SPZ0RAC1EFTH949T4W2SYY6YBHJRMAF4ECT5A7DD.oracle-v1 get-price "artifix-binance" "STX-BTC")
)

(define-private (update (price (tuple (amount uint) (height uint) (timestamp uint))) (height uint))
  (if (> (get height (var-get last-price)) height)
    (var-set last-price price)
    false))

(define-private (get-price-at-height (height uint))
  (match (get-block-info? id-header-hash height)
    hash (match (at-block hash (oracle-get-price))
          price (begin
                  (update price height)
                  (some (get amount price)))
          none)
    none))

(define-private (get-price (height uint))
  (match (get-price-at-height height)
    price price
    (match (get-price-at-height (- height u1))
      price-1 price-1
      (match (get-price-at-height (- height u2))
        price-2 price-2
        (get amount (print (var-get last-price)))))))

(define-public (get-price-stx-btc (height uint))
  (ok (get-price height)))

(define-constant ERR_VERIFICATION_FAILED (err u1))
(define-constant ERR_FAILED_TO_PARSE_TX (err u2))
(define-constant ERR_INVALID_ID (err u3))
(define-constant ERR_TOO_EARLY (err u4))
(define-constant ERR_TX_VALUE_TOO_SMALL (err u5))
(define-constant ERR_TX_IGNORED (err u6))
(define-constant ERR_ALREADY_DONE (err u7))
(define-constant ERR_NO_STX_RECEIVER (err u8))
(define-constant ERR_FAILED_TO_GET_PRICE (err u9))
(define-constant ERR_NATIVE_FAILURE (err u99))
