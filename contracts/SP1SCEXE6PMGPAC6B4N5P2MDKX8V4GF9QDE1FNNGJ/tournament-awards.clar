;;; TOURNAMENT AWARDS

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

;; Non Fungible Token, using sip-009
(define-non-fungible-token tournament-awards uint)

;; Constants
(define-constant err-no-more-nfts u300)
(define-constant err-invalid-user u500)
(define-constant err-mint-not-enabled (err u1004))
(define-constant address-master tx-sender)

;; Internal variables
(define-data-var last-id uint u0)
(define-data-var mint-limit uint u99)
(define-data-var ipfs-root (string-ascii 80) "ipfs://QmaoSqizZjqypxbd6bmZfoUZFYuBerSY5KGpBCVrMbLeX4/")


;; private functions
(define-private (mint (new-owner principal))
(let ((next-id (+ u1 (var-get last-id)))  
  (count (var-get last-id)))
  (asserts! (< count (var-get mint-limit)) (err err-no-more-nfts))
  (if (is-eq tx-sender address-master)
    (mint-helper new-owner next-id)
    (err err-invalid-user)
  ) 
)
)

(define-private (mint-helper (new-owner principal) (next-id uint))
(match (nft-mint? tournament-awards next-id new-owner)
  success
  (begin
    (var-set last-id next-id)
    (ok true)
  )
  error (err error)
)
)


;; public functions
(define-public (tournament-award (address principal))
(mint address)
)

(define-public (set-mint-limit (new-mint-limit uint))
(if (is-eq tx-sender address-master)
  (begin 
    (var-set mint-limit new-mint-limit)
    (ok true)
  )
  (err err-invalid-user)
)
)

(define-public (set-ipfs-root (new-ipfs-root (string-ascii 80)))
(if (is-eq tx-sender address-master)
  (begin 
    (var-set ipfs-root new-ipfs-root)
    (ok true)
  )
  (err err-invalid-user)
)
)

(define-public (transfer (token-id uint) (sender principal) (recipient principal))
(if (and
      (is-eq tx-sender sender)
    )
    (match (nft-transfer? tournament-awards token-id sender recipient)
      success (ok success)
      error (err error)
    )
    (err err-invalid-user)
)
)


;; read-only functions
(define-read-only (get-owner (token-id uint))
(ok (nft-get-owner? tournament-awards token-id)))

(define-read-only (get-last-token-id)
(ok (var-get last-id)))

(define-read-only (get-token-uri (token-id uint))
(ok (some (concat (concat (var-get ipfs-root) (unwrap-panic (contract-call? .conversion lookup token-id))) ".json"))))

(define-read-only (get-base-uri)
(ok (var-get ipfs-root)))

(define-read-only (get-mint-limit)
(ok (var-get mint-limit)))