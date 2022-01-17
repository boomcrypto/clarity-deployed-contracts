;; dcards-nft
;; NFT contract for stacks cards
;; https://cards.layerc.xyz


;; (impl-trait .nft-trait.nft-trait)

;; contract name
(define-non-fungible-token dcards-nft uint)

;; initializers

(define-data-var mint-price uint u3000000)
(define-data-var current-mint-price uint u3000000)

;; Store the last issues token ID
(define-data-var last-id uint u0)

;; postman-wallet can transfer tokens
(define-data-var postman-wallet principal tx-sender) ;; deployer

;; this has to be the exact length of the string
(define-data-var meta-url (string-ascii 49) "https://cards.layerc.xyz/api/tokens/cards/v1/{id}")

;; data maps and vars

;; map tokenId: seed
(define-map seeds uint (buff 128))

(define-map claimed uint bool)

;; map owner/operator/tokenId: approved
(define-map approvals {owner: principal, operator: principal, id: uint} bool)
(define-map approvals-all {owner: principal, operator: principal} bool)

;; public functions

;; Mint new NFT
(define-public (mint (new-owner principal) (seed (buff 128)))
  (begin
    (var-set current-mint-price (var-get mint-price))
    (mint-with-seeds {address: new-owner, seed: seed})))

;; multi-mint
(define-private (mint-with-seeds (details {address: principal, seed: (buff 128)}))
  (let ((next-id (+ u1 (var-get last-id)))
    (new-owner (get address details))
    (seed (get seed details)))
    ;; pay the mint price
    (try! (match (stx-transfer? (var-get current-mint-price) tx-sender (var-get postman-wallet) )
      success (ok success)
      error (err (* error u10))))
    ;; mint the NFT
    (try! (nft-mint? dcards-nft next-id new-owner))
    (var-set last-id next-id)
    (map-insert seeds next-id seed) ;; ensures that token-id is unique
    (print {minted: next-id})
    (ok next-id)))

(define-read-only (check-err (result (response uint uint)) (previous-result (response (list 500 uint) {ids: (list 500 uint), error: uint})))
  (match previous-result
    ids (match result
      id (ok (unwrap! (as-max-len? (append ids id) u500) (err {ids: (list), error: u999})))
      error (err {ids: ids, error: error}))
    error (err error)))

;; claim many nfts
(define-public (mint-many (details (list 500 {address: principal, seed: (buff 128)})))
  (let ((price (var-get mint-price))
      (length (len details)))
    (var-set current-mint-price (if (>= length u10) (if (>= length u50) (if (>= length u100)
      (* (/ price u5) u3)
      (* (/ price u3) u2))
      (* (/ price u6) u5))
      price))
    (fold check-err (map mint-with-seeds details) (ok (list)))))

;; get seed for token id
(define-read-only (get-seed (token-id uint))
  (map-get? seeds token-id))

;; SIP009: Transfer token to a specified principal
;; the token-id has to be owned by the sender? validated inside nft-transfer
(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (if (or
        (is-eq tx-sender sender)
        (is-approved-with-owner token-id contract-caller (unwrap! (nft-get-owner? dcards-nft token-id) (err u404)))
        (handle-postman-transfer token-id))
    ;; nft-transfer? fails if sender is not owner
    (nft-transfer? dcards-nft token-id sender recipient)
    (err u403)))

;; Transfer token to a specified principal with a memo
(define-public (transfer-memo (id uint) (sender principal) (recipient principal) (memo (buff 34)))
    (let ((result (transfer id sender recipient)))
      (print memo)
      result))

(define-read-only (can-transfer (token-id uint) (sender principal) (recipient principal))
  (or (is-eq tx-sender sender)
      (is-approved-with-owner token-id contract-caller (unwrap! (nft-get-owner? dcards-nft token-id) false))
      (and
        (is-eq contract-caller (var-get postman-wallet))
        (not (default-to false (map-get? claimed token-id))))))

;;
;; operable functions

;; check postman address and only allow transfer once
(define-private (handle-postman-transfer (token-id uint))
  (and (is-eq contract-caller (var-get postman-wallet))
    ;; map-insert returns false if entry exists
    (map-insert claimed token-id true)))

(define-private (is-approved-with-owner (token-id uint) (operator principal) (owner principal))
  (or
    (is-eq operator owner)
    (default-to
      (default-to
        false
        (map-get? approvals-all {owner: owner, operator: operator}))
          (map-get? approvals {owner: owner, operator: operator, id:  token-id}))))

(define-read-only (is-approved ( token-id uint) (operator principal))
  (let ((owner (unwrap! (nft-get-owner? dcards-nft  token-id) (err u404))))
    (ok (is-approved-with-owner token-id operator owner))))

(define-public (set-approved ( token-id uint) (operator principal) (approved bool))
	  (ok (map-set approvals {owner: contract-caller, operator: operator, id: token-id} approved)))

(define-public (set-approved-all (operator principal) (approved bool))
	  (ok (map-set approvals-all {owner: contract-caller, operator: operator} approved)))


;; SIP009: Get the owner of the specified token ID
(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? dcards-nft token-id)))

;; SIP009: Get the last token ID
(define-read-only (get-last-token-id)
  (ok (var-get last-id)))

(define-read-only (get-info (token-id uint))
  (ok {
    owner: (nft-get-owner? dcards-nft token-id),
    seed: (get-seed token-id),
    approved: (is-approved token-id contract-caller),
    claimed: (map-get? claimed token-id),
    last-id: (var-get last-id),
    mint-price: (var-get mint-price)
  }))


(define-read-only (get-token-uri (token-id uint))
  (ok (some (var-get meta-url) )))

(define-read-only (get-mint-price)
  (var-get mint-price))

(define-public (set-mint-price (price uint))
  (begin
    (asserts! (is-eq tx-sender (var-get postman-wallet)) (err u403))
    (ok (var-set mint-price price))))

;; check status on last mint
(define-read-only (mint-check)
  (print {evt: "mint-check", last: (var-get last-id), owner: tx-sender, amount: (var-get mint-price)})
)
