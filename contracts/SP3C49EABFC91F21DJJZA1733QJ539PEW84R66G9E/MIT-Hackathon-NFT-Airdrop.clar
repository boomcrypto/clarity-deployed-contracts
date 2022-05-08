;; use the SIP009 interface (testnet)
;; trait deployed by deployer address from ./settings/Devnet.toml
(use-trait nft-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token MIT-Hackathon uint)
(define-constant ERROR1 u0)
(define-data-var last-id uint u0)
(define-data-var ipfs-link (string-ascii 256) "https://ipfs.io/ipfs/Qmc2KihxS5AGgM3uHz4sww9bwuFperp6JCZ1WkPwu6d6CS?filename=Screenshot%202022-05-07%20at%2001.44.14.png")

;; Claim a new NFT
(define-public (claim)
  (mint tx-sender))

(define-public (claim-transfer (recipient principal))
  (begin
    (try! (claim))
    (transfer (var-get last-id) tx-sender recipient)
  )
)

(define-public (airdrop (receipients (list 100 principal)))
  (ok (map claim-transfer receipients))
)

(define-public (set-ipfs-link (link (string-ascii 256)))
  (if (var-set ipfs-link link)
    (ok true)
    (err ERROR1))
)

;; SIP009: Transfer token to a specified principal
(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (begin
     (asserts! (is-eq tx-sender sender) (err u403))
     ;; Make sure to replace MY-OWN-NFT
     (nft-transfer?  MIT-Hackathon token-id sender recipient)))

(define-public (transfer-memo (token-id uint) (sender principal) (recipient principal) (memo (buff 34)))
  (begin 
    (try! (transfer token-id sender recipient))
    (print memo)
    (ok true)))

;; SIP009: Get the owner of the specified token ID
(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner?  MIT-Hackathon token-id)))

;; SIP009: Get the last token ID
(define-read-only (get-last-token-id)
  (ok (var-get last-id)))

;; SIP009: Get the token URI. You can set it to any other URI
(define-read-only (get-token-uri (token-id uint))
  (ok (some (var-get ipfs-link))))

;; Internal - Mint new NFT
(define-private (mint (new-owner principal))
    (let ((next-id (+ u1 (var-get last-id))))
      (var-set last-id next-id)
      (nft-mint? MIT-Hackathon next-id new-owner)))