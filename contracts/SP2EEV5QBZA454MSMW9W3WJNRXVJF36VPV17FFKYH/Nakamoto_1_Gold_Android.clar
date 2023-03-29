;; Nakamoto_1 Gold Android (1 of 1) NFT Contract
;; Written by the StrataLabs team and LunarCrush

;; Gold Android NFT
;; The Nakamoto_1_Gold_Android NFT has a collection limit of one (1), therefore considered a 1/1
;; This will be minted by the admin team & later sent to the moon-locked wallet/principal

;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; Contract Basics ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Check contract adheres to SIP-009
;; mainnet
(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
;; testnet
;; (impl-trait 'ST1NXBK3K5YYMD6FD41MVNP3JS1GABZ8TRVX023PT.nft-trait.nft-trait)
;; devnet/local
;; (impl-trait .sip-09.sip-09-trait)


;; Define Gold Android NFT
(define-non-fungible-token Nakamoto_1_Gold_Android uint)

;; constants
(define-constant Nakamoto_1_Gold_Android-limit u2)
(define-constant contract-owner tx-sender)

;; error messages
(define-constant ERR-ALL-MINTED (err u101))
(define-constant ERR-NOT-AUTH (err u102))
(define-constant ERR-NOT-LISTED (err u103))
(define-constant ERR-WRONG-COMMISSION (err u104))
(define-constant ERR-ALREADY-ADMIN (err u105))
(define-constant ERR-LIST-ADMIN (err u106))

;; vars
(define-data-var uri-root (string-ascii 37) "https://nakamoto1.space/gold_android/")
(define-data-var Nakamoto_1_Gold_Android-index uint u1)

;; Admin list for minting
(define-data-var admin-list (list 10 principal) (list tx-sender))

;; Helper principal for removing an admin
(define-data-var admin-to-remove principal tx-sender)

;; storage
(define-map market uint {price: uint, commission: principal})



;;;;;;;;;;;;;;;;;;;;;;
;; SIP009 Functions ;;
;;;;;;;;;;;;;;;;;;;;;;

(define-read-only (get-last-token-id)
  (ok (var-get Nakamoto_1_Gold_Android-index))
)

(define-read-only (get-owner (id uint))
  (ok (nft-get-owner? Nakamoto_1_Gold_Android id))
)

(define-read-only (get-token-uri (token-id uint))
  (ok
    (some
      (concat
        (concat
          (var-get uri-root)
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
    (nft-transfer? Nakamoto_1_Gold_Android id sender recipient)
  )
)



;;;;;;;;;;;;;;;;;;;;;;;;
;; Non-Custodial Help ;;
;;;;;;;;;;;;;;;;;;;;;;;;

;; @desc commission trait, needs to be implemented client-side
;; @param 1 func "pay" with two inputs & one response
(define-trait commission-trait
  (
    (pay (uint uint) (response bool uint))
  )
)

;; @desc gets market listing by market list ID
;; @param id; the ID of the market listing
(define-read-only (get-listing-in-ustx (id uint))
  (map-get? market id)
)

;; @desc checks NFT owner is either tx-sender or contract caller
;; @param id; the ID of the NFT in question
(define-private (is-sender-owner (id uint))
  (let
    (
      (owner (unwrap! (nft-get-owner? Nakamoto_1_Gold_Android id) false))
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
      (owner (unwrap! (nft-get-owner? Nakamoto_1_Gold_Android id) ERR-NOT-AUTH))
      (listing (unwrap! (map-get? market id) ERR-NOT-LISTED))
      (price (get price listing))
    )
    (asserts! (is-eq (contract-of comm-trait) (get commission listing)) ERR-WRONG-COMMISSION)
    (try! (stx-transfer? price tx-sender owner))
    (try! (contract-call? comm-trait pay id price))
    (try! (nft-transfer? Nakamoto_1_Gold_Android id owner tx-sender))
    (map-delete market id)
    (ok (print {a: "buy-in-ustx", id: id}))
  )
)




;;;;;;;;;;;;;;;;;;;;
;; Core Functions ;;
;;;;;;;;;;;;;;;;;;;;

;; @desc core function for minting the single Nakamoto_1_Gold_Android 1/1
(define-public (Mint_Nakamoto_1_Gold_Android)
  (let
    (
      (current-Nakamoto_1_Gold_Android-index (var-get Nakamoto_1_Gold_Android-index))
      (next-Nakamoto_1_Gold_Android-index (+ u1 (var-get Nakamoto_1_Gold_Android-index)))
    )

    ;; Assert that not all Nakamoto_1_Gold_Android have been minted
    (asserts! (< current-Nakamoto_1_Gold_Android-index Nakamoto_1_Gold_Android-limit) ERR-ALL-MINTED)

    ;; Assert that tx-sender is an admin using is-some & index-of
    (asserts! (is-some (index-of (var-get admin-list) tx-sender)) ERR-NOT-AUTH)
    
    ;; Mint Nakamoto_1_Gold_Android
    (try! (nft-mint? Nakamoto_1_Gold_Android current-Nakamoto_1_Gold_Android-index tx-sender))

    ;; Update Nakamoto_1_Gold_Android-index
    (ok (var-set Nakamoto_1_Gold_Android-index next-Nakamoto_1_Gold_Android-index))
  )
)


;;;;;;;;;;;;;;;;;;;;;;;
;; Utility Functions ;;
;;;;;;;;;;;;;;;;;;;;;;;

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



;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; Admin Functions ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Add New Admin
;; @desc function for admin to add new principal to admin list
;; @param - new-admin(principal): new admin principal
(define-public (add-admin (new-admin principal))
  (let
    (
      (current-admin-list (var-get admin-list))
    )
    ;; asserts tx-sender is an admin using is-some & index-of
    (asserts! (is-some (index-of current-admin-list tx-sender)) ERR-NOT-AUTH)

    ;; asserts new admin is not already an admin
    (asserts! (is-none (index-of current-admin-list new-admin)) ERR-ALREADY-ADMIN)

    ;; update (var-set) admin list by appending current-admin-list with new-admin, using as-max-len to ensure max 10 admins
    (ok (var-set admin-list (unwrap! (as-max-len? (append current-admin-list new-admin) u10) ERR-LIST-ADMIN)))
  )
)

;; Remove New Admin
;; @desc function for removing an admin principal from the admin list
;; @param - new-admin(principal): new admin principal
(define-public (remove-admin (removed-admin principal))
  (let
    (
      (current-admin-list (var-get admin-list))
    )
    ;; asserts tx-sender is an admin using is-some & index-of
    (asserts! (is-some (index-of current-admin-list tx-sender)) ERR-NOT-AUTH)

    ;; asserts admin to remove is an admin
    (asserts! (is-some (index-of current-admin-list removed-admin)) ERR-NOT-AUTH)

    ;; Var-set helper-principal to removed-admin
    (var-set admin-to-remove removed-admin)

    ;; update (var-set) admin list by filtering out admin-to-remove using filter
    (ok (var-set admin-list (filter filter-admin-principal current-admin-list)))

  )
)

;; Private helper function to filter out admin-to-remove
(define-private (filter-admin-principal (admin-principal principal))
  (if (is-eq admin-principal (var-get admin-to-remove))
    false
    true
  )
)