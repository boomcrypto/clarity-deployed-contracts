;; citypack-airdrop

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
;; (impl-trait .nft-trait.nft-trait)

;; Non Fungible Token, using sip-009
(define-non-fungible-token citypack-airdrop uint)

;; Constants
(define-constant err-no-more-nfts u300)
(define-constant err-invalid-user u500)
(define-constant mint-limit u15)
(define-constant commission-address tx-sender)
(define-data-var last-id uint u0)

(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/QmPX3w4qogVZPZWaiNxKm4wijPnwoii4BJ91P8Urztv8Ad/")

(define-private (mint (new-owner principal) (next-id uint))
    (match (nft-mint? citypack-airdrop next-id new-owner)
            success
              (begin
                (var-set last-id next-id)
                (ok true))
            error (err error)))

(define-public (claim-for (user principal) (id uint))
  (if (and (is-eq tx-sender commission-address) (<= id mint-limit))
    (mint user id)
    (err err-invalid-user))
)

(define-public (set-ipfs-root (new-ipfs-root (string-ascii 80)))
  (if (is-eq tx-sender commission-address)
    (begin 
      (var-set ipfs-root new-ipfs-root)
      (ok true)
    )
    (err err-invalid-user)))

(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (if (and
        (is-eq tx-sender sender))
      (match (nft-transfer? citypack-airdrop token-id sender recipient)
        success (ok success)
        error (err error))
      (err err-invalid-user)))

;; read-only functions
(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? citypack-airdrop token-id)))

(define-read-only (get-last-token-id)
  (ok (var-get last-id)))

(define-read-only (get-token-uri (token-id uint))
    (ok (some (concat (concat (var-get ipfs-root) "{id}") ".json"))))

(begin
(try! (claim-for 'SP2CNW7ZAQRXPP8KRXM6VCC8H2XS8QNETAMEMBEX9 u1))
(try! (claim-for 'SP2CNW7ZAQRXPP8KRXM6VCC8H2XS8QNETAMEMBEX9 u2))
(try! (claim-for 'SP2CNW7ZAQRXPP8KRXM6VCC8H2XS8QNETAMEMBEX9 u3))
(try! (claim-for 'SP2CNW7ZAQRXPP8KRXM6VCC8H2XS8QNETAMEMBEX9 u4))
(try! (claim-for 'SP2CNW7ZAQRXPP8KRXM6VCC8H2XS8QNETAMEMBEX9 u5))
(try! (claim-for 'SP2CNW7ZAQRXPP8KRXM6VCC8H2XS8QNETAMEMBEX9 u6))
(try! (claim-for 'SP2CNW7ZAQRXPP8KRXM6VCC8H2XS8QNETAMEMBEX9 u7))
(try! (claim-for 'SP2CNW7ZAQRXPP8KRXM6VCC8H2XS8QNETAMEMBEX9 u8))
(try! (claim-for 'SP2CNW7ZAQRXPP8KRXM6VCC8H2XS8QNETAMEMBEX9 u9))
(try! (claim-for 'SP2CNW7ZAQRXPP8KRXM6VCC8H2XS8QNETAMEMBEX9 u10))
(try! (claim-for 'SP2CNW7ZAQRXPP8KRXM6VCC8H2XS8QNETAMEMBEX9 u11))
(try! (claim-for 'SP2CNW7ZAQRXPP8KRXM6VCC8H2XS8QNETAMEMBEX9 u12))
(try! (claim-for 'SP2CNW7ZAQRXPP8KRXM6VCC8H2XS8QNETAMEMBEX9 u13))
(try! (claim-for 'SP2CNW7ZAQRXPP8KRXM6VCC8H2XS8QNETAMEMBEX9 u14))
(try! (claim-for 'SP2CNW7ZAQRXPP8KRXM6VCC8H2XS8QNETAMEMBEX9 u15))
)