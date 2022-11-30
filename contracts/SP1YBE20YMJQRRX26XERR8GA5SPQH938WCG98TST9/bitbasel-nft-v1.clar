;; bitbasel nft
;; contractType: public

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token Bitbasel uint)

;; Constants
;;

;; Deployer
(define-constant DEPLOYER tx-sender)

;; Errors
(define-constant ERR-NOT-AUTHORIZED u100)
(define-constant ERR-MINTING-PAUSED u101)
(define-constant ERR-TOKEN-NOT-FOUND u102)
(define-constant ERR-INVALID-ROYALTY-BIPS u103)
(define-constant ERR-LISTING-NOT-FOUND u104)
(define-constant ERR-ROYALTIES-NOT-FOUND u105)
(define-constant ERR-WRONG-COMMISSION u106)

;; Variables & State Management
;;

;; Admins / Contract Owners
(define-map admins principal bool)

;; Global Control
(define-data-var is-minting-paused bool true)

;; Minting Allowlist
(define-map allowlist principal bool)

;; NFT Functional State
(define-data-var last-token-id uint u1)

;; URI i.e. metadata URI
;; Token Minters, i.e. Artists
;; Royalties
(define-map token-metadata uint {
  uri: (string-ascii 256),
  minter: principal,
  royalty: {receiver: principal, bips: uint}
})

;; Assert Conditions
;;
(define-private (is-admin-sender)
  (or (unwrap! (map-get? admins tx-sender) false)
      (unwrap! (map-get? admins contract-caller) false)
  )
)
(define-private (is-minting-active)
  (not (var-get is-minting-paused))
)
(define-private (is-allowlisted-sender)
  (unwrap! (map-get? allowlist tx-sender) false)
)
(define-private (is-token-known (token-id uint))
  (is-some (map-get? token-metadata token-id))
)
(define-private (is-nft-minter-sender (token-id uint))
  (is-eq
    tx-sender
    (get minter (unwrap! (map-get? token-metadata token-id) false))
  )
)
(define-private (is-nft-owner-sender (token-id uint))
  (let (
      (nft-owner (unwrap! (nft-get-owner? Bitbasel token-id) false))
    )
    (or (is-eq tx-sender nft-owner)
        (is-eq contract-caller nft-owner)
    )
  )
)
(define-private (is-nft-royalty-receiver-sender (token-id uint))
  (let (
      (token (unwrap! (map-get? token-metadata token-id) false))
      (royalty-receiver (get receiver (get royalty token)))
    )
    (or (is-eq tx-sender royalty-receiver)
        (is-eq contract-caller royalty-receiver)
    )
  )
)

;; Functions
;;

;; Toggle Paused
(define-public (toggle-minting-paused)
  (begin
    (asserts! (is-admin-sender) (err ERR-NOT-AUTHORIZED))
    (ok (var-set is-minting-paused (not (var-get is-minting-paused))))
  )
)

;; Mint
(define-public (mint (uri (string-ascii 256)) (royalty-bips uint))
  (begin
    (asserts! (is-minting-active) (err ERR-MINTING-PAUSED))
    (asserts! (is-allowlisted-sender) (err ERR-NOT-AUTHORIZED))
    (let (
        (minter tx-sender)
        (next-id (+ u1 (var-get last-token-id)))
        (count (var-get last-token-id))
      )
      (match (nft-mint? Bitbasel next-id minter)
        success
        (begin
          (var-set last-token-id next-id)
          (map-set token-metadata next-id {
            uri: uri,
            minter: minter,
            royalty: {receiver: minter, bips: royalty-bips}
          })
          (set-address-allowlisted minter false)
          ;; ;; TODO: Unwrap with error handlers instead of try
          ;; (try! (set-royalty-bips next-id royalty-bips))
          (ok next-id)
        )

        error
        (err error)
      )
    )
  )
)

;; SIP009
;;

;; read-only

;; SIP009: get-last-token-id
(define-read-only (get-last-token-id)
  (ok (var-get last-token-id))
)

;; SIP009: get-token-uri
(define-read-only (get-token-uri (token-id uint))
  (let (
      (token (unwrap!
        (map-get? token-metadata token-id)
        (ok none)
      ))
    )
    (ok (some (get uri token)))
  )
)

;; SIP009
(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? Bitbasel token-id))
)

;; public

;; SIP-009: transfer
(define-public
  (transfer
    (token-id uint)
    (sender principal)
    (recipient principal)
  )
  (begin
    (asserts! (is-token-known token-id) (err ERR-TOKEN-NOT-FOUND))
    (asserts! (is-nft-owner-sender token-id) (err ERR-NOT-AUTHORIZED))

    ;; invalidate current listings if the seller transfers the NFT
    (map-delete market token-id)

    (nft-transfer? Bitbasel token-id sender recipient)
  )
)


;; ADMIN LIST FUNCTIONS START
(define-private (set-address-is-admin (address principal) (value bool))
  (map-set admins address value)
)
(define-public (add-address-to-admins (address principal))
  (begin
    (asserts! (is-admin-sender) (err ERR-NOT-AUTHORIZED))
    (ok (set-address-is-admin address true))
  )
)
(define-public (remove-address-from-admins (address principal))
  (begin
    (asserts! (is-admin-sender) (err ERR-NOT-AUTHORIZED))
    (ok (set-address-is-admin address false))
  )
)
;; ADMIN LIST FUNCTIONS END


;; ALLOWLIST FUNCTIONS START
(define-private (set-address-allowlisted (address principal) (value bool))
  (map-set allowlist address value)
)
(define-public (add-address-to-allowlist (address principal))
  (begin
    (asserts! (is-admin-sender) (err ERR-NOT-AUTHORIZED))
    (ok (set-address-allowlisted address true))
  )
)
(define-public (add-address-list-to-allowlist (addresses (list 25 principal)))
  (begin
    (asserts! (is-admin-sender) (err ERR-NOT-AUTHORIZED))
    (ok (fold set-address-allowlisted addresses true))
  )
)
(define-public (remove-address-from-allowlist (address principal))
  (begin
    (asserts! (is-admin-sender) (err ERR-NOT-AUTHORIZED))
    (ok (set-address-allowlisted address false))
  )
)
;; ALLOWLIST FUNCTIONS END


;; ROYALTIES FUNCTIONS START
(define-private (is-valid-royalty-bips (royalty-bips uint))
  (and (>= royalty-bips u0) (<= royalty-bips u10000))
)

(define-read-only (get-royalty-bips (token-id uint))
  (let (
      (token (unwrap!
        (map-get? token-metadata token-id)
        (err ERR-TOKEN-NOT-FOUND)
      ))
    )
    (ok (get bips (get royalty token)))
  )
)

(define-public (set-royalty-bips (token-id uint) (royalty-bips uint))
  (let (
      (token (unwrap!
        (map-get? token-metadata token-id)
        (err ERR-TOKEN-NOT-FOUND)
      ))
    )
    (asserts!
      (or (is-nft-royalty-receiver-sender token-id)
          (is-nft-minter-sender token-id)
      )
      (err ERR-NOT-AUTHORIZED)
    )
    (asserts!
      (is-valid-royalty-bips royalty-bips)
      (err ERR-INVALID-ROYALTY-BIPS)
    )
    (let (
        (royalty (get royalty token))
      )
      (ok (map-set token-metadata token-id
        (merge token {
          royalty: (merge royalty {
            bips: royalty-bips
          })
        })
      ))
    )
  )
)
;; ROYALTIES FUNCTIONS END


;; NON-CUSTODIAL FUNCTIONS START

(use-trait commission-trait 'SP1YBE20YMJQRRX26XERR8GA5SPQH938WCG98TST9.bitbasel-traits-v1.commission-trait)

(define-map market uint {
  seller: principal,
  price: uint,
  commission: principal,
  royalty: {receiver: principal, bips: uint}
})

(define-private
  (pay-royalty
    (royalty-receiver principal)
    (royalty-bips uint)
    (price uint)
  )
  (let ((royalty-amount (/ (* price royalty-bips) u10000)))
    (ok (if (> royalty-amount u0)
      ;; TODO: Unwrap with error handlers instead of try
      (try! (stx-transfer? royalty-amount tx-sender royalty-receiver))
      true
    ))
  )
)

;; Non-custodial marketplace transfer
(define-private
  (non-custodial-transfer
    (token-id uint)
    (sender principal)
    (recipient principal)
  )
  (nft-transfer? Bitbasel token-id sender recipient)
)

(define-read-only (get-listing-in-ustx (token-id uint))
  (map-get? market token-id)
)

(define-public (list-in-ustx
  (token-id uint)
  (price uint)
  (comm-trait <commission-trait>)
)
  (let (
      (token
        (unwrap! (map-get? token-metadata token-id) (err ERR-TOKEN-NOT-FOUND))
      )
    )
    (asserts! (is-nft-owner-sender token-id) (err ERR-NOT-AUTHORIZED))
    (let (
        (royalty (get royalty token))
        (royalty-receiver (get receiver royalty))
        (royalty-bips (get bips royalty))
        (listing {
          seller: tx-sender,
          price: price,
          commission: (contract-of comm-trait),
          royalty: {receiver: royalty-receiver, bips: royalty-bips}
        })
      )
      (map-set market token-id listing)
      (ok (print (merge listing {a: "list-in-ustx", token-id: token-id})))
    )
  )
)

(define-public (unlist-in-ustx (token-id uint))
  (begin
    (asserts! (is-token-known token-id) (err ERR-TOKEN-NOT-FOUND))
    (asserts! (is-nft-owner-sender token-id) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-some (map-get? market token-id)) (err ERR-LISTING-NOT-FOUND))
    (map-delete market token-id)
    (ok (print {a: "unlist-in-ustx", token-id: token-id}))
  )
)

(define-public (buy-in-ustx (token-id uint) (comm-trait <commission-trait>))
  (let (
      (nft-owner
        (unwrap!
          (nft-get-owner? Bitbasel token-id)
          (err ERR-TOKEN-NOT-FOUND)
        )
      )
      (listing (unwrap! (map-get? market token-id) (err ERR-LISTING-NOT-FOUND)))
      (seller (get seller listing))
      (price (get price listing))
      (royalty (get royalty listing))
      (royalty-receiver (get receiver royalty))
      (royalty-bips (get bips royalty))
    )
    (asserts!
      (is-eq (contract-of comm-trait) (get commission listing))
      (err ERR-WRONG-COMMISSION)
    )
    ;; TODO: Unwrap with error handlers instead of try
    (try! (stx-transfer? price tx-sender seller))
    (try! (pay-royalty royalty-receiver royalty-bips price))
    (try! (contract-call? comm-trait pay token-id price))
    (try! (non-custodial-transfer token-id seller tx-sender))
    (map-delete market token-id)
    (ok (print {a: "buy-in-ustx", token-id: token-id}))
  )
)
;; NON-CUSTODIAL FUNCTIONS END

;; Initialization
(set-address-is-admin DEPLOYER true)
