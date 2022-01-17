;; stackards-nft
;; NFT contract for stacks cards
;; https://cards.layerc.xyz


;; (impl-trait .nft-trait.nft-trait)

;; use the SIP090 interface (testnet)
;; mainnet
;; (impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

;; testnet
;; (impl-trait 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.nft-trait.nft-trait)
;; (impl-trait 'ST1HTBVD3JG9C05J7HBJTHGR0GGW7KXW28M5JS8QE.nft-trait.nft-trait)

;; (impl-trait 'ST1NXBK3K5YYMD6FD41MVNP3JS1GABZ8TRVX023PT.nft-trait.nft-trait)

;; contract name
(define-non-fungible-token stackards-nft uint)


;; Store the last issues token ID
(define-data-var last-id uint u0)
(define-data-var mint-price uint u3000000)

;; postman-wallet can transfer tokens

(define-data-var postman-wallet principal tx-sender) ;; deployer

;; (define-data-var admin-wallet principal 'ST19SAM5ASZ4MQ43NCGN1QQV1W4NR3QQDJ7BJP5BD)  ;; dc-3
(define-data-var admin-wallet principal 'SP3V11C6X2EBFN72RMS3B1NYQ1BX98F61GR6CFET9)  ;; max-1
;; (define-data-var admin-wallet principal 'ST1SJ3DTE5DN7X54YDH5D64R3BCB6A2AG2ZQ8YPD5)

;; this has to be the exact length of the string
;; (define-data-var meta-base-url (string-ascii 47) "https://cards.layerc.xyz/api/tokens/cards/v1/")
(define-data-var meta-url (string-ascii 49) "https://cards.layerc.xyz/api/tokens/cards/v1/{id}")

;; data maps and vars

;; map tokenId: seed
(define-map seeds uint (string-ascii 64))

;; initializers

;; public functions

;; ;; claim NFT and store seed parameter
;; (define-public (claim (seed (string-ascii 64)))
;;   (begin
;;     (match (mint tx-sender seed)
;;       success
;;         (begin
;;           (print "minted")
;;           (map-set seeds (var-get last-id) seed)
;;           (ok seed)
;;         )
;;       error (err error)
;;     )
;;   )
;; )


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
    (map-set seeds next-id seed)
    (print {minted: next-id})
    (ok next-id)))

;; (define-private (mint-with-seeds (details {address: principal, seed: (string-ascii 64)}))
;;   (begin
;;     (try! (mint (get address details)))
;;     (map-set seeds (var-get last-id) (get seed details)))

;; ;; claim many nfts
;; (define-public (claim-many (details (list 100 {address: principal, seed: (string-ascii 64)}))
;;   (map mint-with-seeds details)
;;   )

;; get seed for token id
(define-read-only (get-seed (token-id uint))
  (ok (map-get? seeds token-id)))


;; SIP009: Transfer token to a specified principal
;; the token-id has to be owned by the sender? validated inside nft-transfer
(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (if (or
        (is-eq tx-sender sender)
        (is-eq contract-caller sender)
        (is-eq contract-caller (var-get postman-wallet)))
        (match (nft-transfer? stackards-nft token-id sender recipient)
          success (ok success)
          error (err error))
        (err u500)))

;; SIP009: Get the owner of the specified token ID
(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? stackards-nft token-id)))

;; SIP009: Get the last token ID
(define-read-only (get-last-token-id)
  (ok (var-get last-id)))

;; SIP009: Get the token URI. You can set it to any other URI
;; (define-read-only (get-token-uri (token-id uint))
;;   (ok (some "https://stan.rik.ai/api/trees/1")))
;; (define-read-only (get-token-full-uri (token-id uint))
;;   (ok (some (concat (var-get meta-base-url) (uint-to-string token-id) ) ))
;; )

(define-read-only (get-token-uri (token-id uint))
  (ok (some (var-get meta-url) )))

;; (define-read-only (get-meta-base (token-id uint))
;;   (ok (some (var-get meta-base-url) )))


;; (define-read-only (echo-int (token-id uint))
;;   (ok token-id))

;; private functions

(define-read-only (get-caller)
  (begin
    (print contract-caller))
  )

(define-read-only (get-sender)
  (begin
    (print tx-sender)
  )
)

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

;; allow admin wallets to transfer token to the user picking up the card
;; TODO need an OR sent by owner
;; (define-public (admin-transfer (token-id uint) (sender principal) (recipient principal))
;;   (if (and
;;         (is-eq contract-caller (var-get postman-wallet)))
;;         (match (nft-transfer? stackards-nft token-id sender recipient)
;;           success (ok success)
;;           error (err error))
;;         (err u500)))
