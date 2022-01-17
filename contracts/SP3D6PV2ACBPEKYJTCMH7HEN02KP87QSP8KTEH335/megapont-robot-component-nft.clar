(impl-trait .nft-trait.nft-trait)
(use-trait commission-trait .commission-trait.commission)

(define-non-fungible-token Megapont-Robot-Component uint)
(define-map groups uint uint)

;; Storage
(define-map token-count principal uint)
(define-map market uint {price: uint, commission: principal})

;; Define Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-SOLD-OUT (err u300))
(define-constant ERR-ALL-CLAIMED (err u302))
(define-constant ERR-WRONG-COMMISSION (err u301))
(define-constant ERR-NOT-AUTHORIZED (err u401))
(define-constant ERR-NOT-FOUND (err u404))
(define-constant ERR-METADATA-FROZEN (err u505))
(define-constant ERR-MINT-ALREADY-SET (err u506))
(define-constant ERR-BURNER-ALREADY-SET (err u506))
(define-constant ERR-LISTING (err u507))
(define-constant NOT-CALLED-FROM-BURNER (err u508))
(define-constant ERR-WRONG-COMPONENT (err u509))

(define-constant PUBLIC-COMPONENT-LIMIT u50000)
(define-constant RESERVED-LIMIT u12500)

;; Withdraw wallets
(define-constant WALLET_1 'SP39E0V32MC31C5XMZEN1TQ3B0PW2RQSJB8TKQEV9)
(define-constant WALLET_2 'SP1C39PEYB976REP9B19QMFDJHHF27A63WANDGTX4)
(define-constant WALLET_3 'SP11QRBEVACSP2MAYB1FE64PZGXXRWE4R3HY5E68H)

;; Define Variables
(define-data-var last-id uint u0)
(define-data-var metadata-frozen bool false)
(define-data-var base-uri (string-ascii 80) "https://api.megapont.com/components/{id}")
(define-constant contract-uri "ipfs://QmaSFU43Zy9ApVu85P9Z2k8rmP4W1vUgCkefJatL8xLrD3")
(define-map mint-address bool principal)
(define-map burner-address bool principal)
;; Mint counters for both Ape components and bought components
(define-data-var claim-count uint u0)
(define-data-var bought-count uint u0)


;; Token count for account
(define-read-only (get-balance (account principal))
  (default-to u0
    (map-get? token-count account)))

(define-private (trnsfr (id uint) (sender principal) (recipient principal))
  (match (nft-transfer? Megapont-Robot-Component id sender recipient)
        success
          (let
            ((sender-balance (get-balance sender))
            (recipient-balance (get-balance recipient)))
              (map-set token-count
                    sender
                    (- sender-balance u1))
              (map-set token-count
                    recipient
                    (+ recipient-balance u1))
              (ok success))
        error (err error)))

;; SIP009: Transfer token to a specified principal
(define-public (transfer (id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (called-by-operator id) ERR-NOT-AUTHORIZED)
    (asserts! (is-none (map-get? market id)) ERR-LISTING)
    (trnsfr id sender recipient)))

;; SIP009: Get the owner of the specified token ID
(define-read-only (get-owner (id uint))
  (ok (nft-get-owner? Megapont-Robot-Component id)))

;; SIP009: Get the last token ID
(define-read-only (get-last-token-id)
  (ok (var-get last-id)))

;; SIP009: Get the token URI. You can set it to any other URI
(define-read-only (get-token-uri (id uint))
  (ok (some (var-get base-uri))))

(define-read-only (get-contract-uri)
  (ok contract-uri))

(define-read-only (get-sold-count)
  (ok (var-get bought-count)))

(define-read-only (get-claim-count)
  (ok (var-get claim-count)))

(define-private (mnt (new-owner principal) (paid bool))
 (let ((next-id (+ u1 (var-get last-id))))
      (asserts! (called-from-mint) ERR-NOT-AUTHORIZED)
      (asserts! (< (var-get bought-count) PUBLIC-COMPONENT-LIMIT) ERR-SOLD-OUT)
      (match (nft-mint? Megapont-Robot-Component next-id new-owner)
        success
        (let
        ((current-balance (get-balance new-owner)))
          (begin
            (and paid
              (begin
                (try! (stx-transfer? u1860000 tx-sender WALLET_1))
                (try! (stx-transfer? u1740000 tx-sender WALLET_2))
                (try! (stx-transfer? u400000 tx-sender WALLET_3))
              ))
            (var-set last-id next-id)
            (if paid
              (var-set bought-count (+ u1 (var-get bought-count)))
              (var-set claim-count (+ u1 (var-get claim-count)))
              )
            (map-set token-count
              new-owner
              (+ current-balance u1)
            )
            (ok true)))
        error (err (* error u10000)))))

;; Mint new NFT
;; can only be called from the Mint
(define-public (mint (new-owner principal))
  (begin
    (asserts! (< (var-get bought-count) PUBLIC-COMPONENT-LIMIT) ERR-SOLD-OUT)
    (mnt new-owner true)))

(define-public (freebie-mint (new-owner principal))
  (begin
    (asserts! (< (var-get claim-count) RESERVED-LIMIT) ERR-ALL-CLAIMED)
    (mnt new-owner false)))

(define-private (called-by-operator (id uint))
  (let ((owner (unwrap! (nft-get-owner? Megapont-Robot-Component id) false)))
    (or (is-eq tx-sender owner) (is-eq contract-caller owner))))

(define-read-only (get-listing-in-ustx (id uint))
  (map-get? market id))

(define-public (list-in-ustx (id uint) (price uint) (comm <commission-trait>))
  (let ((listing  {price: price, commission: (contract-of comm)}))
    (asserts! (called-by-operator id) ERR-NOT-AUTHORIZED)
    (map-set market id listing)
    (print (merge listing {action: "list-in-ustx", id: id}))
    (ok true)))

(define-public (unlist-in-ustx (id uint))
  (begin
    (asserts! (called-by-operator id) ERR-NOT-AUTHORIZED)
    (map-delete market id)
    (print {action: "unlist-in-ustx", id: id})
    (ok true)))

(define-public (buy-in-ustx (id uint) (comm <commission-trait>))
  (let ((owner (unwrap! (nft-get-owner? Megapont-Robot-Component id) ERR-NOT-FOUND))
      (listing (unwrap! (map-get? market id) ERR-LISTING))
      (price (get price listing)))
    (asserts! (is-eq (contract-of comm) (get commission listing)) ERR-WRONG-COMMISSION)
    (try! (stx-transfer? price tx-sender owner))
    (try! (contract-call? comm pay id price))
    (try! (trnsfr id owner tx-sender))
    (map-delete market id)
    (print {action: "buy-in-ustx", id: id})
    (ok true)))

;; Set base uri
(define-public (set-base-uri (new-base-uri (string-ascii 80)))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (asserts! (not (var-get metadata-frozen)) ERR-METADATA-FROZEN)
    (var-set base-uri new-base-uri)
    (ok true)))

;; Freeze metadata
(define-public (freeze-metadata)
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (var-set metadata-frozen true)
    (ok true)))

;; Manage the Mint
(define-private (called-from-mint)
  (let ((the-mint
          (unwrap! (map-get? mint-address true)
                    false)))
    (is-eq contract-caller the-mint)))

(define-private (called-from-burner)
  (let ((the-burn
          (unwrap! (map-get? burner-address true)
                    false)))
    (is-eq contract-caller the-burn)))

;; can only be called once
(define-public (set-mint-address)
  (let ((the-mint (map-get? mint-address true)))
    (asserts! (and (is-none the-mint)
              (map-insert mint-address true tx-sender))
                ERR-MINT-ALREADY-SET)
    (ok tx-sender)))

;; can only be called once
(define-public (set-burner-address)
  (let ((the-burner (map-get? burner-address true)))
    (asserts! (and (is-none the-burner)
              (map-insert burner-address true tx-sender))
                ERR-BURNER-ALREADY-SET)
    (ok tx-sender)))

;; Burns a component
(define-public (burn (id uint) (owner principal))
  (begin
    (asserts! (called-from-burner) NOT-CALLED-FROM-BURNER)
    (asserts! (is-eq (unwrap! (nft-get-owner? Megapont-Robot-Component id) ERR-NOT-FOUND) owner) ERR-NOT-AUTHORIZED)
    (asserts! (is-none (map-get? market id)) ERR-LISTING)
    (nft-burn? Megapont-Robot-Component id owner)))

(define-private (set-group (entry {i: uint, g: uint}))
  (map-set groups (get i entry) (get g entry)))

(define-public (set-group-many (entries (list 1000 {i: uint, g: uint})))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (map set-group entries)
    (ok true)))

(define-read-only (valid-sequence (mouth uint) (jewellery uint) (head uint) (eyes uint) (ears uint) (body uint) (background uint))
  (begin
    (asserts! (or (is-eq mouth u0) (is-eq (unwrap! (map-get? groups mouth) ERR-NOT-FOUND) u1)) ERR-WRONG-COMPONENT)
    (asserts! (or (is-eq jewellery u0) (is-eq (unwrap! (map-get? groups jewellery) ERR-NOT-FOUND) u2)) ERR-WRONG-COMPONENT)
    (asserts! (or (is-eq head u0) (is-eq (unwrap! (map-get? groups head) ERR-NOT-FOUND) u3)) ERR-WRONG-COMPONENT)
    (asserts! (or (is-eq eyes u0) (is-eq (unwrap! (map-get? groups eyes) ERR-NOT-FOUND) u4)) ERR-WRONG-COMPONENT)
    (asserts! (or (is-eq ears u0) (is-eq (unwrap! (map-get? groups ears) ERR-NOT-FOUND) u5)) ERR-WRONG-COMPONENT)
    (asserts! (or (is-eq body u0)  (is-eq (unwrap! (map-get? groups body) ERR-NOT-FOUND) u6)) ERR-WRONG-COMPONENT)
    (asserts! (or (is-eq background u0) (is-eq (unwrap! (map-get? groups background) ERR-NOT-FOUND) u7)) ERR-WRONG-COMPONENT)
    (ok true)))
