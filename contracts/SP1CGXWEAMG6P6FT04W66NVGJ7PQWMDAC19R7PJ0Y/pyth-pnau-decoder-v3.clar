;; Title: pyth-pnau-decoder
;; Version: v3
;; Check for latest version: https://github.com/Trust-Machines/stacks-pyth-bridge#latest-version
;; Report an issue: https://github.com/Trust-Machines/stacks-pyth-bridge/issues

;;;; Traits
(impl-trait .pyth-traits-v2.decoder-trait)
(use-trait wormhole-core-trait .wormhole-traits-v2.core-trait)

;;;; Constants

(define-constant PNAU_MAGIC 0x504e4155) ;; 'PNAU': Pyth Network Accumulator Update
(define-constant AUWV_MAGIC 0x41555756) ;; 'AUWV': Accumulator Update Wormhole Verification
(define-constant PYTHNET_MAJOR_VERSION u1)
(define-constant PYTHNET_MINOR_VERSION u0)
(define-constant UPDATE_TYPE_WORMHOLE_MERKLE u0)
(define-constant MESSAGE_TYPE_PRICE_FEED u0)
(define-constant MERKLE_PROOF_HASH_SIZE u20)
(define-constant MAXIMUM_UPDATES u6)

;; Unable to price feed magic bytes
(define-constant ERR_MAGIC_BYTES (err u2001))
;; Unable to parse major version
(define-constant ERR_VERSION_MAJ (err u2002))
;; Unable to parse minor version
(define-constant ERR_VERSION_MIN (err u2003))
;; Unable to parse trailing header size
(define-constant ERR_HEADER_TRAILING_SIZE (err u2004))
;; Unable to parse proof type
(define-constant ERR_PROOF_TYPE (err u2005))
;; Unable to parse update type
(define-constant ERR_UPDATE_TYPE (err u2006))
;; Incorrect AUWV message
(define-constant ERR_INVALID_AUWV (err u2007))
;; Merkle root mismatch
(define-constant ERR_MERKLE_ROOT_MISMATCH (err u2008))
;; Incorrect AUWV payload
(define-constant ERR_INCORRECT_AUWV_PAYLOAD (err u2009))
;; Price update not signed by an authorized source 
(define-constant ERR_UNAUTHORIZED_PRICE_UPDATE (err u2401))
;; VAA buffer has unused, extra leading bytes (overlay)
(define-constant ERR_OVERLAY_PRESENT (err u2402))
;; Number of updates exceeded maximum.
(define-constant ERR_MAXIMUM_UPDATES (err u2403))
;; Invalid PNAU buffer, shorter than required
(define-constant ERR_INVALID_PNAU_BYTES (err u2404))

;;;; Public functions
(define-public (decode-and-verify-price-feeds (pnau-bytes (buff 8192)) (wormhole-core-address <wormhole-core-trait>))
	;; Check execution flow
	(let ((execution-check (try! (contract-call? .pyth-governance-v3 check-execution-flow contract-caller none)))
			(offset (try! (parse-pnau-header pnau-bytes)))
			(pnau-vaa-size (try! (read-uint-16 pnau-bytes offset)))
			(pnau-vaa (try! (read-buff pnau-bytes (+ offset u2) pnau-vaa-size)))
			(vaa (try! (contract-call? wormhole-core-address parse-and-verify-vaa pnau-vaa)))
			(merkle-root-hash (try! (parse-merkle-root-data-from-vaa-payload (get payload vaa))))
			(encoded-price-updates (unwrap! (slice? pnau-bytes (+ offset u2 pnau-vaa-size) (len pnau-bytes)) ERR_INVALID_PNAU_BYTES))
			(decoded-prices-updates (try! (parse-and-verify-prices-updates encoded-price-updates merkle-root-hash)))
			(prices-updates (map cast-decoded-price decoded-prices-updates))
			(authorized-prices-data-sources (contract-call? .pyth-governance-v3 get-authorized-prices-data-sources)))
		;; Ensure that update was published by an data source authorized by governance
		(unwrap! (index-of? authorized-prices-data-sources { emitter-chain: (get emitter-chain vaa), emitter-address: (get emitter-address vaa) }) ERR_UNAUTHORIZED_PRICE_UPDATE)
		(ok prices-updates)))

;;;; Private functions
(define-private (parse-merkle-root-data-from-vaa-payload (payload-vaa-bytes (buff 8192)))
	(let ((payload-type (unwrap! (read-buff-4 payload-vaa-bytes u0) ERR_INVALID_AUWV))
			(wh-update-type (unwrap! (read-uint-8 payload-vaa-bytes u4) ERR_INVALID_AUWV))
			;; slot and ring size are not used
			;; (merkle-root-slot (unwrap! (read-uint-64 payload-vaa-bytes u5) ERR_INVALID_AUWV))
			;; (merkle-root-ring-size (unwrap! (read-uint-32 payload-vaa-bytes u13) ERR_INVALID_AUWV))
			(merkle-root-hash (unwrap! (read-buff-20 payload-vaa-bytes u17) ERR_INVALID_AUWV)))
		;; Check payload type
		(asserts! (is-eq payload-type AUWV_MAGIC) ERR_MAGIC_BYTES)
		;; Check update type
		(asserts! (is-eq wh-update-type UPDATE_TYPE_WORMHOLE_MERKLE) ERR_PROOF_TYPE)
		(ok merkle-root-hash)))

(define-private (parse-pnau-header (pf-bytes (buff 8192)))
	(let ((magic (unwrap! (read-buff-4 pf-bytes u0) ERR_MAGIC_BYTES))
			(version-major (unwrap! (read-uint-8 pf-bytes u4) ERR_VERSION_MAJ))
			(version-minor (unwrap! (read-uint-8 pf-bytes u5) ERR_VERSION_MIN))
			(header-trailing-size (unwrap! (read-uint-8 pf-bytes u6) ERR_HEADER_TRAILING_SIZE))
			(proof-type (unwrap! (read-uint-8 pf-bytes (+ u7 header-trailing-size)) ERR_PROOF_TYPE)))
		;; Check magic bytes
		(asserts! (is-eq magic PNAU_MAGIC) ERR_MAGIC_BYTES)
		;; Check major version
		(asserts! (is-eq version-major PYTHNET_MAJOR_VERSION) ERR_VERSION_MAJ)
		;; Check minor version
		(asserts! (>= version-minor PYTHNET_MINOR_VERSION) ERR_VERSION_MIN)
		;; Check proof type
		(asserts! (is-eq proof-type UPDATE_TYPE_WORMHOLE_MERKLE) ERR_PROOF_TYPE)
		(ok (+ header-trailing-size u8))))

(define-private (parse-and-verify-prices-updates (bytes (buff 8192)) (merkle-root-hash (buff 20)))
	(let ((num-updates (try! (read-uint-8 bytes u0)))
			(max-updates-check (asserts! (<= num-updates MAXIMUM_UPDATES) ERR_MAXIMUM_UPDATES))
			(update-data (try! (parse-price-info-and-proof bytes)))
			(updates (get entries update-data))
			(merkle-proof-checks-success (get result (fold check-merkle-proof updates { result: true, merkle-root-hash: merkle-root-hash }))))
		(asserts! merkle-proof-checks-success ERR_MERKLE_ROOT_MISMATCH)
		(asserts! (is-eq (get offset update-data) (len bytes)) ERR_OVERLAY_PRESENT)
		(asserts! (is-eq num-updates (len updates)) ERR_INCORRECT_AUWV_PAYLOAD)
		(ok updates)))

(define-private (parse-price-info-and-proof (bytes (buff 8192)))
	(let (
			(offset u1)
			(update1 (try! (read-and-verify-update bytes offset)))
			(offset-1 (+ offset (get update-size update1)))
			(update2 (unwrap! (read-and-verify-update bytes offset-1) (ok { offset: offset-1, entries: (list update1)})))
			(offset-2 (+ offset-1 (get update-size update2)))
			(update3 (unwrap! (read-and-verify-update bytes offset-2) (ok { offset: offset-2, entries: (list update1 update2)})))
			(offset-3 (+ offset-2 (get update-size update3)))
			(update4 (unwrap! (read-and-verify-update bytes offset-3) (ok { offset: offset-3, entries: (list update1 update2 update3)})))
			(offset-4 (+ offset-3 (get update-size update4)))
			(update5 (unwrap! (read-and-verify-update bytes offset-4) (ok { offset: offset-4, entries: (list update1 update2 update3 update4)})))
			(offset-5 (+ offset-4 (get update-size update5)))
			(update6 (unwrap! (read-and-verify-update bytes offset-5) (ok { offset: offset-5, entries: (list update1 update2 update3 update4 update5)}))))
		(ok { offset: (+ offset-5 (get update-size update6)), entries: (list update1 update2 update3 update4 update5 update6)})))

(define-private (check-merkle-proof
	(entry 
		{
			price-identifier: (buff 32),
			price: int,
			conf: uint,
			expo: int,
			publish-time: uint,
			prev-publish-time: uint,
			ema-price: int,
			ema-conf: uint,
			proof: (list 128 (buff 20)),
			leaf-bytes: (buff 255),
			update-size: uint
		})
	(acc 
		{ 
			merkle-root-hash: (buff 20),
			result: bool, 
		}))
	{ merkle-root-hash: (get merkle-root-hash acc), result: (and (get result acc) (check-proof (get merkle-root-hash acc) (get leaf-bytes entry) (get proof entry)))})

(define-private (read-and-verify-update (bytes (buff 8192)) (offset uint))
	(let ((message-size (try! (read-uint-16 bytes offset)))
			(message-type (try! (read-uint-8 bytes (+ offset u2))))
			(price-identifier (try! (read-buff-32 bytes (+ offset u3))))
			(price (try! (read-int-64 bytes (+ offset u35))))
			(conf (try! (read-uint-64 bytes (+ offset u43))))
			(expo (try! (read-int-32 bytes (+ offset u51))))
			(publish-time (try! (read-uint-64 bytes (+ offset u55))))
			(prev-publish-time (try! (read-uint-64 bytes (+ offset u63))))
			(ema-price (try! (read-int-64 bytes (+ offset u71))))
			(ema-conf (try! (read-uint-64 bytes (+ offset u79))))
			(proof-size (try! (read-uint-8 bytes (+ offset u2 message-size))))
			(proof-length (* MERKLE_PROOF_HASH_SIZE proof-size))
			(proof-bytes (default-to 0x (slice? bytes (+ offset u3 message-size) (+ offset u3 message-size proof-length))))
			(leaf-bytes (default-to 0x (slice? bytes (+ offset u2) (+ offset u2 message-size))))
			(proof (get result (fold parse-proof proof-bytes { result: (list), cursor: {index: u0, next-update-index: u0 }, bytes: proof-bytes, limit: proof-size}))))
		(asserts! (is-eq message-type MESSAGE_TYPE_PRICE_FEED) ERR_UPDATE_TYPE)
		(ok {
			price-identifier: price-identifier,
			price: price,
			conf: conf,
			expo: expo,
			publish-time: publish-time,
			prev-publish-time: prev-publish-time,
			ema-price: ema-price,
			ema-conf: ema-conf,
			proof: proof,
			leaf-bytes: (unwrap-panic (as-max-len? leaf-bytes u255)),
			update-size: (+ u3 message-size proof-length)
		})))

(define-private (parse-proof
		(entry (buff 1)) 
		(acc { 
			cursor: { 
				index: uint,
				next-update-index: uint
			},
			bytes: (buff 8192),
			result: (list 128 (buff 20)), 
			limit: uint
		}))
	(let ((result (get result acc)) (limit (get limit acc)))
		(if (is-eq (len result) limit)
			acc
			(let ((cursor (get cursor acc))
					(index (get index cursor))
					(next-update-index (get next-update-index cursor))
					(bytes (get bytes acc)))
				(if (is-eq index next-update-index)
					;; Parse update
					{
						cursor: { index: (+ index u1), next-update-index: (+ index MERKLE_PROOF_HASH_SIZE)},
						bytes: bytes,
						result: (unwrap-panic (as-max-len? (append result (unwrap-panic (read-buff-20 bytes index))) u128)),
						limit: limit,
					}
					;; Increment position
					{
						cursor: { index: (+ index u1), next-update-index: next-update-index },
						bytes: bytes,
						result: result,
						limit: limit
					}
				)))))

(define-private (cast-decoded-price (entry 
		{
			price-identifier: (buff 32),
			price: int,
			conf: uint,
			expo: int,
			publish-time: uint,
			prev-publish-time: uint,
			ema-price: int,
			ema-conf: uint,
			proof: (list 128 (buff 20)),
			leaf-bytes: (buff 255),
			update-size: uint
		}))
	{
		price-identifier: (get price-identifier entry),
		price: (get price entry),
		conf: (get conf entry),
		expo: (get expo entry),
		publish-time: (get publish-time entry),
		prev-publish-time: (get prev-publish-time entry),
		ema-price: (get ema-price entry),
		ema-conf: (get ema-conf entry)
	})

(define-private (read-buff (bytes (buff 8192)) (pos uint) (length uint))
	(ok (unwrap! (slice? bytes pos (+ pos length)) (err u1))))

(define-private (read-buff-4 (bytes (buff 8192)) (pos uint))
	(ok (unwrap! (as-max-len? (unwrap! (slice? bytes pos (+ pos u4)) (err u1)) u4) (err u1))))

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

(define-private (read-int-32 (bytes (buff 8192)) (pos uint))
	(ok (bit-shift-right (bit-shift-left (buff-to-int-be (unwrap-panic (as-max-len? (try! (read-buff bytes pos u4)) u4))) u96) u96)))

(define-private (read-int-64 (bytes (buff 8192)) (pos uint))
	(ok (bit-shift-right (bit-shift-left (buff-to-int-be (unwrap-panic (as-max-len? (try! (read-buff bytes pos u8)) u8))) u64) u64)))

(define-private (check-proof (root-hash (buff 20)) (leaf (buff 255)) (path (list 255 (buff 20))))
	(is-eq root-hash (fold hash-path path (hash-leaf leaf))))

(define-private (hash-leaf (bytes (buff 255)))
	(keccak160 (concat 0x00 bytes)))

(define-private (keccak160 (bytes (buff 1024)))
	(unwrap-panic (as-max-len? (unwrap-panic (slice? (keccak256 bytes) u0 u20)) u20)))

(define-private (hash-path (entry (buff 20)) (acc (buff 20)))
	(hash-nodes entry acc))

(define-private (hash-nodes (node-1 (buff 20)) (node-2 (buff 20)))
	(let ((uint-1 (buff-20-to-uint node-1))
			(uint-2 (buff-20-to-uint node-2))
			(sequence (if (< uint-2 uint-1) (concat (concat 0x01 node-2) node-1) (concat (concat 0x01 node-1) node-2))))
	(keccak160 sequence)))

(define-private (buff-20-to-uint (bytes (buff 20)))
		(buff-to-uint-be (unwrap-panic (as-max-len? (unwrap-panic (slice? bytes u0 u15)) u16))))
