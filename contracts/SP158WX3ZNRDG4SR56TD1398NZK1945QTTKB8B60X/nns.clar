;;                       **          StacksNNS             **
;;                       **  STACKS NFT Naming Service NNS **
;; Any NFT holder on Stacks Blockchain can now register their NFT name for a Nominal Fee 

;;                 Deployed and Maintained by FreePunks.btc and StackNNS.com
;;          A big Thank You to Friedger.btc for all the support and setting the base

;; Naming Policy : Names cannot include any exploits, profane or obscene language, ethnic or racial slurs.
;;                 Names are unique across the stacks blockchain, names can be deleted or transfered.
;;                 Deleted names become available for registration upon deletion
;;
;; For Support and to Report violation of Naming policy please email: support@StacksNNS.com


(use-trait nft-trait 'SP158WX3ZNRDG4SR56TD1398NZK1945QTTKB8B60X.nft-trait.nft-trait)


(define-constant CONTRACT-OWNER tx-sender)
(define-data-var admins (list 1000 principal) (list 'SPH9R4KTPQS6AWXX9WG0KHC1K9393M83J7KP5NNG 'SP158WX3ZNRDG4SR56TD1398NZK1945QTTKB8B60X 'SPEK28QPHDX8X1WH54T60JADW6G0MD9SP8J0EZ8G))
(define-data-var registration-fee uint u1000000)
(define-data-var transfer-fee uint u10000000)
(define-data-var topay principal 'SPH9R4KTPQS6AWXX9WG0KHC1K9393M83J7KP5NNG)

(define-map names {nft: principal, id: uint} (string-utf8 256))
(define-map lookup {nft: principal, name: (string-utf8 256)} uint)
(define-map namecheck {name: (string-utf8 256)} (string-utf8 256))
(define-map map-whois {name: (string-utf8 256)} {nft: principal, id: uint} )


  

;;Register name

(define-public (register-nft-name (nft <nft-trait>) (id uint) (name (string-utf8 256)))
  (let ((owner (unwrap! (unwrap! (contract-call? nft get-owner id) err-not-found) err-not-found)))
    (asserts! (is-eq tx-sender owner) err-not-authorized)
    ;; check duplicate name
    (asserts! (is-none (map-get? namecheck { name: name})) err-name-owned)
    ;;Check if NFT already has name )
    (asserts! (is-none (map-get? names {nft: (contract-of nft), id: id})) err-already-named)
     
    (try! (stx-transfer? (var-get registration-fee ) tx-sender (var-get topay)))
    ;; register name
    (map-set namecheck {name: name} name)
    (map-set names {nft: (contract-of nft), id: id} name)
    (map-set lookup {nft: (contract-of nft), name: name} id)
    (map-set map-whois {name: name} {nft: (contract-of nft), id: id})
    
    (ok true)
  )
)

;;Delete Name    

(define-public (delete-nft-name (nft <nft-trait>) (id uint) (name (string-utf8 256)))
  (let ((owner (unwrap! (unwrap! (contract-call? nft get-owner id) err-not-found) err-not-found)))    (asserts! (is-eq tx-sender owner) err-not-authorized)
    (asserts! (is-eq tx-sender owner) err-not-authorized)
    ;;does name exist
    (asserts! (is-some (map-get? namecheck { name: name})) err-nothing-to-delete)
    ;;is the name attached to this NFT
    (asserts! (is-some (map-get? names {nft: (contract-of nft), id: id})) err-not-yours-to-delete)
    
    (map-delete namecheck {name: name})
    (map-delete names {nft: (contract-of nft), id: id})
    (map-delete lookup {nft: (contract-of nft), name: name})
    (map-delete map-whois {name: name})
    
    (ok true)
  )
)



;;transfer

(define-public (transfer-nft-name (nft <nft-trait>) (id uint) (name (string-utf8 256)) (receiver principal) (nft2name <nft-trait>) (id2 uint))
  
  (let (
    (owner (unwrap! (unwrap! (contract-call? nft get-owner id) err-not-found) err-not-found))  
    (owner2 (unwrap! (unwrap! (contract-call? nft2name get-owner id2) err-not-found) err-not-found))  
  )
    (begin
    (asserts! (is-eq tx-sender owner) err-not-authorized)
    (asserts! (is-eq receiver owner2) err-receipent-not-authorized)
    
    (asserts! (is-some (map-get? namecheck { name: name})) err-nothing-to-transfer)
    ;;is the name attached to this NFT
    (asserts! (is-some (map-get? names {nft: (contract-of nft), id: id})) err-not-yours-to-transfer)
    ;;Check if NFT2name already has name )
    (asserts! (is-none (map-get? names {nft: (contract-of nft2name), id: id2})) err-recipient-already-named)
    
    (map-delete namecheck {name: name})
    (map-delete names {nft: (contract-of nft), id: id})
    (map-delete lookup {nft: (contract-of nft), name: name})
    (map-delete map-whois {name: name})
    

    (try! (stx-transfer? (var-get transfer-fee ) tx-sender (var-get topay)))
   
    (map-set namecheck {name: name} name)
    (map-set names {nft: (contract-of nft2name), id: id2} name)
    (map-set lookup {nft: (contract-of nft2name), name: name} id2)
    (map-set map-whois {name: name} {nft: (contract-of nft2name), id: id2})
    )
    (ok true)
  )
)


;;look-up    

(define-read-only (resolve-by-name (nft <nft-trait>) (name (string-utf8 256)))
  (map-get? lookup {nft: (contract-of nft), name: name}))

(define-read-only (resolve-by-id (nft <nft-trait>) (id uint))
  (map-get? names {nft: (contract-of nft), id: id}))


(define-read-only (whois (name (string-utf8 256)))
   (let
    (
     (a1 (get nft (map-get? map-whois { name: name} )))
     (a2 (get id (map-get? map-whois { name: name} ))) 
    )
     (print {ID: a2, NFT: a1,})
  )
)


;; Admin Functions are hopefully never used, these are fail-safe for The Unexpected;;)

;;Admin Registeration

(define-public (adminreg (nft <nft-trait>) (id uint) (name (string-utf8 256)))
  (begin (asserts! (is-some (index-of (var-get admins) tx-sender)) err-not-authorized)
    ;; check duplicate name
    (asserts! (is-none (map-get? namecheck { name: name})) err-name-owned)
    ;;Check if NFT already has name )
    (asserts! (is-none (map-get? names {nft: (contract-of nft), id: id})) err-already-named)
     
    
    ;; register name
    (map-set namecheck {name: name} name)
    (map-set names {nft: (contract-of nft), id: id} name)
    (map-set lookup {nft: (contract-of nft), name: name} id)
    (map-set map-whois {name: name} {nft: (contract-of nft), id: id})
    
    (ok true)
  )
)


;;Admin Delete to remove any abuse of naming s

(define-public (admindel (nft <nft-trait>) (id uint) (name (string-utf8 256)))
  (begin 
    (asserts! (is-some (index-of (var-get admins) tx-sender)) err-not-authorized)
     ;;Does name exist to delete
    (asserts! (is-some (map-get? namecheck { name: name})) err-nothing-to-delete)
    ;;is the name attached to this NFT
    (asserts! (is-some (map-get? names {nft: (contract-of nft), id: id})) err-not-yours-to-delete)
    
    (map-delete namecheck {name: name})
    (map-delete names {nft: (contract-of nft), id: id})
    (map-delete lookup {nft: (contract-of nft), name: name})
    (map-delete map-whois {name: name})
    
    (ok true)
  )
)


;;Admin Transfer to resolve any disputes

(define-public (admintransfer (nft <nft-trait>) (id uint) (name (string-utf8 256)) (receiver principal) (nft2name <nft-trait>) (id2 uint))
 (let 
   (
    (owner (unwrap! (unwrap! (contract-call? nft get-owner id) err-not-found) err-not-found))  
    (owner2 (unwrap! (unwrap! (contract-call? nft2name get-owner id2) err-not-found) err-not-found))  
   )
  
  (begin 
    (asserts! (is-some (index-of (var-get admins) tx-sender)) err-not-authorized)
    (asserts! (is-eq receiver owner2) err-receipent-not-authorized)
    ;;Does name exist to transfer
    (asserts! (is-some (map-get? namecheck { name: name})) err-nothing-to-transfer)
    ;;is the name attached to this NFT
    (asserts! (is-some (map-get? names {nft: (contract-of nft), id: id})) err-not-yours-to-transfer)
    ;;Check if NFT2name already has name )
    (asserts! (is-none (map-get? names {nft: (contract-of nft2name), id: id2})) err-recipient-already-named)
    
    (map-delete namecheck {name: name})
    (map-delete names {nft: (contract-of nft), id: id})
    (map-delete lookup {nft: (contract-of nft), name: name})
    (map-delete map-whois {name: name})
    
   
    (map-set namecheck {name: name} name)
    (map-set names {nft: (contract-of nft2name), id: id2} name)
    (map-set lookup {nft: (contract-of nft2name), name: name} id2)
    (map-set map-whois {name: name} {nft: (contract-of nft2name), id: id2})
    
    (ok true)
  )
 )
)

;;Internal Admin Functions 
(define-data-var current-removing-administrative (optional principal) none )
  
(define-private (is-administrative (address principal))
  (or
    (is-eq CONTRACT-OWNER address )
    (not (is-none (index-of (var-get admins) address)) )
  )
)


(define-read-only (is-admin (address principal))
  (begin
    (asserts! (is-administrative address) err-not-authorized)
    (ok u1)
  )
)


(define-private (filter-remove-from-administrative (address principal ))
  (
    not (is-eq (some address) (var-get current-removing-administrative))
  )
)

(define-public (remove-admin (address principal))
  (begin
    (asserts! (is-administrative tx-sender) err-not-authorized)
    (asserts! (var-set current-removing-administrative (some address) ) err-not-authorized )
    (asserts! (var-set admins (filter filter-remove-from-administrative (var-get admins) ) ) err-not-authorized )
    (ok true)
  )
)


(define-public (add-admin (address principal))
  (if (is-eq tx-sender CONTRACT-OWNER)
    (ok (var-set admins (unwrap-panic (as-max-len? (append (var-get admins) address) u1000))))
    (err err-not-authorized)
  )
)


(define-read-only (get-admin-list)
 (begin
    (asserts! (is-some (index-of (var-get admins) tx-sender)) (err err-not-authorized))
    (ok (var-get admins)) 
 )
)


(define-public (setregfee (newregfee uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) (err err-not-authorized))
    (ok (var-set registration-fee  newregfee))
  )
)

(define-read-only (get-regfee)
  (var-get registration-fee ))




(define-public (set-transfer-fee (newfee uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) (err err-not-authorized))
    (ok (var-set transfer-fee newfee))
  )
)

(define-read-only (get-fee)
  (var-get transfer-fee))


(define-public (payto (newpayee principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) (err err-not-authorized))
    (ok (var-set topay newpayee))
  )
)



(define-read-only (get-payee)
 (begin
    (asserts! (is-some (index-of (var-get admins) tx-sender)) (err err-not-authorized))
    (ok (var-get topay)) 
 )
)

(define-constant err-not-yours-to-delete (err u201))
(define-constant err-not-yours-to-transfer (err u221))
(define-constant err-already-named (err u202))
(define-constant err-recipient-already-named (err u222))
(define-constant err-name-owned (err u203))
(define-constant err-name-not-yours (err u205))
(define-constant err-nothing-to-delete (err u206))
(define-constant err-nothing-to-transfer (err u207))
(define-constant err-not-authorized (err u403))
(define-constant err-not-found (err u404))
(define-constant err-receipent-not-authorized (err u410))

