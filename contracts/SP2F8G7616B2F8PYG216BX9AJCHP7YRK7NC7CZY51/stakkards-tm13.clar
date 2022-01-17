;; stackards-nft
;; NFT contract for stacks cards
;; https://cards.layerc.xyz


;; (impl-trait .nft-trait.nft-trait)

;; contract name
(define-non-fungible-token stackards-nft uint)

;; initializers

;; Store the last issues token ID
(define-data-var last-id uint u0)
(define-data-var mint-price uint u3000000)

;; postman-wallet can transfer tokens
(define-data-var postman-wallet principal tx-sender) ;; deployer

;; this has to be the exact length of the string
(define-data-var meta-url (string-ascii 49) "https://cards.layerc.xyz/api/tokens/cards/v1/{id}")

;; data maps and vars

;; map tokenId: seed
(define-map seeds uint (string-ascii 64))
(define-map token-id-by-seed (string-ascii 64) uint)

(define-map claimed uint bool)

;; map owner/operator/tokenId: approved
(define-map approvals {owner: principal, operator: principal, id: uint} bool)

;; public functions

;; Mint new NFT
(define-public (mint (new-owner principal) (seed (string-ascii 64) ))
  (let ((next-id (+ u1 (var-get last-id))))
    ;; pay the mint price
    (try! (match (stx-transfer? (var-get mint-price) tx-sender (var-get postman-wallet) )
      success (ok success)
      error (err (* error u10))))
    ;; mint the NFT
    (try! (nft-mint? stackards-nft next-id new-owner))
    (var-set last-id next-id)
    (map-insert seeds next-id seed) ;; ensures that token-id is unique
    (map-insert token-id-by-seed seed next-id) ;; ensures that seed is only used once
    (print {minted: next-id})
    (ok next-id)))

;; (define-private (mint-with-seeds (details {address: principal, seed: (string-ascii 64)}))
;;   (begin
;;     (try! (mint (get address details)))
;;     (map-set seeds (var-get last-id) (get seed details))))

;; ;; claim many nfts
;; (define-public (claim-many (details (list 100 {address: principal, seed: (string-ascii 64)}))
;;   (map mint-with-seeds details)
;;   ))

;; get seed for token id
(define-read-only (get-seed (token-id uint))
  (map-get? seeds token-id))

;; SIP009: Transfer token to a specified principal
;; the token-id has to be owned by the sender? validated inside nft-transfer
(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (if (or
        (is-eq tx-sender sender)
        (is-approved-with-owner token-id contract-caller (unwrap! (nft-get-owner? stackards-nft token-id) (err u404)))
        (handle-postman-transfer token-id))
    ;; nft-transfer? fails if sender is not owner
    (nft-transfer? stackards-nft token-id sender recipient)
    (err u403)))

;; Transfer token to a specified principal with a memo
(define-public (transfer-memo (id uint) (sender principal) (recipient principal) (memo (buff 34)))
    (let ((result (transfer id sender recipient)))
      (print memo)
      result))

(define-public (transfer-by-seed (seed (string-ascii 64)) (sender principal) (recipient principal))
  (let ((token-id (unwrap! (map-get? token-id-by-seed seed) (err u404))))
    (transfer token-id sender recipient)))

(define-public (transfer-memo-by-seed (seed (string-ascii 64)) (sender principal) (recipient principal) (memo (buff 34)))
  (let ((token-id (unwrap! (map-get? token-id-by-seed seed) (err u404))))
    (transfer-memo token-id sender recipient memo)))

;;
;; operable functions
;;

;; check postman address and only allow transfer once
;;
(define-private (handle-postman-transfer (token-id uint))
  (and (is-eq contract-caller (var-get postman-wallet))
    ;; map-insert returns false if entry exists
    (map-insert claimed token-id true)))

(define-private (is-approved-with-owner (token-id uint) (operator principal) (owner principal))
  (or
    (is-eq operator owner)
    (default-to false (map-get? approvals {owner: owner, operator: operator, id:  token-id}))))

(define-read-only (is-approved ( token-id uint) (operator principal))
  (let ((owner (unwrap! (nft-get-owner? stackards-nft  token-id) (err u404))))
    (ok (is-approved-with-owner token-id operator owner))))

(define-public (set-approved ( token-id uint) (operator principal) (approved bool))
  (let ((owner (unwrap! (nft-get-owner? stackards-nft  token-id) (err u404))))
    (asserts! (is-eq owner contract-caller) (err u403))
	  (ok (map-set approvals {owner: contract-caller, operator: operator, id:  token-id} approved))))


;; SIP009: Get the owner of the specified token ID
(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? stackards-nft token-id)))

;; SIP009: Get the last token ID
(define-read-only (get-last-token-id)
  (ok (var-get last-id)))

(define-read-only (get-info (token-id uint))
  (ok {
    token-id: token-id,
    owner: (nft-get-owner? stackards-nft token-id),
    seed: (get-seed token-id),
    approved: (is-approved token-id contract-caller),
    claimed: (map-get? claimed token-id)
    }))


(define-read-only (get-token-uri (token-id uint))
  (ok (some (var-get meta-url) )))

(define-read-only (get-mint-price)
  (begin
    (print (var-get mint-price))
    (ok (var-get mint-price))
  )
)


;; check status on last mint
(define-read-only (mint-check)
  (print {evt: "mint-check", last: (var-get last-id), owner: tx-sender, amount: (var-get mint-price)})
)
