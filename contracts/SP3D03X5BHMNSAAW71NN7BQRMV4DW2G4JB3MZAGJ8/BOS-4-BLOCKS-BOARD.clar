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
(use-trait nft-collection 'SP3D03X5BHMNSAAW71NN7BQRMV4DW2G4JB3MZAGJ8.sip-09.nft-trait)
;; (use-trait nft-collection .sip-09.nft-trait)

;; The max amount of possible tiles on the board
(define-constant tiles-in-board u5000)

;; Deployer principal
(define-constant deployer tx-sender)

;; Replacement fee (25 STX in microSTX) for replacing a tile
(define-constant replacement-fee u25000000)

;; Board duration in blocks (4320 blocks = 1 month)
(define-constant board-duration u4320)

;; Three days in blocks
(define-constant three-days u864)

;; Reward height (432 divided by 6)
(define-constant reward-height u864)

;;;;;;;;;;;;
;;; Vars ;;;
;;;;;;;;;;;;

;; Helper to remove a collection or admin
(define-data-var helper-collection-principal principal tx-sender)

;; Helper to transfer the correct board
(define-data-var board-index-transfer uint u0)

;; Variable helper to transfer the auction earnings
(define-data-var stx-amount uint u0)

;; Variable to determine the percentage of the earnings that go to the team wallet
(define-data-var team-wallet-percentage uint u50)

;; Badger collections
(define-data-var badger-collections (list 10 principal) (list 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.baby-badgers))

;; Var that keeps track of the active board index
(define-data-var board-index uint u0)

;; Var that keeps tracks of admin principals
(define-data-var admins (list 8 principal) (list deployer))

;; Map that keeps track of a tile's history for a specific board
(define-map tile-history {board: uint, tile: uint} (list 25 {color: (string-ascii 6), placer: principal}))

;; Map that keeps track of the last time an item's tiles was placed & when
(define-map last-used-tile {board: uint, collection: principal, item: uint, block: uint} (list 100 {last-placed-height: uint, last-placed-amount: uint}))

;; Map that keeps track of current board whitelisted collections
(define-map board-meta uint {
  end-height: uint,
  minted: bool,
  placed-tiles: (list 5000 uint),
  tile-placers: (list 500 principal),
  whitelisted-collections: (list 10 principal),
  paid: bool
})

;; Map that keeps track of number of placed tiles by principal and board
(define-map tiles-placed-per-principal-per-board {placer: principal, board: uint} uint)


(define-map paid-board { board: uint } bool)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; Read-Only Functions ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-read-only (get-admins)
  (var-get admins)
)

(define-read-only (get-paid-board (board uint))
  (map-get? paid-board {board: board})
)

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

;; Get a list of all the tile placers of current board
(define-read-only (get-board-placers (board uint))
  (ok (unwrap! (get tile-placers (map-get? board-meta board)) (err "err-unwrap")))
)

;; Get the amount of tiles placed by placer
(define-read-only (get-board-placer-tiles (placer principal) (board uint))
 (default-to u0 (map-get? tiles-placed-per-principal-per-board {placer: placer, board: board}))
)

;; Get item tile balance
;; Balance for an item in a collection (current block height - last used block height) / 72 with a max value of 6 (~3 days before tile expires) - tiles placed in last 3 days.
(define-read-only (get-item-balance (collection principal) (item uint))
    (let 
        (
            ;; List of all times user has placed tiles for this item for current board
            (current-recently-placed 
              (if (<= (unwrap! (get-board-time-remaining (var-get board-index)) (err "err-unwrap-time")) u864)
                (default-to (list) (map-get? last-used-tile {board: (var-get board-index), collection: collection, item: item, block: u864}))
                  (if (<= (unwrap! (get-board-time-remaining (var-get board-index)) (err "err-unwrap-time")) u1728)
                    (default-to (list) (map-get? last-used-tile {board: (var-get board-index), collection: collection, item: item, block: u1728}))
                      (if (<= (unwrap! (get-board-time-remaining (var-get board-index)) (err "err-unwrap-time")) u2592)
                        (default-to (list) (map-get? last-used-tile {board: (var-get board-index), collection: collection, item: item, block: u2592}))
                            (if (<= (unwrap! (get-board-time-remaining (var-get board-index)) (err "err-unwrap-time")) u3456)
                              (default-to (list) (map-get? last-used-tile {board: (var-get board-index), collection: collection, item: item, block: u3456}))
                                (default-to (list) (map-get? last-used-tile {board: (var-get board-index), collection: collection, item: item, block: u4320}))
                            )
                      )
                  )
                )
              )
            ;; Fold from all placements in last 3 days to final total amount of tiles placed in last 3 days
            (current-recently-placed-folded (fold fold-from-all-placements-to-recent-placements current-recently-placed u0))
        )
        ;; Badger collection - 12 tiles (x2) ; Other collections - 6 tiles (x1)
        (ok (if (is-some (index-of (var-get badger-collections) collection))
          (- u24 current-recently-placed-folded)
          (- u12 current-recently-placed-folded)
        ))
    )
)

;; Balance for 10 items in a collection
(define-read-only (get-5-item-balance (collection principal) (items (list 5 (optional uint))))
  (let 
    (
      (nft-1 (unwrap! (element-at items u0) (err "err-unwrap")))
      (nft-2 (unwrap! (element-at items u1) (err "err-unwrap")))
      (nft-3 (unwrap! (element-at items u2) (err "err-unwrap")))
      (nft-4 (unwrap! (element-at items u3) (err "err-unwrap")))
      (nft-5 (unwrap! (element-at items u4) (err "err-unwrap")))
    )

    (ok
      (list 
        (if (is-some nft-1)
          (some (get-item-balance collection (unwrap! nft-1 (err "err-unwrap"))))
          none
        )
        (if (is-some nft-2)
          (some (get-item-balance collection (unwrap! nft-2 (err "err-unwrap"))))
          none
        )
        (if (is-some nft-3)
          (some (get-item-balance collection (unwrap! nft-3 (err "err-unwrap"))))
          none
        )
        (if (is-some nft-4)
          (some (get-item-balance collection (unwrap! nft-4 (err "err-unwrap"))))
          none
        )
        (if (is-some nft-5)
          (some (get-item-balance collection (unwrap! nft-5 (err "err-unwrap"))))
          none
        )
      )
    )
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
      (current-last-used-tile 
        (if (<= (unwrap! (get-board-time-remaining (var-get board-index)) (err "err-unwrap-time")) u864)
          (map-get? last-used-tile {board: (var-get board-index), collection: (contract-of collection), item: item, block: u864})
            (if (<= (unwrap! (get-board-time-remaining (var-get board-index)) (err "err-unwrap-time")) u1728)
              (map-get? last-used-tile {board: (var-get board-index), collection: (contract-of collection), item: item, block: u1728})
                (if (<= (unwrap! (get-board-time-remaining (var-get board-index)) (err "err-unwrap-time")) u2592)
                  (map-get? last-used-tile {board: (var-get board-index), collection: (contract-of collection), item: item, block: u2592})
                      (if (<= (unwrap! (get-board-time-remaining (var-get board-index)) (err "err-unwrap-time")) u3456)
                        (map-get? last-used-tile {board: (var-get board-index), collection: (contract-of collection), item: item, block: u3456})
                          (map-get? last-used-tile {board: (var-get board-index), collection: (contract-of collection), item: item, block: u4320})
                      )
                )
            )
        )      
      )
      (current-item-balance (unwrap! (get-item-balance (contract-of collection) item) (err "err-unwrap-item-balance")))
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
      (if (<= (unwrap! (get-board-time-remaining (var-get board-index)) (err "err-unwrap-time")) u864)
          (map-set last-used-tile {board: (var-get board-index), collection: (contract-of collection), item: item, block: u864} (unwrap! (as-max-len? (append last-used-tile-list {last-placed-height: block-height, last-placed-amount: u1}) u100) (err "err-list-overflow")))
            (if (<= (unwrap! (get-board-time-remaining (var-get board-index)) (err "err-unwrap-time")) u1728)
              (map-set last-used-tile {board: (var-get board-index), collection: (contract-of collection), item: item, block: u1728} (unwrap! (as-max-len? (append last-used-tile-list {last-placed-height: block-height, last-placed-amount: u1}) u100) (err "err-list-overflow")))
                (if (<= (unwrap! (get-board-time-remaining (var-get board-index)) (err "err-unwrap-time")) u2592)
                  (map-set last-used-tile {board: (var-get board-index), collection: (contract-of collection), item: item, block: u2592} (unwrap! (as-max-len? (append last-used-tile-list {last-placed-height: block-height, last-placed-amount: u1}) u100) (err "err-list-overflow")))
                      (if (<= (unwrap! (get-board-time-remaining (var-get board-index)) (err "err-unwrap-time")) u3456)
                      (map-set last-used-tile {board: (var-get board-index), collection: (contract-of collection), item: item, block: u3456} (unwrap! (as-max-len? (append last-used-tile-list {last-placed-height: block-height, last-placed-amount: u1}) u100) (err "err-list-overflow")))
                          (map-set last-used-tile {board: (var-get board-index), collection: (contract-of collection), item: item, block: u4320} (unwrap! (as-max-len? (append last-used-tile-list {last-placed-height: block-height, last-placed-amount: u1}) u100) (err "err-list-overflow")))
                      )
                )
            )
        )
                
        (if (<= (unwrap! (get-board-time-remaining (var-get board-index)) (err "err-unwrap-time")) u864)
          (map-set last-used-tile {board: (var-get board-index), collection: (contract-of collection), item: item, block: u864} (list {last-placed-height: block-height, last-placed-amount: u1}))
            (if (<= (unwrap! (get-board-time-remaining (var-get board-index)) (err "err-unwrap-time")) u1728)
              (map-set last-used-tile {board: (var-get board-index), collection: (contract-of collection), item: item, block: u1728} (list {last-placed-height: block-height, last-placed-amount: u1}))
                (if (<= (unwrap! (get-board-time-remaining (var-get board-index)) (err "err-unwrap-time")) u2592)
                  (map-set last-used-tile {board: (var-get board-index), collection: (contract-of collection), item: item, block: u2592} (list {last-placed-height: block-height, last-placed-amount: u1}))
                      (if (<= (unwrap! (get-board-time-remaining (var-get board-index)) (err "err-unwrap-time")) u3456)
                      (map-set last-used-tile {board: (var-get board-index), collection: (contract-of collection), item: item, block: u3456} (list {last-placed-height: block-height, last-placed-amount: u1}))
                          (map-set last-used-tile {board: (var-get board-index), collection: (contract-of collection), item: item, block: u4320} (list {last-placed-height: block-height, last-placed-amount: u1}))
                      )
                )
            )
        )
                
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

;; @desc - Function to place more than 1 tile of various collections
(define-public 
  (place-tiles-many-collections (tile-placements (list 60 {tile-position: uint, item: uint, color: (string-ascii 6)})) 
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
      ))
      (trait-list-2 (list 
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
      ))
      (trait-list-4 (list 
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
      ))
      (trait-list-6 (list 
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
      ))
      (trait-list-8 (list 
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
      ))
      (trait-list-10 (list 
        collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10
        collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10
        collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10
        collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10
        collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10
        collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10 collection-10
      ))
    )
    ;; Then map the result from a list of tuples to a simple list of traits
    ;; Finally call place-many-helper with the tile-placements & the list of traits
    (ok 
      (list 
        (map place-many-helper-collections tile-placements trait-list-1)
        (map place-many-helper-collections tile-placements trait-list-2)
        (map place-many-helper-collections tile-placements trait-list-3)
        (map place-many-helper-collections tile-placements trait-list-4)
        (map place-many-helper-collections tile-placements trait-list-5)
        (map place-many-helper-collections tile-placements trait-list-6)
        (map place-many-helper-collections tile-placements trait-list-7)
        (map place-many-helper-collections tile-placements trait-list-8)
        (map place-many-helper-collections tile-placements trait-list-9)
        (map place-many-helper-collections tile-placements trait-list-10)
      )
    )
  )
)

;; Private helper function for placing many tiles many collections
(define-private (place-many-helper-collections (test-placement {tile-position: uint, item: uint, color: (string-ascii 6)}) (test-collection <nft-collection>)) 
  (place-tile (get item test-placement) test-collection (get tile-position test-placement) (get color test-placement))
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
      (principal-number-tiles (default-to u0 (map-get? tiles-placed-per-principal-per-board {placer: tx-sender, board: (var-get board-index)})))
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
;; @desc - Mint function that calls the .bos-nft contract
(define-public (mint-ended-board (board uint)) 
  (let
    (
      (current-board-meta (unwrap! (map-get? board-meta board) (err "err-no-board-data")))
      (current-board-end-height (get end-height current-board-meta))
      (admin-list (var-get admins))
      (is-minted (get minted current-board-meta))
    )

    ;; Assert that block-height > end-height
    (asserts! (> block-height current-board-end-height) (err "err-block-height-invalid"))
    (asserts! (is-some (index-of admin-list tx-sender)) (err "err-not-auth"))
    (asserts! (not is-minted) (err "err-board-minted"))

    (map-set board-meta board (merge current-board-meta {minted: true}))

    ;; Call the .bos-nft contract to mint the board
    (ok
      (unwrap! (contract-call? .BOS-4-BLOCKS-NFT mint-bos) (err "err-mint-failed"))
    )
  )
)

;; Start the next board
;; @desc - Function to start the next board
;; @param - Whitelisted-Collections (list 100 principal) - A list of this months whitelisted collections
(define-public (start-next-board (whitelisted-collections (list 10 principal)))
  (let
    (
      (current-board-index (var-get board-index))
      (next-board-index (+ current-board-index u1))
      (admin-list (var-get admins))
      (current-board-meta (default-to {end-height: (+ block-height board-duration), minted: false, placed-tiles: (list ), tile-placers: (list ),whitelisted-collections: (list )}  (get-board-meta next-board-index)))
      (past-board-meta (default-to {end-height: (+ block-height board-duration), minted: false, placed-tiles: (list ), tile-placers: (list ),whitelisted-collections: (list )}  (get-board-meta current-board-index)))
      (current-board-end-height (get end-height past-board-meta))
    )

    ;; Asserts that tx-sender is admin
    (asserts! (is-some (index-of admin-list tx-sender)) (err "err-not-admin"))

    (var-set board-index next-board-index)

    ;; Check if first board
    (if (is-eq next-board-index u1)
      ;; First board, no need to update index
      (ok 
        (begin
          (map-set paid-board {board: next-board-index} false)
          (map-set board-meta next-board-index {
            end-height: (+ block-height board-duration),
            whitelisted-collections: whitelisted-collections,
            placed-tiles: (list ),
            tile-placers: (list ),
            minted: false,
            paid: false
          })
        )
      )
      ;; Not first board, check if previous board is minted
      (begin
        ;; Assert that block-height > end-height
        (asserts! (> block-height current-board-end-height) (err "err-block-height-invalid")) 

        ;; Map set board-meta by merging everything with a new placed-tiles value
        (ok 
          (begin 
            ;; Map-set paid-board to false
            (map-set paid-board {board: next-board-index} false)
            (map-set board-meta next-board-index {
                end-height: (+ block-height board-duration),
                whitelisted-collections: whitelisted-collections,
                placed-tiles: (list ),
                tile-placers: (list ),
                minted: false,
                paid: false
              }
            )
          )
        )
      )
    )
  )
)

;; Distribute earnings
;; @desc - Function to distribute the assigned% to team wallet and the rest to tile placers according to tiles placed
;; @param - board index and stx amount

(define-public (distribute-auction-earnings (board uint) (auction-sale uint)) 
  (let 
    (
      (current-board-meta (unwrap! (map-get? board-meta board) (err "err-no-board")))
      (list-of-placers (get tile-placers current-board-meta))
      (admin-list (var-get admins))
      (current-board-end-height (get end-height current-board-meta))
      (board-paid (get paid current-board-meta))
    )

    (var-set stx-amount auction-sale)
    (var-set board-index-transfer board)

    ;; Asserts board hasn't been paid before
    (asserts! (not board-paid) (err "err-board-paid"))

    ;; Asserts that tx-sender is admin
    (asserts! (is-some (index-of admin-list tx-sender)) (err "not-admin"))

    ;; Assert that block-height > end-height
    (asserts! (> block-height current-board-end-height) (err "err-block-height-invalid"))

    ;; Transfer to the list of principals that placed tiles on the board
    (ok
       (begin
        (map-set board-meta board (merge current-board-meta {paid: true}) )
        (map transfer-earnings list-of-placers)
        (unwrap! (stx-transfer? (/ (* (var-get stx-amount) (var-get team-wallet-percentage)) u100) tx-sender 'SP3PPGA6PNZ1EN4X3A5WDKZJ8QJVDCCPR39FXJC6Y) (err "err-transfer-wallet"))
       )
    )
  )
)

;; Private function that helps transfer the correct percentage to the tile placers per board according to the tiles placed out of 5000 total
(define-private (transfer-earnings (placer principal)) 
  (let
    (
      (board-to-transfer (var-get board-index-transfer))
      (team-percentage (var-get team-wallet-percentage))
      (total-stx (var-get stx-amount))
      (percentage-transfer-to-placers (- u100 team-percentage))
      (total-stx-to-be-divided-between-placers (/ (* total-stx percentage-transfer-to-placers) u100))
      (total-placed-tiles (len (unwrap! (get placed-tiles (map-get? board-meta board-to-transfer)) (err "err-unwrap-list"))))
      (tiles-placed-by-user (get-board-placer-tiles placer board-to-transfer))
      (percentage-of-placer (/ (* tiles-placed-by-user u10000) total-placed-tiles)) 
      (total-stx-to-be-transferred (/ (* total-stx-to-be-divided-between-placers percentage-of-placer) u10000))
    )

    ;; (ok (list board-to-transfer team-percentage total-stx percentage-transfer-to-placers total-stx-to-be-divided-between-placers total-placed-tiles tiles-placed-by-user percentage-of-placer total-stx-to-be-transferred))
    (ok (unwrap! (stx-transfer? total-stx-to-be-transferred tx-sender placer) (err "err-transfer-placer")))
  )
)

;; Func to change wallet percentage
(define-public (change-team-percentage (new-percentage uint))
  (begin
    (asserts! (is-some (index-of (var-get admins) tx-sender)) (err "err-not-admin"))
    (ok (var-set team-wallet-percentage new-percentage))
  )
)

;; Add admin
(define-public (add-admin (new-admin principal))
  (let
    (
      (current-admin-list (var-get admins))
      (caller-principal-position-in-list (index-of current-admin-list tx-sender))
      (param-principal-position-in-list (index-of current-admin-list new-admin))
    )

    ;; asserts tx-sender is an existing whitelist address
    (asserts! (is-some caller-principal-position-in-list) (err "err-not-auth"))

    ;; asserts param principal (new whitelist) doesn't already exist
    (asserts! (is-none param-principal-position-in-list) (err "err-already-whitelisted"))

    ;; append new whitelist address
    (ok (var-set admins (unwrap! (as-max-len? (append (var-get admins) new-admin) u8) (err "err-adding-admin"))))
  )
)

;; Remove admin
(define-public (remove-admin (admin principal))
  (let
    (
      (current-admin-list (var-get admins))
      (caller-principal-position-in-list (index-of current-admin-list tx-sender))
      (removeable-principal-position-in-list (index-of current-admin-list admin))
    )

    ;; asserts tx-sender is an existing whitelist address
    (asserts! (is-some caller-principal-position-in-list) (err "err-not-auth"))

    ;; asserts param principal (removeable whitelist) already exist
    (asserts! (is-eq removeable-principal-position-in-list) (err "err-not-whitelisted"))

    ;; temporary var set to help remove param principal
    (var-set helper-collection-principal admin)

    ;; filter existing whitelist address
    (ok 
      (var-set admins (filter is-not-removeable-collection current-admin-list))
    )
  )
)

;; Add a whitelist collection to the board
(define-public (admin-add-new-collection (collection principal))
  (let
    (
      (current-board (var-get board-index))
      (current-board-meta (unwrap! (map-get? board-meta current-board) (err "err-no-board")))
      (current-list (get whitelisted-collections current-board-meta))
      (current-list-len (len current-list))
      (admins-list (var-get admins))
      (new-list (unwrap! (as-max-len? (append current-list collection) u10) (err "err-creating-new-list")))
    )

    ;; assert the tx-sender is admin
    (asserts! (is-some (index-of admins-list tx-sender)) (err "err-not-auth"))

    ;; assert collection not already added
    (asserts! (is-none (index-of current-list collection)) (err "err-already-whitelisted"))

    ;; assert current list is 10 or smaller
    (asserts! (< current-list-len u11) (err "err-limit-reached"))

    ;; add new principle to whitelist
    (ok 
      (map-set board-meta current-board (merge current-board-meta {whitelisted-collections: new-list}))
    )
  )
)

;; Remove a whitelist collection from the board

(define-public (admin-remove-collection (collection principal))
  (let
    (
      (current-board (var-get board-index))
      (current-board-meta (unwrap! (map-get? board-meta current-board) (err "err-no-board")))
      (current-list (get whitelisted-collections current-board-meta))
      (removeable-principal-position (index-of current-list collection))
      (admins-list (var-get admins))
    )

    ;; assert the tx-sender is admin
    (asserts! (is-some (index-of admins-list tx-sender)) (err "err-not-auth"))

    ;; assert collection is already added in custodial
    (asserts! (is-some removeable-principal-position) (err "err-not-whitelisted"))

    ;; temporary var set to help remove param principal
    (var-set helper-collection-principal collection)

    ;; remove from whitelist
    (ok 
        (map-set board-meta current-board (merge current-board-meta {whitelisted-collections: (filter is-not-removeable-collection current-list)}))
    )
  )
)

;; @desc - Helper function for removing a specific collection from the whitelist
(define-private (is-not-removeable-collection (whitelist-collection principal))
  (not (is-eq whitelist-collection (var-get helper-collection-principal)))
)