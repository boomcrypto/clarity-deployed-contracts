(define-non-fungible-token millie uint)

;; Public functions
(define-constant nft-not-owned-err (err u401)) ;; unauthorized
(define-constant nft-not-found-err (err u404)) ;; not found
(define-constant sender-equals-recipient-err (err u405)) ;; method not allowed

(define-private (nft-transfer-err (code uint))
  (if (is-eq u1 code)
    nft-not-owned-err
    (if (is-eq u2 code)
      sender-equals-recipient-err
      (if (is-eq u3 code)
        nft-not-found-err
        (err code)))))

;; Transfers tokens to a specified principal.
(define-public (transfer (from principal) (to principal) (token-id uint)) 
    (begin
        (asserts! (is-eq (some tx-sender) (nft-get-owner? millie token-id)) nft-not-owned-err)
        (asserts! (is-eq tx-sender from) nft-not-owned-err)
        (asserts! (not (is-eq tx-sender to)) sender-equals-recipient-err)
        (nft-transfer?  millie token-id tx-sender to)))

;; Gets the owner of the specified token ID.
(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner?  millie token-id)))

;; Gets the owner of the specified token ID.
(define-read-only (get-last-token-id)
  (ok u1))

(define-read-only (get-token-uri (token-id uint))
  (ok (some "https://ipfs.io/ipfs/QmW6E4DLT3RWfpBPEa9tgnpFJNnuYEmr7N8NJRgZmkkBCp")))

;; Initialize the contract
(try! (nft-mint? millie  u1 tx-sender))