;; Stacks 1 Year Mainnet Anniversary Boombox

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
(impl-trait 'SP1QK1AZ24R132C0D84EEQ8Y2JDHARDR58R72E1ZW.boombox-trait.boombox-trait)
(define-non-fungible-token mainnet-anniversary-bb-26 uint)

;; constants
;;
(define-constant deployer tx-sender)
(define-constant max-supply u5)

;; err constants
(define-constant err-not-authorized (err u403))
(define-constant err-not-found (err u404))
(define-constant err-sold-out (err u501))
(define-constant err-invalid-stacks-tip (err u608))

;; data maps and vars
;;
(define-data-var last-id uint u0)
(define-data-var uri-prefix (string-ascii 256) "")
(define-data-var metadata-frozen bool false)
(define-data-var ipfs-full-metadata (string-ascii 106) "ipfs://placeholder")
(define-data-var ipfs-root (string-ascii 93) "ipfs://placeholder")
(define-data-var boombox-admin principal 'SP1QK1AZ24R132C0D84EEQ8Y2JDHARDR58R72E1ZW.boombox-admin-v3)
;; boombox-admin contract : boombox id
(define-map boombox-id principal uint)
;; approval maps
(define-map approvals {owner: principal, operator: principal, id: uint} bool)
(define-map approvals-all {owner: principal, operator: principal} bool)

;; private functions
(define-private (is-approved-with-owner (id uint) (operator principal) (owner principal))
  (or
    (is-eq owner operator)
    (default-to (default-to
      false
        (map-get? approvals-all {owner: owner, operator: operator}))
          (map-get? approvals {owner: owner, operator: operator, id: id}))))

;; public functions
;;

;; operable functions
(define-read-only (is-approved (id uint) (operator principal))
  (let ((owner (unwrap! (nft-get-owner? mainnet-anniversary-bb-26 id) err-not-found)))
    (ok (is-approved-with-owner id operator owner))))

(define-public (set-approved (id uint) (operator principal) (approved bool))
	(ok (map-set approvals {owner: contract-caller, operator: operator, id: id} approved)))

(define-public (set-approved-all (operator principal) (approved bool))
	(ok (map-set approvals-all {owner: contract-caller, operator: operator} approved)))

;; transfer functions
(define-public (transfer (id uint) (sender principal) (recipient principal))
  (let ((owner (unwrap! (nft-get-owner? mainnet-anniversary-bb-26 id) err-not-found)))
    (asserts! (is-approved-with-owner id contract-caller owner) err-not-authorized)
    (nft-transfer? mainnet-anniversary-bb-26 id sender recipient)))

(define-public (transfer-memo (id uint) (sender principal) (recipient principal) (memo (buff 34)))
  (begin
    (try! (transfer id sender recipient))
    (print memo)
    (ok true)))

(define-read-only (get-owner (id uint))
  (ok (nft-get-owner? mainnet-anniversary-bb-26 id)))

(define-read-only (get-owner-at-block (id uint) (stacks-tip uint))
  (match (get-block-info? id-header-hash stacks-tip)
    ihh (ok (at-block ihh (nft-get-owner? mainnet-anniversary-bb-26 id)))
    err-invalid-stacks-tip))

(define-read-only (get-last-token-id)
  (ok (var-get last-id)))

(define-read-only (get-token-uri (id uint))
  (if (< id u5001)
    (ok (some (concat (concat (var-get ipfs-root) (unwrap-panic (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.conversion lookup id))) ".json")))
    (ok (some (concat (concat (var-get ipfs-root) (unwrap-panic (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.conversion-v2 lookup (- id u5001)))) ".json")))
    )
)

;; can only be called by boombox admin
(define-public (mint (bb-id uint) (stacker principal) (amount-ustx uint) (pox-addr {version: (buff 1), hashbytes: (buff 20)}) (locking-period uint))
  (let ((next-id (+ u1 (var-get last-id))))
    (asserts! (<= next-id max-supply) err-sold-out)
    (asserts! (is-eq bb-id (unwrap! (map-get? boombox-id contract-caller) err-not-authorized)) err-not-authorized)
    (var-set last-id next-id)
    (try! (nft-mint? mainnet-anniversary-bb-26 next-id stacker))
    (ok next-id)))

;; can only be called by boombox admin
(define-public (set-boombox-id (bb-id uint))
  (begin
    (asserts! (is-eq contract-caller (var-get boombox-admin)) err-not-authorized)
    (map-set boombox-id contract-caller bb-id)
    (ok true)))

;; can only be called by deployer
(define-public (set-boombox-admin (admin principal))
  (begin
    (asserts! (is-eq contract-caller deployer) err-not-authorized)
    (var-set boombox-admin admin)
    (ok true)))


(define-public (set-root-uri (single-uri (string-ascii 93)))
  (begin
          (asserts! (is-eq (var-get metadata-frozen) false) err-not-authorized)
          (asserts! (is-eq tx-sender deployer) err-not-authorized)
          (var-set ipfs-root single-uri)
          (ok true)
      )
)

(define-public (set-full-uri (full-uri (string-ascii 106)))
  (begin
          (asserts! (is-eq (var-get metadata-frozen) false) err-not-authorized)
          (asserts! (is-eq tx-sender deployer) err-not-authorized)
          (var-set ipfs-full-metadata full-uri)
          (ok true)
  )
)

;; Freeze metadata
(define-public (freeze-metadata)
  (if (is-eq tx-sender deployer)
    (ok (var-set metadata-frozen true))
    (err err-not-authorized)
  )
)