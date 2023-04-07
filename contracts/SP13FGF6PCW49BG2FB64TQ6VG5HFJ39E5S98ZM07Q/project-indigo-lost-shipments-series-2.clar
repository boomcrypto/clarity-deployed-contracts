;; lost-shipment(s) NFT
;; Written by StrataLabs

;; lost-shipment(s)
;; lost-shipments are burned for other NFTs within the Project-Indigo ecosystem (equipment, artifacts, treasure, etc...)
;; This first release, with a total of 1,713 NFTs, will be burned in exchange for equipment NFT
;; Out of the 1713 -> 213 will for airdrop, 600 will be up for sale & 900 reserved for gameplay earns

;; Gameplay Earn
;; Server-side airdrops
;; These airdrops are earned by users during Battles

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

;; Defining the lost-shipments(s) NFT
(define-non-fungible-token project-indigo-lost-shipments-series-2 uint)

;; Server-Side Principal -> need to update for non-test/mainnet
(define-constant admin-server 'SP24PZYQTX0Y854AP4B8QFRQ9NFQHD0C8XSC53J9J)


;;;;;;;;;;;;;;;;
;; Error Cons ;;
;;;;;;;;;;;;;;;;
(define-constant ERR-ALL-MINTED (err u101))
(define-constant ERR-SNAPSHOT-LIMIT-OR-ZERO (err u102))
(define-constant ERR-ALL-EARNED (err u103))
(define-constant ERR-NOT-AUTH (err u104))
(define-constant ERR-NOT-LISTED (err u105))
(define-constant ERR-WRONG-COMMISSION (err u106))
(define-constant ERR-MINT-PURCHASE-LIMIT (err u107))
(define-constant ERR-MINT-PURCHASE-INACTIVE (err u108))
(define-constant ERR-ALREADY-WHITELISTED (err u109))
(define-constant ERR-INVALID-TOTAL (err u110))
(define-constant ERR-INVALID-PARAMS (err u111))
(define-constant ERR-ADMIN-OVERFLOW (err u112))
(define-constant ERR-LISTED (err u113))
(define-constant ERR-UNWRAP (err u114))


;;;;;;;;;;;;;;;;;
;; Vars & Maps ;;
;;;;;;;;;;;;;;;;;

;; IPFS Root URI
(define-data-var ipfs-root (string-ascii 144) "ipfs://QmNVwWNzwadkddmnyJjBJ2pWqro9FwLKLmQ3GMsWNUV6un/")

;; Is-earn-or-purchase-active (flipped only once to acitivate mint purchase & mint earn)
(define-data-var is-earn-or-purchase-active bool false)

;; lost-shipment Initial Collection Size (1713)
(define-data-var collection-limit-total uint u1714)

;; Uint var that keeps track of lost-shipments nft index
(define-data-var project-indigo-lost-shipments-series-2-index uint u1)

;; lost-shipment Initial Earn Size (900)
(define-data-var collection-limit-earn uint u901)

;; Uint var that keeps track of earned
(define-data-var project-indigo-lost-shipments-series-2-earned-index uint u1)

;; lost-shipment Initial Purchase Size (600)
(define-data-var collection-limit-purchase uint u601)

;; Uint var that keeps track of earned
(define-data-var project-indigo-lost-shipments-series-2-purchased-index uint u1)

;; lost-shipment Initial Snapshot Airdrop Size (213) -> need final figure
(define-data-var collection-limit-snapshot uint u214)

;; Uint var that keeps track of snapshot airdrops
(define-data-var project-indigo-lost-shipments-series-2-snapshot-index uint u1)

;; Purchase Price - starting at 13 stx but will be able to be modified by admin
(define-data-var purchase-price uint u13000000)

;; lost-shipment Total = Earn + Snapshot + Purchase (leftover)
;; Total is the collection total at any given time.
;; Earn is the amount of lost-shipments that are earned by users during gameplay. 
;; Snapshot is the amount of lost-shipments that are airdropped to users based on a snapshot of the community. We need to keep track of index since we might not be able to airdrop them all at once (likely if need to drop > 250).
;; Purchase is the amount of lost-shipments that are available for purchase.

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

;; Get Purchases Remaining
;; Purchases Remaining = Total - Index - Purchase Left
(define-read-only (get-purchase-remaining) 
    (- (var-get collection-limit-purchase) (var-get project-indigo-lost-shipments-series-2-purchased-index))
)

;; Get Earn Remaining
(define-read-only (get-earn-remaining) 
    (- (var-get collection-limit-earn) (var-get project-indigo-lost-shipments-series-2-earned-index))
)

;; Get Airdrop Remaining
(define-read-only (get-snapshot-remaining) 
    (- (var-get collection-limit-snapshot) (var-get project-indigo-lost-shipments-series-2-snapshot-index))
)

;; Get Mints Remaining
(define-read-only (get-mints-remaining) 
    (- (var-get collection-limit-total) (var-get project-indigo-lost-shipments-series-2-index))
)

;; Get current price
(define-read-only (get-lost-shipment-price)
  (var-get purchase-price)
)

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
  (ok (var-get project-indigo-lost-shipments-series-2-index))
)

(define-read-only (get-owner (id uint))
  (ok (nft-get-owner? project-indigo-lost-shipments-series-2 id))
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
    (nft-transfer? project-indigo-lost-shipments-series-2 id sender recipient)
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
;;(use-trait commission-trait 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.commission-trait.commission)

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
      (owner (unwrap! (nft-get-owner? project-indigo-lost-shipments-series-2 id) false))
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
      (owner (unwrap! (nft-get-owner? project-indigo-lost-shipments-series-2 id) ERR-NOT-AUTH))
      (listing (unwrap! (map-get? market id) ERR-NOT-LISTED))
      (price (get price listing))
    )
    (asserts! (is-eq (contract-of comm-trait) (get commission listing)) ERR-WRONG-COMMISSION)
    (try! (stx-transfer? price tx-sender owner))
    (try! (contract-call? comm-trait pay id price))
    (try! (nft-transfer? project-indigo-lost-shipments-series-2 id owner tx-sender))
    (map-delete market id)
    (ok (print {a: "buy-in-ustx", id: id}))
  )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;; Core Functions ;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; @desc function to out-right purchase a lost-shipment
(define-public (mint-lost-shipment-purchase)
  (let
    (
      (current-id (var-get project-indigo-lost-shipments-series-2-index))
      (next-id (+ current-id u1))
      (current-purchase-id (var-get project-indigo-lost-shipments-series-2-purchased-index))
      (next-purchased (+ u1 current-purchase-id))
    )

    ;; assert that mint purchase & mint earn are active
    (asserts! (var-get is-earn-or-purchase-active) ERR-MINT-PURCHASE-INACTIVE)

    ;; assert that not all purchases have been made
    (asserts! (< current-purchase-id (var-get collection-limit-purchase)) ERR-MINT-PURCHASE-LIMIT)

    ;; assert that not all minted out
    (asserts! (< current-id (var-get collection-limit-total)) ERR-ALL-MINTED)

    ;; Team Mint Commissions
    ;; Karel (25%)
    (unwrap! (stx-transfer? (/ (* (var-get purchase-price) u25) u100) tx-sender 'SP1AD4C22XFTYTV12G0MCGSPGC1B6KP2H1FBJKHWE) ERR-UNWRAP)
    ;; PI Fund (49%) 
    (unwrap! (stx-transfer? (/ (* (var-get purchase-price) u49) u100) tx-sender 'SP2DADKD5KK22MHMVN3DCSKS10T17CM7PDTC6WQV8) ERR-UNWRAP)
    ;; Jon (26%)
    (unwrap! (stx-transfer? (/ (* (var-get purchase-price) u26) u100) tx-sender 'SP18J677R5GRD7EKK0S096WVQW19SDPWTC0TCBTGV) ERR-UNWRAP)

    ;; mint lost-shipment to tx-sender
    (unwrap! (nft-mint? project-indigo-lost-shipments-series-2 current-id tx-sender) ERR-UNWRAP)

    ;; update purchase index
    (var-set project-indigo-lost-shipments-series-2-purchased-index next-purchased)

    ;; update lost-shipments-index
    (ok (var-set project-indigo-lost-shipments-series-2-index next-id))

  )
)

;; Purchase-Mint x3
(define-public (mint-lost-shipment-purchase-x3) 
  (begin
    (unwrap! (mint-lost-shipment-purchase) ERR-UNWRAP)
    (unwrap! (mint-lost-shipment-purchase) ERR-UNWRAP)
    (ok (unwrap! (mint-lost-shipment-purchase) ERR-UNWRAP))
  )
)

;; Purchase-Mint x10
(define-public (mint-lost-shipment-purchase-x10) 
  (begin 
    (unwrap! (mint-lost-shipment-purchase) ERR-UNWRAP)
    (unwrap! (mint-lost-shipment-purchase) ERR-UNWRAP)
    (unwrap! (mint-lost-shipment-purchase) ERR-UNWRAP)
    (unwrap! (mint-lost-shipment-purchase) ERR-UNWRAP)
    (unwrap! (mint-lost-shipment-purchase) ERR-UNWRAP)
    (unwrap! (mint-lost-shipment-purchase) ERR-UNWRAP)
    (unwrap! (mint-lost-shipment-purchase) ERR-UNWRAP)
    (unwrap! (mint-lost-shipment-purchase) ERR-UNWRAP)
    (unwrap! (mint-lost-shipment-purchase) ERR-UNWRAP)
    (ok (unwrap! (mint-lost-shipment-purchase) ERR-UNWRAP))
  )
)

;; @desc function for admin-server to airdrop a lost-shipment to a user that earned it in the ecosystem
;; @param lost-shipment-id: the ID of the lost-shipment-id being used by client to claim equipment
(define-public (mint-lost-shipment-earn (user principal))
  (let
    (
      (current-id (var-get project-indigo-lost-shipments-series-2-index))
      (next-id (+ current-id u1))
      (current-earn-id (var-get project-indigo-lost-shipments-series-2-earned-index))
      (next-earned (+ u1 current-earn-id))
    )

    ;; assert not all minted
    (asserts! (< current-id (var-get collection-limit-total)) ERR-ALL-MINTED)

    ;; assert not all earned
    (asserts! (< current-earn-id (var-get collection-limit-earn)) ERR-ALL-EARNED)

    ;; assert caller is admin-server
    (asserts! (is-eq contract-caller admin-server) ERR-NOT-AUTH)
    
    ;; mint lost-shipment to user
    (unwrap! (nft-mint? project-indigo-lost-shipments-series-2 current-id user) ERR-UNWRAP)

    ;; update lost-shipments-index
    (var-set project-indigo-lost-shipments-series-2-index next-id)

    ;; update lost-shipments-earned
    (ok (var-set project-indigo-lost-shipments-series-2-earned-index next-earned))
  )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;; Admin Functions ;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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

;;;;;;;;;;;;;;;;;;;;;;;;;
;; Reassign-allocation ;;
;;;;;;;;;;;;;;;;;;;;;;;;;
;; Public function for any eligible admin to change the collection allocation for purchase, earn and airdrop according to remaining mints
;; Total = snapshot + earn + purchase

(define-public (reassign-allocation (new-purchase uint) (new-snapshot uint) (new-earn uint)) 
  (let 
    (
      (current-admin-list (var-get whitelist-admins))
      (caller-principal-position-in-list (index-of current-admin-list tx-sender))
      (total-sum (+ new-purchase (+ new-snapshot new-earn)))
      (collection-total (var-get collection-limit-total))
      (mints-remaining (- collection-total (var-get project-indigo-lost-shipments-series-2-index)))
      (current-earn (var-get collection-limit-earn))
      (current-earn-minted (var-get project-indigo-lost-shipments-series-2-earned-index))
      (next-earn new-earn)
      (current-snapshot (var-get collection-limit-snapshot))
      (current-snapshot-minted (var-get project-indigo-lost-shipments-series-2-snapshot-index))
      (next-snapshot new-snapshot)
      (current-purchase (var-get collection-limit-purchase))
      (current-purchase-minted (var-get project-indigo-lost-shipments-series-2-purchased-index))
      (next-purchase new-purchase)
    )

    ;; asserts tx-sender is an existing whitelist address, or admin-one/deployer or server admin/admin-server
    (asserts! (or (is-some caller-principal-position-in-list) (is-eq tx-sender admin-server)) ERR-NOT-AUTH)

    ;; asserts that total-sum is equal to collection-total
    (asserts! (is-eq total-sum mints-remaining) ERR-INVALID-TOTAL)

    ;; set new snapshot
    (var-set collection-limit-snapshot (+ next-snapshot current-snapshot-minted))

    ;; set new earn
    (var-set collection-limit-earn (+ next-earn current-earn-minted))

    ;; set new purchase
    (ok (var-set collection-limit-purchase (+ next-purchase current-purchase-minted)))

  )
)

;;;;;;;;;;;;;;;;;;;;;;;
;; Snapshot Airdrops ;;
;;;;;;;;;;;;;;;;;;;;;;;
;; @desc function for any admin to mass-airdrop a lost-shipment to a list of of recipients/principals - up to 250 recipients per call.  
;; @param recipients: list of all principals to receive a lost-shipment during this airdrop
(define-public (snapshot-airdrops (recipients (list 250 principal)))
  (let 
    (
      (current-id (var-get project-indigo-lost-shipments-series-2-index))
      (collection-limit (var-get collection-limit-total))
      (snapshot-limit (var-get collection-limit-snapshot))
      (current-snapshot-index (var-get project-indigo-lost-shipments-series-2-snapshot-index))
      (planned-airdrops (len recipients))
      (new-snapshot-index (+ current-snapshot-index planned-airdrops))
      (is-txsender-admin (index-of (var-get whitelist-admins) tx-sender))
    )

    ;; assert tx-sender is an existing whitelist address
    (asserts! (is-some is-txsender-admin) ERR-NOT-AUTH)

    ;; assert completed snapshot + current-id is less than or equal to collection-limit
    (asserts! (<= (+ current-id planned-airdrops) collection-limit) ERR-INVALID-PARAMS)

    ;; assert that list of recipients is less than or equal to the remaining snapshots AND that list of recipients is not empty
    (asserts! (and (<= planned-airdrops (- snapshot-limit current-snapshot-index)) (> (len recipients) u0)) ERR-SNAPSHOT-LIMIT-OR-ZERO)

    ;; mass-airdrop a lost-shipment to each recipient in the list
    (ok (map mass-airdrop recipients))

  )
)

;; @desc - Helper function for snapshot-airdrops
;; Map over the list of recipients (principal) & mint a lost-shipment for each recipient
(define-private (mass-airdrop (recipient principal)) 
  (let 
    (
      (current-id (var-get project-indigo-lost-shipments-series-2-index))
      (next-id (+ current-id u1))
      (current-snapshot-index (var-get project-indigo-lost-shipments-series-2-snapshot-index))
      (new-snapshot-index (+ current-snapshot-index u1))
    )

    ;; mint a lost-shipment for each recipient
    (unwrap! (nft-mint? project-indigo-lost-shipments-series-2 current-id recipient) ERR-UNWRAP)

    ;; increment snapshot index
    (var-set project-indigo-lost-shipments-series-2-snapshot-index new-snapshot-index) 

    ;; increment lost-shipments index
    (ok (var-set project-indigo-lost-shipments-series-2-index next-id))
  )
)

;; @desc - Helper function that flips to start mint purchase & mint earn
(define-public (flip-to-start-earn-and-purchase)
  (let 

    (
      (current-admin-list (var-get whitelist-admins))
    )

    ;; Assert tx-sender is an existing current-admin-list
    (asserts! (is-some (index-of current-admin-list tx-sender)) ERR-NOT-AUTH)

    ;; Var-set is-earn-or-purchase-active to true
    (ok (var-set is-earn-or-purchase-active true))


  )
)

;; @desc - Update the mint price
;; @param - new price uint
(define-public (change-price (new-price uint))
  (let 

    (
      (current-admin-list (var-get whitelist-admins))
    )

    ;; Assert tx-sender is an existing current-admin-list
    (asserts! (is-some (index-of current-admin-list tx-sender)) ERR-NOT-AUTH)

    ;; Var-set purchase-price to new-price
    (ok (var-set purchase-price new-price))

  )
)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;; Help Functions ;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; burn function
(define-public (burn-lost-shipment (lost-shipment-id uint))
  (begin 

    ;; assert tx-sender is owner
    (asserts! (is-eq (some tx-sender) (unwrap! (get-owner lost-shipment-id) ERR-ALREADY-WHITELISTED)) ERR-ALREADY-WHITELISTED)

    ;; assert that contract-caller is project-indigo-equipment-series-2.clar 
    (asserts! (is-eq contract-caller 'SP13FGF6PCW49BG2FB64TQ6VG5HFJ39E5S98ZM07Q.project-indigo-equipment-series-2) ERR-NOT-AUTH)

    ;; burn lost-shipment
    (nft-burn? project-indigo-lost-shipments-series-2 lost-shipment-id tx-sender)
  )
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