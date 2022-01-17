(define-constant owner tx-sender)
(define-non-fungible-token quote uint)
(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
(define-data-var last-id uint u0)
;; Last token ID, limited to uint range
(define-read-only (get-last-token-id) 
 (ok (var-get last-id)))

(define-map metadata uint (string-utf8 2048))

;; URI for metadata associated with the token
(define-read-only (get-token-uri (id uint)) (ok none))

(define-read-only (get-owner (id uint)) 
  (ok (nft-get-owner? quote id)))
    ;; Owner of a given token identifier

(define-public (transfer (id uint) (sender principal) (recipient principal))
  (nft-transfer? quote id sender recipient))

(define-public (add-quote (quote-text (string-utf8 2048)))
  (let (
        (last-token-id (var-get last-id))
        (new-id (+ last-token-id u1)))
    (map-insert metadata new-id quote-text)
    (var-set last-id new-id)
    (print quote-text)
    (nft-mint? quote new-id tx-sender)))

(define-read-only (get-quote-by-id (id uint))
    (ok (map-get? metadata id)))