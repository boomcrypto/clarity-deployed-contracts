;; title: menoob3-404

(use-trait commission-trait 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.commission-trait.commission)

(define-non-fungible-token menoob3 uint)
(define-fungible-token moob3)

(define-constant err-not-authorised (err u1000))
(define-constant err-invalid-id (err u1001))
(define-constant err-max-supply (err u1002))
(define-constant err-listing (err u1003))
(define-constant err-wrong-commission (err u1004))
(define-constant err-not-found (err u1005))
(define-constant err-metadata-frozen (err u1006))

(define-constant max-supply u3000)
(define-constant one-8 u100000000)

(define-data-var contract-owner principal tx-sender)
(define-data-var id-nonce uint u0)
(define-data-var available-ids (list 3000 uint) (list ))
(define-data-var metadata-frozen bool false)
(define-data-var ft-token-uri (optional (string-utf8 256)) (some u"ipfs://ipfs/default"))

(define-map owned principal (list 3000 uint))
(define-map cids uint (string-ascii 64))
(define-map market uint {price: uint, commission: principal, royalty: uint})

;; read-only calls
(define-read-only (get-contract-owner)
  (var-get contract-owner))

(define-read-only (get-last-token-id)
  (ok (var-get id-nonce)))

(define-read-only (get-token-uri (token-id uint))
  (ok (some (concat "ipfs://" (unwrap-panic (map-get? cids token-id))))))

(define-read-only (get-ft-token-uri)
  (ok (var-get ft-token-uri)))

(define-read-only (get-owner (id uint))
  (ok (nft-get-owner? menoob3 id)))

(define-read-only (get-owned-or-default (owner principal))
  (default-to (list ) (map-get? owned owner)))

(define-read-only (is-id-owned-by-or-default (id uint) (owner principal))
  (match (nft-get-owner? menoob3 id)
    some-value (is-eq some-value owner)
    false))

(define-read-only (get-name)
  (ok "Menoob3"))

(define-read-only (get-symbol)
  (ok "MOOB3"))

(define-read-only (get-decimals)
  (ok u8))

(define-read-only (get-metadata-name)
  (ok "Menoob Three"))

(define-read-only (get-metadata-description)
  (ok "Menoob three description."))

(define-read-only (get-metadata-image)
  (ok "ipfs://ipfs/QmcYs7YBfNKXfaVNyvygaR1Cr6KeEooaHkMMRorcM5mbUH"))

(define-read-only (get-balance (owner principal))
  (ok (ft-get-balance moob3 owner)))

(define-read-only (get-total-supply)
  (ok (ft-get-supply moob3)))

(define-read-only (get-listing-in-ustx (id uint))
  (map-get? market id))

;; governance calls

(define-public (mint (recipient principal))
  (let (
    (id (var-get id-nonce)))
    (try! (check-is-owner))
    (asserts! (< id max-supply) err-max-supply)
    (try! (ft-mint? moob3 one-8 recipient))
    (try! (nft-mint? menoob3 id recipient))
    (map-set owned recipient (unwrap-panic (as-max-len? (append (get-owned-or-default recipient) id) u3000)))
    (ok (var-set id-nonce (+ id u1)))))

(define-public (mint-pro (recipient principal) (uri (string-ascii 64)))
  (let (
    (id (var-get id-nonce)))
    (try! (check-is-owner))
    (asserts! (< id max-supply) err-max-supply)
    (try! (ft-mint? moob3 one-8 recipient))
    (try! (nft-mint? menoob3 id recipient))
    (map-set owned recipient (unwrap-panic (as-max-len? (append (get-owned-or-default recipient) id) u3000)))
    (map-set cids id uri)
    (ok (var-set id-nonce (+ id u1)))))

(define-public (mint-many (uris (list 200 (string-ascii 64))))
  (let ((id-nonce-end (+ (var-get id-nonce) (- (len uris) u1))))  ;; off-by-one
    (try! (check-is-owner))
    (asserts! (< id-nonce-end max-supply) err-max-supply)
    (try! (fold check-err (map mint-many-iter uris) (ok true)))
    (ok true)))

(define-public (mint-many-pro (uris (list 2000 (string-ascii 64))))
  (let ((id-nonce-end (+ (var-get id-nonce) (- (len uris) u1))))  ;; off-by-one
    (try! (check-is-owner))
    (asserts! (< id-nonce-end max-supply) err-max-supply)
    (try! (fold check-err (map mint-many-iter uris) (ok true)))
    (ok true)))

;; Gamma wrapper
(define-public (claim (uris (list 25 (string-ascii 64))))
  (begin
    (try! (mint-many uris))
    (ok true)))

(define-public (burn (token-id uint))
  (begin
    (try! (check-is-owner))
    (asserts! (is-none (map-get? market token-id)) err-listing)
    (nft-burn? menoob3 token-id tx-sender)))

(define-public (set-token-uri (hash (string-ascii 64)) (token-id uint))
  (begin
    (try! (check-is-owner))
    (asserts! (not (var-get metadata-frozen)) err-metadata-frozen)
    (print { notification: "token-metadata-update", payload: { token-class: "nft", token-ids: (list token-id), contract-id: (as-contract tx-sender) }})
    (map-set cids token-id hash)
    (ok true)))

(define-public (set-ft-token-uri (value (string-utf8 256)))
  (begin
    (try! (check-is-owner))
    (asserts! (not (var-get metadata-frozen)) err-metadata-frozen)
    (var-set ft-token-uri (some value))
    (print { notification: "token-metadata-update", payload: { token-class: "ft", contract-id: (as-contract tx-sender) }})
    (ok true)))

(define-public (freeze-metadata)
  (begin
    (try! (check-is-owner))
    (var-set metadata-frozen true)
    (ok true)))

;; public calls

(define-public (transfer (amount-or-id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq sender tx-sender) err-not-authorised)
    (trnsfr amount-or-id sender recipient)))

(define-public (transfer-many (payload (list 200 {amount-or-id: uint, sender: principal, recipient: principal})))
  (begin
    (try! (fold check-err (map transfer-many-iter payload) (ok true)))
    (ok true)))

(define-public (transfer-many-pro (payload (list 2000 {amount-or-id: uint, sender: principal, recipient: principal})))
  (begin
    (try! (fold check-err (map transfer-many-iter payload) (ok true)))
    (ok true)))

(define-public (list-in-ustx (id uint) (price uint) (comm-trait <commission-trait>))
  (let ((listing  {price: price, commission: (contract-of comm-trait), royalty: u0}))
    (asserts! (is-sender-owner id) err-not-authorised)
    (map-set market id listing)
    (print (merge listing {a: "list-in-ustx", id: id}))
    (ok true)))

(define-public (unlist-in-ustx (id uint))
  (begin
    (asserts! (is-sender-owner id) err-not-authorised)
    (map-delete market id)
    (print {a: "unlist-in-ustx", id: id})
    (ok true)))

(define-public (buy-in-ustx (id uint) (comm-trait <commission-trait>))
  (let (
    (owner (unwrap! (nft-get-owner? menoob3 id) err-not-found))
    (listing (unwrap! (map-get? market id) err-listing))
    (price (get price listing))
    (royalty (get royalty listing)))
    (asserts! (is-eq (contract-of comm-trait) (get commission listing)) err-wrong-commission)
    (try! (stx-transfer? price tx-sender owner))
    (try! (contract-call? comm-trait pay id price))
    (try! (trnsfr id owner tx-sender))
    (map-delete market id)
    (print {a: "buy-in-ustx", id: id})
    (ok true)))

;; private calls

(define-data-var sender-temp principal tx-sender)
(define-data-var recipient-temp principal tx-sender)

(define-private (nft-transfer-iter (id uint))
  (nft-transfer? menoob3 id (var-get sender-temp) (var-get recipient-temp)))

(define-private (check-err (result (response bool uint)) (prior (response bool uint)))
  (match prior ok-value result err-value (err err-value)))

(define-private (check-is-owner)
  (ok (asserts! (is-eq tx-sender (var-get contract-owner)) err-not-authorised)))

(define-private (pop (target (list 3000 uint)) (idx uint))
  (match (slice? target (+ idx u1) (len target))
    some-value (unwrap-panic (as-max-len? (concat (unwrap-panic (slice? target u0 idx)) some-value) u3000))
    (unwrap-panic (slice? target u0 idx))))

(define-private (is-sender-owner (id uint))
  (let ((owner (unwrap! (nft-get-owner? menoob3 id) false)))
    (or (is-eq tx-sender owner) (is-eq contract-caller owner))))

(define-private (mint-many-iter (hash (string-ascii 64)))
  (let ((next-id (var-get id-nonce)))
    (try! (ft-mint? moob3 one-8 tx-sender))
    (try! (nft-mint? menoob3 next-id tx-sender))
    (map-set cids next-id hash)
    (map-set owned tx-sender (unwrap-panic (as-max-len? (append (get-owned-or-default tx-sender) next-id) u3000)))
    (ok (var-set id-nonce (+ next-id u1)))))

(define-private (transfer-many-iter (payload {amount-or-id: uint, sender: principal, recipient: principal}))
  (let (
    (amount-or-id (get amount-or-id payload))
    (sender (get sender payload))
    (recipient (get recipient payload)))
    (asserts! (is-eq sender tx-sender) err-not-authorised)
    (trnsfr amount-or-id sender recipient)))

(define-private (trnsfr (amount-or-id uint) (sender principal) (recipient principal))
  (if (<= amount-or-id max-supply) ;; id transfer
    (let (
      (check-id (asserts! (is-id-owned-by-or-default amount-or-id sender) err-invalid-id))
      (owned-by-sender (get-owned-or-default sender))
      (owned-by-recipient (get-owned-or-default recipient))
      (id-idx (unwrap-panic (index-of? owned-by-sender amount-or-id))))
      (map-set owned sender (pop owned-by-sender id-idx))
      (map-set owned recipient (unwrap-panic (as-max-len? (append owned-by-recipient amount-or-id) u3000)))
      (try! (ft-transfer? moob3 one-8 sender recipient))
      (try! (nft-transfer? menoob3 amount-or-id sender recipient))
      (ok true))
    (let (
      (balance-sender (unwrap-panic (get-balance sender)))
      (balance-recipient (unwrap-panic (get-balance recipient)))
      (check-balance (try! (ft-transfer? moob3 amount-or-id sender recipient)))
      (no-to-treasury (- (/ balance-sender one-8) (/ (- balance-sender amount-or-id) one-8)))
      (no-to-recipient (- (/ (+ balance-recipient amount-or-id) one-8) (/ balance-recipient one-8)))
      (owned-by-sender (get-owned-or-default sender))
      (owned-by-recipient (get-owned-or-default recipient))
      (ids-to-treasury (if (is-eq no-to-treasury u0) (list ) (unwrap-panic (slice? owned-by-sender (- (len owned-by-sender) no-to-treasury) (len owned-by-sender)))))
      (new-available-ids (if (is-eq no-to-treasury u0) (var-get available-ids) (unwrap-panic (as-max-len? (concat (var-get available-ids) ids-to-treasury) u3000))))
      (ids-to-recipient (if (is-eq no-to-recipient u0) (list ) (unwrap-panic (slice? new-available-ids (- (len new-available-ids) no-to-recipient) (len new-available-ids))))))
      (var-set sender-temp sender)
      (var-set recipient-temp (as-contract tx-sender))
      (and (> no-to-treasury u0) (try! (fold check-err (map nft-transfer-iter ids-to-treasury) (ok true))))
      (var-set sender-temp (as-contract tx-sender))
      (var-set recipient-temp recipient)
      (and (> no-to-recipient u0) (try! (fold check-err (map nft-transfer-iter ids-to-recipient) (ok true))))
      (map-set owned sender (if (is-eq no-to-treasury u0) owned-by-sender (unwrap-panic (slice? owned-by-sender u0 (- (len owned-by-sender) no-to-treasury)))))
      (map-set owned recipient (if (is-eq no-to-recipient u0) owned-by-recipient (unwrap-panic (as-max-len? (concat owned-by-recipient ids-to-recipient) u3000))))
      (var-set available-ids (if (is-eq no-to-recipient u0) new-available-ids (unwrap-panic (slice? new-available-ids u0 (- (len new-available-ids) no-to-recipient)))))
      (ok true))))
