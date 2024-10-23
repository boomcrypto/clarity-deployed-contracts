(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-constant DEPLOYER tx-sender)
(define-constant ALL_HEX (contract-call? .utils get-all-hex))
(define-constant ALL_HEX_ASCII (contract-call? .utils get-all-hex-ascii))

(define-data-var nextId uint u1)

(define-data-var url (string-ascii 256) "https://bitcoinfaces.xyz/api/get-nft-metadata?hashedName=")

(define-map FirstOwners uint principal)

(define-non-fungible-token bitcoin-faces uint)

(define-read-only (get-last-token-id) (ok (- (var-get nextId) u1)))

(define-read-only (get-token-uri (id uint))
  (ok (as-max-len? (concat (var-get url) (fold buff-to-ascii (get-first-owner-buff id) "0x")) u256))
)

(define-private (buff-to-ascii (x (buff 1)) (out (string-ascii 1000)))
    (unwrap-panic (as-max-len? (concat out (unwrap-panic (element-at? ALL_HEX_ASCII (unwrap-panic (index-of? ALL_HEX x))))) u1000))
)

(define-read-only (get-owner (id uint)) (ok (nft-get-owner? bitcoin-faces id)))

(define-public (transfer (id uint) (from principal) (to principal))
  (if (or (is-eq from tx-sender) (is-eq from contract-caller))
    (begin
      (map-insert FirstOwners id from)
      (nft-transfer? bitcoin-faces id from to)
    )
    (err u4)
  )
)

(define-public (burn (id uint) (from principal))
  (if (or (is-eq from tx-sender) (is-eq from contract-caller))
    (begin
      (map-insert FirstOwners id from)
      (nft-burn? bitcoin-faces id from)
    )
    (err u4)
  )
)

(define-public (mint (to principal))
  (let ((id (var-get nextId)))
    (asserts! (is-eq DEPLOYER (get-standard-caller)) (err u401))
    (var-set nextId (+ id u1))
    (nft-mint? bitcoin-faces id to)
  )
)

(define-public (set-url (new (string-ascii 256)))
  (if (is-eq DEPLOYER (get-standard-caller))
    (ok (var-set url new))
    (err u401)
  )
)

(define-public (airdrop (l1 (list 5000 principal)) (l2 (list 5000 principal)) (l3 (list 4995 principal)))
  (if (is-eq DEPLOYER (get-standard-caller))
    (ok (var-set nextId (fold drop l3 (fold drop l2 (fold drop l1 (var-get nextId))))))
    (err u401)
  )
)

(define-private (drop (to principal) (id uint))
  (begin (is-err (nft-mint? bitcoin-faces id to)) (+ id u1))
)

(define-read-only (get-standard-caller)
  (let ((d (unwrap-panic (principal-destruct? contract-caller))))
    (unwrap-panic (principal-construct? (get version d) (get hash-bytes d)))
  )
)

(define-read-only (get-first-owner (id uint)) 
  (match (map-get? FirstOwners id) addr (some addr)
    (nft-get-owner? bitcoin-faces id)
  )
)

(define-read-only (get-first-owner-buff (id uint))
  (unwrap-panic (match (get-first-owner id) addr (to-consensus-buff? addr) (some 0x)))
)

(nft-mint? bitcoin-faces u0 (as-contract tx-sender))
(as-contract (transfer u0 tx-sender DEPLOYER))
