(impl-trait .sip009-nft-trait.sip009-nft-trait)

;; SIP009 NFT trait on mainnet
;; (impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

;; nft
;;
(define-non-fungible-token momento-nft uint)

;; constants
;;
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-OWNER-ONLY (err u100))
(define-constant ERR-NOT-TOKEN-OWNER (err u101))

;; data maps and vars
;;
(define-data-var last-token-id uint u0)
(define-data-var token-uri (string-ascii 256) "")

;; private functions
;;

;; public functions
;;
(define-read-only (get-last-token-id) 
  (ok (var-get last-token-id))
)

(define-read-only (get-token-uri (token-id uint)) 
  (ok (some (var-get token-uri)))
)

(define-read-only (get-owner (token-id uint)) 
  (ok (nft-get-owner? momento-nft token-id))
)

(define-public (transfer (token-id uint) (sender principal) (recipient principal)) 
  (begin 
    (asserts! (is-eq tx-sender sender) ERR-NOT-TOKEN-OWNER)
    ;; the token-id is checked by nft-transfer, there is no need to check the recipient
    ;; #[filter(token-id, recipient)] 
    (nft-transfer? momento-nft token-id sender recipient)
  )
)

(define-public (mint (recipient principal) (new-token-uri (string-ascii 256)))
    (let
        (
            (token-id (+ (var-get last-token-id) u1))
        )
        (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-OWNER-ONLY)
        (try! (nft-mint? momento-nft token-id recipient))
        (var-set last-token-id token-id)
        (var-set token-uri new-token-uri)
        (ok token-id)
    )
)
