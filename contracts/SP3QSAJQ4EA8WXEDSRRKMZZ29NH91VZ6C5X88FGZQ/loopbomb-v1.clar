
;; Interface definitions
;; test/mocknet
;; (impl-trait 'SP3QSAJQ4EA8WXEDSRRKMZZ29NH91VZ6C5X88FGZQ.nft-approvable-trait.nft-approvable-trait)
;; (impl-trait 'SP3QSAJQ4EA8WXEDSRRKMZZ29NH91VZ6C5X88FGZQ.nft-trait.nft-trait)
;; mainnet
;; (impl-trait SP3QSAJQ4EA8WXEDSRRKMZZ29NH91VZ6C5X88FGZQ.nft-approvable-trait.nft-approvable-trait)
;; (impl-trait SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

;; contract variables
(define-data-var administrator principal 'SP3QSAJQ4EA8WXEDSRRKMZZ29NH91VZ6C5X88FGZQ)
(define-data-var mint-price uint u100000)
(define-data-var base-token-uri (string-ascii 256) "https://loopbomb.io/nfts")
(define-data-var mint-counter uint u0)
(define-data-var platform-fee uint u5)
;; constants
(define-constant token-name "loopbomb")
(define-constant token-symbol "LOOP")

;; Non Fungible Token, modeled after ERC-721 via nft-trait
;; Note this is a basic implementation - no support yet for setting approvals for assets
;; NFT are identified by nft-index (uint) which is tied via a reverse lookup to a real world
;; asset hash - SHA 256 32 byte value. The Asset Hash is used to tie arbitrary real world
;; data to the NFT
(define-non-fungible-token my-nft uint)

;; data structures
(define-map nft-approvals {nft-index: uint} {approval: principal})
(define-map nft-lookup {asset-hash: (buff 32), edition: uint} {nft-index: uint})
(define-map nft-data {nft-index: uint} {asset-hash: (buff 32), meta-data-url: (buff 200), max-editions: uint, edition: uint, edition-cost: uint, mint-block-height: uint, series-original: uint})
(define-map nft-sale-data {nft-index: uint} {sale-type: uint, increment-stx: uint, reserve-stx: uint, amount-stx: uint, bidding-end-time: uint, sale-cycle-index: uint})
(define-map nft-beneficiaries {nft-index: uint} { addresses: (list 10 principal), shares: (list 10 uint) })
(define-map nft-bid-history {nft-index: uint, bid-index: uint} {sale-cycle: uint, bidder: principal, amount: uint, app-timestamp: uint})
(define-map nft-offer-history {nft-index: uint, offer-index: uint} {sale-cycle: uint, offerer: principal, app-timestamp: uint, amount: uint, accepted: uint})

;; counters keep track per NFT of the...
;;       a) number of editions minted (1 based index)
;;       b) number of offers made (0 based index)
;;       c) number of bids made (0 based index)
(define-map nft-offer-counter {nft-index: uint} {offer-counter: uint, sale-cycle: uint})
(define-map nft-edition-counter {nft-index: uint} {edition-counter: uint})
(define-map nft-high-bid-counter {nft-index: uint} {high-bid-counter: uint, sale-cycle: uint})

(define-constant percentage-on-secondary u10)
(define-constant percentage-with-twodp u10000000000)

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
(define-constant payment-address-error (err u33))
(define-constant payment-share-error (err u34))
(define-constant bidding-error (err u35))
(define-constant prevbid-bidding-error (err u36))
(define-constant not-originale (err u37))
(define-constant bidding-opening-error (err u38))
(define-constant bidding-amount-error (err u39))
(define-constant bidding-endtime-error (err u40))

(define-constant nft-not-owned-err (err u401)) ;; unauthorized
(define-constant sender-equals-recipient-err (err u405)) ;; method not allowed
(define-constant nft-not-found-err (err u404)) ;; not found

;; interface methods
;; from nft-trait: Last token ID, limited to uint range
;; note decrement as mint counter is the id of the next nft
(define-read-only (get-last-token-id)
  (ok (- (var-get mint-counter) u1))
)

;; from nft-trait: URI for metadata associated with the token
(define-read-only (get-token-uri (nftIndex uint))
  (ok (some (var-get base-token-uri)))
)

;; from nft-trait: Gets the owner of the 'SPecified token ID.
(define-read-only (get-owner (nftIndex uint))
  (ok (nft-get-owner? my-nft nftIndex))
)

;; from nft-trait: Gets the owner of the 'SPecified token ID.
(define-read-only (get-approval (nftIndex uint))
  (ok (unwrap! (get approval (map-get? nft-approvals {nft-index: nftIndex})) not-found))
)

;; sets an approval principal - allowed to call transfer on owner behalf.
(define-public (set-approval-for (nftIndex uint) (approval principal))
    (if (is-owner nftIndex tx-sender)
        (begin
            (map-set nft-approvals {nft-index: nftIndex} {approval: approval})
            (ok true)
        )
        nft-not-owned-err
    )
)

;; Transfers tokens to a 'SPecified principal.
(define-public (transfer (nftIndex uint) (owner principal) (recipient principal))
  (if (and (is-owner-or-approval nftIndex owner) (is-owner-or-approval nftIndex tx-sender))
    (match (nft-transfer? my-nft nftIndex owner recipient)
        success (ok true)
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

(define-private (is-owner (nftIndex uint) (user principal))
  (is-eq user (unwrap! (nft-get-owner? my-nft nftIndex) false))
)
(define-private (is-approval (nftIndex uint) (user principal))
  (is-eq user (unwrap! (get approval (map-get? nft-approvals {nft-index: nftIndex})) false))
)
(define-private (is-owner-or-approval (nftIndex uint) (user principal))
    (if (is-owner nftIndex user) true
        (if (is-approval nftIndex user) true false)
    )
)

;; public methods
;; --------------
;; the contract administrator can change the contract administrator
(define-public (transfer-administrator (new-administrator principal))
    (begin
        (asserts! (is-eq (var-get administrator) tx-sender) not-allowed)
        (var-set administrator new-administrator)
        (ok true)
    )
)

;; the contract administrator can change the transfer fee charged by the contract on sale of tokens
(define-public (change-fee (new-fee uint))
    (begin
        (asserts! (is-eq (var-get administrator) tx-sender) not-allowed)
        (var-set platform-fee new-fee)
        (ok true)
    )
)

;; the contract administrator can change the base uri - where meta data for tokens in this contract
;; are located
(define-public (update-base-token-uri (new-base-token-uri (string-ascii 256)))
    (begin
        (asserts! (is-eq (var-get administrator) tx-sender) not-allowed)
        (var-set base-token-uri new-base-token-uri)
        (ok true)
    )
)

;; the contract administrator can change the mint price
(define-public (update-mint-price (new-mint-price uint))
    (begin
        (asserts! (is-eq (var-get administrator) tx-sender) not-allowed)
        (var-set mint-price new-mint-price)
        (ok true)
    )
)

;; The administrator can transfer the balance in the contract to another address
(define-public (transfer-balance (recipient principal))
    (let
        (
            (balance (stx-get-balance (as-contract tx-sender)))
        )
        (asserts! (is-eq (var-get administrator) tx-sender) not-allowed)
        (unwrap! (stx-transfer? balance (as-contract tx-sender) recipient) failed-to-stx-transfer)
        (print {evt: "transfer-balance", recipient: recipient, balance: balance})
        (ok balance)
    )
)

;; adds an offer to the list of offers on an NFT
(define-public (make-offer (nft-index uint) (amount uint) (app-timestamp uint))
    (let
        (
            (saleType (unwrap! (get sale-type (map-get? nft-sale-data {nft-index: nft-index})) not-allowed))
            (offerCounter (default-to u0 (get offer-counter (map-get? nft-offer-counter {nft-index: nft-index}))))
            (saleCycleIndex (unwrap! (get sale-cycle-index (map-get? nft-sale-data {nft-index: nft-index})) amount-not-set))
        )
        (map-insert nft-offer-history {nft-index: nft-index, offer-index: offerCounter} {sale-cycle: saleCycleIndex, offerer: tx-sender, app-timestamp: app-timestamp, amount: amount, accepted: u0})
        (map-set nft-offer-counter {nft-index: nft-index} {sale-cycle: saleCycleIndex, offer-counter: (+ offerCounter u1)})
        (ok (+ offerCounter u1))
    )
)

;; accept-offer
;; marks offer as accepted and transfers ownership to the recipient
(define-public (accept-offer (nft-index uint) (offer-index uint) (owner principal) (recipient principal))
    (let
        (
            (saleType (unwrap! (get sale-type (map-get? nft-sale-data {nft-index: nft-index})) not-allowed))
            (offerer (unwrap! (get offerer (map-get? nft-offer-history {nft-index: nft-index, offer-index: offer-index})) not-allowed))
            (app-timestamp (unwrap! (get app-timestamp (map-get? nft-offer-history {nft-index: nft-index, offer-index: offer-index})) not-allowed))
            (sale-cycle (unwrap! (get sale-cycle (map-get? nft-offer-history {nft-index: nft-index, offer-index: offer-index})) not-allowed))
            (amount (unwrap! (get amount (map-get? nft-offer-history {nft-index: nft-index, offer-index: offer-index})) not-allowed))
        )
        (asserts! (is-eq saleType u3) not-allowed)
        (map-set nft-offer-history {nft-index: nft-index, offer-index: offer-index} {sale-cycle: sale-cycle, offerer: offerer, app-timestamp: app-timestamp, amount: amount, accepted: u1})
        (ok (transfer nft-index owner recipient))
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
(define-public (mint-token (asset-hash (buff 32)) (metaDataUrl (buff 200)) (maxEditions uint) (editionCost uint) (addresses (list 10 principal)) (shares (list 10 uint)))
    (let
        (
            (mintCounter (var-get mint-counter))
            (ahash (get asset-hash (map-get? nft-data {nft-index: (var-get mint-counter)})))
            (block-time (unwrap! (get-block-info? time u0) amount-not-set))
        )
        (asserts! (> maxEditions u0) editions-error)
        (asserts! (> (stx-get-balance tx-sender) (var-get mint-price)) cant-pay-mint-price)
        (asserts! (is-none ahash) asset-not-registered)

        ;; Note: series original is really for later editions to refer back to this one - this one IS the series original
        (map-insert nft-data {nft-index: mintCounter} {asset-hash: asset-hash, meta-data-url: metaDataUrl, max-editions: maxEditions, edition: u1, edition-cost: editionCost, mint-block-height: block-height, series-original: mintCounter})

        ;; Note editions are 1 based and <= maxEditions - the one minted here is #1
        (map-insert nft-edition-counter {nft-index: mintCounter} {edition-counter: u2})

        ;; By default we accept offers - sale type can be changed via the UI.
        (map-insert nft-sale-data { nft-index: mintCounter } { sale-cycle-index: u1, sale-type: u0, increment-stx: u0, reserve-stx: u0, amount-stx: u0, bidding-end-time: (+ block-time u1814400)})

        (map-insert nft-lookup {asset-hash: asset-hash, edition: u1} {nft-index: mintCounter})

        ;; The payment is split between the nft-beneficiaries with share > 0 they are set per edition
        (map-insert nft-beneficiaries {nft-index: mintCounter} {addresses: addresses, shares: shares})

        ;; finally - mint the NFT and step the counter
        (if (is-eq tx-sender (var-get administrator))
            (print "mint-token : tx-sender is contract - skipping mint price")
            (begin
                (unwrap! (stx-transfer? (var-get mint-price) tx-sender (var-get administrator)) failed-to-stx-transfer)
                (print "mint-token : tx-sender paid mint price")
            )
        )
        (unwrap! (nft-mint? my-nft mintCounter tx-sender) failed-to-mint-err)
        (print {evt: "mint-token", nftIndex: mintCounter, owner: tx-sender, amount: (var-get mint-price)})
        (var-set mint-counter (+ mintCounter u1))
        (ok mintCounter)
    )
)

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
        ;; can only mint an edition via buy now or bidding - not offers
        (asserts! (is-eq thisEdition u0) edition-counter-error)
        ;; Note - the edition index is 1 based and incremented before insertion in this method - therefore the test is '<=' here!
        (asserts! (<= editionCounter maxEditions) edition-limit-reached)
        ;; This asserts the first one has been minted already - see mint-token.
        (asserts! (> editionCounter u1) edition-counter-error)
        ;; check the buyer has enough funds..
        (asserts! (> (stx-get-balance tx-sender) editionCost) cant-pay-mint-price)
        ;; set max editions so we know where we are in the series
        (map-insert nft-data {nft-index: mintCounter} {asset-hash: ahash, meta-data-url: metaDataUrl, max-editions: maxEditions, edition: editionCounter, edition-cost: editionCost, mint-block-height: block-height, series-original: nftIndex})
        ;; put the nft index into the list of editions in the look up map
        (map-insert nft-lookup {asset-hash: ahash, edition: editionCounter} {nft-index: mintCounter})
        ;; mint the NFT and update the counter for the next..
        (unwrap! (nft-mint? my-nft mintCounter tx-sender) failed-to-mint-err)
        ;; saleType = 1 (buy now) - split out the payments according to royalties - or roll everything back.
        (if (> editionCost u0)
            (begin (unwrap! (payment-split nftIndex editionCost tx-sender) failed-to-mint-err) (print "mint-edition : payment split made"))
                (print "mint-edition : payment not required")
        )
        ;; (print "mint-edition : payment managed")

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
            (ahash           (unwrap! (get asset-hash   (map-get? nft-data {nft-index: nftIndex})) not-allowed))
            (metaDataUrl     (unwrap! (get meta-data-url   (map-get? nft-data {nft-index: nftIndex})) not-allowed))
            (edition         (unwrap! (get edition (map-get? nft-data {nft-index: nftIndex})) not-allowed))
            (mintBlockHeight (unwrap! (get mint-block-height (map-get? nft-data {nft-index: nftIndex})) not-allowed))
            (seriesOriginal  (unwrap! (get series-original (map-get? nft-data {nft-index: nftIndex})) not-allowed))
        )
        (asserts! (is-owner nftIndex tx-sender) nft-not-owned-err)
        (asserts! (is-eq nftIndex seriesOriginal) not-originale)
        (ok (map-set nft-data {nft-index: nftIndex} {asset-hash: ahash, meta-data-url: metaDataUrl, max-editions: maxEditions, edition: edition, edition-cost: editionCost, mint-block-height: mintBlockHeight, series-original: seriesOriginal}))
    )
)


;; set-sale-data updates the sale type and purchase info for a given NFT. Only the owner can call this method
;; and doing so make the asset transferable by the recipient - on condition of meeting the conditions of sale
;; This is equivalent to the setApprovalForAll method in ERC 721 contracts.
;; Assumption being made here is that all editions have the same sale data associated
(define-public (set-sale-data (nftIndex uint) (sale-type uint) (increment-stx uint) (reserve-stx uint) (amount-stx uint) (bidding-end-time uint))
    (let
        (
            ;; before we start... check the hash corresponds to a minted asset
            (saleCycleIndex (unwrap! (get sale-cycle-index (map-get? nft-sale-data {nft-index: nftIndex})) amount-not-set))
            (saleType (unwrap! (get sale-type (map-get? nft-sale-data {nft-index: nftIndex})) amount-not-set))
            (currentBidIndex (default-to u0 (get high-bid-counter (map-get? nft-high-bid-counter {nft-index: nftIndex}))))
            (currentAmount (unwrap! (get-current-bid-amount nftIndex currentBidIndex) bidding-error))
        )
        (asserts! (not (and (> currentAmount u0) (is-eq saleType u2))) bidding-error)
        (print {evt: "set-sale-data", nftIndex: nftIndex, saleType: sale-type, increment: increment-stx, reserve: reserve-stx, amount: amount-stx, biddingEndTime: bidding-end-time})
        (if (is-owner nftIndex tx-sender)
            ;; Note - don't override the sale cyle index here as this is a public method and can be called ad hoc. Sale cycle is update at end of sale!
            (if (map-set nft-sale-data {nft-index: nftIndex} {sale-cycle-index: saleCycleIndex, sale-type: sale-type, increment-stx: increment-stx, reserve-stx: reserve-stx, amount-stx: amount-stx, bidding-end-time: bidding-end-time})
                (ok nftIndex) not-allowed
            )
            not-allowed
        )
    )
)

;; buy-now
;; pay royalties and transfer asset ownership to tx-sender.
;; Checks that:
;;             a) asset is registered
;;             b) on sale via buy now
;;             c) amount is set
;;
(define-public (buy-now (nftIndex uint) (owner principal) (recipient principal))
    (let
        (
            (saleType (unwrap! (get sale-type (map-get? nft-sale-data {nft-index: nftIndex})) amount-not-set))
            (saleCycleIndex (unwrap! (get sale-cycle-index (map-get? nft-sale-data {nft-index: nftIndex})) amount-not-set))
            (amount (unwrap! (get amount-stx (map-get? nft-sale-data {nft-index: nftIndex})) amount-not-set))
            (ahash (get asset-hash (map-get? nft-data {nft-index: nftIndex})))
        )
        (asserts! (is-some ahash) asset-not-registered)
        (asserts! (is-eq saleType u1) not-approved-to-sell)
        (asserts! (> amount u0) amount-not-set)

        ;; Make the royalty payments - then zero out the sale data and register the transfer
        ;; (print "buy-now : Make the royalty payments")
        (print (unwrap! (payment-split nftIndex amount tx-sender) payment-error))
        (map-set nft-sale-data { nft-index: nftIndex } { sale-cycle-index: (+ saleCycleIndex u1), sale-type: u0, increment-stx: u0, reserve-stx: u0, amount-stx: u0, bidding-end-time: u0})
        ;; (print "buy-now : Added internal transfer - transfering nft...")
        ;; finally transfer ownership to the buyer (note: via the buyers transaction!)
        (print {evt: "buy-now", nftIndex: nftIndex, owner: owner, recipient: recipient, amount: amount})
        (nft-transfer? my-nft nftIndex owner recipient)
    )
)

;; opening-bid
;; nft-index: unique index for NFT
;; The opening bid in the given sale cycle a given item.
(define-public (opening-bid (nftIndex uint) (bidAmount uint) (appTimestamp uint))
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
        (asserts! (> biddingEndTime appTimestamp) bidding-endtime-error)

        (print "place-bid : sending this much to; ")
        (print bidAmount)
        (print (as-contract tx-sender))
        (print "place-bid : when")
        (print appTimestamp)
        (unwrap! (stx-transfer? bidAmount tx-sender (as-contract tx-sender)) failed-to-stx-transfer)
        (map-insert nft-bid-history {nft-index: nftIndex, bid-index: bidCounter} {bidder: tx-sender, amount: bidAmount, app-timestamp: appTimestamp, sale-cycle: saleCycle})
        (map-set nft-high-bid-counter {nft-index: nftIndex} {high-bid-counter: (+ bidCounter u1), sale-cycle: saleCycle})
        (print {evt: "opening-bid", nftIndex: nftIndex, txSender: tx-sender, appTimestamp: appTimestamp, amount: bidAmount})
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
(define-public (place-bid (nftIndex uint) (nextBidAmount uint) (appTimestamp uint))
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
            (owner (unwrap! (nft-get-owner? my-nft nftIndex) nft-not-owned-err))
        )

        ;; Check the user bid amount is the opening price OR the current bid plus increment
        (print "place-bid : assert there is an opening bid - otherwise client calls opening-bid")
        (print currentAmount)
        (asserts! (> currentAmount u0) user-amount-different)
        (asserts! (is-eq nextBidAmount (+ currentAmount increment)) user-amount-different)

        ;; if (appTimestamp > bidding-end-time) then this is either the winning or a too late bid on the NFT
        ;; a too late bid will have been rejected as the last bid resets the sale/bidding data on the item.
        ;; if its the last bid...
        ;;               1. Refund the currentBid to the bidder
        ;;               2. move currentBid to bid history
        ;;               3. Set the bid in nft-high-bid-counter - note 'set' so we overwrite the previous bid
        ;; (next-bid) we
        ;;               1. Refund the currentBid to the bidder
        ;;               2. Insert currentBid to bid history
        ;;               3. Set the bid in nft-high-bid-counter - note 'set' so we overwrite the previous bid

        (if (> appTimestamp bidding-end-time)
            (begin
                (print {evt: "place-bid-closure", nftIndex: nftIndex, appTimestamp: appTimestamp, biddingEndTime: bidding-end-time, amount: nextBidAmount, reserve: reserve})
                (unwrap! (refund-bid nftIndex currentBidder currentAmount) failed-to-stx-transfer)
                (if (< nextBidAmount reserve)
                    ;; if this bid is less than reserve & its the last bid then just refund previous bid
                    (unwrap! (ok true) failed-to-stx-transfer)
                    (begin
                        ;; WINNING BID - is the FIRST bid after bidding close.
                        (print "place-bid : Make the royalty payments")
                        (unwrap! (payment-split nftIndex nextBidAmount tx-sender) payment-error)
                        (unwrap! (record-bid nftIndex nextBidAmount currentBidIndex appTimestamp saleCycle) failed-to-stx-transfer)
                        (map-set nft-sale-data { nft-index: nftIndex } { sale-cycle-index: (+ saleCycle u1), sale-type: u0, increment-stx: u0, reserve-stx: u0, amount-stx: u0, bidding-end-time: u0})
                        (print "place-bid : Added internal transfer - transfering nft...")
                        ;; finally transfer ownership to the buyer (note: via the buyers transaction!)
                        (unwrap! (nft-transfer? my-nft nftIndex owner tx-sender) failed-to-stx-transfer)
                    )
                )
            )
            (begin
                (print {evt: "place-bid-refund", nftIndex: nftIndex, appTimestamp: appTimestamp, biddingEndTime: bidding-end-time, amount: nextBidAmount})
                (unwrap! (refund-bid nftIndex currentBidder currentAmount) failed-refund)
                (unwrap! (next-bid nftIndex nextBidAmount currentBidIndex appTimestamp saleCycle) failed-to-stx-transfer)
            )
        )
        ;;
        ;; NOTE: Above code will only reconcile IF a bid comes in after 'block-time'
        ;; We may need a manual trigger to end bidding when this doesn't happen - unless there is a
        ;; to repond to future events / timeouts that I dont know about.
        ;;
        (print {evt: "place-bid", nftIndex: nftIndex, txSender: tx-sender, appTimestamp: appTimestamp, amount: nextBidAmount})
        (ok true)
    )
)

;; Mint subsequent editions of the NFT
;; nft-index: the index of the original NFT in this series of editions.
;; The sale data must have been set on the asset before calling this.
;; The amount is split according to the royalties.
;; The nextBidAmount is passed to avoid concurrency issues - amount on the buy/bid button must
;; equal the amount expected by the contract.

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
        )
        (asserts! (or (is-eq closeType u1) (is-eq closeType u2)) failed-to-close-1)
        ;; only the owner or administrator can call close
        (asserts! (or (is-owner nftIndex tx-sender) (unwrap! (is-administrator) not-allowed)) not-allowed)
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
                    (unwrap! (payment-split nftIndex currentAmount (as-contract tx-sender)) payment-error)
                    (unwrap! (nft-transfer? my-nft nftIndex (unwrap! (nft-get-owner? my-nft nftIndex) nft-not-owned-err) tx-sender) transfer-error)
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

(define-read-only (get-base-token-uri)
    (var-get base-token-uri))

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

(define-read-only (get-offer-at-index (nftIndex uint) (offerIndex uint))
    (let
        (
            (the-offer (map-get? nft-offer-history {nft-index: nftIndex, offer-index: offerIndex}))
        )
        (ok the-offer)
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
            (the-base-token-uri  (var-get base-token-uri))
            (the-mint-counter  (var-get mint-counter))
            (the-platform-fee  (var-get platform-fee))
            (the-token-name  token-name)
            (the-token-symbol  token-symbol)
        )
        (ok (tuple  (administrator the-administrator)
                    (mintPrice the-mint-price)
                    (baseTokenUri the-base-token-uri)
                    (mintCounter the-mint-counter)
                    (platformFee the-platform-fee)
                    (tokenName the-token-name)
                    (tokenSymbol the-token-symbol)))
    )
)

(define-private (get-all-data (nftIndex uint))
    (let
        (
            (the-owner                  (unwrap-panic (nft-get-owner? my-nft nftIndex)))
            (the-token-info             (map-get? nft-data {nft-index: nftIndex}))
            (the-sale-data              (map-get? nft-sale-data {nft-index: nftIndex}))
            (the-beneficiary-data       (map-get? nft-beneficiaries {nft-index: nftIndex}))
            (the-edition-counter        (default-to u0 (get edition-counter (map-get? nft-edition-counter {nft-index: nftIndex}))))
            (the-offer-counter          (default-to u0 (get offer-counter (map-get? nft-offer-counter {nft-index: nftIndex}))))
            (the-high-bid-counter       (default-to u0 (get high-bid-counter (map-get? nft-high-bid-counter {nft-index: nftIndex}))))
        )
        (ok (tuple  (offerCounter the-offer-counter)
                    (bidCounter the-high-bid-counter)
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
;; ---------------
(define-private (refund-bid (nftIndex uint) (currentBidder principal) (currentAmount uint))
    (begin
        (unwrap! (as-contract (stx-transfer? currentAmount tx-sender currentBidder)) failed-to-stx-transfer)
        (print {evt: "refund-bid", nftIndex: nftIndex, txSender: tx-sender, currentBidder: currentBidder, currentAmount: currentAmount})
        (ok true)
    )
)

;; need to account for reserve-stx
(define-private (record-bid (nftIndex uint) (bidAmount uint) (bidCounter uint) (appTimestamp uint) (saleCycle uint))
    (begin
        ;; see place-bid for the payment - no need for this (unwrap! (stx-transfer? bidAmount tx-sender (as-contract tx-sender)) failed-to-stx-transfer)
        (map-insert nft-bid-history {nft-index: nftIndex, bid-index: bidCounter} {bidder: tx-sender, amount: bidAmount, app-timestamp: appTimestamp, sale-cycle: saleCycle})
        (map-set nft-high-bid-counter {nft-index: nftIndex} {high-bid-counter: (+ bidCounter u1), sale-cycle: saleCycle})
        (print {evt: "record-bid", nftIndex: nftIndex, txSender: tx-sender, bidAmount: bidAmount, bidCounter: bidCounter, appTimestamp: appTimestamp, saleCycle: saleCycle})
        (ok true)
    )
)

(define-private (next-bid (nftIndex uint) (bidAmount uint) (bidCounter uint) (appTimestamp uint) (saleCycle uint))
    (begin
        (unwrap! (stx-transfer? bidAmount tx-sender (as-contract tx-sender)) failed-to-stx-transfer)
        (map-insert nft-bid-history {nft-index: nftIndex, bid-index: bidCounter} {bidder: tx-sender, amount: bidAmount, app-timestamp: appTimestamp, sale-cycle: saleCycle})
        (map-set nft-high-bid-counter {nft-index: nftIndex} {high-bid-counter: (+ bidCounter u1), sale-cycle: saleCycle})
        (print {appTimestamp: appTimestamp, bidAmount: bidAmount, bidCounter: bidCounter, evt: "next-bid", nftIndex: nftIndex, saleCycle: saleCycle, txSender: tx-sender})
        (ok true)
    )
)

;; sends payments to each recipient listed in the royalties
;; Note this is called by mint-edition where thee nftIndex actuallt referes to the series orginal and is where the royalties are stored.
(define-private (payment-split (nftIndex uint) (saleAmount uint) (payer principal))
    (let
        (
            (addresses (unwrap! (get addresses (map-get? nft-beneficiaries {nft-index: nftIndex})) failed-to-mint-err))
            (shares (unwrap! (get shares (map-get? nft-beneficiaries {nft-index: nftIndex})) failed-to-mint-err))
            (saleCycle (unwrap! (get sale-cycle-index (map-get? nft-sale-data {nft-index: nftIndex})) amount-not-set))
            (split u0)
            ;; If secondary sale (sale-cycle > 1) - the seller gets half the sale value and each royalty payment is half the original amount
            (scalor (if (> (unwrap! (get sale-cycle-index (map-get? nft-sale-data {nft-index: nftIndex})) amount-not-set) u1)
                percentage-on-secondary  u1))
        )
        (if (is-eq scalor percentage-on-secondary)
            ;; If secondary sale - pay the seller then split the royalties
            (unwrap! (stx-transfer? (/ (* saleAmount (- u100 percentage-on-secondary)) u100) payer (unwrap! (nft-get-owner? my-nft nftIndex) payment-share-error)) transfer-error)
            ;; Primary sale - split the royalties
            true
        )
        (+ split (unwrap! (pay-royalty scalor payer saleAmount (unwrap! (element-at addresses u0) payment-address-error) (unwrap! (element-at shares u0) payment-share-error)) payment-share-error))
        (+ split (unwrap! (pay-royalty scalor payer saleAmount (unwrap! (element-at addresses u1) payment-address-error) (unwrap! (element-at shares u1) payment-share-error)) payment-share-error))
        (+ split (unwrap! (pay-royalty scalor payer saleAmount (unwrap! (element-at addresses u2) payment-address-error) (unwrap! (element-at shares u2) payment-share-error)) payment-share-error))
        (+ split (unwrap! (pay-royalty scalor payer saleAmount (unwrap! (element-at addresses u3) payment-address-error) (unwrap! (element-at shares u3) payment-share-error)) payment-share-error))
        (+ split (unwrap! (pay-royalty scalor payer saleAmount (unwrap! (element-at addresses u4) payment-address-error) (unwrap! (element-at shares u4) payment-share-error)) payment-share-error))
        (+ split (unwrap! (pay-royalty scalor payer saleAmount (unwrap! (element-at addresses u5) payment-address-error) (unwrap! (element-at shares u5) payment-share-error)) payment-share-error))
        (+ split (unwrap! (pay-royalty scalor payer saleAmount (unwrap! (element-at addresses u6) payment-address-error) (unwrap! (element-at shares u6) payment-share-error)) payment-share-error))
        (+ split (unwrap! (pay-royalty scalor payer saleAmount (unwrap! (element-at addresses u7) payment-address-error) (unwrap! (element-at shares u7) payment-share-error)) payment-share-error))
        (+ split (unwrap! (pay-royalty scalor payer saleAmount (unwrap! (element-at addresses u8) payment-address-error) (unwrap! (element-at shares u8) payment-share-error)) payment-share-error))
        (+ split (unwrap! (pay-royalty scalor payer saleAmount (unwrap! (element-at addresses u9) payment-address-error) (unwrap! (element-at shares u9) payment-share-error)) payment-share-error))
        (print {evt: "payment-split", nftIndex: nftIndex, scalor: scalor, payer: payer, saleAmount: saleAmount, seller: (/ (* saleAmount (- u100 percentage-on-secondary)) u100), txSender: tx-sender})
        (ok split)
    )
)

;; unit of saleAmount is in Satoshi and the share variable is a percentage (ex for 5% it will be equal to 5)
;; also the scalor is 1 on first purchase - direct from artist and 2 for secondary sales - so the seller gets half the
;; sale value and each royalty address gets half their original amount.
(define-private (pay-royalty (scalor uint) (payer principal) (saleAmount uint) (payee principal) (share uint))
    (begin
        (if (> share u0)
            (let
                (
                    (split (/ (* saleAmount (/ share scalor)) percentage-with-twodp))
                )
                ;; ignore royalty payment if its to the buyer / tx-sender.
                (if (not (is-eq tx-sender payee))
                    (unwrap! (stx-transfer? split payer payee) transfer-error)
                    (unwrap! (ok true) transfer-error)
                )
                (print {evt: "pay-royalty-primary", payee: payee, payer: payer, saleAmount: saleAmount, scalor: scalor, share: share, split: split, txSender: tx-sender})
                (ok split)
            )
            (ok u0)
        )
    )
)
