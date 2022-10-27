(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
(define-constant ERROR_NOT_TOKEN_OWNER (err u400))
(define-constant ERR-NO-MORE-NFTS u100)
(define-constant ERROR-NOT-ALLOWED u200)

(define-non-fungible-token shadowy-super-coder uint)
;; data maps and vars
;;
(define-map token-count principal uint)


(define-data-var base-uri (string-ascii 80) "https://arweave.net/shadowy-super-coder/images/{id}")
(define-data-var last-shadowy-super-coder uint u0)
(define-data-var deployer principal tx-sender)
(define-data-var pack-mint-price uint u4206900)
;; 4.2069
(define-data-var mint-limit uint u49)


(define-public (transfer (id uint) (sender principal) (recipient principal))
 (begin
        (asserts! (is-eq tx-sender sender) ERROR_NOT_TOKEN_OWNER)
        (nft-transfer? shadowy-super-coder id sender recipient)
  )
)

(define-public (increase-mint-limit (limit uint))
(begin 
    (asserts! (is-eq tx-sender (var-get deployer))  (err ERROR-NOT-ALLOWED))
    (var-set mint-limit limit)
    (ok true)
)   

)
;; SIP009: Get the owner of the specified token ID
(define-read-only (get-owner (id uint))
  (ok (nft-get-owner? shadowy-super-coder id)))

;; SIP009: Get the last token ID
(define-read-only (get-last-token-id)
  (ok (var-get last-shadowy-super-coder)))

;; SIP009: Get the token URI. You can set it to any other URI
(define-read-only (get-token-uri (id uint))
  (ok (some (var-get base-uri))))

(define-read-only (get-balance (account principal))
  (default-to u0
    (map-get? token-count account)))
;; private functions
;;

;; public functions
;;
(define-public (claim-five)
  (mint (list true true true true true)))

(define-private (mint (orders (list 5 bool)))
  (mint-many orders))

(define-private (mint-many (orders (list 5 bool )))
  (let
    (
      (last-nft-id  (var-get last-shadowy-super-coder))
      (enabled (asserts! (<= last-nft-id (var-get mint-limit)) (err ERR-NO-MORE-NFTS)))
      (id-reached (fold mint-many-iter orders last-nft-id))
      (price (* (var-get pack-mint-price) (- id-reached last-nft-id)))
      (current-balance (get-balance tx-sender))
    )
      (begin
        (var-set last-shadowy-super-coder id-reached)
        (map-set token-count tx-sender (+ current-balance (- id-reached last-nft-id)))
        (try! (stx-transfer? price tx-sender (var-get deployer)))
      )
    (ok id-reached)))

  (define-private (mint-many-iter (ignore bool) (next-id uint))
  (if (<= next-id (var-get mint-limit))
    (begin
      (unwrap! (nft-mint? shadowy-super-coder next-id tx-sender) next-id)
      (+ next-id u1)
    )
    next-id))