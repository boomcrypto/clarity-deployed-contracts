
;; Interface definitions
;; (impl-trait .nft-trait.nft-trait)
;; (impl-trait .operable.operable)
;; (impl-trait .transferable.transferable)

;; (impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
(impl-trait 'SP3N4AJFZZYC4BK99H53XP8KDGXFGQ2PRSQP2HGT6.operable.operable)
(impl-trait 'SP3N4AJFZZYC4BK99H53XP8KDGXFGQ2PRSQP2HGT6.transferable.transferable)

;; contract variables
(define-data-var administrator principal 'SP3N4AJFZZYC4BK99H53XP8KDGXFGQ2PRSQP2HGT6)
(define-data-var mint-price uint u20000000)
(define-data-var mint-counter uint u0)
(define-data-var signer (buff 33) 0x02815c03f6d7181332afb1b0114f5a1c97286b6092957910ae3fab4006598aee1b)
(define-data-var is-collection bool false)
(define-data-var collection-mint-addresses (list 4 principal) (list))
(define-data-var collection-mint-shares (list 4 uint) (list))
(define-data-var collection-addresses (list 10 principal) (list))
(define-data-var collection-shares (list 10 uint) (list))
(define-data-var collection-secondaries (list 10 uint) (list))

;; constants
(define-constant token-name "thisis")
(define-constant token-symbol "#1")
(define-constant collection-max-supply u0)

(define-non-fungible-token thisis uint)

;; data structures
(define-map approvals {owner: principal, operator: principal, nft-index: uint} bool)
(define-map nft-lookup {asset-hash: (buff 32), edition: uint} {nft-index: uint})
(define-map nft-data {nft-index: uint} {asset-hash: (buff 32), meta-data-url: (string-ascii 256), max-editions: uint, edition: uint, edition-cost: uint, series-original: uint})
(define-map nft-sale-data {nft-index: uint} {sale-type: uint, increment-stx: uint, reserve-stx: uint, amount-stx: uint, bidding-end-time: uint, sale-cycle-index: uint})
(define-map nft-beneficiaries {nft-index: uint} { addresses: (list 10 principal), shares: (list 10 uint), secondaries: (list 10 uint) })
(define-map nft-bid-history {nft-index: uint, bid-index: uint} {sale-cycle: uint, bidder: principal, amount: uint, bid-in-block: uint})

;; track per NFT of the number of editions minted (1 based)
(define-map nft-edition-counter {nft-index: uint} {edition-counter: uint})
;; track per NFT of the number of bids
(define-map nft-high-bid-counter {nft-index: uint} {high-bid-counter: uint, sale-cycle: uint})

(define-constant percentage-with-twodp u10000000000)

(define-constant err-permission-denied u1)
(define-constant not-allowed (err u10))
(define-constant not-found (err u11))
(define-constant amount-not-set (err u12))
(define-constant seller-not-found (err u13))
(define-constant asset-not-registered (err u14))
(define-constant transfer-error (err u15))
(define-constant not-approved-to-sell (err u16))
(define-constant same-spender-err (err u17))
(define-constant failed-to-mint-err (err u18))
(define-constant edition-counter-error (err u19))
(define-constant edition-limit-reached (err u20))
(define-constant user-amount-different (err u21))
(define-constant failed-to-stx-transfer (err u22))
(define-constant failed-to-close-1 (err u23))
(define-constant failed-refund (err u24))
(define-constant failed-to-close-3 (err u24))
(define-constant cant-pay-mint-price (err u25))
(define-constant editions-error (err u26))
(define-constant payment-error (err u28))
(define-constant payment-error-collection (err u29))
(define-constant payment-address-error (err u33))
(define-constant payment-share-error (err u34))
(define-constant bidding-error (err u35))
(define-constant prevbid-bidding-error (err u36))
(define-constant not-originale (err u37))
(define-constant bidding-opening-error (err u38))
(define-constant bidding-amount-error (err u39))
(define-constant bidding-endtime-error (err u40))
(define-constant collection-limit-reached (err u41))
(define-constant nft-not-owned-err (err u401)) ;; unauthorized
(define-constant sender-equals-recipient-err (err u405)) ;; method not allowed
(define-constant nft-not-found-err (err u404)) ;; not found

;; from nft-trait: Last token ID, limited to uint range
(define-read-only (get-last-token-id)
  (ok (- (var-get mint-counter) u1))
)

;; from nft-trait: URI for metadata associated with the token
(define-read-only (get-token-uri (nftIndex uint))
  (ok (get meta-data-url (map-get? nft-data {nft-index: nftIndex})))
)
;; allows the meta data url to change - e.g. when an nft transfers from buyer to seller allows the meta data to move to new owners gaia storage.
(define-public (update-meta-data-url (nftIndex uint) (newMetaDataUrl (string-ascii 256)))
    (let
        (
            (ahash           (unwrap! (get asset-hash   (map-get? nft-data {nft-index: nftIndex})) not-allowed))
            (edition         (unwrap! (get edition (map-get? nft-data {nft-index: nftIndex})) not-allowed))
            (editionCost     (unwrap! (get edition-cost (map-get? nft-data {nft-index: nftIndex})) not-allowed))
            (maxEditions     (unwrap! (get max-editions (map-get? nft-data {nft-index: nftIndex})) not-allowed))
            (seriesOriginal  (unwrap! (get series-original (map-get? nft-data {nft-index: nftIndex})) not-allowed))
        )
        (asserts! (unwrap! (is-approved nftIndex (unwrap! (nft-get-owner? thisis nftIndex) not-allowed)) not-allowed) not-allowed)
        (ok (map-set nft-data {nft-index: nftIndex} {asset-hash: ahash, meta-data-url: newMetaDataUrl, max-editions: maxEditions, edition: edition, edition-cost: editionCost, series-original: seriesOriginal}))
    )
)

;; from nft-trait: Gets the owner of the 'Specified token ID.
(define-read-only (get-owner (nftIndex uint))
  (ok (nft-get-owner? thisis nftIndex))
)

(define-public (set-is-collection (new-is-collection bool))
    (begin
        (asserts! (is-eq (var-get administrator) contract-caller) not-allowed)
        (var-set is-collection new-is-collection)
        (ok true)
    )
)

(define-public (set-collection-royalties (new-mint-addresses (list 4 principal)) (new-mint-shares (list 4 uint)) (new-addresses (list 10 principal)) (new-shares (list 10 uint)) (new-secondaries (list 10 uint)))
    (begin
        (asserts! (is-eq (var-get administrator) contract-caller) not-allowed)
        (var-set collection-mint-addresses new-mint-addresses)
        (var-set collection-mint-shares new-mint-shares)
        (var-set collection-addresses new-addresses)
        (var-set collection-shares new-shares)
        (var-set collection-secondaries new-secondaries)
        (ok true)
    )
)

(define-public (set-collection-mint-addresses (new-mint-addresses (list 4 principal)))
    (begin
        (asserts! (is-eq (var-get administrator) contract-caller) not-allowed)
        (var-set collection-mint-addresses new-mint-addresses)
        (ok true)
    )
)

(define-public (set-collection-mint-shares (new-mint-shares (list 4 uint)))
    (begin
        (asserts! (is-eq (var-get administrator) contract-caller) not-allowed)
        (var-set collection-mint-shares new-mint-shares)
        (ok true)
    )
)

(define-public (set-collection-addresses (new-addresses (list 10 principal)))
    (begin
        (asserts! (is-eq (var-get administrator) contract-caller) not-allowed)
        (var-set collection-addresses new-addresses)
        (ok true)
    )
)

(define-public (set-collection-shares (new-shares (list 10 uint)))
    (begin
        (asserts! (is-eq (var-get administrator) contract-caller) not-allowed)
        (var-set collection-shares new-shares)
        (ok true)
    )
)

(define-public (set-collection-secondaries (new-secondaries (list 10 uint)))
    (begin
        (asserts! (is-eq (var-get administrator) contract-caller) not-allowed)
        (var-set collection-secondaries new-secondaries)
        (ok true)
    )
)

;; Transfers tokens to a 'SPecified principal.
(define-public (transfer (nftIndex uint) (owner principal) (recipient principal))
  (if (unwrap! (is-approved nftIndex owner) nft-not-owned-err)
    (match (nft-transfer? thisis nftIndex owner recipient)
        success (begin (ok success))
        error (nft-transfer-err error))
    nft-not-owned-err)
)

(define-public (transfer-memo (id uint) (sender principal) (recipient principal) (memo (buff 34)))
    (let ((result (transfer id sender recipient)))
      (print memo)
      result))

;; Burns tokens
(define-public (burn (nftIndex uint) (owner principal))
  (if (unwrap! (is-approved nftIndex owner) nft-not-owned-err)
    (match (nft-burn? thisis nftIndex owner)
        success (begin
            (ok success)
        )
        error (nft-transfer-err error))
    nft-not-owned-err)
)

(define-private (nft-transfer-err (code uint))
  (if (is-eq u1 code)
    nft-not-owned-err
    (if (is-eq u2 code)
      sender-equals-recipient-err
      (if (is-eq u3 code)
        nft-not-found-err
        (err code)))))

;; see operable-trait
(define-public (set-approved (nftIndex uint) (operator principal) (approved bool))
    (let
        (
            (owner (unwrap! (nft-get-owner? thisis nftIndex) not-allowed))
        )
        (begin
            (if (is-eq owner contract-caller)
                (ok (map-set approvals {owner: owner, operator: operator, nft-index: nftIndex} approved))
                not-allowed
            )
        )
    )
)

(define-read-only (is-approved (nftIndex uint) (address principal))
    (let
        (
            (owner (unwrap! (nft-get-owner? thisis nftIndex) not-allowed))
        )
        (begin
            (if (or
                (is-eq owner tx-sender)
                (is-eq owner contract-caller)
                (default-to false (map-get? approvals {owner: owner, operator: tx-sender, nft-index: nftIndex}))
                (default-to false (map-get? approvals {owner: owner, operator: contract-caller, nft-index: nftIndex}))
            ) (ok true) nft-not-owned-err
            )
        )
    )
)

;; public methods
;; --------------
;; the contract administrator can change the contract administrator
(define-public (transfer-administrator (new-administrator principal))
    (begin
        (asserts! (is-eq (var-get administrator) contract-caller) not-allowed)
        (var-set administrator new-administrator)
        (ok true)
    )
)

;; the contract administrator can change the mint price
(define-public (update-mint-price (new-mint-price uint))
    (begin
        (asserts! (is-eq (var-get administrator) contract-caller) not-allowed)
        (var-set mint-price new-mint-price)
        (ok true)
    )
)

(define-public (update-signer (new-signer (buff 33)))
    (begin
        (asserts! (is-eq (var-get administrator) contract-caller) not-allowed)
        (var-set signer new-signer)
        (print {evt: "update-signer", new-signer: new-signer})
        (ok true)
    )
)

;; The administrator can transfer the balance in the contract to another address
(define-public (transfer-balance (recipient principal))
    (let
        (
            (balance (stx-get-balance (as-contract tx-sender)))
        )
        (asserts! (is-eq (var-get administrator) contract-caller) not-allowed)
        (unwrap! (stx-transfer? balance (as-contract tx-sender) recipient) failed-to-stx-transfer)
        (print {evt: "transfer-balance", recipient: recipient, balance: balance})
        (ok balance)
    )
)

;; mint twenty tokens
(define-public (mint-token-twenty (signature (buff 65)) (message (buff 32)) (hashes (list 20 (buff 32))) (meta-urls (list 20 (string-ascii 256))) (maxEditions uint) (editionCost uint) (clientMintPrice uint) (buyNowPrice uint) (mintAddresses (list 4 principal)) (mintShares (list 4 uint)) (addresses (list 10 principal)) (shares (list 10 uint)) (secondaries (list 10 uint)))
    (begin
        (unwrap! (mint-token signature message (unwrap! (element-at hashes u0) not-allowed) (unwrap! (element-at meta-urls u0) not-allowed) maxEditions editionCost clientMintPrice buyNowPrice mintAddresses mintShares addresses shares secondaries) not-allowed)
        (unwrap! (mint-token signature message (unwrap! (element-at hashes u1) not-allowed) (unwrap! (element-at meta-urls u1) not-allowed) maxEditions editionCost clientMintPrice buyNowPrice mintAddresses mintShares addresses shares secondaries) not-allowed)
        (unwrap! (mint-token signature message (unwrap! (element-at hashes u2) not-allowed) (unwrap! (element-at meta-urls u2) not-allowed) maxEditions editionCost clientMintPrice buyNowPrice mintAddresses mintShares addresses shares secondaries) not-allowed)
        (unwrap! (mint-token signature message (unwrap! (element-at hashes u3) not-allowed) (unwrap! (element-at meta-urls u3) not-allowed) maxEditions editionCost clientMintPrice buyNowPrice mintAddresses mintShares addresses shares secondaries) not-allowed)
        (unwrap! (mint-token signature message (unwrap! (element-at hashes u4) not-allowed) (unwrap! (element-at meta-urls u4) not-allowed) maxEditions editionCost clientMintPrice buyNowPrice mintAddresses mintShares addresses shares secondaries) not-allowed)
        (unwrap! (mint-token signature message (unwrap! (element-at hashes u5) not-allowed) (unwrap! (element-at meta-urls u5) not-allowed) maxEditions editionCost clientMintPrice buyNowPrice mintAddresses mintShares addresses shares secondaries) not-allowed)
        (unwrap! (mint-token signature message (unwrap! (element-at hashes u6) not-allowed) (unwrap! (element-at meta-urls u6) not-allowed) maxEditions editionCost clientMintPrice buyNowPrice mintAddresses mintShares addresses shares secondaries) not-allowed)
        (unwrap! (mint-token signature message (unwrap! (element-at hashes u7) not-allowed) (unwrap! (element-at meta-urls u7) not-allowed) maxEditions editionCost clientMintPrice buyNowPrice mintAddresses mintShares addresses shares secondaries) not-allowed)
        (unwrap! (mint-token signature message (unwrap! (element-at hashes u8) not-allowed) (unwrap! (element-at meta-urls u8) not-allowed) maxEditions editionCost clientMintPrice buyNowPrice mintAddresses mintShares addresses shares secondaries) not-allowed)
        (unwrap! (mint-token signature message (unwrap! (element-at hashes u9) not-allowed) (unwrap! (element-at meta-urls u9) not-allowed) maxEditions editionCost clientMintPrice buyNowPrice mintAddresses mintShares addresses shares secondaries) not-allowed)
        (unwrap! (mint-token signature message (unwrap! (element-at hashes u10) not-allowed) (unwrap! (element-at meta-urls u10) not-allowed) maxEditions editionCost clientMintPrice buyNowPrice mintAddresses mintShares addresses shares secondaries) not-allowed)
        (unwrap! (mint-token signature message (unwrap! (element-at hashes u11) not-allowed) (unwrap! (element-at meta-urls u11) not-allowed) maxEditions editionCost clientMintPrice buyNowPrice mintAddresses mintShares addresses shares secondaries) not-allowed)
        (unwrap! (mint-token signature message (unwrap! (element-at hashes u12) not-allowed) (unwrap! (element-at meta-urls u12) not-allowed) maxEditions editionCost clientMintPrice buyNowPrice mintAddresses mintShares addresses shares secondaries) not-allowed)
        (unwrap! (mint-token signature message (unwrap! (element-at hashes u13) not-allowed) (unwrap! (element-at meta-urls u13) not-allowed) maxEditions editionCost clientMintPrice buyNowPrice mintAddresses mintShares addresses shares secondaries) not-allowed)
        (unwrap! (mint-token signature message (unwrap! (element-at hashes u14) not-allowed) (unwrap! (element-at meta-urls u14) not-allowed) maxEditions editionCost clientMintPrice buyNowPrice mintAddresses mintShares addresses shares secondaries) not-allowed)
        (unwrap! (mint-token signature message (unwrap! (element-at hashes u15) not-allowed) (unwrap! (element-at meta-urls u15) not-allowed) maxEditions editionCost clientMintPrice buyNowPrice mintAddresses mintShares addresses shares secondaries) not-allowed)
        (unwrap! (mint-token signature message (unwrap! (element-at hashes u16) not-allowed) (unwrap! (element-at meta-urls u16) not-allowed) maxEditions editionCost clientMintPrice buyNowPrice mintAddresses mintShares addresses shares secondaries) not-allowed)
        (unwrap! (mint-token signature message (unwrap! (element-at hashes u17) not-allowed) (unwrap! (element-at meta-urls u17) not-allowed) maxEditions editionCost clientMintPrice buyNowPrice mintAddresses mintShares addresses shares secondaries) not-allowed)
        (unwrap! (mint-token signature message (unwrap! (element-at hashes u18) not-allowed) (unwrap! (element-at meta-urls u18) not-allowed) maxEditions editionCost clientMintPrice buyNowPrice mintAddresses mintShares addresses shares secondaries) not-allowed)
        (unwrap! (mint-token signature message (unwrap! (element-at hashes u19) not-allowed) (unwrap! (element-at meta-urls u19) not-allowed) maxEditions editionCost clientMintPrice buyNowPrice mintAddresses mintShares addresses shares secondaries) not-allowed)
        (print {evt: "mint-token-twenty", txSender: tx-sender})
        (ok true)
    )
)

;; mint twenty tokens
(define-public (collection-mint-token-twenty (signature (buff 65)) (message (buff 32)) (hashes (list 20 (buff 32))) (meta-urls (list 20 (string-ascii 256))) (maxEditions uint) (editionCost uint) (clientMintPrice uint) (buyNowPrice uint))
    (begin
        (unwrap! (collection-mint-token signature message (unwrap! (element-at hashes u0) not-allowed) (unwrap! (element-at meta-urls u0) not-allowed) maxEditions editionCost clientMintPrice buyNowPrice) not-allowed)
        (unwrap! (collection-mint-token signature message (unwrap! (element-at hashes u1) not-allowed) (unwrap! (element-at meta-urls u1) not-allowed) maxEditions editionCost clientMintPrice buyNowPrice) not-allowed)
        (unwrap! (collection-mint-token signature message (unwrap! (element-at hashes u2) not-allowed) (unwrap! (element-at meta-urls u2) not-allowed) maxEditions editionCost clientMintPrice buyNowPrice) not-allowed)
        (unwrap! (collection-mint-token signature message (unwrap! (element-at hashes u3) not-allowed) (unwrap! (element-at meta-urls u3) not-allowed) maxEditions editionCost clientMintPrice buyNowPrice) not-allowed)
        (unwrap! (collection-mint-token signature message (unwrap! (element-at hashes u4) not-allowed) (unwrap! (element-at meta-urls u4) not-allowed) maxEditions editionCost clientMintPrice buyNowPrice) not-allowed)
        (unwrap! (collection-mint-token signature message (unwrap! (element-at hashes u5) not-allowed) (unwrap! (element-at meta-urls u5) not-allowed) maxEditions editionCost clientMintPrice buyNowPrice) not-allowed)
        (unwrap! (collection-mint-token signature message (unwrap! (element-at hashes u6) not-allowed) (unwrap! (element-at meta-urls u6) not-allowed) maxEditions editionCost clientMintPrice buyNowPrice) not-allowed)
        (unwrap! (collection-mint-token signature message (unwrap! (element-at hashes u7) not-allowed) (unwrap! (element-at meta-urls u7) not-allowed) maxEditions editionCost clientMintPrice buyNowPrice) not-allowed)
        (unwrap! (collection-mint-token signature message (unwrap! (element-at hashes u8) not-allowed) (unwrap! (element-at meta-urls u8) not-allowed) maxEditions editionCost clientMintPrice buyNowPrice) not-allowed)
        (unwrap! (collection-mint-token signature message (unwrap! (element-at hashes u9) not-allowed) (unwrap! (element-at meta-urls u9) not-allowed) maxEditions editionCost clientMintPrice buyNowPrice) not-allowed)
        (unwrap! (collection-mint-token signature message (unwrap! (element-at hashes u10) not-allowed) (unwrap! (element-at meta-urls u10) not-allowed) maxEditions editionCost clientMintPrice buyNowPrice) not-allowed)
        (unwrap! (collection-mint-token signature message (unwrap! (element-at hashes u11) not-allowed) (unwrap! (element-at meta-urls u11) not-allowed) maxEditions editionCost clientMintPrice buyNowPrice) not-allowed)
        (unwrap! (collection-mint-token signature message (unwrap! (element-at hashes u12) not-allowed) (unwrap! (element-at meta-urls u12) not-allowed) maxEditions editionCost clientMintPrice buyNowPrice) not-allowed)
        (unwrap! (collection-mint-token signature message (unwrap! (element-at hashes u13) not-allowed) (unwrap! (element-at meta-urls u13) not-allowed) maxEditions editionCost clientMintPrice buyNowPrice) not-allowed)
        (unwrap! (collection-mint-token signature message (unwrap! (element-at hashes u14) not-allowed) (unwrap! (element-at meta-urls u14) not-allowed) maxEditions editionCost clientMintPrice buyNowPrice) not-allowed)
        (unwrap! (collection-mint-token signature message (unwrap! (element-at hashes u15) not-allowed) (unwrap! (element-at meta-urls u15) not-allowed) maxEditions editionCost clientMintPrice buyNowPrice) not-allowed)
        (unwrap! (collection-mint-token signature message (unwrap! (element-at hashes u16) not-allowed) (unwrap! (element-at meta-urls u16) not-allowed) maxEditions editionCost clientMintPrice buyNowPrice) not-allowed)
        (unwrap! (collection-mint-token signature message (unwrap! (element-at hashes u17) not-allowed) (unwrap! (element-at meta-urls u17) not-allowed) maxEditions editionCost clientMintPrice buyNowPrice) not-allowed)
        (unwrap! (collection-mint-token signature message (unwrap! (element-at hashes u18) not-allowed) (unwrap! (element-at meta-urls u18) not-allowed) maxEditions editionCost clientMintPrice buyNowPrice) not-allowed)
        (unwrap! (collection-mint-token signature message (unwrap! (element-at hashes u19) not-allowed) (unwrap! (element-at meta-urls u19) not-allowed) maxEditions editionCost clientMintPrice buyNowPrice) not-allowed)
        (print {evt: "mint-token-twenty", txSender: tx-sender})
        (ok true)
    )
)

;; mint a new token
;; asset-hash: sha256 hash of asset file
;; max-editions: maximum number of editions allowed for this asset
;; royalties: a list of priciple/percentages to be be paid from sale price
;;
;; 1. transfer mint price to the administrator
;; 2. mint the token using built in mint function
;; 3. update the two maps - first contains the data indexed by the nft index, second
;; provides a reverse lookup based on the asset hash - this allows tokens to be located
;; from just a knowledge of the original asset.
;; Note series-original in the case of the original in series is just
;; mintCounter - for editions this provides a safety hook back to the original in cases
;; where the asset hash is unknown (ie cant be found from nft-lookup).
(define-public (mint-token (signature (buff 65)) (message-hash (buff 32)) (asset-hash (buff 32)) (metaDataUrl (string-ascii 256)) (maxEditions uint) (editionCost uint) (clientMintPrice uint) (buyNowPrice uint) (mintAddresses (list 4 principal)) (mintShares (list 4 uint)) (addresses (list 10 principal)) (shares (list 10 uint)) (secondaries (list 10 uint)))
    (begin
        (asserts! (is-ok (recover-pubkey signature message-hash)) (err u9))
        (print "mint-token pubkey recovered")
        (if (< (len metaDataUrl) u10) (ok (var-get mint-counter))
            (let
                (
                    ;; if client bypasses UI clientMintPrice then charge mint-price
                    (myMintPrice (max-of (var-get mint-price) clientMintPrice))
                    (mintCounter (var-get mint-counter))
                    (index (get nft-index (map-get? nft-lookup {asset-hash: asset-hash, edition: u1})))
                    (block-time (unwrap! (get-block-info? time u0) amount-not-set))
                )
                (asserts! (> maxEditions u0) editions-error)
                (asserts! (> (stx-get-balance tx-sender) (var-get mint-price)) cant-pay-mint-price)
                (asserts! (is-none index) asset-not-registered)

                ;; Note: series original is really for later editions to refer back to this one - this one IS the series original
                (map-insert nft-data {nft-index: mintCounter} {asset-hash: asset-hash, meta-data-url: metaDataUrl, max-editions: maxEditions, edition: u1, edition-cost: editionCost, series-original: mintCounter})

                ;; Note editions are 1 based and <= maxEditions - the one minted here is #1
                (map-insert nft-edition-counter {nft-index: mintCounter} {edition-counter: u2})

                (if (> buyNowPrice u0)
                    (map-insert nft-sale-data { nft-index: mintCounter } { sale-cycle-index: u1, sale-type: u1, increment-stx: u0, reserve-stx: u0, amount-stx: buyNowPrice, bidding-end-time: (+ block-height u200)})
                    (map-insert nft-sale-data { nft-index: mintCounter } { sale-cycle-index: u1, sale-type: u0, increment-stx: u0, reserve-stx: u0, amount-stx: u0, bidding-end-time: u0})
                )

                (map-insert nft-lookup {asset-hash: asset-hash, edition: u1} {nft-index: mintCounter})

                ;; The payment is split between the nft-beneficiaries with share > 0 they are set per edition
                (map-insert nft-beneficiaries {nft-index: mintCounter} {addresses: addresses, shares: shares, secondaries: secondaries})

                ;; finally - mint the NFT and step the counter
                (if (is-eq tx-sender (var-get administrator))
                    u0
                    (unwrap! (paymint-split mintCounter myMintPrice tx-sender mintAddresses mintShares) payment-error-collection)
                )
                (unwrap! (nft-mint? thisis mintCounter tx-sender) failed-to-mint-err)
                (print {evt: "mint-token", nftIndex: mintCounter, owner: tx-sender, amount: myMintPrice})
                (var-set mint-counter (+ mintCounter u1))
                (ok mintCounter)
            )
        )
    )
)

(define-public (collection-mint-token (signature (buff 65)) (message-hash (buff 32)) (asset-hash (buff 32)) (metaDataUrl (string-ascii 256)) (maxEditions uint) (editionCost uint) (clientMintPrice uint) (buyNowPrice uint))
    (begin
        (asserts! (is-ok (recover-pubkey signature message-hash)) (err u9))
        (if (< (len metaDataUrl) u10) (ok (var-get mint-counter))
            (let
                (
                    ;; if client bypasses UI clientMintPrice then charge mint-price
                    (myMintPrice (max-of (var-get mint-price) clientMintPrice))
                    (mintCounter (var-get mint-counter))
                    (index (get nft-index (map-get? nft-lookup {asset-hash: asset-hash, edition: u1})))
                    (block-time (unwrap! (get-block-info? time u0) amount-not-set))
                )
                (print {evt: "collection-mint-token", sender: tx-sender, meta-data-url: metaDataUrl})
                (asserts! (< mintCounter collection-max-supply) collection-limit-reached)
                (asserts! (> maxEditions u0) editions-error)
                (asserts! (> (stx-get-balance tx-sender) (var-get mint-price)) cant-pay-mint-price)
                (asserts! (is-none index) asset-not-registered)

                ;; Note: series original is really for later editions to refer back to this one - this one IS the series original
                (map-insert nft-data {nft-index: mintCounter} {asset-hash: asset-hash, meta-data-url: metaDataUrl, max-editions: maxEditions, edition: u1, edition-cost: editionCost, series-original: mintCounter})

                ;; Note editions are 1 based and <= maxEditions - the one minted here is #1
                (map-insert nft-edition-counter {nft-index: mintCounter} {edition-counter: u2})

                (if (> buyNowPrice u0)
                    (map-insert nft-sale-data { nft-index: mintCounter } { sale-cycle-index: u1, sale-type: u1, increment-stx: u0, reserve-stx: u0, amount-stx: buyNowPrice, bidding-end-time: (+ block-time u1814400)})
                    (map-insert nft-sale-data { nft-index: mintCounter } { sale-cycle-index: u1, sale-type: u0, increment-stx: u0, reserve-stx: u0, amount-stx: u0, bidding-end-time: (+ block-time u1814400)})
                )

                (map-insert nft-lookup {asset-hash: asset-hash, edition: u1} {nft-index: mintCounter})

                ;; finally - mint the NFT and step the counter
                (if (is-eq tx-sender (var-get administrator))
                    u0
                    (unwrap! (collection-paymint-split mintCounter myMintPrice tx-sender) payment-error-collection)
                )
                (unwrap! (nft-mint? thisis mintCounter tx-sender) failed-to-mint-err)
                (print {evt: "mint-token", nftIndex: mintCounter, owner: tx-sender, amount: myMintPrice})
                (var-set mint-counter (+ mintCounter u1))
                (ok mintCounter)
            )
        )
    )
)

;; the message is the hash of the asset-hash of the original artwork
;; the client calls utils.signPayloadEC(privateKey, asssetHash)
;; to generate the signature using the private key and the sha256 of the message.
;; The public key corresponding to this private key is 'signer' and
;; secp256k1-recover? returns this key and proves only the authorised key
;; could have sent this message
(define-private (recover-pubkey (signature (buff 65)) (hash-of-message (buff 32)))
  (let
    (
      ;; (hash (sha256 message))
      (pubkey (try! (secp256k1-recover? hash-of-message signature)))
    )
    ;; (print {evt: "verify-sig1", pubkey: pubkey, signer: (var-get signer), message: hash-of-message, signature: signature})
    (asserts! (is-eq pubkey (var-get signer)) (err u5))
    ;; (print {evt: "verify-sig", pubkey: pubkey, signer: (var-get signer)})
    (if (is-eq pubkey (var-get signer)) (ok true) (err u1))
  )
)

(define-private (max-of (i1 uint) (i2 uint))
    (if (> i1 i2)
        i1
        i2))

(define-public (mint-edition (nftIndex uint))
    (let
        (
            ;; before we start... check the hash corresponds to a minted asset
            (ahash          (unwrap! (get asset-hash   (map-get? nft-data {nft-index: nftIndex})) not-allowed))
            (metaDataUrl    (unwrap! (get meta-data-url   (map-get? nft-data {nft-index: nftIndex})) not-allowed))
            (maxEditions    (unwrap! (get max-editions (map-get? nft-data {nft-index: nftIndex})) not-allowed))
            (editionCost    (unwrap! (get edition-cost (map-get? nft-data {nft-index: nftIndex})) not-allowed))
            (editionCounter (unwrap! (get edition-counter (map-get? nft-edition-counter {nft-index: nftIndex})) edition-counter-error))
            (thisEdition    (default-to u0 (get nft-index (map-get? nft-lookup {asset-hash: ahash, edition: editionCounter}))))
            (block-time     (unwrap!  (get-block-info? time u0) amount-not-set))
            (mintCounter    (var-get mint-counter))
        )
        ;; can only mint an edition via buy now or bidding
        (asserts! (is-eq thisEdition u0) edition-counter-error)
        ;; Note - the edition index is 1 based and incremented before insertion in this method - therefore the test is '<=' here!
        (asserts! (<= editionCounter maxEditions) edition-limit-reached)
        ;; This asserts the first one has been minted already - see mint-token.
        (asserts! (> editionCounter u1) edition-counter-error)
        ;; check the buyer has enough funds..
        (asserts! (> (stx-get-balance tx-sender) editionCost) cant-pay-mint-price)
        ;; set max editions so we know where we are in the series
        (map-insert nft-data {nft-index: mintCounter} {asset-hash: ahash, meta-data-url: metaDataUrl, max-editions: maxEditions, edition: editionCounter, edition-cost: editionCost, series-original: nftIndex})
        ;; put the nft index into the list of editions in the look up map
        (map-insert nft-lookup {asset-hash: ahash, edition: editionCounter} {nft-index: mintCounter})
        ;; mint the NFT and update the counter for the next..
        (unwrap! (nft-mint? thisis mintCounter tx-sender) failed-to-mint-err)
        ;; saleType = 1 (buy now) - split out the payments according to royalties - or roll everything back.
        (if (> editionCost u0)
            (unwrap! (payment-split nftIndex editionCost tx-sender nftIndex) failed-to-mint-err)
            u0
        )

        ;; initialise the sale data - not for sale until the owner sets it.
        (map-insert nft-sale-data { nft-index: mintCounter } { sale-cycle-index: u1, sale-type: u0, increment-stx: u0, reserve-stx: u0, amount-stx: u0, bidding-end-time: (+ block-time u1814400)})

        (print {evt: "mint-edition", nftIndex: nftIndex, owner: tx-sender, edition: editionCounter, amount: editionCost})

        ;; inncrement the mint counter and edition counter ready for the next edition
        (map-set nft-edition-counter {nft-index: nftIndex} {edition-counter: (+ u1 editionCounter)})
        (var-set mint-counter (+ mintCounter u1))

        (ok mintCounter)
    )
)

;; allow the owner of the series original to set the cost of minting editions
;; the cost for each edition is taken from the series original and so we need to
;; operate on the the original here - ie nftIndex is the index of thee original
;; and NOT the edition andd only the creator of the series original can change this.
(define-public (set-edition-cost (nftIndex uint) (maxEditions uint) (editionCost uint))
    (let
        (
            (owner           (unwrap! (nft-get-owner? thisis nftIndex) not-allowed))
            (ahash           (unwrap! (get asset-hash   (map-get? nft-data {nft-index: nftIndex})) not-allowed))
            (metaDataUrl     (unwrap! (get meta-data-url   (map-get? nft-data {nft-index: nftIndex})) not-allowed))
            (edition         (unwrap! (get edition (map-get? nft-data {nft-index: nftIndex})) not-allowed))
            (seriesOriginal  (unwrap! (get series-original (map-get? nft-data {nft-index: nftIndex})) not-allowed))
        )
        (asserts! (unwrap! (is-approved nftIndex owner) nft-not-owned-err) nft-not-owned-err)
        (asserts! (is-eq nftIndex seriesOriginal) not-originale)
        (ok (map-set nft-data {nft-index: nftIndex} {asset-hash: ahash, meta-data-url: metaDataUrl, max-editions: maxEditions, edition: edition, edition-cost: editionCost, series-original: seriesOriginal}))
    )
)


;; set-sale-data updates the sale type and purchase info for a given NFT. Only the owner can call this method
;; and doing so make the asset transferable by the recipient - on condition of meeting the conditions of sale
;; This is equivalent to the setApprovalForAll method in ERC 721 contracts.
;; Assumption being made here is that all editions have the same sale data associated
(define-public (set-sale-data (nftIndex uint) (sale-type uint) (increment-stx uint) (reserve-stx uint) (amount-stx uint) (bidding-end-time uint))
    (let
        (
            ;; keeps track of the sale cycles for this NFT.
            (owner           (unwrap! (nft-get-owner? thisis nftIndex) not-allowed))
            (saleCycleIndex (unwrap! (get sale-cycle-index (map-get? nft-sale-data {nft-index: nftIndex})) amount-not-set))
            (saleType (unwrap! (get sale-type (map-get? nft-sale-data {nft-index: nftIndex})) amount-not-set))
            (currentBidIndex (default-to u0 (get high-bid-counter (map-get? nft-high-bid-counter {nft-index: nftIndex}))))
            (currentAmount (unwrap! (get-current-bid-amount nftIndex currentBidIndex) bidding-error))
        )
        ;; u2 means bidding is in progress and the sale data can't be changed.
        (asserts! (not (and (> currentAmount u0) (is-eq saleType u2))) bidding-error)
        ;; owner or approval can do this.
        (asserts! (unwrap! (is-approved nftIndex owner) nft-not-owned-err) nft-not-owned-err)
        ;; Note - don't override the sale cyle index here as this is a public method and can be called ad hoc. Sale cycle is update at end of sale!
        (asserts! (map-set nft-sale-data {nft-index: nftIndex} {sale-cycle-index: saleCycleIndex, sale-type: sale-type, increment-stx: increment-stx, reserve-stx: reserve-stx, amount-stx: amount-stx, bidding-end-time: bidding-end-time}) not-allowed)
        (print {evt: "set-sale-data", nftIndex: nftIndex, saleType: sale-type, increment: increment-stx, reserve: reserve-stx, amount: amount-stx, biddingEndTime: bidding-end-time})
        (ok true)
    )
)

;; see nft-tradable-trait
(define-public (unlist-item (nftIndex uint))
    (let
        (
            (saleCycleIndex (unwrap! (get sale-cycle-index (map-get? nft-sale-data {nft-index: nftIndex})) amount-not-set))
            (owner           (unwrap! (nft-get-owner? thisis nftIndex) not-allowed))
        )
        (asserts! (unwrap! (is-approved nftIndex owner) nft-not-owned-err) nft-not-owned-err)
        ;; Note - don't override the sale cyle index here as this is a public method and can be called ad hoc. Sale cycle is update at end of sale!
        (asserts! (map-set nft-sale-data {nft-index: nftIndex} {sale-cycle-index: saleCycleIndex, sale-type: u0, increment-stx: u0, reserve-stx: u0, amount-stx: u0, bidding-end-time: u0}) not-allowed)
        (print {evt: "unlist-item", nftIndex: nftIndex})
        (ok true)
    )
)

;; see nft-tradable-trait
(define-public (list-item (nftIndex uint) (amount uint))
    (let
        (
            (saleCycleIndex (unwrap! (get sale-cycle-index (map-get? nft-sale-data {nft-index: nftIndex})) amount-not-set))
            (owner           (unwrap! (nft-get-owner? thisis nftIndex) not-allowed))
        )
        (asserts! (unwrap! (is-approved nftIndex owner) nft-not-owned-err) nft-not-owned-err)
        ;; (map-set approvals {owner: tx-sender, operator: operator, nft-index: token-id} true)
        ;; Note - don't override the sale cyle index here as this is a public method and can be called ad hoc. Sale cycle is update at end of sale!
        (asserts! (map-set nft-sale-data {nft-index: nftIndex} {sale-cycle-index: saleCycleIndex, sale-type: u1, increment-stx: u0, reserve-stx: u0, amount-stx: amount, bidding-end-time: u0}) not-allowed)
        (print {evt: "list-item", nftIndex: nftIndex, amount: amount})
        (ok true)
    )
)

;; see nft-tradable-trait
(define-public (buy-now (nftIndex uint) (owner principal) (recipient principal))
    (let
        (
            (saleType (unwrap! (get sale-type (map-get? nft-sale-data {nft-index: nftIndex})) amount-not-set))
            (saleCycleIndex (unwrap! (get sale-cycle-index (map-get? nft-sale-data {nft-index: nftIndex})) amount-not-set))
            (amount (unwrap! (get amount-stx (map-get? nft-sale-data {nft-index: nftIndex})) amount-not-set))
            (ahash (get asset-hash (map-get? nft-data {nft-index: nftIndex})))
            (seriesOriginal  (unwrap! (get series-original (map-get? nft-data {nft-index: nftIndex})) not-allowed))
        )
        (asserts! (is-some ahash) asset-not-registered)
        (asserts! (is-eq saleType u1) not-approved-to-sell)
        (asserts! (>= amount u0) amount-not-set)

        ;; Make the royalty payments - then zero out the sale data and register the transfer
        (unwrap! (payment-split nftIndex amount tx-sender seriesOriginal) payment-error)
        (map-set nft-sale-data { nft-index: nftIndex } { sale-cycle-index: (+ saleCycleIndex u1), sale-type: u0, increment-stx: u0, reserve-stx: u0, amount-stx: u0, bidding-end-time: u0})
        ;; finally transfer ownership to the buyer (note: via the buyers transaction!)
        (print {evt: "buy-now", nftIndex: nftIndex, owner: owner, recipient: recipient, amount: amount})
        (nft-transfer? thisis nftIndex owner recipient)
    )
)

;; opening-bid
;; nft-index: unique index for NFT
;; The opening bid in the given sale cycle a given item.
(define-public (opening-bid (nftIndex uint) (bidAmount uint))
    (let
        (
            (amount (unwrap! (get amount-stx (map-get? nft-sale-data {nft-index: nftIndex})) amount-not-set))
            (saleType (unwrap! (get sale-type (map-get? nft-sale-data {nft-index: nftIndex})) amount-not-set))
            (saleCycle (unwrap! (get sale-cycle-index (map-get? nft-sale-data {nft-index: nftIndex})) amount-not-set))
            (biddingEndTime (unwrap! (get bidding-end-time (map-get? nft-sale-data {nft-index: nftIndex})) amount-not-set))
            (bidCounter (default-to u0 (get high-bid-counter (map-get? nft-high-bid-counter {nft-index: nftIndex}))))
        )

        ;; Check the user bid amount is the opening price OR the current bid plus increment
        (asserts! (is-eq bidAmount amount) bidding-amount-error)
        (asserts! (> biddingEndTime block-height) bidding-endtime-error)

        (unwrap! (stx-transfer? bidAmount tx-sender (as-contract tx-sender)) failed-to-stx-transfer)
        (map-insert nft-bid-history {nft-index: nftIndex, bid-index: bidCounter} {bidder: tx-sender, amount: bidAmount, bid-in-block: block-height, sale-cycle: saleCycle})
        (map-set nft-high-bid-counter {nft-index: nftIndex} {high-bid-counter: (+ bidCounter u1), sale-cycle: saleCycle})
        (print {evt: "opening-bid", nftIndex: nftIndex, txSender: tx-sender, amount: bidAmount})
        (ok bidAmount)
    )
)

(define-private (get-current-bidder (nftIndex uint) (currentBidIndex uint))
  (let
      (
        (currentBidder (unwrap! (get bidder (map-get? nft-bid-history {nft-index: nftIndex, bid-index: (- currentBidIndex u1)})) bidding-error))
      )
      (ok currentBidder)
  )
)

(define-private (get-current-bid-amount (nftIndex uint) (currentBidIndex uint))
  (if (is-eq currentBidIndex u0)
    (ok u0)
    (let
        (
            (currentAmount (default-to u0 (get amount (map-get? nft-bid-history {nft-index: nftIndex, bid-index: (- currentBidIndex u1)}))))
        )
        (ok currentAmount)
    )
  )
)

;; place-bid
;; nft-index: unique index for NFT
;; nextBidAmount: amount the user is bidding - i.e the amount display on th place bid button.
(define-public (place-bid (nftIndex uint) (nextBidAmount uint))
    (let
        (
            (bidding-end-time (unwrap! (get bidding-end-time (map-get? nft-sale-data {nft-index: nftIndex})) amount-not-set))
            (saleType (unwrap! (get sale-type (map-get? nft-sale-data {nft-index: nftIndex})) amount-not-set))
            (saleCycle (unwrap! (get sale-cycle-index (map-get? nft-sale-data {nft-index: nftIndex})) amount-not-set))
            (amountStart (unwrap! (get amount-stx (map-get? nft-sale-data {nft-index: nftIndex})) amount-not-set))
            (increment (unwrap! (get increment-stx (map-get? nft-sale-data {nft-index: nftIndex})) amount-not-set))
            (reserve (unwrap! (get reserve-stx (map-get? nft-sale-data {nft-index: nftIndex})) amount-not-set))
            (currentBidIndex (default-to u0 (get high-bid-counter (map-get? nft-high-bid-counter {nft-index: nftIndex}))))
            (currentBidder (unwrap! (get-current-bidder nftIndex currentBidIndex) bidding-error))
            (currentAmount (unwrap! (get-current-bid-amount nftIndex currentBidIndex) bidding-error))
            (owner (unwrap! (nft-get-owner? thisis nftIndex) nft-not-owned-err))
            (seriesOriginal  (unwrap! (get series-original (map-get? nft-data {nft-index: nftIndex})) not-allowed))
        )

        ;; Check the user bid amount is the opening price OR the current bid plus increment
        (asserts! (> currentAmount u0) user-amount-different)
        (asserts! (is-eq nextBidAmount (+ currentAmount increment)) user-amount-different)

        ;; if ( block-height > bidding-end-time) then this is either the winning or a too late bid on the NFT
        ;; a too late bid will have been rejected as the last bid resets the sale/bidding data on the item.
        ;; if its the last bid...
        ;;               1. Refund the currentBid to the bidder
        ;;               2. move currentBid to bid history
        ;;               3. Set the bid in nft-high-bid-counter - note 'set' so we overwrite the previous bid
        ;; (next-bid) we
        ;;               1. Refund the currentBid to the bidder
        ;;               2. Insert currentBid to bid history
        ;;               3. Set the bid in nft-high-bid-counter - note 'set' so we overwrite the previous bid

        (if (>  block-height bidding-end-time)
            (begin
                (print {evt: "place-bid-closure", nftIndex: nftIndex, biddingEndTime: bidding-end-time, amount: nextBidAmount, reserve: reserve})
                (unwrap! (refund-bid nftIndex currentBidder currentAmount) failed-to-stx-transfer)
                (if (< nextBidAmount reserve)
                    ;; if this bid is less than reserve & its the last bid then just refund previous bid
                    (unwrap! (ok true) failed-to-stx-transfer)
                    (begin
                        ;; WINNING BID - is the FIRST bid after bidding close.
                        (unwrap! (payment-split nftIndex nextBidAmount tx-sender seriesOriginal) payment-error)
                        (unwrap! (record-bid nftIndex nextBidAmount currentBidIndex  block-height saleCycle) failed-to-stx-transfer)
                        (map-set nft-sale-data { nft-index: nftIndex } { sale-cycle-index: (+ saleCycle u1), sale-type: u0, increment-stx: u0, reserve-stx: u0, amount-stx: u0, bidding-end-time: u0})
                        ;; finally transfer ownership to the buyer (note: via the buyers transaction!)
                        (unwrap! (nft-transfer? thisis nftIndex owner tx-sender) failed-to-stx-transfer)
                    )
                )
            )
            (begin
                (print {evt: "place-bid-refund", nftIndex: nftIndex, biddingEndTime: bidding-end-time, amount: nextBidAmount})
                (unwrap! (refund-bid nftIndex currentBidder currentAmount) failed-refund)
                (unwrap! (next-bid nftIndex nextBidAmount currentBidIndex saleCycle) failed-to-stx-transfer)
            )
        )
        ;;
        ;; NOTE: Above code will only reconcile IF a bid comes in after 'block-time'
        ;; We may need a manual trigger to end bidding when this doesn't happen - unless there is a
        ;; to repond to future events / timeouts that I dont know about.
        ;;
        (print {evt: "place-bid", nftIndex: nftIndex, txSender: tx-sender, amount: nextBidAmount})
        (ok true)
    )
)

;; close-bidding
;; nft-index: index of the NFT
;; closeType: type of closure, values are;
;;             1 = buy now closure - uses the last bid (thats held in escrow) to transfer the item to the bidder and to pay royalties
;;             2 = refund closure - the last bid gets refunded and sale is closed. The item ownership does not change.
;; Note bidding can also be closed automatically - if a bid is received after the bidding end time.
;; In the context of a 'live auction' items have no end time and are closed by the 'auctioneer'.
(define-public (close-bidding (nftIndex uint) (closeType uint))
    (let
        (
            (bidding-end-time (unwrap! (get bidding-end-time (map-get? nft-sale-data {nft-index: nftIndex})) amount-not-set))
            (saleType (unwrap! (get sale-type (map-get? nft-sale-data {nft-index: nftIndex})) amount-not-set))
            (saleCycleIndex (unwrap! (get sale-cycle-index (map-get? nft-sale-data {nft-index: nftIndex})) failed-to-close-1))
            (block-time (unwrap! (get-block-info? time u0) not-allowed))
            (currentBidIndex (default-to u0 (get high-bid-counter (map-get? nft-high-bid-counter {nft-index: nftIndex}))))
            (currentBidder (unwrap! (get-current-bidder nftIndex currentBidIndex) bidding-error))
            (currentAmount (unwrap! (get-current-bid-amount nftIndex currentBidIndex) bidding-error))
            (seriesOriginal  (unwrap! (get series-original (map-get? nft-data {nft-index: nftIndex})) not-allowed))
            (owner           (unwrap! (nft-get-owner? thisis nftIndex) not-allowed))
        )
        (asserts! (or (is-eq closeType u1) (is-eq closeType u2)) failed-to-close-1)
        ;; only the owner or administrator can call close
        (asserts! (or (unwrap! (is-approved nftIndex owner) nft-not-owned-err) (unwrap! (is-administrator) not-allowed)) not-allowed)
        ;; only the administrator can call close BEFORE the end time - note we use the less accurate
        ;; but fool proof block time here to prevent owner/client code jerry mandering the close function
        (asserts! (or (> block-time bidding-end-time) (unwrap! (is-administrator) failed-to-close-3)) failed-to-close-3)

        ;; Check for a current bid - if none then just reset the sale data to not selling
        (if (is-eq currentAmount u0)
            (map-set nft-sale-data { nft-index: nftIndex } { sale-cycle-index: (+ saleCycleIndex u1), sale-type: u0, increment-stx: u0, reserve-stx: u0, amount-stx: u0, bidding-end-time: u0})
            (if (is-eq closeType u1)
                (begin
                    ;; buy now closure - pay and transfer ownership
                    ;; note that the money to pay with is in the contract!
                    (print {evt: "close-bidding", nftIndex: nftIndex, payType: "from-contract", txSender: tx-sender, currentBidder: currentBidder, currentAmount: currentAmount, currentBidIndex: currentBidIndex})
                    (unwrap! (payment-split nftIndex currentAmount (as-contract tx-sender) seriesOriginal) payment-error)
                    (unwrap! (nft-transfer? thisis nftIndex (unwrap! (nft-get-owner? thisis nftIndex) nft-not-owned-err) tx-sender) transfer-error)
                )
                (begin
                    ;; refund closure - refund the bid and reset sale data
                    (print {evt: "close-bidding", nftIndex: nftIndex, payType: "refund", txSender: tx-sender, currentBidder: currentBidder, currentAmount: currentAmount})
                    (unwrap! (refund-bid nftIndex currentBidder currentAmount) failed-refund)
                    (map-set nft-sale-data { nft-index: nftIndex } { sale-cycle-index: (+ saleCycleIndex u1), sale-type: u0, increment-stx: u0, reserve-stx: u0, amount-stx: u0, bidding-end-time: u0})
                )
            )
        )
        (print {evt: "close-bidding", nftIndex: nftIndex, closeType: closeType, txSender: tx-sender, currentBidder: currentBidder, currentAmount: currentAmount})
        (ok nftIndex)
    )
)

;; read only methods
;; ---------------
(define-read-only (get-administrator)
    (var-get administrator))

(define-read-only (is-administrator)
    (ok (is-eq (var-get administrator) tx-sender)))

(define-read-only (get-mint-counter)
  (ok (var-get mint-counter))
)
(define-read-only (get-mint-price)
    (var-get mint-price))

(define-read-only (get-token-by-index (nftIndex uint))
    (ok (get-all-data nftIndex))
)
(define-read-only (get-beneficiaries (nftIndex uint))
    (let
        (
            (beneficiaries (map-get? nft-beneficiaries {nft-index: nftIndex}))
        )
        (ok beneficiaries)
    )
)
(define-read-only (get-collection-beneficiaries)
    (let
        (
            (the-mint-addresses  (var-get collection-mint-addresses))
            (the-mint-shares  (var-get collection-mint-shares))
            (the-addresses  (var-get collection-addresses))
            (the-shares  (var-get collection-shares))
            (the-secondaries  (var-get collection-secondaries))
        )
        (ok (tuple  (collection-mint-addresses the-mint-addresses)
                    (collection-mint-shares the-mint-shares)
                    (collection-addresses the-addresses)
                    (collection-shares the-shares)
                    (collection-secondaries the-secondaries)))
    )
)
(define-read-only (get-bid-at-index (nftIndex uint) (bidIndex uint))
    (let
        (
            (the-bid (map-get? nft-bid-history {nft-index: nftIndex, bid-index: bidIndex}))
        )
        (ok the-bid)
    )
)
;; Get the edition from a knowledge of the #1 edition and the specific edition number
(define-read-only (get-edition-by-hash (asset-hash (buff 32)) (edition uint))
    (let
        (
            (nftIndex (unwrap! (get nft-index (map-get? nft-lookup {asset-hash: asset-hash, edition: edition})) amount-not-set))
        )
        (ok (get-all-data nftIndex))
    )
)
(define-read-only (get-token-by-hash (asset-hash (buff 32)))
    (let
        (
            (nftIndex (unwrap! (get nft-index (map-get? nft-lookup {asset-hash: asset-hash, edition: u1})) amount-not-set))
        )
        (ok (get-all-data nftIndex))
    )
)
(define-read-only (get-contract-data)
    (let
        (
            (the-administrator  (var-get administrator))
            (the-mint-price  (var-get mint-price))
            (the-mint-counter  (var-get mint-counter))
            (the-token-name  token-name)
            (the-token-symbol  token-symbol)
        )
        (ok (tuple  (administrator the-administrator)
                    (mintPrice the-mint-price)
                    (mintCounter the-mint-counter)
                    (tokenName the-token-name)
                    (tokenSymbol the-token-symbol)))
    )
)
(define-private (get-all-data (nftIndex uint))
    (let
        (
            (the-owner                  (unwrap-panic (nft-get-owner? thisis nftIndex)))
            (the-token-info             (map-get? nft-data {nft-index: nftIndex}))
            (the-sale-data              (map-get? nft-sale-data {nft-index: nftIndex}))
            (the-beneficiary-data       (map-get? nft-beneficiaries {nft-index: nftIndex}))
            (the-edition-counter        (default-to u0 (get edition-counter (map-get? nft-edition-counter {nft-index: nftIndex}))))
            (the-high-bid-counter       (default-to u0 (get high-bid-counter (map-get? nft-high-bid-counter {nft-index: nftIndex}))))
        )
        (ok (tuple  (bidCounter the-high-bid-counter)
                    (editionCounter the-edition-counter)
                    (nftIndex nftIndex)
                    (tokenInfo the-token-info)
                    (saleData the-sale-data)
                    (beneficiaryData the-beneficiary-data)
                    (owner the-owner)
            )
        )
    )
)
(define-read-only (get-sale-data (nftIndex uint))
    (match (map-get? nft-sale-data {nft-index: nftIndex})
        mySaleData
        (ok mySaleData)
        not-found
    )
)
(define-read-only (get-token-name)
    (ok token-name)
)

(define-read-only (get-token-symbol)
    (ok token-symbol)
)
(define-read-only (get-balance)
    (begin
        (asserts! (is-eq (var-get administrator) tx-sender) not-allowed)
        (ok (stx-get-balance (as-contract tx-sender)))
    )
)
;; private methods
(define-private (refund-bid (nftIndex uint) (currentBidder principal) (currentAmount uint))
    (begin
        (unwrap! (as-contract (stx-transfer? currentAmount tx-sender currentBidder)) failed-to-stx-transfer)
        (print {evt: "refund-bid", nftIndex: nftIndex, txSender: tx-sender, currentBidder: currentBidder, currentAmount: currentAmount})
        (ok true)
    )
)
(define-private (record-bid (nftIndex uint) (bidAmount uint) (bidCounter uint) (saleCycle uint))
    (begin
        (map-insert nft-bid-history {nft-index: nftIndex, bid-index: bidCounter} {bidder: tx-sender, amount: bidAmount, bid-in-block:  block-height, sale-cycle: saleCycle})
        (map-set nft-high-bid-counter {nft-index: nftIndex} {high-bid-counter: (+ bidCounter u1), sale-cycle: saleCycle})
        (print {evt: "record-bid", nftIndex: nftIndex, txSender: tx-sender, bidAmount: bidAmount, bidCounter: bidCounter, saleCycle: saleCycle})
        (ok true)
    )
)
(define-private (next-bid (nftIndex uint) (bidAmount uint) (bidCounter uint) (saleCycle uint))
    (begin
        (unwrap! (stx-transfer? bidAmount tx-sender (as-contract tx-sender)) failed-to-stx-transfer)
        (map-insert nft-bid-history {nft-index: nftIndex, bid-index: bidCounter} {bidder: tx-sender, amount: bidAmount, bid-in-block:  block-height, sale-cycle: saleCycle})
        (map-set nft-high-bid-counter {nft-index: nftIndex} {high-bid-counter: (+ bidCounter u1), sale-cycle: saleCycle})
        (ok true)
    )
)
;; split payment of the mint price to each recipient.
(define-private (paymint-split (nftIndex uint) (myMintPrice uint) (payer principal) (mintAddresses (list 4 principal)) (mintShares (list 4 uint)))
    (let
        (
            (split u0)
        )
        (+ split (unwrap! (pay-royalty payer myMintPrice (unwrap! (element-at mintAddresses u0) payment-address-error) (unwrap! (element-at mintShares u0) payment-share-error)) payment-share-error))
        (+ split (unwrap! (pay-royalty payer myMintPrice (unwrap! (element-at mintAddresses u1) payment-address-error) (unwrap! (element-at mintShares u1) payment-share-error)) payment-share-error))
        (+ split (unwrap! (pay-royalty payer myMintPrice (unwrap! (element-at mintAddresses u2) payment-address-error) (unwrap! (element-at mintShares u2) payment-share-error)) payment-share-error))
        (+ split (unwrap! (pay-royalty payer myMintPrice (unwrap! (element-at mintAddresses u3) payment-address-error) (unwrap! (element-at mintShares u3) payment-share-error)) payment-share-error))
        ;; (print {evt: "paymint-split", nftIndex: nftIndex, payer: payer, mintPrice: myMintPrice, txSender: tx-sender})
        (ok split)
    )
)
(define-private (collection-paymint-split (nftIndex uint) (myMintPrice uint) (payer principal))
    (let
        (
            (mintAddresses (var-get collection-mint-addresses))
            (mintShares (var-get collection-mint-shares))
        )
        (paymint-split nftIndex myMintPrice payer mintAddresses mintShares)
    )
)
;; sends payments to each recipient listed in the royalties
;; Note this is called by mint-edition where thee nftIndex actuallt referes to the series orginal and is where the royalties are stored.
(define-private (payment-split (nftIndex uint) (saleAmount uint) (payer principal) (seriesOriginal uint))
    (if (var-get is-collection)
        (let
            (
                (addresses (var-get collection-addresses))
                (shares (var-get collection-shares))
                (secondaries (var-get collection-secondaries))
                (saleCycle (unwrap! (get sale-cycle-index (map-get? nft-sale-data {nft-index: nftIndex})) amount-not-set))
                (split u0)
            )
            (internal-payment-split nftIndex saleAmount payer seriesOriginal addresses shares secondaries saleCycle)
        )
        (let
            (
                (addresses (unwrap! (get addresses (map-get? nft-beneficiaries {nft-index: seriesOriginal})) failed-to-mint-err))
                (shares (unwrap! (get shares (map-get? nft-beneficiaries {nft-index: seriesOriginal})) failed-to-mint-err))
                (secondaries (unwrap! (get secondaries (map-get? nft-beneficiaries {nft-index: seriesOriginal})) failed-to-mint-err))
                (saleCycle (unwrap! (get sale-cycle-index (map-get? nft-sale-data {nft-index: nftIndex})) amount-not-set))
                (split u0)
            )
            (internal-payment-split nftIndex saleAmount payer seriesOriginal addresses shares secondaries saleCycle)
        )
    )
)

(define-private (internal-payment-split (nftIndex uint) (saleAmount uint) (payer principal) (seriesOriginal uint) (addresses (list 10 principal)) (shares (list 10 uint)) (secondaries (list 10 uint)) (saleCycle uint))
    (let
        ((split u0))
        (+ split (unwrap! (pay-royalty payer saleAmount (unwrap! (nft-get-owner? thisis nftIndex) payment-address-error) (unwrap! (if (is-eq saleCycle u1) (element-at shares u0) (element-at secondaries u0)) payment-share-error)) payment-share-error))
        (+ split (unwrap! (pay-royalty payer saleAmount (unwrap! (element-at addresses u1) payment-address-error) (unwrap! (if (is-eq saleCycle u1) (element-at shares u1) (element-at secondaries u1)) payment-share-error)) payment-share-error))
        (+ split (unwrap! (pay-royalty payer saleAmount (unwrap! (element-at addresses u2) payment-address-error) (unwrap! (if (is-eq saleCycle u1) (element-at shares u2) (element-at secondaries u2)) payment-share-error)) payment-share-error))
        (+ split (unwrap! (pay-royalty payer saleAmount (unwrap! (element-at addresses u3) payment-address-error) (unwrap! (if (is-eq saleCycle u1) (element-at shares u3) (element-at secondaries u3)) payment-share-error)) payment-share-error))
        (+ split (unwrap! (pay-royalty payer saleAmount (unwrap! (element-at addresses u4) payment-address-error) (unwrap! (if (is-eq saleCycle u1) (element-at shares u4) (element-at secondaries u4)) payment-share-error)) payment-share-error))
        (+ split (unwrap! (pay-royalty payer saleAmount (unwrap! (element-at addresses u5) payment-address-error) (unwrap! (if (is-eq saleCycle u1) (element-at shares u5) (element-at secondaries u5)) payment-share-error)) payment-share-error))
        (+ split (unwrap! (pay-royalty payer saleAmount (unwrap! (element-at addresses u6) payment-address-error) (unwrap! (if (is-eq saleCycle u1) (element-at shares u6) (element-at secondaries u6)) payment-share-error)) payment-share-error))
        (+ split (unwrap! (pay-royalty payer saleAmount (unwrap! (element-at addresses u7) payment-address-error) (unwrap! (if (is-eq saleCycle u1) (element-at shares u7) (element-at secondaries u7)) payment-share-error)) payment-share-error))
        (+ split (unwrap! (pay-royalty payer saleAmount (unwrap! (element-at addresses u8) payment-address-error) (unwrap! (if (is-eq saleCycle u1) (element-at shares u8) (element-at secondaries u8)) payment-share-error)) payment-share-error))
        (+ split (unwrap! (pay-royalty payer saleAmount (unwrap! (element-at addresses u9) payment-address-error) (unwrap! (if (is-eq saleCycle u1) (element-at shares u9) (element-at secondaries u9)) payment-share-error)) payment-share-error))
        ;; (print {evt: "payment-split", nftIndex: nftIndex, saleCycle: saleCycle, payer: payer, saleAmount: saleAmount, txSender: tx-sender})
        (ok split)
    )
)

;; unit of saleAmount is in Satoshi and the share variable is a percentage (ex for 5% it will be equal to 5)
;; also the scalor is 1 on first purchase - direct from artist and 2 for secondary sales - so the seller gets half the
;; sale value and each royalty address gets half their original amount.
(define-private (pay-royalty (payer principal) (saleAmount uint) (payee principal) (share uint))
    (if (> share u0)
        (let
            (
                (split (/ (* saleAmount share) percentage-with-twodp))
            )
            ;; ignore royalty payment if its to the buyer / tx-sender.
            (if (not (is-eq tx-sender payee))
                (unwrap! (stx-transfer? split payer payee) transfer-error)
                true
            )
            (print {evt: "pay-royalty-primary", payee: payee, payer: payer, saleAmount: saleAmount, share: share, split: split, txSender: tx-sender})
            (ok split)
        )
        (ok u0)
    )
)
