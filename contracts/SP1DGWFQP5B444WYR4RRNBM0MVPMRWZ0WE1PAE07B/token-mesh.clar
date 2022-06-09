(impl-trait .traits.sip-010-trait)

;; ================ Token Trait ================
(define-fungible-token bridge-token)
(define-data-var name (string-ascii 32) "")
(define-data-var symbol (string-ascii 32) "")
(define-data-var token-decimals uint u18)

(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
	(begin
		(asserts! (is-eq tx-sender sender) err-not-token-owner)
        (match (ft-transfer? bridge-token amount sender recipient)
            response (begin
                (print memo)
                (ok response)
            )
            error (err error)
        )
	)
)

(define-read-only (get-name)
	(ok (var-get name))
)

(define-read-only (get-symbol)
	(ok (var-get symbol))
)

(define-read-only (get-decimals)
	(ok (var-get token-decimals))
)

(define-read-only (get-balance (who principal))
	(ok (ft-get-balance bridge-token who))
)

(define-read-only (get-total-supply)
	(ok (ft-get-supply bridge-token))
)

(define-read-only (get-token-uri)
	(ok (some u"https://bridge.orbitchain.io"))
)

(define-private (mint (amount uint) (recipient principal))
     (ft-mint? bridge-token amount recipient)
)

(define-private (burn (amount uint) (spender principal))
    (ft-burn? bridge-token amount spender)
)

;; ================ Error code ================
(define-constant err-not-token-owner (err u100))
(define-constant err-required-not-met (err u101))
(define-constant err-already-confirmed (err u102))
(define-constant err-invalid-gov-id (err u103))
(define-constant err-invalid-token-address (err u104))
(define-constant err-invalid-signer (err u105))
(define-constant err-need-more-signature (err u106))
(define-constant err-invalid-chain (err u107))
(define-constant err-invalid-length (err u108))
(define-constant err-invalid-data-id (err u109))
(define-constant err-invalid-required (err u110))
(define-constant err-invalid-decimals (err u111))
(define-constant err-invalid-amount (err u112))

;; ============== Token storage ==============
(define-constant STACKS 0x535441434b53)

(define-data-var governance-id (buff 32) 0x0000000000000000000000000000000000000000000000000000000000000000)
(define-data-var origin-token (buff 20) 0x0000000000000000000000000000000000000000)
(define-data-var deposit-count uint u1)

(define-data-var data-count uint u0)
(define-map swap-data uint
    {
        hub-contract: (buff 20),
        from-chain: (buff 256),
        from-addr: (buff 20),
        to-addr: principal,
        token: (buff 20),
        gov-id: (buff 32),
        tx-hash: (buff 32),
        amount: uint,
        decimals: (buff 32),
        deposit-id: (buff 32)
   }
)

(define-map confirmed-hash (buff 32) bool)
(define-map hash-validators {hash: (buff 32), validator: principal} bool)

;; ============== Public ==============

(define-public (add-swap-data
	    (hub-contract (buff 20)) ;; verification contract in orbit chain ( evm contract address )
	    (from-chain (buff 256)) ;; hex buffer of ascii (ex, "STACKS" => "0x535441434b53")
	    (from-addr (buff 20)) ;; ethereum user address
	    (to-addr principal) ;; ** hex buffer that can be changed to a principal type ( not a public key ) **
	    (token (buff 20)) ;; token address at ethereum
	    (gov-id (buff 32)) ;; governance ID
	    (tx-hash (buff 32)) ;; deposit tx-hash at ethereum
	    (amount uint) ;; deposit amount at ethereum
	    (decimals (buff 32)) ;; token decimal at ethereum
	    (deposit-id (buff 32)) ;; deposit id at ethereum
    )
    (let
        (
            (swap-hash (make-swap-hash hub-contract from-chain from-addr token gov-id tx-hash decimals deposit-id))
            (decimals-uint (buff-to-uint decimals))
            (data-id (var-get data-count))
        )

        (asserts! (is-eq (is-confirmed swap-hash) false) err-already-confirmed)
        (asserts! (is-eq gov-id (var-get governance-id)) err-invalid-gov-id)
        (asserts! (is-eq token (var-get origin-token)) err-invalid-token-address)
        (asserts! (is-eq (is-valid-chain from-chain) true) err-invalid-chain)
        (asserts! (is-eq decimals-uint (var-get token-decimals)) err-invalid-decimals)

        (map-set swap-data data-id {hub-contract: hub-contract, from-chain: from-chain, from-addr: from-addr, to-addr: to-addr, token: token, gov-id: gov-id, tx-hash: tx-hash, amount: amount, decimals: decimals, deposit-id: deposit-id})
        (print {type: "add-swap-data", data-id: data-id, hub-contract: hub-contract, from-chain: from-chain, to-addr: to-addr, token: token, gov-id: gov-id, tx-hash: tx-hash, amount: amount, decimals: decimals, deposit-id: deposit-id})

        (ok (var-set data-count (+ data-id u1)))
    )
)

(define-public (swap (data-id (buff 32)) (sigs (list 100 (buff 65))))
	(let
		(
			(req (get-required))
            (data-id-uint (buff-to-uint data-id))
            (hub-contract (get hub-contract (unwrap-panic (map-get? swap-data data-id-uint))))
            (from-chain (get from-chain (unwrap-panic (map-get? swap-data data-id-uint))))
            (from-addr (get from-addr (unwrap-panic (map-get? swap-data data-id-uint))))
            (to-addr (get to-addr (unwrap-panic (map-get? swap-data data-id-uint))))
            (token (get token (unwrap-panic (map-get? swap-data data-id-uint))))
            (gov-id (get gov-id (unwrap-panic (map-get? swap-data data-id-uint))))
            (tx-hash (get tx-hash (unwrap-panic (map-get? swap-data data-id-uint))))
            (amount (get amount (unwrap-panic (map-get? swap-data data-id-uint))))
            (decimals (get decimals (unwrap-panic (map-get? swap-data data-id-uint))))
            (deposit-id (get deposit-id (unwrap-panic (map-get? swap-data data-id-uint))))
			(swap-hash (make-swap-hash hub-contract from-chain from-addr token gov-id tx-hash decimals deposit-id))
            (sig-hash (make-signature-hash hub-contract from-chain from-addr token gov-id tx-hash decimals deposit-id data-id))
		)

        (asserts! (is-eq (len data-id) u32) err-invalid-length)
        (asserts! (is-eq (< data-id-uint (var-get data-count)) true) err-invalid-data-id)

        (asserts! (is-eq (is-confirmed swap-hash) false) err-already-confirmed)
        (asserts! (is-eq gov-id (var-get governance-id)) err-invalid-gov-id)
        (asserts! (is-eq token (var-get origin-token)) err-invalid-token-address)
        (asserts! (is-eq (is-valid-chain from-chain) true) err-invalid-chain)

        (asserts! (is-eq (> req u0) true) err-invalid-required)
		(asserts! (>= (len sigs) req) err-need-more-signature)

        (asserts! (<= (get cnt (fold validate-sig-fold sigs {hash: sig-hash, cnt: u0})) req) err-required-not-met)
        (map-set confirmed-hash swap-hash true)
        (map-set confirmed-hash sig-hash true)

        (print {type: "swap", data-id: data-id-uint, hub-contract: hub-contract, from-chain: from-chain, to-addr: to-addr, token: token, gov-id: gov-id, tx-hash: tx-hash, amount: amount, decimals: decimals, deposit-id: deposit-id})
        (mint amount to-addr)
	)
)

(define-public (request-swap (to-chain (buff 256)) (to-addr (buff 20)) (amount uint))
    (let
        (
            (deposit-id (var-get deposit-count))
            (decimal (var-get token-decimals))
        )
        (asserts! (is-eq (> amount u0) true) err-invalid-amount)
        (asserts! (is-eq (<= amount (unwrap-panic (get-balance contract-caller))) true) err-invalid-amount)
        (asserts! (is-eq (is-valid-chain to-chain) true) err-invalid-chain)

        ;; TODO: bridging fee + tax

        ;;emit SwapRequest(toChain, msg.sender, toAddr, token, tokenAddress, decimal, amount, depositCount, data)
        (print {type: "request-swap", to-chain: to-chain, from-addr: contract-caller, to-addr: to-addr, decimal: decimal, amount: amount, deposit-id: deposit-id})
        (var-set deposit-count (+ deposit-id u1))
        (burn amount contract-caller)
    )
)

(define-private (validate-sig-fold (signature (buff 65)) (info (tuple (hash (buff 32)) (cnt uint))))
	(let
		(
			(next_cnt (validate-sig (get hash info) signature (get cnt info)))
		)
		{hash: (get hash info), cnt: next_cnt}
	)
)

(define-private (validate-sig (hash (buff 32)) (signature (buff 65)) (cnt uint))
	(let
		(
			(validator (sig-recover hash signature))
		)
		(if
			(and
				(is-eq (is-validator validator) true)
				(is-eq (already-signed hash validator) false)
			)
			(begin
				(map-set hash-validators {hash: hash, validator: validator} true)
				(+ cnt u1)
			)
			cnt
		)
	)
)

;; ============== Read only ==============
(define-read-only (is-confirmed (hash (buff 32)))
    (unwrap! (map-get? confirmed-hash hash) false)
)

(define-read-only (is-valid-chain (chain (buff 256)))
    (contract-call? .gov-polygon is-valid-chain chain)
)

(define-read-only (is-validator (validator principal))
	(contract-call? .gov-polygon is-validator validator)
)

(define-read-only (get-required)
    (contract-call? .gov-polygon get-min-confirmation)
)

(define-read-only (make-swap-hash
        (hub-contract (buff 20))
        (from-chain (buff 256))
        (from-addr (buff 20))
        (token (buff 20))
        (gov-id (buff 32))
        (tx-hash (buff 32))
	    (decimals (buff 32))
	    (deposit-id (buff 32))
	)
    (sha256 (concat (concat (concat (concat (concat (concat (concat (concat hub-contract from-chain) STACKS) from-addr) token) gov-id) tx-hash) decimals) deposit-id))
)

(define-read-only (make-signature-hash
        (hub-contract (buff 20))
        (from-chain (buff 256))
        (from-addr (buff 20))
        (token (buff 20))
        (gov-id (buff 32))
        (tx-hash (buff 32))
	    (decimals (buff 32))
	    (deposit-id (buff 32))
        (data-id (buff 32))
	)
    (sha256 (concat (concat (concat (concat (concat (concat (concat (concat (concat hub-contract from-chain) STACKS) from-addr) token) gov-id) tx-hash) decimals) deposit-id) data-id))
)

(define-read-only (already-signed (hash (buff 32)) (validator principal))
	(unwrap! (map-get? hash-validators {hash: hash, validator: validator}) false)
)

(define-read-only (sig-recover (hash (buff 32)) (signature (buff 65)))
	(unwrap-panic (principal-of? (unwrap-panic (secp256k1-recover? hash signature))))
)

(define-read-only (get-swap-data (data-id uint))
    (let
		(
            (hub-contract (get hub-contract (unwrap-panic (map-get? swap-data data-id))))
            (from-chain (get from-chain (unwrap-panic (map-get? swap-data data-id))))
            (from-addr (get from-addr (unwrap-panic (map-get? swap-data data-id))))
            (to-addr (get to-addr (unwrap-panic (map-get? swap-data data-id))))
            (token (get token (unwrap-panic (map-get? swap-data data-id))))
            (gov-id (get gov-id (unwrap-panic (map-get? swap-data data-id))))
            (tx-hash (get tx-hash (unwrap-panic (map-get? swap-data data-id))))
            (amount (get amount (unwrap-panic (map-get? swap-data data-id))))
            (decimals (get decimals (unwrap-panic (map-get? swap-data data-id))))
            (deposit-id (get deposit-id (unwrap-panic (map-get? swap-data data-id))))
		)
        {hub-contract: hub-contract, from-chain: from-chain, from-addr: from-addr, to-addr: to-addr, token: token, gov-id: gov-id, tx-hash: tx-hash, amount: amount, decimals: decimals, deposit-id: deposit-id}
    )
)
;; ============== Utils ==============
(define-private (buff-to-uint (bytes (buff 32)))
    (let
        (
            (reverse-bytes (reverse-buff bytes))
        )
        (+
            (match (element-at reverse-bytes u0) byte (byte-to-uint byte) u0)
            (match (element-at reverse-bytes u1) byte (* (byte-to-uint byte) u256) u0)
            (match (element-at reverse-bytes u2) byte (* (byte-to-uint byte) u65536) u0)
            (match (element-at reverse-bytes u3) byte (* (byte-to-uint byte) u16777216) u0)
            (match (element-at reverse-bytes u4) byte (* (byte-to-uint byte) u4294967296) u0)
            (match (element-at reverse-bytes u5) byte (* (byte-to-uint byte) u1099511627776) u0)
            (match (element-at reverse-bytes u6) byte (* (byte-to-uint byte) u281474976710656) u0)
            (match (element-at reverse-bytes u7) byte (* (byte-to-uint byte) u72057594037927936) u0)
            (match (element-at reverse-bytes u8) byte (* (byte-to-uint byte) u18446744073709551616) u0)
            (match (element-at reverse-bytes u9) byte (* (byte-to-uint byte) u4722366482869645213696) u0)
            (match (element-at reverse-bytes u10) byte (* (byte-to-uint byte) u1208925819614629174706176) u0)
            (match (element-at reverse-bytes u11) byte (* (byte-to-uint byte) u309485009821345068724781056) u0)
            (match (element-at reverse-bytes u12) byte (* (byte-to-uint byte) u79228162514264337593543950336) u0)
            (match (element-at reverse-bytes u13) byte (* (byte-to-uint byte) u20282409603651670423947251286016) u0)
            (match (element-at reverse-bytes u14) byte (* (byte-to-uint byte) u5192296858534827628530496329220096) u0)
            (match (element-at reverse-bytes u15) byte (* (byte-to-uint byte) u1329227995784915872903807060280344576) u0)
        )
    )
)

(define-read-only (byte-to-uint (byte (buff 1)))
    (unwrap-panic (index-of BUFF-TO-BYTE byte))
)

(define-read-only (reverse-buff (a (buff 32)))
    (fold concat-buff a 0x)
)

(define-private (concat-buff (a (buff 32)) (b (buff 32)))
    (unwrap-panic (as-max-len? (concat a b) u32))
)

(define-constant BUFF-TO-BYTE (list
    0x00 0x01 0x02 0x03 0x04 0x05 0x06 0x07 0x08 0x09 0x0a 0x0b 0x0c 0x0d 0x0e 0x0f
    0x10 0x11 0x12 0x13 0x14 0x15 0x16 0x17 0x18 0x19 0x1a 0x1b 0x1c 0x1d 0x1e 0x1f
    0x20 0x21 0x22 0x23 0x24 0x25 0x26 0x27 0x28 0x29 0x2a 0x2b 0x2c 0x2d 0x2e 0x2f
    0x30 0x31 0x32 0x33 0x34 0x35 0x36 0x37 0x38 0x39 0x3a 0x3b 0x3c 0x3d 0x3e 0x3f
    0x40 0x41 0x42 0x43 0x44 0x45 0x46 0x47 0x48 0x49 0x4a 0x4b 0x4c 0x4d 0x4e 0x4f
    0x50 0x51 0x52 0x53 0x54 0x55 0x56 0x57 0x58 0x59 0x5a 0x5b 0x5c 0x5d 0x5e 0x5f
    0x60 0x61 0x62 0x63 0x64 0x65 0x66 0x67 0x68 0x69 0x6a 0x6b 0x6c 0x6d 0x6e 0x6f
    0x70 0x71 0x72 0x73 0x74 0x75 0x76 0x77 0x78 0x79 0x7a 0x7b 0x7c 0x7d 0x7e 0x7f
    0x80 0x81 0x82 0x83 0x84 0x85 0x86 0x87 0x88 0x89 0x8a 0x8b 0x8c 0x8d 0x8e 0x8f
    0x90 0x91 0x92 0x93 0x94 0x95 0x96 0x97 0x98 0x99 0x9a 0x9b 0x9c 0x9d 0x9e 0x9f
    0xa0 0xa1 0xa2 0xa3 0xa4 0xa5 0xa6 0xa7 0xa8 0xa9 0xaa 0xab 0xac 0xad 0xae 0xaf
    0xb0 0xb1 0xb2 0xb3 0xb4 0xb5 0xb6 0xb7 0xb8 0xb9 0xba 0xbb 0xbc 0xbd 0xbe 0xbf
    0xc0 0xc1 0xc2 0xc3 0xc4 0xc5 0xc6 0xc7 0xc8 0xc9 0xca 0xcb 0xcc 0xcd 0xce 0xcf
    0xd0 0xd1 0xd2 0xd3 0xd4 0xd5 0xd6 0xd7 0xd8 0xd9 0xda 0xdb 0xdc 0xdd 0xde 0xdf
    0xe0 0xe1 0xe2 0xe3 0xe4 0xe5 0xe6 0xe7 0xe8 0xe9 0xea 0xeb 0xec 0xed 0xee 0xef
    0xf0 0xf1 0xf2 0xf3 0xf4 0xf5 0xf6 0xf7 0xf8 0xf9 0xfa 0xfb 0xfc 0xfd 0xfe 0xff
))

;; ================ constructor ================
(var-set name "Orbit Bridge Stacks Meshswap")
(var-set symbol "oMESH.sandbox")
(var-set token-decimals u18)
(var-set governance-id 0x91464d7416306c2ed6114d456bf2f8c94e7d72721794962d7d2128b308ec2925)
(var-set origin-token 0x82362Ec182Db3Cf7829014Bc61E9BE8a2E82868a)
