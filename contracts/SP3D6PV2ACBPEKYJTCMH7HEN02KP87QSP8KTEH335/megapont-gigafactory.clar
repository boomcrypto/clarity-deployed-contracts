;; Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u401))
(define-constant ERR-NOT-FOUND (err u404))
(define-constant ERR-LISTING (err u507))
(define-constant ERR-WRONG-COMPONENT (err u509))
(define-constant ERR-INTERACTING (err u510))
(define-constant SCRAPYARD .scrapyard)

;; Storage
;; groups is a map of id to group
;; groups are as follows:
;; 1 = mouth
;; 2 = jewellery
;; 3 = head
;; 4 = eyes
;; 5 = ears
;; 6 = body
;; 7 = background
(define-map groups uint uint)
;; component-collection is a mapping of id
;; to the contract
(define-map component-collection uint principal)
;; robot-collection is a mapping of id
;; to the contract
(define-map robot-collection uint principal)
(define-map robot-names uint (string-ascii 80))
(define-map robot-sequence uint {mouth: uint, jewellery: uint, head: uint, eyes: uint, ears: uint, body: uint, background: uint})

;; These set the int counters for the Robot and Components that are used to determine
;; what contracts should be called for upgrades and burn.
(define-data-var v1-component-last-id uint u0)
(define-data-var v1-robot-last-id uint u0)

(define-private (set-group (entry {i: uint, g: uint}))
  (map-set groups (get i entry) (get g entry)))

(define-private (update-robot-sequence
    (id uint) (mouth uint) (jewellery uint) (head uint) (eyes uint) (ears uint)
    (body uint) (background uint))
  (map-set robot-sequence id {
      mouth: mouth,
      jewellery: jewellery,
      head: head,
      eyes: eyes,
      ears: ears,
      body: body,
      background: background
      }))

(define-private (called-by-robot-owner (id uint))
    (if (<= id (var-get v1-robot-last-id))
      (is-eq tx-sender (unwrap-panic (unwrap-panic (contract-call? .megapont-robot-nft get-owner id))))
      (is-eq tx-sender (unwrap-panic (unwrap-panic (contract-call? .megapont-robot-expansion-nft get-owner id))))
    ))

(define-private (is-listed (id uint))
    (if (<= id (var-get v1-robot-last-id))
      (not (is-none (contract-call? .megapont-robot-nft get-listing-in-ustx id)))
      (not (is-none (contract-call? .megapont-robot-expansion-nft get-listing-in-ustx id)))
    ))

(define-private (scrap-component (id uint))
    (if (<= id (var-get v1-component-last-id))
      (contract-call? .megapont-robot-component-nft transfer id tx-sender SCRAPYARD)
      (contract-call? .megapont-robot-component-expansion-nft transfer id tx-sender SCRAPYARD)
    ))

(define-read-only (get-sequence (id uint))
  (if (and (<= id (var-get v1-robot-last-id)) (is-none (map-get? robot-sequence id)))
    (contract-call? .megapont-robot-nft get-sequence id)
    (default-to {mouth: u0, jewellery: u0, head: u0, eyes: u0, ears: u0, body: u0, background: u0}
      (map-get? robot-sequence id)))
)

(define-read-only (get-name (id uint))
  (if (and (<= id (var-get v1-robot-last-id)) (is-none (map-get? robot-names id)))
    (contract-call? .megapont-robot-nft get-name id)
    (default-to ""
      (map-get? robot-names id)))
)

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

(define-public (upgrade (id uint) (mouth uint) (jewellery uint) (head uint) (eyes uint) (ears uint) (body uint) (background uint) (name (string-ascii 80)))
(let ((sequence-mapping (get-sequence id)))
    (asserts! (called-by-robot-owner id) ERR-NOT-AUTHORIZED)
    (asserts! (is-eq false (is-listed id)) ERR-LISTING)
    (try! (valid-sequence mouth jewellery head eyes ears body background))
    (and (not (is-eq (get mouth sequence-mapping) mouth)) (> mouth u0) (try! (scrap-component mouth)))
    (and (not (is-eq (get jewellery sequence-mapping) jewellery)) (> jewellery u0) (try! (scrap-component jewellery)))
    (and (not (is-eq (get head sequence-mapping) head)) (> head u0) (try! (scrap-component head)))
    (and (not (is-eq (get eyes sequence-mapping) eyes)) (> eyes u0) (try! (scrap-component eyes)))
    (and (not (is-eq (get ears sequence-mapping) ears)) (> ears u0) (try! (scrap-component ears)))
    (and (not (is-eq (get body sequence-mapping) body)) (> body u0) (try! (scrap-component body)))
    (and (not (is-eq (get background sequence-mapping) background)) (> background u0) (try! (scrap-component background)))
    (update-robot-sequence id mouth jewellery head eyes ears body background)
    (and (not (is-eq (get-name id) name)) (map-set robot-names id name))
    (ok true)))

(define-public (set-group-many (entries (list 1000 {i: uint, g: uint})))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (map set-group entries)
    (ok true)))

;; Used to rename robots that might have otherwise offensive names
;; Not particulary web3, but required to avoid abuse
(define-public (override-name (id uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (map-set robot-names id "MALFUNCTION")
    (ok true)))

;; Used to override the robot sequence this is may never be required
;; but in the event something goes wrong we want to be able to fix
;; the sequence.
(define-public (override-sequence (id uint) (mouth uint) (jewellery uint) (head uint) (eyes uint) (ears uint) (body uint) (background uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (update-robot-sequence id mouth jewellery head eyes ears body background)
    (ok true)))

(let ((last-minted-v1-robot-id (unwrap! (contract-call? .megapont-robot-nft get-last-token-id) ERR-INTERACTING)))
  (var-set v1-robot-last-id last-minted-v1-robot-id))

(let ((last-minted-v1-component-id (unwrap! (contract-call? .megapont-robot-component-nft get-last-token-id) ERR-INTERACTING)))
  (var-set v1-component-last-id last-minted-v1-component-id))
