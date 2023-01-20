(impl-trait .trait-ownable.ownable-trait)
(use-trait ft-trait .trait-sip-010.sip-010-trait)
(define-constant ERR-NOT-AUTHORIZED (err u1000))
(define-constant ERR-TOKEN-NOT-AUTHORIZED (err u1001))
(define-constant ERR-RECIPIENT-NOT-AUTHORIZED (err u1002))
(define-constant ERR-WRAPPER-NOT-AUTHORIZED (err u1004))
(define-constant ERR-UNKNOWN-USER-ID (err u1005))
(define-constant ERR-UNKNOWN-VALIDATOR-ID (err u1006))
(define-constant ERR-USER-ALREADY-REGISTERED (err u1007))
(define-constant ERR-VALIDATOR-ALREADY-REGISTERED (err u1008))
(define-constant ERR-DUPLICATE-SIGNATURE (err u1009))
(define-constant ERR-ORDER-HASH-MISMATCH (err u1010))
(define-constant ERR-INVALID-SIGNATURE (err u1011))
(define-constant ERR-UKNOWN-RELAYER (err u1012))
(define-constant ERR-REQUIRED-VALIDATORS (err u1013))
(define-constant ERR-ORDER-ALREADY-SENT (err u1014))
(define-constant ERR-PAUSED (err u1015))
(define-constant ERR-USER-NOT-WHITELISTED (err u1016))
(define-constant ERR-AMOUNT-LESS-THAN-MIN-FEE (err u1017))
(define-constant ERR-UNKNOWN-CHAIN-ID (err u1018))
(define-constant ERR-INVALID-AMOUNT (err u1019))
(define-constant MAX_UINT u340282366920938463463374607431768211455)
(define-constant ONE_8 u100000000)
(define-constant MAX_REQUIRED_VALIDATORS u100)
(define-constant structured-data-prefix 0x534950303138)
(define-constant message-domain 0x57790ebb55cb7aa3d0ffb493faf4fa3a8513cc07323280dac9f19a442bc81809) ;;mainnet
(define-constant serialized-key-to (serialize-tuple-key "to"))
(define-constant serialized-key-token (serialize-tuple-key "token"))
(define-constant serialized-key-amount (serialize-tuple-key "amount-in-fixed"))
(define-constant serialized-key-salt (serialize-tuple-key "salt"))
(define-constant serialized-key-chain-id (serialize-tuple-key "chain-id"))
(define-constant serialized-order-header (concat type-id-tuple (uint32-to-buff-be u5)))
(define-data-var contract-owner principal tx-sender)
(define-data-var is-paused bool true)
(define-data-var use-whitelist bool false)
(define-map approved-recipients principal bool)
(define-map approved-relayers principal bool)
(define-map whitelisted-users principal bool)
(define-data-var token-nonce uint u0)
(define-map token-id-registry principal uint)
(define-map token-registry uint { token: principal, approved: bool, fee: uint, min-amount: uint, max-amount: uint, accrued-fee: uint })
(define-data-var chain-nonce uint u0)
(define-map chain-registry uint { name: (string-utf8 256), min-fee: uint, buff-length: uint })
(define-data-var validator-nonce uint u0)
(define-map validator-id-registry principal uint)
(define-map validator-registry uint { validator: principal, validator-pubkey: (buff 33) })
(define-data-var validator-count uint u0)
(define-data-var required-validators uint MAX_UINT)
(define-map order-sent (buff 32) bool)
(define-map order-validated-by { order-hash: (buff 32), validator: principal } bool)
(define-data-var user-nonce uint u0)
(define-map user-registry uint principal)
(define-map user-id-registry principal uint)
(define-data-var order-hash-to-iter (buff 32) 0x)
(define-public (register-user (user principal))
  (let
    (
      (reg-id (+ (var-get user-nonce) u1))
    )
    (asserts! (not (var-get is-paused)) ERR-PAUSED)
    (asserts! (or (not (var-get use-whitelist)) (is-whitelisted user)) ERR-USER-NOT-WHITELISTED)
    (asserts! (map-insert user-id-registry user reg-id) ERR-USER-ALREADY-REGISTERED)
    (map-insert user-registry reg-id user)
    (var-set user-nonce reg-id)
    (print { object: "bridge-endpoint", action: "register-user", user-id: reg-id, principal: user })
    (ok reg-id)
  )
)
(define-public (transfer-to-unwrap (token-trait <ft-trait>) (amount-in-fixed uint) (recipient principal) (the-chain-id uint) (settle-address (buff 256)))
  (let
    (
      (token (contract-of token-trait))
      (chain-details (try! (get-approved-chain-or-fail the-chain-id)))
      (token-id (try! (get-approved-token-id-or-fail token)))
      (token-details (try! (get-approved-token-or-fail token)))
      (fee (max (mul-down amount-in-fixed (get fee token-details)) (get min-fee chain-details)))
      (net-amount (- amount-in-fixed fee))
      (user-id (match (get-user-id tx-sender) user-id user-id (try! (register-user tx-sender))))
    )
    (asserts! (not (var-get is-paused)) ERR-PAUSED)
    (asserts! (or (not (var-get use-whitelist)) (is-whitelisted tx-sender)) ERR-USER-NOT-WHITELISTED)
    (asserts! (and (>= amount-in-fixed (get min-amount token-details)) (<= amount-in-fixed (get max-amount token-details))) ERR-INVALID-AMOUNT)
    (asserts! (> amount-in-fixed (get min-fee chain-details)) ERR-AMOUNT-LESS-THAN-MIN-FEE)
    (try! (check-is-approved-recipient recipient))
    (try! (contract-call? token-trait transfer-fixed net-amount tx-sender recipient none))
    (and (> fee u0) (try! (contract-call? token-trait transfer-fixed fee tx-sender (as-contract tx-sender) none)))
    (and (> fee u0) (map-set token-registry token-id (merge token-details { accrued-fee: (+ (get accrued-fee token-details) fee) })))
    (print { 
      object: "bridge-endpoint", 
      action: "transfer-to-unwrap", 
      user-id: user-id, 
      chain: (get name chain-details), 
      net-amount: net-amount, 
      settle-address: 
      (buff-slice settle-address u0 (get buff-length chain-details)), 
      recipient: recipient, 
      token-id: token-id 
    })
    (ok true)
  )
)
(define-read-only (is-whitelisted (user principal))
  (default-to false (map-get? whitelisted-users user))
)
(define-read-only (get-user-id (user principal))
  (map-get? user-id-registry user)
)
(define-read-only (get-user-id-or-fail (user principal))
  (ok (unwrap! (get-user-id user) ERR-UNKNOWN-USER-ID))
)
(define-read-only (user-from-id (id uint))
  (map-get? user-registry id)
)
(define-read-only (user-from-id-or-fail (id uint))
  (ok (unwrap! (user-from-id id) ERR-UNKNOWN-USER-ID))
)
(define-read-only (get-validator-id (validator principal))
	(map-get? validator-id-registry validator)
)
(define-read-only (get-validator-id-or-fail (validator principal))
	(ok (unwrap! (get-validator-id validator) ERR-UNKNOWN-VALIDATOR-ID))
)
(define-read-only (validator-from-id (id uint))
	(map-get? validator-registry id)
)
(define-read-only (validator-from-id-or-fail (id uint))
	(ok (unwrap! (validator-from-id id) ERR-UNKNOWN-VALIDATOR-ID))
)
(define-read-only (get-required-validators)
  (var-get required-validators)
)
(define-read-only (get-paused)
  (var-get is-paused)
)
(define-read-only (get-approved-chain-or-fail (the-chain-id uint))
  (ok (unwrap! (map-get? chain-registry the-chain-id) ERR-UNKNOWN-CHAIN-ID))
)
(define-read-only (hash-order
  (order
    {
      to: uint,
      token: uint,
      amount-in-fixed: uint,
      chain-id: uint,
      salt: (buff 256)
    }
  )
  )
	(sha256
		(concat serialized-order-header
    (concat serialized-key-amount
      (concat (serialize-uint (get amount-in-fixed order))
      (concat serialized-key-chain-id
      (concat (serialize-uint (get chain-id order))
      (concat serialized-key-salt
			(concat (serialize-buff (get salt order))
      (concat serialized-key-to
      (concat (serialize-uint (get to order))
      (concat serialized-key-token (serialize-uint (get token order))
      ))))))))))
	)
)
(define-read-only (get-contract-owner)
  (ok (var-get contract-owner))
)
(define-read-only (get-approved-token-id-or-fail (token principal))
  (ok (unwrap! (map-get? token-id-registry token) ERR-TOKEN-NOT-AUTHORIZED))
)
(define-read-only (get-approved-token-by-id-or-fail (token-id uint))
  (ok (unwrap! (map-get? token-registry token-id) ERR-TOKEN-NOT-AUTHORIZED))
)
(define-read-only (get-approved-token-or-fail (token principal))
  (get-approved-token-by-id-or-fail (try! (get-approved-token-id-or-fail token)))
)
(define-read-only (check-is-approved-token (token principal))
  (ok (asserts! (get approved (try! (get-approved-token-or-fail token))) ERR-TOKEN-NOT-AUTHORIZED))
)
(define-read-only (check-is-approved-recipient (recipient principal))
  (ok (asserts! (default-to false (map-get? approved-recipients recipient)) ERR-RECIPIENT-NOT-AUTHORIZED))
)
(define-public (transfer-to-wrap
    (order
      {
        to: uint,
        token: uint,
        amount-in-fixed: uint,
        chain-id: uint,
        salt: (buff 256)
      }
    )
    (token-trait <ft-trait>)
    (signature-packs (list 100 { signer: principal, order-hash: (buff 32), signature: (buff 65)})))
    (let
        (
          (order-hash (hash-order order))
          (user (try! (user-from-id-or-fail (get to order))))
        )
        (asserts! (not (var-get is-paused)) ERR-PAUSED)
        (asserts! (is-some (map-get? approved-relayers tx-sender)) ERR-UKNOWN-RELAYER)
        (asserts! (>= (len signature-packs) (var-get required-validators)) ERR-REQUIRED-VALIDATORS)
        (asserts! (is-none (map-get? order-sent order-hash)) ERR-ORDER-ALREADY-SENT)
        (var-set order-hash-to-iter order-hash)
        (try! (fold validate-signature-iter signature-packs (ok true)))
        (as-contract (try! (transfer-to-wrap-internal order token-trait)))
        (ok (map-set order-sent order-hash true))
    )
)
(define-public (add-validator (validator-pubkey (buff 33)) (validator principal))
	(let
		(
			(reg-id (+ (var-get validator-nonce) u1))
		)
    (try! (check-is-owner))
		(asserts! (map-insert validator-id-registry validator reg-id) ERR-VALIDATOR-ALREADY-REGISTERED)
		(map-insert validator-registry reg-id {validator: validator, validator-pubkey: validator-pubkey})
		(var-set validator-nonce reg-id)
    (var-set validator-count (+ u1 (var-get validator-count)))
		(ok (+ u1 (var-get validator-count)))
	)
)
(define-public (remove-validator (validator principal))
    (let
        (
          (reg-id (unwrap! (map-get? validator-id-registry validator) ERR-UNKNOWN-VALIDATOR-ID ))
        )
        (try! (check-is-owner))
        (map-delete validator-id-registry validator)
        (map-delete validator-registry reg-id)
        (var-set validator-count (- (var-get validator-count) u1))
        (ok (- (var-get validator-count) u1))
    )
)
(define-public (approve-relayer (relayer principal) (approved bool))
    (begin
        (try! (check-is-owner))
        (ok (map-set approved-relayers relayer approved))
    )
)
(define-public (set-required-validators (new-required-validators uint))
    (begin
        (try! (check-is-owner))
        (asserts! (< new-required-validators MAX_REQUIRED_VALIDATORS) ERR-REQUIRED-VALIDATORS)
        (ok (var-set required-validators new-required-validators))
    )
)
(define-public (set-paused (paused bool))
  (begin
    (try! (check-is-owner))
    (ok (var-set is-paused paused))
  )
)
(define-public (apply-whitelist (new-use-whitelist bool))
  (begin
    (try! (check-is-owner))
    (ok (var-set use-whitelist new-use-whitelist))
  )
)
(define-public (set-approved-chain (the-chain-id uint) (chain-details { name: (string-utf8 256), min-fee: uint, buff-length: uint }))
  (begin 
    (try! (check-is-owner))
    (if (is-some (map-get? chain-registry the-chain-id))
      (begin    
        (map-set chain-registry the-chain-id chain-details)
        (ok the-chain-id)
      )
      (let 
        (
          (the-chain-id-next (+ (var-get chain-nonce) u1))
        )
        (var-set chain-nonce the-chain-id-next)
        (map-set chain-registry the-chain-id-next chain-details)
        (ok the-chain-id-next)
      )
    )
  )
)
(define-public (set-approved-token (token principal) (approved bool) (fee uint) (min-amount uint) (max-amount uint))
	(begin
		(try! (check-is-owner))
    (match (map-get? token-id-registry token)
      token-id
      (begin
        (map-set token-registry token-id (merge (try! (get-approved-token-by-id-or-fail token-id)) { approved: approved, fee: fee, min-amount: min-amount, max-amount: max-amount }))
        (ok token-id)
      )
      (let
        (
          (token-id (+ u1 (var-get token-nonce)))
        )
        (map-set token-id-registry token token-id)
        (map-set token-registry token-id { token: token, approved: approved, fee: fee, min-amount: min-amount, max-amount: max-amount, accrued-fee: u0 })
        (var-set token-nonce token-id)
        (ok token-id)
      )
    )
	)
)
(define-public (collect-accrued-fee (token-trait <ft-trait>))
  (let
    (
      (token-id (try! (get-approved-token-id-or-fail (contract-of token-trait))))
      (token-details (try! (get-approved-token-or-fail (contract-of token-trait))))
    )
    (try! (check-is-owner))
    (as-contract (try! (contract-call? token-trait transfer-fixed (get accrued-fee token-details) tx-sender (var-get contract-owner) none)))
    (ok (map-set token-registry token-id (merge token-details { accrued-fee: u0 })))
  )
)
(define-public (set-approved-recipient (recipient principal) (approved bool))
	(begin
		(try! (check-is-owner))
		(ok (map-set approved-recipients recipient approved))
	)
)
(define-public (whitelist (user principal) (whitelisted bool))
  (begin
    (try! (check-is-owner))
    (ok (map-set whitelisted-users user whitelisted))
  )
)
(define-public (whitelist-many (users (list 2000 principal)) (whitelisted (list 2000 bool)))
  (ok (map whitelist users whitelisted))
)
(define-public (set-contract-owner (owner principal))
  (begin
    (try! (check-is-owner))
    (ok (var-set contract-owner owner))
  )
)
(define-private (validate-order (order-hash (buff 32)) (signature-pack { signer: principal, order-hash: (buff 32), signature: (buff 65)}))
    (let
        (
            (validator (unwrap! (map-get? validator-registry (unwrap! (map-get? validator-id-registry (get signer signature-pack)) ERR-UNKNOWN-VALIDATOR-ID )) ERR-UNKNOWN-VALIDATOR-ID ))
        )
        (asserts! (is-none (map-get? order-validated-by { order-hash: order-hash, validator: (get signer signature-pack) })) ERR-DUPLICATE-SIGNATURE)
        (asserts! (is-eq order-hash (get order-hash signature-pack)) ERR-ORDER-HASH-MISMATCH)
        (asserts! (is-eq (secp256k1-recover? (sha256 (concat structured-data-prefix (concat message-domain order-hash))) (get signature signature-pack)) (ok (get validator-pubkey validator))) ERR-INVALID-SIGNATURE)
        (ok (map-set order-validated-by { order-hash: order-hash, validator: (get signer signature-pack) } true))
    )
)
(define-private (validate-signature-iter
    (signature-pack { signer: principal, order-hash: (buff 32), signature: (buff 65)})
    (previous-response (response bool uint))
    )
    (match previous-response
        prev-ok
        (validate-order (var-get order-hash-to-iter) signature-pack)
        prev-err
        previous-response
    )
)
(define-private (check-is-owner)
  (ok (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED))
)
(define-private (transfer-to-wrap-internal
  (order
    {
      to: uint,
      token: uint,
      amount-in-fixed: uint,
      chain-id: uint,
      salt: (buff 256)
    }
  )
  (token-trait <ft-trait>)
  )
  (let
    (
      (chain-details (try! (get-approved-chain-or-fail (get chain-id order))))
      (recipient (try! (user-from-id-or-fail (get to order))))
    )
    (asserts! (is-eq (try! (get-approved-token-id-or-fail (contract-of token-trait))) (get token order)) ERR-TOKEN-NOT-AUTHORIZED)
    (try! (contract-call? token-trait transfer-fixed (get amount-in-fixed order) tx-sender recipient none))
    (print { 
      object: "bridge-endpoint", 
      action: "transfer-to-wrap", 
      salt: (get salt order), 
      principal: recipient, 
      amount-in-fixed: (get amount-in-fixed order), 
      token: (get token order), 
      to: (get to order), 
      chain-id: (get chain-id order) 
    })
    (ok true)
  )
)
(define-private (buff-slice-iterator (byte (buff 1)) (state {accumulator: (buff 256), index: uint, start: uint, end: uint}))
	(let
		(
			(start (get start state))
			(end (get end state))
			(index (get index state))
			(accumulator (get accumulator state))
		)
		{
			start: start,
			end: end,
			accumulator: (if (and (>= index start) (< index end)) (unwrap-panic (as-max-len? (concat accumulator byte) u256)) accumulator),
			index: (+ index u1)
		}
	)
)
(define-read-only (buff-slice (bytes (buff 256)) (start uint) (end uint))
	(get accumulator (fold buff-slice-iterator bytes {accumulator: 0x, index: u0, start: start, end: end}))
)
(define-private (mul-down (a uint) (b uint))
    (/ (* a b) ONE_8)
)
(define-private (div-down (a uint) (b uint))
    (if (is-eq a u0)
        u0
        (/ (* a ONE_8) b)
   )
)
(define-private (max (a uint) (b uint))
  (if (<= a b) b a)
)
(define-read-only (serialize-tuple-key (key (string-ascii 128)))
	(concat
		(unwrap-panic (element-at byte-list (len key)))
		(string-ascii-to-buff key)
	)
)
(define-read-only (serialize-bool (value bool))
	(if value type-id-true type-id-false)
)
(define-read-only (serialize-uint (value uint))
	(concat type-id-uint (uint128-to-buff-be value))
)
(define-read-only (serialize-buff (value (buff 256)))
	(concat
		type-id-buff
	(concat
		(uint32-to-buff-be (len value))
		value
	))
)
(define-read-only (byte-to-uint (byte (buff 1)))
	(unwrap-panic (index-of byte-list byte))
)
(define-read-only (uint-to-byte (n uint))
	(unwrap-panic (element-at byte-list (mod n u255)))
)
(define-read-only (uint128-to-buff-be (n uint))
	(concat (unwrap-panic (element-at byte-list (mod (/ n u1329227995784915872903807060280344576) u256)))
		(concat (unwrap-panic (element-at byte-list (mod (/ n u5192296858534827628530496329220096) u256)))
		(concat (unwrap-panic (element-at byte-list (mod (/ n u20282409603651670423947251286016) u256)))
		(concat (unwrap-panic (element-at byte-list (mod (/ n u79228162514264337593543950336) u256)))
		(concat (unwrap-panic (element-at byte-list (mod (/ n u309485009821345068724781056) u256)))
		(concat (unwrap-panic (element-at byte-list (mod (/ n u1208925819614629174706176) u256)))
		(concat (unwrap-panic (element-at byte-list (mod (/ n u4722366482869645213696) u256)))
		(concat (unwrap-panic (element-at byte-list (mod (/ n u18446744073709551616) u256)))
		(concat (unwrap-panic (element-at byte-list (mod (/ n u72057594037927936) u256)))
		(concat (unwrap-panic (element-at byte-list (mod (/ n u281474976710656) u256)))
		(concat (unwrap-panic (element-at byte-list (mod (/ n u1099511627776) u256)))
		(concat (unwrap-panic (element-at byte-list (mod (/ n u4294967296) u256)))
		(concat (unwrap-panic (element-at byte-list (mod (/ n u16777216) u256)))
		(concat (unwrap-panic (element-at byte-list (mod (/ n u65536) u256)))
		(concat (unwrap-panic (element-at byte-list (mod (/ n u256) u256)))
						(unwrap-panic (element-at byte-list (mod n u256)))
		)))))))))))))))
)
(define-read-only (uint32-to-buff-be (n uint))
	(concat (unwrap-panic (element-at byte-list (mod (/ n u16777216) u256)))
		(concat (unwrap-panic (element-at byte-list (mod (/ n u65536) u256)))
		(concat (unwrap-panic (element-at byte-list (mod (/ n u256) u256)))
						(unwrap-panic (element-at byte-list (mod n u256))
		))))
)
(define-private (string-ascii-to-buff-iter (c (string-ascii 1)) (a (buff 128)))
	(unwrap-panic (as-max-len? (concat a (string-ascii-to-byte c)) u128))
)
(define-read-only (string-ascii-to-buff (str (string-ascii 128)))
	(fold string-ascii-to-buff-iter str 0x)
)
(define-private (string-ascii-to-byte (c (string-ascii 1)))
	(unwrap-panic (element-at byte-list (unwrap-panic (index-of ascii-list c))))
)
(define-constant type-id-uint 0x01)
(define-constant type-id-true 0x03)
(define-constant type-id-false 0x04)
(define-constant type-id-buff 0x02)
(define-constant type-id-none 0x09)
(define-constant type-id-some 0x0a)
(define-constant type-id-tuple 0x0c)
(define-constant byte-list 0x000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f404142434445464748494a4b4c4d4e4f505152535455565758595a5b5c5d5e5f606162636465666768696a6b6c6d6e6f707172737475767778797a7b7c7d7e7f808182838485868788898a8b8c8d8e8f909192939495969798999a9b9c9d9e9fa0a1a2a3a4a5a6a7a8a9aaabacadaeafb0b1b2b3b4b5b6b7b8b9babbbcbdbebfc0c1c2c3c4c5c6c7c8c9cacbcccdcecfd0d1d2d3d4d5d6d7d8d9dadbdcdddedfe0e1e2e3e4e5e6e7e8e9eaebecedeeeff0f1f2f3f4f5f6f7f8f9fafbfcfdfeff)
(define-constant ascii-list "//////////////////////////////// !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////")
(set-contract-owner .executor-dao)