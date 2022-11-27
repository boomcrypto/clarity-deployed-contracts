;; use the SIP009 interface (testnet)
(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

;; define a new NFT
(define-non-fungible-token duck uint)

(define-constant err-already-registered (err u403))
(define-map registered principal bool)

;; check if user already registered
(define-read-only (is-registered (address principal))
  (ok (map-get? registered address)))

;; set a user as registered
(define-private (set-registered (address principal)) 
  (map-set registered address true))

;; Store the last issues token ID
(define-data-var last-id uint u0)

;; if user already registered throw an error
;; else set user as registered and mint 6 consecutive NFTs
(define-public (claim-registration-workshop) 
  (begin
    (asserts! (is-none (unwrap-panic (is-registered tx-sender))) err-already-registered)
    (set-registered tx-sender)
    (some (mint tx-sender))
    (some (mint tx-sender))
    (some (mint tx-sender))
    (some (mint tx-sender))
    (some (mint tx-sender))
    (ok (mint tx-sender))))

;; Claim a new NFT
(define-public (claim)
  (claim-registration-workshop))

;; SIP009: Transfer token to a specified principal
(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) (err u403))
    ;; Make sure to replace duck
    (nft-transfer? duck token-id sender recipient)))

(define-public (transfer-memo (token-id uint) (sender principal) (recipient principal) (memo (buff 34)))
  (begin 
    (try! (transfer token-id sender recipient))
    (print memo)
    (ok true)))

;; SIP009: Get the owner of the specified token ID
(define-read-only (get-owner (token-id uint))
  ;; Make sure to replace duck
  (ok (nft-get-owner? duck token-id)))

;; SIP009: Get the last token ID
(define-read-only (get-last-token-id)
  (ok (var-get last-id)))

;; SIP009: Get the token URI. You can set it to any other URI
(define-read-only (get-token-uri (token-id uint))
  (ok (some "ipfs://QmXJMB28PPfqN9yEhdi2ZvmKCAeDckiwSENZa7TwhSmknp/{id}.json")))

;; Internal - Mint new NFT
(define-private (mint (new-owner principal))
    (let ((next-id (+ u1 (var-get last-id))))
      (var-set last-id next-id)
      ;; Make sure to replace duck
      (nft-mint? duck next-id new-owner)))
