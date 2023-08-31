(define-map supplier-by-id uint {
  public-key: (buff 33),
  controller: principal,
  inbound-fee: (optional int),
  outbound-fee: (optional int),
  outbound-base-fee: int,
  inbound-base-fee: int,
})
(define-map supplier-by-public-key (buff 33) uint)
(define-map supplier-by-controller principal uint)

(define-map swapper-by-id uint principal)
(define-map swapper-by-principal principal uint)

;; amount of xBTC funds per supplier
;; supplier-id -> xBTC (sats)
(define-map supplier-funds uint uint)
;; amount of xBTC funds in escrow per supplier
;; supplier-id -> xBTC
(define-map supplier-escrow uint uint)

(define-map inbound-swaps (buff 32) {
  swapper: principal,
  xbtc: uint,
  supplier: uint,
  expiration: uint,
  hash: (buff 32),
})

;; extra info for inbound swaps - not needed for the `finalize` step
(define-map inbound-meta (buff 32) {
  sender-public-key: (buff 33),
  output-index: uint,
  csv: uint,
  sats: uint,
  redeem-script: (buff 148),
})
;; mapping of txid -> preimage
(define-map inbound-preimages (buff 32) (buff 128))

(define-map outbound-swaps uint {
  swapper: principal,
  sats: uint,
  xbtc: uint,
  supplier: uint,
  output: (buff 128),
  created-at: uint,
})
;; mapping of swap -> txid
(define-map completed-outbound-swaps uint (buff 32))
(define-map completed-outbound-swap-txids (buff 32) uint)

;; tracking of total volume
(define-map user-inbound-volume-map principal uint)
(define-data-var total-inbound-volume-var uint u0)

(define-map user-outbound-volume-map principal uint)
(define-data-var total-outbound-volume-var uint u0)

(define-data-var next-supplier-id uint u0)
(define-data-var next-swapper-id uint u0)
(define-data-var next-outbound-id uint u0)

(define-constant MIN_EXPIRATION u250)
(define-constant ESCROW_EXPIRATION u200)
(define-constant OUTBOUND_EXPIRATION u200)
(define-constant MAX_HTLC_EXPIRATION u550)

(define-constant P2PKH_VERSION 0x00)
(define-constant P2SH_VERSION 0x05)

;; use a placeholder txid to mark as "finalized"
(define-constant REVOKED_OUTBOUND_TXID 0x00)
;; placeholder to mark inbound swap as revoked
(define-constant REVOKED_INBOUND_PREIMAGE 0x00)

(define-constant ERR_SUPPLIER_EXISTS (err u2))
(define-constant ERR_UNAUTHORIZED (err u3))
(define-constant ERR_ADD_FUNDS (err u4))
(define-constant ERR_TRANSFER (err u5))
(define-constant ERR_SUPPLIER_NOT_FOUND (err u6))
(define-constant ERR_SWAPPER_NOT_FOUND (err u7))
(define-constant ERR_FEE_INVALID (err u8))
(define-constant ERR_SWAPPER_EXISTS (err u9))
(define-constant ERR_INVALID_TX (err u10))
(define-constant ERR_INVALID_OUTPUT (err u11))
(define-constant ERR_INVALID_HASH (err u12))
(define-constant ERR_INVALID_SUPPLIER (err u13))
(define-constant ERR_INSUFFICIENT_FUNDS (err u14))
(define-constant ERR_INVALID_EXPIRATION (err u15))
(define-constant ERR_TXID_USED (err u16))
(define-constant ERR_ALREADY_FINALIZED (err u17))
(define-constant ERR_INVALID_ESCROW (err u18))
(define-constant ERR_INVALID_PREIMAGE (err u19))
(define-constant ERR_ESCROW_EXPIRED (err u20))
(define-constant ERR_TX_NOT_MINED (err u21))
(define-constant ERR_INVALID_BTC_ADDR (err u22))
(define-constant ERR_SWAP_NOT_FOUND (err u23))
(define-constant ERR_INSUFFICIENT_AMOUNT (err u24))
(define-constant ERR_REVOKE_OUTBOUND_NOT_EXPIRED (err u25))
(define-constant ERR_REVOKE_OUTBOUND_IS_FINALIZED (err u26))
(define-constant ERR_INCONSISTENT_FEES (err u27))
(define-constant ERR_REVOKE_INBOUND_NOT_EXPIRED (err u28))
(define-constant ERR_REVOKE_INBOUND_IS_FINALIZED (err u29))


;; Register a supplier and add funds.
;; Validates that the public key and "controller" (STX address) are not
;; in use for another controller.
;;
;; @returns the newly generated supplier ID.
;; 
;; @param public-key; the public key used in HTLCs
;; @param inbound-fee; optional fee (in basis points) for inbound swaps
;; @param outbound-fee; optional fee (in basis points) for outbound
;; @param outbound-base-fee; fixed fee applied to outbound swaps (in xBTC sats)
;; @param inbound-base-fee; fixed fee for inbound swaps (in BTC/sats)
;; @param funds; amount of xBTC (sats) to initially supply
(define-public (register-supplier
    (public-key (buff 33))
    (inbound-fee (optional int))
    (outbound-fee (optional int))
    (outbound-base-fee int)
    (inbound-base-fee int)
    (funds uint)
  )
  (let
    (
      (id (var-get next-supplier-id))
      (supplier { 
        inbound-fee: inbound-fee, 
        outbound-fee: outbound-fee, 
        public-key: public-key, 
        controller: tx-sender, 
        outbound-base-fee: outbound-base-fee,
        inbound-base-fee: inbound-base-fee,
      })
    )
    (map-insert supplier-by-id id supplier)
    (map-insert supplier-funds id u0)
    (map-insert supplier-escrow id u0)
    (try! (validate-fee inbound-fee))
    (try! (validate-fee outbound-fee))

    ;; validate that the public key and controller do not exist
    (asserts! (map-insert supplier-by-public-key public-key id) ERR_SUPPLIER_EXISTS)
    (asserts! (map-insert supplier-by-controller tx-sender id) ERR_SUPPLIER_EXISTS)
    (var-set next-supplier-id (+ id u1))
    (try! (add-funds funds))
    (ok id)
  )
)

;; As a supplier, add funds.
;; The `supplier-id` is automatically looked up from the `contract-caller` (tx-sender).
;;
;; @returns the new amount of funds pooled for this supplier
;;
;; @param amount; the amount of funds to add (in xBTC/sats)
(define-public (add-funds (amount uint))
  (let
    (
      ;; #[filter(amount, new-funds)]
      (supplier-id (unwrap! (get-supplier-id-by-controller contract-caller) ERR_UNAUTHORIZED))
      (existing-funds (get-funds supplier-id))
      (new-funds (+ amount existing-funds))
    )
    (try! (transfer amount tx-sender (as-contract tx-sender)))
    (map-set supplier-funds supplier-id new-funds)
    (ok new-funds)
  )
)

;; As a supplier, remove funds.
;;
;; @returns the new amount of funds pooled for this supplier.
;;
;; @param amount; the amount of funds to remove (in xBTC/sats)
(define-public (remove-funds (amount uint))
  (let
    (
      (supplier-id (unwrap! (get-supplier-id-by-controller contract-caller) ERR_UNAUTHORIZED))
      (existing-funds (get-funds supplier-id))
      (amount-ok (asserts! (>= existing-funds amount) ERR_INSUFFICIENT_FUNDS))
      (new-funds (- existing-funds amount))
      (controller contract-caller)
    )
    (try! (as-contract (transfer amount tx-sender controller)))
    (map-set supplier-funds supplier-id new-funds)
    (ok new-funds)
  )
)

;; Update fees for a supplier
;;
;; @returns new metadata for supplier
;;
;; @param inbound-fee; optional fee (in basis points) for inbound swaps
;; @param outbound-fee; optional fee (in basis points) for outbound
;; @param outbound-base-fee; fixed fee applied to outbound swaps (in xBTC sats)
;; @param inbound-base-fee; fixed fee for inbound swaps (in BTC/sats)
(define-public (update-supplier-fees
    (inbound-fee (optional int))
    (outbound-fee (optional int))
    (outbound-base-fee int)
    (inbound-base-fee int)
  )
  (let
    (
      (supplier-id (unwrap! (get-supplier-id-by-controller contract-caller) ERR_UNAUTHORIZED))
      (existing-supplier (unwrap-panic (get-supplier supplier-id)))
      (new-supplier (merge existing-supplier {
        inbound-fee: inbound-fee, 
        outbound-fee: outbound-fee, 
        outbound-base-fee: outbound-base-fee,
        inbound-base-fee: inbound-base-fee,
      }))
    )
    (try! (validate-fee inbound-fee))
    (try! (validate-fee outbound-fee))
    (map-set supplier-by-id supplier-id new-supplier)
    (ok new-supplier)
  )
)

;; Update the public-key for a supplier
;;
;; @returns new metadata for the supplier
;;
;; @param public-key; the public key used in HTLCs
(define-public (update-supplier-public-key (public-key (buff 33)))
  (let
    (
      (supplier-id (unwrap! (get-supplier-id-by-controller contract-caller) ERR_UNAUTHORIZED))
      (existing-supplier (unwrap-panic (get-supplier supplier-id)))
      (new-supplier (merge existing-supplier {
        public-key: public-key,
      }))
    )
    (asserts! (map-insert supplier-by-public-key public-key supplier-id) ERR_SUPPLIER_EXISTS)
    (map-delete supplier-by-public-key (get public-key existing-supplier))
    (map-set supplier-by-id supplier-id new-supplier)
    (ok new-supplier)
  )
)

;; Reserve the funds from a supplier's account after the Bitcoin transaction is sent during an inbound swap.
;; The function validates the Bitcoin transaction by reconstructing the HTLC script and comparing it to the Bitcoin transaction.
;; It also ensures that the HTLC parameters (like expiration) are valid.
;; The `tx-sender` must be the same as the `swapper` embedded in the HTLC, ensuring that the `min-to-receive` parameter is provided by the end-user.
;;
;; @returns metadata regarding the escrowed swap (refer to `inbound-meta` map for fields)
;;
;; @param block; a tuple containing the `header` (Bitcoin block header) and `height` (Stacks block height) where the Bitcoin transaction was confirmed.
;; @param prev-blocks; due to the fact that Clarity contracts cannot access Bitcoin headers when there is no Stacks block, this parameter allows users to specify the chain of block headers going back to the block where the Bitcoin transaction was confirmed.
;; @param tx; the hex data of the Bitcoin transaction.
;; @param proof; a merkle proof to validate the inclusion of this transaction in the Bitcoin block.
;; @param output-index; the index of the HTLC output in the Bitcoin transaction.
;; @param sender; the swapper's public key used in the HTLC.
;; @param recipient; the supplier's public key used in the HTLC.
;; @param expiration-buff; a 4-byte buffer indicating the HTLC expiration.
;; @param hash; the hash of the `preimage` used in this swap.
;; @param swapper; the Stacks address receiving xBTC from this swap.
;; @param supplier-id; the ID of the supplier used in this swap.
;; @param max-base-fee; the maximum base fee that the supplier can charge.
;; @param max-fee-rate; the maximum fee rate that the supplier can charge.
;;
;; @throws ERR_TX_NOT_MINED if the transaction was not mined.
;; @throws ERR_INVALID_TX if the transaction is invalid.
;; @throws ERR_INVALID_SUPPLIER if the supplier is invalid.
;; @throws ERR_INSUFFICIENT_FUNDS if there are not enough funds for the swap.
;; @throws ERR_INVALID_OUTPUT if the output script does not match the HTLC script or if the supplier's public key does not match the recipient.
;; @throws ERR_INVALID_HASH if the hash length is not 32 bytes.
;; @throws ERR_TXID_USED if the transaction id has already been used.
;; @throws ERR_INCONSISTENT_FEES if the base fee or the fee rate are greater than the maximum allowed values.
(define-public (escrow-swap
    (block { header: (buff 80), height: uint })
    (prev-blocks (list 10 (buff 80)))
    (tx (buff 1024))
    (proof { tx-index: uint, hashes: (list 20 (buff 32)), tree-depth: uint })
    (output-index uint)
    (sender (buff 33))
    (recipient (buff 33))
    (expiration-buff (buff 4))
    (hash (buff 32))
    (swapper principal)
    (supplier-id uint)
    (max-base-fee int)
    (max-fee-rate int)
  )
  (let
    (
      (was-mined-bool (unwrap! (contract-call? .clarity-bitcoin was-tx-mined-prev? block prev-blocks tx proof) ERR_TX_NOT_MINED))
      (was-mined (asserts! was-mined-bool ERR_TX_NOT_MINED))
      (mined-height (get height block))
      (metadata (hash-metadata swapper max-base-fee max-fee-rate))
      (htlc-redeem (generate-htlc-script sender recipient expiration-buff hash metadata))
      (htlc-output (generate-wsh-output htlc-redeem))
      (parsed-tx (unwrap! (contract-call? .clarity-bitcoin parse-tx tx) ERR_INVALID_TX))
      (output (unwrap! (element-at (get outs parsed-tx) output-index) ERR_INVALID_TX))
      (output-script (get scriptPubKey output))
      (supplier (unwrap! (map-get? supplier-by-id supplier-id) ERR_INVALID_SUPPLIER))
      (sats (get value output))
      (fee-rate (unwrap! (get inbound-fee supplier) ERR_INVALID_SUPPLIER))
      (base-fee (get inbound-base-fee supplier))
      (xbtc (try! (get-swap-amount sats fee-rate base-fee)))
      (funds (get-funds supplier-id))
      (funds-ok (asserts! (>= funds xbtc) ERR_INSUFFICIENT_FUNDS))
      (escrowed (unwrap-panic (map-get? supplier-escrow supplier-id)))
      (new-funds (- funds xbtc))
      (new-escrow (+ escrowed xbtc))
      (expiration (try! (read-varint expiration-buff)))
      (txid (contract-call? .clarity-bitcoin get-txid tx))
      (expiration-ok (try! (validate-expiration expiration mined-height)))
      (escrow {
        swapper: swapper,
        supplier: supplier-id,
        xbtc: xbtc,
        expiration: (+ mined-height (- expiration ESCROW_EXPIRATION)),
        hash: hash,
      })
      (meta {
        sender-public-key: sender,
        output-index: output-index,
        csv: expiration,
        redeem-script: htlc-redeem,
        sats: sats,
      })
    )
    (asserts! (is-eq (get public-key supplier) recipient) ERR_INVALID_OUTPUT)
    ;; #[filter(output-index)]
    (asserts! (is-eq output-script htlc-output) ERR_INVALID_OUTPUT)
    (asserts! (is-eq (len hash) u32) ERR_INVALID_HASH)
    (asserts! (map-insert inbound-swaps txid escrow) ERR_TXID_USED)
    (map-insert inbound-meta txid meta)
    (asserts! (<= base-fee max-base-fee) ERR_INCONSISTENT_FEES)
    (asserts! (<= fee-rate max-fee-rate) ERR_INCONSISTENT_FEES)
    (map-set supplier-funds supplier-id new-funds)
    (map-set supplier-escrow supplier-id new-escrow)
    (print (merge (merge escrow meta) { 
      topic: "escrow",
      txid: txid,
    }))
    (ok meta)
  )
)

;; Conclude an inbound swap by revealing the preimage.
;; The function validates that `sha256(preimage)` is equivalent to the `hash` given when the swap was escrowed.
;; 
;; This function updates the supplier escrow and the user inbound volume. If successful, the funds are transferred from the contract to the swapper.
;;
;; @returns metadata associated with the swap (refer to `inbound-swaps` map for fields)
;;
;; @param txid; the transaction ID of the Bitcoin transaction utilized for this inbound swap.
;; @param preimage; the preimage that when hashed, results in the swap's `hash`.
;;
;; @throws ERR_ALREADY_FINALIZED if the preimage already exists for the provided transaction id.
;; @throws ERR_INVALID_ESCROW if there is no swap associated with the provided transaction id.
;; @throws ERR_INVALID_PREIMAGE if the hash of the preimage does not match the stored hash.
;; @throws ERR_ESCROW_EXPIRED if the block height has exceeded the swap's expiration height.
(define-public (finalize-swap (txid (buff 32)) (preimage (buff 128)))
  (match (map-get? inbound-preimages txid)
    existing ERR_ALREADY_FINALIZED
    (let
      (
        (swap (unwrap! (map-get? inbound-swaps txid) ERR_INVALID_ESCROW))
        (stored-hash (get hash swap))
        (preimage-ok (asserts! (is-eq (sha256 preimage) stored-hash) ERR_INVALID_PREIMAGE))
        (supplier-id (get supplier swap))
        (xbtc (get xbtc swap))
        (escrowed (unwrap-panic (map-get? supplier-escrow supplier-id)))
        (swapper (get swapper swap))
      )
      (map-insert inbound-preimages txid preimage)
      (try! (as-contract (transfer xbtc tx-sender swapper)))
      (asserts! (>= (get expiration swap) block-height) ERR_ESCROW_EXPIRED)
      (map-set supplier-escrow supplier-id (- escrowed xbtc))
      (update-user-inbound-volume swapper xbtc)
      (print (merge swap {
        preimage: preimage,
        topic: "finalize-inbound",
        txid: txid,
      }))
      (ok swap)
    )
  )
)

;; Revoke an expired inbound swap.
;; 
;; If an inbound swap has expired, and is not finalized, then the `xbtc`
;; amount of the swap is "stuck" in escrow. Calling this function will:
;; 
;; - Update the supplier's funds and escrow
;; - Mark the swap as finalized
;; 
;; To finalize the swap, the pre-image stored for the swap is the constant
;; REVOKED_INBOUND_PREIMAGE (0x00).
;; 
;; @returns the swap's metadata
;; 
;; @param txid; the txid of the BTC tx used for this inbound swap
(define-public (revoke-expired-inbound (txid (buff 32)))
  (match (map-get? inbound-preimages txid)
    existing ERR_REVOKE_INBOUND_IS_FINALIZED
    (let
      (
        (swap (unwrap! (map-get? inbound-swaps txid) ERR_INVALID_ESCROW))
        (xbtc (get xbtc swap))
        (supplier-id (get supplier swap))
        (funds (get-funds supplier-id))
        (escrowed (unwrap-panic (get-escrow supplier-id)))
        (new-funds (+ funds xbtc))
        (new-escrow (- escrowed xbtc))
      )
      (asserts! (<= (get expiration swap) block-height) ERR_REVOKE_INBOUND_NOT_EXPIRED)
      (map-insert inbound-preimages txid REVOKED_INBOUND_PREIMAGE)
      (map-set supplier-escrow supplier-id new-escrow)
      (map-set supplier-funds supplier-id new-funds)
      (print (merge swap {
        topic: "revoke-inbound",
        txid: txid,
      }))
      (ok swap)
    )
  )
)

;; Initiate an outbound swap.
;; Swapper provides the amount of xBTC and their withdraw address.
;;
;; @returns the auto-generated swap-id of this swap
;; 
;; @throws ERR_INCONSISTENT_FEES if `min-to-receive` is less than the calculated
;; amount of sats (in BTC) that the swapper will receive
;;
;; @param xbtc; amount of xBTC (sats) to swap
;; @param output; the output script for the swapper's BTC address
;; @param supplier-id; the supplier used for this swap
(define-public (initiate-outbound-swap (xbtc uint) (output (buff 128)) (supplier-id uint) (min-to-receive uint))
  (let
    (
      (supplier (unwrap! (map-get? supplier-by-id supplier-id) ERR_INVALID_SUPPLIER))
      (fee-rate (unwrap! (get outbound-fee supplier) ERR_INVALID_SUPPLIER))
      (sats (try! (get-swap-amount xbtc fee-rate (get outbound-base-fee supplier))))
      (swap {
        sats: sats,
        xbtc: xbtc,
        supplier: supplier-id,
        output: output,
        created-at: burn-block-height,
        swapper: tx-sender,
      })
      (swap-id (var-get next-outbound-id))
    )
    (asserts! (>= sats min-to-receive) ERR_INCONSISTENT_FEES)
    ;; #[filter(xbtc)]
    (try! (transfer xbtc tx-sender (as-contract tx-sender)))
    (map-insert outbound-swaps swap-id swap)
    (var-set next-outbound-id (+ swap-id u1))
    (print (merge swap {
      swap-id: swap-id,
      topic: "initiate-outbound",
    }))
    (ok swap-id)
  )
)

;; Finalize an outbound swap.
;; This method is called by the supplier after they've sent the swapper BTC.
;;
;; @returns true
;;
;; @param block; a tuple containing `header` (the Bitcoin block header) and the `height` (Stacks height)
;; where the BTC tx was confirmed.
;; @param prev-blocks; because Clarity contracts can't get Bitcoin headers when there is no Stacks block,
;; this param allows users to specify the chain of block headers going back to the block where the
;; BTC tx was confirmed.
;; @param tx; the hex data of the BTC tx
;; @param proof; a merkle proof to validate inclusion of this tx in the BTC block
;; @param output-index; the index of the HTLC output in the BTC tx
;; @param swap-id; the outbound swap ID they're finalizing
(define-public (finalize-outbound-swap
    (block { header: (buff 80), height: uint })
    (prev-blocks (list 10 (buff 80)))
    (tx (buff 1024))
    (proof { tx-index: uint, hashes: (list 20 (buff 32)), tree-depth: uint })
    (output-index uint)
    (swap-id uint)
  )
  (let
    (
      (was-mined-bool (unwrap! (contract-call? .clarity-bitcoin was-tx-mined-prev? block prev-blocks tx proof) ERR_TX_NOT_MINED))
      (was-mined (asserts! was-mined-bool ERR_TX_NOT_MINED))
      (swap (unwrap! (map-get? outbound-swaps swap-id) ERR_SWAP_NOT_FOUND))
      (parsed-tx (unwrap! (contract-call? .clarity-bitcoin parse-tx tx) ERR_INVALID_TX))
      (output (unwrap! (element-at (get outs parsed-tx) output-index) ERR_INVALID_TX))
      (output-script (get scriptPubKey output))
      (txid (contract-call? .clarity-bitcoin get-txid tx))
      (output-sats (get value output))
      (xbtc (get xbtc swap))
      (supplier (get supplier swap))
      (funds-before (get-funds supplier))
    )
    (map-set supplier-funds supplier (+ funds-before xbtc))
    (asserts! (is-eq output-script (get output swap)) ERR_INVALID_OUTPUT)
    (asserts! (map-insert completed-outbound-swaps swap-id txid) ERR_ALREADY_FINALIZED)
    (asserts! (map-insert completed-outbound-swap-txids txid swap-id) ERR_TXID_USED)
    (asserts! (>= output-sats (get sats swap)) ERR_INSUFFICIENT_AMOUNT)
    (update-user-outbound-volume (get swapper swap) xbtc)
    (print (merge swap {
      topic: "finalize-outbound",
      txid: txid,
      swap-id: swap-id,
    }))
    (ok true)
  )
)

;; Revoke an expired outbound swap.
;; After an outbound swap has expired without finalizing, a swapper may call this function
;; to receive the xBTC escrowed.
;;
;; @returns the metadata regarding the outbound swap
;;
;; @param swap-id; the ID of the outbound swap being revoked.
(define-public (revoke-expired-outbound (swap-id uint))
  (let
    (
      ;; #[filter(swap-id)]
      (swap (try! (validate-outbound-revocable swap-id)))
      (xbtc (get xbtc swap))
      (swapper (get swapper swap))
    )
    (try! (as-contract (transfer xbtc tx-sender swapper)))
    (map-insert completed-outbound-swaps swap-id REVOKED_OUTBOUND_TXID)
    (print (merge swap {
      topic: "revoke-outbound",
      swap-id: swap-id,
    }))
    (ok swap)
  )
)

;; getters

(define-read-only (get-supplier-id-by-controller (controller principal))
  (map-get? supplier-by-controller controller)
)

(define-read-only (get-supplier-id-by-public-key (public-key (buff 33)))
  (map-get? supplier-by-public-key public-key)
)

(define-read-only (get-supplier (id uint))
  (map-get? supplier-by-id id)
)

(define-read-only (get-funds (id uint))
  (default-to u0 (map-get? supplier-funds id))
)

(define-read-only (get-escrow (id uint))
  (map-get? supplier-escrow id)
)

(define-read-only (get-inbound-swap (txid (buff 32)))
  (map-get? inbound-swaps txid)
)

(define-read-only (get-preimage (txid (buff 32)))
  (map-get? inbound-preimages txid)
)

(define-read-only (get-outbound-swap (id uint))
  (map-get? outbound-swaps id)
)

(define-read-only (get-completed-outbound-swap-txid (id uint))
  (map-get? completed-outbound-swaps id)
)

(define-read-only (get-completed-outbound-swap-by-txid (txid (buff 32)))
  (map-get? completed-outbound-swap-txids txid)
)

(define-read-only (get-next-supplier-id) (var-get next-supplier-id))
(define-read-only (get-next-outbound-id) (var-get next-outbound-id))

(define-read-only (get-full-supplier (id uint))
  (let
    (
      (supplier (unwrap! (get-supplier id) ERR_INVALID_SUPPLIER))
      (funds (get-funds id))
      (escrow (unwrap-panic (get-escrow id)))
    )
    (ok (merge supplier { funds: funds, escrow: escrow }))
  )
)

(define-read-only (get-inbound-meta (txid (buff 32)))
  (map-get? inbound-meta txid)
)

(define-read-only (get-full-inbound (txid (buff 32)))
  (let
    (
      (swap (unwrap! (get-inbound-swap txid) ERR_INVALID_ESCROW))
      (meta (unwrap! (get-inbound-meta txid) ERR_INVALID_ESCROW))
    )
    (ok (merge swap meta))
  )
)

(define-read-only (get-user-inbound-volume (user principal))
  (match (map-get? user-inbound-volume-map user)
    vol vol
    u0
  )
)

(define-read-only (get-total-inbound-volume) (var-get total-inbound-volume-var))

(define-read-only (get-user-outbound-volume (user principal))
  (match (map-get? user-outbound-volume-map user)
    vol vol
    u0
  )
)

(define-read-only (get-total-outbound-volume) (var-get total-outbound-volume-var))

(define-read-only (get-user-total-volume (user principal))
  (+ (get-user-inbound-volume user) (get-user-outbound-volume user))
)

(define-read-only (get-total-volume)
  (+ (get-total-inbound-volume) (get-total-outbound-volume))
)

;; helpers

(define-private (transfer (amount uint) (sender principal) (recipient principal))
  (match (contract-call? 'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin transfer amount sender recipient none)
    success (ok success)
    error (begin
      (print { transfer-error: error })
      ERR_TRANSFER
    )
  )
)

;; Serialize the metadata for a transaction involving a swapper, base-fee, and a fee-rate.
;; This function calls to the underlying `to-consensus-muff` function to serialize the data.
;;
;; @returns the serialized buffer representing the metadata
;;
;; @param swapper; the principal involved in the transaction
;; @param base-fee; the base fee for the transaction
;; @param fee-rate; the fee rate for the transaction
(define-read-only (serialize-metadata (swapper principal) (base-fee int) (fee-rate int))
  (unwrap-panic (to-consensus-buff? {
    swapper: swapper,
    base-fee: base-fee,
    fee-rate: fee-rate,
  }))
)

;; Generate a metadata hash, which is embedded in an inbound HTLC.
;; 
;; @param swapper; the STX address of the recipient of the swap
;; @param base-fee; the maximum base fee that can be charged by the supplier
;; @param fee-rate; the maximum fee rate that can be charged by the supplier
(define-read-only (hash-metadata (swapper principal) (base-fee int) (fee-rate int))
  (sha256 (serialize-metadata swapper base-fee fee-rate))
)

;; Compute the swap amount by applying a fee rate and deducting a base fee from the initial amount.
;; If the base-fee is greater than or equal to the amount after the fee rate deduction,
;; an error is thrown indicating insufficient amount.
;;
;; @returns the final amount after applying the fee rate and deducting the base fee, or an error
;;
;; @param amount; the original amount to be swapped
;; @param fee-rate; the fee rate to be deducted from the original amount
;; @param base-fee; the base fee to be deducted after applying the fee rate
;;
;; @throws ERR_INSUFFICIENT_AMOUNT if the base-fee is greater than or equal to the amount after applying the fee rate
(define-read-only (get-swap-amount (amount uint) (fee-rate int) (base-fee int))
  (let
    (
      (with-bps-fee (get-amount-with-fee-rate amount fee-rate))
    )
    (if (>= base-fee with-bps-fee)
      ERR_INSUFFICIENT_AMOUNT
      (ok (to-uint (- with-bps-fee base-fee)))
    )
  )
)

;; Calculate the transaction amount with a fee rate applied.
;; This function computes a new amount by subtracting the fee-rate from the amount,
;; treating the result as a percentage of the original amount.
;;
;; @returns the calculated amount after applying the fee rate
;;
;; @param amount; the original amount of the transaction
;; @param fee-rate; the fee rate to be deducted from the original amount
(define-read-only (get-amount-with-fee-rate (amount uint) (fee-rate int))
  (let
    (
      (numerator (* (to-int amount) (- 10000 fee-rate)))
      (final (/ numerator 10000))
    )
    final
  )
)

(define-private (update-user-inbound-volume (user principal) (amount uint))
  (let
    (
      (user-total (get-user-inbound-volume user))
      (total (get-total-inbound-volume))
    )
    (map-set user-inbound-volume-map user (+ user-total amount))
    (var-set total-inbound-volume-var (+ total amount))
    true
  )
)

(define-private (update-user-outbound-volume (user principal) (amount uint))
  (let
    (
      (user-total (get-user-outbound-volume user))
      (total (get-total-outbound-volume))
    )
    (map-set user-outbound-volume-map user (+ user-total amount))
    (var-set total-outbound-volume-var (+ total amount))
    true
  )
)

;; validators

;; Validate the expiration for an inbound swap.
;; 
;; There are two validations used here:
;; 
;; - Expiration isn't too soon. To ensure that the swapper and supplier have sufficient
;; time to finalize, a swap must be escrowed with **at least** 250 blocks remaining.
;; - Expiration isn't too far. The HTLC must have a `CHECKSEQUENCEVERIFY` of less
;; than 550. This ensures that a supplier's xBTC isn't escrowed for unnecessarily long times.
;; 
;; @param expiration; the amount of blocks that need to pass before
;; the sender can recover their HTLC. This is the value used with `CHECKSEQUENCEVERIFY`
;; in the HTLC script.
;; @param mined-height; the nearest stacks block after (or including) the Bitcoin
;; block where the HTLC was confirmed.
(define-read-only (validate-expiration (expiration uint) (mined-height uint))
  (if (> expiration (+ (- block-height mined-height) MIN_EXPIRATION))
    (if (< expiration MAX_HTLC_EXPIRATION) (ok true) ERR_INVALID_EXPIRATION)
    ERR_INVALID_EXPIRATION
  )
)

;; Validate a fee by checking if it falls within an acceptable range.
;; The acceptable range is between -10000 and 10000 (exclusive). 
;; If the fee does not fall within this range, an error is thrown indicating an invalid fee.
;; If no fee is provided, it defaults to true without performing any validation.
;;
;; @returns true if the fee is within the acceptable range, or an error
;;
;; @param fee-opt; the optional fee to be validated
;;
;; @throws ERR_FEE_INVALID if the fee does not fall within the acceptable range
(define-read-only (validate-fee (fee-opt (optional int)))
  (match fee-opt
    fee (let
      (
        (max-fee 10000)
        (within-upper (< fee max-fee))
        (within-lower (> fee (* -1 max-fee)))
      )
      (asserts! (and within-upper within-lower) ERR_FEE_INVALID)
      (ok true)
    )
    (ok true)
  )
)

;; Validate if an outbound swap is revocable.
;; A swap is considered revocable if it is expired and not yet finalized.
;; The function fetches the swap using the provided swap-id, checks if the swap is expired, 
;; and if it has not yet been finalized.
;; If the swap is not expired or has been finalized, an error is thrown respectively.
;; 
;; @returns the swap if it is revocable, or an error
;;
;; @param swap-id; the ID of the outbound swap to be checked for revocability
;;
;; @throws ERR_SWAP_NOT_FOUND if no swap is found with the provided swap-id
;; @throws ERR_REVOKE_OUTBOUND_NOT_EXPIRED if the swap is not yet expired
;; @throws ERR_REVOKE_OUTBOUND_IS_FINALIZED if the swap has been finalized

(define-read-only (validate-outbound-revocable (swap-id uint))
  (let
    (
      (swap (unwrap! (get-outbound-swap swap-id) ERR_SWAP_NOT_FOUND))
      (finalize-txid (get-completed-outbound-swap-txid swap-id))
      (swap-expiration (+ (get created-at swap) OUTBOUND_EXPIRATION))
      (is-expired (>= burn-block-height swap-expiration))
      (is-not-finalized (is-none finalize-txid))
    )
    (asserts! is-expired ERR_REVOKE_OUTBOUND_NOT_EXPIRED)
    (asserts! is-not-finalized ERR_REVOKE_OUTBOUND_IS_FINALIZED)
    (ok swap)
  )
)

;; htlc

;; Generate a hashed timelock contract (HTLC) script.
;; The function concatenates various components including sender, recipient, expiration, 
;; hash, and metadata to form the HTLC script.
;; These scripts allow locked transactions to be spent if certain conditions are met. 
;;
;; @returns the HTLC script
;;
;; @param sender; a 33-byte public key of the sender
;; @param recipient; a 33-byte public key of the recipient
;; @param expiration; a 4-byte expiration time buffer
;; @param hash; a 32-byte hash of the secret
;; @param metadata; a 32-byte buffer containing hashed metadata for the transaction - see [`hash-metadata`](#hash-metadata)
(define-read-only (generate-htlc-script
    (sender (buff 33))
    (recipient (buff 33))
    (expiration (buff 4))
    (hash (buff 32))
    (metadata (buff 32))
  )
  (concat 0x20
  (concat metadata
  (concat 0x7563a820 ;; DROP; IF; PUSH32
  (concat hash
  (concat 0x8821 ;; EQUALVERIFY; PUSH33
  (concat recipient
  (concat 0x67 ;; ELSE
  (concat (bytes-len expiration)
  (concat expiration
  (concat 0xb27521 ;; CHECKSEQUENCEVERIFY; DROP; PUSH33
  (concat sender 0x68ac) ;; ENDIF; CHECKSIG;
  ))))))))))
)

;; Generate a SegWit script hash (wsh) output.
;; The function computes a SHA256 hash of the provided script and prepends it with `0x0020`.
;; The output can be used as a Pay-to-Witness-Script-Hash (P2WSH) output script.
;;
;; @returns a P2WSH output script
;;
;; @param script; a 148-byte buffer containing the script from which to generate the output
(define-read-only (generate-wsh-output (script (buff 148)))
  (concat 0x0020 (sha256 script))
)

(define-read-only (bytes-len (bytes (buff 4)))
  (unwrap-panic (element-at BUFF_TO_BYTE (len bytes)))
)

(define-constant ERR_READ_UINT (err u100))

(define-read-only (read-varint (num (buff 4)))
  (let
    (
      (length (len num))
    )
    (if (> length u1)
      (let
        (
          (first-byte (unwrap-panic (slice? num u0 u1)))
        )
        (asserts! (or 
          (and (is-eq first-byte 0xfd) (is-eq length u3))
          (and (is-eq first-byte 0xfe) (is-eq length u4))
        ) ERR_READ_UINT)
        (ok (buff-to-uint-le (unwrap-panic (slice? num u1 length))))
      )
      (ok (buff-to-uint-le num))
    )
  )
)

(define-constant BUFF_TO_BYTE (list 0x00 0x01 0x02 0x03 0x04))
