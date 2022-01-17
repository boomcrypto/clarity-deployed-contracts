(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(define-fungible-token wrapped-rewards)

(define-constant pool-admin 'SP1K1A1PMGW2ZJCNF46NWZWHG8TS1D23EGH1KNK60)
(define-constant pool-scriptpubkey 0xa91413effebe0ea4bb45e35694f5a15bb5b96e851afb87)
(define-map rewards-by-tx (buff 1024) uint)
(define-map rewards-by-cycle uint uint)

;; total submitted btc rewards
(define-read-only (get-rewards-by-cycle (cycle uint))
  (ok (default-to u0 (map-get? rewards-by-cycle cycle))))

;; get the token balance of owner
(define-read-only (get-balance (owner principal))
  (ok (ft-get-balance wrapped-rewards owner)))

;; returns the total number of tokens
(define-read-only (get-total-supply)
  (ok (ft-get-supply wrapped-rewards)))

;; returns the token name
(define-read-only (get-name)
  (ok "Friedger Pool xBTC rewards"))

;; the symbol or "ticker" for this token
(define-read-only (get-symbol)
  (ok "FPXR"))

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


;; Backport of .pox's burn-height-to-reward-cycle
(define-read-only (burn-height-to-reward-cycle (height uint))
    (let (
        (pox-info (unwrap-panic (contract-call? 'SP000000000000000000002Q6VF78.pox get-pox-info)))
    )
    (/ (- height (get first-burnchain-block-height pox-info)) (get reward-cycle-length pox-info))))

(define-private (map-update-cycle-rewards (height uint) (value uint))
  (let ((cycle (burn-height-to-reward-cycle height)))
    (map-set rewards-by-cycle cycle (+ value (default-to u0 (map-get? rewards-by-cycle cycle))))))

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
        result (let ((value (get-tx-value tx)))
                (asserts! result ERR_VERIFICATION_FAILED)
                (asserts! (> value u0) ERR_TX_IGNORED)
                (asserts! (map-insert rewards-by-tx tx-buff value) ERR_ALREADY_DONE)
                (asserts! (map-update-cycle-rewards (get height block) value) ERR_NATIVE_FAILURE)
                (ft-mint? wrapped-rewards value pool-admin))
        error (err (* error u1000)))))

(define-constant ERR_VERIFICATION_FAILED (err u1))
(define-constant ERR_FAILED_TO_PARSE_TX (err u2))
(define-constant ERR_INVALID_ID (err u3))
(define-constant ERR_TOO_EARLY (err u4))
(define-constant ERR_TX_VALUE_TOO_SMALL (err u5))
(define-constant ERR_TX_IGNORED (err u6))
(define-constant ERR_ALREADY_DONE (err u7))
(define-constant ERR_NO_STX_RECEIVER (err u8))
(define-constant ERR_NATIVE_FAILURE (err u99))
