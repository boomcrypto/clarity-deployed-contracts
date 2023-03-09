
(define-constant total-amount u1000)
(define-data-var last-id uint u0)
(define-map degen-name uint (string-ascii 30))
(define-constant err-bns-convert (err u200))
(define-constant err-bnsx-convert (err u201))
(define-constant err-bns-size (err u202))
(define-constant err-full-mint-reached (err u302))

(define-private (set-nft-name (id uint) (name (string-ascii 30)))
  (map-set degen-name id name))

;; Internal - Mint new NFT
(define-public (mint (new-owner principal))
  (begin 
    (let 
      ((next-id (+ u1 (var-get last-id)))
        (address-bnsx-name (contract-call? 'SP1JTCR202ECC6333N7ZXD7MK7E3ZTEEE1MJ73C60.bnsx-registry get-primary-name new-owner))) 
      (asserts! (<= next-id total-amount) err-full-mint-reached)
        (if (is-some address-bnsx-name)
          (let 
            ((complete-bns-name (unwrap! address-bnsx-name err-bns-convert))
              (bns-name (as-max-len? (get name complete-bns-name) u20))
              (bns-namespace (as-max-len? (get namespace complete-bns-name) u9)))
              (set-nft-name next-id "NeFite#23"))
          ;; does not have bns address
          (set-nft-name next-id "NeFite#23"))
      (ok (var-set last-id next-id)))))