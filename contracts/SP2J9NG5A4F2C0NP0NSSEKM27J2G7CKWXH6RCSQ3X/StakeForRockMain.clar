(use-trait nft-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
(use-trait ft-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(define-constant Owner tx-sender)

(define-constant ERR_UNKNOWN_LISTING (err u2000))
(define-constant ERR_UNAUTHORISED (err u2001))
(define-constant ERR_ASSET_CONTRACT_NOT_WHITELISTED (err u2007))
(define-constant ERR_NFT_ASSET_MISMATCH (err u2003))
(define-data-var returnRate uint u10000)
(define-data-var contract-owner principal Owner)

;; Updated listings map without `payment-asset-contract`
(define-map listings
  uint
  {
    maker: principal,
    hi: uint,
    token-id: uint,
    nft-asset-contract: principal,
    staked-at: uint
  }
)

(define-map listing-by-nft (tuple (nft-asset-contract principal) (token-id uint)) uint)


(define-data-var listing-nonce uint u0)

(define-map whitelisted-asset-contracts principal bool)
(define-map nft-listing-counts principal uint)

(define-read-only (is-whitelisted (asset-contract principal))
  (default-to false (map-get? whitelisted-asset-contracts asset-contract))
)

(define-read-only (get-listing-count (nft-asset-contract principal))
  (default-to u0 (map-get? nft-listing-counts nft-asset-contract))
)

;;Using contract-caller for safety S/O Ghislo
(define-public (set-whitelisted (asset-contract principal) (whitelisted bool))
  (begin
    (asserts! (is-eq (var-get contract-owner) contract-caller) ERR_UNAUTHORISED)
    (ok (map-set whitelisted-asset-contracts asset-contract whitelisted))
  )
)

(define-public (set-owner (newOwner principal))
  (begin
    (asserts! (is-eq (var-get contract-owner) contract-caller) ERR_UNAUTHORISED)
    (ok (var-set contract-owner newOwner))
  )
)

(define-public (set-rate (newRate uint))
  (begin
    (asserts! (is-eq (var-get contract-owner) contract-caller) ERR_UNAUTHORISED)
    (ok (var-set returnRate newRate))
  )
)

(define-private (transfer-nft
  (token-contract <nft-trait>)
  (token-id uint)
  (sender principal)
  (recipient principal)
)
  (contract-call? token-contract transfer token-id sender recipient)
)

(define-private (transfer-ft
  (token-contract <ft-trait>)
  (amount uint)
  (sender principal)
  (recipient principal)
)
  (contract-call? token-contract transfer amount sender recipient none)
)


(define-read-only (get-listing-by-nft (nft-asset-contract principal) (token-id uint))
  (map-get? listing-by-nft { nft-asset-contract: nft-asset-contract, token-id: token-id })
)

(define-read-only (get-listing (listing-id uint))
  (map-get? listings listing-id)
)

(define-read-only (get-listing-nonce)
  (var-get listing-nonce)
)

(define-public (stake
  (nft-asset-contract <nft-trait>)
  (token-id uint)
)
  (let (
    (listing-id (var-get listing-nonce))
    (sender tx-sender)
    
    )
    (asserts! (is-whitelisted (contract-of nft-asset-contract)) ERR_ASSET_CONTRACT_NOT_WHITELISTED)
    
    (try! (transfer-nft
      nft-asset-contract
      token-id
      tx-sender
      (as-contract tx-sender)
    ))
    
    (map-set listings listing-id {
      maker: tx-sender,
      hi: block-height,
      token-id: token-id,
      nft-asset-contract: (contract-of nft-asset-contract),
      staked-at: block-height
    })

    (map-set listing-by-nft 
      { nft-asset-contract: (contract-of nft-asset-contract), token-id: token-id } 
      listing-id
    )

    (let ((current-count (get-listing-count (contract-of nft-asset-contract))))
      (map-set nft-listing-counts (contract-of nft-asset-contract) (+ current-count u1))
    )

    (var-set listing-nonce (+ listing-id u1))

    ;; Mint a placeholder NFT for the staker
    (try! (as-contract (contract-call? 'SP2J9NG5A4F2C0NP0NSSEKM27J2G7CKWXH6RCSQ3X.Staking-NFTv1 mint sender)))

    (print {listing-id: listing-id, token-id: token-id, block-height: block-height, maker: tx-sender})
    (ok listing-id)
  )
)


(define-public (unstake (listing-id uint) (nft-asset-contract <nft-trait>))
  (let (
    (listing (unwrap! (map-get? listings listing-id) ERR_UNKNOWN_LISTING))
    (maker (get maker listing))
    (token-id (get token-id listing))
  )
    (asserts! (is-eq maker tx-sender) ERR_UNAUTHORISED)
    (asserts! (is-eq
      (get nft-asset-contract listing)
      (contract-of nft-asset-contract)
    ) ERR_NFT_ASSET_MISMATCH)
    
    (map-delete listings listing-id)

    (map-delete listing-by-nft 
      { nft-asset-contract: (contract-of nft-asset-contract), token-id: token-id }
    )

    (let ((current-count (get-listing-count (contract-of nft-asset-contract))))
      (map-set nft-listing-counts (contract-of nft-asset-contract) (if (> current-count u0) (- current-count u1) u0))
    )

    ;; Transfer the staked NFT back to the staker
    (try! (as-contract (contract-call? nft-asset-contract transfer token-id (as-contract tx-sender) maker)))

    ;; Burn the placeholder NFT
    (try! (as-contract (contract-call? 'SP2J9NG5A4F2C0NP0NSSEKM27J2G7CKWXH6RCSQ3X.Staking-NFTv1 burn (+ listing-id u1) maker)))

    (print {listing-id: listing-id, token-id: token-id, maker: maker, block-height: block-height})
    (ok listing-id)
  )
)

(define-read-only (checkClaim-with-tokenID (nft-asset-contract <nft-trait>) (token-id uint))
  (let (
    ;; Retrieve the listing-id from the listing-by-nft map using the token-id and nft-asset-contract
    (listing-id (unwrap! (map-get? listing-by-nft { nft-asset-contract: (contract-of nft-asset-contract), token-id: token-id }) ERR_UNKNOWN_LISTING))
  )
    ;; Call the existing claim function using the retrieved listing-id
    (checkClaim listing-id)
  )
)

(define-read-only (checkClaim (listing-id uint))
  (let (
    (listing (unwrap! (map-get? listings listing-id) ERR_UNKNOWN_LISTING))
    (maker (get maker listing))
    (height (get hi listing))
    (rock-height (- block-height height))
    (return (* rock-height u10000))
  )
    (print {listing-id: listing-id, maker: maker, block-height: block-height})
    (ok return)
  )
)

(define-public (claim (listing-id uint))
  (let (
    (listing (unwrap! (map-get? listings listing-id) ERR_UNKNOWN_LISTING))
    (maker (get maker listing))
    (height (get hi listing))
    (rock-height (- block-height height))
  )
    (asserts! (is-eq maker tx-sender) ERR_UNAUTHORISED)
    
    ;; Transfer the reward tokens to the maker (tx-sender)
    (try! (as-contract (contract-call? 'SP4M2C88EE8RQZPYTC4PZ88CE16YGP825EYF6KBQ.stacks-rock transfer (* rock-height (var-get returnRate)) tx-sender maker none)))
    
    ;; Reset the `hi` of the listing to the current block-height
    (map-set listings listing-id (merge listing { hi: block-height }))
    
    (print {listing-id: listing-id, maker: maker, block-height: block-height})
    (ok listing-id)
  )
)

(define-public (unstake-with-tokenID (nft-asset-contract <nft-trait>) (token-id uint))
  (let (
    ;; Retrieve the listing-id from the listing-by-nft map using the token-id and nft-asset-contract
    (listing-id (unwrap! (map-get? listing-by-nft { nft-asset-contract: (contract-of nft-asset-contract), token-id: token-id }) ERR_UNKNOWN_LISTING))
  )
    ;; Call the existing unstake function using the retrieved listing-id
    (unstake listing-id nft-asset-contract)
  )
)

(define-public (claim-with-tokenID (nft-asset-contract <nft-trait>) (token-id uint))
  (let (
    ;; Retrieve the listing-id from the listing-by-nft map using the token-id and nft-asset-contract
    (listing-id (unwrap! (map-get? listing-by-nft { nft-asset-contract: (contract-of nft-asset-contract), token-id: token-id }) ERR_UNKNOWN_LISTING))
  )
    ;; Call the existing claim function using the retrieved listing-id
    (claim listing-id)
  )
)

(define-public (unstake-all (nft-asset-contract <nft-trait>) (nfts (list 24 uint)))
  (let
    (
      ;; Extract NFTs from the list, ensuring safe unwrapping
      (nft-1 (element-at nfts u0))  (nft-2 (element-at nfts u1))  (nft-3 (element-at nfts u2))  (nft-4 (element-at nfts u3))
      (nft-5 (element-at nfts u4))  (nft-6 (element-at nfts u5))  (nft-7 (element-at nfts u6))  (nft-8 (element-at nfts u7))
      (nft-9 (element-at nfts u8))  (nft-10 (element-at nfts u9)) (nft-11 (element-at nfts u10)) (nft-12 (element-at nfts u11))
      (nft-13 (element-at nfts u12)) (nft-14 (element-at nfts u13)) (nft-15 (element-at nfts u14)) (nft-16 (element-at nfts u15))
      (nft-17 (element-at nfts u16)) (nft-18 (element-at nfts u17)) (nft-19 (element-at nfts u18)) (nft-20 (element-at nfts u19))
      (nft-21 (element-at nfts u20)) (nft-22 (element-at nfts u21)) (nft-23 (element-at nfts u22)) (nft-24 (element-at nfts u23))

      ;; Apply the unstaking logic for each NFT, only unstaking if the NFT exists. S/O CP
      (unstake-1 (if (is-some nft-1) (some (unstake-with-tokenID nft-asset-contract (unwrap! nft-1 ERR_UNAUTHORISED))) none))
      (unstake-2 (if (is-some nft-2) (some (unstake-with-tokenID nft-asset-contract (unwrap! nft-2 ERR_UNAUTHORISED))) none))
      (unstake-3 (if (is-some nft-3) (some (unstake-with-tokenID nft-asset-contract (unwrap! nft-3 ERR_UNAUTHORISED))) none))
      (unstake-4 (if (is-some nft-4) (some (unstake-with-tokenID nft-asset-contract (unwrap! nft-4 ERR_UNAUTHORISED))) none))
      (unstake-5 (if (is-some nft-5) (some (unstake-with-tokenID nft-asset-contract (unwrap! nft-5 ERR_UNAUTHORISED))) none))
      (unstake-6 (if (is-some nft-6) (some (unstake-with-tokenID nft-asset-contract (unwrap! nft-6 ERR_UNAUTHORISED))) none))
      (unstake-7 (if (is-some nft-7) (some (unstake-with-tokenID nft-asset-contract (unwrap! nft-7 ERR_UNAUTHORISED))) none))
      (unstake-8 (if (is-some nft-8) (some (unstake-with-tokenID nft-asset-contract (unwrap! nft-8 ERR_UNAUTHORISED))) none))
      (unstake-9 (if (is-some nft-9) (some (unstake-with-tokenID nft-asset-contract (unwrap! nft-9 ERR_UNAUTHORISED))) none))
      (unstake-10 (if (is-some nft-10) (some (unstake-with-tokenID nft-asset-contract (unwrap! nft-10 ERR_UNAUTHORISED))) none))
      (unstake-11 (if (is-some nft-11) (some (unstake-with-tokenID nft-asset-contract (unwrap! nft-11 ERR_UNAUTHORISED))) none))
      (unstake-12 (if (is-some nft-12) (some (unstake-with-tokenID nft-asset-contract (unwrap! nft-12 ERR_UNAUTHORISED))) none))
      (unstake-13 (if (is-some nft-13) (some (unstake-with-tokenID nft-asset-contract (unwrap! nft-13 ERR_UNAUTHORISED))) none))
      (unstake-14 (if (is-some nft-14) (some (unstake-with-tokenID nft-asset-contract (unwrap! nft-14 ERR_UNAUTHORISED))) none))
      (unstake-15 (if (is-some nft-15) (some (unstake-with-tokenID nft-asset-contract (unwrap! nft-15 ERR_UNAUTHORISED))) none))
      (unstake-16 (if (is-some nft-16) (some (unstake-with-tokenID nft-asset-contract (unwrap! nft-16 ERR_UNAUTHORISED))) none))
      (unstake-17 (if (is-some nft-17) (some (unstake-with-tokenID nft-asset-contract (unwrap! nft-17 ERR_UNAUTHORISED))) none))
      (unstake-18 (if (is-some nft-18) (some (unstake-with-tokenID nft-asset-contract (unwrap! nft-18 ERR_UNAUTHORISED))) none))
      (unstake-19 (if (is-some nft-19) (some (unstake-with-tokenID nft-asset-contract (unwrap! nft-19 ERR_UNAUTHORISED))) none))
      (unstake-20 (if (is-some nft-20) (some (unstake-with-tokenID nft-asset-contract (unwrap! nft-20 ERR_UNAUTHORISED))) none))
      (unstake-21 (if (is-some nft-21) (some (unstake-with-tokenID nft-asset-contract (unwrap! nft-21 ERR_UNAUTHORISED))) none))
      (unstake-22 (if (is-some nft-22) (some (unstake-with-tokenID nft-asset-contract (unwrap! nft-22 ERR_UNAUTHORISED))) none))
      (unstake-23 (if (is-some nft-23) (some (unstake-with-tokenID nft-asset-contract (unwrap! nft-23 ERR_UNAUTHORISED))) none))
      (unstake-24 (if (is-some nft-24) (some (unstake-with-tokenID nft-asset-contract (unwrap! nft-24 ERR_UNAUTHORISED))) none))

      ;; Combine all unstake results into a list
      (unstake-results (list unstake-1 unstake-2 unstake-3 unstake-4 unstake-5 unstake-6 unstake-7 unstake-8 unstake-9 unstake-10
                            unstake-11 unstake-12 unstake-13 unstake-14 unstake-15 unstake-16 unstake-17 unstake-18 unstake-19 
                            unstake-20 unstake-21 unstake-22 unstake-23 unstake-24))
    )
    ;; Return the list of results from each unstake operation
    (ok unstake-results)
  )
)


(define-public (stake-all (nft-asset-contract <nft-trait>) (nfts (list 24 uint)))
  (let 
    (
      ;; Extract NFTs from the list, ensuring safe unwrapping
      (nft-1 (element-at nfts u0))  (nft-2 (element-at nfts u1))  (nft-3 (element-at nfts u2))  (nft-4 (element-at nfts u3))
      (nft-5 (element-at nfts u4))  (nft-6 (element-at nfts u5))  (nft-7 (element-at nfts u6))  (nft-8 (element-at nfts u7))
      (nft-9 (element-at nfts u8))  (nft-10 (element-at nfts u9)) (nft-11 (element-at nfts u10)) (nft-12 (element-at nfts u11))
      (nft-13 (element-at nfts u12)) (nft-14 (element-at nfts u13)) (nft-15 (element-at nfts u14)) (nft-16 (element-at nfts u15))
      (nft-17 (element-at nfts u16)) (nft-18 (element-at nfts u17)) (nft-19 (element-at nfts u18)) (nft-20 (element-at nfts u19))
      (nft-21 (element-at nfts u20)) (nft-22 (element-at nfts u21)) (nft-23 (element-at nfts u22)) (nft-24 (element-at nfts u23))

      ;; Apply the staking logic for each NFT, only staking if the NFT exists
      (stake-1 (if (is-some nft-1) (some (stake nft-asset-contract (unwrap! nft-1 ERR_UNAUTHORISED))) none))
      (stake-2 (if (is-some nft-2) (some (stake nft-asset-contract (unwrap! nft-2 ERR_UNAUTHORISED))) none))
      (stake-3 (if (is-some nft-3) (some (stake nft-asset-contract (unwrap! nft-3 ERR_UNAUTHORISED))) none))
      (stake-4 (if (is-some nft-4) (some (stake nft-asset-contract (unwrap! nft-4 ERR_UNAUTHORISED))) none))
      (stake-5 (if (is-some nft-5) (some (stake nft-asset-contract (unwrap! nft-5 ERR_UNAUTHORISED))) none))
      (stake-6 (if (is-some nft-6) (some (stake nft-asset-contract (unwrap! nft-6 ERR_UNAUTHORISED))) none))
      (stake-7 (if (is-some nft-7) (some (stake nft-asset-contract (unwrap! nft-7 ERR_UNAUTHORISED))) none))
      (stake-8 (if (is-some nft-8) (some (stake nft-asset-contract (unwrap! nft-8 ERR_UNAUTHORISED))) none))
      (stake-9 (if (is-some nft-9) (some (stake nft-asset-contract (unwrap! nft-9 ERR_UNAUTHORISED))) none))
      (stake-10 (if (is-some nft-10) (some (stake nft-asset-contract (unwrap! nft-10 ERR_UNAUTHORISED))) none))
      (stake-11 (if (is-some nft-11) (some (stake nft-asset-contract (unwrap! nft-11 ERR_UNAUTHORISED))) none))
      (stake-12 (if (is-some nft-12) (some (stake nft-asset-contract (unwrap! nft-12 ERR_UNAUTHORISED))) none))
      (stake-13 (if (is-some nft-13) (some (stake nft-asset-contract (unwrap! nft-13 ERR_UNAUTHORISED))) none))
      (stake-14 (if (is-some nft-14) (some (stake nft-asset-contract (unwrap! nft-14 ERR_UNAUTHORISED))) none))
      (stake-15 (if (is-some nft-15) (some (stake nft-asset-contract (unwrap! nft-15 ERR_UNAUTHORISED))) none))
      (stake-16 (if (is-some nft-16) (some (stake nft-asset-contract (unwrap! nft-16 ERR_UNAUTHORISED))) none))
      (stake-17 (if (is-some nft-17) (some (stake nft-asset-contract (unwrap! nft-17 ERR_UNAUTHORISED))) none))
      (stake-18 (if (is-some nft-18) (some (stake nft-asset-contract (unwrap! nft-18 ERR_UNAUTHORISED))) none))
      (stake-19 (if (is-some nft-19) (some (stake nft-asset-contract (unwrap! nft-19 ERR_UNAUTHORISED))) none))
      (stake-20 (if (is-some nft-20) (some (stake nft-asset-contract (unwrap! nft-20 ERR_UNAUTHORISED))) none))
      (stake-21 (if (is-some nft-21) (some (stake nft-asset-contract (unwrap! nft-21 ERR_UNAUTHORISED))) none))
      (stake-22 (if (is-some nft-22) (some (stake nft-asset-contract (unwrap! nft-22 ERR_UNAUTHORISED))) none))
      (stake-23 (if (is-some nft-23) (some (stake nft-asset-contract (unwrap! nft-23 ERR_UNAUTHORISED))) none))
      (stake-24 (if (is-some nft-24) (some (stake nft-asset-contract (unwrap! nft-24 ERR_UNAUTHORISED))) none))

      ;; Combine all stake results into a list
      (stake-results (list stake-1 stake-2 stake-3 stake-4 stake-5 stake-6 stake-7 stake-8 stake-9 stake-10
                           stake-11 stake-12 stake-13 stake-14 stake-15 stake-16 stake-17 stake-18 stake-19 
                           stake-20 stake-21 stake-22 stake-23 stake-24))
    )
    ;; Return the list of results from each stake operation
    (ok stake-results)
  )
)



(define-public (claim-all (nft-asset-contract <nft-trait>) (nfts (list 24 uint)))
  (let 
    (
      ;; Extract NFTs from the list, ensuring safe unwrapping
      (nft-1 (element-at nfts u0))  (nft-2 (element-at nfts u1))  (nft-3 (element-at nfts u2))  (nft-4 (element-at nfts u3))
      (nft-5 (element-at nfts u4))  (nft-6 (element-at nfts u5))  (nft-7 (element-at nfts u6))  (nft-8 (element-at nfts u7))
      (nft-9 (element-at nfts u8))  (nft-10 (element-at nfts u9)) (nft-11 (element-at nfts u10)) (nft-12 (element-at nfts u11))
      (nft-13 (element-at nfts u12)) (nft-14 (element-at nfts u13)) (nft-15 (element-at nfts u14)) (nft-16 (element-at nfts u15))
      (nft-17 (element-at nfts u16)) (nft-18 (element-at nfts u17)) (nft-19 (element-at nfts u18)) (nft-20 (element-at nfts u19))
      (nft-21 (element-at nfts u20)) (nft-22 (element-at nfts u21)) (nft-23 (element-at nfts u22)) (nft-24 (element-at nfts u23))

      ;; Apply the claim logic for each NFT, only claiming if the NFT exists
      (claim-1 (if (is-some nft-1) (some (claim-with-tokenID nft-asset-contract (unwrap! nft-1 ERR_UNAUTHORISED))) none))
      (claim-2 (if (is-some nft-2) (some (claim-with-tokenID nft-asset-contract (unwrap! nft-2 ERR_UNAUTHORISED))) none))
      (claim-3 (if (is-some nft-3) (some (claim-with-tokenID nft-asset-contract (unwrap! nft-3 ERR_UNAUTHORISED))) none))
      (claim-4 (if (is-some nft-4) (some (claim-with-tokenID nft-asset-contract (unwrap! nft-4 ERR_UNAUTHORISED))) none))
      (claim-5 (if (is-some nft-5) (some (claim-with-tokenID nft-asset-contract (unwrap! nft-5 ERR_UNAUTHORISED))) none))
      (claim-6 (if (is-some nft-6) (some (claim-with-tokenID nft-asset-contract (unwrap! nft-6 ERR_UNAUTHORISED))) none))
      (claim-7 (if (is-some nft-7) (some (claim-with-tokenID nft-asset-contract (unwrap! nft-7 ERR_UNAUTHORISED))) none))
      (claim-8 (if (is-some nft-8) (some (claim-with-tokenID nft-asset-contract (unwrap! nft-8 ERR_UNAUTHORISED))) none))
      (claim-9 (if (is-some nft-9) (some (claim-with-tokenID nft-asset-contract (unwrap! nft-9 ERR_UNAUTHORISED))) none))
      (claim-10 (if (is-some nft-10) (some (claim-with-tokenID nft-asset-contract (unwrap! nft-10 ERR_UNAUTHORISED))) none))
      (claim-11 (if (is-some nft-11) (some (claim-with-tokenID nft-asset-contract (unwrap! nft-11 ERR_UNAUTHORISED))) none))
      (claim-12 (if (is-some nft-12) (some (claim-with-tokenID nft-asset-contract (unwrap! nft-12 ERR_UNAUTHORISED))) none))
      (claim-13 (if (is-some nft-13) (some (claim-with-tokenID nft-asset-contract (unwrap! nft-13 ERR_UNAUTHORISED))) none))
      (claim-14 (if (is-some nft-14) (some (claim-with-tokenID nft-asset-contract (unwrap! nft-14 ERR_UNAUTHORISED))) none))
      (claim-15 (if (is-some nft-15) (some (claim-with-tokenID nft-asset-contract (unwrap! nft-15 ERR_UNAUTHORISED))) none))
      (claim-16 (if (is-some nft-16) (some (claim-with-tokenID nft-asset-contract (unwrap! nft-16 ERR_UNAUTHORISED))) none))
      (claim-17 (if (is-some nft-17) (some (claim-with-tokenID nft-asset-contract (unwrap! nft-17 ERR_UNAUTHORISED))) none))
      (claim-18 (if (is-some nft-18) (some (claim-with-tokenID nft-asset-contract (unwrap! nft-18 ERR_UNAUTHORISED))) none))
      (claim-19 (if (is-some nft-19) (some (claim-with-tokenID nft-asset-contract (unwrap! nft-19 ERR_UNAUTHORISED))) none))
      (claim-20 (if (is-some nft-20) (some (claim-with-tokenID nft-asset-contract (unwrap! nft-20 ERR_UNAUTHORISED))) none))
      (claim-21 (if (is-some nft-21) (some (claim-with-tokenID nft-asset-contract (unwrap! nft-21 ERR_UNAUTHORISED))) none))
      (claim-22 (if (is-some nft-22) (some (claim-with-tokenID nft-asset-contract (unwrap! nft-22 ERR_UNAUTHORISED))) none))
      (claim-23 (if (is-some nft-23) (some (claim-with-tokenID nft-asset-contract (unwrap! nft-23 ERR_UNAUTHORISED))) none))
      (claim-24 (if (is-some nft-24) (some (claim-with-tokenID nft-asset-contract (unwrap! nft-24 ERR_UNAUTHORISED))) none))

      ;; Combine all claim results into a list
      (claim-results (list claim-1 claim-2 claim-3 claim-4 claim-5 claim-6 claim-7 claim-8 claim-9 claim-10
                           claim-11 claim-12 claim-13 claim-14 claim-15 claim-16 claim-17 claim-18 claim-19 
                           claim-20 claim-21 claim-22 claim-23 claim-24))
    )
    ;; Return the list of results from each claim operation
    (ok claim-results)
  )
)

(define-read-only (checkClaimAll (nft-asset-contract <nft-trait>) (nfts (list 24 uint)))
  (let
    (
      ;; Extract NFTs from the list, ensuring safe unwrapping
      (nft-1 (element-at nfts u0))  (nft-2 (element-at nfts u1))  (nft-3 (element-at nfts u2))  (nft-4 (element-at nfts u3))
      (nft-5 (element-at nfts u4))  (nft-6 (element-at nfts u5))  (nft-7 (element-at nfts u6))  (nft-8 (element-at nfts u7))
      (nft-9 (element-at nfts u8))  (nft-10 (element-at nfts u9)) (nft-11 (element-at nfts u10)) (nft-12 (element-at nfts u11))
      (nft-13 (element-at nfts u12)) (nft-14 (element-at nfts u13)) (nft-15 (element-at nfts u14)) (nft-16 (element-at nfts u15))
      (nft-17 (element-at nfts u16)) (nft-18 (element-at nfts u17)) (nft-19 (element-at nfts u18)) (nft-20 (element-at nfts u19))
      (nft-21 (element-at nfts u20)) (nft-22 (element-at nfts u21)) (nft-23 (element-at nfts u22)) (nft-24 (element-at nfts u23))

      ;; Apply the checkClaim logic for each NFT, only checking if the NFT exists
      (check-1 (if (is-some nft-1) (some (checkClaim-with-tokenID nft-asset-contract (unwrap! nft-1 ERR_UNAUTHORISED))) none))
      (check-2 (if (is-some nft-2) (some (checkClaim-with-tokenID nft-asset-contract (unwrap! nft-2 ERR_UNAUTHORISED))) none))
      (check-3 (if (is-some nft-3) (some (checkClaim-with-tokenID nft-asset-contract (unwrap! nft-3 ERR_UNAUTHORISED))) none))
      (check-4 (if (is-some nft-4) (some (checkClaim-with-tokenID nft-asset-contract (unwrap! nft-4 ERR_UNAUTHORISED))) none))
      (check-5 (if (is-some nft-5) (some (checkClaim-with-tokenID nft-asset-contract (unwrap! nft-5 ERR_UNAUTHORISED))) none))
      (check-6 (if (is-some nft-6) (some (checkClaim-with-tokenID nft-asset-contract (unwrap! nft-6 ERR_UNAUTHORISED))) none))
      (check-7 (if (is-some nft-7) (some (checkClaim-with-tokenID nft-asset-contract (unwrap! nft-7 ERR_UNAUTHORISED))) none))
      (check-8 (if (is-some nft-8) (some (checkClaim-with-tokenID nft-asset-contract (unwrap! nft-8 ERR_UNAUTHORISED))) none))
      (check-9 (if (is-some nft-9) (some (checkClaim-with-tokenID nft-asset-contract (unwrap! nft-9 ERR_UNAUTHORISED))) none))
      (check-10 (if (is-some nft-10) (some (checkClaim-with-tokenID nft-asset-contract (unwrap! nft-10 ERR_UNAUTHORISED))) none))
      (check-11 (if (is-some nft-11) (some (checkClaim-with-tokenID nft-asset-contract (unwrap! nft-11 ERR_UNAUTHORISED))) none))
      (check-12 (if (is-some nft-12) (some (checkClaim-with-tokenID nft-asset-contract (unwrap! nft-12 ERR_UNAUTHORISED))) none))
      (check-13 (if (is-some nft-13) (some (checkClaim-with-tokenID nft-asset-contract (unwrap! nft-13 ERR_UNAUTHORISED))) none))
      (check-14 (if (is-some nft-14) (some (checkClaim-with-tokenID nft-asset-contract (unwrap! nft-14 ERR_UNAUTHORISED))) none))
      (check-15 (if (is-some nft-15) (some (checkClaim-with-tokenID nft-asset-contract (unwrap! nft-15 ERR_UNAUTHORISED))) none))
      (check-16 (if (is-some nft-16) (some (checkClaim-with-tokenID nft-asset-contract (unwrap! nft-16 ERR_UNAUTHORISED))) none))
      (check-17 (if (is-some nft-17) (some (checkClaim-with-tokenID nft-asset-contract (unwrap! nft-17 ERR_UNAUTHORISED))) none))
      (check-18 (if (is-some nft-18) (some (checkClaim-with-tokenID nft-asset-contract (unwrap! nft-18 ERR_UNAUTHORISED))) none))
      (check-19 (if (is-some nft-19) (some (checkClaim-with-tokenID nft-asset-contract (unwrap! nft-19 ERR_UNAUTHORISED))) none))
      (check-20 (if (is-some nft-20) (some (checkClaim-with-tokenID nft-asset-contract (unwrap! nft-20 ERR_UNAUTHORISED))) none))
      (check-21 (if (is-some nft-21) (some (checkClaim-with-tokenID nft-asset-contract (unwrap! nft-21 ERR_UNAUTHORISED))) none))
      (check-22 (if (is-some nft-22) (some (checkClaim-with-tokenID nft-asset-contract (unwrap! nft-22 ERR_UNAUTHORISED))) none))
      (check-23 (if (is-some nft-23) (some (checkClaim-with-tokenID nft-asset-contract (unwrap! nft-23 ERR_UNAUTHORISED))) none))
      (check-24 (if (is-some nft-24) (some (checkClaim-with-tokenID nft-asset-contract (unwrap! nft-24 ERR_UNAUTHORISED))) none))

      ;; Combine all checkClaim results into a list
      (check-results (list check-1 check-2 check-3 check-4 check-5 check-6 check-7 check-8 check-9 check-10
                           check-11 check-12 check-13 check-14 check-15 check-16 check-17 check-18 check-19 
                           check-20 check-21 check-22 check-23 check-24))
    )
    ;; Return the list of results from each checkClaim operation
    (ok check-results)
  )
)