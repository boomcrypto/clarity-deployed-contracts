
;; discount
;; <add a description here>

;; constants
;;
(define-non-fungible-token deep-lake-birds-for-bitcoin uint)
(define-constant dao  'SP2Y4MPQC3ZTXE9Z3NJAP1B5XDYRQZH3ZTY9TZFZM)
(define-constant DAO_ONLY_ERROR (err u100))
(define-constant NOT_TOKEN_OWNER_ERROR (err u101))
;; data maps and vars
;;
(define-data-var last-token-id uint u0)

;; private functions
;;

;; public functions
;;
(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender (unwrap-panic (nft-get-owner? deep-lake-birds-for-bitcoin token-id))) NOT_TOKEN_OWNER_ERROR)
    (nft-transfer? deep-lake-birds-for-bitcoin token-id sender recipient)
  )
)

(define-public (mint (recipient principal))
  (let
    ((token-id (+ (var-get last-token-id) u1)))
    (asserts! (is-eq tx-sender dao) DAO_ONLY_ERROR)
    (try! (nft-mint? deep-lake-birds-for-bitcoin token-id recipient))
    (var-set last-token-id token-id)
    (ok token-id)
  )
)

(define-public (burn (id uint) (owner principal))
  (begin
    (asserts! (is-eq tx-sender dao) DAO_ONLY_ERROR)
    (try! (nft-burn? deep-lake-birds-for-bitcoin id owner))
    (ok id)
  )
)

;; read only functions
;;
(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? deep-lake-birds-for-bitcoin token-id))
)
