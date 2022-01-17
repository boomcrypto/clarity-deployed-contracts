(impl-trait 'SP39HVW6GG1TBGHN4QV03CPGB5VJ62J05WPN85APB.nft-trait.nft-trait)

(define-non-fungible-token stacks-xyyznft uint)

(define-map tokens-count
  principal
  uint)

(define-constant ERR-ALL-MINTED u101)
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED u401)
(define-constant MINT-LIMIT u10)

(define-data-var last-id uint u0)
(define-data-var uri (string-ascii 256) "")
(define-data-var cost-per-mint uint u1000000)

(define-public (claim)
  (mint tx-sender))

(define-private (balance-of (account principal))
  (default-to u0 (map-get? tokens-count account)))

(define-private (mint (new-owner principal))
  (let (
        (next-id (+ u1 (var-get last-id)))  
        (count (var-get last-id))
      )
      (asserts! (< count MINT-LIMIT) (err ERR-ALL-MINTED))
        (match (stx-transfer? (var-get cost-per-mint) tx-sender (as-contract tx-sender))
          success (begin
            (try! (nft-mint? stacks-xyyznft next-id new-owner))
            (var-set last-id next-id)
            (ok next-id)
          ) 
          error (err error)
          )
          )
        )


(define-public (set-cost-per-mint (value uint))
  (if (is-eq tx-sender CONTRACT-OWNER)
    (ok (var-set cost-per-mint value))
    (err ERR-NOT-AUTHORIZED)
  )
)

(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (if (and
        (is-eq tx-sender sender))
      ;; Make sure to replace MY-OWN-NFT
      (match (nft-transfer? stacks-xyyznft token-id sender recipient)
        success (ok success)
        error (err error))
      (err u500)))

(define-public (transfer-stx (address principal) (amount uint))
  (if (is-eq tx-sender CONTRACT-OWNER)
    (as-contract (stx-transfer? amount (as-contract tx-sender) address))
    (err ERR-NOT-AUTHORIZED)
  )
)

(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? stacks-xyyznft token-id)))

(define-read-only (get-last-token-id)
  (ok (var-get last-id)))

(define-read-only (get-token-uri (token-id uint))
  (ok (some (unwrap! (contract-call? 'SP39HVW6GG1TBGHN4QV03CPGB5VJ62J05WPN85APB.xyz-meta get-map token-id) (err u10))))

)

(begin
  (try! (mint 'SP1RX0PMP3J0EDHH4D27PN7277X6SPVDHRD911FM3)))