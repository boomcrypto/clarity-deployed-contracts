;; Interface definitions
;; test/mocknet
;; (impl-trait 'SP3QSAJQ4EA8WXEDSRRKMZZ29NH91VZ6C5X88FGZQ.nft-trait.nft-trait)
;; mainnet
;;impl-trait SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

;; Define a new NFT
(define-non-fungible-token doge-punks uint)

;; We can only create 25 doge-punks
(define-constant MAX-PUNKS u24)
(define-constant CONTRACT-OWNER tx-sender)

;; Custom Errors
(define-constant ERR-ALL-MINTED u101)
(define-constant ERR-NOT-AUTHORIZED u102)
(define-constant ERR-CONTRACT-PAUSED u103)

;; Constant used to help convert uint to string
(define-constant LIST_40 (list
  true true true true true true true true true true
  true true true true true true true true true true
  true true true true true true true true true true
  true true true true true true true true true true
))

;; Map - token-uris for each NFT
(define-map meta uint {uri: (string-ascii 2048)})

;; Store the last issued token ID
(define-data-var last-token-id uint u0)
;; Contract active status
(define-data-var contract-active bool false)
(define-data-var base-uri (string-ascii 256) "https://jch.sfo3.digitaloceanspaces.com/doge-punks")

;; Toggle the contract active status
;; No minting allowed when the contract is paused
(define-public (toggle)
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) (err ERR-NOT-AUTHORIZED))
    (var-set contract-active (not (var-get contract-active)))
    (ok true)))

;; Claim a new NFT
(define-public (claim)
  (begin
    (asserts! (var-get contract-active) (err ERR-CONTRACT-PAUSED))
    (asserts! (<= (var-get last-token-id) MAX-PUNKS) (err ERR-ALL-MINTED))
    (mint tx-sender)))

;; SIP009: Transfer token to a specified principal
(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (if (and
        (is-eq tx-sender sender))
      (match (nft-transfer? doge-punks token-id sender recipient)
        success (ok success)
        error (err error))
      (err u500)))

;; Contract owner can update the base-uri
(define-public (set-base-uri (new-uri (string-ascii 256)))
  (if (is-eq tx-sender CONTRACT-OWNER)
        (begin
          (var-set base-uri new-uri)
          (ok true)
        )
    (err ERR-NOT-AUTHORIZED)))

;; Contract owner can update the token uri
(define-public (set-token-uri (token-id uint) (new-uri (string-ascii 256)))
  (if (is-eq tx-sender CONTRACT-OWNER)
        (begin
          (map-set meta token-id { uri: new-uri})
          (ok true)
        )
    (err ERR-NOT-AUTHORIZED)))

;; SIP009: Get the owner of the specified token ID
(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? doge-punks token-id)))

;; SIP009: Get the last token ID
(define-read-only (get-last-token-id)
  (ok (var-get last-token-id)))

;; SIP009: Get the token URI
(define-read-only (get-token-uri (id uint))
  (begin
    (asserts! (<= id (var-get last-token-id)) (ok none))
    (ok (get uri (map-get? meta id)) )))

;; Get active status
(define-read-only (get-contract-active-status)
  (ok (var-get contract-active)))

;; Helper for token-uri string interpolation
(define-read-only (uint-to-string (value uint))
  (get return (fold uint-to-string-clojure LIST_40 {value: value, return: ""})))

;; Helper for token-uri string interpolation
(define-read-only (uint-to-string-clojure (i bool) (data {value: uint, return: (string-ascii 40)}))
  (if (> (get value data) u0)
        {
          value: (/ (get value data) u10),
          return: (unwrap-panic (as-max-len? (concat (unwrap-panic (element-at "0123456789" (mod (get value data) u10))) (get return data)) u40))
        }
      data))

;; Mint new NFT
(define-private (mint (new-owner principal))
    (let ((next-id (+ u1 (var-get last-token-id))))
      (match (nft-mint? doge-punks next-id new-owner)
        success
          (begin
            (var-set last-token-id next-id)
            (map-insert meta next-id { uri: (concat (concat (var-get base-uri) (concat "/punk" (uint-to-string next-id))) ".png")})
            (ok true))
        error (err error))))
