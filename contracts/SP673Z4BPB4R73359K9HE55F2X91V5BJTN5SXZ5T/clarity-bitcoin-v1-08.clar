;; Error codes
(define-constant ERR-OUT-OF-BOUNDS (err u1001))
(define-constant ERR-TOO-MANY-TXINS (err u1002))
(define-constant ERR-TOO-MANY-TXOUTS (err u1003))
(define-constant ERR-VARSLICE-TOO-LONG (err u1004))
(define-constant ERR-BAD-HEADER (err u1005))
(define-constant ERR-PROOF-TOO-SHORT (err u1006))
(define-constant ERR-TOO-MANY-WITNESSES (err u1007))
(define-constant ERR-INVALID-COMMITMENT (err u1008))
(define-constant ERR-WITNESS-TX-NOT-IN-COMMITMENT (err u1009))
(define-constant ERR-LEFTOVER-DATA (err u1010))
(define-constant ERR-NOT-SEGWIT-TRANSACTION (err u1011))

;; Reads the next two bytes from txbuff as a little-endian 16-bit integer, and updates the index.
;; Returns (ok { uint16: uint, ctx: { txbuff: (buff 32768), index: uint } }) on success.
;; Returns ERR-OUT-OF-BOUNDS if we read past the end of txbuff
(define-read-only (read-uint8 (ctx { txbuff: (buff 32768), index: uint}))
	(let (
			(data (get txbuff ctx))
			(base (get index ctx)))
		(ok {uint8: (buff-to-uint-le (unwrap-panic (as-max-len? (unwrap! (slice? data base (+ base u1)) ERR-OUT-OF-BOUNDS) u1))), ctx: { txbuff: data, index: (+ u1 base)}})))

;; Reads the next two bytes from txbuff as a little-endian 16-bit integer, and updates the index.
;; Returns (ok { uint16: uint, ctx: { txbuff: (buff 32768), index: uint } }) on success.
;; Returns ERR-OUT-OF-BOUNDS if we read past the end of txbuff
(define-read-only (read-uint16 (ctx { txbuff: (buff 32768), index: uint}))
	(let (
			(data (get txbuff ctx))
			(base (get index ctx)))
		(ok {uint16: (buff-to-uint-le (unwrap-panic (as-max-len? (unwrap! (slice? data base (+ base u2)) ERR-OUT-OF-BOUNDS) u2))), ctx: { txbuff: data, index: (+ u2 base)}})))

;; Reads the next four bytes from txbuff as a little-endian 32-bit integer, and updates the index.
;; Returns (ok { uint32: uint, ctx: { txbuff: (buff 32768), index: uint } }) on success.
;; Returns ERR-OUT-OF-BOUNDS if we read past the end of txbuff
(define-read-only (read-uint32 (ctx { txbuff: (buff 32768), index: uint}))
	(let (
			(data (get txbuff ctx))
			(base (get index ctx)))
		(ok {uint32: (buff-to-uint-le (unwrap-panic (as-max-len? (unwrap! (slice? data base (+ base u4)) ERR-OUT-OF-BOUNDS) u4))), ctx: { txbuff: data, index: (+ u4 base)}})))

;; Reads the next eight bytes from txbuff as a little-endian 64-bit integer, and updates the index.
;; Returns (ok { uint64: uint, ctx: { txbuff: (buff 32768), index: uint } }) on success.
;; Returns ERR-OUT-OF-BOUNDS if we read past the end of txbuff
(define-read-only (read-uint64 (ctx { txbuff: (buff 32768), index: uint}))
	(let (
			(data (get txbuff ctx))
			(base (get index ctx)))
		(ok {uint64: (buff-to-uint-le (unwrap-panic (as-max-len? (unwrap! (slice? data base (+ base u8)) ERR-OUT-OF-BOUNDS) u8))), ctx: { txbuff: data, index: (+ u8 base)}})))

;; Reads the next varint from txbuff, and updates the index.
;; Returns (ok { varint: uint, ctx: { txbuff: (buff 32768), index: uint } }) on success
;; Returns ERR-OUT-OF-BOUNDS if we read past the end of txbuff.
(define-read-only (read-varint (ctx { txbuff: (buff 32768), index: uint}))
	(let (
			(ptr (get index ctx))
			(tx (get txbuff ctx))
			(byte (buff-to-uint-le (unwrap! (element-at tx ptr) ERR-OUT-OF-BOUNDS))))
		(if (<= byte u252)
			;; given byte is the varint
			(ok { varint: byte, ctx: { txbuff: tx, index: (+ u1 ptr)}})
			(if (is-eq byte u253)
				(let (
						;; next two bytes is the varint
						(parsed-u16 (try! (read-uint16 { txbuff: tx, index: (+ u1 ptr)}))))
					(ok { varint: (get uint16 parsed-u16), ctx: (get ctx parsed-u16)}))
				(if (is-eq byte u254)
					(let (
							;; next four bytes is the varint
							(parsed-u32 (try! (read-uint32 { txbuff: tx, index: (+ u1 ptr)}))))
						(ok { varint: (get uint32 parsed-u32), ctx: (get ctx parsed-u32)}))
						(let (
								;; next eight bytes is the varint
								(parsed-u64 (try! (read-uint64 { txbuff: tx, index: (+ u1 ptr)}))))
							(ok { varint: (get uint64 parsed-u64), ctx: (get ctx parsed-u64)})))))))

;; Reads a varint-prefixed byte slice from txbuff, and updates the index to point to the byte after the varint and slice.
;; Returns (ok { varslice: (buff 32768), ctx: { txbuff: (buff 32768), index: uint } }) on success, where varslice has the length of the varint prefix.
;; Returns ERR-OUT-OF-BOUNDS if we read past the end of txbuff.
(define-read-only (read-varslice (old-ctx { txbuff: (buff 32768), index: uint}))
	(let (
			(parsed (try! (read-varint old-ctx)))
			(ctx (get ctx parsed))
			(slice-start (get index ctx))
			(target-index (+ slice-start (get varint parsed)))
			(txbuff (get txbuff ctx)))
		(ok {varslice: (unwrap! (slice? txbuff slice-start target-index) ERR-OUT-OF-BOUNDS), ctx: { txbuff: txbuff, index: target-index}})))

;; Generate a permutation of a given 32-byte buffer, appending the element at target-index to hash-output.
;; The target-index decides which index in hash-input gets appended to hash-output.
(define-read-only (inner-reverse (target-index uint) (hash-input (buff 32)))
	(unwrap-panic
		(replace-at?
			(unwrap-panic
				(replace-at?
					hash-input
					target-index
					(unwrap-panic (element-at? hash-input (- u31 target-index)))))
			(- u31 target-index)
			(unwrap-panic (element-at? hash-input  target-index)))))

;; Reverse the byte order of a 32-byte buffer.  Returns the (buff 32).
(define-read-only (reverse-buff32 (input (buff 32)))
	(fold inner-reverse
		(list u31 u30 u29 u28 u27 u26 u25 u24 u23 u22 u21 u20 u19 u18 u17 u16)
		input))

;; Reads a little-endian hash -- consume the next 32 bytes, and reverse them.
;; Returns (ok { hashslice: (buff 32), ctx: { txbuff: (buff 32768), index: uint } }) on success, and updates the index.
;; Returns ERR-OUT-OF-BOUNDS if we read past the end of txbuff.
(define-read-only (read-hashslice (old-ctx { txbuff: (buff 32768), index: uint}))
	(let (
			(slice-start (get index old-ctx))
			(target-index (+ u32 slice-start))
			(txbuff (get txbuff old-ctx))
			(hash-le
				(unwrap-panic
					(as-max-len? (unwrap! (slice? txbuff slice-start target-index) ERR-OUT-OF-BOUNDS)
						u32))))
		(ok {hashslice: (reverse-buff32 hash-le), ctx: { txbuff: txbuff, index: target-index}})))

;; Inner fold method to read the next tx input from txbuff.
;; The index in ctx will be updated to point to the next tx input if all goes well (or to the start of the outputs)
;; Returns (ok { ... }) on success.
;; Returns ERR-OUT-OF-BOUNDS if we read past the end of txbuff.
;; Returns ERR-VARSLICE-TOO-LONG if we find a scriptSig that's too long to parse.
;; Returns ERR-TOO-MANY-TXINS if there are more than eight inputs to read.
(define-read-only (read-next-txin
		(ignored bool)
		(state-res
			(response {
					ctx: { txbuff: (buff 32768), index: uint },
					remaining: uint,
					txins: (list 32 {
						outpoint: {
							hash: (buff 32),
							index: uint},
						scriptSig: (buff 256),	;; just big enough to hold a 2-of-3 multisig script
						sequence: uint})}
				uint)))
	(match state-res
		state
			(if (< u0 (get remaining state))
				(let (
						(remaining (get remaining state))
						(ctx (get ctx state))
						(parsed-hash (try! (read-hashslice ctx)))
						(parsed-index (try! (read-uint32 (get ctx parsed-hash))))
						(parsed-scriptSig (try! (read-varslice (get ctx parsed-index))))
						(parsed-sequence (try! (read-uint32 (get ctx parsed-scriptSig))))
						(new-ctx (get ctx parsed-sequence)))
					(ok {
							ctx: new-ctx,
							remaining: (- remaining u1),
							txins:
								(unwrap!
									(as-max-len?
										(append
											(get txins state)
											{
												outpoint: {
													hash: (get hashslice parsed-hash),
													index: (get uint32 parsed-index) },
												scriptSig: (unwrap! (as-max-len? (get varslice parsed-scriptSig) u256) ERR-VARSLICE-TOO-LONG),
												sequence: (get uint32 parsed-sequence)})
										u32)
									ERR-TOO-MANY-TXINS)}))
				(ok state))
		error
			(err error)))

;; Read a transaction's inputs.
;; Returns (ok { txins: (list { ... }), remaining: uint, ctx: { txbuff: (buff 32768), index: uint } }) on success, and updates the index in ctx to point to the start of the tx outputs.
;; Returns ERR-OUT-OF-BOUNDS if we read past the end of txbuff.
;; Returns ERR-VARSLICE-TOO-LONG if we find a scriptSig that's too long to parse.
;; Returns ERR-TOO-MANY-TXINS if there are more than eight inputs to read.
(define-read-only (read-txins (ctx { txbuff: (buff 32768), index: uint}))
	(let (
			(parsed-num-txins (try! (read-varint ctx)))
			(num-txins (get varint parsed-num-txins))
			(new-ctx (get ctx parsed-num-txins)))
		(if (> num-txins u32)
			ERR-TOO-MANY-TXINS
			(fold read-next-txin (unwrap-panic (slice?
				(list
					true true true true true true true true true true true true true true true true true true true true true true true true true true true true true true true true
					true true true true true true true true true true true true true true true true true true true true true true true true true true true true true true
				) u0 num-txins)) (ok { ctx: new-ctx, remaining: num-txins, txins: (list)})))))

;; Read the next transaction output, and update the index in ctx to point to the next output.
;; Returns (ok { ... }) on success
;; Returns ERR-OUT-OF-BOUNDS if we read past the end of txbuff.
;; Returns ERR-VARSLICE-TOO-LONG if we find a scriptPubKey that's too long to parse.
;; Returns ERR-TOO-MANY-TXOUTS if there are more than eight outputs to read.
(define-read-only (read-next-txout
		(ignored bool)
		(state-res
			(response
				{	ctx: { txbuff: (buff 32768), index: uint },
					txouts: (list 32 {value: uint, scriptPubKey: (buff 128)})}
				uint)))
	(match state-res
		state
			(let (
					(parsed-value (try! (read-uint64 (get ctx state))))
					(parsed-script (try! (read-varslice (get ctx parsed-value))))
					(new-ctx (get ctx parsed-script)))
				(ok {
					ctx: new-ctx,
					txouts: (unwrap!
						(as-max-len?
							(append (get txouts state)
								{	value: (get uint64 parsed-value),
									scriptPubKey: (unwrap! (as-max-len? (get varslice parsed-script) u128) ERR-VARSLICE-TOO-LONG)})
							u32)
						ERR-TOO-MANY-TXOUTS)}))
		error (err error)))

;; Read all transaction outputs in a transaction.  Update the index to point to the first byte after the outputs, if all goes well.
;; Returns (ok { txouts: (list { ... }), remaining: uint, ctx: { txbuff: (buff 32768), index: uint } }) on success, and updates the index in ctx to point to the start of the tx outputs.
;; Returns ERR-OUT-OF-BOUNDS if we read past the end of txbuff.
;; Returns ERR-VARSLICE-TOO-LONG if we find a scriptPubKey that's too long to parse.
;; Returns ERR-TOO-MANY-TXOUTS if there are more than eight outputs to read.
(define-read-only (read-txouts (ctx { txbuff: (buff 32768), index: uint}))
	(let (
			(parsed-num-txouts (try! (read-varint ctx)))
			(num-txouts (get varint parsed-num-txouts))
			(new-ctx (get ctx parsed-num-txouts)))
		(if (> num-txouts u32)
			ERR-TOO-MANY-TXOUTS
			(fold read-next-txout (unwrap-panic (slice?
				(list
					true true true true true true true true true true true true true true true true true true true true true true true true true true true true true true true true
					true true true true true true true true true true true true true true true true true true true true true true true true true true true true true true
				) u0 num-txouts)) (ok { ctx: new-ctx, txouts: (list)})))))

(define-read-only (read-next-element
		(ignored bool)
		(state-res (response
			{ctx: { txbuff: (buff 32768), index: uint }, elements: (list 32 (buff 512))}
			uint)))
	(match state-res
		state
			(let (
					(parsed-script (try! (read-varslice (get ctx state))))
					(new-ctx (get ctx parsed-script)))
				(ok {
					ctx: new-ctx,
					elements: (unwrap!
						(as-max-len?
							(append (get elements state) (unwrap! (as-max-len? (get varslice parsed-script) u256) ERR-VARSLICE-TOO-LONG))
							u32)
						ERR-TOO-MANY-TXOUTS)}))
		error
			(err error)))

(define-read-only (read-next-witness
		(ignored bool)
		(state-res (response
			{ctx: {txbuff: (buff 32768), index: uint}, witnesses: (list 32 (list 32 (buff 512)))}
			uint)))
	(match state-res
		state
			(let (
					(parsed-num-items (try! (read-varint (get ctx state))))
					(ctx (get ctx parsed-num-items))
					(varint (get varint parsed-num-items)))
				(if (> varint u0)
					(let ((parsed-elements (try! (fold read-next-element (unwrap-panic (slice?
						(list
							true true true true true true true true true true true true true true true true true true true true true true true true true true true true true true true true
							true true true true true true true true true true true true true true true true true true true true true true true true true true true true true true
						) u0 varint)) (ok { ctx: ctx, elements: (list)})))))
						(ok {
							witnesses: (unwrap-panic (as-max-len? (append (get witnesses state) (get elements parsed-elements)) u32)),
							ctx: (get ctx parsed-elements)}))
					(begin
						(ok {
							witnesses: (unwrap-panic (as-max-len? (append (get witnesses state) (list)) u32)),
							ctx: (get ctx parsed-num-items)}))))
		error (err u1)))

(define-read-only (read-witnesses (ctx { txbuff: (buff 32768), index: uint }) (num-txins uint))
	(fold read-next-witness
		(unwrap-panic (slice?
			(list
				true true true true true true true true true true true true true true true true true true true true true true true true true true true true true true true true
				true true true true true true true true true true true true true true true true true true true true true true true true true true true true true true
			) u0 num-txins))
		(ok { ctx: ctx, witnesses: (list) })))

;; Helper function to check if tx is a segwit tx
;; if the 5th byte is 0x00 then it is segwit.
(define-read-only (is-segwit-tx (tx (buff 32768)))
	(let (
			(ctx { txbuff: tx, index: u0})
			(parsed-version (try! (read-uint32 ctx)))
			(parsed-segwit-marker (try! (read-uint8 (get ctx parsed-version)))))
			(ok (is-eq (get uint8 parsed-segwit-marker) u0))
	)
)

;; Helper functions for smart contract that want to use information of a Bitcoin transaction
;;
;; Parses a Bitcoin transaction, with up to 32 inputs and 32 outputs, with scriptSigs of up to 256 bytes each, and with scriptPubKeys up to 128 bytes.
;; Returns a tuple structured as follows on success:
;; (ok {
;;      version: uint,                      ;; tx version
;;      ins: (list 32
;;          {
;;              outpoint: {                 ;; pointer to the utxo this input consumes
;;                  hash: (buff 32),
;;                  index: uint
;;              },
;;              scriptSig: (buff 256),      ;; spending condition script
;;              sequence: uint
;;          }),
;;      outs: (list 32
;;          {
;;              value: uint,                ;; satoshis sent
;;              scriptPubKey: (buff 128)    ;; parse this to get an address
;;          }),
;;      locktime: uint
;; })
;; Returns ERR-OUT-OF-BOUNDS if we read past the end of txbuff.
;; Returns ERR-VARSLICE-TOO-LONG if we find a scriptPubKey or scriptSig that's too long to parse.
;; Returns ERR-TOO-MANY-TXOUTS if there are more than eight inputs to read.
;; Returns ERR-TOO-MANY-TXINS if there are more than eight outputs to read.
(define-read-only (parse-wtx (tx (buff 32768)))
	(let (
			(ctx { txbuff: tx, index: u0})
			(parsed-version (try! (read-uint32 ctx)))
			(parsed-segwit-marker (try! (read-uint8 (get ctx parsed-version))))
			(parsed-segwit-version (try! (read-uint8 (get ctx parsed-segwit-marker))))
			(parsed-txins (try! (read-txins (get ctx parsed-segwit-version))))
			(parsed-txouts (try! (read-txouts (get ctx parsed-txins))))
			(parsed-witnesses (try! (read-witnesses (get ctx parsed-txouts) (len (get txins parsed-txins)))))
			(parsed-locktime (try! (read-uint32 (get ctx parsed-witnesses)))))
		(asserts! (and (is-eq (get uint8 parsed-segwit-marker) u0) (is-eq (get uint8 parsed-segwit-version) u1)) ERR-NOT-SEGWIT-TRANSACTION)
		(asserts! (is-eq (len tx) (get index (get ctx parsed-locktime))) ERR-LEFTOVER-DATA)
		(ok {
			version: (get uint32 parsed-version),
			segwit-marker: (get uint8 parsed-segwit-marker),
			segwit-version: (get uint8 parsed-segwit-version),
			ins: (get txins parsed-txins),
			outs: (get txouts parsed-txouts),
			witnesses: (get witnesses parsed-witnesses),
			locktime: (get uint32 parsed-locktime)})))

(define-read-only (parse-tx (tx (buff 32768)))
	(let (
			(ctx { txbuff: tx, index: u0})
			(parsed-version (try! (read-uint32 ctx)))
			(parsed-txins (try! (read-txins (get ctx parsed-version))))
			(parsed-txouts (try! (read-txouts (get ctx parsed-txins))))
			(parsed-locktime (try! (read-uint32 (get ctx parsed-txouts)))))
		(asserts! (is-eq (len tx) (get index (get ctx parsed-locktime))) ERR-LEFTOVER-DATA)
		(ok {
			version: (get uint32 parsed-version),
			ins: (get txins parsed-txins),
			outs: (get txouts parsed-txouts),
			locktime: (get uint32 parsed-locktime)})))

;; Parse a Bitcoin block header.
;; Returns a tuple structured as folowed on success:
;; (ok {
;;      version: uint,                  ;; block version,
;;      parent: (buff 32),              ;; parent block hash,
;;      merkle-root: (buff 32),         ;; merkle root for all this block's transactions
;;      timestamp: uint,                ;; UNIX epoch timestamp of this block, in seconds
;;      nbits: uint,                    ;; compact block difficulty representation
;;      nonce: uint                     ;; PoW solution
;; })
(define-read-only (parse-block-header (headerbuff (buff 80)))
	(let (
			(ctx { txbuff: headerbuff, index: u0})
			(parsed-version (try! (read-uint32 ctx)))
			(parsed-parent-hash (try! (read-hashslice (get ctx parsed-version))))
			(parsed-merkle-root (try! (read-hashslice (get ctx parsed-parent-hash))))
			(parsed-timestamp (try! (read-uint32 (get ctx parsed-merkle-root))))
			(parsed-nbits (try! (read-uint32 (get ctx parsed-timestamp))))
			(parsed-nonce (try! (read-uint32 (get ctx parsed-nbits)))))
		(ok {
			version: (get uint32 parsed-version),
			parent: (get hashslice parsed-parent-hash),
			merkle-root: (get hashslice parsed-merkle-root),
			timestamp: (get uint32 parsed-timestamp),
			nbits: (get uint32 parsed-nbits),
			nonce: (get uint32 parsed-nonce)})))

(define-map mock-burnchain-header-hashes uint (buff 32))

(define-public (mock-add-burnchain-block-header-hash (burn-height uint) (hash (buff 32)))
	(ok (map-set mock-burnchain-header-hashes burn-height hash)))

(define-read-only (get-bc-h-hash (bh uint))
	(if (is-eq chain-id u1) (get-burn-block-info? header-hash bh) (map-get? mock-burnchain-header-hashes bh)))

;; Verify that a block header hashes to a burnchain header hash at a given height.
;; Returns true if so; false if not.
(define-read-only (verify-block-header (headerbuff (buff 80)) (expected-block-height uint))
	(match (get-bc-h-hash expected-block-height)
		bhh
		(is-eq bhh (reverse-buff32 (sha256 (sha256 headerbuff))))
		false))

;; Get the txid of a transaction, but little-endian.
;; This is the reverse of what you see on block explorers.
;; For a segwit tx, this produces wtxid (reversed).
(define-read-only (get-reversed-txid (tx (buff 32768)))
	(sha256 (sha256 tx)))

;; Get the txid of a transaction.
;; This is what you see on block explorers.
;; For a segwit tx, this produces wtxid.
(define-read-only (get-txid (tx (buff 32768)))
	(reverse-buff32 (get-reversed-txid tx)))

;; Get the txid of a native segwit transaction, but little-endian.
;; This produces a "classic" (reversed) txid for a segwit tx by dropping the witness data
(define-read-only (get-reversed-segwit-txid (tx (buff 32768)))
	(let (
			(ctx { txbuff: tx, index: u0})
			(parsed-version (unwrap-panic (read-uint32 ctx)))
			(parsed-segwit-marker (unwrap-panic (read-uint8 (get ctx parsed-version))))
			(parsed-segwit-version (unwrap-panic (read-uint8 (get ctx parsed-segwit-marker))))
			(parsed-txins (unwrap-panic (read-txins (get ctx parsed-segwit-version))))
			(parsed-txouts (unwrap-panic (read-txouts (get ctx parsed-txins))))
			(parsed-witnesses (unwrap-panic (read-witnesses (get ctx parsed-txouts) (len (get txins parsed-txins)))))
			(parsed-locktime (unwrap-panic (read-uint32 (get ctx parsed-witnesses))))
			(dropped-tx
				(concat
					(unwrap-panic (slice? tx u0 (get index (get ctx parsed-version))))
					(concat
						(unwrap-panic (slice? tx (get index (get ctx parsed-segwit-version)) (get index (get ctx parsed-txouts))))
						(unwrap-panic (slice? tx (get index (get ctx parsed-witnesses)) (len tx)))))))
		(sha256 (sha256 dropped-tx))
	)
)

;; Get the txid of a native segwit transaction, but little-endian.
;; This produces a "classic" txid for a segwit tx by dropping the witness data
(define-read-only (get-segwit-txid (tx (buff 32768)))
	(reverse-buff32 (get-reversed-segwit-txid tx))
)

;; Determine if the ith bit in a uint is set to 1
(define-read-only (is-bit-set (val uint) (bit uint))
	(> (bit-and val (bit-shift-left u1 bit)) u0))

;; Verify the next step of a Merkle proof.
;; This hashes cur-hash against the ctr-th hash in proof-hashes, and uses that as the next cur-hash.
;; The path is a bitfield describing the walk from the txid up to the merkle root:
;; * if the ith bit is 0, then cur-hash is hashed before the next proof-hash (cur-hash is "left").
;; * if the ith bit is 1, then the next proof-hash is hashed before cur-hash (cur-hash is "right").
;; The proof verifies if cur-hash is equal to root-hash, and we're out of proof-hashes to check.
(define-read-only (inner-merkle-proof-verify (ctr uint) (state { path: uint, root-hash: (buff 32), proof-hashes: (list 14 (buff 32)), tree-depth: uint, cur-hash: (buff 32), verified: bool}))
	(if (get verified state)
		state
		(if (>= ctr (get tree-depth state))
			(merge state { verified: false})
			(let (
					(path (get path state))
					(is-left (is-bit-set path ctr))
					(proof-hashes (get proof-hashes state))
					(cur-hash (get cur-hash state))
					(root-hash (get root-hash state))
					(h1 (if is-left (unwrap-panic (element-at proof-hashes ctr)) cur-hash))
					(h2 (if is-left cur-hash (unwrap-panic (element-at proof-hashes ctr))))
					(next-hash (sha256 (sha256 (concat h1 h2))))
					(is-verified (and (is-eq (+ u1 ctr) (len proof-hashes)) (is-eq next-hash root-hash))))
				(merge state { cur-hash: next-hash, verified: is-verified})))))

;; Verify a Merkle proof, given the _reversed_ txid of a transaction, the merkle root of its block, and a proof consisting of:
;; * The index in the block where the transaction can be found (starting from 0),
;; * The list of hashes that link the txid to the merkle root,
;; * The depth of the block's merkle tree (required because Bitcoin does not identify merkle tree nodes as being leaves or intermediates).
;; The _reversed_ txid is required because that's the order (little-endian) processes them in.
;; The tx-index is required because it tells us the left/right traversals we'd make if we were walking down the tree from root to transaction,
;; and is thus used to deduce the order in which to hash the intermediate hashes with one another to link the txid to the merkle root.
;; Returns (ok true) if the proof is valid.
;; Returns (ok false) if the proof is invalid.
;; Returns ERR-PROOF-TOO-SHORT if the proof's hashes aren't long enough to link the txid to the merkle root.
(define-read-only (verify-merkle-proof (reversed-txid (buff 32)) (merkle-root (buff 32)) (proof { tx-index: uint, hashes: (list 14 (buff 32)), tree-depth: uint}))
	(if (> (get tree-depth proof) (len (get hashes proof)))
		ERR-PROOF-TOO-SHORT
		(ok
			(get verified
				(fold inner-merkle-proof-verify
						(list u0 u1 u2 u3 u4 u5 u6 u7 u8 u9 u10 u11 u12 u13)
						{
							path: (+ (pow u2 (get tree-depth proof)) (get tx-index proof)),
							root-hash: merkle-root,
							proof-hashes: (get hashes proof),
							cur-hash: reversed-txid,
							tree-depth: (get tree-depth proof),
							verified: false})))))

;; Top-level verification code to determine whether or not a Bitcoin transaction was mined in a prior Bitcoin block.
;; It takes the block header and block height, the transaction, and a merkle proof, and determines that:
;; * the block header corresponds to the block that was mined at the given Bitcoin height
;; * the transaction's merkle proof links it to the block header's merkle root.
;; The proof is a list of sibling merkle tree nodes that allow us to calculate the parent node from two children nodes in each merkle tree level,
;; the depth of the block's merkle tree, and the index in the block in which the given transaction can be found (starting from 0).
;; The first element in hashes must be the given transaction's sibling transaction's ID.  This and the given transaction's txid are hashed to
;; calculate the parent hash in the merkle tree, which is then hashed with the *next* hash in the proof, and so on and so forth, until the final
;; hash can be compared against the block header's merkle root field.  The tx-index tells us in which order to hash each pair of siblings.
;; Note that the proof hashes -- including the sibling txid -- must be _big-endian_ hashes, because this is how Bitcoin generates them.
;; This is the reverse of what you'd see in a block explorer!
;; Returns (ok true) if the proof checks out.
;; Returns (ok false) if not.
;; Returns ERR-PROOF-TOO-SHORT if the proof doesn't contain enough intermediate hash nodes in the merkle tree.

(define-read-only (was-tx-mined? (block { header: (buff 80), height: uint }) (tx (buff 32768)) (proof { tx-index: uint, hashes: (list 14 (buff 32)), tree-depth: uint }))
	(let (
			(header-valid (verify-block-header (get header block) (get height block)))
			(reversed-txid (get-reversed-txid tx))
			(parsed-header (try! (parse-block-header (get header block))))
			(merkle-root (reverse-buff32 (get merkle-root parsed-header)))
			(merkle-valid (verify-merkle-proof reversed-txid merkle-root proof)))
		(if header-valid
			merkle-valid
			(ok false))))

(define-read-only (was-segwit-tx-mined? (block { header: (buff 80), height: uint }) (tx (buff 32768)) (proof { tx-index: uint, hashes: (list 14 (buff 32)), tree-depth: uint }))
	(let (
			(header-valid (verify-block-header (get header block) (get height block)))
			(reversed-txid (get-reversed-segwit-txid tx))
			(parsed-header (try! (parse-block-header (get header block))))
			(merkle-root (reverse-buff32 (get merkle-root parsed-header)))
			(merkle-valid (verify-merkle-proof reversed-txid merkle-root proof)))
		(if header-valid
			merkle-valid
			(ok false))))
