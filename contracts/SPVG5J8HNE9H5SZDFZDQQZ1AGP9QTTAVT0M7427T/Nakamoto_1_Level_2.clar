;; Nakamoto_1 Level 2 NFT Contract
;; Written by the StrataLabs team and LunarCrush

;; Level 2 NFT
;; The Nakamoto_1_Level_2 NFT has a collection limit of 6k. All 6k are derived from a tx-sender "burning" exactly 4 Nakamoto_1_Level_1s of different sub-types
;; Each Nakamoto_1_Level_2 NFT has a one of three different "sub-types" (u0,u1,u2). A user needs one of each sub-type to qualify for a Nakamoto_1_Level_2 NFT

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
(define-non-fungible-token Nakamoto_1_Level_2 uint)

;; constants
(define-constant Nakamoto_1_Level_2-limit u6001)
(define-constant DEPLOYER tx-sender)


;; error messages
(define-constant ERR-ALL-MINTED (err u101))
(define-constant ERR-NOT-AUTH (err u102))
(define-constant ERR-NOT-LISTED (err u103))
(define-constant ERR-WRONG-COMMISSION (err u104))
(define-constant ERR-INCORRECT-SUBTYPES (err u105))
(define-constant ERR-BURN-FIRST (err u106))
(define-constant ERR-BURN-SECOND (err u107))
(define-constant ERR-BURN-THIRD (err u108))
(define-constant ERR-BURN-FOURTH (err u109))
(define-constant ERR-Mint_Nakamoto_1_Level_2 (err u110))
(define-constant ERR-NFT-BURN (err u111))
(define-constant ERR-LISTED (err u112))


;; vars
(define-data-var ipfs-root (string-ascii 32) "https://nakamoto1.space/level_2/")
(define-data-var Nakamoto_1_Level_2-index uint u1)
(define-data-var Nakamoto_1_Level_2-subtype-index uint u1)

;; storage
(define-map market uint {price: uint, commission: principal})
(define-map sub-type uint uint)


;;;;;;;;;;;;;;;;;;;;;;
;; SIP009 Functions ;;
;;;;;;;;;;;;;;;;;;;;;;

(define-read-only (get-last-token-id)
  (ok (var-get Nakamoto_1_Level_2-index))
)

(define-read-only (get-owner (id uint))
  (ok (nft-get-owner? Nakamoto_1_Level_2 id))
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
    (nft-transfer? Nakamoto_1_Level_2 id sender recipient)
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
      (owner (unwrap! (nft-get-owner? Nakamoto_1_Level_2 id) false))
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
      (owner (unwrap! (nft-get-owner? Nakamoto_1_Level_2 id) ERR-NOT-AUTH))
      (listing (unwrap! (map-get? market id) ERR-NOT-LISTED))
      (price (get price listing))
    )
    (asserts! (is-eq (contract-of comm-trait) (get commission listing)) ERR-WRONG-COMMISSION)
    (try! (stx-transfer? price tx-sender owner))
    (try! (contract-call? comm-trait pay id price))
    (try! (nft-transfer? Nakamoto_1_Level_2 id owner tx-sender))
    (map-delete market id)
    (ok (print {a: "buy-in-ustx", id: id}))
  )
)




;;;;;;;;;;;;;;;;;;;;
;; Core Functions ;;
;;;;;;;;;;;;;;;;;;;;

;; @desc core function for minting a Nakamoto_1_Level_2, four lunar-fragments are required as burns
;; @param Nakamoto_1_Level_1-id-1: id of the 1/4 Nakamoto_1_Level_1 burned, Nakamoto_1_Level_1-id-2: id of the 2/4 Nakamoto_1_Level_1 burned, Nakamoto_1_Level_1-id-3: id of the 3/4 Nakamoto_1_Level_1 burned, Nakamoto_1_Level_1-id-4: id of the 4/4 Nakamoto_1_Level_1 burned
(define-public (Mint_Nakamoto_1_Level_2 (Nakamoto_1_Level_1-id-1 uint) (Nakamoto_1_Level_1-id-2 uint) (Nakamoto_1_Level_1-id-3 uint) (Nakamoto_1_Level_1-id-4 uint))
  (let
    (
      (current-Nakamoto_1_Level_2-index (var-get Nakamoto_1_Level_2-index))
      (next-Nakamoto_1_Level_2-index (+ u1 current-Nakamoto_1_Level_2-index))
      (current-Nakamoto_1_Level_2-subtype-index (var-get Nakamoto_1_Level_2-subtype-index))
      (nft-1-subtype (default-to u10 (contract-call? .Nakamoto_1_Level_1 check-subtype Nakamoto_1_Level_1-id-1)))
      (nft-2-subtype (default-to u10 (contract-call? .Nakamoto_1_Level_1 check-subtype Nakamoto_1_Level_1-id-2)))
      (nft-3-subtype (default-to u10 (contract-call? .Nakamoto_1_Level_1 check-subtype Nakamoto_1_Level_1-id-3)))
      (nft-4-subtype (default-to u10 (contract-call? .Nakamoto_1_Level_1 check-subtype Nakamoto_1_Level_1-id-4)))
    )

    ;; Assert that the Nakamoto_1_Level_2 index is less than the limit
    (asserts! (< (var-get Nakamoto_1_Level_2-index) Nakamoto_1_Level_2-limit) ERR-ALL-MINTED)

    ;; Assert that all four Nakamoto_1_Level_1's have different subtypes using is-eq
    (asserts! (and (is-eq nft-1-subtype u1) (is-eq nft-2-subtype u2) (is-eq nft-3-subtype u3) (is-eq nft-4-subtype u4)) ERR-INCORRECT-SUBTYPES)

    ;; Burn Nakamoto_1_Level_1-id-1 NFT
    (unwrap! (contract-call? .Nakamoto_1_Level_1 burn Nakamoto_1_Level_1-id-1) ERR-BURN-FIRST)

    ;; Burn Nakamoto_1_Level_1-id-2 NFT
    (unwrap! (contract-call? .Nakamoto_1_Level_1 burn Nakamoto_1_Level_1-id-2) ERR-BURN-SECOND)

    ;; Burn Nakamoto_1_Level_1-id-3 NFT
    (unwrap! (contract-call? .Nakamoto_1_Level_1 burn Nakamoto_1_Level_1-id-3) ERR-BURN-THIRD)

    ;; Burn Nakamoto_1_Level_1-id-4 NFT
    (unwrap! (contract-call? .Nakamoto_1_Level_1 burn Nakamoto_1_Level_1-id-4) ERR-BURN-FOURTH)
    
    ;; Insert the new Nakamoto_1_Level_2 sub-type into the sub-type map
    (map-insert sub-type current-Nakamoto_1_Level_2-index current-Nakamoto_1_Level_2-subtype-index)
    
    ;; Mint the Nakamoto_1_Level_2
    (unwrap! (nft-mint? Nakamoto_1_Level_2 current-Nakamoto_1_Level_2-index tx-sender) ERR-Mint_Nakamoto_1_Level_2)

    ;; Update to next sub-type
    (assign-next-subtype)

    ;; Update Nakamoto_1_Level_2 index
    (ok (var-set Nakamoto_1_Level_2-index next-Nakamoto_1_Level_2-index))
  )
)

;; @desc sub-type helper function - helps assign sub-types of type 1,2,3 when minted
(define-private (assign-next-subtype)
  (let
    (
      (current-subtype (var-get Nakamoto_1_Level_2-subtype-index))
    )
      (if (is-eq current-subtype u1)
          (var-set Nakamoto_1_Level_2-subtype-index u2)
          (if (is-eq current-subtype u2)
            (var-set Nakamoto_1_Level_2-subtype-index u3)
            (var-set Nakamoto_1_Level_2-subtype-index u1)
          )
      )
 )
)

  ;; @desc sub-type helper function - helps assign sub-types of type 1,2,3 when minted
  (define-read-only (check-subtype (Nakamoto_1_Level_2-id uint))
      (map-get? sub-type Nakamoto_1_Level_2-id)
  )

;;;;;;;;;;;;;;;;;;;
;; Burn Function ;;
;;;;;;;;;;;;;;;;;;;
;; @desc - burn function for Nakamoto_1_Level_1 NFTs
;; @param - id (uint): id of NFT to burn
(define-public (burn (id uint))
    (let
        (
            (owner (unwrap! (nft-get-owner? Nakamoto_1_Level_2 id) ERR-NOT-AUTH))
        )

        ;; Assert tx-sender is owner of NFT
        (asserts! (is-eq tx-sender owner) ERR-NOT-AUTH)

        ;; Burn NFT
        (ok (unwrap! (nft-burn? Nakamoto_1_Level_2 id tx-sender) ERR-NFT-BURN))

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

;; Migration Airdrop

;; Function to airdrop NFTs based on a list of uints
;; @param l1: A list of up to 1000 uint identifiers that will be used to determine NFT recipients
(define-public (airdrop-uints (l1 (list 1000 uint)))
    (ok 
        (begin 
            (asserts! (is-eq DEPLOYER tx-sender) ERR-NOT-AUTH) 
            (fold drop-uint l1 (var-get Nakamoto_1_Level_2-index))
        )
    )
)

;; Private helper function that processes each uint in the airdrop list
;; This is the core migration logic that maps old NFT IDs to owners
;; @param which: The NFT ID to look up in the old contract
;; @param id: The current NFT ID counter
(define-private (drop-uint (which uint) (id uint))
    (let 
        (
            ;; Look up who owned NFT ID 'which' at block height u1108000 in the previous contract
            (owner-at-block (get-owner-at-block which u1108000))
        ) 
        ;; Check if we found an owner
        (match owner-at-block owner-exists
                ;; If an owner was found, mint to that owner
                (is-err (Mint_Nakamoto_1_Level_2_Drop owner-exists)) 
                ;; If no owner was found, mint to the tx-sender
                (is-err (Mint_Nakamoto_1_Level_2_Drop tx-sender)) 
        )
        (+ id u1)
    )
)

;; Special Mint Function for Migration Airdrops
;; Similar to regular mint but doesn't check if minting is paused and does not burn nfts, they are already burnt from migration 1
;; Used exclusively for migration purposes
;; @param owner: The principal that will receive the NFT
(define-private (Mint_Nakamoto_1_Level_2_Drop (owner principal))
    (let
        (
            (current-Nakamoto_1_Level_2-index (var-get Nakamoto_1_Level_2-index))
            (next-Nakamoto_1_Level_2-index (+ u1 current-Nakamoto_1_Level_2-index))
            (current-Nakamoto_1_Level_2-subtype-index (var-get Nakamoto_1_Level_2-subtype-index))
        )
        ;; Assert that the Nakamoto_1_Level_2 index is less than the limit
        (asserts! (< (var-get Nakamoto_1_Level_2-index) Nakamoto_1_Level_2-limit) ERR-ALL-MINTED)
        ;; Insert the new Nakamoto_1_Level_2 sub-type into the sub-type map
        (map-insert sub-type current-Nakamoto_1_Level_2-index current-Nakamoto_1_Level_2-subtype-index)
        ;; Mint the Nakamoto_1_Level_2
        (unwrap! (nft-mint? Nakamoto_1_Level_2 current-Nakamoto_1_Level_2-index owner) ERR-Mint_Nakamoto_1_Level_2)
        ;; Update Nakamoto_1_Level_2 index
        (var-set Nakamoto_1_Level_2-index next-Nakamoto_1_Level_2-index)
        ;; If the recipient is the contract deployer, immediately burn the NFT
        ;; This is to have the exact same state as old contract
        (if (is-eq owner DEPLOYER)
            (unwrap! (nft-burn? Nakamoto_1_Level_2 current-Nakamoto_1_Level_2-index owner) ERR-NFT-BURN)
            false
        )
        ;; Update to next sub-type
        (ok (assign-next-subtype))
    )
)

;; Read-only function to get the owner of an NFT at a specific block height
;; Used to look up ownership data in the old contract
;; @param id: The NFT ID to check ownership for
;; @param block: The block height at which to check ownership
(define-read-only (get-owner-at-block (id uint) (block uint))
   ;; 1. Get the block information from the snapshot block height
   ;; 2. Call the get-owner function on the previous contract for the specified NFT ID
   ;; 3. Unwrap the response to get the principal or none
   (unwrap-panic (at-block (unwrap-panic (get-stacks-block-info? id-header-hash block)) (contract-call? 'SP2EEV5QBZA454MSMW9W3WJNRXVJF36VPV17FFKYH.Nakamoto_1_Level_2 get-owner id)))
)

(define-read-only (get-last-token-at-block)
   ;; 1. Get the block information from the snapshot block height
   ;; 2. Call the get-last-token-id function on the previous contract 
   ;; 3. Unwrap the response to get the uint
   (unwrap-panic (at-block (unwrap-panic (get-stacks-block-info? id-header-hash u1108000)) (contract-call? 'SP2EEV5QBZA454MSMW9W3WJNRXVJF36VPV17FFKYH.Nakamoto_1_Level_2 get-last-token-id)))
)