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

;; info for inbound swaps
(define-map inbound-swaps (buff 32) {
  swapper: uint,
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
  redeem-script: (buff 120),
})
;; mapping of txid -> preimage
(define-map inbound-preimages (buff 32) (buff 128))

(define-map outbound-swaps uint {
  swapper: principal,
  sats: uint,
  xbtc: uint,
  supplier: uint,
  version: (buff 1),
  hash: (buff 20),
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

(define-constant ERR_PANIC (err u1)) ;; should never be thrown
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
    (asserts! (map-insert supplier-by-id id supplier) ERR_PANIC)
    (asserts! (map-insert supplier-funds id u0) ERR_PANIC)
    (asserts! (map-insert supplier-escrow id u0) ERR_PANIC)
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
      (existing-supplier (unwrap! (get-supplier supplier-id) ERR_PANIC))
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
      (existing-supplier (unwrap! (get-supplier supplier-id) ERR_PANIC))
      (new-supplier (merge existing-supplier {
        public-key: public-key,
      }))
    )
    (asserts! (map-insert supplier-by-public-key public-key supplier-id) ERR_SUPPLIER_EXISTS)
    (asserts! (map-delete supplier-by-public-key (get public-key existing-supplier)) ERR_PANIC)
    (map-set supplier-by-id supplier-id new-supplier)
    (ok new-supplier)
  )
)


;; As a swapper, register with the contract to generate your `swapper-id`.
;; This is required to generate BTC deposit addresses that include metadata
;; that point to a specific STX address as the swapper.
;;
;; @returns the newly generated swapper ID.
(define-public (initialize-swapper)
  (let
    (
      (swapper tx-sender)
      (id (var-get next-swapper-id))
    )
    (asserts! (map-insert swapper-by-id id swapper) ERR_PANIC)
    (asserts! (map-insert swapper-by-principal swapper id) ERR_SWAPPER_EXISTS)
    (var-set next-swapper-id (+ id u1))
    (ok id)
  )
)

;; Escrow funds for a supplier after sending BTC during an inbound swap.
;; Validates that the BTC tx is valid by re-constructing the HTLC script
;; and comparing it to the BTC tx.
;; Validates that the HTLC data (like expiration) is valid.
;; 
;; `tx-sender` must be equal to the swapper embedded in the HTLC. This ensures
;; that the `min-to-receive` parameter is provided by the end-user.
;;
;; @returns metadata regarding this inbound swap (see `inbound-meta` map)
;;
;; @param block; a tuple containing `header` (the Bitcoin block header) and the `height` (Stacks height)
;; where the BTC tx was confirmed.
;; @param prev-blocks; because Clarity contracts can't get Bitcoin headers when there is no Stacks block,
;; this param allows users to specify the chain of block headers going back to the block where the
;; BTC tx was confirmed.
;; @param tx; the hex data of the BTC tx
;; @param proof; a merkle proof to validate inclusion of this tx in the BTC block
;; @param output-index; the index of the HTLC output in the BTC tx
;; @param sender; The swapper's public key used in the HTLC
;; @param recipient; The supplier's public key used in the HTLC
;; @param expiration-buff; A 4-byte integer the indicated the expiration of the HTLC
;; @param hash; a hash of the `preimage` used in this swap
;; @param swapper-buff; a 4-byte integer that indicates the `swapper-id`
;; @param supplier-id; the supplier used in this swap
;; @param min-to-receive; minimum receivable calculated off-chain to avoid the supplier front-run the swap by adjusting fees
(define-public (escrow-swap
    (block { header: (buff 80), height: uint })
    (prev-blocks (list 10 (buff 80)))
    (tx (buff 1024))
    (proof { tx-index: uint, hashes: (list 12 (buff 32)), tree-depth: uint })
    (output-index uint)
    (sender (buff 33))
    (recipient (buff 33))
    (expiration-buff (buff 4))
    (hash (buff 32))
    (swapper-buff (buff 4))
    (supplier-id uint)
    (min-to-receive uint)
  )
  (let
    (
      (was-mined-bool (unwrap! (contract-call? .clarity-bitcoin was-tx-mined-prev? block prev-blocks tx proof) ERR_TX_NOT_MINED))
      (was-mined (asserts! was-mined-bool ERR_TX_NOT_MINED))
      (mined-height (get height block))
      (htlc-redeem (generate-htlc-script sender recipient expiration-buff hash swapper-buff))
      (htlc-output (generate-script-hash htlc-redeem))
      (parsed-tx (unwrap! (contract-call? .clarity-bitcoin parse-tx tx) ERR_INVALID_TX))
      (output (unwrap! (element-at (get outs parsed-tx) output-index) ERR_INVALID_TX))
      (output-script (get scriptPubKey output))
      (supplier (unwrap! (map-get? supplier-by-id supplier-id) ERR_INVALID_SUPPLIER))
      (sats (get value output))
      (fee-rate (unwrap! (get inbound-fee supplier) ERR_INVALID_SUPPLIER))
      (xbtc (try! (get-swap-amount sats fee-rate (get inbound-base-fee supplier))))
      (funds (get-funds supplier-id))
      (funds-ok (asserts! (>= funds xbtc) ERR_INSUFFICIENT_FUNDS))
      (escrowed (unwrap! (map-get? supplier-escrow supplier-id) ERR_PANIC))
      (new-funds (- funds xbtc))
      (new-escrow (+ escrowed xbtc))
      (expiration (try! (read-uint32 expiration-buff (len expiration-buff))))
      (swapper-id (try! (read-uint32 swapper-buff u4)))
      (txid (contract-call? .clarity-bitcoin get-txid tx))
      (expiration-ok (try! (validate-expiration expiration mined-height)))
      (escrow {
        swapper: swapper-id,
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
    ;; assert tx-sender is swapper
    (asserts! (is-eq tx-sender (unwrap! (map-get? swapper-by-id swapper-id) ERR_SWAPPER_NOT_FOUND)) ERR_UNAUTHORIZED)
    (asserts! (is-eq (get public-key supplier) recipient) ERR_INVALID_OUTPUT)
    (asserts! (is-eq output-script htlc-output) ERR_INVALID_OUTPUT)
    (asserts! (is-eq (len hash) u32) ERR_INVALID_HASH)
    (asserts! (map-insert inbound-swaps txid escrow) ERR_TXID_USED)
    (asserts! (map-insert inbound-meta txid meta) ERR_PANIC)
    (asserts! (>= xbtc min-to-receive) ERR_INCONSISTENT_FEES)
    (map-set supplier-funds supplier-id new-funds)
    (map-set supplier-escrow supplier-id new-escrow)
    (print (merge (merge escrow meta) { 
      topic: "escrow",
      txid: txid,
    }))
    (ok meta)
  )
)

;; Finalize an inbound swap by revealing the preimage.
;; Validates that `sha256(preimage)` is equal to the `hash` provided when
;; escrowing the swap.
;;
;; @returns metadata relating to the swap (see `inbound-swaps` map)
;;
;; @param txid; the txid of the BTC tx used for this inbound swap
;; @param preimage; the preimage that hashes to the swap's `hash`
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
        (escrowed (unwrap! (map-get? supplier-escrow supplier-id) ERR_PANIC))
        (swapper (unwrap! (get-swapper-principal (get swapper swap)) ERR_PANIC))
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
        (escrowed (unwrap! (get-escrow supplier-id) ERR_PANIC))
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

;; outbound swaps

;; Initiate an outbound swap.
;; Swapper provides the amount of xBTC and their withdraw address.
;;
;; @returns the auto-generated swap-id of this swap
;;
;; @param xbtc; amount of xBTC (sats) to swap
;; @param btc-version; the address version for the swapper's BTC address
;; @param btc-hash; the hash for the swapper's BTC address
;; @param supplier-id; the supplier used for this swap
(define-public (initiate-outbound-swap (xbtc uint) (btc-version (buff 1)) (btc-hash (buff 20)) (supplier-id uint))
  (let
    (
      (supplier (unwrap! (map-get? supplier-by-id supplier-id) ERR_INVALID_SUPPLIER))
      (fee-rate (unwrap! (get outbound-fee supplier) ERR_INVALID_SUPPLIER))
      (sats (try! (get-swap-amount xbtc fee-rate (get outbound-base-fee supplier))))
      (swap {
        sats: sats,
        xbtc: xbtc,
        supplier: supplier-id,
        version: btc-version,
        hash: btc-hash,
        created-at: burn-block-height,
        swapper: tx-sender,
      })
      (swap-id (var-get next-outbound-id))
    )
    (try! (validate-btc-addr btc-version btc-hash))
    (try! (transfer xbtc tx-sender (as-contract tx-sender)))
    (asserts! (map-insert outbound-swaps swap-id swap) ERR_PANIC)
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
    (proof { tx-index: uint, hashes: (list 12 (buff 32)), tree-depth: uint })
    (output-index uint)
    (swap-id uint)
  )
  (let
    (
      (was-mined-bool (unwrap! (contract-call? .clarity-bitcoin was-tx-mined-prev? block prev-blocks tx proof) ERR_TX_NOT_MINED))
      (was-mined (asserts! was-mined-bool ERR_TX_NOT_MINED))
      (swap (unwrap! (get-outbound-swap swap-id) ERR_SWAP_NOT_FOUND))
      (expected-output (generate-output (get version swap) (get hash swap)))
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
    (asserts! (is-eq output-script expected-output) ERR_INVALID_OUTPUT)
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
      (swap (try! (validate-outbound-revocable swap-id)))
      (xbtc (get xbtc swap))
      (swapper (get swapper swap))
    )
    (try! (as-contract (transfer xbtc tx-sender swapper)))
    (asserts! (map-insert completed-outbound-swaps swap-id REVOKED_OUTBOUND_TXID) ERR_PANIC)
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

(define-read-only (get-swapper-id (swapper principal))
  (map-get? swapper-by-principal swapper)
)

(define-read-only (get-swapper-principal (id uint))
  (map-get? swapper-by-id id)
)

(define-read-only (get-next-supplier-id) (var-get next-supplier-id))
(define-read-only (get-next-swapper-id) (var-get next-swapper-id))
(define-read-only (get-next-outbound-id) (var-get next-outbound-id))

(define-read-only (get-full-supplier (id uint))
  (let
    (
      (supplier (unwrap! (get-supplier id) ERR_INVALID_SUPPLIER))
      (funds (get-funds id))
      (escrow (unwrap! (get-escrow id) ERR_PANIC))
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
      (swapper-principal (unwrap! (get-swapper-principal (get swapper swap)) ERR_PANIC))
    )
    (ok (merge { swapper-principal: swapper-principal } (merge swap meta)))
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

(define-read-only (concat-buffs (buffs (list 6 (buff 32))))
  (let
    (
      (initial-buff 0x)
      (final (fold concat-buffs-fold buffs initial-buff))
    )
    final
  )
)

(define-private (concat-buffs-fold (b (buff 32)) (result (buff 192)))
  (let
    (
      (next-buff (concat result b))
      (next-buff-min (as-max-len? next-buff u192))
    )
    (match next-buff-min
      min-buff min-buff
      result ;; if using `concat-buffs`, this should never happen.
    )
  )
)

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

(define-read-only (validate-btc-addr (version (buff 1)) (hash (buff 20)))
  (let
    (
      (valid-hash (is-eq (len hash) u20))
      (valid-version (or (is-eq version P2PKH_VERSION) (is-eq version P2SH_VERSION)))
    )
    (asserts! (and valid-hash valid-version) ERR_INVALID_BTC_ADDR)
    (ok true)
  )
)

;; lookup an outbound swap and validate that it is revocable.
;; to be revoked, it must be expired and not finalized
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

(define-read-only (generate-htlc-script
    (sender (buff 33))
    (recipient (buff 33))
    (expiration (buff 4))
    (hash (buff 32))
    (swapper (buff 4))
  )
  (let
    (
      (swapper-id (concat 0x04 swapper))
      (b10 (concat swapper-id 0x7563a820))
      (b1 (concat b10 hash))
      (b2 (concat b1 0x8821))
      (b3 (concat b2 recipient))
      (b4 (concat b3 0x67))
      (exp-len (bytes-len expiration))
      (b9 (concat b4 exp-len))
      (b5 (concat b9 expiration))
      (b6 (concat b5 0xb27521))
      (b7 (concat b6 sender))
      (b8 (concat b7 0x68ac))
    )
    b8
  )
)

(define-read-only (generate-script-hash (script (buff 120)))
  (generate-p2sh-output (hash160 script))
)

(define-read-only (generate-htlc-script-hash
    (sender (buff 33))
    (recipient (buff 33))
    (expiration (buff 4))
    (hash (buff 32))
    (swapper (buff 4))
  )
  (generate-script-hash (generate-htlc-script sender recipient expiration hash swapper))
)

(define-read-only (generate-p2pkh-output (hash (buff 20)))
  (concat (concat 0x76a914 hash) 0x88ac)
)

(define-read-only (generate-p2sh-output (hash (buff 20)))
  (concat (concat 0xa914 hash) 0x87)
)

;; generate an output, given btc address.
;; assumes that if the version is not p2sh, it's p2pkh.
;; for outbound swaps, the version is validated when initiated,
;; so it should only ever be these two.
(define-read-only (generate-output (version (buff 1)) (hash (buff 20)))
  (if (is-eq version P2SH_VERSION)
    (generate-p2sh-output hash)
    (generate-p2pkh-output hash)
  )
)

(define-read-only (bytes-len (bytes (buff 4)))
  (unwrap-panic (element-at BUFF_TO_BYTE (len bytes)))
)

(define-constant ERR_READ_UINT (err u100))

;; little-endian
(define-read-only (read-uint32 (num (buff 4)) (length uint))
  (let
    (
      (byte-1 (buff-to-u8 (unwrap! (element-at num u0) ERR_READ_UINT)))
      (byte-2 (if (> length u1) (buff-to-u8 (unwrap! (element-at num u1) ERR_READ_UINT)) u0))
      (byte-3 (if (> length u2) (buff-to-u8 (unwrap! (element-at num u2) ERR_READ_UINT)) u0))
      (byte-4 (if (> length u3) (buff-to-u8 (unwrap! (element-at num u3) ERR_READ_UINT)) u0))
    )
    (ok (+ (* byte-4 u16777216) (* byte-3 u65536) (* byte-2 u256) byte-1))
  )
)

(define-read-only (buff-to-u8 (byte (buff 1)))
    (unwrap-panic (index-of BUFF_TO_BYTE byte)))


(define-constant BUFF_TO_BYTE (list 
   0x00 0x01 0x02 0x03 0x04 0x05 0x06 0x07 0x08 0x09 0x0a 0x0b 0x0c 0x0d 0x0e 0x0f
   0x10 0x11 0x12 0x13 0x14 0x15 0x16 0x17 0x18 0x19 0x1a 0x1b 0x1c 0x1d 0x1e 0x1f
   0x20 0x21 0x22 0x23 0x24 0x25 0x26 0x27 0x28 0x29 0x2a 0x2b 0x2c 0x2d 0x2e 0x2f
   0x30 0x31 0x32 0x33 0x34 0x35 0x36 0x37 0x38 0x39 0x3a 0x3b 0x3c 0x3d 0x3e 0x3f
   0x40 0x41 0x42 0x43 0x44 0x45 0x46 0x47 0x48 0x49 0x4a 0x4b 0x4c 0x4d 0x4e 0x4f
   0x50 0x51 0x52 0x53 0x54 0x55 0x56 0x57 0x58 0x59 0x5a 0x5b 0x5c 0x5d 0x5e 0x5f
   0x60 0x61 0x62 0x63 0x64 0x65 0x66 0x67 0x68 0x69 0x6a 0x6b 0x6c 0x6d 0x6e 0x6f
   0x70 0x71 0x72 0x73 0x74 0x75 0x76 0x77 0x78 0x79 0x7a 0x7b 0x7c 0x7d 0x7e 0x7f
   0x80 0x81 0x82 0x83 0x84 0x85 0x86 0x87 0x88 0x89 0x8a 0x8b 0x8c 0x8d 0x8e 0x8f
   0x90 0x91 0x92 0x93 0x94 0x95 0x96 0x97 0x98 0x99 0x9a 0x9b 0x9c 0x9d 0x9e 0x9f
   0xa0 0xa1 0xa2 0xa3 0xa4 0xa5 0xa6 0xa7 0xa8 0xa9 0xaa 0xab 0xac 0xad 0xae 0xaf
   0xb0 0xb1 0xb2 0xb3 0xb4 0xb5 0xb6 0xb7 0xb8 0xb9 0xba 0xbb 0xbc 0xbd 0xbe 0xbf
   0xc0 0xc1 0xc2 0xc3 0xc4 0xc5 0xc6 0xc7 0xc8 0xc9 0xca 0xcb 0xcc 0xcd 0xce 0xcf
   0xd0 0xd1 0xd2 0xd3 0xd4 0xd5 0xd6 0xd7 0xd8 0xd9 0xda 0xdb 0xdc 0xdd 0xde 0xdf
   0xe0 0xe1 0xe2 0xe3 0xe4 0xe5 0xe6 0xe7 0xe8 0xe9 0xea 0xeb 0xec 0xed 0xee 0xef
   0xf0 0xf1 0xf2 0xf3 0xf4 0xf5 0xf6 0xf7 0xf8 0xf9 0xfa 0xfb 0xfc 0xfd 0xfe 0xff
))
