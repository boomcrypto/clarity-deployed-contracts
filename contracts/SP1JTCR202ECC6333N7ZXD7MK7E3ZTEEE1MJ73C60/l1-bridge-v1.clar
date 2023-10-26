;; This contract exposes functions for interacting with the
;; BNS L1<->L2 bridge.

(define-data-var signer-var principal tx-sender)
(define-data-var signer-pubkey-hash-var (buff 20)
  (get-pubkey-hash tx-sender))

;; Errors

(define-constant ERR_INVALID_BLOCK (err u1200))
(define-constant ERR_RECOVER (err u1201))
(define-constant ERR_INVALID_SIGNER (err u1202))
(define-constant ERR_NAME_NOT_MIGRATED (err u1203))
(define-constant ERR_TRANSFER (err u1204))
(define-constant ERR_INVALID_BURN_ADDRESS (err u1205))

;; Public functions

(define-public (bridge-to-l1
    (name (buff 48))
    (namespace (buff 20))
    (inscription-id (buff 35))
    (signature (buff 65))
  )
  (let
    (
      ;; #[filter(name, namespace, inscription-id, signature)]
      (name-id (unwrap! (contract-call? .bnsx-registry get-id-for-name { name: name, namespace: namespace }) ERR_NAME_NOT_MIGRATED))
    )
    (match (contract-call? .bnsx-registry transfer name-id tx-sender .l1-registry)
      res (handle-bridge-to-v1
        name-id
        name
        namespace
        inscription-id
        signature
      )
      e (begin
        (print {
          topic: "transfer-error",
          error: e,
        })
        ERR_TRANSFER
      )
    )
  )
)

(define-public (migrate-and-bridge
    (name (buff 48))
    (namespace (buff 20))
    (inscription-id (buff 35))
    (bridge-signature (buff 65))
    (wrapper principal)
    (migrate-signature (buff 65))
  )
  (let
    (
      (name-details (try! (contract-call? .wrapper-migrator-v2 migrate wrapper migrate-signature .l1-registry)))
      (name-id (get id name-details))
    )
    ;; #[allow(unchecked_data)]
    (handle-bridge-to-v1 name-id name namespace inscription-id bridge-signature)
  )
)

(define-private (handle-bridge-to-v1
    (name-id uint)
    (name (buff 48))
    (namespace (buff 20))
    (inscription-id (buff 35))
    (signature (buff 65))
  )
  (begin
    (try! (validate-wrap-signature name namespace inscription-id signature))
    (try! (contract-call? .l1-registry wrap name-id tx-sender inscription-id))
    (ok true)
  )
)

(define-public (bridge-to-l2
    (inscription-id (buff 35))
    (recipient principal)
    (signature (buff 65))
  )
  (let
    (
      (expected-output (generate-burn-output recipient))
    )
    (try! (validate-unwrap-signature inscription-id recipient expected-output signature))
    (try! (contract-call? .l1-registry unwrap inscription-id recipient))
    (ok true)
  )
)

;; Signature validation

;; #[filter(signature)]
(define-read-only (validate-wrap-signature
    (name (buff 48))
    (namespace (buff 20))
    (inscription-id (buff 35))
    (signature (buff 65))
  )
  (let
    (
      (hash (hash-wrap-data name namespace inscription-id))
      (pubkey (unwrap! (secp256k1-recover? hash signature) ERR_RECOVER))
      (pubkey-hash (hash160 pubkey))
    )
    (asserts! (is-eq (var-get signer-pubkey-hash-var) pubkey-hash) ERR_INVALID_SIGNER)
    (ok true)
  )
)

;; (define-read-only (validate-block-hash (height uint) (header-hash (buff 32)))
;;   (let
;;     (
;;       (block-hash (unwrap! (get-block-info? header-hash height) ERR_INVALID_BLOCK))
;;     )
;;     (asserts! (is-eq block-hash header-hash) ERR_INVALID_BLOCK)
;;     (ok true)
;;   )
;; )

(define-read-only (hash-for-height (height uint))
  (unwrap-panic (get-block-info? header-hash height))
)

(define-read-only (hash-wrap-data
    (name (buff 48))
    (namespace (buff 20))
    (inscription-id (buff 35))
  )
  (sha256 (unwrap-panic (to-consensus-buff? {
    name: name,
    namespace: namespace,
    inscription-id: inscription-id,
  })))
)

(define-read-only (hash-unwrap-data (inscription-id (buff 35)) (owner (buff 34)))
  (sha256 (unwrap-panic (to-consensus-buff? {
    inscription-id: inscription-id,
    owner: owner
  })))
)

(define-read-only (validate-unwrap-signature
    (inscription-id (buff 35))
    (recipient principal)
    (owner (buff 34))
    (signature (buff 65))
  )
  (let
    (
      (hash (hash-unwrap-data inscription-id owner))
      (pubkey (unwrap! (secp256k1-recover? hash signature) ERR_RECOVER))
      (pubkey-hash (hash160 pubkey))
      (expected-output (generate-burn-output recipient))
    )
    (asserts! (is-eq pubkey-hash (var-get signer-pubkey-hash-var)) ERR_INVALID_SIGNER)
    (asserts! (is-eq expected-output owner) ERR_INVALID_BURN_ADDRESS)
    (ok true)
  )
)

;; Signer management functions

;; #[allow(unchecked_data)]
(define-private (set-signer-inner (signer principal))
  (let
    (
      (pubkey (get-pubkey-hash signer))
    )
    (var-set signer-var signer)
    (var-set signer-pubkey-hash-var pubkey)
    true
  )
)

;; #[allow(unchecked_data)]
(define-private (get-pubkey-hash (addr principal))
  (get hash-bytes (unwrap-panic (principal-destruct? addr)))
)

(define-public (update-signer (signer principal))
  (begin
    (asserts! (is-eq (var-get signer-var) tx-sender) ERR_INVALID_SIGNER)
    (set-signer-inner signer)
    (ok true)
  )
)

(define-read-only (get-signer) (var-get signer-var))

(define-public (update-registry-extension (new-extension principal))
  (begin
    (asserts! (is-eq (var-get signer-var) tx-sender) ERR_INVALID_SIGNER)
    (try! (contract-call? .l1-registry update-extension new-extension))
    (ok new-extension)
  )
)

;; Burn script helpers

(define-read-only (burn-script-data (recipient principal))
  (unwrap-panic (to-consensus-buff? {
    recipient: recipient,
    topic: "burn",
    bridge: (as-contract tx-sender),
  }))
)

(define-read-only (hash-burn-script-data (recipient principal))
  (hash160 (burn-script-data recipient))
)

(define-read-only (generate-burn-script (recipient principal))
  (let
    (
      (data-hash (hash-burn-script-data recipient))
      (pushdata (concat 0x14 data-hash))
    )
    (concat pushdata 0x7500) ;; OP_DROP, OP_FALSE
  )
)

(define-read-only (generate-burn-output (recipient principal))
  (let
    (
      (script (generate-burn-script recipient))
    )
    (concat 0x0020 (sha256 script))
  )
)