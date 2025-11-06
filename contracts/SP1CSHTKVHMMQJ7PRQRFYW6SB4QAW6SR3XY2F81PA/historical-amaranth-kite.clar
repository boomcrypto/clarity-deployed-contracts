;; mint-with-tokens
;; contractType: public
;; version: 0
;; versionDate: 20251014
;; versionSummary: Add mint-with, list-in-token functionality via ft-trait

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
(use-trait ft-trait 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.ft-trait.sip-010-trait)

(define-non-fungible-token mint-with-tokens uint)

(define-constant DEPLOYER tx-sender)
(define-constant COMM u1000)
(define-constant COMM-ADDR 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S)

(define-constant ERR-NO-MORE-NFTS u100)
(define-constant ERR-NOT-ENOUGH-PASSES u101)
(define-constant ERR-PUBLIC-SALE-DISABLED u102)
(define-constant ERR-CONTRACT-INITIALIZED u103)
(define-constant ERR-NOT-AUTHORIZED u104)
(define-constant ERR-INVALID-USER u105)
(define-constant ERR-LISTING u106)
(define-constant ERR-WRONG-COMMISSION u107)
(define-constant ERR-NOT-FOUND u108)
(define-constant ERR-PAUSED u109)
(define-constant ERR-MINT-LIMIT u110)
(define-constant ERR-METADATA-FROZEN u111)
(define-constant ERR-NO-MORE-MINTS u113)
(define-constant ERR-INVALID-PERCENTAGE u114)
(define-constant ERR-MINT-FAILURE u115)
(define-constant ERR-WRONG-TOKEN u116)
(define-constant ERR-UNSUPPORTED-TOKEN u500)

(define-data-var mint-limit uint u40)
(define-data-var last-id uint u0)
(define-data-var total-price uint u1000000)
(define-data-var artist-address principal 'SP1CSHTKVHMMQJ7PRQRFYW6SB4QAW6SR3XY2F81PA)
(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/QmXByXzDPPTCuVaaKuT4d4PkdWZRoF8W7gob7fG5kShDFd/json/")
(define-data-var mint-paused bool false)
(define-data-var premint-enabled bool false)
(define-data-var sale-enabled bool false)
(define-data-var metadata-frozen bool false)
(define-data-var mint-cap uint u0)

(define-map mints-per-user principal uint)
(define-map mint-passes principal uint)
(define-map token-prices principal uint)
(define-map whitelisted-tokens principal bool)

(define-public (mint-for-many (recipients (list 25 principal)))
  (let
    (
      (next-id (+ (var-get last-id) u1))
      (id-reached (fold mint-for-many-iter recipients next-id))
      (last-id-minted (- id-reached u1))
    )
    (begin
      (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
      (var-set last-id last-id-minted)
      (ok last-id-minted))))

(define-private (mint-for-many-iter (recipient principal) (next-id uint))
  (if (<= next-id (var-get mint-limit))
    (begin
      (unwrap! (nft-mint? mint-with-tokens next-id tx-sender) next-id)
      (unwrap! (nft-transfer? mint-with-tokens next-id tx-sender recipient) next-id)
      (map-set token-count recipient (+ (get-balance recipient) u1))
      (+ next-id u1)
    )
    next-id))

;; Default claim function. Replace with mintpass claim function if using mintpass
;; (define-public (claim (orders uint))
;;   (mint-many orders))

;; Default claim-with function. Replace with mintpass claim-with function if using mintpass
;; (define-public (claim-with (orders uint) (token <ft-trait>))
;;   (mint-many-with orders token))

(define-private (mint-many (orders uint))
  (let
    (
      (art-addr (var-get artist-address))
      (price (* (var-get total-price) orders))
      (total-commission (/ (* price COMM) u10000))
      (total-artist (- price total-commission))
      (current-balance (get-balance tx-sender))
      (capped (> (var-get mint-cap) u0))
      (user-mints (get-mints tx-sender))
    )
    (asserts! (or (is-eq false (var-get mint-paused)) (is-eq tx-sender DEPLOYER)) (err ERR-PAUSED))
    (asserts! (or (not capped) (is-eq tx-sender DEPLOYER) (is-eq tx-sender art-addr) (>= (var-get mint-cap) (+ orders user-mints))) (err ERR-NO-MORE-MINTS))
    (try! (if (<= u1 orders) (mint) (ok u0)))
    (try! (if (<= u2 orders) (mint) (ok u0)))
    (try! (if (<= u3 orders) (mint) (ok u0)))
    (try! (if (<= u4 orders) (mint) (ok u0)))
    (try! (if (<= u5 orders) (mint) (ok u0)))
    (try! (if (<= u6 orders) (mint) (ok u0)))
    (try! (if (<= u7 orders) (mint) (ok u0)))
    (try! (if (<= u8 orders) (mint) (ok u0)))
    (try! (if (<= u9 orders) (mint) (ok u0)))
    (try! (if (<= u10 orders) (mint) (ok u0)))
    (try! (if (<= u11 orders) (mint) (ok u0)))
    (try! (if (<= u12 orders) (mint) (ok u0)))
    (try! (if (<= u13 orders) (mint) (ok u0)))
    (try! (if (<= u14 orders) (mint) (ok u0)))
    (try! (if (<= u15 orders) (mint) (ok u0)))
    (try! (if (<= u16 orders) (mint) (ok u0)))
    (try! (if (<= u17 orders) (mint) (ok u0)))
    (try! (if (<= u18 orders) (mint) (ok u0)))
    (try! (if (<= u19 orders) (mint) (ok u0)))
    (try! (if (<= u20 orders) (mint) (ok u0)))
    (try! (if (<= u21 orders) (mint) (ok u0)))
    (try! (if (<= u22 orders) (mint) (ok u0)))
    (try! (if (<= u23 orders) (mint) (ok u0)))
    (try! (if (<= u24 orders) (mint) (ok u0)))
    (try! (if (<= u25 orders) (mint) (ok u0)))
    (map-set mints-per-user tx-sender (+ orders user-mints))
    (if (or (is-eq tx-sender art-addr) (is-eq tx-sender DEPLOYER) (is-eq (var-get total-price) u0000000))
      (begin
        (map-set token-count tx-sender (+ current-balance orders))
      )
      (begin
        (map-set token-count tx-sender (+ current-balance orders))
        (try! (stx-transfer? total-artist tx-sender (var-get artist-address)))
        (try! (stx-transfer? total-commission tx-sender COMM-ADDR))
      )
    )
    (ok true)))

(define-private (mint-many-with (orders uint) (token <ft-trait>))
  (let
    (
      (art-addr (var-get artist-address))
      (token-price (unwrap! (map-get? token-prices (contract-of token)) (err ERR-UNSUPPORTED-TOKEN)))
      (price (* token-price orders))
      (total-commission (/ (* price COMM) u10000))
      (total-artist (- price total-commission))
      (current-balance (get-balance tx-sender))
      (capped (> (var-get mint-cap) u0))
      (user-mints (get-mints tx-sender))
    )
    (asserts! (or (is-eq false (var-get mint-paused)) (is-eq tx-sender DEPLOYER)) (err ERR-PAUSED))
    (asserts! (is-token-whitelisted (contract-of token)) (err ERR-UNSUPPORTED-TOKEN))
    (asserts! (or (not capped) (is-eq tx-sender DEPLOYER) (is-eq tx-sender art-addr) (>= (var-get mint-cap) (+ orders user-mints))) (err ERR-NO-MORE-MINTS))
    (asserts! (<= orders u25) (err ERR-NO-MORE-MINTS))
    (try! (if (>= orders u1) (mint-with token) (ok true)))
    (try! (if (>= orders u2) (mint-with token) (ok true)))
    (try! (if (>= orders u3) (mint-with token) (ok true)))
    (try! (if (>= orders u4) (mint-with token) (ok true)))
    (try! (if (>= orders u5) (mint-with token) (ok true)))
    (try! (if (>= orders u6) (mint-with token) (ok true)))
    (try! (if (>= orders u7) (mint-with token) (ok true)))
    (try! (if (>= orders u8) (mint-with token) (ok true)))
    (try! (if (>= orders u9) (mint-with token) (ok true)))
    (try! (if (>= orders u10) (mint-with token) (ok true)))
    (try! (if (>= orders u11) (mint-with token) (ok true)))
    (try! (if (>= orders u12) (mint-with token) (ok true)))
    (try! (if (>= orders u13) (mint-with token) (ok true)))
    (try! (if (>= orders u14) (mint-with token) (ok true)))
    (try! (if (>= orders u15) (mint-with token) (ok true)))
    (try! (if (>= orders u16) (mint-with token) (ok true)))
    (try! (if (>= orders u17) (mint-with token) (ok true)))
    (try! (if (>= orders u18) (mint-with token) (ok true)))
    (try! (if (>= orders u19) (mint-with token) (ok true)))
    (try! (if (>= orders u20) (mint-with token) (ok true)))
    (try! (if (>= orders u21) (mint-with token) (ok true)))
    (try! (if (>= orders u22) (mint-with token) (ok true)))
    (try! (if (>= orders u23) (mint-with token) (ok true)))
    (try! (if (>= orders u24) (mint-with token) (ok true)))
    (try! (if (>= orders u25) (mint-with token) (ok true)))
    (map-set mints-per-user tx-sender (+ orders user-mints))
    (if (or (is-eq tx-sender art-addr) (is-eq tx-sender DEPLOYER))
      (map-set token-count tx-sender (+ current-balance orders))
      (begin
        (map-set token-count tx-sender (+ current-balance orders))
        (try! (contract-call? token transfer total-artist tx-sender (var-get artist-address) none))
        (try! (contract-call? token transfer total-commission tx-sender COMM-ADDR none))
      ))
    (ok true)))

(define-private (mint)
  (let
    (
      (next-id (+ (var-get last-id) u1))
      (enabled (asserts! (<= next-id (var-get mint-limit)) (err ERR-NO-MORE-NFTS)))
    )
    (try! (nft-mint? mint-with-tokens next-id tx-sender))
    (var-set last-id next-id)
    (ok next-id)))

(define-private (mint-with (token <ft-trait>))
  (let
    (
      (next-id (+ (var-get last-id) u1))
      (enabled (asserts! (<= next-id (var-get mint-limit)) (err ERR-NO-MORE-NFTS)))
    )
    (try! (nft-mint? mint-with-tokens next-id tx-sender))
    (var-set last-id next-id)
    (ok true)))

(define-public (set-artist-address (address principal))
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-INVALID-USER))
    (ok (var-set artist-address address))))

(define-public (set-price (price uint))
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-INVALID-USER))
    (ok (var-set total-price price))))

(define-public (set-token-price (token <ft-trait>) (price uint))
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-INVALID-USER))
    (map-set whitelisted-tokens (contract-of token) true)
    (ok (map-set token-prices (contract-of token) price))))

(define-public (toggle-pause)
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-INVALID-USER))
    (ok (var-set mint-paused (not (var-get mint-paused))))))

(define-public (admin-add-token (token principal))
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-INVALID-USER))
    (map-set whitelisted-tokens token true)
    (ok true)))

(define-public (admin-remove-token (token principal))
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-INVALID-USER))
    (map-delete whitelisted-tokens token)
    (ok true)))

(define-read-only (is-token-whitelisted (token principal))
  (default-to false (map-get? whitelisted-tokens token)))

(define-public (set-mint-limit (limit uint))
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-INVALID-USER))
    (asserts! (< limit (var-get mint-limit)) (err ERR-MINT-LIMIT))
    (asserts! (var-get metadata-frozen) (err ERR-METADATA-FROZEN))
    (ok (var-set mint-limit limit))))

(define-public (burn (token-id uint))
  (begin
    (asserts! (is-owner token-id tx-sender) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-none (map-get? market token-id)) (err ERR-LISTING))
    (nft-burn? mint-with-tokens token-id tx-sender)))

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? mint-with-tokens token-id) false)))

(define-public (set-base-uri (new-base-uri (string-ascii 80)))
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
    (asserts! (not (var-get metadata-frozen)) (err ERR-METADATA-FROZEN))
    (var-set ipfs-root new-base-uri)
    (ok true)))

(define-public (freeze-metadata)
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
    (var-set metadata-frozen true)
    (ok true)))

(define-public (transfer (id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-none (map-get? market id)) (err ERR-LISTING))
    (trnsfr id sender recipient)))

;; read-only functions
(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? mint-with-tokens token-id)))

(define-read-only (get-last-token-id)
  (ok (var-get last-id)))

(define-read-only (get-token-uri (token-id uint))
  (ok (some (concat (concat (var-get ipfs-root) "{id}") ".json"))))

(define-read-only (get-paused)
  (ok (var-get mint-paused)))

(define-read-only (get-price)
  (ok (var-get total-price)))

(define-read-only (get-token-price (token <ft-trait>))
  (ok (unwrap! (map-get? token-prices (contract-of token)) (err ERR-UNSUPPORTED-TOKEN))))

(define-read-only (get-mints (caller principal))
  (default-to u0 (map-get? mints-per-user caller)))

(define-read-only (get-mint-limit)
  (ok (var-get mint-limit)))

(define-read-only (get-artist-address)
  (ok (var-get artist-address)))

(define-read-only (get-mint-cap)
  (ok (var-get mint-cap)))

(define-read-only (get-metadata-frozen)
  (ok (var-get metadata-frozen)))

;; Non-custodial marketplace
(use-trait commission-trait .commission-trait.commission-trait)
(use-trait ft-commission-trait .ft-commission-trait.ft-commission-trait)

(define-map token-count principal uint)
(define-map market uint {price: uint, commission: principal, royalty: uint, token: (optional principal)})

(define-read-only (get-balance (account principal))
  (default-to u0
    (map-get? token-count account)))

(define-private (trnsfr (id uint) (sender principal) (recipient principal))
  (match (nft-transfer? mint-with-tokens id sender recipient)
    success
      (let
        ((sender-balance (get-balance sender))
        (recipient-balance (get-balance recipient)))
          (map-set token-count
            sender
            (- sender-balance u1))
          (map-set token-count
            recipient
            (+ recipient-balance u1))
          (ok success))
    error (err error)))

(define-private (is-sender-owner (id uint))
  (let ((owner (unwrap! (nft-get-owner? mint-with-tokens id) false)))
    (or (is-eq tx-sender owner) (is-eq contract-caller owner))))

(define-read-only (get-listing-in-ustx (id uint))
  (map-get? market id))

(define-public (list-in-ustx (id uint) (price uint) (comm-trait <commission-trait>))
  (let ((listing  {price: price, commission: (contract-of comm-trait), royalty: (var-get royalty-percent), token: none}))
    (asserts! (is-sender-owner id) (err ERR-NOT-AUTHORIZED))
    (map-set market id listing)
    (print (merge listing {a: "list-in-ustx", id: id}))
    (ok true)))

(define-public (list-in-token (id uint) (price uint) (comm-trait <ft-commission-trait>) (token <ft-trait>))
  (let ((listing  {price: price, commission: (contract-of comm-trait), royalty: (var-get royalty-percent), token: (some (contract-of token))}))
    (asserts! (is-sender-owner id) (err ERR-NOT-AUTHORIZED))
    (map-set market id listing)
    (print (merge listing {a: "list-in-token", id: id}))
    (ok true)))

(define-public (unlist-in-ustx (id uint))
  (begin
    (asserts! (is-sender-owner id) (err ERR-NOT-AUTHORIZED))
    (map-delete market id)
    (print {a: "unlist-in-ustx", id: id})
    (ok true)))

(define-public (buy-in-ustx (id uint) (comm-trait <commission-trait>))
  (let ((owner (unwrap! (nft-get-owner? mint-with-tokens id) (err ERR-NOT-FOUND)))
      (listing (unwrap! (map-get? market id) (err ERR-LISTING)))
      (price (get price listing))
      (royalty (get royalty listing)))
    (asserts! (is-none (get token listing)) (err ERR-WRONG-TOKEN))
    (asserts! (is-eq (contract-of comm-trait) (get commission listing)) (err ERR-WRONG-COMMISSION))
    (try! (stx-transfer? price tx-sender owner))
    (try! (pay-royalty price royalty))
    (try! (contract-call? comm-trait pay id price))
    (try! (trnsfr id owner tx-sender))
    (map-delete market id)
    (print {a: "buy-in-ustx", id: id})
    (ok true)))

(define-public (buy-in-token (id uint) (comm-trait <ft-commission-trait>) (token-trait <ft-trait>))
  (let ((owner (unwrap! (nft-get-owner? mint-with-tokens id) (err ERR-NOT-FOUND)))
      (listing (unwrap! (map-get? market id) (err ERR-LISTING)))
      (price (get price listing))
      (royalty (get royalty listing)))
    (asserts! (is-eq (contract-of comm-trait) (get commission listing)) (err ERR-WRONG-COMMISSION))
    (asserts! (is-eq (contract-of token-trait) (unwrap! (get token listing) (err ERR-WRONG-TOKEN))) (err ERR-WRONG-TOKEN))
    (try! (contract-call? token-trait transfer price tx-sender owner none))
    (try! (pay-royalty-in-token price royalty token-trait))
    (try! (contract-call? comm-trait pay-in-token id price token-trait))
    (try! (trnsfr id owner tx-sender))
    (map-delete market id)
    (print {a: "buy-in-token", id: id})
    (ok true)))

(define-data-var royalty-percent uint u500)

(define-read-only (get-royalty-percent)
  (ok (var-get royalty-percent)))

(define-public (set-royalty-percent (royalty uint))
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-INVALID-USER))
    (asserts! (and (>= royalty u0) (<= royalty u1000)) (err ERR-INVALID-PERCENTAGE))
    (ok (var-set royalty-percent royalty))))

(define-private (pay-royalty (price uint) (royalty uint))
  (let (
    (royalty-amount (/ (* price royalty) u10000))
  )
  (if (> royalty-amount u0)
    (try! (stx-transfer? royalty-amount tx-sender (var-get artist-address)))
    (print false)
  )
  (ok true)))

(define-private (pay-royalty-in-token (price uint) (royalty uint) (token <ft-trait>))
  (let (
    (royalty-amount (/ (* price royalty) u10000))
  )
  (if (> royalty-amount u0)
    (try! (contract-call? token transfer royalty-amount tx-sender (var-get artist-address) none))
    (print false)
  )
  (ok true)))

;; Initial token whitelist setup - these can be called on deploy to set mint price for specific fungible tokens
(set-token-price 'SP1Q4E6971M7HJ6H8XXDSCAFJ96GEQ02RNN8S55ZZ.doge u1)
;; (set-token-price 'SP125J1ADVYWGWB9NQRCVGKYAG73R17ZNMV17XEJ7.slime-token u1)
;; (set-token-price 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.mega u1)

;; --- MINTPASS FUNCTIONALITY START ---

;; -- For mintpass, replace the default claim function with this one
(define-public (claim (orders uint))
  (let
    (
      (passes (get-passes tx-sender))
    )
    (if (var-get premint-enabled)
      (begin
        (asserts! (>= passes orders) (err ERR-NOT-ENOUGH-PASSES))
        (map-set mint-passes tx-sender (- passes orders))
        (mint-many orders)
      )
      (begin
        (asserts! (var-get sale-enabled) (err ERR-PUBLIC-SALE-DISABLED))
        (mint-many orders)
      )
    )))

;; -- For mintpass, replace the default claim-with function with this one
(define-public (claim-with (orders uint) (token <ft-trait>))
  (let
    (
      (passes (get-passes tx-sender))
    )
    (if (var-get premint-enabled)
      (begin
        (asserts! (>= passes orders) (err ERR-NOT-ENOUGH-PASSES))
        (map-set mint-passes tx-sender (- passes orders))
        (mint-many-with orders token)
      )
      (begin
        (asserts! (var-get sale-enabled) (err ERR-PUBLIC-SALE-DISABLED))
        (mint-many-with orders token)
      )
    )))

;; -- For mintpass, the following additional functions are required
(define-public (toggle-sale-state)
  (let
    (
      (sale (not (var-get sale-enabled)))
    )
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
    (var-set premint-enabled false)
    (var-set sale-enabled sale)
    (print { sale: sale })
    (ok true)))

(define-public (enable-premint)
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
    (ok (var-set premint-enabled true))))

(define-public (disable-premint)
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
    (ok (var-set premint-enabled false))))

(define-read-only (get-passes (caller principal))
  (default-to u0 (map-get? mint-passes caller)))

(define-read-only (get-premint-enabled)
  (ok (var-get premint-enabled)))

(define-read-only (get-sale-enabled)
  (ok (var-get sale-enabled)))

;; --- MINTPASS FUNCTIONALITY END ---

;; For testing mintpass, set the mint passes for an address
(map-set mint-passes 'SP1CSHTKVHMMQJ7PRQRFYW6SB4QAW6SR3XY2F81PA u1)