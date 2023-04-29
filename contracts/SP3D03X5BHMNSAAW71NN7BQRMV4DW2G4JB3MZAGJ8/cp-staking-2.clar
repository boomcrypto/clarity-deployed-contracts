;; Crash Punk NFT(s) -> $SNOW Staking Contract
;; This contract is in charge of handling all staking within the Crash Punks ecosystem.
;; Written by StrataLabs


;; $SNOW FT Unique Properties
;; 1. Minting should only be allowed by the staking.clar contract

;;(use-trait nft-trait .nft-trait.nft-trait)
(use-trait nft-trait 'SP3D03X5BHMNSAAW71NN7BQRMV4DW2G4JB3MZAGJ8.nft-trait.nft-trait)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Cons, Vars, & Maps ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;
;; Vars/Cons ;;
;;;;;;;;;;;;;;;

;; (temporary) Helper Variable to stake and unstake custodial
(define-data-var function-caller-helper-to-unstake principal tx-sender)

;; @desc - List of principals that represents all whitelisted, actively-staking collections
(define-data-var whitelist-collections (list 100 principal) (list))
(define-data-var custodial-whitelist-collections (list 100 principal) (list))
(define-data-var non-custodial-whitelist-collections (list 100 principal) (list))

;; @desc - Uint that represents the *max* possible stake reward per block
(define-data-var max-payout-per-block uint u69444)

;; @desc - (temporary) Uint that's used to aggregate when calling "get-unclaimed-balance"
(define-data-var helper-total-unclaimed-balance uint u0)

;; @desc - (temporary) Principal that's used to temporarily hold a collection principal
(define-data-var helper-collection-principal principal tx-sender)

;; @desc - (temporary) List of uints that's used to temporarily hold the output of a map resulting in a list of height differences (aka blocks staked)
(define-data-var helper-height-difference-list (list 10000 uint) (list))

;; @desc - (temporary) Uint that needs to be removed when unstaking
(define-data-var id-being-removed uint u0)

;; @desc - Var (uint) that keeps track of the *current* (aka maybe people burned) max token supply
(define-data-var token-max-supply (optional uint) none)

;; @desc - Map that keeps track of whitelisted principal (key) & corresponding multiplier (value)
(define-map collection-multiplier principal uint)

;; @desc - List of principals that are whitelisted/have admin privileges
(define-data-var whitelist-admins (list 100 principal) (list tx-sender))

;; @desc - Map that tracks a staked item details (value) by collection & ID (key)
(define-map staked-item {collection: principal, id: uint}
  {
    staker: principal,
    status: bool,
    last-staked-or-claimed: uint
  }
)

;; @desc - Map that tracks all staked IDs (value) by collection principal (key)
(define-map all-stakes-in-collection principal (list 10000 uint))

;; @desc - Map that tracks all staked IDs in a collection (value) by user & collection & ID (key)
(define-map user-stakes-by-collection {user: principal, collection: principal}
  (list 10000 uint)
)

;;;;;;;;;;;;;;;;
;; Error Cons ;;
;;;;;;;;;;;;;;;;

(define-constant ERR-ALL-MINTED (err u101))
(define-constant ERR-NOT-AUTH (err u102))
(define-constant ERR-NOT-LISTED (err u103))
(define-constant ERR-WRONG-COMMISSION (err u104))
(define-constant ERR-NO-MINTS-LEFT (err u105))
(define-constant ERR-PARAM-TYPE (err u106))
(define-constant ERR-NOT-ACTIVE (err u107))
(define-constant ERR-NOT-STAKED (err u108))
(define-constant ERR-STAKED-OR-NONE (err u109))
(define-constant ERR-NOT-WHITELISTED (err u110))
(define-constant ERR-UNWRAP (err u111))
(define-constant ERR-NOT-OWNER (err u112))
(define-constant ERR-MIN-STAKE-HEIGHT (err u113))
(define-constant ERR-ALREADY-WHITELISTED (err u114))
(define-constant ERR-MULTIPLIER (err u115))
(define-constant ERR-UNWRAP-GET-UNCLAIMED-BALANCE-BY-COLLECTION (err u116))
(define-constant ERR-UNWRAP-SET-APPROVED (err u117))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;; Read Functions ;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-read-only (active-admins)
  (var-get whitelist-admins)
)

(define-read-only (active-collections)
  (var-get whitelist-collections)
)

(define-read-only (custodial-active-collections)
  (var-get custodial-whitelist-collections)
)

(define-read-only (non-custodial-active-collections)
  (var-get non-custodial-whitelist-collections)
)

(define-read-only (get-generation-rate-of-a-collection (collection principal)) 
  (map-get? collection-multiplier collection)
)

;; @desc - Read function that returns the current generation rate for tx-sender across all actively staked collective assets
(define-read-only (get-total-generation-rate-through-all-collections)
  (let
    (
      (list-of-collections-with-active-user-stakes (filter filter-out-collections-with-no-stakes (var-get whitelist-collections)))
      (list-of-generation-per-collection (map map-from-list-staked-to-generation-per-collection list-of-collections-with-active-user-stakes))
    )
    (print list-of-collections-with-active-user-stakes)
    (ok (fold + list-of-generation-per-collection u0))
  )
)

;; @desc - Filter function used which takes in all (list principal) stakeable/whitelist principals & outputs a (list principal) of actively-staked (by tx-sender) principals
(define-private (filter-out-collections-with-no-stakes (collection principal))
  (let
    (
      (collection-staked-by-user-list (default-to (list) (map-get? user-stakes-by-collection {user: tx-sender, collection: collection})))
      (collection-staked-by-user-count (len collection-staked-by-user-list))
    )
    (if (>= collection-staked-by-user-count u0)
      true
      false
    )
  )
)

;; @desc - Map function which takes in a list of actively-staked principals & returns a list of current generation rate per collection
(define-private (map-from-list-staked-to-generation-per-collection (collection principal))
  (let
    (
      (this-collection-multiplier (default-to u0 (map-get? collection-multiplier collection)))
      (collection-staked-by-user-list (default-to (list) (map-get? user-stakes-by-collection {user: tx-sender, collection: collection})))
      (collection-staked-by-user-count (len collection-staked-by-user-list))
      (this-collection-multiplier-normalized (/ (* this-collection-multiplier (var-get max-payout-per-block)) u10))
    )
    (* this-collection-multiplier-normalized collection-staked-by-user-count)
  )
)

;; @desc - Read function that returns the current generation rate for a user across one specific collection
(define-read-only (get-generation-by-collection (collection <nft-trait>) (user principal))
  (let
    (
      (this-collection-multiplier (default-to u0 (map-get? collection-multiplier (contract-of collection))))
      (collection-staked-by-user-list (get-items-staked-by-collection-and-user collection user))
      (collection-staked-by-user-count (len (unwrap! collection-staked-by-user-list ERR-UNWRAP)))
      (this-collection-multiplier-normalized (/ (* this-collection-multiplier (var-get max-payout-per-block)) u10))
    )

    ;; check collection is existing whitelist collection
    (asserts! (> this-collection-multiplier u0) ERR-NOT-WHITELISTED)
    (ok (* this-collection-multiplier-normalized collection-staked-by-user-count))
  )
)

;; @desc - function that gets the unclaimed balance by item and collection
(define-read-only (get-unclaimed-balance-by-collection-and-item (collection <nft-trait>) (item uint))
  (let
    (
      (this-collection-multiplier (default-to u0 (map-get? collection-multiplier (contract-of collection))))
      (this-collection-multiplier-normalized (/ (* this-collection-multiplier (var-get max-payout-per-block)) u10))
      (item-info (get-item-stake-details (contract-of collection) item))
      (get-time-from-staking-or-claiming (unwrap! (get last-staked-or-claimed item-info) ERR-UNWRAP))
      (time-passed (- block-height get-time-from-staking-or-claiming))
    )
    
    ;; check collection is existing whitelist collection
    (asserts! (> this-collection-multiplier u0) ERR-NOT-WHITELISTED)
    ;; check if item is staked
    (asserts! (is-eq true (unwrap! (get status item-info) ERR-UNWRAP)) ERR-NOT-STAKED)

    (ok (* this-collection-multiplier-normalized time-passed))
  )
)

;; @desc - function that gets the unclaimed balance by a list of items and a specific collection
(define-read-only (get-unclaimed-balance-by-collection-and-items (collection <nft-trait>) (items (list 10 (optional uint))))
  (let
    (
      (this-collection-multiplier (default-to u0 (map-get? collection-multiplier (contract-of collection))))
      (this-collection-multiplier-normalized (/ (* this-collection-multiplier (var-get max-payout-per-block)) u10))
      (item-info-1 (get-item-stake-details (contract-of collection) (unwrap! (unwrap! (element-at items u0) ERR-UNWRAP) ERR-UNWRAP)))
      (get-time-from-staking-or-claiming-1 (unwrap! (get last-staked-or-claimed item-info-1) ERR-UNWRAP))
      (time-passed-1 (- block-height get-time-from-staking-or-claiming-1))
      (item-info-2 (get-item-stake-details (contract-of collection) (unwrap! (unwrap! (element-at items u1) ERR-UNWRAP) ERR-UNWRAP)))
      (get-time-from-staking-or-claiming-2 (unwrap! (get last-staked-or-claimed item-info-2) ERR-UNWRAP))
      (time-passed-2 (- block-height get-time-from-staking-or-claiming-2))
      (item-info-3 (get-item-stake-details (contract-of collection) (unwrap! (unwrap! (element-at items u2) ERR-UNWRAP) ERR-UNWRAP)))
      (get-time-from-staking-or-claiming-3 (unwrap! (get last-staked-or-claimed item-info-3) ERR-UNWRAP))
      (time-passed-3 (- block-height get-time-from-staking-or-claiming-3))
      (item-info-4 (get-item-stake-details (contract-of collection) (unwrap! (unwrap! (element-at items u3) ERR-UNWRAP) ERR-UNWRAP)))
      (get-time-from-staking-or-claiming-4 (unwrap! (get last-staked-or-claimed item-info-4) ERR-UNWRAP))
      (time-passed-4 (- block-height get-time-from-staking-or-claiming-4))
      (item-info-5 (get-item-stake-details (contract-of collection) (unwrap! (unwrap! (element-at items u4) ERR-UNWRAP) ERR-UNWRAP)))
      (get-time-from-staking-or-claiming-5 (unwrap! (get last-staked-or-claimed item-info-5) ERR-UNWRAP))
      (time-passed-5 (- block-height get-time-from-staking-or-claiming-5))
      (item-info-6 (get-item-stake-details (contract-of collection) (unwrap! (unwrap! (element-at items u5) ERR-UNWRAP) ERR-UNWRAP)))
      (get-time-from-staking-or-claiming-6 (unwrap! (get last-staked-or-claimed item-info-6) ERR-UNWRAP))
      (time-passed-6 (- block-height get-time-from-staking-or-claiming-6))
      (item-info-7 (get-item-stake-details (contract-of collection) (unwrap! (unwrap! (element-at items u6) ERR-UNWRAP) ERR-UNWRAP)))
      (get-time-from-staking-or-claiming-7 (unwrap! (get last-staked-or-claimed item-info-7) ERR-UNWRAP))
      (time-passed-7 (- block-height get-time-from-staking-or-claiming-7))
      (item-info-8 (get-item-stake-details (contract-of collection) (unwrap! (unwrap! (element-at items u7) ERR-UNWRAP) ERR-UNWRAP)))
      (get-time-from-staking-or-claiming-8 (unwrap! (get last-staked-or-claimed item-info-8) ERR-UNWRAP))
      (time-passed-8 (- block-height get-time-from-staking-or-claiming-8))
      (item-info-9 (get-item-stake-details (contract-of collection) (unwrap! (unwrap! (element-at items u8) ERR-UNWRAP) ERR-UNWRAP)))
      (get-time-from-staking-or-claiming-9 (unwrap! (get last-staked-or-claimed item-info-9) ERR-UNWRAP))
      (time-passed-9 (- block-height get-time-from-staking-or-claiming-9))
      (item-info-10 (get-item-stake-details (contract-of collection) (unwrap! (unwrap! (element-at items u9) ERR-UNWRAP) ERR-UNWRAP)))
      (get-time-from-staking-or-claiming-10 (unwrap! (get last-staked-or-claimed item-info-10) ERR-UNWRAP))
      (time-passed-10 (- block-height get-time-from-staking-or-claiming-10))
    )
  
    ;; check collection is existing whitelist collection
    (asserts! (> this-collection-multiplier u0) ERR-NOT-WHITELISTED)

    ;; check if item is staked
    (asserts! (is-eq true (unwrap! (get status item-info-1) ERR-UNWRAP)) ERR-NOT-STAKED)
    (asserts! (is-eq true (unwrap! (get status item-info-2) ERR-UNWRAP)) ERR-NOT-STAKED)
    (asserts! (is-eq true (unwrap! (get status item-info-3) ERR-UNWRAP)) ERR-NOT-STAKED)
    (asserts! (is-eq true (unwrap! (get status item-info-4) ERR-UNWRAP)) ERR-NOT-STAKED)
    (asserts! (is-eq true (unwrap! (get status item-info-5) ERR-UNWRAP)) ERR-NOT-STAKED)
    (asserts! (is-eq true (unwrap! (get status item-info-6) ERR-UNWRAP)) ERR-NOT-STAKED)
    (asserts! (is-eq true (unwrap! (get status item-info-7) ERR-UNWRAP)) ERR-NOT-STAKED)
    (asserts! (is-eq true (unwrap! (get status item-info-8) ERR-UNWRAP)) ERR-NOT-STAKED)
    (asserts! (is-eq true (unwrap! (get status item-info-9) ERR-UNWRAP)) ERR-NOT-STAKED)
    (asserts! (is-eq true (unwrap! (get status item-info-10) ERR-UNWRAP)) ERR-NOT-STAKED)

    ;; Return a list of balance per each nft on the list
    (ok
      (list
        (* this-collection-multiplier-normalized time-passed-1)
        (* this-collection-multiplier-normalized time-passed-2)
        (* this-collection-multiplier-normalized time-passed-3)
        (* this-collection-multiplier-normalized time-passed-4)
        (* this-collection-multiplier-normalized time-passed-5)
        (* this-collection-multiplier-normalized time-passed-6)
        (* this-collection-multiplier-normalized time-passed-7)
        (* this-collection-multiplier-normalized time-passed-8)
        (* this-collection-multiplier-normalized time-passed-9)
        (* this-collection-multiplier-normalized time-passed-10)
      )
    )
  )
)

;; @desc - Read function that returns a (list uint) of all actively-staked IDs in a collection by user
(define-read-only (get-items-staked-by-collection-and-user (collection <nft-trait>) (user principal))
  (ok (default-to (list) (map-get? user-stakes-by-collection {user: user, collection: (contract-of collection)})))
)

;; @desc - Read function that returns stake details (staker, status, last-staked-or-claimed) in a specific collection & id
(define-read-only (get-item-stake-details (collection principal) (item-id uint))
      (map-get? staked-item {collection: collection, id: item-id})
)

;; @desc - Read function that returns the tx-sender's total unclaimed balance across all whitelisted collections
(define-public (get-unclaimed-balance)
  (let
    (
      ;; Filter from (list principal) of all whitelist principals/NFTs to (list principal) of all whitelist principals/NFTs where user has > 0 stakes
      (this-collection-stakes-by-user (filter filter-out-collections-with-no-stakes (var-get whitelist-collections)))
      (list-of-height-differences (list))
    )

    ;; 1. Filter from whitelisted to active staked
    ;; 2. Map from a list of principals to a list of uints

    ;; clear temporary unclaimed balance uint
    (var-set helper-total-unclaimed-balance u0)

    ;; map through this-collection-stakes-by-user, don't care about output list, care about appending to list-of-height-differences
    (map map-to-append-to-list-of-height-differences this-collection-stakes-by-user)

    ;; return unclaimed balance from tx-sender
    (ok (var-get helper-total-unclaimed-balance))
  )
)

;; @desc - looping through all the collections that a user *does* have active stakes, goal of this function is to append the unclaimed balance from each collection to a new list (helper-height-difference)
(define-private (map-to-append-to-list-of-height-differences (collection principal))
  (let
    (
      (this-collection-multiplier (default-to u0 (map-get? collection-multiplier collection)))
      (this-collection-stakes-by-user (default-to (list) (map-get? user-stakes-by-collection {user: tx-sender, collection: collection})))
      (this-collection-multiplier-normalized (/ (* this-collection-multiplier (var-get max-payout-per-block)) u10))
    )

    ;; set helper list to empty
    (var-set helper-height-difference-list (list))

    ;; Set collection helper var for folding through height differences
    (var-set helper-collection-principal collection)

    ;; Use map as a loop to append helper list with get-unclaimed-balance-by-collection
    (map append-helper-list-from-id-staked-to-height-difference this-collection-stakes-by-user)

    ;; Total unclaimed balance in collection
    (var-set helper-total-unclaimed-balance
      (+
        (var-get helper-total-unclaimed-balance)
        (* this-collection-multiplier-normalized (fold + (var-get helper-height-difference-list) u0))
      )
    )

    tx-sender
  )
)

;; @desc - function to append the height-difference
(define-private (append-helper-list-from-id-staked-to-height-difference (staked-id uint))
  (let
    (
      (staked-or-claimed-height (get last-staked-or-claimed (default-to {status: false, last-staked-or-claimed: block-height, staker: tx-sender} (map-get? staked-item {collection: (var-get helper-collection-principal), id: staked-id}))))
      (height-difference (- block-height staked-or-claimed-height))
    )

    (var-set helper-height-difference-list
      (unwrap! (as-max-len? (append (var-get helper-height-difference-list) height-difference) u1000) u0)
    )
    u1
  )
)

;; @desc - Read function that outputs a tx-sender total unclaimed balance from a specific collection
(define-public (get-unclaimed-balance-by-collection (collection <nft-trait>))
  (let
    (
      (this-collection-multiplier (unwrap! (map-get? collection-multiplier (contract-of collection)) (err u0)))
      (this-collection-stakes-by-user (default-to (list) (map-get? user-stakes-by-collection {user: tx-sender, collection: (contract-of collection)})))
      (list-of-staked-height-differences (map map-from-id-staked-to-height-difference this-collection-stakes-by-user))
      (this-collection-multiplier-normalized (/ (* this-collection-multiplier (var-get max-payout-per-block)) u10))
    )

      ;; Assert at least one stake exists
      (asserts! (and (> (len this-collection-stakes-by-user) u0) (> (len list-of-staked-height-differences) u0)) (err u0))

      ;; Var-set helper-collection-principal for use in map-from-id-staked-to-height-difference
      (var-set helper-collection-principal (contract-of collection))

      ;; Unclaimed $SNOW balance by user in this collection
      ;; Fold to aggregate total blocks staked across all IDs, then multiply collection multiplier
      (ok (* this-collection-multiplier-normalized (fold + list-of-staked-height-differences u0)))
  )
)

;; @desc - Helper function used to map from a list of uint of staked ids to a list of uint of height-differences
(define-private (map-from-id-staked-to-height-difference (staked-id uint))
  (let
    (
      (staked-or-claimed-height (get last-staked-or-claimed (default-to {status: false, last-staked-or-claimed: block-height, staker: tx-sender} (map-get? staked-item {collection: (var-get helper-collection-principal), id: staked-id}))))
    )
    (print (- block-height staked-or-claimed-height))
    (- block-height staked-or-claimed-height)
  )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;; Stake Functions ;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-public (stake (collection <nft-trait>) (id uint))
  (let
    (
      (current-all-staked-in-collection-list (default-to (list) (map-get? all-stakes-in-collection (contract-of collection))))
      (is-unstaked-in-all-staked-ids-list (index-of current-all-staked-in-collection-list id))
      (is-unstaked-in-staked-by-user-list (index-of (default-to (list) (map-get? user-stakes-by-collection {user: tx-sender, collection: (contract-of collection)})) id))
      (is-unstaked-in-stake-details-map (get status (default-to {status: false, last-staked-or-claimed: block-height, staker: tx-sender} (map-get? staked-item {collection: (var-get helper-collection-principal), id: id}))))
      (current-nft-owner (unwrap! (contract-call? collection get-owner id) ERR-UNWRAP))
      (custodial-list (var-get custodial-whitelist-collections))
      (transaction-sender tx-sender)
    )

    ;; Assert collection is whitelisted
    (asserts! (is-some (index-of (var-get whitelist-collections) (contract-of collection))) ERR-NOT-WHITELISTED)

    ;; Assert caller is current owner of NFT
    (asserts! (is-eq (some tx-sender) current-nft-owner) ERR-NOT-OWNER)

    ;; Asserts item is unstaked across all necessary storage
    (asserts! (and (is-none is-unstaked-in-all-staked-ids-list) (is-none is-unstaked-in-staked-by-user-list) (not is-unstaked-in-stake-details-map)) ERR-STAKED-OR-NONE)

    ;; manual staking for custodial
    (if
      (is-some (index-of custodial-list (contract-of collection))) 
        ;;(unwrap! (contract-call? collection transfer id tx-sender .staking) (err u401))
        (unwrap! (contract-call? collection transfer id tx-sender 'SP3D03X5BHMNSAAW71NN7BQRMV4DW2G4JB3MZAGJ8.cp-staking-2) (err u401))
    false
    )

    ;; Var set all staked ids list
    (map-set all-stakes-in-collection (contract-of collection)
      (unwrap! (as-max-len? (append (default-to (list) (map-get? all-stakes-in-collection (contract-of collection))) id) u10000) ERR-UNWRAP)
    )

    ;; Map set user staked in collection list
    (map-set user-stakes-by-collection {user: tx-sender, collection: (contract-of collection)}
        (unwrap! (as-max-len? (append (default-to (list) (map-get? user-stakes-by-collection {user: tx-sender, collection: (contract-of collection)})) id) u10000) ERR-UNWRAP)
    )

    ;; Map set staked-item details
    (ok (map-set staked-item {collection: (contract-of collection), id: id}
      {
        staker: tx-sender,
        status: true,
        last-staked-or-claimed: block-height
      }
    ))
  )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;; Claim Functions ;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; @desc - Function that a user calls to claim any generated stake rewards for a specific collection & specific id
(define-public (claim-item-stake (collection-collective <nft-trait>) (staked-id uint))
  (let
    (
      (this-collection-multiplier (default-to u0 (map-get? collection-multiplier (contract-of collection-collective))))
      (this-collection-multiplier-normalized (/ (* this-collection-multiplier (var-get max-payout-per-block)) u10))
      (current-staker (get staker (default-to {status: false, last-staked-or-claimed: block-height, staker: tx-sender} (map-get? staked-item {collection: (contract-of collection-collective), id: staked-id}))))
      (stake-status (get status (default-to {status: false, last-staked-or-claimed: block-height, staker: tx-sender} (map-get? staked-item {collection: (contract-of collection-collective), id: staked-id}))))
      (last-claimed-or-staked-height (get last-staked-or-claimed (default-to {status: false, last-staked-or-claimed: block-height, staker: tx-sender} (map-get? staked-item {collection: (contract-of collection-collective), id: staked-id}))))
      (current-nft-owner (unwrap! (contract-call? collection-collective get-owner staked-id) ERR-NOT-AUTH))
      (blocks-staked (- block-height last-claimed-or-staked-height))
    )

    ;; assert collection-collective is active/whitelisted
    (asserts! (is-some (index-of (var-get whitelist-collections) (contract-of collection-collective))) ERR-NOT-WHITELISTED)                                     

    ;; asserts is staked
    (asserts! stake-status ERR-NOT-STAKED)

    ;; asserts tx-sender is owner && asserts tx-sender is staker
    (asserts! (is-eq tx-sender current-staker) ERR-NOT-OWNER)

    ;; asserts height-difference > 0
    (asserts! (> blocks-staked u0) ERR-MIN-STAKE-HEIGHT)

    ;; contract call to mint for X amount
    ;;(unwrap! (contract-call? .snow mint (* this-collection-multiplier-normalized blocks-staked) tx-sender) ERR-UNWRAP)
    (unwrap! (contract-call? 'SP3D03X5BHMNSAAW71NN7BQRMV4DW2G4JB3MZAGJ8.cp-sn-2 mint (* this-collection-multiplier-normalized blocks-staked) tx-sender) ERR-UNWRAP)

    ;; update last-staked-or-claimed height
    (ok (map-set staked-item {collection: (contract-of collection-collective), id: staked-id}
      {
        status: true,
        last-staked-or-claimed: block-height,
        staker: tx-sender
      }
    ))
  )
)

;; ;; @desc - Function that a user calls to claim any generated stake rewards for a specific collection
;; (define-public (claim-collection-stake (collection-collective <nft-trait>))
;;   (let
;;     (
;;       (unclaimed-balance-by-collection (unwrap! (get-unclaimed-balance-by-collection collection-collective) ERR-UNWRAP-GET-UNCLAIMED-BALANCE-BY-COLLECTION))
;;     )

;;     ;; contract call to mint for X amount
;;     (unwrap! (contract-call? .snow mint unclaimed-balance-by-collection tx-sender) ERR-UNWRAP)
;;     ;;  (unwrap! (contract-call? 'SP3D03X5BHMNSAAW71NN7BQRMV4DW2G4JB3MZAGJ8.cp-sn-1 mint unclaimed-balance-by-collection tx-sender) ERR-UNWRAP)

;;     ;; Set collection helper var for folding through height differences
;;     (var-set helper-collection-principal (contract-of collection-collective))

;;     ;; need to update last-staked-or-claimed from every ID just claimed...
;;     ;; map from ID staked, don't care of output just update all stake details
;;     (ok (map map-to-reset-all-ids-staked-by-user-in-this-collection (default-to (list) (map-get? user-stakes-by-collection {user: tx-sender, collection: (contract-of collection-collective)}))))
;;   )
;; )

;; (define-private (map-to-reset-all-ids-staked-by-user-in-this-collection (staked-id uint))
;;   (begin
;;     (map-set staked-item {collection: (var-get helper-collection-principal), id: staked-id}
;;       (merge
;;         (default-to {status: false, last-staked-or-claimed: block-height, staker: tx-sender} (map-get? staked-item {collection: (var-get helper-collection-principal), id: staked-id}))
;;         {last-staked-or-claimed: block-height}
;;       )
;;     )
;;     u1
;;   )
;; )

;; @desc -Function that a user calls to stake any current or future SGC asset for $SNOW
;; @param - Collection (principal or collection?), ID (uint) -> bool?
(define-public (claim-all-stake)
  (let
    (
      (list-of-collections-with-active-user-stakes (filter filter-out-collections-with-no-stakes (var-get whitelist-collections)))
      (unclaimed-balance-total (unwrap! (get-unclaimed-balance) ERR-UNWRAP))
    )

    ;; contract call to mint for X amount
    ;;(unwrap! (contract-call? .snow mint unclaimed-balance-total tx-sender) ERR-UNWRAP)
    (unwrap! (contract-call? 'SP3D03X5BHMNSAAW71NN7BQRMV4DW2G4JB3MZAGJ8.cp-sn-2 mint unclaimed-balance-total tx-sender) ERR-UNWRAP)

    ;; loop through collections, then through IDs, reset last-staked-or-claimed value for each staked ID in each collection by user
    (ok (map map-to-loop-through-active-collection list-of-collections-with-active-user-stakes))
  )
)

(define-private (map-to-loop-through-active-collection (collection principal))
  (let
    (
      (collection-staked-by-user-list (default-to (list) (map-get? user-stakes-by-collection {user: tx-sender, collection: collection})))
    )
      (map map-to-set-reset-last-claimed-or-staked-height collection-staked-by-user-list)
      tx-sender
  )
)

(define-private (map-to-set-reset-last-claimed-or-staked-height (staked-id uint))
  (begin
    (map-set staked-item {collection: (var-get helper-collection-principal), id: staked-id}
      (merge
        (default-to {status: false, last-staked-or-claimed: block-height, staker: tx-sender} (map-get? staked-item {collection: (var-get helper-collection-principal), id: staked-id}))
        {last-staked-or-claimed: block-height}
      )
    )
    u0
  )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;; Unstake Functions ;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-public (unstake-item (collection <nft-trait>) (staked-id uint))
  (let
    (
      (this-collection-multiplier (default-to u0 (map-get? collection-multiplier (contract-of collection))))
      (this-collection-multiplier-normalized (/ (* this-collection-multiplier (var-get max-payout-per-block)) u10))
      (current-staker (get staker (default-to {status: false, last-staked-or-claimed: block-height, staker: tx-sender} (map-get? staked-item {collection: (contract-of collection), id: staked-id}))))
      (stake-status (get status (default-to {status: false, last-staked-or-claimed: block-height, staker: tx-sender} (map-get? staked-item {collection: (contract-of collection), id: staked-id}))))
      (last-claimed-or-staked-height (get last-staked-or-claimed (default-to {status: false, last-staked-or-claimed: block-height, staker: tx-sender} (map-get? staked-item {collection: (contract-of collection), id: staked-id}))))
      (current-nft-owner (unwrap! (contract-call? collection get-owner staked-id) ERR-NOT-AUTH))
      (blocks-staked (- block-height last-claimed-or-staked-height))
      (current-all-staked-in-collection-list (default-to (list) (map-get? all-stakes-in-collection (contract-of collection))))
      (current-user-staked-by-collection-list (default-to (list) (map-get? user-stakes-by-collection {user: tx-sender, collection: (contract-of collection)})))
      (custodial-list (var-get custodial-whitelist-collections))
    )

    ;; asserts is staked
    (asserts! stake-status ERR-NOT-STAKED)

    ;; asserts tx-sender is owner staker
    (asserts! (is-eq tx-sender current-staker) ERR-NOT-OWNER)

    ;; check if blocks-staked > 0 to see if there's any unclaimed $SNOW to claim
    (if (> blocks-staked u0)

      ;; if there is, need to claim snow balance
      ;;(unwrap! (contract-call? .snow mint (* this-collection-multiplier-normalized blocks-staked) tx-sender) ERR-UNWRAP)
      (unwrap! (contract-call? 'SP3D03X5BHMNSAAW71NN7BQRMV4DW2G4JB3MZAGJ8.cp-sn-2 mint (* this-collection-multiplier-normalized blocks-staked) tx-sender) ERR-UNWRAP)

      ;; if not, proceed
      true
    )

    ;; set function calle to tx-sender to send from contract
    (var-set function-caller-helper-to-unstake tx-sender)

    ;;manual unstake of custodial
    (if
        (is-some (index-of custodial-list (contract-of collection)))
        
        ;;(as-contract (unwrap! (contract-call? collection transfer staked-id .staking (var-get function-caller-helper-to-unstake)) (err u401)))
        (as-contract (unwrap! (contract-call? collection transfer staked-id 'SP3D03X5BHMNSAAW71NN7BQRMV4DW2G4JB3MZAGJ8.cp-staking-2 (var-get function-caller-helper-to-unstake)) (err u401)))

        true
    )

    ;; Set helper id for removal in filters below
    (var-set id-being-removed staked-id)

    ;; filter/remove staked-id from all-stakes-in-collection
    (map-set all-stakes-in-collection (contract-of collection) (filter is-not-id current-all-staked-in-collection-list))

    ;; filter/remove staked-id from user-stakes-by-collection
    (map-set user-stakes-by-collection {user: tx-sender, collection: (contract-of collection)} (filter is-not-id current-user-staked-by-collection-list))

    ;; update last-staked-or-claimed height
    (ok (map-set staked-item {collection: (contract-of collection), id: staked-id}
      {
        status: false,
        last-staked-or-claimed: block-height,
        staker: tx-sender
      }
    ))
  )
)

(define-private (is-not-id (list-id uint))
  (not (is-eq list-id (var-get id-being-removed)))
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;; Admin Functions ;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; @desc - Function that only an admin user can call to add a new SGC collection for staking
;; @param - Collection (principal or collection?), Collection-Multiple (uint)
(define-public (admin-add-new-custodial-collection (collection <nft-trait>) (collection-multiple uint))
  (let
    (
      (active-whitelist (var-get custodial-whitelist-collections))
      (all-whitelist (var-get whitelist-collections))
    )

    ;; assert the tx-sender is admin
    (asserts! (is-some (index-of (var-get whitelist-admins) tx-sender)) ERR-NOT-AUTH)

    ;; assert collection not already added
    (asserts! (is-none (index-of all-whitelist (contract-of collection))) ERR-ALREADY-WHITELISTED)

    ;; assert multiple < 100
    (asserts! (and (< collection-multiple u101) (> collection-multiple u0)) ERR-MULTIPLIER)

    ;; update collection-multiplier map
    (map-set collection-multiplier (contract-of collection) collection-multiple)

    ;; add new principle to whitelist
   (ok 
      (begin
        (var-set custodial-whitelist-collections (unwrap! (as-max-len? (append active-whitelist (contract-of collection)) u100) ERR-UNWRAP))
        (var-set whitelist-collections (unwrap! (as-max-len? (append all-whitelist (contract-of collection)) u100) ERR-UNWRAP))
      )
    )
  )
)

(define-public (admin-add-new-non-custodial-collection (collection <nft-trait>) (collection-multiple uint))
  (let
    (
      (active-whitelist (var-get non-custodial-whitelist-collections))
      (all-whitelist (var-get whitelist-collections))
    )

    ;; assert the tx-sender is admin
    (asserts! (is-some (index-of (var-get whitelist-admins) tx-sender)) ERR-NOT-AUTH)

    ;; assert collection not already added
    (asserts! (is-none (index-of all-whitelist (contract-of collection))) ERR-ALREADY-WHITELISTED)

    ;; assert multiple < 100
    (asserts! (and (< collection-multiple u101) (> collection-multiple u0)) ERR-MULTIPLIER)

    ;; update collection-multiplier map
    (map-set collection-multiplier (contract-of collection) collection-multiple)

    ;; add new principal to whitelist
    (ok 
      (begin
        (var-set non-custodial-whitelist-collections (unwrap! (as-max-len? (append active-whitelist (contract-of collection)) u100) ERR-UNWRAP))
        (var-set whitelist-collections (unwrap! (as-max-len? (append all-whitelist (contract-of collection)) u100) ERR-UNWRAP))
      )
    )
  )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Add Admin Address For Whitelisting ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; @desc - Function for add principals that have explicit permission to add current or future stakeable collections
;; @param - Principal that we're adding as whitelist
(define-public (add-admin-address-for-whitelisting (new-whitelist principal))
  (let
    (
      (current-admin-list (var-get whitelist-admins))
      (caller-principal-position-in-list (index-of current-admin-list tx-sender))
      (param-principal-position-in-list (index-of current-admin-list new-whitelist))
    )

    ;; asserts tx-sender is an existing whitelist address
    (asserts! (is-some caller-principal-position-in-list) ERR-NOT-AUTH)

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

    ;; assert the tx-sender is admin
    (asserts! (is-some (index-of (var-get whitelist-admins) tx-sender)) ERR-NOT-AUTH)

    ;; asserts param principal (removeable whitelist) already exist
    (asserts! (is-eq removeable-principal-position-in-list) ERR-NOT-WHITELISTED)

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

;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Admin Manual Unstake ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;
;; @desc - Function for emergency un-staking all manually custodied assets (Stacculents or Spookies)
;; @param - Principal of collection we're removing, ID of item we're manually unstaking & returning to user

(define-public (admin-emergency-unstake (collection <nft-trait>) (staked-id uint) (original-owner principal))
  (let
    (
      (this-collection-multiplier (default-to u0 (map-get? collection-multiplier (contract-of collection))))
      (this-collection-multiplier-normalized (/ (* this-collection-multiplier (var-get max-payout-per-block)) u10))
      (current-staker (get staker (default-to {status: false, last-staked-or-claimed: block-height, staker: tx-sender} (map-get? staked-item {collection: (contract-of collection), id: staked-id}))))
      (stake-status (get status (default-to {status: false, last-staked-or-claimed: block-height, staker: tx-sender} (map-get? staked-item {collection: (contract-of collection), id: staked-id}))))
      (last-claimed-or-staked-height (get last-staked-or-claimed (default-to {status: false, last-staked-or-claimed: block-height, staker: tx-sender} (map-get? staked-item {collection: (contract-of collection), id: staked-id}))))
      (current-nft-owner (unwrap! (contract-call? collection get-owner staked-id) ERR-NOT-AUTH))
      (blocks-staked (- block-height last-claimed-or-staked-height))
      (current-all-staked-in-collection-list (default-to (list) (map-get? all-stakes-in-collection (contract-of collection))))
      (current-user-staked-by-collection-list (default-to (list) (map-get? user-stakes-by-collection {user: tx-sender, collection: (contract-of collection)})))
      (custodial-list (var-get custodial-whitelist-collections))
      (admins (var-get whitelist-admins))
    )

    ;; asserts is staked
    (asserts! stake-status ERR-NOT-STAKED)

    ;; asserts original-owner is staker
    (asserts! (is-eq original-owner current-staker) ERR-NOT-OWNER)

    ;; asserts that tx-sender is admin
    (asserts! (is-some (index-of admins tx-sender)) ERR-NOT-AUTH)

    ;; check if blocks-staked > 0 to see if there's any unclaimed $SNOW to claim
    (if (> blocks-staked u0)

      ;; if there is, need to claim unstaked
      ;;(unwrap! (contract-call? .snow mint (* this-collection-multiplier-normalized blocks-staked) original-owner) ERR-UNWRAP)
      (unwrap! (contract-call? 'SP3D03X5BHMNSAAW71NN7BQRMV4DW2G4JB3MZAGJ8.cp-sn-2 mint (* this-collection-multiplier-normalized blocks-staked) original-owner) ERR-UNWRAP)

      ;; if not, proceed
      true
    )

    ;;manual unstake of custodial
    (if
        (is-some (index-of custodial-list (contract-of collection)))
        
        ;;(as-contract (unwrap! (contract-call? collection transfer staked-id .staking original-owner) (err u401))) 
        (as-contract (unwrap! (contract-call? collection transfer staked-id 'SP3D03X5BHMNSAAW71NN7BQRMV4DW2G4JB3MZAGJ8.cp-staking-2 original-owner) (err u401)))

        true
    )

    ;; Set helper id for removal in filters below
    (var-set id-being-removed staked-id)

    ;; filter/remove staked-id from all-stakes-in-collection
    (map-set all-stakes-in-collection (contract-of collection) (filter is-not-id current-all-staked-in-collection-list))

    ;; filter/remove staked-id from user-stakes-by-collection
    (map-set user-stakes-by-collection {user: original-owner, collection: (contract-of collection)} (filter is-not-id current-user-staked-by-collection-list))

    ;; update last-staked-or-claimed height
    (ok (map-set staked-item {collection: (contract-of collection), id: staked-id}
      {
        status: false,
        last-staked-or-claimed: block-height,
        staker: original-owner
      }
    ))
  )
)

;; @desc - Function that only an admin user can call to add a new SGC collection for staking
;; @param - Collection (principal or collection?), Collection-Multiple (uint)
(define-private (get-token-max-supply)
  (match (var-get token-max-supply)
    returnTokenMaxSupply returnTokenMaxSupply
    (let
      (
        ;;(new-token-max-supply (unwrap! (contract-call? .snow get-max-supply) u0))
        (new-token-max-supply (unwrap! (contract-call? 'SP3D03X5BHMNSAAW71NN7BQRMV4DW2G4JB3MZAGJ8.cp-sn-2 get-max-supply) u0))
      )
      (var-set token-max-supply (some new-token-max-supply))
      new-token-max-supply
    )
  )
)