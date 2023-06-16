;; Partage-v1.1 is an update of partage-v1.
;; It contains functions to mint, burn, transfer, fractionalize NFTs,
;; list/unlist fractions for sale, buy, transfer and burn fractions.

;; At fractionalization the original NFT is locked in the contract. 
;; The fractions of NFT are SFTs (= FT linked to an NFT ID). 
;; The original NFT can't be redeemed from the escrow account, 
;; unless by someone owning 100% of the fractions and burning them. 

;; The buy function spreads payment between three beneficiaries: 
;; the utility provider, the listing maker, and the platform fees.

;; Author Julien Carbonnell for Partage <|> 
;; Twitter: @jcarbonnell @partage_btc 

;; explicitly assert conformity with depending traits.
(impl-trait .sft-trait.sft-trait)
(use-trait ft-trait .ft-trait.ft-trait)
(use-trait nft-trait .nft-trait.nft-trait)

;; constants
(define-constant contract-owner tx-sender)
;; nft errors
(define-constant err-recipient-only (err u100))
(define-constant err-owner-only (err u101))
(define-constant err-unallowed-recipient (err u102))
(define-constant err-insufficient-balance (err u103))
(define-constant err-invalid-supply-value (err u104))
(define-constant err-invalid-nft-id (err u105))
;; marketplace errors
(define-constant err-unknown-listing (err u200))
(define-constant err-price-zero (err u201))
(define-constant err-nft-asset-mismatch (err u202))
(define-constant err-asset-contract-not-whitelisted (err u203))
(define-constant err-asset-expired (err u204))
(define-constant err-maker-taker-equal (err u206))
(define-constant err-unintended-taker (err u207))
(define-constant err-listing-expired (err u208))

;; data structure
(define-fungible-token fractions)
(define-non-fungible-token pNFT uint)
;; data storage
(define-map balances {id: uint, owner: principal} uint)
(define-map supplies uint uint)
(define-map uris uint (string-ascii 256))
(define-map listings uint
    {
      token-id: uint,
      maker: principal,
      amount: uint,
      unit-price: uint,
		  expiry: uint,
      taker: (optional principal)})
;; data vars
;; principal variable to pay the utility provider
(define-data-var utility-provider principal 'SPB52MT44QE7WZMNCE9200AY7WBVDJH3726JD3H5)
;; principal variable to pay the platform fees
(define-data-var platform-fees principal 'SP3Y7N3BH2XTCC7NEM6ZRFF356PTXRWJB6GNYQQ21)
;; counter variable to increment new id each time an nft is minted 
(define-data-var last-nft-id uint u0)
;; counter variable to increment new id each time fractions are listed for sale
(define-data-var listing-nonce uint u1)

;; wrap the built-in nft-get-owner? function
(define-read-only (get-owner (id uint)) 
    (ok (nft-get-owner? pNFT id)))
;; track the last token ID
(define-read-only (get-last-nft-id) 
    (ok (var-get last-nft-id)))
;; get the link to the metadata of a given nft
(define-read-only (get-token-uri (id uint)) 
  (ok (default-to none (some (map-get? uris id)))))
;; what's the current utility-provider address? 
(define-read-only (get-utility-provider)
  (ok (var-get utility-provider)))
;; what's the current platform-fees address? 
(define-read-only (get-platform-fees)
  (ok (var-get platform-fees)))
;; get decimals
(define-read-only (get-decimals (id uint)) 
  (ok u0))
;; how many fractions of a given nft are owned by this wallet?
(define-read-only (get-balance (id uint) (who principal))
  (ok (default-to u0 (map-get? balances {id: id, owner: who}))))
;; how many fractions does this wallet own overall?
(define-read-only (get-overall-balance (who principal))
  (ok (ft-get-balance fractions who)))
;; how many fractions are supplied on the market overall?
(define-read-only (get-overall-supply) 
  (ok (ft-get-supply fractions)))
;; how many fractions of a given nft are supplied on the market?
(define-read-only (get-total-supply (id uint)) 
  (ok (default-to u0 (map-get? supplies id))))
;; returns a listing content
(define-read-only (get-listing (listing-id uint))
	(map-get? listings listing-id))
;; track the last listing ID
(define-read-only (get-listing-nonce) 
    (ok (var-get listing-nonce)))

;; public functions
;; nft-related functions
;; mint an nft (nft recipient only)
(define-public (mint-nft (recipient principal) (uri (string-ascii 256)))
    (let 
        (
          (id (+ (var-get last-nft-id) u1))
        )
        (asserts! (is-eq tx-sender recipient) err-recipient-only)
        (try! (nft-mint? pNFT id recipient))
        ;; a uri is attached to each nft id
        (map-set uris id uri)
        (print 
          {
            type: "nft_mint", 
            token-id: id, 
            recipient: recipient,
          }
        )
        (var-set last-nft-id id)
        (ok id)))

;; burn an nft (nft owner only) (assume nft isn't fractionalized)
(define-public (burn-nft (id uint) (recipient principal)) 
    (begin
        (asserts! (is-eq tx-sender recipient) err-owner-only)
        (asserts! (is-eq (unwrap-panic (get-total-supply id)) u0) err-invalid-supply-value)
        (try! (nft-burn? pNFT id recipient))
        (print
          {
            type: "burn-nft",
            token-id: id,
            sender: recipient
          }
        )
        (ok true)))

;; transfer an nft (assert that sender == contract owner)
(define-public (transfer-nft (id uint) (sender principal) (recipient principal)) 
    (begin
        (asserts! (is-eq tx-sender sender) err-owner-only)
        (nft-transfer? pNFT id sender recipient)))

;; fractionalize an nft into fractions and locks nft in an escrow account (nft owner and recipient only)
(define-public (fractionalize-nft (id uint) (recipient principal) (supply uint))
  (let 
    (
      (owner (unwrap! (nft-get-owner? pNFT id) err-invalid-nft-id))
    )
    (asserts! (is-eq tx-sender recipient) err-recipient-only)
    (asserts! (is-eq tx-sender owner) err-owner-only)
    (asserts! (> supply u0) err-invalid-supply-value)
    ;; create fractions
    (try! (ft-mint? fractions supply recipient))
    ;; lock the nft in an escrow account on the contract
    (try! (nft-transfer? pNFT id recipient (as-contract tx-sender)))
    (map-set supplies id supply)
    (map-set balances { id: id, owner: recipient } supply)
    (print 
      {type: "fractionalize_nft",
       token-id: id,
       amount: supply,
       recipient: recipient})
    (ok true)))

;; transfer fractions of a specific nft from one wallet to another
(define-public (transfer (id uint) (amount uint) (sender principal) (recipient principal))
  (let 
    (
      (senderBalance (unwrap-panic (get-balance id sender)))
      (recipientBalance (unwrap-panic (get-balance id recipient)))
    )
    (asserts! (is-eq tx-sender sender) err-owner-only)
    (asserts! (not (is-eq sender recipient)) err-unallowed-recipient)
    (asserts! (<= amount senderBalance) err-insufficient-balance)
    (try! (ft-transfer? fractions amount sender recipient))
    (map-set balances { id: id, owner: sender } (- senderBalance amount))
    (map-set balances { id: id, owner: recipient } (+ recipientBalance amount))
    (print 
      {type: "fraction_transfer",
       token-id: id,
       amount: amount,
       sender: sender,
       recipient: recipient})
    (ok true)))
;; same with memo
(define-public (transfer-memo (id uint) (amount uint) (sender principal) (recipient principal) (memo (buff 34)))
  (begin
    (try! (transfer id amount sender recipient))
    (print memo)
    (ok true)))

;; burn the fraction of an nft (assume the caller has 100% fractions)
(define-public (burn-fractions (id uint) (recipient principal)) 
  (let 
    (
      (balance (unwrap-panic (get-balance id recipient)))
      (supply (unwrap-panic (get-total-supply id)))
    )
    (asserts! (is-eq tx-sender recipient) err-recipient-only)
    (asserts! (is-eq balance supply) err-insufficient-balance)
    (as-contract (try! (nft-transfer? pNFT id tx-sender recipient)))
    (try! (ft-burn? fractions balance recipient))
    (map-delete balances { id: id, owner: recipient })
    (map-delete supplies id)
    (print 
      {
        type: "fraction_burn",
        token-id: id,
        amount: balance,
        sender: recipient
      }
    )
    (ok true)))


;; marketplace-related functions
;; change default utility-provider address (contract owner only)
(define-public (set-utility-provider (address principal))
  (begin
      (asserts! (is-eq tx-sender contract-owner) err-owner-only)
      (var-set utility-provider address)
      (ok true)
    ))

;; change default platform-fees address (contract owner only)
(define-public (set-platform-fees (address principal))
  (begin
      (asserts! (is-eq tx-sender contract-owner) err-owner-only)
      (var-set platform-fees address)
      (ok true)
    ))

;; transfer-stx
(define-public (transfer-stx (amount uint) (sender principal) (recipient principal))
  (begin 
    (asserts! (is-eq tx-sender sender) err-owner-only)
    (try! (stx-transfer? amount sender recipient))
    (print
          {
            type: "stx-transfer",
            amount: amount,
            sender: sender,
            recipient: recipient
          }
        )
        (ok true)
  )
)

;; list full nft for sale (nft owner only, assume nft isn't fractionalized)
(define-public (list-nft (listing {token-id: uint, unit-price: uint, expiry: uint, taker: (optional principal)}))
    (let 
    (
      (listing-id (var-get listing-nonce))
    )
    (asserts! (is-eq (unwrap-panic (get-total-supply (get token-id listing))) u0) err-invalid-supply-value)
		(asserts! (> (get expiry listing) block-height) err-asset-expired)
		(asserts! (> (get unit-price listing) u0) err-price-zero)
    (try! (transfer-nft (get token-id listing) tx-sender (as-contract tx-sender)))
    (map-set listings listing-id (merge {amount: u0, maker: tx-sender} listing))
		(var-set listing-nonce (+ listing-id u1))
		(ok listing-id)))

;; cancel the listing of an nft
(define-public (unlist-nft (listing-id uint))
	(let (
		  (listing (unwrap! (map-get? listings listing-id) err-unknown-listing))
		  (maker (get maker listing))
		)
		(asserts! (is-eq maker tx-sender) err-owner-only)
		(map-delete listings listing-id)
		(as-contract (transfer-nft (get token-id listing) tx-sender maker))))

;; list fractions for sale (nft owner only, limited to fraction balance in wallet)
(define-public (list-fractions (listing {token-id: uint, amount: uint, unit-price: uint, expiry: uint, taker: (optional principal)}))
    (let 
    (
      (listing-id (var-get listing-nonce))
    )
		(asserts! (> (get expiry listing) block-height) err-asset-expired)
		(asserts! (> (get unit-price listing) u0) err-price-zero)
    (try! (transfer (get token-id listing) (get amount listing) tx-sender (as-contract tx-sender)))
    (map-set listings listing-id (merge {maker: tx-sender} listing))
		(var-set listing-nonce (+ listing-id u1))
		(ok listing-id)))

;; cancel the listing of an amount of fractions (owner only)
(define-public (unlist-fractions (listing-id uint) (amount uint))
	(let (
		  (listing (unwrap! (map-get? listings listing-id) err-unknown-listing))
		  (maker (get maker listing))
		)
		(asserts! (is-eq maker tx-sender) err-owner-only)
		(map-delete listings listing-id)
		(as-contract (transfer (get token-id listing) (get amount listing) tx-sender maker))))

;; buy nft on sale
(define-public (buy-nft (listing-id uint))
    (let 
        (
		      (listing (unwrap! (map-get? listings listing-id) err-unknown-listing))
          (taker tx-sender)
          (price (get unit-price listing))
        )
        ;; check if all buying conditions are met
		    (asserts! (not (is-eq (get maker listing) taker)) err-maker-taker-equal)
		    (asserts! (match (get taker listing) intended-taker (is-eq intended-taker tx-sender) true) err-unintended-taker)
		    (asserts! (< block-height (get expiry listing)) err-listing-expired)
        ;; split the price over distinct beneficiaries: nft owner, platform fees.
		    (try! (transfer-stx (/ (* price u95) u100) taker (get maker listing)))
        (try! (transfer-stx (/ (* price u5) u100) taker (var-get platform-fees)))
		    (as-contract (try! (transfer-nft (get token-id listing) tx-sender taker)))
		    ;; delete the listing
		    (map-delete listings listing-id)
        ;; print a result to user
        (print 
          {
            type: "nft_sale",
            token-id: (get token-id listing),
            seller: (get maker listing),
            buyer: taker
          }
        )
        (ok true)))

;; buy fractions on sale
(define-public (buy-fractions (listing-id uint) (amount uint))
    (let 
        (
		      (listing (unwrap! (map-get? listings listing-id) err-unknown-listing))
          (taker tx-sender)
          (price (* amount (get unit-price listing)))
        )
        ;; check if all buying conditions are met
		    (asserts! (not (is-eq (get maker listing) taker)) err-maker-taker-equal)
		    (asserts! (match (get taker listing) intended-taker (is-eq intended-taker tx-sender) true) err-unintended-taker)
		    (asserts! (< block-height (get expiry listing)) err-listing-expired)
        ;; check enough money in the buyers wallet

        ;; split the price over distinct beneficiaries: utility provider, nft owner, platform fees.
		    (try! (transfer-stx (/ (* price u85) u100) taker (var-get utility-provider)))
		    (try! (transfer-stx (/ (* price u10) u100) taker (get maker listing)))
        (try! (transfer-stx (/ (* price u5) u100) taker (var-get platform-fees)))
		    (as-contract (try! (transfer (get token-id listing) amount tx-sender taker)))
		    ;; update the amount of fractions available in the listing
		    (map-set listings listing-id 
							{
								token-id: (get token-id listing), 
								amount: (- (get amount listing) amount), 
								unit-price: (get unit-price listing), 
								expiry: (get expiry listing), 
								taker: (get taker listing), 
								maker: (get maker listing)
							})
		    ;; if amount = 0 then (map-delete listings listing-id)
        (if true (is-eq (get amount listing) u0) (map-delete listings listing-id))
        ;; print a result to user
        (print 
          {
            type: "fraction_sale",
            token-id: (get token-id listing),
            amount: (get amount listing),
            seller: (get maker listing),
            buyer: taker
          }
        )
        (ok true)))