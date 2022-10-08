;;
;; collectible (c) TRUBIT.TECH 2022
;;

(define-non-fungible-token collectible uint)

(define-constant CONTRACT-CREATOR tx-sender)

(define-constant ERR-NOT-AUTHORIZED (err u0))

(define-data-var token-uri (string-ascii 256) "https://sspblsjcforgiuatmnbp.nhost.run/v1/functions/rewards/stacks/metadata?id=3892979")

(define-data-var last-id uint u0)

(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) ERR-NOT-AUTHORIZED)
    (nft-transfer? collectible token-id sender recipient)
  )
)

(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? collectible token-id))
)

(define-read-only (get-last-token-id)
  (ok (var-get last-id))
)

(define-read-only (get-token-uri (token-id uint))
  (ok (some (var-get token-uri)))
)

(define-public (mint (token-id uint) (recipient principal))
  (begin
    (asserts! (or (is-eq tx-sender CONTRACT-CREATOR) (is-eq tx-sender 'ST3AX0XG7Y00HPKESYHRTH58QHN06EMNW6NHJMNE2)) ERR-NOT-AUTHORIZED)
    (try! (nft-mint? collectible token-id recipient))
    (var-set last-id token-id)
    (ok true)
  )
)

(define-public (set-token-uri (new-token-uri (string-ascii 256)))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-CREATOR) (err ERR-NOT-AUTHORIZED))
    (var-set token-uri new-token-uri)
    (ok true)
  )
)