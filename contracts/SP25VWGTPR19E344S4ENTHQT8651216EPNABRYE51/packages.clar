;; Package(s) NFT
;; This is a test contract for an upcoming NFT!!! :)
;; There is zero metadata in this contract, so it is not a real NFT.

;; ---------------------------------------------------------------------

;; Package(s)
;; Packages are burned for other NFTs within the  ______ ______ ecosystem (tnempiuqe, stcafitra, etc...)
;; This first release, with a total of 8000 NFTs, will be burned in exchange for tnempiuqe NFT
;; Out of the 8000 -> 1566 will be immediately airdropped, 6000 will be up for sale & 434 reserved for gameplay earns

;; Gameplay Earn
;; 434 Packages will be reserved for server-side airdrops
;; These airdrops are earned by users during Battles

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
(use-trait commission-trait 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.commission-trait.commission)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Cons, Vars, & Maps ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;
;; NFT Vars/Cons ;;
;;;;;;;;;;;;;;;;;;;

;; Defining the Package(s) NFT
(define-non-fungible-token package uint)

;; Server-Side Principal
(define-constant admin-one tx-sender)

;; Server-Side Principal -> need to update for non-test/mainnet
(define-constant admin-server 'SP1Y0KTSFKF9R5P762NAZ9T41GEVMQH9FHQRVG81W)

;; Purchase Price - 25 STX
(define-constant purchase-price u25000)

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
(define-constant ERR-INVALID-TOTAL (err u108))
(define-constant ERR-INVALID-PARAMS (err u109))

;;;;;;;;;;;;;;;;;
;; Vars & Maps ;;
;;;;;;;;;;;;;;;;;

;; IPFS Root URI - Changes only when collection is admin updated
(define-data-var ipfs-root (string-ascii 144) "")

;; Package Initial Collection Size (8k)
(define-data-var collection-limit-total uint u8001)

;; Uint var that keeps track of packages nft index
(define-data-var packages-index uint u1)

;; Package Initial Earn Size (434)
(define-data-var collection-limit-earn uint u435)

;; Uint var that keeps track of earned
(define-data-var packages-earned-index uint u1)

;; Package Initial Snapshot Airdrop Size (~1.5k) -> need final figure
(define-data-var collection-limit-snapshot uint u1565)

;; Uint var that keeps track of snapshot airdrops
(define-data-var packages-snapshot-index uint u1)

;; Package Total = Earn + Snapshot + Purchase (leftover)
;; Total is the collection total at any given time. When collection is extended total increases by the total new amount of Packages provided.
;; Earn is the amount of Packages that are earned by users during gameplay. When collection is extended, the Earn amount & earn amount index are both reset to the new value & u0 respectively.
;; Snapshot is the amount of Packages that are airdropped to users based on a snapshot of the community. We need to keep track of index since we might not be able to airdrop them all at once (likely if need to drop > 250).
;; Purchase is the amount of Packages that are available for purchase. Since Purchase is the leftover amount after the airdropped & reserved for gameplay, there is no need to keep track of index.

;; List of whitelisted game events (starting with "battle")
(define-data-var whitelisted-game-events (list 50 (string-ascii 128)) (list "battle"))

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
;; Purchases Remaining = Total - Index - Earns Left
(define-read-only (get-purchase-remaining) 
    (let 
      (
        (earns-remaining (- (var-get collection-limit-earn) (var-get packages-earned-index)))
        (airdrops-remaining (- (var-get collection-limit-snapshot) (var-get packages-snapshot-index)))
      ) 
      (- (- (- (var-get collection-limit-total) (var-get packages-index)) (+ earns-remaining airdrops-remaining)) u2)
    )
)

;; Get Airdrops Remaining
(define-read-only (get-earn-remaining) 
    (- (var-get collection-limit-earn) (var-get packages-earned-index))
)



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;; SIP09 Functions ;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-read-only (get-last-token-id)
  (ok (var-get packages-index))
)

(define-read-only (get-owner (id uint))
  (ok (nft-get-owner? package id))
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
    (nft-transfer? package id sender recipient)
  )
)



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;; Non-Custodial Help ;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


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
      (owner (unwrap! (nft-get-owner? package id) false))
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
      (owner (unwrap! (nft-get-owner? package id) ERR-NOT-AUTH))
      (listing (unwrap! (map-get? market id) ERR-NOT-LISTED))
      (price (get price listing))
    )
    (asserts! (is-eq (contract-of comm-trait) (get commission listing)) ERR-WRONG-COMMISSION)
    (try! (stx-transfer? price tx-sender owner))
    (try! (contract-call? comm-trait pay id price))
    (try! (transfer id owner tx-sender))
    (map-delete market id)
    (ok (print {a: "buy-in-ustx", id: id}))
  )
)



;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;; Core Functions ;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; @desc function to out-right purchase a package
(define-public (mint-package-purchase)
  (let
    (
      (current-id (var-get packages-index))
      (next-id (+ current-id u1))
    )

    ;; assert that not all minted out
    (asserts! (< current-id (var-get collection-limit-total)) ERR-ALL-MINTED)

    ;; Team Mint Commissions
    ;;  Fund (36%) -> 9 stx
    (try! (stx-transfer? (/ (* purchase-price u36) u100) tx-sender 'SP1AD4C22XFTYTV12G0MCGSPGC1B6KP2H1FBJKHWE))
    ;;  (26%) -> 6.5 stx
    (try! (stx-transfer? (/ (* purchase-price u26) u100) tx-sender 'SP2DADKD5KK22MHMVN3DCSKS10T17CM7PDTC6WQV8))
    ;;  (25%) -> 6.25 stx
    (try! (stx-transfer? (/ (* purchase-price u25) u100) tx-sender 'SP18J677R5GRD7EKK0S096WVQW19SDPWTC0TCBTGV))
    ;;  (13%) -> 3.25 stx
    (try! (stx-transfer? (/ (* purchase-price u25) u100) tx-sender 'SPZE89TY5HZPMHQGT0WGQ2HJHEJPHYF17YH825H6))

    ;; mint package to tx-sender
    (try! (nft-mint? package current-id tx-sender))

    ;; update packages-index
    (ok (var-set packages-index next-id))

  )
)

;; Purchase-Mint x3
(define-public (mint-package-purchase-x3) 
  (begin
    (try! (mint-package-purchase))
    (try! (mint-package-purchase))
    (ok (try! (mint-package-purchase)))
  )
)

;; Purchase-Mint x10
(define-public (mint-package-purchase-x10) 
  (begin 
    (try! (mint-package-purchase))
    (try! (mint-package-purchase))
    (try! (mint-package-purchase))
    (try! (mint-package-purchase))
    (try! (mint-package-purchase))
    (try! (mint-package-purchase))
    (try! (mint-package-purchase))
    (try! (mint-package-purchase))
    (try! (mint-package-purchase))
    (ok (try! (mint-package-purchase)))
  )
)

;; @desc function for admin-server to airdrop a Package to a user that earned it in the ecosystem
;; @param user: the principal of the winning user
(define-public (mint-package-earn (user principal))
  (let
    (
      (current-id (var-get packages-index))
      (next-id (+ current-id u1))
      (current-earn-id (var-get packages-earned-index))
      (next-earned (+ u1 current-earn-id))
    )

    ;; assert not all minted
    (asserts! (< current-id (var-get collection-limit-total)) ERR-ALL-MINTED)

    ;; assert not all earned
    (asserts! (< current-earn-id (var-get collection-limit-earn)) ERR-ALL-MINTED)

    ;; assert caller is admin-server
    (asserts! (is-eq contract-caller admin-server) ERR-NOT-AUTH)
    
    ;; mint package to user
    (try! (nft-mint? package current-id user))

    ;; update packages-index
    (var-set packages-index next-id)

    ;; update packages-earned
    (ok (var-set packages-earned-index next-earned))
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
    (asserts! (or (is-some caller-principal-position-in-list) (is-eq tx-sender admin-one) (is-eq tx-sender admin-server)) ERR-NOT-AUTH)

    ;; asserts param principal (new whitelist) doesn't already exist
    (asserts! (is-none param-principal-position-in-list) ERR-ALREADY-WHITELISTED)

    ;; append new whitelist address
    (ok (as-max-len? (append (var-get whitelist-admins) new-whitelist) u100))
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
    (asserts! (or (is-some caller-principal-position-in-list) (is-eq tx-sender admin-one) (is-eq tx-sender admin-server)) ERR-NOT-AUTH)

    ;; asserts param principal (removeable whitelist) already exist
    (asserts! (is-some removeable-principal-position-in-list) ERR-ALREADY-WHITELISTED)

    ;; temporary var set to help remove param principal
    (var-set helper-collection-principal remove-whitelist)

    ;; filter existing whitelist address
    (ok (filter is-not-removeable (var-get whitelist-admins)))
  )
)

;; @desc - Helper function for removing a specific admin from tne admin whitelist
(define-private (is-not-removeable (admin-principal principal))
  (not (is-eq admin-principal (var-get helper-collection-principal)))
)

;;;;;;;;;;;;;;;;;;;;;;;
;; Extend Collection ;;
;;;;;;;;;;;;;;;;;;;;;;;
;; Public function for any eligible admin to extend the collection limit, collection purchase & collection earn limits
;; Total = snapshot + earn + purchase(leftover)
;; Total collection limit is *ADDED* while purchase limit & earn limit are both ***RESET*** along with their indexes
(define-public (extend-collection (total-adding uint) (new-snapshot uint) (new-earn uint) (new-ipfs (string-ascii 144))) 
  (let 
    (
      (current-admin-list (var-get whitelist-admins))
      (caller-principal-position-in-list (index-of current-admin-list tx-sender))
      (current-total (var-get collection-limit-total))
      (next-total (+ current-total total-adding))
      (current-earn (var-get collection-limit-earn))
      (next-earn new-earn)
      (current-snapshot (var-get collection-limit-snapshot))
      (next-snapshot new-snapshot)
      (is-tx-sender-admin (index-of (var-get whitelist-admins) tx-sender))
    )

    ;; asserts tx-sender is an existing whitelist address, or admin-one/deployer or server admin/admin-server
    (asserts! (or (is-some caller-principal-position-in-list) (is-eq tx-sender admin-one) (is-eq tx-sender admin-server)) ERR-NOT-AUTH)

    ;; asserts that total-adding is greater than u0 and new-snapshot + new-snapshot is less than or equal to total-adding
    (asserts! (and (> total-adding u0) (<= (+ new-snapshot new-snapshot) total-adding)) ERR-INVALID-PARAMS)

    ;; asserts that new-earn is greater than u0...since it's a reset we'll likely always want game airdrops
    (asserts! (> new-earn u0) ERR-INVALID-PARAMS)

    ;; set new snapshot
    (var-set collection-limit-snapshot next-snapshot)

    ;; reset snapshot index
    (var-set packages-snapshot-index u1)

    ;; set new earn
    (var-set collection-limit-earn next-earn)

    ;; reset earn index
    (var-set packages-earned-index u1)

    ;; set new total
    (var-set collection-limit-total next-total)

    ;; set new ipfs
    (ok (var-set ipfs-root new-ipfs))

  )
)

;;;;;;;;;;;;;;;;;;;;;;;
;; Snapshot Airdrops ;;
;;;;;;;;;;;;;;;;;;;;;;;
;; @desc function for any admin to mass-airdrop a Package to a list of of recipients/principals - up to 250 recipients per call.  
;; @param recipients: list of all principals to receive a Package during this airdrop
(define-public (snapshot-airdrops (recipients (list 250 principal)))
  (let 
    (
      (current-id (var-get packages-index))
      (next-id (+ current-id u1))
      (collection-limit (var-get collection-limit-total))
      (snapshot-limit (var-get collection-limit-snapshot))
      (current-snapshot-index (var-get packages-snapshot-index))
      (planned-airdrops (len recipients))
      (new-snapshot-index (+ current-snapshot-index planned-airdrops))
      (is-tx-sender-admin (index-of (var-get whitelist-admins) tx-sender))
    )

    ;; assert tx-sender is an existing whitelist address
    (asserts! (is-some is-tx-sender-admin) ERR-NOT-AUTH)

    ;; assert completed snapshot + current-id is less than or equal to collection-limit
    (asserts! (<= (+ current-id planned-airdrops) collection-limit) ERR-INVALID-PARAMS)

    ;; assert that list of recipients is less than or equal to the remaining snapshots AND that list of recipients is not empty
    (asserts! (and (<= planned-airdrops (- snapshot-limit current-snapshot-index)) (> (len recipients) u0)) ERR-INVALID-PARAMS)

    ;; mass-airdrop a Package to each recipient in the list
    (ok (map mass-airdrop recipients))

  )
)

;; @desc - Helper function for snapshot-airdrops
;; Map over the list of recipients (principal) & mint a Package for each recipient
(define-private (mass-airdrop (recipient principal)) 
  (let 
    (
      (current-id (var-get packages-index))
      (next-id (+ current-id u1))
      (current-snapshot-index (var-get packages-snapshot-index))
      (new-snapshot-index (+ current-snapshot-index u1))
    )

    ;; mint a Package for each recipient
    (try! (nft-mint? package current-id tx-sender))

    ;; increment snapshot index
    (var-set packages-snapshot-index new-snapshot-index) 

    ;; increment packages index
    (ok (var-set packages-index next-id))
  )
)



;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;; Help Functions ;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; burn function
(define-public (burn-package (package-id uint))
  (begin 

    ;; assert tx-sender is owner
    (asserts! (is-eq (some tx-sender) (unwrap! (get-owner package-id) ERR-ALREADY-WHITELISTED)) ERR-ALREADY-WHITELISTED)

    ;; assert that contract-caller is tnempiuqe.clar 
    (asserts! (is-eq contract-caller .tnempiuqe) ERR-NOT-AUTH)

    ;; burn package
    (nft-burn? package package-id tx-sender)
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