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
      (initial-tuple-trait-list (list 
        {index: u0, trait: tiles-collection} {index: u1, trait: tiles-collection} {index: u2, trait: tiles-collection} {index: u3, trait: tiles-collection} {index: u4, trait: tiles-collection} {index: u5, trait: tiles-collection} {index: u6, trait: tiles-collection} {index: u7, trait: tiles-collection} {index: u8, trait: tiles-collection} {index: u9, trait: tiles-collection}
        {index: u10, trait: tiles-collection} {index: u11, trait: tiles-collection} {index: u12, trait: tiles-collection} {index: u13, trait: tiles-collection} {index: u14, trait: tiles-collection} {index: u15, trait: tiles-collection} {index: u16, trait: tiles-collection} {index: u17, trait: tiles-collection} {index: u18, trait: tiles-collection} {index: u19, trait: tiles-collection}
        {index: u20, trait: tiles-collection} {index: u21, trait: tiles-collection} {index: u22, trait: tiles-collection} {index: u23, trait: tiles-collection} {index: u24, trait: tiles-collection} {index: u25, trait: tiles-collection} {index: u26, trait: tiles-collection} {index: u27, trait: tiles-collection} {index: u28, trait: tiles-collection} {index: u29, trait: tiles-collection}
        {index: u30, trait: tiles-collection} {index: u31, trait: tiles-collection} {index: u32, trait: tiles-collection} {index: u33, trait: tiles-collection} {index: u34, trait: tiles-collection} {index: u35, trait: tiles-collection} {index: u36, trait: tiles-collection} {index: u37, trait: tiles-collection} {index: u38, trait: tiles-collection} {index: u39, trait: tiles-collection}
        {index: u40, trait: tiles-collection} {index: u41, trait: tiles-collection} {index: u42, trait: tiles-collection} {index: u43, trait: tiles-collection} {index: u44, trait: tiles-collection} {index: u45, trait: tiles-collection} {index: u46, trait: tiles-collection} {index: u47, trait: tiles-collection} {index: u48, trait: tiles-collection} {index: u49, trait: tiles-collection}
        {index: u50, trait: tiles-collection} {index: u51, trait: tiles-collection} {index: u52, trait: tiles-collection} {index: u53, trait: tiles-collection} {index: u54, trait: tiles-collection} {index: u55, trait: tiles-collection} {index: u56, trait: tiles-collection} {index: u57, trait: tiles-collection} {index: u58, trait: tiles-collection} {index: u59, trait: tiles-collection}
        {index: u60, trait: tiles-collection} {index: u61, trait: tiles-collection} {index: u62, trait: tiles-collection} {index: u63, trait: tiles-collection} {index: u64, trait: tiles-collection} {index: u65, trait: tiles-collection} {index: u66, trait: tiles-collection} {index: u67, trait: tiles-collection} {index: u68, trait: tiles-collection} {index: u69, trait: tiles-collection}
        {index: u70, trait: tiles-collection} {index: u71, trait: tiles-collection} {index: u72, trait: tiles-collection} {index: u73, trait: tiles-collection} {index: u74, trait: tiles-collection} {index: u75, trait: tiles-collection} {index: u76, trait: tiles-collection} {index: u77, trait: tiles-collection} {index: u78, trait: tiles-collection} {index: u79, trait: tiles-collection}
        {index: u80, trait: tiles-collection} {index: u81, trait: tiles-collection} {index: u82, trait: tiles-collection} {index: u83, trait: tiles-collection} {index: u84, trait: tiles-collection} {index: u85, trait: tiles-collection} {index: u86, trait: tiles-collection} {index: u87, trait: tiles-collection} {index: u88, trait: tiles-collection} {index: u89, trait: tiles-collection}
        {index: u90, trait: tiles-collection} {index: u91, trait: tiles-collection} {index: u92, trait: tiles-collection} {index: u93, trait: tiles-collection} {index: u94, trait: tiles-collection} {index: u95, trait: tiles-collection} {index: u96, trait: tiles-collection} {index: u97, trait: tiles-collection} {index: u98, trait: tiles-collection} {index: u99, trait: tiles-collection}
        {index: u100, trait: tiles-collection} {index: u101, trait: tiles-collection} {index: u102, trait: tiles-collection} {index: u103, trait: tiles-collection} {index: u104, trait: tiles-collection} {index: u105, trait: tiles-collection} {index: u106, trait: tiles-collection} {index: u107, trait: tiles-collection} {index: u108, trait: tiles-collection} {index: u109, trait: tiles-collection}
        {index: u110, trait: tiles-collection} {index: u111, trait: tiles-collection} {index: u112, trait: tiles-collection} {index: u113, trait: tiles-collection} {index: u114, trait: tiles-collection} {index: u115, trait: tiles-collection} {index: u116, trait: tiles-collection} {index: u117, trait: tiles-collection} {index: u118, trait: tiles-collection} {index: u119, trait: tiles-collection}
        {index: u120, trait: tiles-collection} {index: u121, trait: tiles-collection} {index: u122, trait: tiles-collection} {index: u123, trait: tiles-collection} {index: u124, trait: tiles-collection} {index: u125, trait: tiles-collection} {index: u126, trait: tiles-collection} {index: u127, trait: tiles-collection} {index: u128, trait: tiles-collection} {index: u129, trait: tiles-collection}
        {index: u130, trait: tiles-collection} {index: u131, trait: tiles-collection} {index: u132, trait: tiles-collection} {index: u133, trait: tiles-collection} {index: u134, trait: tiles-collection} {index: u135, trait: tiles-collection} {index: u136, trait: tiles-collection} {index: u137, trait: tiles-collection} {index: u138, trait: tiles-collection} {index: u139, trait: tiles-collection}
        {index: u140, trait: tiles-collection} {index: u141, trait: tiles-collection} {index: u142, trait: tiles-collection} {index: u143, trait: tiles-collection} {index: u144, trait: tiles-collection} {index: u145, trait: tiles-collection} {index: u146, trait: tiles-collection} {index: u147, trait: tiles-collection} {index: u148, trait: tiles-collection} {index: u149, trait: tiles-collection}
        {index: u150, trait: tiles-collection} {index: u151, trait: tiles-collection} {index: u152, trait: tiles-collection} {index: u153, trait: tiles-collection} {index: u154, trait: tiles-collection} {index: u155, trait: tiles-collection} {index: u156, trait: tiles-collection} {index: u157, trait: tiles-collection} {index: u158, trait: tiles-collection} {index: u159, trait: tiles-collection}
        {index: u160, trait: tiles-collection} {index: u161, trait: tiles-collection} {index: u162, trait: tiles-collection} {index: u163, trait: tiles-collection} {index: u164, trait: tiles-collection} {index: u165, trait: tiles-collection} {index: u166, trait: tiles-collection} {index: u167, trait: tiles-collection} {index: u168, trait: tiles-collection} {index: u169, trait: tiles-collection}
        {index: u170, trait: tiles-collection} {index: u171, trait: tiles-collection} {index: u172, trait: tiles-collection} {index: u173, trait: tiles-collection} {index: u174, trait: tiles-collection} {index: u175, trait: tiles-collection} {index: u176, trait: tiles-collection} {index: u177, trait: tiles-collection} {index: u178, trait: tiles-collection} {index: u179, trait: tiles-collection}
        {index: u180, trait: tiles-collection} {index: u181, trait: tiles-collection} {index: u182, trait: tiles-collection} {index: u183, trait: tiles-collection} {index: u184, trait: tiles-collection} {index: u185, trait: tiles-collection} {index: u186, trait: tiles-collection} {index: u187, trait: tiles-collection} {index: u188, trait: tiles-collection} {index: u189, trait: tiles-collection}
        {index: u190, trait: tiles-collection} {index: u191, trait: tiles-collection} {index: u192, trait: tiles-collection} {index: u193, trait: tiles-collection} {index: u194, trait: tiles-collection} {index: u195, trait: tiles-collection} {index: u196, trait: tiles-collection} {index: u197, trait: tiles-collection} {index: u198, trait: tiles-collection} {index: u199, trait: tiles-collection}
        {index: u200, trait: tiles-collection} {index: u201, trait: tiles-collection} {index: u202, trait: tiles-collection} {index: u203, trait: tiles-collection} {index: u204, trait: tiles-collection} {index: u205, trait: tiles-collection} {index: u206, trait: tiles-collection} {index: u207, trait: tiles-collection} {index: u208, trait: tiles-collection} {index: u209, trait: tiles-collection}
        {index: u210, trait: tiles-collection} {index: u211, trait: tiles-collection} {index: u212, trait: tiles-collection} {index: u213, trait: tiles-collection} {index: u214, trait: tiles-collection} {index: u215, trait: tiles-collection} {index: u216, trait: tiles-collection} {index: u217, trait: tiles-collection} {index: u218, trait: tiles-collection} {index: u219, trait: tiles-collection}
        {index: u220, trait: tiles-collection} {index: u221, trait: tiles-collection} {index: u222, trait: tiles-collection} {index: u223, trait: tiles-collection} {index: u224, trait: tiles-collection} {index: u225, trait: tiles-collection} {index: u226, trait: tiles-collection} {index: u227, trait: tiles-collection} {index: u228, trait: tiles-collection} {index: u229, trait: tiles-collection}
        {index: u230, trait: tiles-collection} {index: u231, trait: tiles-collection} {index: u232, trait: tiles-collection} {index: u233, trait: tiles-collection} {index: u234, trait: tiles-collection} {index: u235, trait: tiles-collection} {index: u236, trait: tiles-collection} {index: u237, trait: tiles-collection} {index: u238, trait: tiles-collection} {index: u239, trait: tiles-collection}
        {index: u240, trait: tiles-collection} {index: u241, trait: tiles-collection} {index: u242, trait: tiles-collection} {index: u243, trait: tiles-collection} {index: u244, trait: tiles-collection} {index: u245, trait: tiles-collection} {index: u246, trait: tiles-collection} {index: u247, trait: tiles-collection} {index: u248, trait: tiles-collection} {index: u249, trait: tiles-collection}
        {index: u250, trait: tiles-collection} {index: u251, trait: tiles-collection} {index: u252, trait: tiles-collection} {index: u253, trait: tiles-collection} {index: u254, trait: tiles-collection} {index: u255, trait: tiles-collection} {index: u256, trait: tiles-collection} {index: u257, trait: tiles-collection} {index: u258, trait: tiles-collection} {index: u259, trait: tiles-collection}
      ))
    )

    ;; Var-set helper-uint to the length of tile-placements passed in parameter
    (var-set helper-uint (len tile-placements))

    ;; Filter initial-tuple-trait-list using the index key & helper-uint 
    ;; Then map the result from a list of tuples to a simple list of traits
    ;; Finally call place-many-helper with the tile-placements & the list of traits
    (ok (map place-many-helper tile-placements (map map-to-trait-list (filter filter-initial-tuple-trait-list initial-tuple-trait-list))))
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