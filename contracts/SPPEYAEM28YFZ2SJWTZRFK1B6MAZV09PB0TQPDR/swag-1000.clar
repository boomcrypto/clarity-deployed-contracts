(impl-trait 'SPPEYAEM28YFZ2SJWTZRFK1B6MAZV09PB0TQPDR.nft-trait.nft-trait)
(define-non-fungible-token swag-1000 uint)

;; Limited to first 1000 users
(define-constant max-tokens u1000)

;; Error handling
(define-constant nft-max-reached (err u403)) ;; no more tokens availabale
(define-constant nft-not-owned-err (err u401)) ;; unauthorized
(define-constant nft-not-found-err (err u404)) ;; not found
(define-constant sender-equals-recipient-err (err u405)) ;; method not allowed
(define-constant nft-exists-err (err u409)) ;; conflict

(define-private (nft-transfer-err (code uint))
  (if (is-eq u1 code)
    nft-not-owned-err
    (if (is-eq u2 code)
      sender-equals-recipient-err
      (if (is-eq u3 code)
        nft-not-found-err
        (err code)))))

(define-private (nft-mint-err (code uint))
  (if (is-eq u1 code)
    nft-exists-err
    (err code)))

;; Storage
(define-map tokens-count principal uint)
(define-data-var last-id uint u0)

;; Transfers tokens to a specified principal.
(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (if (and
        (is-eq tx-sender sender))
      (match (nft-transfer? swag-1000 token-id sender recipient)
        success (ok success)
        error (nft-transfer-err error))
      nft-not-owned-err))

;; Claim a new swag-1000-nft token.
(define-public (claim-swag)
  (if 
    (and 
      (< (var-get last-id) max-tokens)
      (is-eq (balance-of tx-sender) u0))
        (ok (mint tx-sender))
        (err nft-max-reached)))

;; Gets the owner of the specified token ID.
(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? swag-1000 token-id)))

;; Gets the last token ID.
(define-read-only (get-last-token-id)
  (ok (var-get last-id)))

(define-read-only (get-token-uri (token-id uint))
  (ok (some "https://docs.stacks.co/")))

(define-read-only (get-meta (token-id uint))
  (ok (some {name: "Clarity Developer OG", uri: "https://bafybeif4p2ukltj5eofwriclz4ru3p7izitprrs7a2rjhtp6qat673wagu.ipfs.dweb.link/", mime-type: "video/webm"})))

(define-read-only (get-nft-meta)
  (ok (some {name: "Clarity Developer OG", uri: "https://bafybeif4p2ukltj5eofwriclz4ru3p7izitprrs7a2rjhtp6qat673wagu.ipfs.dweb.link/", mime-type: "video/webm"})))

;; Internal - Gets the amount of tokens owned by the specified address.
(define-private (balance-of (account principal))
  (default-to u0 (map-get? tokens-count account)))

;; Internal - Register token
(define-private (mint (new-owner principal))
    (let ((current-balance (balance-of new-owner)) (next-id (+ u1 (var-get last-id))))
      (match (nft-mint? swag-1000 next-id new-owner)
        success
          (begin
            (map-set tokens-count
              new-owner
              (+ u1 current-balance))
            (var-set last-id next-id)
            (ok success))
        error (nft-mint-err error))))