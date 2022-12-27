
;; liquidium-early-access-ticket-v1
(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
(define-non-fungible-token Liquidium-Early-Access-Ticket uint)

;; constants
(define-constant DEPLOYER-ACCONT tx-sender)
(define-constant TICKET-LIMIT u100)

;; errors
(define-constant ERR-MAX-TICKETS-REACHED (err u1000))

(define-constant ERR-ON-MINT (err u2001))
(define-constant ERR-ON-BURN (err u2002))

(define-constant ERR-NOT-ALLOWED (err u9999))

;; vars
(define-data-var last-id uint u0)
(define-data-var token-uri (string-ascii 100) "ipfs://QmTjSpsevh4b8B7NMiWkfCEakCA8ktcLiB8bLfstDesa3o/{id}")
(define-data-var contract-uri (string-ascii 100) "ipfs://placeholder")

;; maps
(define-map Admin principal bool)

;; read only functions
(define-read-only (get-last-token-id) 
  (ok (var-get last-id))
)

(define-read-only (get-contract-uri)
  (ok (some (var-get contract-uri)))
)

(define-read-only (get-token-uri (id uint))
  (ok (some (var-get token-uri)))
)    

(define-read-only (get-owner (id uint))
  (ok (nft-get-owner? Liquidium-Early-Access-Ticket id))
)

;; public functions
(define-public (transfer (id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) ERR-NOT-ALLOWED)
    (asserts! (not (is-eq tx-sender recipient)) ERR-NOT-ALLOWED)
    (asserts! (is-eq (unwrap! (nft-get-owner? Liquidium-Early-Access-Ticket id) ERR-NOT-ALLOWED) sender) ERR-NOT-ALLOWED)
    (nft-transfer? Liquidium-Early-Access-Ticket id sender recipient)
  )
)

(define-public (mint (recipient (optional principal))) 
  (let ((id (+ u1 (var-get last-id))) (send-to (match recipient x x tx-sender)))
    (asserts! (is-admin tx-sender) ERR-NOT-ALLOWED)
    (asserts! (<= id TICKET-LIMIT) ERR-MAX-TICKETS-REACHED)
    (var-set last-id id)
    (asserts! (is-ok (nft-mint? Liquidium-Early-Access-Ticket id send-to)) ERR-ON-MINT)
    (ok id)
  )
)

(define-public (burn (id uint))
  (begin
    (asserts! (is-admin tx-sender) ERR-NOT-ALLOWED)
    (asserts! (is-ok (nft-burn? Liquidium-Early-Access-Ticket id tx-sender)) ERR-ON-BURN)
    (ok id)
  )
)

;;; admin functions
(define-read-only (is-admin (account principal))
  (or 
    (default-to false (map-get? Admin account))
    (is-eq account DEPLOYER-ACCONT)
  )
)

(define-public (set-admin (account principal) (allowed bool))
  (begin
    (asserts! (is-admin tx-sender) ERR-NOT-ALLOWED)
    (ok (map-set Admin account allowed))
  )
)

(define-public (set-token-uri (new-token-uri (string-ascii 100)))
  (begin
    (asserts! (is-admin tx-sender) ERR-NOT-ALLOWED)
    (var-set token-uri new-token-uri)
    (ok new-token-uri)
  )
)

(define-public (set-contract-uri (new-contract-uri (string-ascii 100)))
  (begin
    (asserts! (is-admin tx-sender) ERR-NOT-ALLOWED)
    (var-set contract-uri new-contract-uri)
    (ok new-contract-uri)
  )
)
