;; Title: wormhole-core
;; Version: v4
;; Check for latest version: https://github.com/Trust-Machines/stacks-pyth-bridge#latest-version
;; Report an issue: https://github.com/Trust-Machines/stacks-pyth-bridge/issues

;;;; Traits

;; Implements trait specified in wormhole-core-trait contract
(impl-trait .wormhole-traits-v2.core-trait)

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
;; signature data size
(define-constant SIGNATURE_DATA_SIZE u66)
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
	(let ((vaa-bytes-len (len vaa-bytes))
		(version (unwrap! (read-uint-8 vaa-bytes u0) ERR_VAA_PARSING_VERSION))
		(guardian-set-id (unwrap! (read-uint-32 vaa-bytes u1) ERR_VAA_PARSING_GUARDIAN_SET))
		(signatures-len (unwrap! (read-uint-8 vaa-bytes u5) ERR_VAA_PARSING_SIGNATURES_LEN))
		(signatures-offset (+ u6 (* signatures-len SIGNATURE_DATA_SIZE)))
		(signatures (map read-one-signature 
			(unwrap-panic (slice? (list 
				(default-to 0x (slice? vaa-bytes u6 u72))
				(default-to 0x (slice? vaa-bytes u72 u138))
				(default-to 0x (slice? vaa-bytes u138 u204))
				(default-to 0x (slice? vaa-bytes u204 u270))
				(default-to 0x (slice? vaa-bytes u270 u336))
				(default-to 0x (slice? vaa-bytes u336 u402))
				(default-to 0x (slice? vaa-bytes u402 u468))
				(default-to 0x (slice? vaa-bytes u468 u534))
				(default-to 0x (slice? vaa-bytes u534 u600))
				(default-to 0x (slice? vaa-bytes u600 u666))
				(default-to 0x (slice? vaa-bytes u666 u732))
				(default-to 0x (slice? vaa-bytes u732 u798))
				(default-to 0x (slice? vaa-bytes u798 u864))
				(default-to 0x (slice? vaa-bytes u864 u930))
				(default-to 0x (slice? vaa-bytes u930 u996))
				(default-to 0x (slice? vaa-bytes u996 u1062))
				(default-to 0x (slice? vaa-bytes u1062 u1128))
				(default-to 0x (slice? vaa-bytes u1128 u1194))
				(default-to 0x (slice? vaa-bytes u1194 u1260))) u0 signatures-len))
		))
		(vaa-body-hash (keccak256 (keccak256 (unwrap! (slice? vaa-bytes signatures-offset vaa-bytes-len) ERR_VAA_HASHING_BODY))))
		;; following values are ignored as they are not used anywhere
		;; (timestamp (unwrap! (read-uint-32 vaa-bytes signatures-offset) ERR_VAA_PARSING_TIMESTAMP))
		;; (nonce (unwrap! (read-uint-32 vaa-bytes (+ signatures-offset u4)) ERR_VAA_PARSING_NONCE))
		;; (consistency-level (unwrap! (read-uint-8 vaa-bytes (+ signatures-offset u50)) ERR_VAA_PARSING_CONSISTENCY_LEVEL))
		(emitter-chain (unwrap! (read-uint-16 vaa-bytes (+ signatures-offset u8)) ERR_VAA_PARSING_EMITTER_CHAIN))
		(emitter-address (unwrap! (read-buff-32 vaa-bytes (+ signatures-offset u10)) ERR_VAA_PARSING_EMITTER_ADDRESS))
		(sequence (unwrap! (read-uint-64 vaa-bytes (+ signatures-offset u42)) ERR_VAA_PARSING_SEQUENCE))
		(payload (unwrap! (slice? vaa-bytes (+ signatures-offset u51) vaa-bytes-len) ERR_VAA_PARSING_PAYLOAD))
		(vaa-body-hash-list (unwrap-panic (slice? (list vaa-body-hash vaa-body-hash vaa-body-hash vaa-body-hash vaa-body-hash 
			vaa-body-hash vaa-body-hash vaa-body-hash vaa-body-hash vaa-body-hash vaa-body-hash 
			vaa-body-hash vaa-body-hash vaa-body-hash vaa-body-hash vaa-body-hash vaa-body-hash vaa-body-hash vaa-body-hash) u0 signatures-len)))
		(public-keys-results (filter empty-key (map recover-public-key signatures vaa-body-hash-list))))
		(ok { 
			vaa: {
				version: version, 
				guardian-set-id: guardian-set-id,
				emitter-chain: emitter-chain,
				emitter-address: emitter-address,
				sequence: sequence,
				payload: payload,
			},
			recovered-public-keys: public-keys-results,
		})))

;; @desc Parse and check the validity of a Verified Action Approval (VAA)
;; @param vaa-bytes: 
(define-read-only (parse-and-verify-vaa (vaa-bytes (buff 8192)))
	(let ((message (try! (parse-vaa vaa-bytes)))
		(vaa-message (get vaa message))
		(guardian-set-id (get guardian-set-id vaa-message)))
	;; Ensure that the guardian-set-id is the active one or unexpired previous one
	(asserts! (try! (is-valid-guardian-set guardian-set-id)) ERR_VAA_CHECKS_GUARDIAN_SET_CONSISTENCY)
	(let (
		(active-guardians (unwrap! (map-get? guardian-sets guardian-set-id) ERR_VAA_CHECKS_GUARDIAN_SET_CONSISTENCY))
		(signatures-from-active-guardians (fold batch-check-active-public-keys (get recovered-public-keys message) {active-guardians: active-guardians, result: (list)})))
	;; Ensure that version is supported (v1 only)
	(asserts! (is-eq (get version vaa-message) u1) ERR_VAA_CHECKS_VERSION_UNSUPPORTED)
	;; Ensure that the count of valid signatures is >= 13
	(asserts! (>= (len (get result signatures-from-active-guardians)) (get-quorum (len active-guardians))) ERR_VAA_CHECKS_THRESHOLD_SIGNATURE)
	(ok vaa-message))))

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
						(get vaa (try! (parse-vaa guardian-set-vaa))))))
			(guardians-data (try! (parse-and-verify-guardians-set (get payload vaa))))
			(set-id (get new-index guardians-data))
			(eth-addresses (get guardians-eth-addresses guardians-data))
			(consolidated-public-keys (fold check-and-consolidate-public-keys 
				uncompressed-public-keys 
				{ cursor: u0, eth-addresses: eth-addresses, result: (list) }))
			(result (get result consolidated-public-keys)))
		;; Ensure that enough uncompressed-public-keys were provided
		(try! (fold is-valid-guardian-entry result (ok true)))
		(asserts! (is-eq (len uncompressed-public-keys) (len eth-addresses)) 
			ERR_GSU_UNCOMPRESSED_PUBLIC_KEYS)
		;; Check emitting address
		(asserts! (is-eq (get emitter-address vaa) GSU-EMITTING-ADDRESS) ERR_GSU_CHECK_EMITTER)
		;; Check emitting address
		(asserts! (is-eq (get emitter-chain vaa) GSU-EMITTING-CHAIN) ERR_GSU_CHECK_EMITTER)
		;; ensure guardian set has at least one member
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
			result: { guardians-eth-addresses: eth-addresses, guardians-public-keys: uncompressed-public-keys }})))

(define-read-only (get-active-guardian-set) 
	(let ((set-id (var-get active-guardian-set-id))
			(guardians (unwrap-panic (map-get? guardian-sets set-id))))
		(ok {set-id: set-id, guardians: guardians})))

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
		{ cursor: (+ u1 (get cursor acc)),
			eth-addresses: (get eth-addresses acc),
			result: (unwrap-panic (as-max-len? (append (get result acc) entry) u19)),
		}))

(define-private (recover-public-key (entry { guardian-id: uint, signature: (buff 65) }) (message-hash (buff 32)))
	(let ((signature (get signature entry))
			(guardian-id (get guardian-id entry))) 
		(if (is-eq 0x signature) { recovered-compressed-public-key: 0x, guardian-id: guardian-id }
			(let ((recovered-compressed-public-key (unwrap-panic (secp256k1-recover? message-hash signature))))
				{ recovered-compressed-public-key: recovered-compressed-public-key, guardian-id: guardian-id }))))

(define-private (empty-key (entry { guardian-id: uint, recovered-compressed-public-key: (buff 33) })) 
	(not (is-eq 0x (get recovered-compressed-public-key entry))))

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

(define-private (read-one-signature (input (buff 8192)))
	{ guardian-id: (unwrap-panic (read-uint-8 input u0)), signature: (unwrap-panic (as-max-len? (unwrap-panic (slice? input u1 u66)) u65))} )

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
		(bytes (get bytes acc))
		(cursor-address-bytes (unwrap-panic (read-buff-20 bytes cue-position))))
	(if (is-none (index-of? (get result acc) cursor-address-bytes))
		{ bytes: bytes, result: (unwrap-panic (as-max-len? (append (get result acc) cursor-address-bytes) u19))}
		acc)))

;; @desc Parse and verify payload's VAA  
(define-private (parse-and-verify-guardians-set (bytes (buff 8192)))
	(let ((module (unwrap! (read-buff-32 bytes u0) ERR_GSU_PARSING_MODULE))
			(action (unwrap! (read-uint-8 bytes u32) ERR_GSU_PARSING_ACTION))
			(chain (unwrap! (read-uint-16 bytes u33) ERR_GSU_PARSING_CHAIN))
			(new-index (unwrap! (read-uint-32 bytes u35) ERR_GSU_PARSING_INDEX))
			(guardians-count (unwrap! (read-uint-8 bytes u39) ERR_GSU_PARSING_GUARDIAN_LEN))
			(guardians-byte-size (* guardians-count GUARDIAN_ETH_ADDRESS_SIZE))
			(guardians-bytes (unwrap! (read-buff bytes u40 guardians-byte-size) ERR_GSU_PARSING_GUARDIANS_BYTES))
			(guardians-cues (get result (fold is-guardian-cue guardians-bytes { cursor: u0, result: (list) })))
			(eth-addresses (get result (fold parse-guardian guardians-cues { bytes: guardians-bytes, result: (list) }))))
		(asserts! (is-eq (+ u40 guardians-byte-size) (len bytes)) ERR_GSU_CHECK_OVERLAY)
		;; Ensure there are no duplicated addresses
		(asserts! (is-eq (len eth-addresses) guardians-count) ERR_DUPLICATED_GUARDIAN_ADDRESSES)
		;; Ensure that this message was emitted from authorized module
		(asserts! (is-eq module CORE_STRING_MODULE) ERR_GSU_CHECK_MODULE)
		;; Ensure that this message is matching the adequate action
		(asserts! (is-eq action ACTION_GUARDIAN_SET_UPDATE) ERR_GSU_CHECK_ACTION)
		;; Ensure that this message is matching the expected chain
		(asserts! (or (is-eq chain (buff-to-uint-be EXPECTED_CHAIN_ID)) (is-eq chain CORE_CHAIN_ID) ) ERR_GSU_CHECK_CHAIN)
		(if (var-get guardian-set-initialized)
			;; Ensure that next index = current index + 1
			(asserts! (is-eq new-index (+ u1 (var-get active-guardian-set-id))) ERR_GSU_CHECK_INDEX)
			;; Ensure that next index > current index
			(asserts! (> new-index (var-get active-guardian-set-id)) ERR_GSU_CHECK_INDEX))
		(ok {
				guardians-eth-addresses: eth-addresses,
				module: module,
				action: action,
				chain: chain,
				new-index: new-index})))

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
		(let ((compressed (get compressed-public-key entry))
				(uncompressed (get uncompressed-public-key entry)))
			(if (or (is-eq 0x compressed) (is-eq 0x uncompressed)) ERR_GSU_PARSING_GUARDIAN_LEN (ok true)))))

(define-private (set-new-guardian-set-id (new-set-id uint))
	(if (var-get guardian-set-initialized)
		(let ((latest-stacks-timestamp (unwrap! (get-stacks-block-info? time (- stacks-block-height u1)) ERR_STACKS_TIMESTAMP))
				(previous-set-expires-at (+ TWENTY_FOUR_HOURS latest-stacks-timestamp)))
			(var-set previous-guardian-set {
					set-id: (var-get active-guardian-set-id),
					expires-at: previous-set-expires-at
			})
			(var-set active-guardian-set-id new-set-id)
			(ok true))
		(begin (var-set active-guardian-set-id new-set-id) (ok true))))

(define-private (is-valid-guardian-set (set-id uint))
	(if (is-eq (var-get active-guardian-set-id) set-id)
		(ok true)
		(let ((prev-guardian-set (var-get previous-guardian-set))
			(prev-guardian-set-id (get set-id prev-guardian-set))
			(prev-guardian-set-expires-at (get expires-at prev-guardian-set))
			(latest-stacks-timestamp (unwrap! (get-stacks-block-info? time (- stacks-block-height u1)) ERR_STACKS_TIMESTAMP))
		) (ok (and (is-eq prev-guardian-set-id set-id) (>= prev-guardian-set-expires-at latest-stacks-timestamp))))))

;; cursor reads
(define-private (read-buff (bytes (buff 8192)) (pos uint) (length uint))
	(ok (unwrap! (slice? bytes pos (+ pos length)) (err u1))))

(define-private (read-buff-20 (bytes (buff 8192)) (pos uint))
	(ok (unwrap! (as-max-len? (unwrap! (slice? bytes pos (+ pos u20)) (err u1)) u20) (err u1))))

(define-private (read-buff-32 (bytes (buff 8192)) (pos uint))
	(ok (unwrap! (as-max-len? (unwrap! (slice? bytes pos (+ pos u32)) (err u1)) u32) (err u1))))

(define-private (read-uint-8 (bytes (buff 8192)) (pos uint))
	(ok (buff-to-uint-be (unwrap-panic (as-max-len? (try! (read-buff bytes pos u1)) u1)))))

(define-private (read-uint-16 (bytes (buff 8192)) (pos uint))
	(ok (buff-to-uint-be (unwrap-panic (as-max-len? (try! (read-buff bytes pos u2)) u2)))))

(define-private (read-uint-32 (bytes (buff 8192)) (pos uint))
	(ok (buff-to-uint-be (unwrap-panic (as-max-len? (try! (read-buff bytes pos u4)) u4)))))

(define-private (read-uint-64 (bytes (buff 8192)) (pos uint))
	(ok (buff-to-uint-be (unwrap-panic (as-max-len? (try! (read-buff bytes pos u8)) u8)))))
