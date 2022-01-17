(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

;; Non Fungible Token, using sip-009
(define-non-fungible-token animal-stacks uint)

;; Storage
(define-map tokens-count
  principal
  uint)

;; Constants
(define-constant ERR-ALL-MINTED u101)
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED u401)
(define-constant ERR-MINT-NOT-ENABLED (err u1004))
(define-constant MINT-LIMIT u2100)

;; Internal variables
(define-data-var last-id uint u0)
(define-data-var uri-prefix (string-ascii 256) "")
(define-data-var cost-per-mint uint u2000000) ;;initial. Will be changed to 25 stx after launch of contract
(define-data-var commission-per-mint uint u1250000)
(define-data-var payout uint u0)
(define-data-var ipfs-full-metadata (string-ascii 113) "ipfs://ipfs/bafybeiemjzstlulp736mjtpeyah4t66uqox2qctbvsjvk24pfumo4dhiim/animal_stacks/animal_stacks_metadata.json")
(define-data-var ipfs-root (string-ascii 100) "ipfs://ipfs/bafybeievvgmobm44fowl3n3rzofcp2mdfpq65t6iwh5syqkalxapueqwte/animal_stacks/animal_stacks_")
(define-data-var artist-address principal 'SP3H8JBZH62417NRMMFTKVN7HTE6R93R906VNDJA6)
(define-data-var minting-enabled bool true)

(define-public (claim)
  (mint tx-sender))

(define-public (claim-five)
  (begin
    (try! (mint tx-sender))
    (try! (mint tx-sender))
    (try! (mint tx-sender))
    (try! (mint tx-sender))
    (try! (mint tx-sender))
    (ok true)
  )
)

(define-public (claim-ten)
  (begin
    (try! (mint tx-sender))
    (try! (mint tx-sender))
    (try! (mint tx-sender))
    (try! (mint tx-sender))
    (try! (mint tx-sender))
    (try! (mint tx-sender))
    (try! (mint tx-sender))
    (try! (mint tx-sender))
    (try! (mint tx-sender))
    (try! (mint tx-sender))
    (ok true)
  )
)

;; Gets the amount of tokens owned by the specified address.
(define-private (balance-of (account principal))
  (default-to u0 (map-get? tokens-count account)))

;; Internal - Register token
(define-private (mint (new-owner principal))
  (let (
        (next-id (+ u1 (var-get last-id)))  
        (count (var-get last-id))
      )
      (asserts! (is-eq (var-get minting-enabled) true) ERR-MINT-NOT-ENABLED)
      (asserts! (< count MINT-LIMIT) (err ERR-ALL-MINTED))
        (match (stx-transfer? (var-get cost-per-mint) tx-sender (as-contract tx-sender))
          success (begin
            (try! (nft-mint? animal-stacks next-id new-owner))
            (var-set last-id next-id)
            (var-set payout (- (var-get cost-per-mint) (var-get commission-per-mint)))
            (try! (as-contract (stx-transfer? (var-get payout) (as-contract tx-sender) (var-get artist-address))))
            (ok next-id)
          ) 
          error (err error)
          )
          )
        )

;; Public functions

;; Allows contract owner to change mint price
(define-public (set-cost-per-mint (value uint))
  (if (is-eq tx-sender CONTRACT-OWNER)
    (ok (var-set cost-per-mint value))
    (err ERR-NOT-AUTHORIZED)
  )
)

;; Allows contract owner to change mint price
(define-public (set-commission-per-mint (value uint))
  (if (is-eq tx-sender CONTRACT-OWNER)
    (ok (var-set commission-per-mint value))
    (err ERR-NOT-AUTHORIZED)
  )
)

;; Allows contract owner to change artist address if need be
(define-public (set-artist-address (value principal))
  (if (is-eq tx-sender CONTRACT-OWNER)
    (ok (var-set artist-address value))
    (err ERR-NOT-AUTHORIZED)
  )
)

;; Turn minting on
(define-public (set-minting-enabled)
  (if (is-eq tx-sender CONTRACT-OWNER)
    (ok (var-set minting-enabled true))
    (err ERR-NOT-AUTHORIZED)
  )
)

;; Turn minting off
(define-public (set-minting-disabled)
  (if (is-eq tx-sender CONTRACT-OWNER)
    (ok (var-set minting-enabled false))
    (err ERR-NOT-AUTHORIZED)
  )
)

;; Transfers tokens to a specified principal.
(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (if (and
        (is-eq tx-sender sender))
      ;; Make sure to replace MY-OWN-NFT
      (match (nft-transfer? animal-stacks token-id sender recipient)
        success (ok success)
        error (err error))
      (err u500)))

;; Transfers stx from contract to contract owner
(define-public (transfer-stx (address principal) (amount uint))
  (if (is-eq tx-sender CONTRACT-OWNER)
    (as-contract (stx-transfer? amount (as-contract tx-sender) address))
    (err ERR-NOT-AUTHORIZED)
  )
)

;; Gets the owner of the specified token ID.
(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? animal-stacks token-id)))

;; Gets the owner of the specified token ID.
(define-read-only (get-last-token-id)
  (ok (var-get last-id)))

(define-read-only (get-contract-metadata)
  (ok (some (var-get ipfs-full-metadata)))
)

(define-read-only (get-token-uri (token-id uint))
  (ok (some (concat (concat (var-get ipfs-root) (unwrap-panic (contract-call? .conversion lookup token-id))) "_metadata.json")))
)

(begin
  (try! (mint 'SPS0K18XF9XS1501YSBVGAS2Q96HK66N6EJ8QNKK))
  (try! (mint 'SPS0K18XF9XS1501YSBVGAS2Q96HK66N6EJ8QNKK))
  (try! (mint 'SPS0K18XF9XS1501YSBVGAS2Q96HK66N6EJ8QNKK))
  (try! (mint 'SPS0K18XF9XS1501YSBVGAS2Q96HK66N6EJ8QNKK))
  (try! (mint 'SPS0K18XF9XS1501YSBVGAS2Q96HK66N6EJ8QNKK))
  (try! (mint 'SPS0K18XF9XS1501YSBVGAS2Q96HK66N6EJ8QNKK))
  (try! (mint 'SPS0K18XF9XS1501YSBVGAS2Q96HK66N6EJ8QNKK))
  (try! (mint 'SPS0K18XF9XS1501YSBVGAS2Q96HK66N6EJ8QNKK))
  (try! (mint 'SPS0K18XF9XS1501YSBVGAS2Q96HK66N6EJ8QNKK))
  (try! (mint 'SPS0K18XF9XS1501YSBVGAS2Q96HK66N6EJ8QNKK))
  (try! (mint 'SPS0K18XF9XS1501YSBVGAS2Q96HK66N6EJ8QNKK))
  (try! (mint 'SPS0K18XF9XS1501YSBVGAS2Q96HK66N6EJ8QNKK))
  (try! (mint 'SPS0K18XF9XS1501YSBVGAS2Q96HK66N6EJ8QNKK))
  (try! (mint 'SPS0K18XF9XS1501YSBVGAS2Q96HK66N6EJ8QNKK))
  (try! (mint 'SPS0K18XF9XS1501YSBVGAS2Q96HK66N6EJ8QNKK))
  (try! (mint 'SPS0K18XF9XS1501YSBVGAS2Q96HK66N6EJ8QNKK))
  (try! (mint 'SPS0K18XF9XS1501YSBVGAS2Q96HK66N6EJ8QNKK))
  (try! (mint 'SPS0K18XF9XS1501YSBVGAS2Q96HK66N6EJ8QNKK))
  (try! (mint 'SPS0K18XF9XS1501YSBVGAS2Q96HK66N6EJ8QNKK))
  (try! (mint 'SPS0K18XF9XS1501YSBVGAS2Q96HK66N6EJ8QNKK))
  (try! (mint 'SP3H8JBZH62417NRMMFTKVN7HTE6R93R906VNDJA6))
  (try! (mint 'SP3H8JBZH62417NRMMFTKVN7HTE6R93R906VNDJA6))
  (try! (mint 'SP3H8JBZH62417NRMMFTKVN7HTE6R93R906VNDJA6))
  (try! (mint 'SP3H8JBZH62417NRMMFTKVN7HTE6R93R906VNDJA6))
  (try! (mint 'SP3H8JBZH62417NRMMFTKVN7HTE6R93R906VNDJA6))
  (try! (mint 'SP3H8JBZH62417NRMMFTKVN7HTE6R93R906VNDJA6))
  (try! (mint 'SP3H8JBZH62417NRMMFTKVN7HTE6R93R906VNDJA6))
  (try! (mint 'SP3H8JBZH62417NRMMFTKVN7HTE6R93R906VNDJA6))
  (try! (mint 'SP3H8JBZH62417NRMMFTKVN7HTE6R93R906VNDJA6))
  (try! (mint 'SP3H8JBZH62417NRMMFTKVN7HTE6R93R906VNDJA6))
  (ok true)
)