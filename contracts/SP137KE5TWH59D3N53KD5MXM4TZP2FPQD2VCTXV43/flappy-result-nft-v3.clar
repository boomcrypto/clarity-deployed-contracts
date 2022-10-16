(define-constant ERR-UNAUTHORIZED (err u601))
(define-constant CONTRACT-OWNER tx-sender)

(define-non-fungible-token FLAPPY-RESULT-NFT {id: uint, score: uint})

(define-data-var json-uri (string-ascii 60) "https://board.stacksforce.xyz/flappy-result.json")
(define-data-var token-counter uint u0)
(define-data-var verify-key (buff 33) 0x023c84b45d4db536f39f4550720ac7658a1f4a1ab5cf2fb414d2eed5bc9d5fbb66)

(define-read-only (get-owner (token-id {id: uint, score: uint}))
	(ok (nft-get-owner? FLAPPY-RESULT-NFT token-id))
)

(define-read-only (get-token-uri (token-id {id: uint, score: uint}))
    (ok (var-get json-uri))
)

(define-public (set-key (new-key (buff 33)))
    (begin
        (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-UNAUTHORIZED)
        (var-set verify-key new-key)
        (ok true)
    )
)

(define-public (transfer (token-id {id: uint, score: uint}) (sender principal) (recipient principal))
    (begin
        (asserts! (is-eq tx-sender sender) ERR-UNAUTHORIZED)
        (nft-transfer? FLAPPY-RESULT-NFT token-id sender recipient)
    )
)

(define-public (mint (data (buff 64)) (ssig (buff 64)))
    (begin
        (let
            (
                (hash (sha256 data))
                (principalFromKey (unwrap-panic (principal-of? (extractBytes data))))
            )
            (asserts! (secp256k1-verify hash ssig (var-get verify-key)) ERR-UNAUTHORIZED)
            ;; bug - doesn't work in mainnet, to be fixed in 2.1
            ;;(asserts! (is-eq principalFromKey tx-sender) ERR-UNAUTHORIZED)
        )    
        
        (let 
            (
                (score (extractScore data))
                (token-id-new (+ (var-get token-counter) u1))
                (token-data {id: token-id-new, score: score})
            )    
            (try! (nft-mint? FLAPPY-RESULT-NFT token-data tx-sender))
	    	(var-set token-counter token-id-new)
		    (ok token-data)
        )
    )
)

(define-private (extractScore (data (buff 64)))
    (get val (fold buff-to-int data {val: u0, pos: u0}))
)

(define-private (extractBytes (data (buff 64)))
    (get val (fold sub-buff data {val: 0x, pos: u0}))
)

(define-private (sub-buff (buf (buff 1)) (data {val: (buff 33), pos: uint}))
    (let
        (
            (val (get val data))
            (pos (get pos data))
        )
        (if (or (< pos u8) (> pos u40)) {val: val, pos: (+ pos u1)}  {val: (unwrap-panic (as-max-len? (concat val buf) u33)), pos: (+ pos u1)})
    )
)

(define-private (buff-to-int (buf (buff 1)) (data {val: uint, pos: uint}))
    (let
        (
            (val (get val data))
            (pos (get pos data))
            (b (buff-to-byte buf))
        )
        (if (> pos u7) data  {val: (+ (* val u256) b), pos: (+ pos u1)})
    )
)

(define-private (buff-to-byte (byte (buff 1)))
  (unwrap-panic (index-of 0x000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f404142434445464748494a4b4c4d4e4f505152535455565758595a5b5c5d5e5f606162636465666768696a6b6c6d6e6f707172737475767778797a7b7c7d7e7f808182838485868788898a8b8c8d8e8f909192939495969798999a9b9c9d9e9fa0a1a2a3a4a5a6a7a8a9aaabacadaeafb0b1b2b3b4b5b6b7b8b9babbbcbdbebfc0c1c2c3c4c5c6c7c8c9cacbcccdcecfd0d1d2d3d4d5d6d7d8d9dadbdcdddedfe0e1e2e3e4e5e6e7e8e9eaebecedeeeff0f1f2f3f4f5f6f7f8f9fafbfcfdfeff byte))
)

