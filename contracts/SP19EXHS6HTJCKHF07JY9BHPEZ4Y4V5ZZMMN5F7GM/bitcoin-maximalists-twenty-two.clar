(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token bitcoin-maximalists-twenty-two uint)

(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_INVALID_PERCENTAGE (err u900))
(define-constant ERR_LICENSE_FROZEN (err u901))
(define-constant ERR_METADATA_FROZEN (err u902))
(define-constant ERR_MINT_LIMIT_REACHED (err u903))
(define-constant ERR_MINT_PAUSED (err u904))
(define-constant ERR_NO_LISTINGS (err u905))
(define-constant ERR_NO_OWNER (err u906))
(define-constant ERR_NOT_CONTRACT_OWNER (err u907))
(define-constant ERR_NOT_TOKEN_OWNER (err u908))
(define-constant ERR_TOKEN_ALREADY_MINTED (err u909))
(define-constant ERR_TOKEN_DOES_NOT_EXIST (err u910))
(define-constant ERR_TOKEN_LISTED (err u911))
(define-constant ERR_TOKEN_NOT_LISTED (err u912))
(define-constant ERR_TOKEN_NOT_MINTED (err u913))

(define-data-var last-token-id uint u1)
(define-data-var base-uri (string-ascii 100) "ipfs://bafybeidqp7bbe7ensdrpnz7h7eko4gio7hrrs5ff74qbkspqlrw4xhcof4/")
(define-data-var mint-price uint u420000000)
(define-data-var mint-list (list 365 uint) (list))
(define-data-var mint-limit uint u21)
(define-data-var mint-paused bool false)
(define-data-var market-enabled bool false)
(define-data-var listing-list (list 365 uint) (list))
(define-data-var license-frozen bool false)
(define-data-var metadata-frozen bool false)
(define-data-var artist-address principal 'SP28P0QPAKY7X7KMBKWXFHBP5X4ZET90T96QDHMNJ)
(define-data-var commission-address principal 'SP3DB5QDJAMRNRTQQ291X2HRQEHERH13QEE06HQC9)
(define-data-var market-address principal 'SP2BS7P19T6WP6734EBQ4B7PYYHTGYM0K7HDFEMJE)
(define-data-var artist-royalty uint u500)
(define-data-var commission-percent uint u800)
(define-data-var market-percent uint u200)
(define-map mints-per-user-map principal uint)
(define-map listing-map uint {price: uint})
(define-map owner-map uint principal)

(define-public (freeze-metadata)
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_CONTRACT_OWNER)
    (var-set metadata-frozen true)
    (ok true)))
;; #[allow(unchecked_data)]
(define-public (set-base-uri (new-base-uri (string-ascii 80)))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_CONTRACT_OWNER)
    (asserts! (not (var-get metadata-frozen)) ERR_METADATA_FROZEN)
    (print { notification: "token-metadata-update", payload: { token-class: "nft", contract-id: (as-contract tx-sender) }})
    (var-set base-uri new-base-uri)
    (ok true)))
;; #[allow(unchecked_data)]
(define-public (set-mint-limit (limit uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_CONTRACT_OWNER)
    (ok (var-set mint-limit limit))))
;; #[allow(unchecked_data)]
(define-public (set-mint-price (price uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_CONTRACT_OWNER)
    (ok (var-set mint-price price))))

(define-public (toggle-mint-pause)
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_CONTRACT_OWNER)
    (ok (var-set mint-paused (not (var-get mint-paused))))))

;; #[allow(unchecked_data)]
(define-public (mint (id uint))
    (let ((user-mints (get-mints-per-user tx-sender)))
    (begin
        (asserts! (is-eq false (var-get mint-paused)) ERR_MINT_PAUSED)
        (asserts! (< user-mints (var-get mint-limit)) ERR_MINT_LIMIT_REACHED)
        (asserts! (> id u0) ERR_TOKEN_DOES_NOT_EXIST)
        (asserts! (<= id u365) ERR_TOKEN_DOES_NOT_EXIST)
        (asserts! (is-none (index-of? (var-get mint-list) id)) ERR_TOKEN_ALREADY_MINTED)
        (map-set mints-per-user-map tx-sender (+ user-mints u1))
        (map-set owner-map id tx-sender)
        (try! (stx-transfer? (var-get mint-price) tx-sender CONTRACT_OWNER))
        (try! (nft-mint? bitcoin-maximalists-twenty-two id tx-sender))
        (var-set mint-list (unwrap-panic (as-max-len? (append (var-get mint-list) id) u365)))
        (ok id))))

(define-private (get-mints-per-user (caller principal))
  (default-to u0 (map-get? mints-per-user-map caller)))

(define-private (is-owner (id uint))
  (let ((owner (unwrap! (nft-get-owner? bitcoin-maximalists-twenty-two id) false)))
    (or (is-eq tx-sender owner) (is-eq contract-caller owner))))

(define-read-only (get-freeze-metadata)
  (ok (var-get metadata-frozen)))

(define-read-only (get-last-token-id)
  (ok (- (var-get last-token-id) u1)))

(define-read-only (get-mint-limit)
  (ok (var-get mint-limit)))

(define-read-only (get-mint-list)
  (ok (var-get mint-list)))

(define-read-only (get-mint-paused)
  (ok (var-get mint-paused)))

(define-read-only (get-mint-price)
  (ok (var-get mint-price)))

(define-read-only (get-owner (id uint))
  (ok (nft-get-owner? bitcoin-maximalists-twenty-two id)))

(define-read-only (get-token-owner (id uint))
  (ok (unwrap! (nft-get-owner? bitcoin-maximalists-twenty-two id) ERR_NO_OWNER)))

(define-read-only (get-token-uri (id uint))
  (ok (some (concat (concat (var-get base-uri) (int-to-ascii id)) ".json"))))

(define-read-only (get-uri (id uint))
  (ok (concat (concat (var-get base-uri) (int-to-ascii id)) ".json")))

(define-public (enlist (id uint) (price uint))
  (let ((listing  {price: price}))
    (asserts! (is-owner id) ERR_NOT_TOKEN_OWNER)
    (asserts! (not (is-some (index-of? (var-get listing-list) id))) ERR_TOKEN_LISTED)
    (var-set listing-list (unwrap-panic (as-max-len? (append (var-get listing-list) id) u365)))
    (map-set listing-map id listing)
    (print (merge listing {event: "new listing", id: id}))
    (ok true)))

(define-public (unlist (id uint))
  (begin
    (asserts! (is-owner id) ERR_NOT_TOKEN_OWNER)
    (try! (remove-listing id))
    (map-delete listing-map id)
    (print {event: "removed listing", id: id})
    (ok true)))
;; #[allow(unchecked_data)]
(define-public (buy (id uint))
  (let
       ((owner (unwrap! (nft-get-owner? bitcoin-maximalists-twenty-two id) ERR_NOT_TOKEN_OWNER))
        (listing (unwrap! (map-get? listing-map id) ERR_TOKEN_NOT_LISTED))
        (price (get price listing))
        (commission (var-get commission-percent))
        (comm-amount (/ (* price commission) u10000))
        (market (var-get market-percent))
        (market-amount (/ (* price market) u10000))
        (royalty (var-get artist-royalty))
        (royal-amount (/ (* price royalty) u10000)))
    (try! (stx-transfer? (- price (+ royal-amount (+ comm-amount market-amount))) tx-sender owner))
    (try! (pay price commission (as-contract (var-get commission-address))))
    (try! (pay price market (as-contract (var-get market-address))))
    (try! (pay price royalty (as-contract (var-get artist-address))))
    (try! (nft-transfer? bitcoin-maximalists-twenty-two id owner tx-sender))
    (try! (unlist id))
    (map-delete listing-map id)
    (print {event: "buy", id: id})
    (ok true)))
;; #[allow(unchecked_data)]
(define-public (transfer (id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) ERR_NOT_TOKEN_OWNER)
    (asserts! (is-none (map-get? listing-map id)) ERR_TOKEN_LISTED)
    (try! (nft-transfer? bitcoin-maximalists-twenty-two id sender recipient))
    (ok true)))
;; #[allow(unchecked_data)]
(define-public (set-artist-address (address principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_CONTRACT_OWNER)
    (ok (var-set artist-address address))))

(define-public (set-artist-royalty (royalty uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_CONTRACT_OWNER)
    (asserts! (and (>= royalty u0) (<= royalty u1500)) ERR_INVALID_PERCENTAGE)
    (ok (var-set artist-royalty royalty))))
;; #[allow(unchecked_data)]
(define-public (set-commission-address (address principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_CONTRACT_OWNER)
    (ok (var-set commission-address address))))

(define-public (set-commission-percent (percent uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_CONTRACT_OWNER)
    (asserts! (and (>= percent u0) (<= percent u1500)) ERR_INVALID_PERCENTAGE)
    (ok (var-set commission-percent percent))))
;; #[allow(unchecked_data)]
(define-public (set-market-address (address principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_CONTRACT_OWNER)
    (ok (var-set market-address address))))

(define-public (set-market-percent (percent uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_CONTRACT_OWNER)
    (asserts! (and (>= percent u0) (<= percent u1500)) ERR_INVALID_PERCENTAGE)
    (ok (var-set market-percent percent))))

(define-private (pay (price uint) (amount uint) (recipient principal))
  (let ((pay-amount (/ (* price amount) u10000)))
  (if (and (> pay-amount u0) (not (is-eq tx-sender recipient)))
    (try! (stx-transfer? pay-amount tx-sender recipient))
    (print false))
  (ok true)))

(define-private (remove-listing (id uint))
  (let ((mylist (var-get listing-list))) 
    (match (index-of? mylist id) idx 
      (ok (var-set listing-list (unwrap-panic (as-max-len? (if (< idx (- (len mylist) u1))
        (concat (unwrap-panic (slice? mylist u0 idx)) (unwrap-panic (slice? mylist (+ idx u1) (len mylist))))
        (unwrap-panic (slice? mylist u0 idx))) u10))))
      ERR_TOKEN_NOT_LISTED)))

(define-read-only (get-artist-address)
  (ok (var-get artist-address)))

(define-read-only (get-artist-royalty)
  (ok (var-get artist-royalty)))

(define-read-only (get-commission-address)
  (ok (var-get commission-address)))

(define-read-only (get-commission-percent)
  (ok (var-get commission-percent)))

(define-read-only (get-market-address)
  (ok (var-get market-address)))

(define-read-only (get-market-percent)
  (ok (var-get market-percent)))

(define-read-only (get-listing-info (id uint))
  (ok (unwrap! (map-get? listing-map id) ERR_TOKEN_NOT_LISTED)))

(define-read-only (get-listing-list)
  (ok (var-get listing-list)))

(define-data-var license-uri (string-ascii 80) "https://arweave.net/zmc1WTspIhFyVY82bwfAIcIExLFH5lUcHHUN0wXg4W8/0")
(define-data-var license-name (string-ascii 40) "PUBLIC")

(define-public (freeze-license)
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_CONTRACT_OWNER)
    (var-set license-frozen true)
    (ok true)))
;; #[allow(unchecked_data)]
(define-public (set-license-name (name (string-ascii 40)))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_CONTRACT_OWNER)
    (asserts! (not (var-get license-frozen)) ERR_LICENSE_FROZEN)
    (ok (var-set license-name name))))
;; #[allow(unchecked_data)]
(define-public (set-license-uri (uri (string-ascii 80)))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_CONTRACT_OWNER)
    (asserts! (not (var-get license-frozen)) ERR_LICENSE_FROZEN)
    (ok (var-set license-uri uri))))

(define-read-only (get-license-name)
  (ok (var-get license-name)))

(define-read-only (get-license-uri)
  (ok (var-get license-uri)))

(define-read-only (get-freeze-license)
  (ok (var-get license-frozen)))