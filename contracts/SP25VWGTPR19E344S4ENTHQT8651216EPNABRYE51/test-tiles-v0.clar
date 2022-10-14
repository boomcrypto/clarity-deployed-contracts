;; Tiles
;; Control contract for how a user tracks & gets tiles
;; Written by Stratalabs

;; Tiles
;; A user spends 1 tile every time they set/place a tile position to a color
;; A user gets tiles through either "staking" or buying tiles
;; Generated tiles from staking expire after 3 days (432 blocks)
;; A tile is generated every 10 blocks
;; Purchased tiles don't have an expiration date

;; Current limitations & Architecture
;; https://github.com/stacks-network/stacks-blockchain/issues/1981
;; We can't use read-only functions with trait-parameter contract calls
;; Which means we can't centrally query/get from multiple collections from tiles.clar (since they'd be define-public functions & would take a block confirmation to return)
;; We can still get generation rates & unclaimed balances when placing a tile, but not when simply reading
;; A users balance of tiles therefore has to be calculated & displayed on the front-end but should rightly display the on-chain balance
;; User Tile Balance = Purchases + Active Collection 1 + Active Collection N...
;; All write functions (placing & replacing) should remain unaffected
;; We'll update tile-balance 

;; Existing Badger collections
;; Badger -> SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2
;; Baby -> SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.baby-badgers

(use-trait nft-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Cons, Vars & Maps ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;
;; Cons ;;
;;;;;;;;;;
(define-constant contract-owner tx-sender)
(define-constant purchase-5-price u2000000)
(define-constant purchase-25-price u5000000)
(define-constant purchase-100-price u10000000)
(define-constant purchase-500-price u25000000)
(define-constant generation-max-height u432)

;;;;;;;;;;
;; Errs ;;
;;;;;;;;;;

;;;;;;;;;;
;; Vars ;;
;;;;;;;;;;
;; @desc - Var list of principals that are considered admins
(define-data-var admins (list 10 principal) (list tx-sender))

;; @desc - Var list of principals that are considered admins
(define-data-var helper-amount-list (list 100 uint) (list ))

;; @desc - Helper var for principal
(define-data-var helper-principal principal tx-sender)

;; @desc - Helper var for uint
(define-data-var helper-uint uint u0)

;; @desc - Var list of whitelisted collections/principals
(define-data-var whitelisted-collections (list 100 principal) (list 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.baby-badgers))


;;;;;;;;;
;; Map ;;
;;;;;;;;;

(define-map purchased-balance principal uint)

(define-map active-by-user-and-collection { user: principal, collection: principal } (list 5000 uint))

(define-map status-by-id-and-collection { id: uint, collection: principal } {
  last-claimed-height: uint,
  last-claimed-user: principal
})

;; how many blocks until a full tile is generated, badgers -> 1 tile / 10 blocks, babies -> 1 tile / 5 blocks
(define-map whitelisted-collection-blocks-per-tile-generation principal uint)


;; @desc - Function to get the total balance for a user; only works when spending
(define-public (get-total-balance) 
  (let
    (
      ;; Get purchased
      (purchased (default-to u0  (map-get? purchased-balance tx-sender)))
      ;; Get generated balance (private function)
      (generated (unwrap! (get-generated-balance) (err u0)))
      ;; Add together
      (total-balance (+ purchased generated))
    )
    (ok total-balance)
  )
)


;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Read-Only Funcs ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;

;; @desc - Function to get the generated balance for a user; only works when spending
(define-public (get-generated-balance) 
  (let
    (
      (current-user-active-generations (filter remove-inactive-generations (var-get whitelisted-collections)))
      (current-user-collection-balance (map map-from-collection-to-balance current-user-active-generations))
    )
    (ok (fold + current-user-collection-balance u0))
  )
)

(define-private (remove-inactive-generations (collection principal))
  (let
    (
      (actives-in-collection (default-to (list ) (map-get? active-by-user-and-collection { user: tx-sender, collection: collection })))
    )
    (if (> (len actives-in-collection) u0)
      true
      false
    )
  )
)

(define-private (map-from-collection-to-balance (collection principal))
  (begin 
    (var-set helper-principal collection)
    (get-generation-balance-by-collection-private collection)
  )
)

(define-private (get-generation-balance-by-collection-private (collection principal)) 
  (begin 
    (var-set helper-principal collection)
    (let 
      (
        (current-actives-in-collection (default-to (list ) (map-get? active-by-user-and-collection { user: tx-sender, collection: collection })))
        (current-heights-in-collection (map map-from-ids-to-heights current-actives-in-collection))
        ;; Only add heights that are higher than blocks-per-tile-generation that way there's a gurantee that a can tile can be deleted
        (current-generation-balance-raw (fold + current-heights-in-collection u0))
        (current-collection-blocks-per-tile (default-to u0 (map-get? whitelisted-collection-blocks-per-tile-generation collection)))
        (current-generation-balance-normalized (/ current-generation-balance-raw current-collection-blocks-per-tile))
      )
      current-generation-balance-normalized
    )
  )
)

;; @desc - Function to get the generated balance for a user across a specific collection
(define-public (get-generation-balance-by-collection (collection principal)) 
  (begin 
    (var-set helper-principal collection)
    (let 
      (
        (current-actives-in-collection (default-to (list ) (map-get? active-by-user-and-collection { user: tx-sender, collection: collection })))
        (current-heights-in-collection (map map-from-ids-to-heights current-actives-in-collection))
        ;; Only add heights that are higher than blocks-per-tile-generation that way there's a gurantee that a can tile can be deleted
        (current-generation-balance-raw (fold + current-heights-in-collection u0))
        (current-collection-blocks-per-tile (unwrap! (map-get? whitelisted-collection-blocks-per-tile-generation collection) (err u0)))
        (current-generation-balance-normalized (/ current-generation-balance-raw current-collection-blocks-per-tile))
      )
      (ok current-generation-balance-normalized)
    )
  )
)

(define-private (map-from-ids-to-heights (id uint)) 
  (let 
    (
      (id-status (default-to { last-claimed-height: block-height, last-claimed-user: tx-sender } (map-get? status-by-id-and-collection { id: id, collection: (var-get helper-principal)})))
      (id-last-claim-height (get last-claimed-height id-status))
      (current-collection-blocks-per-tile (default-to u0 (map-get? whitelisted-collection-blocks-per-tile-generation (var-get helper-principal))))
    ) 
      (if (> (- block-height id-last-claim-height) current-collection-blocks-per-tile)
        (if (> (- block-height id-last-claim-height) generation-max-height)
          generation-max-height
          (- block-height id-last-claim-height)
        )
        u0
      )
  )
)



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Getting Tiles Funcs ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;
;;;; Activate Item ;;;;
;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;

;; @desc - Function to activate an item
;; @param - collection - The collection the item is in, id - The id of the item
(define-public (activate-item (collection <nft-trait>) (id uint)) 
  (let 
    (
      (current-user-active-in-collection (default-to (list ) (map-get? active-by-user-and-collection { user: tx-sender, collection: (contract-of collection) })))
      (current-item-status (map-get? status-by-id-and-collection {id: id, collection: (contract-of collection)}))
      (current-nft-owner (unwrap! (contract-call? collection get-owner id) (err u4)))
    )

    ;; Assert that collection is whitelisted
    (asserts! (is-some (index-of (var-get whitelisted-collections) (contract-of collection))) (err u7))

    ;; Assert that tx-sender is the owner of the NFT
    (asserts! (is-eq (some tx-sender) current-nft-owner) (err u4))

    ;; Assert that the item is not already active / item-status is-none, if it is user should be calling "reactive-item"
    (asserts! (is-none current-item-status) (err u5))

    ;; Map-set active-by-user-and-collection list by appending new item
    (map-set active-by-user-and-collection { user: tx-sender, collection: (contract-of collection) } 
      (unwrap! (as-max-len? (append current-user-active-in-collection id) u5000) (err u6))
    )

    ;; Map-set status-by-id-and-collection
    (ok (map-set status-by-id-and-collection { id: id, collection: (contract-of collection) } 
      { last-claimed-height: block-height, last-claimed-user: tx-sender }
    ))
  )
)

;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Reactivate Item ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;

;; @desc - Function to reactivate an item (aka reset the user)
;; @param - collection - The collection the item is in, id - The id of the item
(define-public (reactivate-item (collection <nft-trait>) (id uint)) 
  (let 
    (
      (current-user-active-in-collection (default-to (list ) (map-get? active-by-user-and-collection { user: tx-sender, collection: (contract-of collection) })))
      (current-item-status (unwrap! (map-get? status-by-id-and-collection {id: id, collection: (contract-of collection)}) (err u5)))
      (current-status-owner (get last-claimed-user current-item-status))
      (current-nft-owner (unwrap! (contract-call? collection get-owner id) (err u4)))
    )

    ;; Assert that collection is whitelisted
    (asserts! (is-some (index-of (var-get whitelisted-collections) (contract-of collection))) (err u7))

    ;; Assert that tx-sender is the owner of the NFT
    (asserts! (is-eq (some tx-sender) current-nft-owner) (err u4))

    ;; Assert that tx-sender is not the current-status-owner
    (asserts! (not (is-eq tx-sender current-status-owner)) (err u8))

    ;; Var-set helper uint
    (var-set helper-uint id)

    ;; Filter out the id from the active-by-user-and-collection list from the previous owner / current-status-owner
    (map-set active-by-user-and-collection { user: current-status-owner, collection: (contract-of collection) } 
      (filter filter-out-id current-user-active-in-collection)
    )

    ;; Map-set active-by-user-and-collection list by appending new item
    (map-set active-by-user-and-collection { user: tx-sender, collection: (contract-of collection) } 
      (unwrap! (as-max-len? (append current-user-active-in-collection id) u5000) (err u6))
    )

    ;; Map-set status-by-id-and-collection
    (ok (map-set status-by-id-and-collection { id: id, collection: (contract-of collection) } 
      { last-claimed-height: block-height, last-claimed-user: tx-sender }
    ))
  )
)

(define-private (filter-out-id (id uint)) 
  (not (is-eq id (var-get helper-uint)))
) 

;;;;;;;;;;;;;;;
;; Buy Tiles ;;
;;;;;;;;;;;;;;;
;; Buy 5 tiles
(define-public (buy-5-tiles)
  (let
    (
      (current-purchased-balance (default-to u0 (map-get? purchased-balance tx-sender)))
      (new-purchased-balance (+ current-purchased-balance u5))
    )

    ;; user sends 2 stx
    (try! (stx-transfer? purchase-5-price tx-sender contract-owner))

    (ok (map-set purchased-balance tx-sender new-purchased-balance))

  )
)

(define-public (buy-25-tiles)
  (let
    (
      (current-purchased-balance (default-to u0 (map-get? purchased-balance tx-sender)))
      (new-purchased-balance (+ current-purchased-balance u25))
    )

    ;; user sends 5 stx
    (try! (stx-transfer? purchase-25-price tx-sender contract-owner))

    (ok (map-set purchased-balance tx-sender new-purchased-balance))
  )
)

(define-public (buy-100-tiles)
  (let
   (
      (current-purchased-balance (default-to u0 (map-get? purchased-balance tx-sender)))
      (new-purchased-balance (+ current-purchased-balance u100))
    )

    ;; user sends 10 stx
    (try! (stx-transfer? purchase-100-price tx-sender contract-owner))

    (ok (map-set purchased-balance tx-sender new-purchased-balance))

  )
)

(define-public (buy-500-tiles)
  (let
    (
      (current-purchased-balance (default-to u0 (map-get? purchased-balance tx-sender)))
      (new-purchased-balance (+ current-purchased-balance u500))
    )

    ;; user sends 10 stx
    (try! (stx-transfer? purchase-500-price tx-sender contract-owner))

    (ok (map-set purchased-balance tx-sender new-purchased-balance))

  )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Spending Tiles Funcs ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;
;; Spend Tile ;;
;;;;;;;;;;;;;;;;
;; @desc - Function that canvas contract calls to spend a tile
(define-public (spend-tile) 
  (let 
    (
      (purchase-balance (default-to u0 (map-get? purchased-balance tx-sender)))
      (generated-balance (unwrap! (get-generated-balance) (err u0)))
      (total-balance (+ purchase-balance generated-balance))
      (current-user-active-generations (filter remove-inactive-generations (var-get whitelisted-collections)))
      (first-collection-active (unwrap! (element-at current-user-active-generations u0) (err u1)))
      (first-collection-blocks-per-tile (unwrap! (map-get? whitelisted-collection-blocks-per-tile-generation first-collection-active) (err u5)))
      (first-id-active (default-to u0 (element-at (unwrap! (map-get? active-by-user-and-collection {user: tx-sender, collection: first-collection-active}) (err u3)) u0)))
      (first-id-status (unwrap! (map-get? status-by-id-and-collection {collection: first-collection-active, id: first-id-active}) (err u4)))
      (first-id-last-claimed-height (get last-claimed-height first-id-status))
    )

    ;; Assert user has at least 1 tile 
    (asserts! (> total-balance u0) (err u0))

    ;; Assert contract caller is canvas contract
    (asserts! (is-eq contract-caller .canvas) (err u1))

    ;; By default we will use a generated tile
    (ok (if (is-eq generated-balance u0)

      ;; If user has no generated tiles, use a purchased tile
      (map-set purchased-balance tx-sender  (- purchase-balance u1))

      ;; If user has generated tiles, use the first collection with the first full height
      (map-set status-by-id-and-collection {collection: first-collection-active, id: first-id-active} {
        last-claimed-height: (- first-id-last-claimed-height first-collection-blocks-per-tile),
        last-claimed-user: tx-sender
      })

    ))
  )
)

;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;
;;;; Admin Funcs ;;;;
;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;

;; Add Whitelist Collection
;; @desc - Add a collection to the whitelist
;; @param - collection
(define-public (add-whitelist-collection (collection principal) (blocks-per-tile uint))
  (let
    (
      (current-admins (var-get admins))
      (current-whitelisted-collections (var-get whitelisted-collections))
    )
    
    ;; Assert tx-sender is an admin
    (asserts! (is-some (index-of current-admins tx-sender)) (err u2))

    ;; Assert collection is not already whitelisted
    (asserts! (is-none (index-of current-whitelisted-collections collection)) (err u3))

    ;; Set collection block-per-tile-generation rate
    (map-set whitelisted-collection-blocks-per-tile-generation collection blocks-per-tile)

    ;; Add collection to whitelist
    (ok (var-set whitelisted-collections (unwrap! (as-max-len? (append current-whitelisted-collections collection) u100) (err u4))))

  )
)

;; Remove Whitelist Collection
;; @desc - Remove a collection from the whitelist
;; @param - collection
(define-public (remove-whitelist-collection (collection principal))
  (let
    (
      (current-admins (var-get admins))
      (current-whitelisted-collections (var-get whitelisted-collections))
    )
    
    ;; Assert tx-sender is an admin
    (asserts! (is-some (index-of current-admins tx-sender)) (err u2))

    ;; Assert collection is whitelisted
    (asserts! (is-some (index-of current-whitelisted-collections collection)) (err u3))

    ;; Var-set helper principal
    (var-set helper-principal collection)

    ;; Remove collection from whitelist
    (ok (var-set whitelisted-collections (filter remove-principal-from-list current-admins)))

  )
)

;; Helper function to remove a principal from a list
(define-private (remove-principal-from-list (collection principal))
  (not (is-eq collection (var-get helper-principal)))
)

;; Add Admin
;; @desc - Add an admin
;; @param - admin
(define-public (add-admin (admin principal))
  (let
    (
      (current-admins (var-get admins))
    )
    
    ;; Assert tx-sender is an admin
    (asserts! (is-some (index-of current-admins tx-sender)) (err u2))

    ;; Assert admin is not already an admin
    (asserts! (is-none (index-of current-admins admin)) (err u5))

    ;; Add admin
    (ok (var-set admins (unwrap! (as-max-len? (append current-admins admin) u10) (err u6))))

  )
)
