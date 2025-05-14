;; title: blaze-rc2
;; authors: rozar.btc, brice.btc
;; summary: Shared utility contract for verifying blaze-style signed messages (using a generic opcode)
;;          and managing global UUID consumption via `submit`. Provides a read-only `verify` function.
;;          Called by various blaze-core contracts.

;; --- Constants for SIP-018 structured data ---
(define-constant structured-data-prefix 0x534950303138)
(define-constant message-domain-hash (sha256 (unwrap-panic (to-consensus-buff? { name: "BLAZE_PROTOCOL", version: "rc2", chain-id: chain-id }))))
(define-constant structured-data-header (concat structured-data-prefix message-domain-hash))

;; --- Errors ---
(define-constant ERR_INVALID_SIGNATURE (err u101))
(define-constant ERR_CONSENSUS_BUFF (err u103))
(define-constant ERR_UUID_SUBMITTED (err u107))

;; --- Data Storage ---
(define-map submitted-uuids (string-ascii 64) bool)

;; --- Public State-Changing Function ---
;; Verifies a signature against a hash derived from opcode, uuid, and the calling contract (`contract-caller`).
;; Asserts the UUID has not been submitted, then submits it upon successful verification.
(define-public (submit
    (signature (buff 65))
    (uuid (string-ascii 64))
    (opcode (string-ascii 64)) ;; Generic opcode encoding action details
  )
  (let
    (
      ;; Generate the hash using the opcode, uuid, and the immediate caller (`contract-caller`).
      (hash (try! (hash-data contract-caller opcode uuid)))
    )
    ;; 1. Check for replay first - This check remains crucial before state change
    (asserts! (is-none (map-get? submitted-uuids uuid)) ERR_UUID_SUBMITTED)

    ;; 2. Verify the signature against the hash constructed with contract-caller and opcode
    (match (secp256k1-recover? hash signature)
      recovered-pubkey (let
          (
            (signer-principal (principal-of? recovered-pubkey))
          )
          ;; 3. Mark UUID as submitted only on successful verification *after* the check
          (map-set submitted-uuids uuid true)
          signer-principal ;; Return the original signer's principal
        )
      ;; If signature recovery fails
      error ERR_INVALID_SIGNATURE
    )
  )
)

;; --- Read-Only Functions ---

;; Checks if a UUID has already been submitted. Can be called before `submit`.
(define-read-only (is-uuid-submitted (uuid (string-ascii 64)))
  (is-some (map-get? submitted-uuids uuid))
)

;; Performs signature verification without checking consumption state or consuming the UUID.
;; Requires the intended contract principal to construct the correct hash.
(define-read-only (verify
    (signature (buff 65))
    (contract principal)
    (opcode (string-ascii 64))
    (uuid (string-ascii 64))
  )
  (let
    (
      ;; Generate the hash using the provided arguments.
      (hash (try! (hash-data contract opcode uuid)))
    )
    ;; Verify the signature against the hash.
    (get-signer hash signature)
  )
)

;; Helper function to construct the SIP-018 compliant hash using the generic opcode.
;; Used by both `submit` (implicitly with contract-caller) and `verify` (explicitly with contract arg).
(define-read-only (hash-data
    (contract principal)
    (opcode (string-ascii 64))
    (uuid (string-ascii 64))
  )
  (let (
      (structured-data { contract: contract, opcode: opcode, uuid: uuid })
      (data-hash (sha256 (unwrap! (to-consensus-buff? structured-data) ERR_CONSENSUS_BUFF)))
    )
    (ok (sha256 (concat structured-data-header data-hash)))
  )
)

;; Recovers the signer principal from a given *pre-computed* hash and signature.
(define-read-only (get-signer (hash (buff 32)) (signature (buff 65)))
  (match (secp256k1-recover? hash signature)
    public-key (principal-of? public-key)
    error ERR_INVALID_SIGNATURE
  )
)