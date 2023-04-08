;; Board
;; Contract that defines & control the board
;; Written by StrataLabs

;; The Board
;; The Built On STX NFT tile canvas (what was previously the BadgerBoard)
;; The Board represents a 5000-tile canvas that select collections with generated tiles can interact with by placing colored tiles on the board
;; For each tile, the Board stores a history of the tile's color & the placer's principal
;; Approximately once a month (every 4320 blocks), the Board will be reset to a blank canvas

;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Cons, Vars & Maps ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;
;;; Cons ;;;
;;;;;;;;;;;;

;; Use SIP-09 NFT trait
;; (use-trait nft-collection 'SP3D03X5BHMNSAAW71NN7BQRMV4DW2G4JB3MZAGJ8.sip-09.nft-trait)
(use-trait nft-collection .sip-09.nft-trait)

;; The max amount of possible tiles on the board
(define-constant tiles-in-board u5000)

;; Deployer principal
(define-constant deployer tx-sender)

;; Replacement fee (25 STX in microSTX) for replacing a tile
(define-constant replacement-fee u25000000)

;; Board duration in blocks (4320 blocks = 1 month)
(define-constant board-duration u4320)

;; Three days in blocks
(define-constant three-days u432)

;; Reward height (432 divided by 6)
(define-constant reward-height u432)


;;;;;;;;;;;;
;;; Vars ;;;
;;;;;;;;;;;;

;; Var-helper to transfer earnings
(define-data-var stx-amount uint u0)

;; Badger collections
(define-data-var badger-collections (list 10 principal) (list 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.baby-badgers))

;; Var that keeps track of the active board index
(define-data-var board-index uint u1)

;; Var that keeps track of helper principal
;;(define-data-var helper-principal <nft-collection> .nft-a)

(define-data-var helper-uint uint u0)

;; Var that keeps tracks of admin principals
(define-data-var admins (list 8 principal) (list deployer))

;; Map that keeps track of a tile's history for a specific board
(define-map tile-history {board: uint, tile: uint} (list 25 {color: (string-ascii 6), placer: principal}))

;; Map that keeps track of the last time an item's tiles was placed & when
(define-map last-used-tile {board: uint, collection: principal, item: uint} (list 100 {last-placed-height: uint, last-placed-amount: uint}))

;; Map that keeps track of current board whitelisted collections
(define-map board-meta uint {
  end-height: uint,
  minted: bool,
  placed-tiles: (list 5000 uint),
  ;; This property below (tile-placed) needs to be implemented since that's what we're using as the payout
  tile-placers: (list 500 principal),
  whitelisted-collections: (list 10 principal)
})

;; Map that keeps track of number of placed tiles by principal and board
(define-map tiles-placed-per-principal-per-board {placer: principal, board: uint} uint)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; Read-Only Functions ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Get the current board index
(define-read-only (get-board-index)
  (var-get board-index)
)

;; Get current board meta
(define-read-only (get-board-meta (index uint))
  (map-get? board-meta index)
)

;; Get current board time remaining
(define-read-only (get-board-time-remaining (index uint))
  (let 
    (
      (time-to-end (unwrap! (get end-height (map-get? board-meta index)) (err "err-no-board")))
      (time-passed (- time-to-end block-height))
    )

    (ok 
      (- time-to-end block-height)
    )             
  )
)

;; Get tile meta for a specific board
(define-read-only (get-tile-history (tile-param uint))
  (map-get? tile-history {board: (var-get board-index), tile: tile-param})
)

(define-read-only (get-board-meta-tile-placers (index uint))
  (get tile-placers (map-get? board-meta index))
)

(define-read-only (get-board-placer-tiles (placer principal) (board uint))
 (default-to u0 (map-get? tiles-placed-per-principal-per-board {placer: placer, board: (var-get board-index)}))
)

(define-read-only (get-board-placers (board uint))
  (ok (unwrap! (get tile-placers (map-get? board-meta board)) (err "err-unwrap")))
)


;; Get item tile balance
;; Balance for each item in a collection (current block height - last used block height) / 72 with a max value of 6 (~3 days before tile expires) - tiles placed in last 3 days.
(define-read-only (get-all-items-balance-per-collection-1 (items (list 10000 uint)))
    (ok (print (map get-all-items-balance-helper-1 items)))
)

(define-private (get-all-items-balance-helper-1 (item uint))
  (ok 
      (get-item-balance (unwrap! (element-at (unwrap! (get whitelisted-collections (map-get? board-meta (var-get board-index))) (err "err-list")) u0) (err "err-unwrap")) item)
  )
)

(define-read-only (get-all-items-balance-per-collection-2 (items (list 10000 uint)))
    (ok (print (map get-all-items-balance-helper-2 items)))
)

(define-private (get-all-items-balance-helper-2 (item uint))
  (ok 
      (get-item-balance (unwrap! (element-at (unwrap! (get whitelisted-collections (map-get? board-meta (var-get board-index))) (err "err-list")) u1) (err "err-unwrap")) item)
  )
)


(define-read-only (get-item-balance (collection principal) (item uint))
    (let 
        (
            ;; List of all times user has placed tiles for this item for current board
            (current-recently-placed (default-to (list ) (map-get? last-used-tile {board: (var-get board-index), collection: collection, item: item})))
            ;; Filter to all placements in last 3 days
            (current-recently-placed-filtered (filter filter-from-all-placements-to-recent-placements current-recently-placed))
            ;; Fold from all placements in last 3 days to final total amount of tiles placed in last 3 days
            (current-recently-placed-folded (fold fold-from-all-placements-to-recent-placements current-recently-placed-filtered u0))
        )
        ;; Badger collection - 12 tiles (x2) ; Other collections - 6 tiles (x1)
        (if (is-some (index-of (var-get badger-collections) collection))
          (- u12 current-recently-placed-folded)
          (- u6 current-recently-placed-folded)
        )
    )
)

;; Private helper function to filter out all placements NOT in the last 3 days
(define-private (filter-from-all-placements-to-recent-placements (placement {last-placed-height: uint, last-placed-amount: uint}))
  (if (> (+ (get last-placed-height placement) three-days) block-height)
    true
    false
  )
)

;; Private helper function to fold from all placements in last 3 days to total amount of tiles placed in last 3 days - any placement with more than 1 tile needs to be further checked to see if some of the tiles were placed in the last 3 days
(define-private (fold-from-all-placements-to-recent-placements (placement {last-placed-height: uint, last-placed-amount: uint}) (total uint))
  (if (> (get last-placed-amount placement) u1)
    ;; Placement has more than 1 tile - further check to see if all, or just some of the tiles were placed in the last 3 days
    (+ total (/ (- (get last-placed-height placement) (- block-height three-days)) reward-height))
    ;; Placement has 1 tile - return 1
    (+ total u1)
  )
)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; Core Placement Functions ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Place a tile on the board
;; @desc - Core function for placing a tile on the current board
;; @param - Item (uint) - The item ID of the item being placed, Collection (principal) - The collection the item belongs to, Tile (uint) - The tile ID being placed, Color (string-ascii 6) - The color of the tile being placed
(define-public (place-tile (item uint) (collection <nft-collection>) (tile-position uint) (color (string-ascii 6)))
  (let
    (
      (current-board-meta (unwrap! (get-board-meta (var-get board-index)) (err "err-no-board-meta")))
      (current-board-end-height (get end-height current-board-meta))
      (current-board-placed-tiles (get placed-tiles current-board-meta))
      (current-board-whitelisted-collections (get whitelisted-collections current-board-meta))
      (current-last-used-tile (map-get? last-used-tile {board: (var-get board-index), collection: (contract-of collection), item: item}))
      (current-item-balance (get-item-balance (contract-of collection) item))
      (current-nft-owner (unwrap! (contract-call? collection get-owner item) (err "err-nft-get-owner")))
      (current-tile-placers (get tile-placers current-board-meta))
      (principal-number-tiles (default-to u0 (map-get? tiles-placed-per-principal-per-board {placer: tx-sender, board: (var-get board-index)})))
    )

    ;; Assert that the item balance is greater than 0
    (asserts! (> current-item-balance u0) (err "err-item-balance-zero"))

    ;; Assert the current NFT owner
    (asserts! (is-eq current-nft-owner (some tx-sender)) (err "err-nft-get-owner"))

    ;; Assert that tile metadata is none
    (asserts! (is-none (get-tile-history tile-position)) (err "err-tile-meta-exists"))

    ;; Assert that submitted collection is whitelisted
    (asserts! (or (is-some (index-of current-board-whitelisted-collections (contract-of collection))) (is-some (index-of (var-get badger-collections) (contract-of collection)))) (err "err-collection-not-whitelisted"))

    ;; Assert that the tile position is valid (less than the max amount of tiles on the board)
    (asserts! (< tile-position u5000) (err "err-tile-position-invalid"))

    ;; Assert that block height is less than the end height of the board
    (asserts! (< block-height current-board-end-height) (err "err-block-height-invalid"))

    ;; Map set tile meta
    (map-set tile-history {board: (var-get board-index), tile: tile-position} (list {color: color, placer: tx-sender}))

    ;; Map set last used tile
    (match current-last-used-tile
      last-used-tile-list
        (map-set last-used-tile {board: (var-get board-index), collection: (contract-of collection), item: item} (unwrap! (as-max-len? (append last-used-tile-list {last-placed-height: block-height, last-placed-amount: u1}) u100) (err "err-list-overflow")))
      (map-set last-used-tile {board: (var-get board-index), collection: (contract-of collection), item: item} (list {last-placed-height: block-height, last-placed-amount: u1}))
    )

    (if (is-some (index-of current-tile-placers tx-sender)) 

      (begin 

        ;; map set the tiles placed by principal and board
        (map-set tiles-placed-per-principal-per-board {placer: tx-sender, board: (var-get board-index)} (+ principal-number-tiles u1))

        ;; Map set board-meta by merging everything with a new placed-tiles value
        (map-set board-meta (var-get board-index) 
          (merge 
            current-board-meta 
            {
              placed-tiles: (unwrap! (as-max-len? (append current-board-placed-tiles item) u5000) (err "err-placed-tiles-overflow")),
            }
          )
        )
        
      ) 
      
      ;; Map set board-meta by merging everything with a new placed-tiles value and the tile placers
      (map-set board-meta (var-get board-index) 
        (merge 
          current-board-meta 
          {
            placed-tiles: (unwrap! (as-max-len? (append current-board-placed-tiles item) u5000) (err "err-placed-tiles-overflow")),
            tile-placers: (unwrap! (as-max-len? (append current-tile-placers tx-sender) u500) (err "err-unwrap"))
          }
        )
      )
    )
    
    (ok (map-set tiles-placed-per-principal-per-board {placer: tx-sender, board: (var-get board-index)} (+ principal-number-tiles u1)))

  )
)

;; Function to place many tiles at once
;; @desc - Function to place many tiles at once
;; @param - Tile-Placement (list 1000 {tile-position: uint, item: uint, collection: principal, color: (string-ascii 6)}) - A list of tile placements
;; (define-public (place-tiles (tile-placements (list 2 {tile-position: uint, item: uint, color: (string-ascii 6)})) (tiles-collection <nft-collection>))
;;   (let 
;;     (
;;       (initial-trait-list (list 250 tiles-collection))
;;     )
;;     (ok true)
;;   )
;;   ;; (begin 
;;   ;;   ;; var-set helper-principal to tiles-collection
;;   ;;   (var-set helper-principal tiles-collection)
;;   ;;   (ok (map map-to-place-each-tile tile-placements)) 
;;   ;; )
;; )


;; Notes for Pato
;; Working with traits is notoriously a headache which makes using map/fold extremely challenging
;; Specifically, traits can be *passed down* but CANT be resurfaced
;; They also can't get pulled out from tuples :/
(define-public (place-tiles-many-collections (tile-placements (list 250 {tile-position: uint, item: uint, color: (string-ascii 6)})) 
;; (collection-1 (optional <nft-collection>))
;; (collection-2 (optional <nft-collection>))
;; (collection-3 (optional <nft-collection>))
;; (collection-4 (optional <nft-collection>))
;; (collection-5 (optional <nft-collection>))
;; (collection-6 (optional <nft-collection>))
;; (collection-7 (optional <nft-collection>))
;; (collection-8 (optional <nft-collection>))
;; (collection-9 (optional <nft-collection>))
;; (collection-10 (optional <nft-collection>))

(collection-1 <nft-collection>)
(collection-2 <nft-collection>)
(collection-3 <nft-collection>)
(collection-4 <nft-collection>)
(collection-5 <nft-collection>)
(collection-6 <nft-collection>)
(collection-7 <nft-collection>)
(collection-8 <nft-collection>)
(collection-9 <nft-collection>)
(collection-10 <nft-collection>)

)
  (let
    (
      (trait-list-1 (list 
        collection-1 collection-1 collection-1 collection-1 collection-1 collection-1 collection-1 collection-1 collection-1 collection-1
        collection-1 collection-1 collection-1 collection-1 collection-1 collection-1 collection-1 collection-1 collection-1 collection-1
        collection-1 collection-1 collection-1 collection-1 collection-1 collection-1 collection-1 collection-1 collection-1 collection-1
        collection-1 collection-1 collection-1 collection-1 collection-1 collection-1 collection-1 collection-1 collection-1 collection-1
        collection-1 collection-1 collection-1 collection-1 collection-1 collection-1 collection-1 collection-1 collection-1 collection-1
        collection-1 collection-1 collection-1 collection-1 collection-1 collection-1 collection-1 collection-1 collection-1 collection-1
        collection-1 collection-1 collection-1 collection-1 collection-1 collection-1 collection-1 collection-1 collection-1 collection-1
        collection-1 collection-1 collection-1 collection-1 collection-1 collection-1 collection-1 collection-1 collection-1 collection-1
        collection-1 collection-1 collection-1 collection-1 collection-1 collection-1 collection-1 collection-1 collection-1 collection-1
        collection-1 collection-1 collection-1 collection-1 collection-1 collection-1 collection-1 collection-1 collection-1 collection-1
        collection-1 collection-1 collection-1 collection-1 collection-1 collection-1 collection-1 collection-1 collection-1 collection-1
        collection-1 collection-1 collection-1 collection-1 collection-1 collection-1 collection-1 collection-1 collection-1 collection-1
        collection-1 collection-1 collection-1 collection-1 collection-1 collection-1 collection-1 collection-1 collection-1 collection-1
        collection-1 collection-1 collection-1 collection-1 collection-1 collection-1 collection-1 collection-1 collection-1 collection-1
        collection-1 collection-1 collection-1 collection-1 collection-1 collection-1 collection-1 collection-1 collection-1 collection-1
        collection-1 collection-1 collection-1 collection-1 collection-1 collection-1 collection-1 collection-1 collection-1 collection-1
        collection-1 collection-1 collection-1 collection-1 collection-1 collection-1 collection-1 collection-1 collection-1 collection-1
        collection-1 collection-1 collection-1 collection-1 collection-1 collection-1 collection-1 collection-1 collection-1 collection-1
        collection-1 collection-1 collection-1 collection-1 collection-1 collection-1 collection-1 collection-1 collection-1 collection-1
        collection-1 collection-1 collection-1 collection-1 collection-1 collection-1 collection-1 collection-1 collection-1 collection-1
        collection-1 collection-1 collection-1 collection-1 collection-1 collection-1 collection-1 collection-1 collection-1 collection-1
        collection-1 collection-1 collection-1 collection-1 collection-1 collection-1 collection-1 collection-1 collection-1 collection-1
        collection-1 collection-1 collection-1 collection-1 collection-1 collection-1 collection-1 collection-1 collection-1 collection-1
        collection-1 collection-1 collection-1 collection-1 collection-1 collection-1 collection-1 collection-1 collection-1 collection-1
        collection-1 collection-1 collection-1 collection-1 collection-1 collection-1 collection-1 collection-1 collection-1 collection-1
      ))
      (trait-list-2 (list 
        collection-2 collection-2 collection-2 collection-2 collection-2 collection-2 collection-2 collection-2 collection-2 collection-2
        collection-2 collection-2 collection-2 collection-2 collection-2 collection-2 collection-2 collection-2 collection-2 collection-2
        collection-2 collection-2 collection-2 collection-2 collection-2 collection-2 collection-2 collection-2 collection-2 collection-2
        collection-2 collection-2 collection-2 collection-2 collection-2 collection-2 collection-2 collection-2 collection-2 collection-2
        collection-2 collection-2 collection-2 collection-2 collection-2 collection-2 collection-2 collection-2 collection-2 collection-2
        collection-2 collection-2 collection-2 collection-2 collection-2 collection-2 collection-2 collection-2 collection-2 collection-2
        collection-2 collection-2 collection-2 collection-2 collection-2 collection-2 collection-2 collection-2 collection-2 collection-2
        collection-2 collection-2 collection-2 collection-2 collection-2 collection-2 collection-2 collection-2 collection-2 collection-2
        collection-2 collection-2 collection-2 collection-2 collection-2 collection-2 collection-2 collection-2 collection-2 collection-2
        collection-2 collection-2 collection-2 collection-2 collection-2 collection-2 collection-2 collection-2 collection-2 collection-2
        collection-2 collection-2 collection-2 collection-2 collection-2 collection-2 collection-2 collection-2 collection-2 collection-2
        collection-2 collection-2 collection-2 collection-2 collection-2 collection-2 collection-2 collection-2 collection-2 collection-2
        collection-2 collection-2 collection-2 collection-2 collection-2 collection-2 collection-2 collection-2 collection-2 collection-2
        collection-2 collection-2 collection-2 collection-2 collection-2 collection-2 collection-2 collection-2 collection-2 collection-2
        collection-2 collection-2 collection-2 collection-2 collection-2 collection-2 collection-2 collection-2 collection-2 collection-2
        collection-2 collection-2 collection-2 collection-2 collection-2 collection-2 collection-2 collection-2 collection-2 collection-2
        collection-2 collection-2 collection-2 collection-2 collection-2 collection-2 collection-2 collection-2 collection-2 collection-2
        collection-2 collection-2 collection-2 collection-2 collection-2 collection-2 collection-2 collection-2 collection-2 collection-2
        collection-2 collection-2 collection-2 collection-2 collection-2 collection-2 collection-2 collection-2 collection-2 collection-2
        collection-2 collection-2 collection-2 collection-2 collection-2 collection-2 collection-2 collection-2 collection-2 collection-2
        collection-2 collection-2 collection-2 collection-2 collection-2 collection-2 collection-2 collection-2 collection-2 collection-2
        collection-2 collection-2 collection-2 collection-2 collection-2 collection-2 collection-2 collection-2 collection-2 collection-2
        collection-2 collection-2 collection-2 collection-2 collection-2 collection-2 collection-2 collection-2 collection-2 collection-2
        collection-2 collection-2 collection-2 collection-2 collection-2 collection-2 collection-2 collection-2 collection-2 collection-2
        collection-2 collection-2 collection-2 collection-2 collection-2 collection-2 collection-2 collection-2 collection-2 collection-2
      ))
      (trait-list-3 (list 
        collection-3 collection-3 collection-3 collection-3 collection-3 collection-3 collection-3 collection-3 collection-3 collection-3
        collection-3 collection-3 collection-3 collection-3 collection-3 collection-3 collection-3 collection-3 collection-3 collection-3
        collection-3 collection-3 collection-3 collection-3 collection-3 collection-3 collection-3 collection-3 collection-3 collection-3
        collection-3 collection-3 collection-3 collection-3 collection-3 collection-3 collection-3 collection-3 collection-3 collection-3
        collection-3 collection-3 collection-3 collection-3 collection-3 collection-3 collection-3 collection-3 collection-3 collection-3
        collection-3 collection-3 collection-3 collection-3 collection-3 collection-3 collection-3 collection-3 collection-3 collection-3
        collection-3 collection-3 collection-3 collection-3 collection-3 collection-3 collection-3 collection-3 collection-3 collection-3
        collection-3 collection-3 collection-3 collection-3 collection-3 collection-3 collection-3 collection-3 collection-3 collection-3
        collection-3 collection-3 collection-3 collection-3 collection-3 collection-3 collection-3 collection-3 collection-3 collection-3
        collection-3 collection-3 collection-3 collection-3 collection-3 collection-3 collection-3 collection-3 collection-3 collection-3
        collection-3 collection-3 collection-3 collection-3 collection-3 collection-3 collection-3 collection-3 collection-3 collection-3
        collection-3 collection-3 collection-3 collection-3 collection-3 collection-3 collection-3 collection-3 collection-3 collection-3
        collection-3 collection-3 collection-3 collection-3 collection-3 collection-3 collection-3 collection-3 collection-3 collection-3
        collection-3 collection-3 collection-3 collection-3 collection-3 collection-3 collection-3 collection-3 collection-3 collection-3
        collection-3 collection-3 collection-3 collection-3 collection-3 collection-3 collection-3 collection-3 collection-3 collection-3
        collection-3 collection-3 collection-3 collection-3 collection-3 collection-3 collection-3 collection-3 collection-3 collection-3
        collection-3 collection-3 collection-3 collection-3 collection-3 collection-3 collection-3 collection-3 collection-3 collection-3
        collection-3 collection-3 collection-3 collection-3 collection-3 collection-3 collection-3 collection-3 collection-3 collection-3
        collection-3 collection-3 collection-3 collection-3 collection-3 collection-3 collection-3 collection-3 collection-3 collection-3
        collection-3 collection-3 collection-3 collection-3 collection-3 collection-3 collection-3 collection-3 collection-3 collection-3
        collection-3 collection-3 collection-3 collection-3 collection-3 collection-3 collection-3 collection-3 collection-3 collection-3
        collection-3 collection-3 collection-3 collection-3 collection-3 collection-3 collection-3 collection-3 collection-3 collection-3
        collection-3 collection-3 collection-3 collection-3 collection-3 collection-3 collection-3 collection-3 collection-3 collection-3
        collection-3 collection-3 collection-3 collection-3 collection-3 collection-3 collection-3 collection-3 collection-3 collection-3
        collection-3 collection-3 collection-3 collection-3 collection-3 collection-3 collection-3 collection-3 collection-3 collection-3
      ))
      (trait-list-4 (list 
        collection-4 collection-4 collection-4 collection-4 collection-4 collection-4 collection-4 collection-4 collection-4 collection-4
        collection-4 collection-4 collection-4 collection-4 collection-4 collection-4 collection-4 collection-4 collection-4 collection-4
        collection-4 collection-4 collection-4 collection-4 collection-4 collection-4 collection-4 collection-4 collection-4 collection-4
        collection-4 collection-4 collection-4 collection-4 collection-4 collection-4 collection-4 collection-4 collection-4 collection-4
        collection-4 collection-4 collection-4 collection-4 collection-4 collection-4 collection-4 collection-4 collection-4 collection-4
        collection-4 collection-4 collection-4 collection-4 collection-4 collection-4 collection-4 collection-4 collection-4 collection-4
        collection-4 collection-4 collection-4 collection-4 collection-4 collection-4 collection-4 collection-4 collection-4 collection-4
        collection-4 collection-4 collection-4 collection-4 collection-4 collection-4 collection-4 collection-4 collection-4 collection-4
        collection-4 collection-4 collection-4 collection-4 collection-4 collection-4 collection-4 collection-4 collection-4 collection-4
        collection-4 collection-4 collection-4 collection-4 collection-4 collection-4 collection-4 collection-4 collection-4 collection-4
        collection-4 collection-4 collection-4 collection-4 collection-4 collection-4 collection-4 collection-4 collection-4 collection-4
        collection-4 collection-4 collection-4 collection-4 collection-4 collection-4 collection-4 collection-4 collection-4 collection-4
        collection-4 collection-4 collection-4 collection-4 collection-4 collection-4 collection-4 collection-4 collection-4 collection-4
        collection-4 collection-4 collection-4 collection-4 collection-4 collection-4 collection-4 collection-4 collection-4 collection-4
        collection-4 collection-4 collection-4 collection-4 collection-4 collection-4 collection-4 collection-4 collection-4 collection-4
        collection-4 collection-4 collection-4 collection-4 collection-4 collection-4 collection-4 collection-4 collection-4 collection-4
        collection-4 collection-4 collection-4 collection-4 collection-4 collection-4 collection-4 collection-4 collection-4 collection-4
        collection-4 collection-4 collection-4 collection-4 collection-4 collection-4 collection-4 collection-4 collection-4 collection-4
        collection-4 collection-4 collection-4 collection-4 collection-4 collection-4 collection-4 collection-4 collection-4 collection-4
        collection-4 collection-4 collection-4 collection-4 collection-4 collection-4 collection-4 collection-4 collection-4 collection-4
        collection-4 collection-4 collection-4 collection-4 collection-4 collection-4 collection-4 collection-4 collection-4 collection-4
        collection-4 collection-4 collection-4 collection-4 collection-4 collection-4 collection-4 collection-4 collection-4 collection-4
        collection-4 collection-4 collection-4 collection-4 collection-4 collection-4 collection-4 collection-4 collection-4 collection-4
        collection-4 collection-4 collection-4 collection-4 collection-4 collection-4 collection-4 collection-4 collection-4 collection-4
        collection-4 collection-4 collection-4 collection-4 collection-4 collection-4 collection-4 collection-4 collection-4 collection-4
      ))
      (trait-list-5 (list 
        collection-5 collection-5 collection-5 collection-5 collection-5 collection-5 collection-5 collection-5 collection-5 collection-5
        collection-5 collection-5 collection-5 collection-5 collection-5 collection-5 collection-5 collection-5 collection-5 collection-5
        collection-5 collection-5 collection-5 collection-5 collection-5 collection-5 collection-5 collection-5 collection-5 collection-5
        collection-5 collection-5 collection-5 collection-5 collection-5 collection-5 collection-5 collection-5 collection-5 collection-5
        collection-5 collection-5 collection-5 collection-5 collection-5 collection-5 collection-5 collection-5 collection-5 collection-5
        collection-5 collection-5 collection-5 collection-5 collection-5 collection-5 collection-5 collection-5 collection-5 collection-5
        collection-5 collection-5 collection-5 collection-5 collection-5 collection-5 collection-5 collection-5 collection-5 collection-5
        collection-5 collection-5 collection-5 collection-5 collection-5 collection-5 collection-5 collection-5 collection-5 collection-5
        collection-5 collection-5 collection-5 collection-5 collection-5 collection-5 collection-5 collection-5 collection-5 collection-5
        collection-5 collection-5 collection-5 collection-5 collection-5 collection-5 collection-5 collection-5 collection-5 collection-5
        collection-5 collection-5 collection-5 collection-5 collection-5 collection-5 collection-5 collection-5 collection-5 collection-5
        collection-5 collection-5 collection-5 collection-5 collection-5 collection-5 collection-5 collection-5 collection-5 collection-5
        collection-5 collection-5 collection-5 collection-5 collection-5 collection-5 collection-5 collection-5 collection-5 collection-5
        collection-5 collection-5 collection-5 collection-5 collection-5 collection-5 collection-5 collection-5 collection-5 collection-5
        collection-5 collection-5 collection-5 collection-5 collection-5 collection-5 collection-5 collection-5 collection-5 collection-5
        collection-5 collection-5 collection-5 collection-5 collection-5 collection-5 collection-5 collection-5 collection-5 collection-5
        collection-5 collection-5 collection-5 collection-5 collection-5 collection-5 collection-5 collection-5 collection-5 collection-5
        collection-5 collection-5 collection-5 collection-5 collection-5 collection-5 collection-5 collection-5 collection-5 collection-5
        collection-5 collection-5 collection-5 collection-5 collection-5 collection-5 collection-5 collection-5 collection-5 collection-5
        collection-5 collection-5 collection-5 collection-5 collection-5 collection-5 collection-5 collection-5 collection-5 collection-5
        collection-5 collection-5 collection-5 collection-5 collection-5 collection-5 collection-5 collection-5 collection-5 collection-5
        collection-5 collection-5 collection-5 collection-5 collection-5 collection-5 collection-5 collection-5 collection-5 collection-5
        collection-5 collection-5 collection-5 collection-5 collection-5 collection-5 collection-5 collection-5 collection-5 collection-5
        collection-5 collection-5 collection-5 collection-5 collection-5 collection-5 collection-5 collection-5 collection-5 collection-5
        collection-5 collection-5 collection-5 collection-5 collection-5 collection-5 collection-5 collection-5 collection-5 collection-5
      ))
      (trait-list-6 (list 
        collection-6 collection-6 collection-6 collection-6 collection-6 collection-6 collection-6 collection-6 collection-6 collection-6
        collection-6 collection-6 collection-6 collection-6 collection-6 collection-6 collection-6 collection-6 collection-6 collection-6
        collection-6 collection-6 collection-6 collection-6 collection-6 collection-6 collection-6 collection-6 collection-6 collection-6
        collection-6 collection-6 collection-6 collection-6 collection-6 collection-6 collection-6 collection-6 collection-6 collection-6
        collection-6 collection-6 collection-6 collection-6 collection-6 collection-6 collection-6 collection-6 collection-6 collection-6
        collection-6 collection-6 collection-6 collection-6 collection-6 collection-6 collection-6 collection-6 collection-6 collection-6
        collection-6 collection-6 collection-6 collection-6 collection-6 collection-6 collection-6 collection-6 collection-6 collection-6
        collection-6 collection-6 collection-6 collection-6 collection-6 collection-6 collection-6 collection-6 collection-6 collection-6
        collection-6 collection-6 collection-6 collection-6 collection-6 collection-6 collection-6 collection-6 collection-6 collection-6
        collection-6 collection-6 collection-6 collection-6 collection-6 collection-6 collection-6 collection-6 collection-6 collection-6
        collection-6 collection-6 collection-6 collection-6 collection-6 collection-6 collection-6 collection-6 collection-6 collection-6
        collection-6 collection-6 collection-6 collection-6 collection-6 collection-6 collection-6 collection-6 collection-6 collection-6
        collection-6 collection-6 collection-6 collection-6 collection-6 collection-6 collection-6 collection-6 collection-6 collection-6
        collection-6 collection-6 collection-6 collection-6 collection-6 collection-6 collection-6 collection-6 collection-6 collection-6
        collection-6 collection-6 collection-6 collection-6 collection-6 collection-6 collection-6 collection-6 collection-6 collection-6
        collection-6 collection-6 collection-6 collection-6 collection-6 collection-6 collection-6 collection-6 collection-6 collection-6
        collection-6 collection-6 collection-6 collection-6 collection-6 collection-6 collection-6 collection-6 collection-6 collection-6
        collection-6 collection-6 collection-6 collection-6 collection-6 collection-6 collection-6 collection-6 collection-6 collection-6
        collection-6 collection-6 collection-6 collection-6 collection-6 collection-6 collection-6 collection-6 collection-6 collection-6
        collection-6 collection-6 collection-6 collection-6 collection-6 collection-6 collection-6 collection-6 collection-6 collection-6
        collection-6 collection-6 collection-6 collection-6 collection-6 collection-6 collection-6 collection-6 collection-6 collection-6
        collection-6 collection-6 collection-6 collection-6 collection-6 collection-6 collection-6 collection-6 collection-6 collection-6
        collection-6 collection-6 collection-6 collection-6 collection-6 collection-6 collection-6 collection-6 collection-6 collection-6
        collection-6 collection-6 collection-6 collection-6 collection-6 collection-6 collection-6 collection-6 collection-6 collection-6
        collection-6 collection-6 collection-6 collection-6 collection-6 collection-6 collection-6 collection-6 collection-6 collection-6
      ))
      (trait-list-7 (list 
        collection-7 collection-7 collection-7 collection-7 collection-7 collection-7 collection-7 collection-7 collection-7 collection-7
        collection-7 collection-7 collection-7 collection-7 collection-7 collection-7 collection-7 collection-7 collection-7 collection-7
        collection-7 collection-7 collection-7 collection-7 collection-7 collection-7 collection-7 collection-7 collection-7 collection-7
        collection-7 collection-7 collection-7 collection-7 collection-7 collection-7 collection-7 collection-7 collection-7 collection-7
        collection-7 collection-7 collection-7 collection-7 collection-7 collection-7 collection-7 collection-7 collection-7 collection-7
        collection-7 collection-7 collection-7 collection-7 collection-7 collection-7 collection-7 collection-7 collection-7 collection-7
        collection-7 collection-7 collection-7 collection-7 collection-7 collection-7 collection-7 collection-7 collection-7 collection-7
        collection-7 collection-7 collection-7 collection-7 collection-7 collection-7 collection-7 collection-7 collection-7 collection-7
        collection-7 collection-7 collection-7 collection-7 collection-7 collection-7 collection-7 collection-7 collection-7 collection-7
        collection-7 collection-7 collection-7 collection-7 collection-7 collection-7 collection-7 collection-7 collection-7 collection-7
        collection-7 collection-7 collection-7 collection-7 collection-7 collection-7 collection-7 collection-7 collection-7 collection-7
        collection-7 collection-7 collection-7 collection-7 collection-7 collection-7 collection-7 collection-7 collection-7 collection-7
        collection-7 collection-7 collection-7 collection-7 collection-7 collection-7 collection-7 collection-7 collection-7 collection-7
        collection-7 collection-7 collection-7 collection-7 collection-7 collection-7 collection-7 collection-7 collection-7 collection-7
        collection-7 collection-7 collection-7 collection-7 collection-7 collection-7 collection-7 collection-7 collection-7 collection-7
        collection-7 collection-7 collection-7 collection-7 collection-7 collection-7 collection-7 collection-7 collection-7 collection-7
        collection-7 collection-7 collection-7 collection-7 collection-7 collection-7 collection-7 collection-7 collection-7 collection-7
        collection-7 collection-7 collection-7 collection-7 collection-7 collection-7 collection-7 collection-7 collection-7 collection-7
        collection-7 collection-7 collection-7 collection-7 collection-7 collection-7 collection-7 collection-7 collection-7 collection-7
        collection-7 collection-7 collection-7 collection-7 collection-7 collection-7 collection-7 collection-7 collection-7 collection-7
        collection-7 collection-7 collection-7 collection-7 collection-7 collection-7 collection-7 collection-7 collection-7 collection-7
        collection-7 collection-7 collection-7 collection-7 collection-7 collection-7 collection-7 collection-7 collection-7 collection-7
        collection-7 collection-7 collection-7 collection-7 collection-7 collection-7 collection-7 collection-7 collection-7 collection-7
        collection-7 collection-7 collection-7 collection-7 collection-7 collection-7 collection-7 collection-7 collection-7 collection-7
        collection-7 collection-7 collection-7 collection-7 collection-7 collection-7 collection-7 collection-7 collection-7 collection-7
      ))
      (trait-list-8 (list 
        collection-8 collection-8 collection-8 collection-8 collection-8 collection-8 collection-8 collection-8 collection-8 collection-8
        collection-8 collection-8 collection-8 collection-8 collection-8 collection-8 collection-8 collection-8 collection-8 collection-8
        collection-8 collection-8 collection-8 collection-8 collection-8 collection-8 collection-8 collection-8 collection-8 collection-8
        collection-8 collection-8 collection-8 collection-8 collection-8 collection-8 collection-8 collection-8 collection-8 collection-8
        collection-8 collection-8 collection-8 collection-8 collection-8 collection-8 collection-8 collection-8 collection-8 collection-8
        collection-8 collection-8 collection-8 collection-8 collection-8 collection-8 collection-8 collection-8 collection-8 collection-8
        collection-8 collection-8 collection-8 collection-8 collection-8 collection-8 collection-8 collection-8 collection-8 collection-8
        collection-8 collection-8 collection-8 collection-8 collection-8 collection-8 collection-8 collection-8 collection-8 collection-8
        collection-8 collection-8 collection-8 collection-8 collection-8 collection-8 collection-8 collection-8 collection-8 collection-8
        collection-8 collection-8 collection-8 collection-8 collection-8 collection-8 collection-8 collection-8 collection-8 collection-8
        collection-8 collection-8 collection-8 collection-8 collection-8 collection-8 collection-8 collection-8 collection-8 collection-8
        collection-8 collection-8 collection-8 collection-8 collection-8 collection-8 collection-8 collection-8 collection-8 collection-8
        collection-8 collection-8 collection-8 collection-8 collection-8 collection-8 collection-8 collection-8 collection-8 collection-8
        collection-8 collection-8 collection-8 collection-8 collection-8 collection-8 collection-8 collection-8 collection-8 collection-8
        collection-8 collection-8 collection-8 collection-8 collection-8 collection-8 collection-8 collection-8 collection-8 collection-8
        collection-8 collection-8 collection-8 collection-8 collection-8 collection-8 collection-8 collection-8 collection-8 collection-8
        collection-8 collection-8 collection-8 collection-8 collection-8 collection-8 collection-8 collection-8 collection-8 collection-8
        collection-8 collection-8 collection-8 collection-8 collection-8 collection-8 collection-8 collection-8 collection-8 collection-8
        collection-8 collection-8 collection-8 collection-8 collection-8 collection-8 collection-8 collection-8 collection-8 collection-8
        collection-8 collection-8 collection-8 collection-8 collection-8 collection-8 collection-8 collection-8 collection-8 collection-8
        collection-8 collection-8 collection-8 collection-8 collection-8 collection-8 collection-8 collection-8 collection-8 collection-8
        collection-8 collection-8 collection-8 collection-8 collection-8 collection-8 collection-8 collection-8 collection-8 collection-8
        collection-8 collection-8 collection-8 collection-8 collection-8 collection-8 collection-8 collection-8 collection-8 collection-8
        collection-8 collection-8 collection-8 collection-8 collection-8 collection-8 collection-8 collection-8 collection-8 collection-8
        collection-8 collection-8 collection-8 collection-8 collection-8 collection-8 collection-8 collection-8 collection-8 collection-8
      ))
      (trait-list-9 (list 
        collection-9 collection-9 collection-9 collection-9 collection-9 collection-9 collection-9 collection-9 collection-9 collection-9
        collection-9 collection-9 collection-9 collection-9 collection-9 collection-9 collection-9 collection-9 collection-9 collection-9
        collection-9 collection-9 collection-9 collection-9 collection-9 collection-9 collection-9 collection-9 collection-9 collection-9
        collection-9 collection-9 collection-9 collection-9 collection-9 collection-9 collection-9 collection-9 collection-9 collection-9
        collection-9 collection-9 collection-9 collection-9 collection-9 collection-9 collection-9 collection-9 collection-9 collection-9
        collection-9 collection-9 collection-9 collection-9 collection-9 collection-9 collection-9 collection-9 collection-9 collection-9
        collection-9 collection-9 collection-9 collection-9 collection-9 collection-9 collection-9 collection-9 collection-9 collection-9
        collection-9 collection-9 collection-9 collection-9 collection-9 collection-9 collection-9 collection-9 collection-9 collection-9
        collection-9 collection-9 collection-9 collection-9 collection-9 collection-9 collection-9 collection-9 collection-9 collection-9
        collection-9 collection-9 collection-9 collection-9 collection-9 collection-9 collection-9 collection-9 collection-9 collection-9
        collection-9 collection-9 collection-9 collection-9 collection-9 collection-9 collection-9 collection-9 collection-9 collection-9
        collection-9 collection-9 collection-9 collection-9 collection-9 collection-9 collection-9 collection-9 collection-9 collection-9
        collection-9 collection-9 collection-9 collection-9 collection-9 collection-9 collection-9 collection-9 collection-9 collection-9
        collection-9 collection-9 collection-9 collection-9 collection-9 collection-9 collection-9 collection-9 collection-9 collection-9
        collection-9 collection-9 collection-9 collection-9 collection-9 collection-9 collection-9 collection-9 collection-9 collection-9
        collection-9 collection-9 collection-9 collection-9 collection-9 collection-9 collection-9 collection-9 collection-9 collection-9
        collection-9 collection-9 collection-9 collection-9 collection-9 collection-9 collection-9 collection-9 collection-9 collection-9
        collection-9 collection-9 collection-9 collection-9 collection-9 collection-9 collection-9 collection-9 collection-9 collection-9
        collection-9 collection-9 collection-9 collection-9 collection-9 collection-9 collection-9 collection-9 collection-9 collection-9
        collection-9 collection-9 collection-9 collection-9 collection-9 collection-9 collection-9 collection-9 collection-9 collection-9
        collection-9 collection-9 collection-9 collection-9 collection-9 collection-9 collection-9 collection-9 collection-9 collection-9
        collection-9 collection-9 collection-9 collection-9 collection-9 collection-9 collection-9 collection-9 collection-9 collection-9
        collection-9 collection-9 collection-9 collection-9 collection-9 collection-9 collection-9 collection-9 collection-9 collection-9
        collection-9 collection-9 collection-9 collection-9 collection-9 collection-9 collection-9 collection-9 collection-9 collection-9
        collection-9 collection-9 collection-9 collection-9 collection-9 collection-9 collection-9 collection-9 collection-9 collection-9
      ))
      (trait-list-10 (list 
        collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10
        collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10
        collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10
        collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10
        collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10
        collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10
        collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10
        collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10
        collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10
        collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10
        collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10
        collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10
        collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10
        collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10
        collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10
        collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10
        collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10
        collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10
        collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10
        collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10
        collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10
        collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10
        collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10
        collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10
        collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10
      ))
    )

    ;; Var-set helper-uint to the length of tile-placements passed in parameter
    (var-set helper-uint (len tile-placements))

    ;; Filter initial-tuple-trait-list using the index key & helper-uint 
    ;; Then map the result from a list of tuples to a simple list of traits
    ;; Finally call place-many-helper with the tile-placements & the list of traits
    (ok 
      (begin 
        (print (map place-many-helper-collections tile-placements trait-list-1))
        (print (map place-many-helper-collections tile-placements trait-list-2))
        (print (map place-many-helper-collections tile-placements trait-list-3))
        (print (map place-many-helper-collections tile-placements trait-list-4))
        (print (map place-many-helper-collections tile-placements trait-list-5))
        (print (map place-many-helper-collections tile-placements trait-list-6))
        (print (map place-many-helper-collections tile-placements trait-list-7))
        (print (map place-many-helper-collections tile-placements trait-list-8))
        (print (map place-many-helper-collections tile-placements trait-list-9))
        (print (map place-many-helper-collections tile-placements trait-list-10))
      )
    )
  )
)

;; Private helper function for placing many tiles many collections
;; (define-private (place-many-helper-collections (test-placement {tile-position: uint, item: uint, color: (string-ascii 6)}) (test-collection (optional <nft-collection>))) 
;;   (place-tile (get item test-placement) (unwrap! test-collection (err "err-no-collection")) (get tile-position test-placement) (get color test-placement))
;; )

(define-private (place-many-helper-collections (test-placement {tile-position: uint, item: uint, color: (string-ascii 6)}) (test-collection <nft-collection>)) 
  (place-tile (get item test-placement) test-collection (get tile-position test-placement) (get color test-placement))
)

(define-public (place-tiles-single-collection (tile-placements (list 250 {tile-position: uint, item: uint, color: (string-ascii 6)})) (tiles-collection <nft-collection>)) 
  (let
    (
      (trait-list (list 
        tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection
        tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection
        tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection
        tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection
        tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection
        tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection
        tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection
        tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection
        tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection
        tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection
        tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection
        tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection
        tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection
        tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection
        tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection
        tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection
        tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection
        tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection
        tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection
        tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection
        tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection
        tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection
        tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection
        tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection
        tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection tiles-collection
      ))
    )

    ;; Var-set helper-uint to the length of tile-placements passed in parameter
    (var-set helper-uint (len tile-placements))

    ;; Filter initial-tuple-trait-list using the index key & helper-uint 
    ;; Then map the result from a list of tuples to a simple list of traits
    ;; Finally call place-many-helper with the tile-placements & the list of traits
    (ok (map place-many-helper tile-placements trait-list))
  )
)

;; Private helper function for placing many tiles
(define-private (place-many-helper (test-placement {tile-position: uint, item: uint, color: (string-ascii 6)}) (test-collection <nft-collection>)) 
  (place-tile (get item test-placement) test-collection (get tile-position test-placement) (get color test-placement))
)

;; Private helper function for filtering initial tuple trait list using the index key & helper-uint
(define-private (filter-initial-tuple-trait-list (initial-tuple {index: uint, trait: <nft-collection>}))
  (if (< (get index initial-tuple) (var-get helper-uint))
    true
    false
  )
)

;; Private helper function from mapping from tuple trait list to a list of traits
(define-private (map-to-trait-list (initial-tuple {index: uint, trait: <nft-collection>}))
  (get trait initial-tuple)
)

;; Function to replace a tile
;; @desc - Function to replace a tile, costs 25 STX
;; @param - Tile (uint) - The tile ID being replaced, Color (string-ascii 6) - The color of the tile being placed
(define-public (replace-tile (tile uint) (color (string-ascii 6)))
  (let
    (
      (current-board-meta (unwrap! (get-board-meta (var-get board-index)) (err "err-no-board-meta")))
      (current-board-end-height (get end-height current-board-meta))
      (current-board-placed-tiles (get placed-tiles current-board-meta))
      (current-board-whitelisted-collections (get whitelisted-collections current-board-meta))
      (current-board-index (var-get board-index))
      (current-tile-history (unwrap! (get-tile-history tile) (err "err-no-tile-meta")))
    )

    ;; Assert that tile metadata is-some
    (asserts! (is-some (get-tile-history tile)) (err "err-tile-meta-missing"))

    ;; Send 25 STX to the deployer
    (unwrap! (stx-transfer? u25 tx-sender deployer) (err "err-stx-transfer-failed"))

    ;; Map set tile history by appending the new color & placer to the current list
    (ok (map-set tile-history {board: current-board-index, tile: tile} 
      (unwrap! (as-max-len? (append current-tile-history {color: color, placer: tx-sender}) u25) (err "err-tile-history-overflow"))
    ))
   
  )
)



;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; Admin Functions ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Mint function for the bos-nft
;; ;; @desc - Mint function that calls the .bos-nft contract
;; (define-public (mint-ended-board) 
;;   (let
;;     (
;;       (current-board-meta (unwrap! (get-current-board-meta) (err "err-no-board-meta")))
;;       (current-board-end-height (get end-height current-board-meta))
;;     )

;;     ;; Assert that block-height > end-height
;;     (asserts! (> block-height current-board-end-height) (err "err-block-height-invalid"))

;;     ;; Call the .bos-nft contract to mint the board
;;     (ok (unwrap! (contract-call? .bos-nft mint-bos) (err "err-mint-failed")))
;;   )
;; )

;; Start the next board
;; @desc - Function to start the next board
;; @param - Whitelisted-Collections (list 100 principal) - A list of this months whitelisted collections
(define-public (start-next-board (whitelisted-collections (list 10 principal)))
  (let
    (
      (current-board-meta (default-to {end-height: (+ block-height board-duration), minted: false, placed-tiles: (list ), tile-placers: (list ),whitelisted-collections: (list )}  (get-board-meta (var-get board-index))))
      (current-board-end-height (get end-height current-board-meta))
      (current-board-index (var-get board-index))
      (current-next-index (+ current-board-index u1))
    )

    ;; Check if first board
    (if (is-eq current-board-index u1)
      ;; First board, no need to update index
      (ok (map-set board-meta current-board-index {
          end-height: (+ block-height board-duration),
          whitelisted-collections: whitelisted-collections,
          placed-tiles: (list ),
          tile-placers: (list ),
          minted: false
        })
      )
      ;; Not first board, update index
      (begin 
        ;; Assert that block-height > end-height
        (asserts! (> block-height current-board-end-height) (err "err-block-height-invalid"))

        ;; Var set board-index to the next board index
        (var-set board-index current-next-index)

        ;; Map set board-meta by merging everything with a new placed-tiles value
        (ok (map-set board-meta current-next-index {
          end-height: (+ block-height board-duration),
          whitelisted-collections: whitelisted-collections,
          placed-tiles: (list ),
          tile-placers: (list ),
          minted: false
        }))
      )
    )

  )
)

;; Distribute earnings
;; @desc - Function to distribute the 50% to team wallet and 50% to tile placers according to tiles placed
;; @param - board index and stx amount

(define-public (distribute-auction-earnings (board uint) (amount uint)) 
  (let 
    (
      (current-board-meta (map-get? board-meta board))
      (list-of-placers (unwrap! (get tile-placers current-board-meta) (err "err-unwrap")))
      (admin-list (var-get admins))
      (current-board-end-height (get end-height current-board-meta))
    )

    (var-set stx-amount amount)

    ;; Asserts that tx-sender is admin
    (asserts! (is-some (index-of admin-list tx-sender)) (err "not-admin"))

    ;; Assert that block-height > end-height
    (asserts! (> block-height (unwrap! current-board-end-height (err "err-unwrap"))) (err "err-block-height-invalid"))

    


    ;; Transfer to the list of principals that placed tiles on the board
    (ok
      (begin
        (map transfer-earnings list-of-placers)
        (as-contract (stx-transfer? (* (/ (var-get stx-amount) u2)) .board tx-sender))
      )
    )
  )
)

;; Private function that helps transfer the correct percentage to the tile placers per board according to the tiles placed out of 5000 total 

(define-private (transfer-earnings (placer principal)) 
  (as-contract (stx-transfer? (* (/ (var-get stx-amount) u2) (/ (* (get-board-placer-tiles placer (var-get board-index)) u100) u5000)) .board placer))
)

