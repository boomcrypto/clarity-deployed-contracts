;; stacks-ludenz

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

;; Non Fungible Token, using sip-009
(define-non-fungible-token stacks-ludenz uint)

;; Constants
(define-constant err-no-more-nfts u300)
(define-constant err-invalid-user u500)

(define-constant commission1-address 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S)
(define-constant commission2-address 'SP1PPPCP0Q0GZK3H23JAZSG4TYGYHC3KP81ZHSS3J)

;; Internal variables
(define-data-var mint-limit uint u50)
(define-data-var last-id uint u0)
(define-data-var commission1 uint u700)
(define-data-var commission2 uint u300)
(define-data-var total-price uint u6500)
(define-data-var artist-address principal 'SP9A95KVDHHTNQE7S7F6028RSMBAXF44JXM8PY8D)
(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/QmRjfoZkSyns3614y5YK65HgeKiNcA4UfiH1HWdKtBNByp/")

;; private functions
(define-private (mint (new-owner principal))
  (let ((next-id (+ u1 (var-get last-id)))  
        (count (var-get last-id)))
      (asserts! (< count (var-get mint-limit)) (err err-no-more-nfts))
    (let
      ((total-commission1 (/ (* (var-get total-price) (var-get commission1)) u10000))
       (total-commission2 (/ (* (var-get total-price) (var-get commission2)) u10000))
       (total-artist (- (var-get total-price) (+ total-commission1 total-commission2))))
      (if (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender commission1-address))
        (mint-helper new-owner next-id)
          (begin
            (try! (contract-call?
                    'SP466FNC0P7JWTNM2R9T199QRZN1MYEDTAR0KP27.miamicoin-token
                    send-many
                    (list
                      { to: (var-get artist-address) , amount: total-artist, memo: (some 0x00) }
                      { to: commission1-address , amount: total-commission1, memo: (some 0x00) }
                      { to: commission2-address , amount: total-commission2, memo: (some 0x00) })
            ))
            (mint-helper new-owner next-id)))
    )
  )
)

(define-private (mint-helper (new-owner principal) (next-id uint))
    (match (nft-mint? stacks-ludenz next-id new-owner)
            success
              (begin
                (var-set last-id next-id)
                (ok true))
            error (err error)))

;; public functions
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

(define-public (set-artist-address (address principal))
  (if (is-eq tx-sender commission1-address)
    (begin 
      (var-set artist-address address)
      (ok true)
    )
    (err err-invalid-user)))

(define-public (set-price (price uint))
  (if (is-eq tx-sender commission1-address)
    (begin 
      (var-set total-price price)
      (ok true)
    )
    (err err-invalid-user)))

(define-public (set-ipfs-root (new-ipfs-root (string-ascii 80)))
  (if (is-eq tx-sender commission1-address)
    (begin 
      (var-set ipfs-root new-ipfs-root)
      (ok true)
    )
    (err err-invalid-user)))

(define-public (set-mint-limit (new-mint-limit uint))
  (if (is-eq tx-sender commission1-address)
    (begin 
      (var-set mint-limit new-mint-limit)
      (ok true)
    )
    (err err-invalid-user)))

(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (if (and
        (is-eq tx-sender sender))
      (match (nft-transfer? stacks-ludenz token-id sender recipient)
        success (ok success)
        error (err error))
      (err err-invalid-user)))

;; read-only functions
(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? stacks-ludenz token-id)))

(define-read-only (get-last-token-id)
  (ok (var-get last-id)))

(define-read-only (get-token-uri (token-id uint))
    (ok (some (concat (concat (var-get ipfs-root) "$TOKEN_ID") ".json"))))
