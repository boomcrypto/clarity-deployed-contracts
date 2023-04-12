(define-constant CANT_DO_THAT (err u600))
(define-constant NOT_AUTHORIZED (err u500))

(define-constant CONTRACT-OWNER tx-sender)

(define-non-fungible-token STEAL-ME uint)

(define-data-var json-uri (string-ascii 100) "https://forceprime.io/hackathon/nft2.json")
(define-data-var token-counter uint u0)

(define-data-var steal-count uint u0)
(define-data-var steal-cost uint u0)
(define-data-var last-block uint u0)
(define-data-var first-block uint u0)
(define-data-var winner principal CONTRACT-OWNER)
(define-data-var winner-blocks uint u0)
(define-data-var steal-block uint u0)

(define-map player2count
    principal
    uint
)

(define-read-only (get-owner (token-id uint))
	(ok (nft-get-owner? STEAL-ME token-id))
)

(define-read-only (get-token-uri (token-id uint))
    (ok (var-get json-uri))
)

(define-read-only (get-prize)
    (ok (stx-get-balance (as-contract tx-sender)))
)

(define-read-only (get-steal-attempts)
    (ok (var-get steal-count))
)

(define-read-only (get-blocks-left)
    (ok (- (var-get last-block) block-height))
)

(define-public (finalize)
    (let
        (
            (currentOwner (unwrap-panic (nft-get-owner? STEAL-ME u1)))
            (currentBalance (stx-get-balance (as-contract tx-sender)))
        )
        
        (asserts! (> block-height (var-get last-block)) CANT_DO_THAT)
        (asserts! (> currentBalance u0) CANT_DO_THAT)

        (update-blocks-for currentOwner)
        (update-current-winner currentOwner)
        (try! (as-contract (stx-transfer? currentBalance tx-sender (var-get winner))))
        (if (is-eq currentOwner (var-get winner)) true
            (try! (nft-transfer? STEAL-ME u1 currentOwner (var-get winner))))
        
        (ok true)
    )
)

(define-public (steal)
    (let 
        (
            (cost (var-get steal-cost))
            (currentOwner (unwrap-panic (nft-get-owner? STEAL-ME u1)))
            (stealRoll (roll-steal))
        )
        (asserts! (is-eq (var-get token-counter) u1) CANT_DO_THAT)
        (asserts! (>= (stx-get-balance tx-sender) cost) CANT_DO_THAT)
        (asserts! (<= block-height (var-get last-block)) CANT_DO_THAT)
        (asserts! (not (is-eq currentOwner tx-sender)) CANT_DO_THAT)

        (try! (stx-transfer? cost tx-sender (as-contract tx-sender)))
        (var-set steal-count (+ (var-get steal-count) u1))
        (if stealRoll (process-steal) false)
        (ok stealRoll)
    )
)

(define-private (process-steal)
    (let 
        (
            (currentOwner (unwrap-panic (nft-get-owner? STEAL-ME u1)))
        )
        (unwrap-panic (nft-transfer? STEAL-ME u1 currentOwner tx-sender))
        (update-blocks-for currentOwner)
        (update-current-winner currentOwner)
    )
)

(define-private (update-blocks-for (p principal))
    (let 
        (
            (lastBlock (var-get last-block))
            (maxBlock (if (> block-height lastBlock) lastBlock block-height))
            (blockDelta (- maxBlock (var-get steal-block)))
            (currentBlocks (default-to u0 (map-get? player2count p)))
            (newBlocks (+ blockDelta currentBlocks))
        )
        (map-set player2count p newBlocks)
        (var-set steal-block maxBlock)
    )
)

(define-private (update-current-winner (compareWith principal))
     (let 
        (
            (currentBlocks (default-to u0 (map-get? player2count compareWith)))
        )
        (if (> currentBlocks (var-get winner-blocks))
            (begin
                (var-set winner-blocks currentBlocks)
                (var-set winner compareWith)
            )
            false
        )
    )
)

(define-public (transfer (token-id uint) (sender principal) (recipient principal))
    (begin
        (asserts! (is-eq tx-sender sender) NOT_AUTHORIZED)
        (asserts! (> block-height (var-get last-block)) CANT_DO_THAT)
        (nft-transfer? STEAL-ME token-id sender recipient)
    )
)

(define-public (mint (initialBalance uint) (stealCost uint) (blockCount uint))
    (begin
        (asserts! (is-eq tx-sender CONTRACT-OWNER) CANT_DO_THAT)
        (asserts! (is-eq (var-get token-counter) u0) CANT_DO_THAT)
        (asserts! (>= (stx-get-balance tx-sender) initialBalance) CANT_DO_THAT)

        (var-set steal-cost stealCost)
        (var-set token-counter u1)
        (var-set last-block (+ block-height blockCount))
        (var-set first-block block-height)
        (var-set steal-block block-height)

        (try! (stx-transfer? initialBalance tx-sender (as-contract tx-sender)))
        (try! (nft-mint? STEAL-ME u1 tx-sender))

        (ok 1)
    )
)

(define-private (roll-steal)
    (let
        (
            (vrf (unwrap-panic (get-block-info? vrf-seed (- block-height u1))))
            (thenumber (+ (var-get steal-count) block-height))
            (mixedseed (concat vrf (byte-to-buff (mod thenumber u256))))
            (adr (get hash-bytes (unwrap-panic (principal-destruct? tx-sender))))
            (prndbuff (sha512/256 (concat mixedseed adr)))
            (s (mod (fold + (map buff-to-uint-be prndbuff) u0) u777))
            (v (pow (/ (+ (var-get steal-count) (- block-height (var-get first-block))) u17) u2))
            (vf (if (> v u750) u750 v))
        )
        (if (> s vf) true false)
    )
)

(define-private (byte-to-buff (byte uint))
    (unwrap-panic (element-at 0x000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f404142434445464748494a4b4c4d4e4f505152535455565758595a5b5c5d5e5f606162636465666768696a6b6c6d6e6f707172737475767778797a7b7c7d7e7f808182838485868788898a8b8c8d8e8f909192939495969798999a9b9c9d9e9fa0a1a2a3a4a5a6a7a8a9aaabacadaeafb0b1b2b3b4b5b6b7b8b9babbbcbdbebfc0c1c2c3c4c5c6c7c8c9cacbcccdcecfd0d1d2d3d4d5d6d7d8d9dadbdcdddedfe0e1e2e3e4e5e6e7e8e9eaebecedeeeff0f1f2f3f4f5f6f7f8f9fafbfcfdfeff byte))
)
