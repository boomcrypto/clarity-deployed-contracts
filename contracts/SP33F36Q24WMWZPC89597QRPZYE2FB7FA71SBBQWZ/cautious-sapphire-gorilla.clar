(define-trait nft-trait
  (
    (get-last-token-id () (response uint uint))

    (get-token-uri (uint) (response (optional (string-ascii 256)) uint))

    (get-owner (uint) (response (optional principal) uint))

    (transfer (uint principal principal) (response bool uint))))
  


(define-map hais {hai-id: uint}
  {name: (string-ascii 20), target-aip: (string-ascii 20), num-timeblocks: uint, date-of-birth: uint})
  
  
  


(define-read-only (get-meta-data (hai-id uint)) 
    (map-get? hais {hai-id: hai-id}))

(define-non-fungible-token nft-hais uint)




(define-data-var next-id uint u1)

(define-private (get-time) 
   (unwrap-panic (get-block-info? time (- block-height u1))))

(define-public (create-hai (name (string-ascii 20)) (target-aip (string-ascii 20)) (num-timeblocks uint)) 
  (let ((hai-id (var-get next-id))) 
    (if (is-ok (nft-mint? nft-hais hai-id tx-sender))
      (begin
        (var-set next-id (+ hai-id u1))
        (map-set hais {hai-id: hai-id} {name: name, target-aip: target-aip, num-timeblocks: num-timeblocks, date-of-birth: (get-time)})
      
        
        (ok hai-id))
      err-hai-exists)))

(define-public (transfer (hai-id uint) (sender principal) (recipient principal)) 
  (let ((owner (unwrap! (unwrap-panic (get-owner hai-id)) err-hai-unborn))) 
    (if (is-eq owner sender)
      (match (nft-transfer? nft-hais hai-id sender recipient)
        success (ok success)
        error (err-nft-transfer error))
      err-transfer-not-allowed)))

(define-read-only (get-last-token-id) 
  (ok (- (var-get next-id) u1)))


(define-read-only (get-token-uri (hai-id uint)) 
  (ok none))

(define-read-only (get-owner (hai-id uint)) 
  (match (nft-get-owner? nft-hais hai-id)
    owner (ok (some owner))
    (ok none)))
  
(define-constant err-transfer-not-allowed (err u401)) 
(define-constant err-hai-unborn (err u404)) 
(define-constant err-sender-equals-recipient (err u405)) 
(define-constant err-hai-exists (err u409)) 
(define-constant err-hai-died (err u501)) 


(define-map err-strings (response uint uint) (string-ascii 32))
(map-insert err-strings err-transfer-not-allowed "transfer-not-allowed")
(map-insert err-strings err-hai-unborn "hai-unborn")
(map-insert err-strings err-sender-equals-recipient "sender-equals-recipient")
(map-insert err-strings err-hai-exists "hai-exists")
(map-insert err-strings err-hai-died "hai-died")

(define-private (err-nft-transfer (code uint)) 
  (if (is-eq u1 code)
    err-transfer-not-allowed
    (if (is-eq u2 code)
      err-sender-equals-recipient
      (if (is-eq u3 code)
        err-hai-unborn
        (err code)))))

(define-private (err-nft-mint (code uint)) 
  (if (is-eq u1 code)
    err-hai-exists
    (err code)))

(define-read-only (get-errstr (code uint)) 
  (unwrap! (map-get? err-strings (err code)) "unknown-error"))