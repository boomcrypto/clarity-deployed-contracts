;; use the SIP090 interface
;; (impl-trait .nft-trait.nft-trait)

(define-non-fungible-token FLUID uint)

;; Constants
(define-constant PREMINT-ADDRESS 'SP15YMC0DY40FF56T0RKWWSNDAWPX9W38K36EKGJ9)
(define-constant ERR-ALL-MINTED u101)
(define-constant CONTRACT-OWNER 'SP15YMC0DY40FF56T0RKWWSNDAWPX9W38K36EKGJ9)
(define-constant ERR-NOT-AUTHORIZED u401)
(define-constant MINT-LIMIT u1002)
(define-constant ERR-ALREADY-CLAIMED u501)
(define-constant DEPLOY-BLOCK-HEIGHT block-height)
(define-constant OK-CLAIMED u200)
(define-constant ERR-WHITELIST-LIMIT u403)
(define-constant INTERVAL-ONE u36)
(define-constant INTERVAL-TWO u144)
(define-constant ERR-ALL-PREMINTED u102)

;; Store the last issues token ID
(define-data-var last-id uint u0)
(define-data-var token-uri (string-ascii 256) "")
(define-map token-count principal uint)
(define-data-var cost-per-mint uint u2000000)

;; 6 hours - first-fifty has access to 1 FREE Punk Donut, Mint PD's and claim their SI Vial
(define-map first-fifty {address: principal} {claimedPD: bool})
;; next 18 hours - rest of the whitelist has access to 1 FREE Punk Donut, Mint PD's and claim their SI Vial
(define-map whitelist {address: principal} {claimedPD: bool})
;; anyone that mints 3 PDs can claim special-ingredient once
(define-map whitelist-si {address: principal} {canClaim: bool, claimedSI: bool})

;; Token count for account
(define-read-only (get-balance (account principal))
  (default-to u0
    (map-get? token-count account)))

(define-public (mint-free)
    (let (
        (next-id (+ u1 (var-get last-id)))  
        (count (var-get last-id))
        (whitelist-one-claimable (and (not (default-to true (get claimedPD (map-get? first-fifty {address: tx-sender})))) (< block-height (+ DEPLOY-BLOCK-HEIGHT INTERVAL-TWO))))
        (whitelist-two-claimable (and (not (default-to true (get claimedPD (map-get? whitelist {address: tx-sender})))) (and (< block-height (+ DEPLOY-BLOCK-HEIGHT INTERVAL-TWO)) (> block-height (+ DEPLOY-BLOCK-HEIGHT INTERVAL-ONE)))))
        )
      (asserts! (< count MINT-LIMIT) (err ERR-ALL-MINTED))
      (asserts! (or whitelist-one-claimable whitelist-two-claimable) (err ERR-NOT-AUTHORIZED))
      (try! (nft-mint? FLUID next-id tx-sender))
      (var-set last-id next-id)
      (set-pd-claimed tx-sender)
      (ok next-id)
    )
)

(define-private (set-pd-claimed (address principal))
    (begin 
        (match
            (map-get? first-fifty {address: address})
            whitelist-one
            (map-set first-fifty {address: address}
            (merge whitelist-one { claimedPD: true })
            )
            false
        )
        (match
            (map-get? whitelist {address: address})
            whitelist-two
            (map-set whitelist {address: address}
            (merge whitelist-two { claimedPD: true })
            )
            false
        )
    )
)

(define-public (get-pd-claimable)
    (let (
        (whitelist-one-claimable (and (not (default-to true (get claimedPD (map-get? first-fifty {address: tx-sender})))) (< block-height (+ DEPLOY-BLOCK-HEIGHT INTERVAL-TWO))))
        (whitelist-two-claimable (and (not (default-to true (get claimedPD (map-get? whitelist {address: tx-sender})))) (and (< block-height (+ DEPLOY-BLOCK-HEIGHT INTERVAL-TWO)) (> block-height (+ DEPLOY-BLOCK-HEIGHT INTERVAL-ONE)))))
        )
        (ok (or whitelist-one-claimable whitelist-two-claimable))
    )
)

(define-private (set-si-claimable (address principal))
    (let (
        (claimedSI (default-to false (get claimedSI (map-get? whitelist-si {address: tx-sender}))))
        )
        (map-set whitelist-si { address: address } { canClaim: true, claimedSI: claimedSI })
    )
)

(define-public (set-si-claimed)
    (match
        (map-get? whitelist-si {address: tx-sender})
        whitelist-three
        (ok (map-set whitelist-si {address: tx-sender}
        (merge whitelist-three { claimedSI: true })
        ))
        (ok false)
    )
)

(define-read-only (get-si-claimable)
    (let (
        (si-claimable (default-to false (get canClaim (map-get? whitelist-si {address: tx-sender}))))
        (si-claimed (default-to true (get claimedSI (map-get? whitelist-si {address: tx-sender}))))
        )
        (ok (and si-claimable (not si-claimed)))
    )
)

(define-private (increment-token-count)
    (let (
        (current-balance (get-balance tx-sender))
        )
        (map-set token-count
            tx-sender
            (+ current-balance u1)
        )
    )
)

;; Claim a new NFT
(define-public (claim)
  (mint tx-sender))

(define-public (mint-three)
  (begin
    (try! (mint tx-sender))
    (try! (mint tx-sender))
    (try! (mint tx-sender))
    ;; (try! (set-si-claimable tx-sender))
    (set-si-claimable tx-sender)
    (ok true)
  )
)

;; SIP009: Transfer token to a specified principal
(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (if (and
        (is-eq tx-sender sender))
      (match (nft-transfer? FLUID token-id sender recipient)
        success (ok success)
        error (err error))
      (err u500)))

;; SIP009: Get the owner of the specified token ID
(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? FLUID token-id)))

;; SIP009: Get the last token ID
(define-read-only (get-last-token-id)
  (ok (var-get last-id)))

;; SIP009: Get the token URI. You can set it to any other URI
(define-read-only (get-token-uri (id uint))
  (ok (some (var-get token-uri)))
)

;; Internal - Mint new NFT
(define-private (mint (new-owner principal))
  (let (
        (next-id (+ u1 (var-get last-id)))  
        (count (var-get last-id))
        (whitelisted-one (and (is-some (map-get? first-fifty {address: tx-sender})) (< block-height (+ DEPLOY-BLOCK-HEIGHT INTERVAL-TWO))))
        (whitelisted-two (and (is-some (map-get? whitelist {address: tx-sender})) (and (< block-height (+ DEPLOY-BLOCK-HEIGHT INTERVAL-TWO)) (> block-height (+ DEPLOY-BLOCK-HEIGHT INTERVAL-ONE)))))
        (public-sale (> block-height (+ DEPLOY-BLOCK-HEIGHT INTERVAL-TWO)))
      )
      (asserts! (< count MINT-LIMIT) (err ERR-ALL-MINTED))
      (asserts! (or public-sale (and (or whitelisted-one whitelisted-two) (> u5 (get-balance new-owner)))) (err ERR-NOT-AUTHORIZED))
        (match (stx-transfer? (var-get cost-per-mint) tx-sender (as-contract tx-sender))
          success (begin
            (try! (nft-mint? FLUID next-id new-owner))
            (var-set last-id next-id)
            (increment-token-count)
            (ok next-id)
          ) 
          error (err error)
          )
          )
        )

;; Allows contract owner to change mint price
(define-public (set-cost-per-mint (value uint))
  (if (is-eq tx-sender PREMINT-ADDRESS)
    (ok (var-set cost-per-mint value))
    (err ERR-NOT-AUTHORIZED)
  )
)

(define-read-only (stx-balance)
  (stx-get-balance (as-contract tx-sender))
)

(define-read-only (stx-balance-of (address principal))
  (stx-get-balance address)
)

;; Transfers stx from contract to contract owner
(define-public (transfer-stx (address principal) (amount uint))
  (if (is-eq tx-sender PREMINT-ADDRESS)
    (as-contract (stx-transfer? amount (as-contract tx-sender) address))
    (err ERR-NOT-AUTHORIZED)
  )
)

;; Internal - premint
(define-private (pre-mint (new-owner principal))
  (let (
        (next-id (+ u1 (var-get last-id)))  
        (count (var-get last-id))
      )
      (asserts! (< count MINT-LIMIT) (err ERR-ALL-MINTED))
      (asserts! (is-eq tx-sender CONTRACT-OWNER) (err ERR-NOT-AUTHORIZED))
            (try! (nft-mint? FLUID next-id new-owner))
            (var-set last-id next-id)
            (increment-token-count)
            (ok next-id)
          )
        )

;; premint 10
;; (pre-mint PREMINT-ADDRESS)

;; initialize
(var-set token-uri "ipfs://QmdqLyp8QHqVLbum7H76YNbqXR1FNqeQAhEhW5DpGRtdCi")
