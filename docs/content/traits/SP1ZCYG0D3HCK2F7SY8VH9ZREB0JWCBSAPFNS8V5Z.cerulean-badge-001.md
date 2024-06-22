---
title: "Trait cerulean-badge-001"
draft: true
---
```
;; title: Cerulean Marketplace Completion Badge NFT
;; version: 0.01 
;; summary: Badge Completion for completed gigs
;; description: Upon completion of GIG, an NFT is sent to Client & Creator.

;; DEFINE CONSTANTS ;;
;;;;;;;;;;;;;;;;;;;;;;

;; Define Errors ;;
(define-constant ERR_NOT_FOUND (err u404))
(define-constant ERR_NOT_CLIENT (err u406))
(define-constant ERR_TRANSFER_NOT_ALLOWED (err u407))
(define-constant ERR_INVALID_REQUEST (err u408))

;; Define Contract Owner ;;
(define-constant contract-owner tx-sender)

;; Define NFT ;;
;;;;;;;;;;;;;;;;

(define-non-fungible-token client-badge uint)
(define-non-fungible-token creator-badge uint)

;; DEFINE DATA VARIABLES ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Define last-client-token-id
(define-data-var last-client-token-id uint u0)

;; Define last-creator-token-id
(define-data-var last-creator-token-id uint u0)

;; DEFINE MAPS ;;
;;;;;;;;;;;;;;;;;

;; Keep track of creator URIs
(define-data-var creator-token-uri (string-ascii 256) "ipfs://image1/metadata.json")

;; Keep track of client URIs
(define-data-var client-token-uri (string-ascii 256) "ipfs://image2/metadata.json")

;; DEFINE READ-ONLY FUNCTIONS ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Get token URI for Creator
(define-read-only (get-creator-token-uri)
    (ok (var-get creator-token-uri))
)

;; Get token URI for Client
(define-read-only (get-client-token-uri)
    (ok (var-get client-token-uri))
)

;; Get last minted NFT for Client (SIP-09 TRAIT) ;;
(define-read-only (get-last-client-token-id)
    (ok (var-get last-client-token-id))
)

;; Get last minted NFT for Creator(SIP-09 TRAIT) ;;
(define-read-only (get-last-creator-token-id)
    (ok (var-get last-creator-token-id))
)

;; Get the owner of a client NFT (SIP-09 TRAIT)
(define-read-only (get-clientbadge-owner (token-id uint))
    (ok (nft-get-owner? client-badge token-id))
)

;; Get the owner of a creator NFT (SIP-09 TRAIT)
(define-read-only (get-creatorbadge-owner (token-id uint))
    (ok (nft-get-owner? creator-badge token-id))
)

;; DEFINE PUBLIC FUNCTIONS ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-public (mint-nft (gig-id uint) (client principal) (client-uri (string-ascii 256)) (creator principal) (creator-uri (string-ascii 256)))
    (if (is-eq client contract-caller)
        (begin
            ;; Managing token ID for the client
            (let ((client-token-id (+ (var-get last-client-token-id) u1)))
                (var-set last-client-token-id client-token-id)

            ;; Managing client-token-uri 
            (var-set client-token-uri client-uri)

            ;; NFT minting function for the client
            (try! (nft-mint? client-badge client-token-id contract-caller))

            ;; Managing token ID for the creator
            (let ((creator-token-id (+ (var-get last-creator-token-id) u1)))
                (var-set last-creator-token-id creator-token-id)

            ;; Managing creator-token-uri 
            (var-set creator-token-uri creator-uri)

            ;; NFT minting function for the creator
            (try! (nft-mint? creator-badge creator-token-id creator))

                (print "NFTs minted successfully for both client and creator.")
                (ok (tuple (client-token-id client-token-id) (creator-token-id creator-token-id) ))
               
            )
            )
        )
        (err u406) ;; Not approved to mint
    )
)

;; Define Transfer Function ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-public (transfer (id uint) (sender principal) (recipient principal)) 
    ;; no transfers possible
    (err u407) 
    )
```
