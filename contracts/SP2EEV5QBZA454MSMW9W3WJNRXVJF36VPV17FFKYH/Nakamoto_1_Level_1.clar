;; Nakamoto_1 Level 1 NFT Contract
;; Written by the StrataLabs team and LunarCrush

;; Level 1 NFT
;; 24k collection total, each NFT has one of four sub-types (u1,u2,u3,u4) & is sold for ~$250 USD by updating price in STX to match the market value in USD
;; Each Nakamoto_1_Level_1 NFT has one of four different "sub-types" (u1,u2,u3,u4). A user needs one of each sub-type to qualify for a Nakamoto_1_Level_2 NFT

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

;; Define Nakamoto_1_Level_1 NFT
(define-non-fungible-token Nakamoto_1_Level_1 uint)


;;;;;;;;;;;;;;;
;; Constants ;;
;;;;;;;;;;;;;;;

;; Collection limit (24k)
(define-constant Nakamoto_1_Level_1-limit u24001)

;; error messages
(define-constant ERR-ALL-MINTED (err u101))
(define-constant ERR-NOT-AUTH (err u102))
(define-constant ERR-NOT-LISTED (err u103))
(define-constant ERR-WRONG-COMMISSION (err u104))
(define-constant ERR-STX-TRANSFER (err u105))
(define-constant ERR-LIST-OVERFLOW (err u106))
(define-constant ERR-ALREADY-ADMIN (err u107))
(define-constant ERR-NOT-ADMIN (err u108))
(define-constant ERR-NFT-MINT (err u109))
(define-constant ERR-NFT-MINT-MAP (err u110))
(define-constant ERR-NFT-BURN (err u111))
(define-constant ERR-MINTING-PAUSED (err u112))


;; storage
(define-map market uint {price: uint, commission: principal})
(define-map sub-type uint uint)


;;;;;;;;;;;;;;;;;;;;;
;; Admin Variables ;;
;;;;;;;;;;;;;;;;;;;;;

;; Admin list for minting
(define-data-var admin-list (list 10 principal) (list tx-sender))

;; Helper principal for removing an admin
(define-data-var admin-to-remove principal tx-sender)

;; Mint price -> trying to keep parity w/ $250 USD
(define-data-var mint-price uint u290696900)

;; Nakamoto_1_Level_1 basics
(define-data-var minting-paused bool true)
(define-data-var uri-root (string-ascii 32) "https://nakamoto1.space/level_1/")
(define-data-var Nakamoto_1_Level_1-index uint u1)
(define-data-var Nakamoto_1_Level_1-subtype-index uint u1)


;;;;;;;;;;;;;;;;;;;;;
;; Read-Only Funcs ;;
;;;;;;;;;;;;;;;;;;;;;

;; Get current admins
(define-read-only (get-admins)
  (var-get admin-list)
)

;; Get item sub-type
(define-read-only (check-subtype (Nakamoto_1_Level_1-id uint))
  (map-get? sub-type Nakamoto_1_Level_1-id)
)

;; Get mint price
(define-read-only (get-mint-price)
  (var-get mint-price)
)

;; Get is minting paused
(define-read-only (get-minting-paused)
  (var-get minting-paused)
)

;;;;;;;;;;;;;;;;;;;;;;
;; SIP009 Functions ;;
;;;;;;;;;;;;;;;;;;;;;;

(define-read-only (get-last-token-id)
  (ok (var-get Nakamoto_1_Level_1-index))
)

(define-read-only (get-owner (id uint))
  (ok (nft-get-owner? Nakamoto_1_Level_1 id))
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
    (nft-transfer? Nakamoto_1_Level_1 id sender recipient)
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

;; @desc checks NFT owner is either tx-sender or contract caller,
;; @param id; the ID of the NFT in question
(define-private (is-sender-owner (id uint))
  (let
    (
      (owner (unwrap! (nft-get-owner? Nakamoto_1_Level_1 id) false))
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
      (owner (unwrap! (nft-get-owner? Nakamoto_1_Level_1 id) ERR-NOT-AUTH))
      (listing (unwrap! (map-get? market id) ERR-NOT-LISTED))
      (price (get price listing))
    )
    (asserts! (is-eq (contract-of comm-trait) (get commission listing)) ERR-WRONG-COMMISSION)
    (try! (stx-transfer? price tx-sender owner))
    (try! (contract-call? comm-trait pay id price))
    (try! (nft-transfer? Nakamoto_1_Level_1 id owner tx-sender))
    (map-delete market id)
    (ok (print {a: "buy-in-ustx", id: id}))
  )
)




;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; Core Functions ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;
;; Public Mints ;;
;;;;;;;;;;;;;;;;;;

;; Mint x1 Level 1
;; @desc - public mint for a single Level 1 NFT
(define-public (Mint_Nakamoto_1_Level_1)
  (let 
      ( 
        (current-Nakamoto_1_Level_1-index (var-get Nakamoto_1_Level_1-index))
        (next-Nakamoto_1_Level_1-index (+ u1 (var-get Nakamoto_1_Level_1-index)))
        (current-Nakamoto_1_Level_1-subtype-index (var-get Nakamoto_1_Level_1-subtype-index))
        (is-minting-paused (var-get minting-paused))
      )

      ;; checking for minting-paused
      (asserts! (is-eq is-minting-paused false) ERR-MINTING-PAUSED)

      ;; checking for Nakamoto_1_Level_1-index against entire Nakamoto_1_Level_1 collection (24k)
      (asserts! (< current-Nakamoto_1_Level_1-index Nakamoto_1_Level_1-limit) ERR-ALL-MINTED)
    
      ;; Charge the user Nakamoto_1_Level_1-price
      (unwrap! (stx-transfer? (var-get mint-price) tx-sender (as-contract tx-sender)) ERR-STX-TRANSFER)

      ;; Mint 1 Level 1 NFT
      (unwrap! (nft-mint? Nakamoto_1_Level_1 current-Nakamoto_1_Level_1-index tx-sender) ERR-NFT-MINT)

      ;; Assign the next sub-type
      (map-insert sub-type current-Nakamoto_1_Level_1-index current-Nakamoto_1_Level_1-subtype-index)

      ;; Increment the Nakamoto_1_Level_1-subtype-index
      (var-set Nakamoto_1_Level_1-index next-Nakamoto_1_Level_1-index)

      ;; Increment the Nakamoto_1_Level_1-subtype-index
      (ok (assign-next-subtype))
  )
)

;; Mint x2 Level 1
;; @desc - public mint for two Level 1 NFTs
(define-public (Mint_2_Nakamoto_1_Level_1)
    (begin 
        (try! (Mint_Nakamoto_1_Level_1))
        (ok (try! (Mint_Nakamoto_1_Level_1)))
    )
)


;;;;;;;;;;;;;;;;;
;; Admin Mints ;;
;;;;;;;;;;;;;;;;;

;; Admin Mint Public
;; @desc - admin mint for up to 250 Level 1 NFTs
;; @param - mint-count (list 250 uint): empty list of up to 250 uints for minting many
(define-public (admin-mint-public (mint-count (list 250 uint))) 
    (let
        (   
            (current-Nakamoto_1_Level_1-index (var-get Nakamoto_1_Level_1-index))
            (next-Nakamoto_1_Level_1-index (+ u1 (var-get Nakamoto_1_Level_1-index)))
            (current-Nakamoto_1_Level_1-subtype-index (var-get Nakamoto_1_Level_1-subtype-index))
            (mints-remaining (- Nakamoto_1_Level_1-limit (var-get Nakamoto_1_Level_1-index))) 
        )

        ;; Assert tx-sender is in admin-list using is-some & index-of
        (asserts! (is-some (index-of (var-get admin-list) tx-sender)) ERR-NOT-AUTH)

        ;; Assert that mint-count length is greater than u0 && that mint-count length is less than or equal to mints-remaining
        (asserts! (and (> (len mint-count) u0) (< (len mint-count) mints-remaining)) ERR-ALL-MINTED)

        ;; Private helper function to mint using map
        (ok (map admin-mint-private-helper mint-count))

    )
)

;; Admin Mint Private Helper
;; @desc - admin mint for a single Level 1 NFT
(define-private (admin-mint-private-helper (id uint))
    (let
        (
            (current-Nakamoto_1_Level_1-index (var-get Nakamoto_1_Level_1-index))
            (next-Nakamoto_1_Level_1-index (+ u1 current-Nakamoto_1_Level_1-index))
            (current-Nakamoto_1_Level_1-subtype-index (var-get Nakamoto_1_Level_1-subtype-index))
        )

        ;; Mint NFT
        (unwrap! (nft-mint? Nakamoto_1_Level_1 current-Nakamoto_1_Level_1-index tx-sender) ERR-NFT-MINT-MAP)

        ;; Update Nakamoto_1_Level_1-index
        (var-set Nakamoto_1_Level_1-index next-Nakamoto_1_Level_1-index)

        ;; Assign sub-type
        (map-insert sub-type current-Nakamoto_1_Level_1-index current-Nakamoto_1_Level_1-subtype-index)

        ;; Update Nakamoto_1_Level_1-subtype-index
        (ok (assign-next-subtype))

    )
)

;;;;;;;;;;;;;;;;;;;
;; Burn Function ;;
;;;;;;;;;;;;;;;;;;;
;; @desc - burn function for Level 1 NFTs
;; @param - id (uint): id of NFT to burn
(define-public (burn (id uint))
    (let
        (
            (owner (unwrap! (nft-get-owner? Nakamoto_1_Level_1 id) ERR-NOT-AUTH))
        )

        ;; Assert tx-sender is owner of NFT
        (asserts! (is-eq tx-sender owner) ERR-NOT-AUTH)

        ;; Burn NFT
        (ok (unwrap! (nft-burn? Nakamoto_1_Level_1 id tx-sender) ERR-NFT-BURN))

    )
)

;;;;;;;;;;;;;
;; Helpers ;;
;;;;;;;;;;;;;

;; @desc sub-type helper function - helps assign sub-types of type 1,2,3,4 when minted
(define-private (assign-next-subtype)
  (let
    (
      (current-subtype (var-get Nakamoto_1_Level_1-subtype-index))
    )
      (if (is-eq current-subtype u1)
          (var-set Nakamoto_1_Level_1-subtype-index u2)
          (if (is-eq current-subtype u2)
            (var-set Nakamoto_1_Level_1-subtype-index u3)
            (if (is-eq current-subtype u3)
              (var-set Nakamoto_1_Level_1-subtype-index u4)
              (var-set Nakamoto_1_Level_1-subtype-index u1)
            )
          )
      )
 )
)



;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; Admin Functions ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Update Mint Price
;; @desc - function for any of the admins to var-set the mint price
;; @param - new-mint-price (uint): new mint price
(define-public (update-mint-price (new-mint-price uint))
  (let
    (
      (current-admin-list (var-get admin-list))
    )
    ;; asserts tx-sender is an admin using is-some & index-of
    (asserts! (is-some (index-of current-admin-list tx-sender)) ERR-NOT-AUTH)

    ;; var-set new mint price
    (ok (var-set mint-price new-mint-price))
  )
)

;; Update Minting Paused
;; @desc - function for any of the admins to var-set  minting-paused
;; @param - new-mint-price (uint): new mint price
(define-public (update-minting-paused (new-minting-paused bool))
  (let
    (
      (current-admin-list (var-get admin-list))
    )
    ;; asserts tx-sender is an admin using is-some & index-of
    (asserts! (is-some (index-of current-admin-list tx-sender)) ERR-NOT-AUTH)

    ;; var-set new minting paused
    (ok (var-set minting-paused new-minting-paused))
  )
)

;; Unlock Contract STX
;; @desc - function for any of the admins to transfer STX out of contract
;; @param - amount (uint): amount of STX to transfer, recipient (principal): recipient of STX
(define-public (unlock-contract-stx (amount uint) (recipient principal))
  (let
    (
      (current-admin-list (var-get admin-list))
      (current-admin tx-sender)
    )
    ;; asserts tx-sender is an admin using is-some & index-of
    (asserts! (is-some (index-of current-admin-list tx-sender)) ERR-NOT-AUTH)

    ;; transfer STX
    (ok (unwrap! (as-contract (stx-transfer? amount tx-sender recipient)) ERR-STX-TRANSFER))
  )
)

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
    (ok (var-set admin-list (unwrap! (as-max-len? (append current-admin-list new-admin) u10) ERR-LIST-OVERFLOW)))
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
    (asserts! (is-some (index-of current-admin-list removed-admin)) ERR-NOT-ADMIN)

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