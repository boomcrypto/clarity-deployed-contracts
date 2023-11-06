(define-constant ERR-NOT-AUTHORIZED (err u1000))
(define-constant ERR-UNKNOWN-VALIDATOR (err u1001))
(define-constant ERR-PAUSED (err u1002))
(define-constant ERR-UKNOWN-RELAYER (err u1003))
(define-constant ERR-REQUIRED-VALIDATORS (err u1004))
(define-constant ERR-VALIDATOR-ALREADY-REGISTERED (err u1005))
(define-constant ERR-DUPLICATE-SIGNATURE (err u1006))
(define-constant ERR-ORDER-HASH-MISMATCH (err u1007))
(define-constant ERR-INVALID-SIGNATURE (err u1008))
(define-constant ERR-BITCOIN-TX-NOT-MINED (err u1009))
(define-constant MAX_UINT u340282366920938463463374607431768211455)
(define-constant ONE_8 u100000000)
(define-constant MAX_REQUIRED_VALIDATORS u10)
(define-constant structured-data-prefix 0x534950303138)
(define-constant message-domain-mainnet 0x6d11cd301d11961e7cfeabd61e3f4da17f42f3d627362c8878aa9cbb5c532be2) ;;mainnet
(define-constant message-domain-testnet 0x84deb9a3b41b870d85819000deefa999f43b1bf2c3d80c3ea19d4b83b7b10fbc) ;; testnet
(define-data-var contract-owner principal tx-sender)
(define-map approved-relayers principal bool)
(define-data-var is-paused bool true)
(define-map validators principal (buff 33))
(define-data-var validator-count uint u0)
(define-data-var required-validators uint MAX_UINT)
(define-map tx-validated-by { tx-hash: (buff 32), validator: principal } bool)
(define-data-var tx-hash-to-iter (buff 32) 0x)
(define-public (set-paused (paused bool))
	(begin
		(try! (check-is-owner))
		(ok (var-set is-paused paused))))
(define-public (add-validator (validator-pubkey (buff 33)) (validator principal))
	(begin
		(try! (check-is-owner))
		(asserts! (is-none (map-get? validators validator)) ERR-VALIDATOR-ALREADY-REGISTERED)
		(map-set validators validator validator-pubkey)
		(var-set validator-count (+ u1 (var-get validator-count)))
		(ok (var-get validator-count))))
(define-public (remove-validator (validator principal))
	(begin
		(try! (check-is-owner))
		(asserts! (is-some (map-get? validators validator)) ERR-UNKNOWN-VALIDATOR)
		(map-delete validators validator)
		(var-set validator-count (- (var-get validator-count) u1))
		(ok (var-get validator-count))))
(define-public (approve-relayer (relayer principal) (approved bool))
	(begin
		(try! (check-is-owner))
		(ok (map-set approved-relayers relayer approved))))
(define-public (set-required-validators (new-required-validators uint))
	(begin
		(try! (check-is-owner))
		(asserts! (< new-required-validators MAX_REQUIRED_VALIDATORS) ERR-REQUIRED-VALIDATORS)
		(ok (var-set required-validators new-required-validators))))
(define-public (set-contract-owner (owner principal))
	(begin
		(try! (check-is-owner))
		(ok (var-set contract-owner owner))))
(define-read-only (message-domain)
	(if (is-eq chain-id u1) message-domain-mainnet message-domain-testnet))
(define-read-only (get-contract-owner)
	(var-get contract-owner))
(define-read-only (get-validator-or-fail (validator principal))
	(ok (unwrap! (map-get? validators validator) ERR-UNKNOWN-VALIDATOR)))
(define-read-only (get-required-validators)
	(var-get required-validators))
(define-read-only (hash-tx (tx { bitcoin-tx: (buff 4096), output: uint, offset: uint, tick: (string-utf8 4), amt: uint, from: (buff 128), to: (buff 128), from-bal: uint, to-bal: uint, decimals: uint } ))
	(sha256 (unwrap-panic (to-consensus-buff? tx))))
(define-read-only (get-paused)
	(var-get is-paused))
(define-read-only (get-user-balance-or-default (user (buff 128)) (tick (string-utf8 4)))
	(contract-call? .oracle-registry-v1-01 get-user-balance-or-default user tick))
(define-read-only (get-tick-decimals-or-default (tick (string-utf8 4)))
	(contract-call? .oracle-registry-v1-01 get-tick-decimals-or-default tick))
(define-read-only (get-bitcoin-tx-mined-or-fail (tx (buff 4096)))
	(contract-call? .oracle-registry-v1-01 get-bitcoin-tx-mined-or-fail tx))
(define-read-only (get-bitcoin-tx-indexed-or-fail (bitcoin-tx (buff 4096)) (output uint) (offset uint))
	(contract-call? .oracle-registry-v1-01 get-bitcoin-tx-indexed-or-fail bitcoin-tx output offset))
(define-read-only (validate-tx (tx-hash (buff 32)) (signature-pack { signer: principal, tx-hash: (buff 32), signature: (buff 65)}))
	(let (
			(validator-pubkey (try! (get-validator-or-fail (get signer signature-pack)))))
		(asserts! (is-none (map-get? tx-validated-by { tx-hash: tx-hash, validator: (get signer signature-pack) })) ERR-DUPLICATE-SIGNATURE)
		(asserts! (is-eq tx-hash (get tx-hash signature-pack)) ERR-ORDER-HASH-MISMATCH)
		(ok (asserts! (is-eq (secp256k1-recover? (sha256 (concat structured-data-prefix (concat (message-domain) tx-hash))) (get signature signature-pack)) (ok validator-pubkey)) ERR-INVALID-SIGNATURE))))
(define-read-only (verify-mined (tx (buff 4096)) (block { header: (buff 80), height: uint }) (proof { tx-index: uint, hashes: (list 14 (buff 32)), tree-depth: uint }))
	(if (is-eq chain-id u1)		
		(let
			(
				(response (if (try! (contract-call? .clarity-bitcoin-v1-02 is-segwit-tx tx)) 
					(contract-call? .clarity-bitcoin-v1-02 was-segwit-tx-mined? block tx proof)
					(contract-call? .clarity-bitcoin-v1-02 was-tx-mined? block tx proof))))
			(if (or (is-err response) (not (unwrap-panic response)))
				ERR-BITCOIN-TX-NOT-MINED
				(ok true)))
		;; if not mainnet, assume verified
		(ok true)))
(define-public (index-tx-many
		(tx-many (list 25 {
			tx: { bitcoin-tx: (buff 4096), output: uint, offset: uint, tick: (string-utf8 4), amt: uint, from: (buff 128), to: (buff 128), from-bal: uint, to-bal: uint, decimals: uint },
			block: { header: (buff 80), height: uint },
			proof: { tx-index: uint, hashes: (list 14 (buff 32)), tree-depth: uint },
			signature-packs: (list 10 { signer: principal, tx-hash: (buff 32), signature: (buff 65) })})))
	(begin
		(asserts! (not (var-get is-paused)) ERR-PAUSED)
		(asserts! (is-some (map-get? approved-relayers tx-sender)) ERR-UKNOWN-RELAYER)
		(fold index-tx-iter tx-many (ok true))))
(define-private (validate-signature-iter
		(signature-pack { signer: principal, tx-hash: (buff 32), signature: (buff 65)})
		(previous-response (response bool uint)))
	(match previous-response
		prev-ok
		(begin
			(try! (validate-tx (var-get tx-hash-to-iter) signature-pack))
			(ok (map-set tx-validated-by { tx-hash: (var-get tx-hash-to-iter), validator: (get signer signature-pack) } true)))
		prev-err
		previous-response))
(define-private (index-tx-iter
		(signed-tx {
			tx: { bitcoin-tx: (buff 4096), output: uint, offset: uint, tick: (string-utf8 4), amt: uint, from: (buff 128), to: (buff 128), from-bal: uint, to-bal: uint, decimals: uint },
			block: { header: (buff 80), height: uint },
			proof: { tx-index: uint, hashes: (list 14 (buff 32)), tree-depth: uint },
			signature-packs: (list 10 { signer: principal, tx-hash: (buff 32), signature: (buff 65)}) })
		(previous-response (response bool uint)))
	(match previous-response
		prev-ok
		(let (
				(tx (get tx signed-tx))
				(signature-packs (get signature-packs signed-tx))
				(tx-hash (hash-tx tx))
				(from-bal (get-user-balance-or-default (get from tx) (get tick tx)))
				(to-bal (get-user-balance-or-default (get to tx) (get tick tx)))
				(height (get height (get block signed-tx)))
			)
			(asserts! (>= (len signature-packs) (var-get required-validators)) ERR-REQUIRED-VALIDATORS)
			(and (is-err (get-bitcoin-tx-mined-or-fail (get bitcoin-tx tx))) 
				(begin 
					(try! (verify-mined (get bitcoin-tx tx) (get block signed-tx) (get proof signed-tx)))
					(as-contract (try! (contract-call? .oracle-registry-v1-01 set-tx-mined (get bitcoin-tx tx) (get height (get block signed-tx)))))
				)
			)
			(var-set tx-hash-to-iter tx-hash)
			(try! (fold validate-signature-iter signature-packs (ok true)))
			(as-contract (try! (contract-call? .oracle-registry-v1-01 set-tx-indexed { tx-hash: (get bitcoin-tx tx), output: (get output tx), offset: (get offset tx) } { tick: (get tick tx), amt: (get amt tx), from: (get from tx), to: (get to tx) })))
			(and (> height (get up-to-block from-bal)) (as-contract (try! (contract-call? .oracle-registry-v1-01 set-user-balance { user: (get from tx), tick: (get tick tx) } { balance: (get from-bal tx), up-to-block: height }))))
			(and (> height (get up-to-block to-bal)) (as-contract (try! (contract-call? .oracle-registry-v1-01 set-user-balance { user: (get to tx), tick: (get tick tx) } { balance: (get to-bal tx), up-to-block: height }))))
			(as-contract (try! (contract-call? .oracle-registry-v1-01 set-tick-decimals (get tick tx) (get decimals tx))))
			(ok true))
		prev-err
		previous-response))
(define-private (check-is-owner)
	(ok (asserts! (is-eq (var-get contract-owner) tx-sender) ERR-NOT-AUTHORIZED)))