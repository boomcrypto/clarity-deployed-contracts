(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token Staking-NFT uint)

(define-data-var last-token-id uint u0)


;; Store the staking contract as a variable, so it can be changed dynamically
(define-data-var staking-contract principal 'SP2J9NG5A4F2C0NP0NSSEKM27J2G7CKWXH6RCSQ3X.StakeForRock)

;; Error constants
(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_NOT_OWNER (err u101))
(define-constant ERR_NFT_NOT_FOUND (err u102))

;; SIP-009: Retrieve the last minted token ID.
(define-read-only (get-last-token-id)
  (ok (var-get last-token-id))
)

;; SIP-009: Retrieve the token URI (metadata).
(define-read-only (get-token-uri (token-id uint))
  (ok (some "https://example.com/nft/{id}")) ;; Example URI for metadata, adjust as needed
)

;; SIP-009: Get the owner of a given NFT.
(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? Staking-NFT token-id))
)

;; Public function to change the staking contract, only callable by the tx-sender


;; Mint a new NFT to a user, restricted to the staking contract
(define-public (mint (recipient principal))
  (begin
    ;; Ensure only the staking contract can mint NFTs
    (asserts! (is-eq tx-sender (var-get staking-contract)) ERR_UNAUTHORIZED)
    
    ;; Generate the new token ID
    (let ((token-id (+ (var-get last-token-id) u1)))
      ;; Set the new token ID
      (var-set last-token-id token-id)
      
      ;; Mint the NFT to the recipient
      (try! (nft-mint? Staking-NFT token-id recipient))
      (ok token-id)
    )
  )
)

;; Burn an NFT, restricted to the staking contract
(define-public (burn (token-id uint) (owner principal))
  (begin
    ;; Ensure only the staking contract can burn NFTs
    (asserts! (is-eq tx-sender (var-get staking-contract)) ERR_UNAUTHORIZED)

    ;; Check if the owner is correct
    (let ((current-owner (unwrap! (nft-get-owner? Staking-NFT token-id) ERR_NFT_NOT_FOUND)))
      (asserts! (is-eq current-owner owner) ERR_NOT_OWNER)
      
      ;; Burn the NFT
      (try! (nft-burn? Staking-NFT token-id owner))
      (ok token-id)
    )
  )
)

;; Transfer the NFT, restricted to the staking contract
(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (begin
    ;; Ensure only the staking contract can transfer NFTs
    (asserts! (is-eq tx-sender (var-get staking-contract)) ERR_UNAUTHORIZED)
    
    ;; Ensure the sender is the owner of the NFT
    (let ((current-owner (unwrap! (nft-get-owner? Staking-NFT token-id) ERR_NFT_NOT_FOUND)))
      (asserts! (is-eq current-owner sender) ERR_NOT_OWNER)

      ;; Transfer the NFT
      (nft-transfer? Staking-NFT token-id sender recipient)
    )
  )
)