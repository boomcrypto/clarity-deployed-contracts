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
(use-trait nft-collection 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

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
  whitelisted-collections: (list 10 principal)
})



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
(define-read-only (get-current-board-meta)
  (map-get? board-meta (var-get board-index))
)

;; Get tile meta for a specific board
(define-read-only (get-tile-history (tile-param uint))
  (map-get? tile-history {board: (var-get board-index), tile: tile-param})
)


;; Get item tile balance
;; Balance for one specific item is (current block height - last used block height) / 72 with a max value of 6 (~3 days before tile expires) - tiles placed in last 3 days.
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
      (current-board-meta (unwrap! (get-current-board-meta) (err "err-no-board-meta")))
      (current-board-end-height (get end-height current-board-meta))
      (current-board-placed-tiles (get placed-tiles current-board-meta))
      (current-board-whitelisted-collections (get whitelisted-collections current-board-meta))
      (current-last-used-tile (map-get? last-used-tile {board: (var-get board-index), collection: (contract-of collection), item: item}))
      (current-item-balance (get-item-balance (contract-of collection) item))
      (current-nft-owner (unwrap! (contract-call? collection get-owner item) (err "err-nft-get-owner")))
    )

    ;; Assert that the item balance is greater than 0
    (asserts! (> current-item-balance u0) (err "err-item-balance-zero"))

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

    ;; Map set board-meta by merging everything with a new placed-tiles value
    (ok (map-set board-meta (var-get board-index) 
      (merge 
        current-board-meta 
        {placed-tiles: (unwrap! (as-max-len? (append current-board-placed-tiles item) u5000) (err "err-placed-tiles-overflow"))}
      )
    ))

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

(define-public (place-tiles (tile-placements (list 250 {tile-position: uint, item: uint, color: (string-ascii 6)})) (tiles-collection <nft-collection>)) 
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
      (current-board-meta (unwrap! (get-current-board-meta) (err "err-no-board-meta")))
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
      (current-board-meta (default-to {end-height: (+ block-height board-duration), minted: false, placed-tiles: (list ), whitelisted-collections: (list .nft-a)}  (get-current-board-meta)))
      (current-board-end-height (get end-height current-board-meta))
      (current-board-index (var-get board-index))
      (current-next-index (+ current-board-index u1))
    )

    ;; Check if first board
    (if (is-eq current-board-index u1)
      ;; First board, no need to update index
      (ok (map-set board-meta current-board-index current-board-meta))
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
          minted: false
        }))
      )
    )

  )
)