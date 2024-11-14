---
title: "Trait sys-rnft"
draft: true
---
```

;; wannabe rNFT contract
(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
;;
;; =========
;; CONSTANTS
;; =========
;;

;; Contract owner
(define-constant contract-owner tx-sender)

;; ERROR DEFINITIONS
;;


;; referral code was already used to mint rNFT
(define-constant err-refcode-used (err u3001))

;; generic invalid argument error
(define-constant err-invalid-argument (err u3002))

;; invalid token id
(define-constant err-invalid-token-id (err u3003))

;; already exists
(define-constant err-already-exists (err u3004))

;; referral code too length error
(define-constant err-invalid-length (err u3005))

;; recipient invalid i.e. attempted to transfer to self
(define-constant err-invalid-recipient (err u3006))

;; numeric argument is out of allowed range
(define-constant err-argument-out-of-range (err u3007))

;; user not allowed to perform transfer
(define-constant err-forbidden (err u403))


;; asset not found
(define-constant err-not-found (err u404))
;;
;; ==================
;; DATA MAPS AND VARS
;; ==================
;;
(define-non-fungible-token rnft uint)
(define-data-var last-token-id uint u0)

;; define token to token invitation relationship
(define-map token-invitation-meta uint { first-invited-id: uint,
            last-invited-id: uint })
(define-map bt-allocation uint {
            parent: uint,
            alloc-left: (optional bool)
            })
(define-map child-map uint {
            left-child: (optional uint),
            right-child: (optional uint)
            })

;; first owner of minted token
(define-map first-owner uint principal)


;; maps token id to referral code
(define-map token-ids uint (string-utf8 150))
(define-map ref-codes (string-utf8 150) uint)

;; uri mapping
(define-map token-uri uint (string-ascii 256))




;;
;; =================
;; PRIVATE FUNCTIONS
;; =================
;;

(define-private (is-valid-token-id (token-id uint))
  (and (> token-id u0) (<= token-id (var-get last-token-id))))


;;
;; ================
;; PUBLIC FUNCTIONS
;; ================
;;

;; Registering invites into holding tank
(define-public (invite-token (inviting-token-id uint)
                             (invited-token-id uint))
    (let (
          (inviting-meta (map-get? token-invitation-meta inviting-token-id))
          (prev-alloc (map-get? bt-allocation invited-token-id))
          )
     (try! (contract-call? .sys-admin assert-invoked-by-operator))
     (asserts! (not (is-eq inviting-token-id invited-token-id))
               err-invalid-argument)
     (asserts! (is-valid-token-id inviting-token-id) err-invalid-token-id)
     (asserts! (is-valid-token-id invited-token-id) err-invalid-token-id)
     (if (is-some prev-alloc) err-already-exists
         (let (
               (first (match inviting-meta meta 
                             (if (> invited-token-id (get first-invited-id meta))
                                 (get first-invited-id meta) invited-token-id)
                             invited-token-id))
               (last (match inviting-meta meta
                            (if (> invited-token-id (get last-invited-id meta))
                                invited-token-id (get last-invited-id meta))
                            invited-token-id))
               )
           (map-set token-invitation-meta inviting-token-id 
                    {  first-invited-id: first,
                       last-invited-id: last })
           (ok (map-insert bt-allocation invited-token-id 
                           { parent: inviting-token-id,
                           alloc-left: none }))
           )
         )
     )
  )

;; Allocating token from holding tank to right or left node of a token
(define-public (move-from-ht-to-node (ht-node uint) (ht-owner uint)
                                     (dest-node uint)
                                     (left-branch bool))
    (let (
          (ht-alloc (unwrap! (map-get? bt-allocation ht-node) err-not-found))
          (dest-map (default-to { left-child: none, right-child: none }
                                (map-get? child-map dest-node)
                                ))
          )
      (try! (contract-call? .sys-admin assert-invoked-by-operator))
      (asserts! (is-valid-token-id ht-node) err-invalid-token-id)
      (asserts! (is-valid-token-id ht-owner) err-invalid-token-id)
      (asserts! (is-valid-token-id dest-node) err-invalid-token-id)
      (asserts! (is-in-holding-tank ht-node ht-owner) err-invalid-argument)
      (asserts! (not (is-eq ht-node dest-node)) err-invalid-argument)
      (match 
       (if left-branch
           (if (is-some (get left-child dest-map)) err-already-exists
               (ok (map-set child-map dest-node { left-child: (some ht-node),
                            right-child: (get right-child dest-map) })))
           (if (is-some (get right-child dest-map)) err-already-exists
               (ok (map-set child-map dest-node { left-child: (get left-child dest-map),
                            right-child: (some ht-node) })))
           )
       succ (ok (map-set bt-allocation ht-node { parent: dest-node,
                         alloc-left: (some left-branch)} ))
       err (err err))
      )
  )

;;
;; Functions required by nft-trait
;;

(define-read-only (get-last-token-id)
  (ok (var-get last-token-id))
  )

(define-read-only (get-token-uri (token-id uint))
  (ok (map-get? token-uri token-id))
  )

(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? rnft token-id))
  )

(define-public (transfer (token-id uint) (sender principal)
                         (recipient principal))
  (let (
        (token-owner (unwrap! (unwrap! (get-owner token-id) (err u3)) (err u3)))
        (operator (unwrap-panic
                   (unwrap-panic (contract-call? .sys-admin get-operator))))
        (sender-is-internal-wallet (contract-call? .sys-investor
                                                   is-active
                                                   sender))
        )
    (asserts! (not (is-eq sender recipient)) (err u2))
    (asserts! (is-eq token-owner sender) (err u1))
    (if (or
         (and (is-eq tx-sender operator)
              sender-is-internal-wallet)
         (is-eq tx-sender sender))
        (nft-transfer? rnft
                       ;; #[allow(unchecked_data)]
                       token-id
                       sender
                       recipient)
        err-forbidden
        )
    )
  )
;;
;; rNFT public interface
;;
(define-public (mint (refcode (string-utf8 150))
                     (uri (string-ascii 256))
                     (recipient principal)
                     )
    (let (
          (next-token-id (+ (var-get last-token-id) u1))
          )
      (try! (contract-call? .sys-admin assert-invoked-by-operator))
      (if (is-none (map-get? ref-codes refcode))
          (begin
           (map-insert first-owner next-token-id recipient)
           (map-insert ref-codes refcode next-token-id)
           (map-insert token-ids next-token-id refcode)
           (try! (nft-mint? rnft next-token-id recipient))
           (map-set token-uri next-token-id uri)
           (var-set last-token-id next-token-id)
           (ok next-token-id)
           )
          err-refcode-used)
      )
  )

(define-read-only (get-first-owner (token-id uint))
    (match (map-get? first-owner token-id)
           val (ok val)
           err-not-found)
  )

(define-read-only (get-bt-children (token-id uint))
    (map-get? child-map token-id))

(define-read-only (get-parent (token-id uint))
    (match (map-get? bt-allocation token-id)
           all (some { parent: (get parent all),
                       left: (is-eq (get alloc-left all) (some true)),
                       right: (is-eq (get alloc-left all) (some false)),
                       holding-tank: (is-none (get alloc-left all)) })
           none))

(define-read-only (get-token-by-refcode (refcode (string-utf8 150)))
    (map-get? ref-codes refcode))

(define-read-only (get-refcode-of-token (token-id uint))
    (map-get? token-ids token-id))


(define-public (set-uri (token-id uint)
                        (uri (string-ascii 256)))
    (begin
     (try! (contract-call? .sys-admin
                           assert-invoked-by-operator))
     (map-set token-uri token-id uri)
     (ok true)
     )
  )

(define-read-only (is-in-holding-tank
                   (token-id uint) (tank-owner-token-id uint))
    (let (
          (meta-maybe (map-get? bt-allocation  token-id))
          )
      (match meta-maybe meta
             (let (
                   (parent (get parent meta))
                   (alloc-left (get alloc-left meta))
                   )
               (and (is-eq parent tank-owner-token-id)
                    (is-none alloc-left))
               )
             false)
      )
  )

```
