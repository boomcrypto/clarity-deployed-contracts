(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

;; Non Fungible Token, using sip-009
(define-non-fungible-token stacks-mandelbrots uint)

;; Storage
(define-map tokens-count
  principal
  uint)

;; Constants
(define-constant ERR-ALL-MINTED u101)
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED u401)
(define-constant MINT-LIMIT u1000)

;; Internal variables
(define-data-var last-id uint u0)
(define-data-var uri (string-ascii 256) "")
(define-data-var cost-per-mint uint u80000000)

(define-public (claim)
  (mint tx-sender))

;; Gets the amount of tokens owned by the specified address.
(define-private (balance-of (account principal))
  (default-to u0 (map-get? tokens-count account)))

;; Internal - Register token
(define-private (mint (new-owner principal))
  (let (
        (next-id (+ u1 (var-get last-id)))  
        (count (var-get last-id))
      )
      (asserts! (< count MINT-LIMIT) (err ERR-ALL-MINTED))
        (match (stx-transfer? (var-get cost-per-mint) tx-sender (as-contract tx-sender))
          success (begin
            (try! (nft-mint? stacks-mandelbrots next-id new-owner))
            (var-set last-id next-id)
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

;; Transfers tokens to a specified principal.
(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (if (and
        (is-eq tx-sender sender))
      ;; Make sure to replace MY-OWN-NFT
      (match (nft-transfer? stacks-mandelbrots token-id sender recipient)
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
  (ok (nft-get-owner? stacks-mandelbrots token-id)))

;; Gets the owner of the specified token ID.
(define-read-only (get-last-token-id)
  (ok (var-get last-id)))

(define-read-only (get-token-uri (token-id uint))
  (ok (some (unwrap! (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.mandelbrots-meta get-map token-id) (err u10))))

)

(begin
  (try! (mint 'SP2KKB6Y650VECRSAEEHRWZHPWKTMP2STA9YVA3KC))
  (try! (mint 'SP3EZ3H7H49CEE49X8HE9W6QX0Y29W8R5T1MMY7AJ))
  (try! (mint 'SP25VWGTPR19E344S4ENTHQT8651216EPNABRYE51))
  (try! (mint 'SP25VWGTPR19E344S4ENTHQT8651216EPNABRYE51))
  (try! (mint 'SP262CK3VPG6PDF4S96TTXFBVV9Y9Z75F51A6G83N))
  (try! (mint 'SP3GEJ4062VF7WB7GNTJMS3H2QTKJ64KMAPQM5AAC))
  (try! (mint 'SP1C671AAKE9M5T7BPR7X8F9WRK5W7A4PVMHSSPGZ))
  (try! (mint 'SP19WSDJWTH4CW3YG554XS5CAXJJGAN83P8CFZ4K1))
  (try! (mint 'SP2HS73HXN7K5X4QJ5GK6S4MGDSPH24QWZ4NVRB3G))
  (try! (mint 'SP2009N95GZJWQ7W6QFN4CXKVVCM3HKCY050ZM97Y)))