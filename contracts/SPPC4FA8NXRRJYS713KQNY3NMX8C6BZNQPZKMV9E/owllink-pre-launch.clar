
;; owllink

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Non fungible token
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define-non-fungible-token owllink (string-ascii 256))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Constants
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Contract owner
(define-constant CONTRACT-OWNER tx-sender)
;; Errors
(define-constant ERR-NOT-OWNER (err u1403)) ;; Forbidden
(define-constant ERR-FAILED-TO-TRANSFER (err u1001)) ;; Stx transfer failed
(define-constant ERR-NOT-VALID-MINT-PRICE (err u1002)) ;; Mint price not valid
(define-constant ERR-NOT-SET-MINT-PRICE (err u1003)) ;; Mint price not set
(define-constant ERR-NOT-DNS-OWNER (err u1004)) ;; DNS owner forbidden
(define-constant ERR-NOT-SET-GAIA-URL (err u1005)) ;; Gaia url not set
(define-constant ERR-INVALID-GAIA-URL (err u1006)) ;; Gaia url is invalid

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; data maps and vars
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Store the last issues token ID
(define-data-var last-id uint u0)
;; Store the price of each mint
(define-data-var mint-price uint u1000000) ;; 20 (20 STX) * 10,00,000 (1 Micro STX) = 2,00,00,000 Micro STX
;; Store domain name space with gaia address
(define-map owllink-map (string-ascii 256) (string-ascii 256))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; private functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; public functions for all
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Mint new NFT Domain Name Space
(define-public (mint (name (string-ascii 256)) (namespace (buff 20)) (domain (buff 48)) (gaia-url (string-ascii 256)))
    (let 
        (
            (dns-owner (get owner (unwrap-panic (contract-call? 'SP000000000000000000002Q6VF78.bns name-resolve namespace domain))))
        )

        ;; Validation
        (asserts! (is-eq tx-sender contract-caller) ERR-NOT-OWNER)
        (asserts! (is-eq tx-sender dns-owner) ERR-NOT-DNS-OWNER)
        (asserts! (> (len gaia-url) u20) ERR-INVALID-GAIA-URL)

        ;; Transfer mint price
        (try! (stx-transfer? (var-get mint-price) tx-sender CONTRACT-OWNER))      

        ;; Mint name NFT 
        (match (nft-mint? owllink name tx-sender)
          success
            (begin
                (map-set owllink-map name gaia-url)
                (var-set last-id (+ u1 (var-get last-id)))              
                (ok name)
            )
          error (err error)
        )
    )
)

;; Get the owner of the specified token ID
(define-read-only (get-owner (name (string-ascii 256)))
  (ok (nft-get-owner? owllink name)))

;; Get the last token ID
(define-read-only (get-last-token-id)
  (ok (var-get last-id)))

;; Get the token URI. You can set it to any other URI
(define-read-only (get-token-uri (name (string-ascii 256)))
  (ok (some (unwrap-panic (map-get? owllink-map name)))))

;; Transfer token to a specified principal
(define-public (transfer (name (string-ascii 256)) (namespace (buff 20)) (domain (buff 48)) 
    (recipient principal))
    (let 
        (
            ;; Variables            
            (owllink-owner (unwrap-panic (nft-get-owner? owllink name)))
            (dns-owner (get owner (unwrap-panic (contract-call? 'SP000000000000000000002Q6VF78.bns name-resolve namespace domain))))
        )

        ;; Validation
        (asserts! (is-eq tx-sender contract-caller) ERR-NOT-OWNER)
        (asserts! (is-eq tx-sender owllink-owner) ERR-NOT-OWNER)
        (asserts! (is-eq recipient dns-owner) ERR-NOT-DNS-OWNER)

        ;; Business logic
        (match (nft-transfer? owllink name tx-sender recipient)
            success (begin
                (ok success)
            )
            error (err error)
        )
    )
)

;; Update owllink gaia URL
(define-public (update-owllink-profile-url (name (string-ascii 256)) (namespace (buff 20)) (domain (buff 48)) 
  (gaia-url (string-ascii 256)))
  (let
    (        
        (dns-owner (get owner (unwrap-panic (contract-call? 'SP000000000000000000002Q6VF78.bns name-resolve namespace domain))))
    )

    ;; Validation
    (asserts! (is-eq tx-sender contract-caller) ERR-NOT-OWNER)
    (asserts! (is-eq tx-sender dns-owner) ERR-NOT-DNS-OWNER)
    (asserts! (> (len gaia-url) u20) ERR-INVALID-GAIA-URL)

    ;; Business logic
    (match (stx-transfer? (var-get mint-price) tx-sender CONTRACT-OWNER)
      success 
        (begin
          ;; Update new gaia url
          (map-set owllink-map name gaia-url)
          (ok success)
        )
      error (err error)
    )
  )
)

;; Get current mint price
(define-read-only (get-mint-price)
    (ok (var-get mint-price))
)

;; Burn NFT
(define-public (burn (name (string-ascii 256)) (namespace (buff 20)) (domain (buff 48)))
    (let
        (
            (owllink-owner (unwrap-panic (nft-get-owner? owllink name)))
            (dns-owner (get owner (unwrap-panic (contract-call? 'SP000000000000000000002Q6VF78.bns name-resolve namespace domain))))
        )

        ;; Validation
        (asserts! (is-eq tx-sender contract-caller) ERR-NOT-OWNER)
        (asserts! (is-eq tx-sender owllink-owner) ERR-NOT-OWNER)
        (asserts! (is-eq tx-sender dns-owner) ERR-NOT-DNS-OWNER)

        ;; Business logic
        (match (nft-burn? owllink name tx-sender)
            success (ok success)
            error (err error)
        )
    )
)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Public functions for contract owner
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Update mint price
(define-public (update-mint-price (new-mint-price uint))
  (begin
    ;; Validation
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-OWNER)
    (asserts! (> new-mint-price u0) ERR-NOT-VALID-MINT-PRICE)

    ;; Business logic
    (if (var-set mint-price new-mint-price)
      (ok new-mint-price)
      ERR-NOT-SET-MINT-PRICE
    )
  )
)