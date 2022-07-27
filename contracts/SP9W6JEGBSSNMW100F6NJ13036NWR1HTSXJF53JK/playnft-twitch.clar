(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token playnft-twitch uint)

;; Define Constants
(define-constant nft-not-owned-err (err u401)) ;; unauthorized
(define-constant nft-not-found-err (err u404)) ;; not found
(define-constant sender-equals-recipient-err (err u405)) ;; method not allowed
(define-constant err-invalid-caller (err u1))
(define-constant contract-owner 'SP9W6JEGBSSNMW100F6NJ13036NWR1HTSXJF53JK)


(define-private (nft-transfer-err (code uint))
  (if (is-eq u1 code)
    nft-not-owned-err
    (if (is-eq u2 code)
      sender-equals-recipient-err
      (if (is-eq u3 code)
        nft-not-found-err
        (err code)))))


;; Define Variables
(define-data-var last-token-id uint u1)
(define-data-var metadata-base (string-ascii 100) "https://api.playnft.io/tokenmeta?token_id=")
(define-data-var contract-uri (string-ascii 100) "https://api.playnft.io/tokenmeta?token_id=1")

;; Storage
(define-map token-meta-uri uint (string-ascii 256))

(define-private (is-valid-caller)
    (is-eq contract-owner tx-sender)
)

;; Mint token with Metadata URI and recipient. Only usable by contract owner.
(define-public (mint (nft-id (string-ascii 8)) (recipient principal))
    (let 
        (
            (token-id (var-get last-token-id))
        )
        (asserts! (is-valid-caller) err-invalid-caller)
        (asserts! (not (is-eq nft-id "")) (err u500))
        (asserts! (not (is-eq recipient tx-sender)) (err u500))
        
        (var-set last-token-id (+ token-id u1))
        (map-insert token-meta-uri token-id (concat (var-get metadata-base) nft-id))
        (try! (nft-mint? playnft-twitch token-id recipient))
        (ok token-id)
    )
)

;; SIP009: Get the last token ID
(define-read-only (get-last-token-id)
    (ok (var-get last-token-id))
)

;; SIP009: Get the token URI.
(define-read-only (get-token-uri (token-id uint)) 
    (ok (map-get? token-meta-uri token-id))
)

;; SIP009: Get the owner of the specified token ID
(define-read-only (get-owner (token-id uint)) 
    (ok (nft-get-owner? playnft-twitch token-id))
)

;; SIP009: Transfer token to a specified principal
(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (if (and
        (> token-id u0)
        (is-eq tx-sender sender)
        (not (is-eq recipient sender)))
       (match (nft-transfer? playnft-twitch token-id sender recipient)
        success (ok success)
        error (nft-transfer-err error))
      nft-not-owned-err))

;; Set base uri if needed
(define-public (set-token-uri (token-uri (string-ascii 100))) 
    (begin
        (asserts! (is-valid-caller) err-invalid-caller)
        (asserts! (not (is-eq token-uri "")) (err u500))
        (ok (var-set metadata-base token-uri))    
    )
)

(define-read-only (get-contract-uri)
  (ok (var-get contract-uri)))

;; Set base uri
(define-public (set-base-uri (new-base-uri (string-ascii 100)))
  (begin
    (asserts! (is-valid-caller) err-invalid-caller)
    (asserts! (not (is-eq new-base-uri "")) (err u500))
    (var-set metadata-base new-base-uri)
    (ok true)))

;; Set contract uri
(define-public (set-contract-uri (new-contract-uri (string-ascii 100)))
  (begin
    (asserts! (is-valid-caller) err-invalid-caller)
    (asserts! (not (is-eq new-contract-uri "")) (err u500))
    (var-set contract-uri new-contract-uri)
    (ok true))
)