;; Title: wormhole-core
;; Version: Developer Preview 1
;; Check for latest version: https://github.com/hirosystems/stacks-pyth-bridge#latest-version
;; Report an issue: https://github.com/hirosystems/stacks-pyth-bridge/issues

;;;; Traits

;; Implements trait specified in wormhole-core-trait contract
(impl-trait .wormhole-core-trait.wormhole-core-trait)

;;;; Constants

;; Generic error
(define-constant ERR_PANIC (err u0))
;; VAA version not supported
(define-constant ERR_VAA_PARSING_VERSION (err u1001))
;; Unable to extract the guardian set-id from the VAA
(define-constant ERR_VAA_PARSING_GUARDIAN_SET (err u1002))
;; Unable to extract the number of signatures from the VAA
(define-constant ERR_VAA_PARSING_SIGNATURES_LEN (err u1003))
;; Unable to extract the signatures from the VAA
(define-constant ERR_VAA_PARSING_SIGNATURES (err u1004))
;; Unable to extract the timestamp from the VAA
(define-constant ERR_VAA_PARSING_TIMESTAMP (err u1005))
;; Unable to extract the nonce from the VAA
(define-constant ERR_VAA_PARSING_NONCE (err u1006))
;; Unable to extract the emitter chain from the VAA
(define-constant ERR_VAA_PARSING_EMITTER_CHAIN (err u1007))
;; Unable to extract the emitter address from the VAA
(define-constant ERR_VAA_PARSING_EMITTER_ADDRESS (err u1008))
;; Unable to extract the sequence from the VAA
(define-constant ERR_VAA_PARSING_SEQUENCE (err u1009))
;; Unable to extract the consistency level from the VAA
(define-constant ERR_VAA_PARSING_CONSISTENCY_LEVEL (err u1010))
;; Unable to extract the payload from the VAA
(define-constant ERR_VAA_PARSING_PAYLOAD (err u1011))
;; Unable to extract the hash the payload from the VAA
(define-constant ERR_VAA_HASHING_BODY (err u1012))
;; Number of valid signatures insufficient (min: 13/19)
(define-constant ERR_VAA_CHECKS_VERSION_UNSUPPORTED (err u1101))
;; Number of valid signatures insufficient (min: 13/19)
(define-constant ERR_VAA_CHECKS_THRESHOLD_SIGNATURE (err u1102))
;; Multiple signatures were issued by the same guardian
(define-constant ERR_VAA_CHECKS_REDUNDANT_SIGNATURE (err u1103))
;; Guardian set specified is expired
(define-constant ERR_VAA_CHECKS_GUARDIAN_SET_EXPIRED (err u1104))
;; Guardian signature not comprised in guardian set specified
(define-constant ERR_VAA_CHECKS_GUARDIAN_SET_CONSISTENCY (err u1105))
;; Guardian Set Update initiated by an unauthorized module
(define-constant ERR_GSU_PARSING_MODULE (err u1201))
;; Guardian Set Update initiated from an unauthorized module
(define-constant ERR_GSU_PARSING_ACTION (err u1202))
;; Guardian Set Update initiated from an unauthorized module
(define-constant ERR_GSU_PARSING_CHAIN (err u1203))
;; Guardian Set Update new index invalid
(define-constant ERR_GSU_PARSING_INDEX (err u1204))
;; Guardian Set Update length is invalid
(define-constant ERR_GSU_PARSING_GUARDIAN_LEN (err u1205))
;; Guardian Set Update guardians payload is malformatted
(define-constant ERR_GSU_PARSING_GUARDIANS_BYTES (err u1206))
;; Guardian Set Update uncompressed public keys invalid
(define-constant ERR_GSU_UNCOMPRESSED_PUBLIC_KEYS (err u1207))
;; Guardian Set Update initiated by an unauthorized module
(define-constant ERR_GSU_CHECK_MODULE (err u1301))
;; Guardian Set Update initiated from an unauthorized module
(define-constant ERR_GSU_CHECK_ACTION (err u1302))
;; Guardian Set Update initiated from an unauthorized module
(define-constant ERR_GSU_CHECK_CHAIN (err u1303))
;; Guardian Set Update new index invalid
(define-constant ERR_GSU_CHECK_INDEX (err u1304))

;;;; Data vars

;; Guardian Set Update uncompressed public keys invalid
(define-data-var guardian-set-initialized bool false)
;; Keep track of the active guardian set-id
(define-data-var active-guardian-set-id uint u0)

;;;; Data maps

;; Map tracking guardians set
(define-map guardian-sets 
  { set-id: uint } 
  (list 19 { compressed-public-key: (buff 33), uncompressed-public-key: (buff 64) }))

;;;; Public functions

;; @desc Parse a Verified Action Approval (VAA)
;; 
;; VAA Header
;; byte        version             (VAA Version)
;; u32         guardian_set_index  (Indicates which guardian set is signing)
;; u8          len_signatures      (Number of signatures stored)
;; [][66]byte  signatures          (Collection of ecdsa signatures)
;;
;; VAA Body
;; u32         timestamp           (Timestamp of the block where the source transaction occurred)
;; u32         nonce               (A grouping number)
;; u16         emitter_chain       (Wormhole ChainId of emitter contract)
;; [32]byte    emitter_address     (Emitter contract address, in Wormhole format)
;; u64         sequence            (Strictly increasing sequence, tied to emitter address & chain)
;; u8          consistency_level   (What finality level was reached before emitting this message)
;; []byte      payload             (VAA message content)
;;
;; @param vaa-bytes: 
(define-read-only (parse-vaa (vaa-bytes (buff 2048)))
  (let ((cursor-version (unwrap! (contract-call? .hk-cursor-v1 read-u8 { bytes: vaa-bytes, pos: u0 }) 
          ERR_VAA_PARSING_VERSION))
        (cursor-guardian-set-id (unwrap! (contract-call? .hk-cursor-v1 read-u32 (get next cursor-version)) 
          ERR_VAA_PARSING_GUARDIAN_SET))
        (cursor-signatures-len (unwrap! (contract-call? .hk-cursor-v1 read-u8 (get next cursor-guardian-set-id)) 
          ERR_VAA_PARSING_SIGNATURES_LEN))
        (cursor-signatures (fold 
          batch-read-signatures
          (list u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0)
          { 
              next: (get next cursor-signatures-len), 
              value: (list),
              iter: (get value cursor-signatures-len)
          }))
        (vaa-body-hash (keccak256 (keccak256 (get value (unwrap! (contract-call? .hk-cursor-v1 read-remaining-bytes-max-2048 (get next cursor-signatures))
          ERR_VAA_HASHING_BODY)))))
        (cursor-timestamp (unwrap! (contract-call? .hk-cursor-v1 read-u32 (get next cursor-signatures)) 
          ERR_VAA_PARSING_TIMESTAMP))
        (cursor-nonce (unwrap! (contract-call? .hk-cursor-v1 read-u32 (get next cursor-timestamp)) 
          ERR_VAA_PARSING_NONCE))
        (cursor-emitter-chain (unwrap! (contract-call? .hk-cursor-v1 read-u16 (get next cursor-nonce)) 
          ERR_VAA_PARSING_EMITTER_CHAIN))
        (cursor-emitter-address (unwrap! (contract-call? .hk-cursor-v1 read-buff-32 (get next cursor-emitter-chain)) 
          ERR_VAA_PARSING_EMITTER_ADDRESS))
        (cursor-sequence (unwrap! (contract-call? .hk-cursor-v1 read-u64 (get next cursor-emitter-address)) 
          ERR_VAA_PARSING_SEQUENCE))
        (cursor-consistency-level (unwrap! (contract-call? .hk-cursor-v1 read-u8 (get next cursor-sequence)) 
          ERR_VAA_PARSING_CONSISTENCY_LEVEL))
        (cursor-payload (unwrap! (contract-call? .hk-cursor-v1 read-remaining-bytes-max-2048 (get next cursor-consistency-level))
          ERR_VAA_PARSING_PAYLOAD))
        (public-keys-results (fold
          batch-recover-public-keys
          (get value cursor-signatures)
          {
              message-hash: vaa-body-hash,
              value: (list)
          })))
    (ok { 
        version: (get value cursor-version), 
        guardian-set-id: (get value cursor-guardian-set-id),
        signatures-len: (get value cursor-signatures-len),
        signatures: (get value cursor-signatures),
        timestamp: (get value cursor-timestamp),
        nonce: (get value cursor-nonce),
        emitter-chain: (get value cursor-emitter-chain),
        sequence: (get value cursor-sequence),
        consistency-level: (get value cursor-consistency-level),
        payload: (get value cursor-payload),
        guardians-public-keys: (get value public-keys-results),
        vaa-body-hash: vaa-body-hash
    })))

;; @desc Parse and check the validity of a Verified Action Approval (VAA)
;; @param vaa-bytes: 
(define-read-only (parse-and-verify-vaa (vaa-bytes (buff 2048)))
  (let ((vaa (try! (parse-vaa vaa-bytes)))
        (active-guardians (unwrap! (map-get? guardian-sets { set-id: (get guardian-set-id vaa) }) ERR_VAA_CHECKS_GUARDIAN_SET_CONSISTENCY))
        (signatures-from-active-guardians (fold batch-check-active-public-keys (get guardians-public-keys vaa)
          {
              active-guardians: active-guardians,
              value: (unwrap-panic (as-max-len? (list (unwrap-panic (as-max-len? 0x u33))) u20))
          })))
    ;; Ensure that the guardian-set-id is the active one
    (asserts! (is-eq (get guardian-set-id vaa) (var-get active-guardian-set-id)) ERR_VAA_CHECKS_GUARDIAN_SET_CONSISTENCY)
    ;; Ensure that version is supported (v1 only)
    (asserts! (is-eq (get version vaa) u1) ERR_VAA_CHECKS_VERSION_UNSUPPORTED)
    ;; Ensure that the count of valid signatures is >= 13
    (asserts! (>= (len (get value signatures-from-active-guardians)) u13) ERR_VAA_CHECKS_THRESHOLD_SIGNATURE)
    ;; Ensure that each guardian in signatures-from-active-guardians is unique
    ;; ERR_VAA_CHECKS_REDUNDANT_SIGNATURE
    ;; TODO: Ensure that the guardian set is not expired
    ;; ERR_VAA_CHECKS_GUARDIAN_SET_EXPIRED
    ;; Good to go!
    (ok vaa)))

;; @desc Update the active set of guardians 
;; @param guardian-set-vaa: VAA embedding the Guardian Set Update informations
;; @param uncompressed-public-keys: uncompressed public keys, used for recomputing
;; the addresses embedded in the VAA. `secp256k1-verify` returns a compressed 
;; public key, and uncompressing the key in clarity would be inefficient and expansive. 
(define-public (update-guardians-set (guardian-set-vaa (buff 2048)) (uncompressed-public-keys (list 19 (buff 64))))
  (let ((vaa (if (var-get guardian-set-initialized)
          (try! (parse-and-verify-vaa guardian-set-vaa))
          (try! (parse-vaa guardian-set-vaa))))
        (cursor-guardians-data (try! (parse-and-verify-guardians-set (get payload vaa))))
        (set-id (get new-index (get value cursor-guardians-data)))
        (eth-addresses (get guardians-eth-addresses (get value cursor-guardians-data)))
        (acc (unwrap-panic (as-max-len? (list { 
          compressed-public-key: (unwrap-panic (as-max-len? 0x u33)), 
          uncompressed-public-key: (unwrap-panic (as-max-len? 0x u64))
        }) u20)))
        (consolidated-public-keys (fold 
          check-and-consolidate-public-keys 
          uncompressed-public-keys 
          { success: true, cursor: u0, eth-addresses: eth-addresses, result: acc }))
        )
    ;; Ensure that enough uncompressed-public-keys were provided
    (asserts! (is-eq (len uncompressed-public-keys) (len eth-addresses)) 
      ERR_GSU_UNCOMPRESSED_PUBLIC_KEYS)
    ;; Check guardians uncompressed-public-keys
    (asserts! (get success consolidated-public-keys)
      ERR_GSU_UNCOMPRESSED_PUBLIC_KEYS)

    (map-set guardian-sets { set-id: set-id } 
      (unwrap-panic (as-max-len? 
        (unwrap-panic (slice? (get result consolidated-public-keys) u1 (len (get result consolidated-public-keys)))) 
        u19)))
    (var-set active-guardian-set-id set-id)
    (var-set guardian-set-initialized true)
    (ok {
      vaa: vaa,
      consolidated-public-keys: consolidated-public-keys,
    })))

(define-public (get-active-guardian-set) 
  (let ((set-id (var-get active-guardian-set-id))
        (guardians (unwrap-panic (map-get? guardian-sets { set-id: set-id }))))
      (ok {
        set-id: set-id,
        guardians: guardians
      })))

;;;; Private functions

;; @desc Foldable function admitting an uncompressed 64 byts public key as an input, producing a record { uncompressed-public-key, compressed-public-key }
(define-private (check-and-consolidate-public-keys 
      (uncompressed-public-key (buff 64)) 
      (acc { success: bool, cursor: uint, eth-addresses: (list 19 (buff 20)), result: (list 20 { compressed-public-key: (buff 33), uncompressed-public-key: (buff 64)})}))
  (let ((eth-address (unwrap-panic (element-at? (get eth-addresses acc) (get cursor acc))))
        (compressed-public-key (compress-public-key uncompressed-public-key))
        (entry (if (is-eth-address-matching-public-key uncompressed-public-key eth-address)
            { compressed-public-key: compressed-public-key, uncompressed-public-key: uncompressed-public-key }
            { compressed-public-key: 0x, uncompressed-public-key: 0x })))
    {
      cursor: (+ u1 (get cursor acc)),
      eth-addresses: (get eth-addresses acc),
      success: true,
      result: (unwrap-panic (as-max-len? (append (get result acc) entry) u20)),
    }))

;; @desc Foldable function admitting an uncompressed 64 byts public key as an input, producing a record { uncompressed-public-key, compressed-public-key }
(define-private (batch-recover-public-keys 
      (entry { guardian-id: uint, signature: (buff 65) }) 
      (acc { message-hash: (buff 32), value: (list 19 { recovered-compressed-public-key: (response (buff 33) uint), guardian-id: uint }) }))
  (let ((recovered-compressed-public-key (secp256k1-recover? (get message-hash acc) (get signature entry)))
        (updated-public-keys (append (get value acc) { recovered-compressed-public-key: recovered-compressed-public-key, guardian-id: (get guardian-id entry) } )))
    { 
      message-hash: (get message-hash acc), 
      value: (unwrap-panic (as-max-len? updated-public-keys u19)) 
    }))

;; @desc Foldable function evaluating signatures from a list of { guardian-id: u8, signature: (buff 65) }, returning a list of recovered public-keys
(define-private (batch-check-active-public-keys 
      (entry { recovered-compressed-public-key: (response (buff 33) uint), guardian-id: uint }) 
      (acc { active-guardians: (list 19 { compressed-public-key: (buff 33), uncompressed-public-key: (buff 64) }), value: (list 20 (buff 33))}))
   (let ((compressed-public-key (get compressed-public-key (unwrap-panic (element-at? (get active-guardians acc) (get guardian-id entry))))))
     (match (get recovered-compressed-public-key entry) 
        recovered-public-key (if (is-eq recovered-public-key compressed-public-key)
          { value: (unwrap-panic (as-max-len? (append (get value acc) recovered-public-key) u20)), active-guardians: (get active-guardians acc) }
          acc)
        err acc)))

;; @desc Foldable function parsing a sequence of bytes into a list of { guardian-id: u8, signature: (buff 65) } 
(define-private (batch-read-signatures 
      (entry uint) 
      (acc { next: { bytes: (buff 4096), pos: uint }, iter: uint, value: (list 19 { guardian-id: uint, signature: (buff 65) })}))
  (if (is-eq (get iter acc) u0)
    { iter: u0, next: (get next acc), value: (get value acc) }
    (let ((cursor-guardian-id (unwrap-panic (contract-call? .hk-cursor-v1 read-u8 (get next acc))))
          (cursor-signature (unwrap-panic (contract-call? .hk-cursor-v1 read-buff-65 (get next cursor-guardian-id)))))
      { 
        iter: (- (get iter acc) u1), 
        next: (get next cursor-signature), 
        value: 
          (unwrap-panic (as-max-len? (append (get value acc) { guardian-id: (get value cursor-guardian-id), signature: (get value cursor-signature) }) u19))
      })))

;; @desc Convert an uncompressed public key (64 bytes) into a compressed public key (33 bytes)
(define-private (compress-public-key (uncompressed-public-key (buff 64)))
    (if (is-eq (len uncompressed-public-key) u64)
      (let ((x-coordinate (unwrap-panic (slice? uncompressed-public-key u0 u32)))
            (y-coordinate-parity (buff-to-uint-be (unwrap-panic (element-at? uncompressed-public-key u63)))))
        (unwrap-panic (as-max-len? (concat (if (is-eq (mod y-coordinate-parity u2) u0) 0x02 0x03) x-coordinate) u33)))
      (unwrap-panic (as-max-len? 0x u33))))

(define-private (is-eth-address-matching-public-key (uncompressed-public-key (buff 64)) (eth-address (buff 20)))
  (is-eq (unwrap-panic (slice? (keccak256 uncompressed-public-key) u12 u32)) eth-address))

(define-private (parse-guardian (cue-position uint) (acc { bytes: (buff 2048), result: (list 20 (buff 20))}))
  (let (
    (cursor-address-bytes (unwrap-panic (contract-call? .hk-cursor-v1 read-buff-20 { bytes: (get bytes acc), pos: cue-position })))
  )
  {
    bytes: (get bytes acc),
    result: (unwrap-panic (as-max-len? (append (get result acc) (get value cursor-address-bytes)) u20))
  }))

;; @desc Update the active set of guardians 
;; @param expiration-time:
;; @param guardians:
(define-private (insert-entry-in-guardians (expiration-time uint) (new-set-id uint) (new-guardians (list 19 { uncompressed-public-key: (buff 64), compressed-public-key: (buff 33) })))
  (let ((set-id (var-get active-guardian-set-id)))
    ;; TODO: check authorization
    ;; Update set
    ;; (fold add-guardian-to-guardian-set guardians { id: u0, set-id: new-set-id })
    ;; Update set-id
    ;; (var-set current-guardian-set-id new-set-id)
    { set-id: new-set-id, guardians: new-guardians }))

;; @desc Parse and verify payload's VAA  
(define-private (parse-and-verify-guardians-set (bytes (buff 2048)))
  (let 
      ((cursor-module (unwrap! (contract-call? .hk-cursor-v1 read-buff-32 { bytes: bytes, pos: u0 }) 
          ERR_GSU_PARSING_MODULE))
      (cursor-action (unwrap! (contract-call? .hk-cursor-v1 read-u8 (get next cursor-module)) 
          ERR_GSU_PARSING_ACTION))
      (cursor-chain (unwrap! (contract-call? .hk-cursor-v1 read-u16 (get next cursor-action)) 
          ERR_GSU_PARSING_CHAIN))
      (cursor-new-index (unwrap! (contract-call? .hk-cursor-v1 read-u32 (get next cursor-chain)) 
          ERR_GSU_PARSING_INDEX))
      (cursor-guardians-count (unwrap! (contract-call? .hk-cursor-v1 read-u8 (get next cursor-new-index)) 
          ERR_GSU_PARSING_GUARDIAN_LEN))
      (guardians-bytes (unwrap! (slice? bytes (get pos (get next cursor-guardians-count)) (+ (get pos (get next cursor-guardians-count)) (* (get value cursor-guardians-count) u20)))
          ERR_GSU_PARSING_GUARDIANS_BYTES))
      (guardians-cues (get result (fold is-guardian-cue guardians-bytes { cursor: u0, result: (unwrap-panic (as-max-len? (list u0) u19)) })))
      (eth-addresses-init (unwrap-panic (as-max-len? (list (unwrap-panic (as-max-len? 0x u20))) u19)))
      (eth-addresses (get result (fold parse-guardian guardians-cues { bytes: guardians-bytes, result: eth-addresses-init }))))
    ;; Ensure that this message was emitted from authorized module
    (asserts! (is-eq (get value cursor-module) 0x00000000000000000000000000000000000000000000000000000000436f7265) 
      ERR_GSU_CHECK_MODULE)
    ;; Ensure that this message is matching the adequate action
    (asserts! (is-eq (get value cursor-action) u2) 
      ERR_GSU_CHECK_ACTION)
    ;; Ensure that this message is matching the adequate action
    (asserts! (is-eq (get value cursor-chain) u0) 
      ERR_GSU_CHECK_CHAIN)
    ;; Ensure that next index > current index
    (asserts! (> (get value cursor-new-index) (var-get active-guardian-set-id)) 
      ERR_GSU_CHECK_INDEX)
    ;; Good to go!
    (ok {
      value: {
        guardians-eth-addresses: (unwrap-panic (as-max-len? (unwrap-panic (slice? eth-addresses u1 (+ u1 (get value cursor-guardians-count)))) u19)),
        module: (get value cursor-module),
        action: (get value cursor-action),
        chain: (get value cursor-chain),
        new-index: (get value cursor-new-index)
      },
      next: { 
        bytes: bytes, 
        pos: (+ (get pos (get next cursor-guardians-count)) 
                (* (get value cursor-guardians-count) u20)) 
      }
    })))

(define-private (is-guardian-cue (byte (buff 1)) (acc { cursor: uint, result: (list 19 uint) }))
  (if (and (is-eq u0 (mod (get cursor acc) u20)) (> (get cursor acc) u0) )
    { 
      cursor: (+ u1 (get cursor acc)), 
      result: (unwrap-panic (as-max-len? (append (get result acc) (get cursor acc)) u19)),
    }
    {
      cursor: (+ u1 (get cursor acc)), 
      result: (get result acc),
    }))