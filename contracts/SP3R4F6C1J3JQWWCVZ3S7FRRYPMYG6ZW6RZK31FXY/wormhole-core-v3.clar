;; Title: wormhole-core
;; Version: v3
;; Check for latest version: https://github.com/Trust-Machines/stacks-pyth-bridge#latest-version
;; Report an issue: https://github.com/Trust-Machines/stacks-pyth-bridge/issues

;;;; Traits

;; Implements trait specified in wormhole-core-trait contract
(impl-trait .wormhole-traits-v1.core-trait)

;;;; Constants

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
;; Guardian signature not comprised in guardian set specified
(define-constant ERR_VAA_CHECKS_GUARDIAN_SET_CONSISTENCY (err u1103))
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
;; Guardian Set Update guardians payload is malformed
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
;; Guardian Set Update emission payload unauthorized
(define-constant ERR_GSU_CHECK_EMITTER (err u1305))
;; First guardian set is not being updated by the deployer
(define-constant ERR_NOT_DEPLOYER (err u1306))
;; Overlay present in vaa bytes
(define-constant ERR_GSU_CHECK_OVERLAY (err u1307))
;; Empty guardian set
(define-constant ERR_EMPTY_GUARDIAN_SET (err u1308))
;; Guardian Set Update emission payload unauthorized
(define-constant ERR_DUPLICATED_GUARDIAN_ADDRESSES (err u1309))
;; Unable to get stacks timestamp
(define-constant ERR_STACKS_TIMESTAMP (err u1310))

;; Guardian set upgrade emitting address
(define-constant GSU-EMITTING-ADDRESS 0x0000000000000000000000000000000000000000000000000000000000000004)
;; Guardian set upgrade emitting chain
(define-constant GSU-EMITTING-CHAIN u1)
;; Stacks chain id attributed by Pyth
(define-constant EXPECTED_CHAIN_ID (if is-in-mainnet 0xea86 0xc377))
;; Core string module
(define-constant CORE_STRING_MODULE 0x00000000000000000000000000000000000000000000000000000000436f7265)
;; Guardian set update action
(define-constant ACTION_GUARDIAN_SET_UPDATE u2)
;; Core chain ID
(define-constant CORE_CHAIN_ID u0)
;; Guardian eth address size
(define-constant GUARDIAN_ETH_ADDRESS_SIZE u20)
;; 24 hours in seconds
(define-constant TWENTY_FOUR_HOURS u86400)
;;;; Data vars

;; Guardian Set Update uncompressed public keys invalid
(define-data-var guardian-set-initialized bool false)
;; Contract deployer
(define-constant deployer contract-caller)
;; Keep track of the active guardian set-id
(define-data-var active-guardian-set-id uint u0)
;; Keep track of exiting guardian set
(define-data-var previous-guardian-set {set-id: uint, expires-at: uint} {set-id: u0, expires-at: u0})

;;;; Data maps

;; Map tracking guardians set
(define-map guardian-sets uint (list 19 { compressed-public-key: (buff 33), uncompressed-public-key: (buff 64) }))

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
(define-read-only (parse-vaa (vaa-bytes (buff 8192)))
  (let ((cursor-version (unwrap! (contract-call? 'SP2J933XB2CP2JQ1A4FGN8JA968BBG3NK3EKZ7Q9F.hk-cursor-v2 read-uint-8 { bytes: vaa-bytes, pos: u0 }) 
          ERR_VAA_PARSING_VERSION))
        (cursor-guardian-set-id (unwrap! (contract-call? 'SP2J933XB2CP2JQ1A4FGN8JA968BBG3NK3EKZ7Q9F.hk-cursor-v2 read-uint-32 (get next cursor-version)) 
          ERR_VAA_PARSING_GUARDIAN_SET))
        (cursor-signatures-len (unwrap! (contract-call? 'SP2J933XB2CP2JQ1A4FGN8JA968BBG3NK3EKZ7Q9F.hk-cursor-v2 read-uint-8 (get next cursor-guardian-set-id)) 
          ERR_VAA_PARSING_SIGNATURES_LEN))
        (cursor-signatures (fold batch-read-signatures
          (list u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0)
          { 
              next: (get next cursor-signatures-len), 
              value: (list),
              iter: (get value cursor-signatures-len)
          }))
        (vaa-body-hash (keccak256 (keccak256 (get value (unwrap! (contract-call? 'SP2J933XB2CP2JQ1A4FGN8JA968BBG3NK3EKZ7Q9F.hk-cursor-v2 read-buff-8192-max (get next cursor-signatures) none)
          ERR_VAA_HASHING_BODY)))))
        (cursor-timestamp (unwrap! (contract-call? 'SP2J933XB2CP2JQ1A4FGN8JA968BBG3NK3EKZ7Q9F.hk-cursor-v2 read-uint-32 (get next cursor-signatures)) 
          ERR_VAA_PARSING_TIMESTAMP))
        (cursor-nonce (unwrap! (contract-call? 'SP2J933XB2CP2JQ1A4FGN8JA968BBG3NK3EKZ7Q9F.hk-cursor-v2 read-uint-32 (get next cursor-timestamp)) 
          ERR_VAA_PARSING_NONCE))
        (cursor-emitter-chain (unwrap! (contract-call? 'SP2J933XB2CP2JQ1A4FGN8JA968BBG3NK3EKZ7Q9F.hk-cursor-v2 read-uint-16 (get next cursor-nonce)) 
          ERR_VAA_PARSING_EMITTER_CHAIN))
        (cursor-emitter-address (unwrap! (contract-call? 'SP2J933XB2CP2JQ1A4FGN8JA968BBG3NK3EKZ7Q9F.hk-cursor-v2 read-buff-32 (get next cursor-emitter-chain)) 
          ERR_VAA_PARSING_EMITTER_ADDRESS))
        (cursor-sequence (unwrap! (contract-call? 'SP2J933XB2CP2JQ1A4FGN8JA968BBG3NK3EKZ7Q9F.hk-cursor-v2 read-uint-64 (get next cursor-emitter-address)) 
          ERR_VAA_PARSING_SEQUENCE))
        (cursor-consistency-level (unwrap! (contract-call? 'SP2J933XB2CP2JQ1A4FGN8JA968BBG3NK3EKZ7Q9F.hk-cursor-v2 read-uint-8 (get next cursor-sequence)) 
          ERR_VAA_PARSING_CONSISTENCY_LEVEL))
        (cursor-payload (unwrap! (contract-call? 'SP2J933XB2CP2JQ1A4FGN8JA968BBG3NK3EKZ7Q9F.hk-cursor-v2 read-buff-8192-max (get next cursor-consistency-level) none)
          ERR_VAA_PARSING_PAYLOAD))
        (public-keys-results (fold batch-recover-public-keys
          (get value cursor-signatures)
          {
              message-hash: vaa-body-hash,
              value: (list)
          })))
    (asserts! (is-eq (get pos (get next cursor-payload)) (len vaa-bytes)) ERR_GSU_CHECK_OVERLAY)
    (print { payload: (get value cursor-payload) })
    (ok { 
        vaa: {
          version: (get value cursor-version), 
          guardian-set-id: (get value cursor-guardian-set-id),
          signatures-len: (get value cursor-signatures-len),
          signatures: (get value cursor-signatures),
          timestamp: (get value cursor-timestamp),
          nonce: (get value cursor-nonce),
          emitter-chain: (get value cursor-emitter-chain),
          emitter-address: (get value cursor-emitter-address),
          sequence: (get value cursor-sequence),
          consistency-level: (get value cursor-consistency-level),
          payload: (get value cursor-payload),
        },
        recovered-public-keys: (get value public-keys-results),
    })))

;; @desc Parse and check the validity of a Verified Action Approval (VAA)
;; @param vaa-bytes: 
(define-read-only (parse-and-verify-vaa (vaa-bytes (buff 8192)))
    (let (
        (message (try! (parse-vaa vaa-bytes)))
        (guardian-set-id (get guardian-set-id (get vaa message)))
      )
      ;; Ensure that the guardian-set-id is the active one or unexpired previous one
      (asserts! (try! (is-valid-guardian-set guardian-set-id)) ERR_VAA_CHECKS_GUARDIAN_SET_CONSISTENCY)
    (let ((active-guardians (unwrap! (map-get? guardian-sets guardian-set-id) ERR_VAA_CHECKS_GUARDIAN_SET_CONSISTENCY))
          (signatures-from-active-guardians (fold batch-check-active-public-keys (get recovered-public-keys message)
            {
                active-guardians: active-guardians,
                result: (list)
            })))
      ;; Ensure that version is supported (v1 only)
      (asserts! (is-eq (get version (get vaa message)) u1) 
        ERR_VAA_CHECKS_VERSION_UNSUPPORTED)
      ;; Ensure that the count of valid signatures is >= 13
      (asserts! (>= (len (get result signatures-from-active-guardians)) (get-quorum (len active-guardians)))
        ERR_VAA_CHECKS_THRESHOLD_SIGNATURE)
      ;; Good to go!
      (ok (get vaa message)))))

;; @desc Update the active set of guardians 
;; @param guardian-set-vaa: VAA embedding the Guardian Set Update information
;; @param uncompressed-public-keys: uncompressed public keys, used for recomputing
;; the addresses embedded in the VAA. `secp256k1-verify` returns a compressed 
;; public key, and uncompressing the key in clarity would be inefficient and expensive. 
(define-public (update-guardians-set (guardian-set-vaa (buff 2048)) (uncompressed-public-keys (list 19 (buff 64))))
  (let ((vaa (if (var-get guardian-set-initialized)
          (try! (parse-and-verify-vaa guardian-set-vaa))
          (begin
            (asserts! (is-eq contract-caller deployer) ERR_NOT_DEPLOYER)
            (get vaa (try! (parse-vaa guardian-set-vaa)))
          )))
        (cursor-guardians-data (try! (parse-and-verify-guardians-set (get payload vaa))))
        (set-id (get new-index cursor-guardians-data))
        (eth-addresses (get guardians-eth-addresses cursor-guardians-data))
        (consolidated-public-keys (fold check-and-consolidate-public-keys 
          uncompressed-public-keys 
          { cursor: u0, eth-addresses: eth-addresses, result: (list) }))
        (result (get result consolidated-public-keys))
        )
    ;; Ensure that enough uncompressed-public-keys were provided
    (try! (fold is-valid-guardian-entry result (ok true)))
    (asserts! (is-eq (len uncompressed-public-keys) (len eth-addresses)) 
      ERR_GSU_UNCOMPRESSED_PUBLIC_KEYS)
    ;; Check emitting address
    (asserts! (is-eq (get emitter-address vaa) GSU-EMITTING-ADDRESS) ERR_GSU_CHECK_EMITTER)
    ;; Check emitting address
    (asserts! (is-eq (get emitter-chain vaa) GSU-EMITTING-CHAIN) ERR_GSU_CHECK_EMITTER)
    ;; ensure guardian set has atleast one member
    (asserts! (>= (len result) u1) ERR_EMPTY_GUARDIAN_SET)
    ;; Update storage
    (map-set guardian-sets set-id result)
    (try! (set-new-guardian-set-id set-id))
    (var-set guardian-set-initialized true)
    ;; Emit Event
    (print { 
      type: "guardians-set", 
      action: "updated",
      id: set-id,
      data: { guardians-eth-addresses: eth-addresses, guardians-public-keys: uncompressed-public-keys }})
    (ok {
      vaa: vaa,
      result: { 
        guardians-eth-addresses: eth-addresses, 
        guardians-public-keys: uncompressed-public-keys 
      }
    })))

(define-read-only (get-active-guardian-set) 
  (let ((set-id (var-get active-guardian-set-id))
        (guardians (unwrap-panic (map-get? guardian-sets set-id))))
      (ok {
        set-id: set-id,
        guardians: guardians
      })))

;;;; Private functions

;; @desc Foldable function admitting an uncompressed 64 bytes public key as an input, producing a record { uncompressed-public-key, compressed-public-key }
(define-private (check-and-consolidate-public-keys 
      (uncompressed-public-key (buff 64)) 
      (acc { 
        cursor: uint, 
        eth-addresses: (list 19 (buff 20)), 
        result: (list 19 { compressed-public-key: (buff 33), uncompressed-public-key: (buff 64)})
      }))
  (let ((eth-address (unwrap-panic (element-at? (get eth-addresses acc) (get cursor acc))))
        (compressed-public-key (compress-public-key uncompressed-public-key))
        (entry (if (is-eth-address-matching-public-key uncompressed-public-key eth-address)
            { compressed-public-key: compressed-public-key, uncompressed-public-key: uncompressed-public-key }
            { compressed-public-key: 0x, uncompressed-public-key: 0x })))
    {
      cursor: (+ u1 (get cursor acc)),
      eth-addresses: (get eth-addresses acc),
      result: (unwrap-panic (as-max-len? (append (get result acc) entry) u19)),
    }))

;; @desc Foldable function admitting an guardian input and their signature as an input, producing a record { recovered-compressed-public-key }
(define-private (batch-recover-public-keys 
      (entry { guardian-id: uint, signature: (buff 65) }) 
      (acc { message-hash: (buff 32), value: (list 19 { recovered-compressed-public-key: (buff 33), guardian-id: uint }) }))
  (let ((recovered-compressed-public-key (secp256k1-recover? (get message-hash acc) (get signature entry)))
        (updated-public-keys (match recovered-compressed-public-key 
            public-key (append (get value acc) { recovered-compressed-public-key: public-key, guardian-id: (get guardian-id entry) } )
            error (get value acc))))
    { 
      message-hash: (get message-hash acc), 
      value: (unwrap-panic (as-max-len? updated-public-keys u19)) 
    }))

;; @desc Foldable function evaluating signatures from a list of { guardian-id: u8, signature: (buff 65) }, returning a list of recovered public-keys
(define-private (batch-check-active-public-keys 
      (entry { recovered-compressed-public-key: (buff 33), guardian-id: uint }) 
      (acc { 
        active-guardians: (list 19 { compressed-public-key: (buff 33), uncompressed-public-key: (buff 64) }), 
        result: (list 19 (buff 33))
      }))
   (let ((compressed-public-key (get compressed-public-key (unwrap-panic (element-at? (get active-guardians acc) (get guardian-id entry))))))
     (if (and 
            (is-eq (get recovered-compressed-public-key entry) compressed-public-key)
            (is-none (index-of? (get result acc) (get recovered-compressed-public-key entry))))
          { 
            result: (unwrap-panic (as-max-len? (append (get result acc) (get recovered-compressed-public-key entry)) u19)), 
            active-guardians: (get active-guardians acc)
          }
          acc)))

;; @desc Foldable function parsing a sequence of bytes into a list of { guardian-id: u8, signature: (buff 65) } 
(define-private (batch-read-signatures 
      (entry uint) 
      (acc { next: { bytes: (buff 8192), pos: uint }, iter: uint, value: (list 19 { guardian-id: uint, signature: (buff 65) })}))
  (if (is-eq (get iter acc) u0)
    { iter: u0, next: (get next acc), value: (get value acc) }
    (let ((cursor-guardian-id (unwrap-panic (contract-call? 'SP2J933XB2CP2JQ1A4FGN8JA968BBG3NK3EKZ7Q9F.hk-cursor-v2 read-uint-8 (get next acc))))
          (cursor-signature (unwrap-panic (contract-call? 'SP2J933XB2CP2JQ1A4FGN8JA968BBG3NK3EKZ7Q9F.hk-cursor-v2 read-buff-65 (get next cursor-guardian-id)))))
      { 
        iter: (- (get iter acc) u1), 
        next: (get next cursor-signature), 
        value: 
          (unwrap-panic (as-max-len? (append (get value acc) { guardian-id: (get value cursor-guardian-id), signature: (get value cursor-signature) }) u19))
      })))

;; @desc Convert an uncompressed public key (64 bytes) into a compressed public key (33 bytes)
(define-private (compress-public-key (uncompressed-public-key (buff 64)))
  (if (is-eq 0x uncompressed-public-key) 
    0x 
    (let ((x-coordinate (unwrap-panic (slice? uncompressed-public-key u0 u32)))
          (y-coordinate-parity (buff-to-uint-be (unwrap-panic (element-at? uncompressed-public-key u63)))))
      (unwrap-panic (as-max-len? (concat (if (is-eq (mod y-coordinate-parity u2) u0) 0x02 0x03) x-coordinate) u33)))))

(define-private (is-eth-address-matching-public-key (uncompressed-public-key (buff 64)) (eth-address (buff 20)))
  (is-eq (unwrap-panic (slice? (keccak256 uncompressed-public-key) u12 u32)) eth-address))

(define-private (parse-guardian (cue-position uint) (acc { bytes: (buff 8192), result: (list 19 (buff 20))}))
  (let (
    (cursor-address-bytes (unwrap-panic (contract-call? 'SP2J933XB2CP2JQ1A4FGN8JA968BBG3NK3EKZ7Q9F.hk-cursor-v2 read-buff-20 { bytes: (get bytes acc), pos: cue-position })))
  )
  (if (is-none (index-of? (get result acc) (get value cursor-address-bytes)))
    {
      bytes: (get bytes acc),
      result: (unwrap-panic (as-max-len? (append (get result acc) (get value cursor-address-bytes)) u19))
    }
    acc
  )))

;; @desc Parse and verify payload's VAA  
(define-private (parse-and-verify-guardians-set (bytes (buff 8192)))
  (let 
      ((cursor-module (unwrap! (contract-call? 'SP2J933XB2CP2JQ1A4FGN8JA968BBG3NK3EKZ7Q9F.hk-cursor-v2 read-buff-32 { bytes: bytes, pos: u0 }) 
          ERR_GSU_PARSING_MODULE))
      (cursor-action (unwrap! (contract-call? 'SP2J933XB2CP2JQ1A4FGN8JA968BBG3NK3EKZ7Q9F.hk-cursor-v2 read-uint-8 (get next cursor-module)) 
          ERR_GSU_PARSING_ACTION))
      (cursor-chain (unwrap! (contract-call? 'SP2J933XB2CP2JQ1A4FGN8JA968BBG3NK3EKZ7Q9F.hk-cursor-v2 read-uint-16 (get next cursor-action)) 
          ERR_GSU_PARSING_CHAIN))
      (cursor-new-index (unwrap! (contract-call? 'SP2J933XB2CP2JQ1A4FGN8JA968BBG3NK3EKZ7Q9F.hk-cursor-v2 read-uint-32 (get next cursor-chain)) 
          ERR_GSU_PARSING_INDEX))
      (cursor-guardians-count (unwrap! (contract-call? 'SP2J933XB2CP2JQ1A4FGN8JA968BBG3NK3EKZ7Q9F.hk-cursor-v2 read-uint-8 (get next cursor-new-index)) 
          ERR_GSU_PARSING_GUARDIAN_LEN))
      (guardians-bytes (unwrap! (contract-call? 'SP2J933XB2CP2JQ1A4FGN8JA968BBG3NK3EKZ7Q9F.hk-cursor-v2 read-buff-8192-max (get next cursor-guardians-count) (some (* (get value cursor-guardians-count) GUARDIAN_ETH_ADDRESS_SIZE))) 
          ERR_GSU_PARSING_GUARDIANS_BYTES))
      (guardians-cues (get result (fold is-guardian-cue (get value guardians-bytes) { cursor: u0, result: (list) })))
      (eth-addresses (get result (fold parse-guardian guardians-cues { bytes: (get value guardians-bytes), result: (list) }))))
    (asserts! (is-eq (get pos (get next guardians-bytes)) (len bytes)) ERR_GSU_CHECK_OVERLAY)
    ;; Ensure there are no duplicated addresses
    (asserts! (is-eq (len eth-addresses) (get value cursor-guardians-count)) ERR_DUPLICATED_GUARDIAN_ADDRESSES)
    ;; Ensure that this message was emitted from authorized module
    (asserts! (is-eq (get value cursor-module) CORE_STRING_MODULE) 
      ERR_GSU_CHECK_MODULE)
    ;; Ensure that this message is matching the adequate action
    (asserts! (is-eq (get value cursor-action) ACTION_GUARDIAN_SET_UPDATE) 
      ERR_GSU_CHECK_ACTION)
    ;; Ensure that this message is matching the expected chain
    (asserts! (or (is-eq (get value cursor-chain) (buff-to-uint-be EXPECTED_CHAIN_ID)) (is-eq (get value cursor-chain) CORE_CHAIN_ID) ) ERR_GSU_CHECK_CHAIN)
    (if (var-get guardian-set-initialized)
      ;; Ensure that next index = current index + 1
      (asserts! (is-eq (get value cursor-new-index) (+ u1 (var-get active-guardian-set-id))) ERR_GSU_CHECK_INDEX)
      ;; Ensure that next index > current index
      (asserts! (> (get value cursor-new-index) (var-get active-guardian-set-id)) ERR_GSU_CHECK_INDEX)
    )
    
    ;; Good to go!
    (ok {
        guardians-eth-addresses: eth-addresses,
        module: (get value cursor-module),
        action: (get value cursor-action),
        chain: (get value cursor-chain),
        new-index: (get value cursor-new-index)
      })))

(define-private (get-quorum (guardian-set-size uint))
  (+ (/ (* guardian-set-size u2) u3) u1))

(define-private (is-guardian-cue (byte (buff 1)) (acc { cursor: uint, result: (list 19 uint) }))
  (if (is-eq u0 (mod (get cursor acc) GUARDIAN_ETH_ADDRESS_SIZE))
    { 
      cursor: (+ u1 (get cursor acc)), 
      result: (unwrap-panic (as-max-len? (append (get result acc) (get cursor acc)) u19)),
    }
    {
      cursor: (+ u1 (get cursor acc)), 
      result: (get result acc),
    }))

(define-private (is-valid-guardian-entry (entry { compressed-public-key: (buff 33), uncompressed-public-key: (buff 64)}) (prev-res (response bool uint)))
  (begin 
    (try! prev-res)
    (let (
      (compressed (get compressed-public-key entry))
      (uncompressed (get uncompressed-public-key entry)))
      (if (or (is-eq 0x compressed) (is-eq 0x uncompressed))
        ERR_GSU_PARSING_GUARDIAN_LEN
        (ok true)
      )
    )
  )
)

(define-private (set-new-guardian-set-id (new-set-id uint))
  (if (var-get guardian-set-initialized)
    (let (
        (latest-stacks-timestamp (unwrap! (get-stacks-block-info? time (- stacks-block-height u1)) ERR_STACKS_TIMESTAMP))
        (previous-set-expires-at (+ TWENTY_FOUR_HOURS latest-stacks-timestamp))
      )
      (var-set previous-guardian-set {
          set-id: (var-get active-guardian-set-id),
          expires-at: previous-set-expires-at
        })
      (var-set active-guardian-set-id new-set-id)
      (ok true)
    )
    (begin (var-set active-guardian-set-id new-set-id) (ok true))
  )
)

(define-private (is-valid-guardian-set (set-id uint))
  (if (is-eq (var-get active-guardian-set-id) set-id)
    (ok true)
    (let (
      (prev-guardian-set (var-get previous-guardian-set))
      (prev-guardian-set-id (get set-id prev-guardian-set))
      (prev-guardian-set-expires-at (get expires-at prev-guardian-set))
      (latest-stacks-timestamp (unwrap! (get-stacks-block-info? time (- stacks-block-height u1)) ERR_STACKS_TIMESTAMP))
    ) (ok (and (is-eq prev-guardian-set-id set-id) (>= prev-guardian-set-expires-at latest-stacks-timestamp))))
  )
)
