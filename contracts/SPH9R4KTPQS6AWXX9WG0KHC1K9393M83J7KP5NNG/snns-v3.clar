;;                       **          StacksNNS           **
;;                       **  STACKS NFT Naming Service NNS **
;; Any NFT holder on Stacks Blockchain can now register their NFT name for a Nominal Fee 

;;                 Deployed and Maintained by FreePunks.btc and StackNNS.com
;;          A big Thank You to Friedger.btc for all the support and setting the base

;; Naming Policy : Names cannot include any exploits, profane or obscene language, ethnic or racial slurs.
;;                 Names are unique across the stacks blockchain, names can be deleted or transfered.
;;                 Deleted names become available for registration upon deletion
;;
;; For Support and to Report violation of Naming policy please email: support@StacksNNS.com

(use-trait nft-trait 'SPH9R4KTPQS6AWXX9WG0KHC1K9393M83J7KP5NNG.nft-trait.nft-trait)


(define-constant CONTRACT-OWNER tx-sender)
(define-data-var admins (list 1000 principal) (list 'SPH9R4KTPQS6AWXX9WG0KHC1K9393M83J7KP5NNG 'SPEK28QPHDX8X1WH54T60JADW6G0MD9SP8J0EZ8G))
(define-data-var registration-fee uint u1000000)
(define-data-var transfer-fee uint u1000000)
(define-data-var topay principal 'SPH9R4KTPQS6AWXX9WG0KHC1K9393M83J7KP5NNG)
(define-data-var transferprincipal principal 'SPH9R4KTPQS6AWXX9WG0KHC1K9393M83J7KP5NNG)
(define-map names {nft: principal, id: uint} (string-ascii 256))
(define-map map-whois {name: (string-ascii 256)} {nft: principal, id: uint} )


;;Register name
(define-public (register-nft-name (nft <nft-trait>) (id uint) (name (string-ascii 100)))
  (let ((owner (unwrap! (unwrap! (contract-call? nft get-owner id) err-not-found) err-not-found)))
    (asserts! (is-eq tx-sender owner) err-not-authorized)
    (asserts! (is-upper name) err-invalid-chars)
    (asserts! (is-none (map-get? map-whois { name: name})) err-name-owned)
    (asserts! (is-none (map-get? names {nft: (contract-of nft), id: id})) err-already-named)
    (try! (stx-transfer? (var-get registration-fee ) tx-sender (var-get topay)))
    (begin
     (map-set names {nft: (contract-of nft), id: id} name)
     (map-set map-whois {name: name} {nft: (contract-of nft), id: id})
     (ok true)
    ) 
  )
)
  
(define-public (delete-nft-name (nft <nft-trait>) (id uint) (name (string-ascii 100)))
  (let ((owner (unwrap! (unwrap! (contract-call? nft get-owner id) err-not-found) err-not-found)))
   (begin 
    (asserts! (is-eq tx-sender owner) err-not-authorized)
    (del nft id name)  
   )
 )
)

;;transfer
(define-public (transfer-nft-name (nft <nft-trait>) (id uint) (name (string-ascii 100)) (nft2name <nft-trait>) (id2 uint))
  (let ((owner (unwrap! (unwrap! (contract-call? nft get-owner id) err-not-found) err-not-found)))
   (begin 
    (asserts! (is-eq tx-sender owner) err-not-authorized)
    (try! (stx-transfer? (var-get registration-fee ) tx-sender (var-get topay)))
    (trnsfer nft id name nft2name id2)
   )
  )
)

;;look-up    

(define-read-only (resolve-by-id (nft <nft-trait>) (id uint))
  (map-get? names {nft: (contract-of nft), id: id}))


(define-read-only (whois (name (string-ascii 100)))
   (map-get? map-whois {name: name})
)


;; Admin Functions are hopefully never used, these are fail-safe for The Unexpected;;)
;;Admin Delete to remove any abuse of naming policy

(define-public (admindel (nft <nft-trait>) (id uint) (name (string-ascii 100)))
  (begin 
   (asserts! (is-administrative tx-sender) err-not-authorized)
   (del nft id name)
  )
)

(define-public (admintransfer (nft <nft-trait>) (id uint) (name (string-ascii 100)) (nft2name <nft-trait>) (id2 uint))
  (begin 
   (asserts! (is-administrative tx-sender) err-not-authorized)
   (trnsfer nft id name nft2name id2) 
  )
)

;;functions
(define-private (del (nft <nft-trait>) (id uint) (name (string-ascii 100)))
   (begin 
    (asserts! (is-some (map-get? map-whois { name: name})) err-nothing-to-delete)
    (asserts! (is-some (map-get? names {nft: (contract-of nft), id: id})) err-not-yours-to-delete)
    
    (let 
      (
       (checkname1 (unwrap-panic (map-get? names {nft: (contract-of nft), id: id}))) 
      )
     (asserts! (is-eq checkname1 name) err-name-mismatch)
     (map-delete names {nft: (contract-of nft), id: id})
     (map-delete map-whois {name: name})
     (ok true) 
    )
  )
)

(define-private (trnsfer (nft <nft-trait>) (id uint) (name (string-ascii 100)) (nft2name <nft-trait>) (id2 uint))
   (let ( 
    (owner2 (unwrap! (unwrap! (contract-call? nft2name get-owner id2) err-not-found) err-not-found))  
       )
    (begin
     (asserts! (is-some (map-get? map-whois { name: name})) err-nothing-to-transfer)
     (asserts! (is-some (map-get? names {nft: (contract-of nft), id: id})) err-not-yours-to-transfer)
     (asserts! (is-none (map-get? names {nft: (contract-of nft2name), id: id2})) err-recipient-already-named)

   (let 
      (
       (checkname1 (unwrap-panic (map-get? names {nft: (contract-of nft), id: id}))) 
      )
    (asserts! (is-eq checkname1 name) err-name-mismatch)
    (map-delete names {nft: (contract-of nft), id: id})
    (map-delete map-whois {name: name})
    (map-set names {nft: (contract-of nft2name), id: id2} name)
    (map-set map-whois {name: name} {nft: (contract-of nft2name), id: id2})
    (ok true)
   )
  )
 )
)
;;Internal Functions 

(define-private (is-upper (name (string-ascii 100)))
  (fold upper name true))

(define-private (upper (char (string-ascii 1)) (output bool))
   (and output (is-some (index-of "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_-" char))
))

(define-data-var current-removing-administrative (optional principal) none )

(define-private (is-administrative (address principal))
  (or
    (is-eq CONTRACT-OWNER address )
    (is-some (index-of (var-get admins) address)) 
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
    (asserts! (is-eq tx-sender CONTRACT-OWNER) err-not-authorized)
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

(define-public (set-regfee (newregfee uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) (err err-not-authorized))
    (ok (var-set registration-fee  newregfee))
  )
)

(define-read-only (get-regfee)
  (var-get registration-fee ))


(define-public (set-regac (newpayee principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) (err err-not-authorized))
    (ok (var-set topay newpayee))
  )
)

(define-read-only (is-regac (address principal))
  (begin
    (asserts! (is-eq (var-get topay) address) err-not-registration-account)
    (ok u1)
  )
)

(define-public (set-transferac (newtp principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) (err err-not-authorized))
    (ok (var-set transferprincipal newtp))
  )
)

(define-read-only (is-transferac (address principal))
  (begin
    (asserts! (is-eq (var-get transferprincipal) address) err-not-transfer-account)
    (ok u1)
  )
)

(define-public (set-transfer-fee (newtf uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) (err err-not-authorized))
    (ok (var-set transfer-fee newtf))
  )
)

(define-read-only (get-transfer-fee)
  (var-get transfer-fee))

(define-constant err-not-yours-to-delete (err u201))
(define-constant err-not-yours-to-transfer (err u221))
(define-constant err-already-named (err u202))
(define-constant err-recipient-already-named (err u222))
(define-constant err-name-owned (err u203))
(define-constant err-name-not-yours (err u205))
(define-constant err-nothing-to-delete (err u206))
(define-constant err-nothing-to-transfer (err u207))
(define-constant err-name-mismatch (err u208))
(define-constant err-not-transfer-account (err u209))
(define-constant err-not-registration-account (err u210))
(define-constant err-invalid-chars (err u211))
(define-constant err-not-authorized (err u403))
(define-constant err-not-found (err u404))