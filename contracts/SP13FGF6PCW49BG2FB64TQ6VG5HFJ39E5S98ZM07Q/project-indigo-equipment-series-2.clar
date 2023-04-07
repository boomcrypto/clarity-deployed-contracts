;; Equipment(s) Practice NFT
;; Equipment Practice NFT for Project Indigo
;; Written by StrataLabs

;; Equipment(s)
;; Equipment for battles are minted when a user burns an existing lost-shipment NFT
;; This first release, with a total of 1,713 Equipment(s), maps the initial collection size of lost-shipment(s)

;; (impl-trait .nft-trait.nft-trait)
(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

;; (use-trait commission-trait .commission-trait.commission)
(use-trait commission-trait 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.commission-trait.commission)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Cons, Vars, & Maps ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;
;; NFT Vars/Cons ;;
;;;;;;;;;;;;;;;;;;;

;; Defining the Bud(s) NFT
(define-non-fungible-token project-indigo-equipment-series-2 uint)

;; Need to update to new IPFS
(define-data-var ipfs-root (string-ascii 144) "ipfs://Qmd9Jg7Ejj6CyyzzaLRD8UUpHTvDoiXqgXbyJBckQ9j2WP/")

;; Server-Side Principal
(define-constant admin-server 'SP24PZYQTX0Y854AP4B8QFRQ9NFQHD0C8XSC53J9J)
;; (define-constant admin-server tx-sender)

;;;;;;;;;;;;;;;;
;; Error Cons ;;
;;;;;;;;;;;;;;;;
(define-constant ERR-ALL-MINTED (err u101))
(define-constant ERR-ALL-PURCHASED (err u102))
(define-constant ERR-ALL-EARNED (err u103))
(define-constant ERR-NOT-AUTH (err u104))
(define-constant ERR-NOT-LISTED (err u105))
(define-constant ERR-WRONG-COMMISSION (err u106))
(define-constant ERR-ALREADY-WHITELISTED (err u107))
(define-constant ERR-GET-OWNER-FAILED (err u108))
(define-constant ERR-ADMIN-OVERFLOW (err u109))
(define-constant ERR-LISTED (err u110))
(define-constant ERR-UNWRAP (err u111))

;;;;;;;;;;;;;;;;;
;; Vars & Maps ;;
;;;;;;;;;;;;;;;;;

;; Equipment NFT Index
(define-data-var project-indigo-equipment-series-2-index uint u1)

;; Equipment Initial Collection Size (1713k)
(define-data-var collection-limit-total uint u1714)

;; List of whitelisted game events (starting with tx-sender/deployer)
(define-data-var whitelist-admins (list 10 principal) (list tx-sender))

;; @desc - (temporary) Principal that's used to temporarily hold a collection principal
(define-data-var helper-collection-principal principal tx-sender)

(define-map market uint
  {
    price: uint,
    commission: principal
  }
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;; Read Functions ;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Get current admins
(define-read-only (get-admins)
  (var-get whitelist-admins)
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;; SIP09 Functions ;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-read-only (get-last-token-id)
  (ok (var-get project-indigo-equipment-series-2-index))
)

(define-read-only (get-owner (id uint))
  (ok (nft-get-owner? project-indigo-equipment-series-2 id))
)

(define-read-only (get-token-uri (token-id uint))
  (ok
    (some
      (concat
        (concat
          (var-get ipfs-root)
          (uint-to-ascii token-id)
        )
        ".json"
      )
    )
  )
)

(define-public (transfer (id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) ERR-NOT-AUTH)
    (asserts! (is-none (map-get? market id)) ERR-LISTED)
    (nft-transfer? project-indigo-equipment-series-2 id sender recipient)
  )
)



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;; Non-Custodial Help ;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; @desc commission trait, needs to be implemented client-side
;; @param 1 func "pay" with two inputs & one response
;; (define-trait commission-trait
;;   (
;;     (pay (uint uint) (response bool uint))
;;   )
;; )

;; @desc gets market listing by market list ID
;; @param id; the ID of the market listing
(define-read-only (get-listing-in-ustx (id uint))
  (map-get? market id)
)

;; @desc checks NFT owner is either tx-sender or contract caller,
;; @param id; the ID of the NFT in question
(define-private (is-sender-owner (id uint))
  (let
    (
      (owner (unwrap! (nft-get-owner? project-indigo-equipment-series-2 id) false))
    )
      (or (is-eq tx-sender owner) (is-eq contract-caller owner))
  )
)

;; @desc listing function
;; @param id: the ID of the NFT in question, price: the price being listed, comm-trait: a principal that conforms to the commission-trait
(define-public (list-in-ustx (id uint) (price uint) (comm-trait <commission-trait>))
  (let
    (
      (listing {price: price, commission: (contract-of comm-trait)})
    )

    (asserts! (is-sender-owner id) ERR-NOT-AUTH)
    (map-set market id listing)
    (ok (print (merge listing {a: "list-in-ustx", id: id})))
  )
)

;; @desc un-listing function
;; @param id: the ID of the NFT in question, price: the price being listed, comm-trait: a principal that conforms to the commission-trait
(define-public (unlist-in-ustx (id uint))
  (begin
    (asserts! (is-sender-owner id) ERR-NOT-AUTH)
    (map-delete market id)
    (ok (print {a: "unlist-in-stx", id: id}))
  )
)

;; @desc function to buy from a current listing
;; @param buy: the ID of the NFT in question, comm-trait: a principal that conforms to the commission-trait for royalty split
(define-public (buy-in-ustx (id uint) (comm-trait <commission-trait>))
  (let
    (
      (owner (unwrap! (nft-get-owner? project-indigo-equipment-series-2 id) ERR-NOT-AUTH))
      (listing (unwrap! (map-get? market id) ERR-NOT-LISTED))
      (price (get price listing))
    )
    (asserts! (is-eq (contract-of comm-trait) (get commission listing)) ERR-WRONG-COMMISSION)
    (try! (stx-transfer? price tx-sender owner))
    (try! (contract-call? comm-trait pay id price))
    (try! (nft-transfer? project-indigo-equipment-series-2 id owner tx-sender))
    (map-delete market id)
    (ok (print {a: "buy-in-ustx", id: id}))
  )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;; Core Functions ;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; @desc function to mint equipment 
(define-public (mint-equipment (lost-shipment-id uint))
  (let
    (
      (current-id (var-get project-indigo-equipment-series-2-index))
      (next-id (+ current-id u1))
    )

    ;; assert that not all minted out
    (asserts! (< current-id (var-get collection-limit-total)) ERR-ALL-MINTED)

    ;; assert that tx-sender is lost-shipment owner
    (asserts! (is-eq (some tx-sender) (unwrap! (contract-call? 'SP13FGF6PCW49BG2FB64TQ6VG5HFJ39E5S98ZM07Q.project-indigo-lost-shipments-series-2 get-owner lost-shipment-id) ERR-UNWRAP)) ERR-GET-OWNER-FAILED)

    ;; burn lost-shipments NFTs
    (unwrap! (contract-call? 'SP13FGF6PCW49BG2FB64TQ6VG5HFJ39E5S98ZM07Q.project-indigo-lost-shipments-series-2 burn-lost-shipment lost-shipment-id) ERR-UNWRAP)

    ;; mint lost-shipment to tx-sender
    (unwrap! (nft-mint? project-indigo-equipment-series-2 current-id tx-sender) ERR-UNWRAP)

    ;; update lost-shipments-index
    (ok (var-set project-indigo-equipment-series-2-index next-id))

  )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;; Help Functions ;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Add Admin Address For Whitelisting ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; @desc - Function for add principals that have explicit permission to add current or future stakeable collections
;; @param - Principal that we're adding as whitelist, initially only admin-one has permission
(define-public (add-admin-address-for-whitelisting (new-whitelist principal))
  (let
    (
      (current-admin-list (var-get whitelist-admins))
      (caller-principal-position-in-list (index-of current-admin-list tx-sender))
      (param-principal-position-in-list (index-of current-admin-list new-whitelist))
    )

    ;; asserts tx-sender is an existing whitelist address, or admin-one/deployer or server admin/admin-server
    (asserts! (or (is-some caller-principal-position-in-list) (is-eq tx-sender admin-server)) ERR-NOT-AUTH)

    ;; asserts param principal (new whitelist) doesn't already exist
    (asserts! (is-none param-principal-position-in-list) ERR-ALREADY-WHITELISTED)

    ;; append new whitelist address
    (ok
      (var-set whitelist-admins
        (unwrap! (as-max-len? (append current-admin-list new-whitelist) u10) ERR-ADMIN-OVERFLOW)
      )
    )
  )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Remove Admin Address For Whitelisting ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; @desc - Function for removing principals that have explicit permission to add current or future stakeable collections
;; @param - Principal that we're adding removing as white
(define-public (remove-admin-address-for-whitelisting (remove-whitelist principal))
  (let
    (
      (current-admin-list (var-get whitelist-admins))
      (caller-principal-position-in-list (index-of current-admin-list tx-sender))
      (removeable-principal-position-in-list (index-of current-admin-list remove-whitelist))
    )

    ;; asserts tx-sender is an existing whitelist address, or admin-one/deployer or server admin/admin-server
    (asserts! (or (is-some caller-principal-position-in-list) (is-eq tx-sender admin-server)) ERR-NOT-AUTH)

    ;; asserts param principal (removeable whitelist) already exist
    (asserts! (is-some removeable-principal-position-in-list) ERR-ALREADY-WHITELISTED)

    ;; temporary var set to help remove param principal
    (var-set helper-collection-principal remove-whitelist)

    ;; filter existing whitelist address
    (ok (var-set whitelist-admins (filter is-not-removeable (var-get whitelist-admins))))
  )
)

;; @desc - Helper function for removing a specific admin from tne admin whitelist
(define-private (is-not-removeable (admin-principal principal))
  (not (is-eq admin-principal (var-get helper-collection-principal)))
)

;; @desc utility function that takes in a unit & returns a string
;; @param value; the unit we're casting into a string to concatenate
;; thanks to Lnow for the guidance
(define-read-only (uint-to-ascii (value uint))
  (if (<= value u9)
    (unwrap-panic (element-at "0123456789" value))
    (get r (fold uint-to-ascii-inner
      0x000000000000000000000000000000000000000000000000000000000000000000000000000000
      {v: value, r: ""}
    ))
  )
)

(define-read-only (uint-to-ascii-inner (i (buff 1)) (d {v: uint, r: (string-ascii 39)}))
  (if (> (get v d) u0)
    {
      v: (/ (get v d) u10),
      r: (unwrap-panic (as-max-len? (concat (unwrap-panic (element-at "0123456789" (mod (get v d) u10))) (get r d)) u39))
    }
    d
  )
)