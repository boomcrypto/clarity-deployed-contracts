;; This contract implements the SIP-009 community-standard Non-Fungible Token trait on mainnet.
(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

;; Define constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-token-owner (err u101))
(define-constant err-not-found (err u102))
(define-constant err-unsupported-tx (err u103))
(define-constant err-out-not-found (err u104))
(define-constant err-in-not-found (err u105))
(define-constant err-tx-not-mined (err u106))

;; Sample link where you would host your token metadata
(define-data-var base-uri (string-ascii 80) "https://your.api.com/path/to/collection/{id}")

;; Define the NFT's name
(define-non-fungible-token Your-NFT-Name uint)

;; Keep track of the last minted token ID
(define-data-var last-token-id uint u0)

;; SIP-009 function: Get the last minted token ID.
(define-read-only (get-last-token-id)
    (ok (var-get last-token-id))
)

;; SIP-009 function: Get link where token metadata is hosted
(define-read-only (get-token-uri (token-id uint))
    (ok (some (var-get base-uri)))
)

;; SIP-009 function: Get the owner of a given token
(define-read-only (get-owner (token-id uint))
    (ok (nft-get-owner? Your-NFT-Name token-id))
)

;; SIP-009 function: Transfer NFT token to another owner.
(define-public (transfer (token-id uint) (sender principal) (recipient principal))
    (begin
        ;; #[filter(sender)]
        (asserts! (is-eq tx-sender sender) err-not-token-owner)
        (nft-transfer? Your-NFT-Name token-id sender recipient)
    )
)

;; Mint a new NFT if a specific bitcoin transaction has been mined.
(define-public (mint (recipient principal) (height uint) (tx (buff 1024)) (header (buff 80)) (proof { tx-index: uint, hashes: (list 14 (buff 32)), tree-depth: uint}))
    (let
        (
            ;; Create the new token ID by incrementing the last minted ID.
            (token-id (+ (var-get last-token-id) u1))
            ;; Calls external contract function to confirm mined status on the supplied bitcoin transaction data. Will return (ok txid)
            (tx-was-mined (contract-call? 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.clarity-bitcoin-lib-v5 was-tx-mined-compact height tx header proof))
        )
        ;; Only the contract owner can mint.
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        ;; Confirms if supplied bitcoin transaction data has been mined or not.
        (asserts! (is-ok tx-was-mined) err-tx-not-mined)
        ;; Mint the NFT and send it to the given recipient.
        (try! (nft-mint? Your-NFT-Name token-id recipient))
        ;; Update the last minted token ID.
        (var-set last-token-id token-id)
        ;; Return a success status and the newly minted NFT ID.
        (ok token-id)
    )
)