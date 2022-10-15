;; Board
;; Control contract for all badger board canvases
;; Written by StrataLabs

;; Board
;; The Board represents the 5000-tile canvas that users can draw on (place single tiles)
;; For each tile, the Board stores the color, collection, & owner (principal that placed the tile).

;; Round
;; Every month (4320 blocks), the Board is reset & a new Round begins.

;; Existing Badger collections
;; Badger -> SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2
;; Baby -> SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.baby-badgers


;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Cons, Vars & Maps ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;
;;;;;;;;;;;;
;;; Cons ;;;
;;;;;;;;;;;;
;;;;;;;;;;;;

(use-trait nft-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

;; The max amount of possible canvas tiles
(define-constant tiles-in-canvas u5000)

;; Whitelisted badger collections
;; (define-data-var name type value)

;; Replacement fee in stx (25 stx)
(define-constant replacement-fee u25000000)

;; Deployer address for fees
(define-constant deployer tx-sender)

;; Canvas duration in blocks (4320 blocks = 1 month)
(define-constant canvas-duration u4320)


;;;;;;;;;;;;
;;;;;;;;;;;;
;;; Errs ;;;
;;;;;;;;;;;;
;;;;;;;;;;;;
(define-constant ERR-END-HEIGHT-NOT-REACHED (err u0))
(define-constant ERR-UNWRAP-META (err u1))
(define-constant ERR-UNWRAP-TILE (err u2))
(define-constant ERR-NOT-ENOUGH-TILES (err u3))
(define-constant ERR-INVALID-POSITION (err u4))
(define-constant ERR-POSITION-NOT-EMPTY (err u5))
(define-constant ERR-NOT-OWNER (err u6))
(define-constant ERR-WRONG-COLLECTION-COLOR (err u7))
(define-constant ERR-TILE-LIST-OVERFLOW (err u8))
(define-constant ERR-SPEND-TILE (err u9))
(define-constant ERR-NOT-AUTH (err u10))
(define-constant ERR-NOT-ENOUGH-COLORS (err u11))
(define-constant ERR-INDEX-ISSUE (err u12))
(define-constant ERR-CANVAS-ALREADY-MINTED (err u12))
(define-constant ERR-CANVAS-NOT-MINTED (err u13))
(define-constant ERR-ADMIN-ALREADY-ADDED (err u14))
(define-constant ERR-ADMIN-LIST-OVERFLOW (err u15))



;;;;;;;;;;;;
;;;;;;;;;;;;
;;; Vars ;;;
;;;;;;;;;;;;
;;;;;;;;;;;;

;; @desc - Var that keeps track of the active canvas index
(define-data-var canvas-index uint u1)

;; @desc - Var that keeps track of current Badger colors
(define-data-var badger-colors (list 8 (string-ascii 6)) (list "ffffff" "000000" "ff0000" "00ff00" "0000ff" "ffff00" "00ffff" "ff00ff"))

;; @desc - Var list of principals that are considered admins
(define-data-var admins (list 10 principal) (list tx-sender))

;; @desc - Var list of Badger collections
(define-data-var badger-collections (list 25 principal) (list 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.baby-badgers))

;;;;;;;;;;;;
;;;;;;;;;;;;
;;; Maps ;;;
;;;;;;;;;;;;
;;;;;;;;;;;;

;; @desc - Map that keeps track of a canvas (key: canvas-id/uint) & it's meta properties 
(define-map canvas-meta uint
  {
    charity-name:         (string-ascii 256),
    charity-description:  (string-ascii 256),
    charity-url:          (string-ascii 256),
    placed-tiles:         (list 5000 uint),
    end-height:           uint,
    minted:               bool
  }
)

;; @desc - Map that keeps track of a tile (key: tile-id/uint) & it's competitive properties
(define-map canvas-competition uint {
  badger-placed: uint,
  competitor-placed: uint,
  competitor-collection: principal,
  competitor-colors:    (list 8 (string-ascii 6)),
})

;; @desc - Map that keeps track of a tile in a canvas (key: canvas-id/uint, tile-id/uint) & it's properties (value: color/uint, collection/uint, owner principal)
(define-map tile { canvas: uint, tile: uint } 
  (list 100 
    {
      color: (string-ascii 6),
      collection: (optional principal),
      owner: principal
    }
  )
)

;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Read-Only Funcs ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;

;; Get Canvas Meta Info
;; @desc - Get the current canvas meta
(define-read-only (get-canvas-meta (canvas-id uint))
  (map-get? canvas-meta canvas-id)
)

;; Get Canvas Competition Info
;; @desc - Get the current canvas competition
(define-read-only (get-canvas-competition (canvas-id uint))
  (map-get? canvas-competition canvas-id)
)

;; Get Tile Info
;; @desc - Get the current tile info
(define-read-only (get-tile (canvas-id uint) (tile-id uint))
  (map-get? tile { canvas: canvas-id, tile: tile-id })
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Place/Replace Funcs ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;
;; Place Tile ;;
;;;;;;;;;;;;;;;;
;; @desc - Main function for placing a tile on the active canvas
;; @param - Position (uint), Color (string-ascii 6), Collection (optional principal)
;; Collection-id should be optional since user can have purchases ; collection can't be optional because traits can't be optional?, pass Badgers by default
(define-public (place-tile (position uint) (color (string-ascii 6)) (collection <nft-trait>) (collection-id (optional uint))) 
  (let
    (
      (current-canvas-index (var-get canvas-index))
      (current-user-tile-balance (unwrap! (contract-call? .test-tiles-v1-1 get-total-balance) (err u0)))
      (current-canvas-meta (unwrap! (map-get? canvas-meta current-canvas-index) ERR-UNWRAP-META))
      (current-canvas-end-height (get end-height current-canvas-meta))
      (current-placed-tiles (get placed-tiles current-canvas-meta))
      (current-canvas-competition (unwrap! (map-get? canvas-competition current-canvas-index) ERR-END-HEIGHT-NOT-REACHED))
      (current-competitor (get competitor-collection current-canvas-competition))
      (current-competitor-colors (get competitor-colors current-canvas-competition))
      (current-badger-placement (get badger-placed current-canvas-competition))
      (current-competitor-placement (get competitor-placed current-canvas-competition))
      (current-tile (map-get? tile { canvas: current-canvas-index, tile: position}))
      (current-collection-id (default-to u0 collection-id))
    )

    ;; Assert that the canvas is active / block-height is less than the end-height
    (asserts! (< block-height current-canvas-end-height) ERR-END-HEIGHT-NOT-REACHED)

    ;; Assert that user has a tile to place
    (asserts! (> current-user-tile-balance u0) ERR-NOT-ENOUGH-TILES)

    ;; Assert that the tile position is valid
    (asserts! (< position tiles-in-canvas) ERR-INVALID-POSITION)

    ;; Assert that tile position is empty
    (asserts! (is-none current-tile) ERR-POSITION-NOT-EMPTY)

    ;; Check if collection-id is-some collection parameter is-equal to either current-competitor or badger_contract
    (if (is-some collection-id)

      ;; Provided collection-id / aka might have generated balance
      (begin 

        ;; Assert that tx-sender is-equal to get-owner of collection
        (asserts! (is-eq (some tx-sender) (unwrap! (contract-call? collection get-owner current-collection-id) ERR-END-HEIGHT-NOT-REACHED)) ERR-NOT-OWNER)

        ;; Check if collection is-equal to current-competitor or badger_contract
        (if (is-some (index-of (var-get badger-collections) (contract-of collection)))

          ;; Badger
          (begin 

            ;; Assert that color is in badger-colors
            (asserts! (is-some (index-of (var-get badger-colors) color)) ERR-WRONG-COLLECTION-COLOR)

            ;; Update canvas-competition (Badger)
            (map-set canvas-competition current-canvas-index 
              (merge 
                current-canvas-competition 
                { badger-placed: (+ u1 current-badger-placement) }
              )
            )

            ;; Update tile with first list item
            (map-set tile {canvas: current-canvas-index, tile: position} 
              (list {
                color: color,
                collection: (some (contract-of collection)),
                owner: tx-sender
              })
            )

          )

          ;; Competitor
          (begin 

            ;; Assert that color is in current-competitor-colors
            (asserts! (is-some (index-of (get competitor-colors current-canvas-competition) color)) ERR-WRONG-COLLECTION-COLOR)

            ;; Update canvas-competition (Competitor)
            (map-set canvas-competition current-canvas-index 
              (merge 
                current-canvas-competition 
                { competitor-placed: (+ u1 current-competitor-placement) }
              )
            )

            ;; Update tile with first list item
            (map-set tile {canvas: current-canvas-index, tile: position} 
              (list {
                color: color,
                collection: (some current-competitor),
                owner: tx-sender
              })
            )

          )

        )

      )

      ;; Did not have either collection, set tile
      (map-set tile {canvas: current-canvas-index, tile: position} 
        (list {
          color: color,
          collection: none,
          owner: tx-sender
        })
      )

    )

    ;; Update canvas-meta
    (map-set canvas-meta current-canvas-index 
      (merge 
        current-canvas-meta 
        { placed-tiles: (unwrap! (as-max-len? (append current-placed-tiles position) u5000) ERR-TILE-LIST-OVERFLOW) }
      )
    )

    ;; Subtract tile from user
    (ok (unwrap! (contract-call? .test-tiles-v1-1 spend-tile) ERR-SPEND-TILE))
  )
)

;;;;;;;;;;;;;;;;;;
;; Replace Tile ;;
;;;;;;;;;;;;;;;;;;
;; @desc - Main function for replacing a tile on the active canvas
;; @param - Position (uint), Color (string-ascii 6), Collection (optional principal)
(define-public (replace-tile (position uint) (color (string-ascii 6)) (collection <nft-trait>) (collection-id (optional uint))) 
  (let 
    (
      (current-canvas-index (var-get canvas-index))
      (current-user-tile-balance (unwrap! (contract-call? .test-tiles-v1-1 get-total-balance) (err u0)))
      (current-canvas-meta (unwrap! (map-get? canvas-meta current-canvas-index) ERR-UNWRAP-META))
      (current-canvas-end-height (get end-height current-canvas-meta))
      (current-placed-tiles (get placed-tiles current-canvas-meta))
      (current-canvas-competition (unwrap! (map-get? canvas-competition current-canvas-index) ERR-END-HEIGHT-NOT-REACHED))
      (current-competitor (get competitor-collection current-canvas-competition))
      (current-competitor-colors (get competitor-colors current-canvas-competition))
      (current-badger-placement (get badger-placed current-canvas-competition))
      (current-competitor-placement (get competitor-placed current-canvas-competition))
      (current-tile (unwrap! (map-get? tile { canvas: current-canvas-index, tile: position}) ERR-UNWRAP-TILE))
      (current-collection-id (default-to u0 collection-id))
    )

    ;; Assert that the canvas is active / block-height is less than the end-height
    (asserts! (< block-height current-canvas-end-height) ERR-END-HEIGHT-NOT-REACHED)

    ;; Pay replace fee
    (try! (stx-transfer? replacement-fee tx-sender deployer))

    ;; Check if collection-id is-some collection parameter is-equal to either current-competitor or badger_contract
    (ok (if (or (is-eq (contract-of collection) current-competitor) (is-some (index-of (var-get badger-collections) (contract-of collection))))
      
      ;; Provided active collection
      (begin 

        ;; Assert that tx-sender is-equal to get-owner of collection
        (asserts! (is-eq (some tx-sender) (unwrap! (contract-call? collection get-owner current-collection-id) ERR-END-HEIGHT-NOT-REACHED)) ERR-NOT-OWNER)

        ;; Check if collection is-equal to current-competitor or badger_contract
        (if (is-some (index-of (var-get badger-collections) (contract-of collection)))

          ;; Badger
          (begin 

            ;; Assert that color is in badger-colors
            (asserts! (is-some (index-of (var-get badger-colors) color)) ERR-WRONG-COLLECTION-COLOR)

            ;; Update canvas-competition (Badger)
            (map-set canvas-competition current-canvas-index 
              (merge 
                current-canvas-competition 
                { badger-placed: (+ u1 current-badger-placement), competitor-placed: (- current-competitor-placement u1) }
              )
            )

            ;; Update tile by adding new item to list
            (map-set tile {canvas: current-canvas-index, tile: position} 
              (unwrap! (as-max-len? 
                (append current-tile 
                  {
                    color: color,
                    collection: (some (contract-of collection)),
                    owner: tx-sender
                  }
                ) 
              u100) ERR-TILE-LIST-OVERFLOW)
            )

          )

          ;; Competitor
          (begin 

            ;; Assert that color is in current-competitor-colors
            (asserts! (is-some (index-of (get competitor-colors current-canvas-competition) color)) ERR-WRONG-COLLECTION-COLOR)

            ;; Update canvas-competition (Competitor)
            (map-set canvas-competition current-canvas-index 
              (merge 
                current-canvas-competition 
                { badger-placed: (- current-badger-placement u1), competitor-placed: (+ u1 current-competitor-placement) }
              )
            )

            ;; Update tile by adding new item to list
            (map-set tile {canvas: current-canvas-index, tile: position} 
              (unwrap! (as-max-len? 
                (append current-tile 
                  {
                    color: color,
                    collection: (some current-competitor),
                    owner: tx-sender
                  }
                ) 
              u100) ERR-TILE-LIST-OVERFLOW)
            )

          )

        )
      )
      
      ;; No collection
      (map-set tile {canvas: current-canvas-index, tile: position} 
        (unwrap! (as-max-len? 
          (append current-tile 
            {
              color: color,
              collection: none,
              owner: tx-sender
            }
          ) 
        u100) ERR-TILE-LIST-OVERFLOW)
      )
    
    ))
  )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Admin Control Funcs ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;
;; Mint Ended Canvas ;;
;;;;;;;;;;;;;;;;;;;;;;;
;; @desc - Mint ended canvas by calling giving-nft contract
;; (define-public (mint-ended-canvas) 
;;   (let 
;;     (
;;       (current-canvas-index (var-get canvas-index))
;;       (current-charity-badger-index (unwrap! (contract-call? .giving-nft get-last-token-id) ERR-INDEX-ISSUE))
;;       (current-canvas-meta (unwrap! (map-get? canvas-meta current-canvas-index) ERR-UNWRAP-META))
;;       (current-canvas-end-height (get end-height current-canvas-meta))
;;       (current-canvas-competition (unwrap! (map-get? canvas-competition current-canvas-index) ERR-END-HEIGHT-NOT-REACHED))
;;       (current-competitor (get competitor-collection current-canvas-competition))
;;       (current-badger-placement (get badger-placed current-canvas-competition))
;;       (current-competitor-placement (get competitor-placed current-canvas-competition))
;;       ;;(canvas-winner (if (> current-badger-placement current-competitor-placement) badger-contract current-competitor))
;;     )

;;     ;; Assert that tx-sender is in the admin list
;;     (asserts! (is-some (index-of (var-get admins) tx-sender)) ERR-NOT-AUTH)

;;     ;; Assert that the canvas is over / block-height is greater than the end-height
;;     (asserts! (> block-height current-canvas-end-height) ERR-END-HEIGHT-NOT-REACHED)

;;     ;; Assert that the canvas is not already minted
;;     (asserts! (not (get minted current-canvas-meta)) ERR-CANVAS-ALREADY-MINTED)

;;     ;; Assert that current-canvas-index is-equal to current-charity-badger-index
;;     (asserts! (is-eq current-canvas-index current-charity-badger-index) ERR-INDEX-ISSUE)

;;     ;; Mint Charity Badger
;;     ;;(try! (contract-call? .giving-nft mint-charity-badger canvas-winner (get charity-name current-canvas-meta) (get charity-description current-canvas-meta) (get charity-url current-canvas-meta)))

;;     ;; Update canvas-meta
;;     (ok (map-set canvas-meta current-canvas-index 
;;       (merge 
;;         current-canvas-meta 
;;         { minted: true }
;;       )
;;     ))

;;   )
;; )

;;;;;;;;;;;;;;;;
;; New Canvas ;;
;;;;;;;;;;;;;;;;
;; @desc - Admin function for creating a new canvas
;; @param - Badger Colors (list 6 (string-ascii 6)), Competitor Collection (principal), Competitor Colors (list 6 (string-ascii 6)), charity-name (string-ascii 256), charity-description (string-ascii 256), charity-url (string-ascii 256)
(define-public (new-canvas (new-badger-colors (list 8 (string-ascii 6))) (new-competitor-collection principal) (new-competitor-colors (list 8 (string-ascii 6))) (charity-name (string-ascii 256)) (charity-description (string-ascii 256)) (charity-url (string-ascii 256)))
  (let 
    (
      (current-canvas-index (var-get canvas-index))
      (current-canvas-meta (map-get? canvas-meta current-canvas-index))
      (current-canvas-end-height (get end-height current-canvas-meta))
      (next-canvas-index (+ u1 current-canvas-index))
      (next-end-height (+ block-height canvas-duration))
    )

    ;; Assert that tx-sender is in the admin list
    (asserts! (is-some (index-of (var-get admins) tx-sender)) ERR-NOT-AUTH)

    ;; Assert that badger-colors is-equal to 8
    (asserts! (is-eq (len new-badger-colors) u8) ERR-NOT-ENOUGH-COLORS)

    ;; Assert that competitor-colors is-equal to 8
    (asserts! (is-eq (len new-competitor-colors) u8) ERR-NOT-ENOUGH-COLORS)


    ;; Check if first canvas
    (ok (if (is-eq current-canvas-index u1) 
      ;; First Canvas
      (begin 

          ;; Start canvas-meta
          (map-set canvas-meta current-canvas-index 
            {
              end-height: next-end-height,
              placed-tiles: (list),
              charity-name: charity-name,
              charity-description: charity-description,
              charity-url: charity-url,
              minted: false
            }
          )

        ;; Update canvas-competition
        (map-set canvas-competition current-canvas-index 
          {
            competitor-collection: new-competitor-collection,
            competitor-colors: new-competitor-colors,
            badger-placed: u0,
            competitor-placed: u0
          }
        )
      )

      ;; N Canvas
      (begin 

          ;; Assert that current-canvas is already minted
          (asserts! (get minted (unwrap! current-canvas-meta ERR-UNWRAP-META)) ERR-CANVAS-NOT-MINTED)

          ;; Assert that block-height is higher than current-canvas-end-height (aka last canvas is over)
          (asserts! (> block-height (unwrap! current-canvas-end-height ERR-UNWRAP-META)) ERR-END-HEIGHT-NOT-REACHED)

          ;; Update canvas-meta
          (map-set canvas-meta next-canvas-index 
            {
              end-height: next-end-height,
              placed-tiles: (list),
              charity-name: charity-name,
              charity-description: charity-description,
              charity-url: charity-url,
              minted: false
            }
          )

        ;; Update canvas-competition
        (map-set canvas-competition next-canvas-index 
          {
            competitor-collection: new-competitor-collection,
            competitor-colors: new-competitor-colors,
            badger-placed: u0,
            competitor-placed: u0
          }
        )
      )
    ))
  )
)

;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;
;;;; Admin Funcs ;;;;
;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;

;; Add Admin
;; @desc - function for adding a new admin to admin-list
;; @param - new-admin (principal)
(define-public (add-admin (new-admin principal))
  (let 
    (
      (current-admins (var-get admins))
    )

    ;; Assert that tx-sender is in the admin list
    (asserts! (is-some (index-of current-admins tx-sender)) ERR-NOT-AUTH)

    ;; Assert that new-admin is not already in the admin list
    (asserts! (not (is-some (index-of current-admins new-admin))) ERR-ADMIN-ALREADY-ADDED)

    ;; Update admins
    (ok (var-set admins (unwrap! (as-max-len? (append current-admins new-admin) u10) ERR-ADMIN-LIST-OVERFLOW)))

  )
)

;; Add Badger Contracts
;; @desc - function for adding a new admin to admin-list
;; @param - new-admin (principal)
(define-public (add-badger-collection (new-badger-collection principal))
  (let 
    (
      (current-admins (var-get admins))
      (current-badger-collections (var-get badger-collections))
    )

    ;; Assert that tx-sender is in the admin list
    (asserts! (is-some (index-of current-admins tx-sender)) ERR-NOT-AUTH)

    ;; Assert that new-badger-collection is not already in the admin list
    (asserts! (not (is-some (index-of current-badger-collections new-badger-collection))) ERR-ADMIN-ALREADY-ADDED)

    ;; Update admins
    (ok (var-set badger-collections (unwrap! (as-max-len? (append current-badger-collections new-badger-collection) u25) ERR-ADMIN-LIST-OVERFLOW)))

  )
)

;; Admin Place Tile
;; @desc - Admin function for placing a tile on the canvas
(define-public (admin-place-tile (position uint) (color (string-ascii 6))) 
  (let 
    (
      (current-canvas-index (var-get canvas-index))
      (current-canvas-meta (unwrap! (map-get? canvas-meta current-canvas-index) ERR-UNWRAP-META))
      (current-placed-tiles (get placed-tiles current-canvas-meta))
      (current-end-height (get end-height current-canvas-meta))
      (current-minted-status (get minted current-canvas-meta))
      (current-tile (map-get? tile { canvas: current-canvas-index, tile: position}))
    )

    ;; Assert that the canvas is active / block-height is less than the end-height
    (asserts! (< block-height current-end-height) ERR-END-HEIGHT-NOT-REACHED)

    ;; Assert that the tile position is valid
    (asserts! (< position tiles-in-canvas) ERR-INVALID-POSITION)

    ;; Assert that tile position is empty
    (asserts! (is-none current-tile) ERR-POSITION-NOT-EMPTY)

    ;; Assert that the color is valid
    (asserts! (is-eq (len color) u6) ERR-NOT-ENOUGH-COLORS)


    ;; Update tile by adding new item to list
    (map-set tile {canvas: current-canvas-index, tile: position} 
      (list {
        color: color,
        collection: none,
        owner: tx-sender
      })
    )

    ;; Update canvas-meta by merging current-canvas-meta with appended placed-tiles
    (ok (map-set canvas-meta current-canvas-index 
      (merge 
        current-canvas-meta 
        { placed-tiles: (unwrap! (as-max-len? (append current-placed-tiles position) u5000) ERR-TILE-LIST-OVERFLOW) }
      )
    ))

  )
)

;;;;;;;;;;;;;;;;;;;;;;;;
;; Admin Replace Tile ;;
;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;
;;;; Helper Funcs ;;;;
;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;