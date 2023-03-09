(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token ne-fite uint)

;; define errors
(define-constant err-owner-only (err u100))
(define-constant err-no-rights (err u101))

(define-constant err-bns-convert (err u200))
(define-constant err-bnsx-convert (err u201))
(define-constant err-bns-size (err u202))

(define-constant err-mint-disabled (err u300))
(define-constant err-whitelist-only (err u301))
(define-constant err-full-mint-reached (err u302))

;; price 69 stx
(define-constant price u69000000)
(define-constant total-amount u1000)

;; define variables
;; Store the last issues token ID
(define-data-var last-id uint u0)
(define-data-var contract-owner principal tx-sender)
(define-data-var mint-enabled bool true)
(define-data-var uri-root (string-ascii 80) "https://asd")

;; define maps
;; for each id keep in the map the name of the bns his owner has ( if one is present )
(define-map degen-name uint (string-ascii 30))


(define-read-only (is-mint-enabled) 
  (var-get mint-enabled))

(define-public (set-mint-enabler (bool-value bool))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) err-owner-only)
    (ok (var-set mint-enabled bool-value))))

(define-private (can-mint-and-update-spots (address principal)) 
  (ok true))

;; convert to string-ascii version the buff[] of name and namecheap
(define-read-only (get-address-bns-name (bns {name: (buff 20), namespace: (buff 9)}))
  (unwrap-panic (contract-call? .conversions resolve-principal-to-ascii bns)))

;; SIP009: Transfer token to a specified principal
(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) err-no-rights)
    (let ((address-bns-name (contract-call? 'SP000000000000000000002Q6VF78.bns resolve-principal recipient)) 
      (address-bnsx-name (contract-call? 'SP1JTCR202ECC6333N7ZXD7MK7E3ZTEEE1MJ73C60.bnsx-registry get-primary-name recipient)))
      (if (not (is-err address-bns-name))  
        (let 
          ((complete-bns-name (unwrap! address-bns-name err-bns-convert))
            (bns-name (as-max-len? (get name complete-bns-name) u20))
            (bns-namespace (as-max-len? (get namespace complete-bns-name) u9)))
          (if (and (is-some bns-name)  (is-some bns-namespace)) 
            ;; bns address respects the criterias
            (set-nft-name token-id 
              (get-address-bns-name 
                {name: (unwrap-panic bns-name),
                namespace: (unwrap-panic bns-namespace)}))
            (set-nft-name token-id (concat "NeFite#" (contract-call? .conversions uint-to-string token-id)))))
        (if (is-some address-bnsx-name) 
          (let 
            ((complete-bns-name (unwrap! address-bnsx-name err-bnsx-convert))
              (bns-name (as-max-len? (get name complete-bns-name) u20))
              (bns-namespace (as-max-len? (get namespace complete-bns-name) u9)))
            (if (and (is-some bns-name)  (is-some bns-namespace)) 
              ;; bnsx address respects the criterias
              (set-nft-name token-id 
                (get-address-bns-name 
                  {name: (unwrap-panic bns-name),
                  namespace: (unwrap-panic bns-namespace)}))
              (set-nft-name token-id (concat "NeFite#" (contract-call? .conversions uint-to-string token-id)))))
          ;; does not have bns address
          (set-nft-name token-id (concat "NeFite#" (contract-call? .conversions uint-to-string token-id)))))
    (nft-transfer? ne-fite token-id sender recipient))))

(define-public (transfer-memo (token-id uint) (sender principal) (recipient principal) (memo (buff 34)))
  (begin 
    (try! (transfer token-id sender recipient))
    (print memo)
    (ok true)))

;; SIP009: Get the owner of the specified token ID
(define-read-only (get-owner (token-id uint))
  ;; Make sure to replace ne-fite
  (ok (nft-get-owner? ne-fite token-id)))

;; SIP009: Get the last token ID
(define-read-only (get-last-token-id)
  (ok (var-get last-id)))

;; SIP009: Get the token URI. You can set it to any other URI
(define-read-only (get-token-uri (token-id uint))
  (ok (some (concat (concat (var-get uri-root) "$TOKEN_ID") ".json"))))


;; Internal - Mint new NFT
(define-private (mint (new-owner principal))
  (begin 
    (asserts! (var-get mint-enabled) err-mint-disabled)
    (let 
      ((next-id (+ u1 (var-get last-id)))
        (address-bns-name (contract-call? 'SP000000000000000000002Q6VF78.bns resolve-principal new-owner))
        (address-bnsx-name (contract-call? 'SP1JTCR202ECC6333N7ZXD7MK7E3ZTEEE1MJ73C60.bnsx-registry get-primary-name new-owner))) 
      (asserts! (<= next-id total-amount) err-full-mint-reached)
      (if (not (is-err address-bns-name))  
        (let 
          ((complete-bns-name (unwrap! address-bns-name err-bns-convert))
            (bns-name (as-max-len? (get name complete-bns-name) u20))
            (bns-namespace (as-max-len? (get namespace complete-bns-name) u9)))
          (if (and (is-some bns-name)  (is-some bns-namespace)) 
            ;; bns address respects the criterias
            (set-nft-name next-id 
              (get-address-bns-name 
                {name: (unwrap-panic bns-name),
                namespace: (unwrap-panic bns-namespace)}))
            (set-nft-name next-id (concat "NeFite#" (contract-call? .conversions uint-to-string next-id)))))
        (if (is-some address-bnsx-name) 
          (let 
            ((complete-bns-name (unwrap! address-bnsx-name err-bns-convert))
              (bns-name (as-max-len? (get name complete-bns-name) u20))
              (bns-namespace (as-max-len? (get namespace complete-bns-name) u9)))
            (if (and (is-some bns-name)  (is-some bns-namespace)) 
              ;; bnsx address respects the criterias
              (set-nft-name next-id 
                (get-address-bns-name 
                  {name: (unwrap-panic bns-name),
                  namespace: (unwrap-panic bns-namespace)}))
              (set-nft-name next-id (concat "NeFite#" (contract-call? .conversions uint-to-string next-id)))))
          ;; does not have bns address
          (set-nft-name next-id (concat "NeFite#" (contract-call? .conversions uint-to-string next-id)))))
      (var-set last-id next-id)
      (nft-mint? ne-fite next-id new-owner))))

(define-read-only (get-nft-name (id uint)) 
  (map-get? degen-name id )) 


(define-read-only (get-contract-owner) 
  (var-get contract-owner))

(define-public (set-contract-owner (new-contract-owner principal)) 
  (begin 
    (asserts! (is-eq tx-sender (var-get contract-owner)) err-owner-only)
    (ok (var-set contract-owner new-contract-owner))))

(define-read-only (get-batch-nft-name (token-id-list (list 50 uint))) 
  (map get-nft-name token-id-list))

(define-private (set-nft-name (id uint) (name (string-ascii 30)))
  (map-set degen-name id name))

(define-public (claim) 
  (begin    
    ;; verify can mint
    (asserts! (is-eq (can-mint-and-update-spots tx-sender) (ok true)) err-whitelist-only)
    (if (not (is-eq tx-sender (var-get contract-owner))) 
      (try! (stx-transfer? price tx-sender (var-get contract-owner)))
      false)
    (ok (try! (mint tx-sender)))))

(define-public (claim-5) 
  (begin 
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (ok (try! (claim)))))

(define-public (claim-10) 
  (begin 
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (ok (try! (claim)))))

;; Burn a token
(define-public (burn-token (token-id uint))
	(begin     
		(asserts! (is-eq (some tx-sender) (nft-get-owner? ne-fite token-id)) err-no-rights)
		(nft-burn? ne-fite token-id tx-sender)))