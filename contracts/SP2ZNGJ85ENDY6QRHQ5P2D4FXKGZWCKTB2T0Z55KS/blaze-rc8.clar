;; title: blaze-rc8
;; authors: rozar.btc, brice.btc
;; summary: Shared utility contract for verifying blaze-style signed messages (using a generic opcode)
;;          and managing global UUID consumption via `submit` with read-only signer recovery functions.

;; --- Constants for SIP-018 structured data ---
(define-constant structured-data-prefix 0x534950303138)
(define-constant message-domain-hash (sha256 (unwrap-panic (to-consensus-buff? { name: "BLAZE_PROTOCOL", version: "rc8", chain-id: chain-id }))))
(define-constant structured-data-header (concat structured-data-prefix message-domain-hash))

;; --- Errors ---
(define-constant ERR_INVALID_SIGNATURE (err u400))
(define-constant ERR_CONSENSUS_BUFF    (err u401))
(define-constant ERR_UUID_SUBMITTED    (err u402))

;; --- Data Storage ---
(define-map submitted-uuids (string-ascii 36) bool)

;; --- Public State-Changing Function ---

;; Verifies a signature against a hash and handles UUID submission
;; The authorize parameter determines whether to authorize using the calling contract
(define-public (submit
    (signature (buff 65))
    (opcode (string-ascii 64))
    (uuid (string-ascii 36))
    (authorize (optional bool))
  )
  (let
    (
      ;; Use contract-caller for authorization only if specified (defaults to false)
      (use-caller-auth (default-to false authorize))
      (contract (if use-caller-auth (some contract-caller) none))
      ;; Generate the hash using the opcode, uuid, and optional contract-caller
      (hash (try! (hash-args opcode uuid contract)))
    )
    ;; 1. Check for replay first
    (asserts! (is-none (map-get? submitted-uuids uuid)) ERR_UUID_SUBMITTED)

    ;; 2. Mark UUID as submitted
    (map-set submitted-uuids uuid true)

    ;; 3. Verify the signature against the constructed hash
    (get-signer-from-hash hash signature)
  )
)

;; --- Read-Only Functions ---

;; Checks if a UUID has already been submitted. Can be called before `submit`.
(define-read-only (is-uuid-submitted (uuid (string-ascii 36)))
  (is-some (map-get? submitted-uuids uuid))
)

;; Helper function to construct the SIP-018 compliant hash using the generic opcode.
;; Used by both `submit` (implicitly with contract-caller) and `get-signer-from-args`.
(define-read-only (hash-args
    (opcode (string-ascii 64))
    (uuid (string-ascii 36))
    (contract (optional principal))
  )
  (let (
      (structured-data { opcode: opcode, uuid: uuid, contract: contract })
      (data-hash (sha256 (unwrap! (to-consensus-buff? structured-data) ERR_CONSENSUS_BUFF)))
    )
    (ok (sha256 (concat structured-data-header data-hash)))
  )
)

;; Performs signature verification without checking consumption state or consuming the UUID.
;; Requires the intended contract principal to construct the correct hash.
(define-read-only (get-signer-from-args
    (signature (buff 65))
    (opcode (string-ascii 64))
    (uuid (string-ascii 36))
    (contract (optional principal))
  )
  (let
    (
      ;; Generate the hash using the provided arguments.
      ;; contract is already optional, so it's passed directly
      (hash (try! (hash-args opcode uuid contract)))
    )
    ;; Verify the signature against the hash.
    (get-signer-from-hash hash signature)
  )
)

;; Recovers the signer principal from a given *pre-computed* hash and signature.
(define-read-only (get-signer-from-hash (hash (buff 32)) (signature (buff 65)))
  (match (secp256k1-recover? hash signature)
    public-key (principal-of? public-key)
    error ERR_INVALID_SIGNATURE
  )
)