(use-trait non-fungible-token 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
(define-constant expiry u100)
(define-map swaps uint {sats: uint, btc-receiver: (buff 40), nft-id: uint, nft-receiver: principal, nft-sender: principal, when: uint, done: uint, nft: principal})
(define-data-var next-id uint u0)

(define-private (find-out (entry {scriptPubKey: (buff 128), value: (buff 8)}) (result {pubscriptkey: (buff 40), out: (optional {scriptPubKey: (buff 128), value: uint})}))
  (if (is-eq (get scriptPubKey entry) (get pubscriptkey result))
    (merge result {out: (some {scriptPubKey: (get scriptPubKey entry), value: (get uint32 (unwrap-panic (contract-call? 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.clarity-bitcoin-lib-v1 read-uint32 {txbuff: (get value entry), index: u0})))})})
    result))

(define-public (get-out-value (tx {
    version: (buff 4),
    ins: (list 8
      {outpoint: {hash: (buff 32), index: (buff 4)}, scriptSig: (buff 256), sequence: (buff 4)}),
    outs: (list 8
      {value: (buff 8), scriptPubKey: (buff 128)}),
    locktime: (buff 4)}) (pubscriptkey (buff 40)))
    (ok (fold find-out (get outs tx) {pubscriptkey: pubscriptkey, out: none})))

;; create a swap between btc and fungible token
(define-public (create-swap (sats uint) (btc-receiver (buff 40)) (nft-id uint) (nft-receiver principal) (nft <non-fungible-token>))
  (let ((id (var-get next-id)))
    (asserts! (map-insert swaps id
      {sats: sats, btc-receiver: btc-receiver, nft-id: nft-id, nft-receiver: nft-receiver,
        nft-sender: tx-sender, when: block-height, done: u0, nft: (contract-of nft)}) ERR_INVALID_ID)
    (var-set next-id (+ id u1))
    (match (contract-call? nft transfer nft-id tx-sender (as-contract tx-sender))
      success (ok id)
      error (err (* error u1000)))))

;; any user can cancle the swap after the expiry period
(define-public (cancel (id uint) (nft <non-fungible-token>))
  (let ((swap (unwrap! (map-get? swaps id) ERR_INVALID_ID)))
    (asserts! (is-eq (contract-of nft) (get nft swap)) ERR_INVALID_NFT)
    (asserts! (< (+ (get when swap) expiry) block-height) ERR_TOO_EARLY)
    (asserts! (is-eq (get done swap) u0) ERR_ALREADY_DONE)
    (asserts! (map-set swaps id (merge swap {done: u1})) ERR_NATIVE_FAILURE)
    (as-contract (contract-call? nft transfer (get nft-id swap) tx-sender (get nft-sender swap)))))

;; any user can submit a tx that contains the swap
(define-public (submit-swap
    (id uint)
    (block { version: (buff 4), parent: (buff 32), merkle-root: (buff 32), timestamp: (buff 4), nbits: (buff 4), nonce: (buff 4), height: uint })
    (tx {version: (buff 4),
      ins: (list 8
        {outpoint: {hash: (buff 32), index: (buff 4)}, scriptSig: (buff 256), sequence: (buff 4)}),
      outs: (list 8
        {value: (buff 8), scriptPubKey: (buff 128)}),
      locktime: (buff 4)})
    (proof { tx-index: uint, hashes: (list 12 (buff 32)), tree-depth: uint })
    (nft <non-fungible-token>))
  (let ((swap (unwrap! (map-get? swaps id) ERR_INVALID_ID))
    (tx-buff (contract-call? 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.clarity-bitcoin-lib-v1 concat-tx tx)))
    (match (contract-call? 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.clarity-bitcoin-lib-v1 was-tx-mined block tx-buff proof)
      result
        (begin
          (asserts! result ERR_VERIFICATION_FAILED)
          (asserts! (is-eq (get done swap) u0) ERR_ALREADY_DONE)
          (match (get out (unwrap! (get-out-value tx (get btc-receiver swap)) ERR_NATIVE_FAILURE))
            out (if (>= (get value out) (get sats swap))
              (begin
                    (asserts! (is-eq (contract-of nft) (get nft swap)) ERR_INVALID_NFT)
                    (asserts! (map-set swaps id (merge swap {done: u1})) ERR_NATIVE_FAILURE)
                    (as-contract (contract-call? nft transfer (get nft-id swap) tx-sender (get nft-receiver swap))))
              ERR_TX_VALUE_TOO_SMALL)
           ERR_TX_NOT_FOR_RECEIVER))
      error (err (* error u1000)))))

(define-constant ERR_VERIFICATION_FAILED (err u1))
(define-constant ERR_FAILED_TO_PARSE_TX (err u2))
(define-constant ERR_INVALID_ID (err u3))
(define-constant ERR_TOO_EARLY (err u4))
(define-constant ERR_TX_VALUE_TOO_SMALL (err u5))
(define-constant ERR_TX_NOT_FOR_RECEIVER (err u6))
(define-constant ERR_ALREADY_DONE (err u7))
(define-constant ERR_INVALID_NFT (err u8))
(define-constant ERR_NATIVE_FAILURE (err u99))
