;; By Highroller.btc
;; StakeForRock allows you to stake whitelisted NFT collections' NFTs for ROCK!
;; When you unstake you also collect your deserved rewards.
;; However, if there aren't enough funds left for you to unstake, you can leave 
;; it in to accumulate for the future, or you can unstakeFree which 
;; erases your rewards, but returns your NFT.


(use-trait nft-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
(use-trait ft-trait  'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(define-data-var contract-owner principal 'SM37BZ7SKRTBAM95J54F4QDY83YX63DDFP4M6DTAP)


(define-constant ERR_UNKNOWN_LISTING (err u2000))
(define-constant ERR_UNAUTHORISED (err u2001))
(define-constant ERR_NFT_ASSET_MISMATCH (err u2003))
(define-constant ERR_ASSET_CONTRACT_NOT_WHITELISTED (err u2007))
(define-constant ERR_PAYMENT_CONTRACT_NOT_WHITELISTED (err u2008))
(define-constant hard-as-rock 'SP318K3PRSDM42P68CAK4WS8MB1TRXA1K00TMEF8B.hard-as-rock)
(define-map staked
  uint
  {
    maker: principal,
    hi: uint,
    token-id: uint,
    nft-asset-contract: principal,
    payment-asset-contract: (optional principal)
  }
)

(define-map heights { nftListing: uint } { bheight: uint })

(define-data-var listing-nonce uint u0)
(define-map totalStaked principal uint)

(define-map whitelisted-asset-contracts principal bool)

(define-read-only (is-whitelisted (asset-contract principal))
  (default-to false (map-get? whitelisted-asset-contracts asset-contract))
)

(define-public (set-whitelisted (asset-contract principal) (whitelisted bool))
  (begin
    (asserts! (is-eq (var-get contract-owner) tx-sender) ERR_UNAUTHORISED)
    (ok (map-set whitelisted-asset-contracts asset-contract whitelisted))
  )
)

(define-public (set-hardRock (whitelisted bool))
  (begin
    (ok (map-set whitelisted-asset-contracts hard-as-rock true))
  )
)

(define-read-only (get-count (who principal))
  (default-to u0 (map-get? totalStaked who))
)

;; Function to increment the count for the caller
(define-private (count-up)
  (ok (map-set totalStaked (as-contract tx-sender) (+ (get-count (as-contract tx-sender)) u1)))
)

(define-private (count-down)
  (ok (map-set totalStaked (as-contract tx-sender) (- (get-count (as-contract tx-sender)) u1)))
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

;; Stake NFTs and receive ROCK for your time staked
(define-public (stakeIt
  (nft-asset-contract <nft-trait>)
  (nft-asset {
    hi: uint,
    token-id: uint,
    payment-asset-contract: (optional principal)
  })
)
  (let ((listing-id (var-get listing-nonce)))
    (asserts! (is-whitelisted (contract-of nft-asset-contract)) ERR_ASSET_CONTRACT_NOT_WHITELISTED)
    (asserts! (match (get payment-asset-contract nft-asset)
      payment-asset
      (is-whitelisted payment-asset)
      true
    ) ERR_PAYMENT_CONTRACT_NOT_WHITELISTED)
    (try! (transfer-nft
      nft-asset-contract
      (get token-id nft-asset)
      tx-sender
      (as-contract tx-sender)
    ))
    (map-set staked listing-id (merge
      { maker: tx-sender, hi: block-height, nft-asset-contract: (contract-of nft-asset-contract) }
      nft-asset
    ))
    (map-set heights { nftListing: (var-get listing-nonce) } { bheight: block-height })
    (map-set totalStaked (as-contract tx-sender) (+ (get-count (as-contract tx-sender)) u1))
    (var-set listing-nonce (+ listing-id u1))
    (ok listing-id)
  )
)

(define-read-only (get-stake (listing-id uint))
  (map-get? staked listing-id)
)

;; Unstake NFTs and receive ROCK for your time
(define-public (unstake (listing-id uint) (nft-asset-contract <nft-trait>) (rock-token-contract <ft-trait>))
  (let (
    (listing (unwrap! (map-get? staked listing-id) ERR_UNKNOWN_LISTING))
    (maker (get maker listing))
    (height (get hi listing))
    (rock-height (- block-height height))
  )
  
    (asserts! (is-eq maker tx-sender) ERR_UNAUTHORISED)
    (asserts! (is-eq
      (get nft-asset-contract listing)
      (contract-of nft-asset-contract)
    ) ERR_NFT_ASSET_MISMATCH)
    
    ;; Delete the listing and transfer the NFT back to the maker
    (map-delete staked listing-id)
    (map-set totalStaked (as-contract tx-sender) (- (get-count (as-contract tx-sender)) u1))
    (try! (transfer-nft nft-asset-contract (get token-id listing) (as-contract tx-sender) maker))
    
    ;; Transfer exactly 1 rock (1e6 stacks-rock) to the maker (tx-sender)
    (try! (transfer-ft 'SP4M2C88EE8RQZPYTC4PZ88CE16YGP825EYF6KBQ.stacks-rock (* rock-height u10000) (as-contract tx-sender) tx-sender))
    
    (ok listing-id)
  )
)

(define-public (unstakeFree (listing-id uint) (nft-asset-contract <nft-trait>) (rock-token-contract <ft-trait>))
  (let (
    (listing (unwrap! (map-get? staked listing-id) ERR_UNKNOWN_LISTING))
    (maker (get maker listing))
    (height (get hi listing))
    (rock-height (- block-height height))
  )
  
    (asserts! (is-eq maker tx-sender) ERR_UNAUTHORISED)
    (asserts! (is-eq
      (get nft-asset-contract listing)
      (contract-of nft-asset-contract)
    ) ERR_NFT_ASSET_MISMATCH)
    
    ;; Delete the listing and transfer the NFT back to the maker
    (map-delete staked listing-id)
    (map-set totalStaked (as-contract tx-sender) (- (get-count (as-contract tx-sender)) u1))
    (try! (transfer-nft nft-asset-contract (get token-id listing) (as-contract tx-sender) maker))
  
    
    (ok listing-id)
  )
)