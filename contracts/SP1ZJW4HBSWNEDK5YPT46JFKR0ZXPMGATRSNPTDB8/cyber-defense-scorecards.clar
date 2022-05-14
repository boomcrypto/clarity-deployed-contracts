;; Cyber Defense Scorecards

;; constants
;;
(define-constant ERR-ALL-MINTED u101)
(define-constant ERR-NOT-AUTHORIZED u401)
(define-constant CONTRACT-OWNER tx-sender)


;; variables
;;
(define-data-var nft-counter uint u0)
(define-data-var token-uri (string-ascii 256) "")
(define-data-var token-nft-uri (string-ascii 256) "")

;; use the SIP009 interface (testnet)

;; TESTNET => (impl-trait 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.nft-trait.nft-trait)
(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

;; define a new NFT. Make sure to replace CYBER-DEFENSE-SCORECARDS
(define-non-fungible-token CYBER-DEFENSE-SCORECARDS uint)

;; Store the last issues token ID
(define-data-var last-id uint u0)

;; Claim a new NFT
(define-public (mint-nft)
  (let (
      (count (var-get last-id))
    )
    (asserts! (<= count u19) (err ERR-ALL-MINTED))
    (mint tx-sender)
  )
)

;; SIP009: Transfer token to a specified principal
(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (begin
     (asserts! (is-eq tx-sender sender) (err u403))
     ;; Make sure to replace CYBER-DEFENSE-SCORECARDS
     (nft-transfer? CYBER-DEFENSE-SCORECARDS token-id sender recipient)))

(define-public (transfer-memo (token-id uint) (sender principal) (recipient principal) (memo (buff 34)))
  (begin 
    (try! (transfer token-id sender recipient))
    (print memo)
    (ok true)))

;; SIP009: Get the owner of the specified token ID
(define-read-only (get-owner (token-id uint))
  ;; Make sure to replace CYBER-DEFENSE-SCORECARDS
  (ok (nft-get-owner? CYBER-DEFENSE-SCORECARDS token-id)))

;; SIP009: Get the last token ID
(define-read-only (get-last-token-id)
  (ok (var-get last-id)))

;; SIP009: Get the token URI. You can set it to any other URI
;; (define-read-only (get-token-uri (token-id uint))
;;   (ok (some "https://token.stacks.co/{id}.json")))

(define-read-only (get-token-uri (id uint))
  (if (not (is-eq id u0))
    (ok (some (var-get token-uri)))
    (ok (some (var-get token-nft-uri)))
  )
)


;; Internal - Mint new NFT
(define-private (mint (new-owner principal))
    (let ((next-id (+ u1 (var-get last-id))))
      (var-set last-id next-id)
      ;; Make sure to replace CYBER-DEFENSE-SCORECARDS
      (nft-mint? CYBER-DEFENSE-SCORECARDS next-id new-owner)))

(define-public (set-token-uri (value (string-ascii 256)))
  (if (is-eq tx-sender CONTRACT-OWNER)
    (ok (var-set token-uri value))
    (err ERR-NOT-AUTHORIZED)
  )
)

(define-public (set-token-nft-uri (value (string-ascii 256)))
  (if (is-eq tx-sender CONTRACT-OWNER)
    (ok (var-set token-nft-uri value))
    (err ERR-NOT-AUTHORIZED)
  )
)

