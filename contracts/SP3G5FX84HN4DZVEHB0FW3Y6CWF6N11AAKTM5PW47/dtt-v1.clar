;; @contract dtt
;; @version 0

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
(impl-trait 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.trait-ownable.ownable-trait)

(define-constant digital-twin-version-prefix 0xc1)
(define-constant counter-max-value u4294967295)

(define-constant err-not-authorized (err u403))
(define-constant err-old-message (err u500))
(define-constant err-invalid-signature (err u501))
(define-constant err-invalid-pubkey (err u502))
(define-constant err-invalid-pubkey-length (err u503))
(define-constant err-counter-too-large (err u504))
(define-constant err-invalid-name (err u505))

(define-map valid-tokens (buff 33) bool)
(define-map counters (buff 33) uint)
(define-map nft-ids (buff 33) uint)
(define-map nft-pubkeys uint (buff 33))

(define-data-var last-id uint u0)
(define-data-var contract-owner principal tx-sender)
(define-data-var token-uri (optional (string-ascii 256)) (some "https://tag.ryder.id/tag.json"))

(define-non-fungible-token digital-twin-tag (buff 33))

;; Digital Twin fuctions

;; Transfers a token by submitting a valid signature.
(define-public (transfer-by-sig (token-pubkey (buff 33)) (counter uint) (namespace (buff 20)) (name (buff 48)) (signature (buff 65)))
	(let ((recipient (get owner (unwrap! (contract-call? 'SP000000000000000000002Q6VF78.bns name-resolve namespace name) err-invalid-name))))
		(asserts! (is-eq (len token-pubkey) u33) err-invalid-pubkey-length)
		(asserts! (> counter (get-latest-counter token-pubkey)) err-old-message)
		(asserts! (<= counter counter-max-value) err-counter-too-large)
		(asserts! (verify-signature token-pubkey counter namespace name signature) err-invalid-signature)
		(map-set counters token-pubkey counter)
		(match (nft-get-owner? digital-twin-tag token-pubkey)
			owner (nft-transfer? digital-twin-tag token-pubkey owner recipient)
			(let ((id (+ u1 (var-get last-id))))
				(asserts! (is-valid-token token-pubkey) err-invalid-pubkey)
				(map-insert nft-ids token-pubkey id)
				(map-insert nft-pubkeys id token-pubkey)
				(var-set last-id id)
				(nft-mint? digital-twin-tag token-pubkey recipient)
			)
		)
	)
)

;; Calculates a message hash as follows:
;; SHA256(VersionPrefix || ConsensusBuff(counter) || ConsensusBuff(recipient))
(define-read-only (message-hash (counter uint) (namespace (buff 20)) (name (buff 48)))
	(sha256 (concat digital-twin-version-prefix (concat (counter-to-bytes counter) (concat name (concat 0x2e namespace)))))
)

(define-read-only (verify-signature (token-pubkey (buff 33)) (counter uint) (namespace (buff 20)) (name (buff 48)) (signature (buff 65)))
	(secp256k1-verify (message-hash counter namespace name) signature token-pubkey)
)

(define-read-only (get-latest-counter (token-pubkey (buff 33)))
	(default-to u0 (map-get? counters token-pubkey))
)

(define-read-only (id-to-token-pubkey (id uint))
	(default-to 0x (map-get? nft-pubkeys id))
)

(define-read-only (token-pubkey-to-id (token-pubkey (buff 33)))
	(map-get? nft-ids token-pubkey)
)

(define-read-only (is-valid-token (token-pubkey (buff 33)))
	(default-to false (map-get? valid-tokens token-pubkey))
)

;; SIP009 functions

(define-read-only (get-last-token-id)
	(ok (var-get last-id))
)

(define-read-only (get-token-uri (id uint))
	(ok (var-get token-uri))
)

(define-read-only (get-owner (id uint))
	(ok (nft-get-owner? digital-twin-tag (id-to-token-pubkey id)))
)

(define-public  (transfer (id uint) (sender principal) (recipient principal))
	err-not-authorized
)



;; Administrative functions

(define-public (add-valid-token (token-pubkey (buff 33)))
	(begin
		;; #[filter(token-pubkey)]
		(try! (is-contract-owner))
		(ok (map-set valid-tokens token-pubkey true))
	)
)

(define-public (set-token-uri (new-uri (optional (string-ascii 256))))
	(begin
		;; #[filter(new-uri)]
		(try! (is-contract-owner))
		(ok (var-set token-uri new-uri))
	)
)

;; Ownable trait

(define-read-only (is-contract-owner)
	(ok (asserts! (is-eq (var-get contract-owner) tx-sender) err-not-authorized))
)

(define-read-only (get-contract-owner)
	(ok (var-get contract-owner))
)

(define-public (set-contract-owner (new-owner principal))
	(begin
		;; #[filter(new-owner)]
		(try! (is-contract-owner))
		(ok (var-set contract-owner new-owner))
	)
)

;; uint to buffer

(define-constant byte-list 0x000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f404142434445464748494a4b4c4d4e4f505152535455565758595a5b5c5d5e5f606162636465666768696a6b6c6d6e6f707172737475767778797a7b7c7d7e7f808182838485868788898a8b8c8d8e8f909192939495969798999a9b9c9d9e9fa0a1a2a3a4a5a6a7a8a9aaabacadaeafb0b1b2b3b4b5b6b7b8b9babbbcbdbebfc0c1c2c3c4c5c6c7c8c9cacbcccdcecfd0d1d2d3d4d5d6d7d8d9dadbdcdddedfe0e1e2e3e4e5e6e7e8e9eaebecedeeeff0f1f2f3f4f5f6f7f8f9fafbfcfdfeff)
(define-read-only (counter-to-bytes (counter uint))
	(concat
		(unwrap-panic (element-at byte-list (mod (/ counter u16777216) u256)))
	(concat
		(unwrap-panic (element-at byte-list (mod (/ counter u65536) u256)))
	(concat
		(unwrap-panic (element-at byte-list (mod (/ counter u256) u256)))
		(unwrap-panic (element-at byte-list (mod counter u256)))
	)))
)

(add-valid-token 0x039afa0e856508befc096ab5323cc893b115cf46741442be61bd65059655f6f74b)