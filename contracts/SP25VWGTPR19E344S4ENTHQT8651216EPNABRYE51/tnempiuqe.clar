;; Tnempiuqe(s) NFT
;; This is a test contract for an upcoming NFT!!! :)
;; There is zero metadata in this contract, so it is not a real NFT. 

;; ---------------------------------------------------------------------

;; Tnempiuqe(s)
;; Tnempiuqe for battles are minted when a user burns an existing Package NFT
;; This first release, with a total of 8000 Tnempiuqe(s), maps the initial collection size of Packages(s)

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

;; Defining the Tnempiuqe(s) NFT
(define-non-fungible-token tnempiuqe uint)

;; Need to update to new IPFS
(define-constant ipfs-root "")

;; Admin Principal
(define-constant admin-one tx-sender)

;; Server-Side Principal
(define-constant admin-server 'SP1Y0KTSFKF9R5P762NAZ9T41GEVMQH9FHQRVG81W)

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
(define-constant ERR-GET-OWNER-FAILED (err u108))

;;;;;;;;;;;;;;;;;
;; Vars & Maps ;;
;;;;;;;;;;;;;;;;;

;; Tnempiuqe NFT Index
(define-data-var tnempiuqe-index uint u1)

;; Tnempiuqe Initial Collection Size (8k)
(define-data-var collection-limit-total uint u8001)

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





;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;; SIP09 Functions ;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-read-only (get-last-token-id)
  (ok (var-get tnempiuqe-index))
)

(define-read-only (get-owner (id uint))
  (ok (nft-get-owner? tnempiuqe id))
)

(define-read-only (get-token-uri (token-id uint))
  (ok
    (some
      (concat
        (concat
          ipfs-root
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
    (nft-transfer? tnempiuqe id sender recipient)
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
      (owner (unwrap! (nft-get-owner? tnempiuqe id) false))
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
      (owner (unwrap! (nft-get-owner? tnempiuqe id) ERR-NOT-AUTH))
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

;; @desc function to mint tnempiuqe, only redeemable
(define-public (mint-tnempiuqe (package-id uint ))
  (let
    (
      (current-id (var-get tnempiuqe-index))
      (next-id (+ current-id u1))
    )

    ;; assert that not all minted out
    (asserts! (< current-id (var-get collection-limit-total)) ERR-ALL-MINTED)

    ;; assert that tx-sender is package owner
    (asserts! (is-eq tx-sender (unwrap-panic (unwrap-panic (contract-call? .packages get-owner package-id)))) ERR-GET-OWNER-FAILED)

    ;; burn package NFTs
    (try! (contract-call? .packages burn-package package-id))

    ;; mint package to tx-sender
    (try! (nft-mint? tnempiuqe current-id tx-sender))

    ;; update packages-index
    (ok (var-set tnempiuqe-index next-id))

  )
)



;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;; Help Functions ;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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