;; Bitbasel
  

  ;; (impl-trait .nft-trait.nft-trait)
  (impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
  

  ;; Non Fungible Token, using sip-009
  (define-non-fungible-token Bitbasel uint)
  

  ;; Constants
  (define-constant err-no-more-nfts u300)
  (define-constant err-invalid-user u500)
  

  ;; Internal variables
  (define-data-var mint-limit uint u5000)
  (define-data-var last-id uint u0)
  (define-map nft-meta-data uint (string-ascii 80))
  ;; private functions
  ;; Internal - Mint new NFT
  

  (define-private (mint-private (new-owner principal))  
    (let ((next-id (+ u1 (var-get last-id)))
          (count (var-get last-id)))  
        (asserts! (< count (var-get mint-limit)) (err err-no-more-nfts))
      (begin
        (mint-helper new-owner next-id))))
  

  (define-private (mint-helper (new-owner principal) (next-id uint))  
      (match (nft-mint? Bitbasel next-id new-owner) success
                (begin
                  (var-set last-id next-id)
                  (ok next-id))
              error (err error)))
  

  ;; public functions
  (define-public (mint (data (string-ascii 80)))  
    (match (mint-private tx-sender) success
      (begin 
        (map-set nft-meta-data success data)
        (ok data))
      error (err error)))
  

  (define-public (transfer (token-id uint) (sender principal) (recipient principal))  
    (if (and
          (is-eq tx-sender sender))
        (match (nft-transfer? Bitbasel token-id sender recipient)
          success (ok success)
          error (err error))
        (err err-invalid-user)))
  

  ;; read-only functions
  ;; SIP009: Get the owner of the specified token ID
  (define-read-only (get-owner (token-id uint))  
    (ok (nft-get-owner? Bitbasel token-id)))
  

  ;; SIP009: Get the last token ID
  (define-read-only (get-last-token-id)  
    (ok (var-get last-id)))
  

  (define-read-only (get-token-uri (token-id uint))  
    (begin (match (map-get? nft-meta-data token-id) entry 
            (ok (some entry))
            (ok none))))