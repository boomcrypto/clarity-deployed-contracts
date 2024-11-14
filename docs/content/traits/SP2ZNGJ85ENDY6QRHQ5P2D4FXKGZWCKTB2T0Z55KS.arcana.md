---
title: "Trait arcana"
draft: true
---
```
;; Intelligence - Arcana
;; 
;; Purpose:
;; This contract, named Arcana, is designed to reveal and manage key metrics of smart contracts
;; and tokens in the Stacks ecosystem. It serves as a central repository for important data, 
;; offering a standardized method to store, update, and retrieve critical information 
;; about various protocols, applications, and tokens.
;;
;; The Arcana contract provides insight into the underlying nature and behavior of smart contracts
;; and tokens, which can be utilized by DeFi protocols, analytics platforms, or other 
;; blockchain applications to make informed decisions and analyses.
;;
;; Key Features:
;; 1. Alignment Classification: A classification for each smart contract, providing a framework 
;;    to understand its nature, intent, and potential impact. Alignments are represented by 
;;    uint values from 0 to 9, where:
;;
;;      0 = Undefined
;;
;;      1 = Lawful Constructive: Contracts with strong principles aimed at creating value within defined rules.
;;         Examples: Transparent governance protocols, Audited lending platforms, Verified charity distribution contracts
;;
;;      2 = Neutral Constructive: Contracts that create value with more flexible methods.
;;         Examples: Adaptive yield optimization protocols, Community-driven grant distribution contracts
;;
;;      3 = Chaotic Constructive: Contracts promoting individual freedom while aiming to create value.
;;         Examples: Decentralized identity management contracts, Privacy-preserving transaction protocols
;;
;;      4 = Lawful Neutral: Contracts with strict adherence to predefined rules, prioritizing consistency.
;;         Examples: Algorithmic stablecoin contracts, Automated market maker contracts, Trustless escrow contracts
;;
;;      5 = True Neutral: Contracts that function without bias, simply enabling interactions.
;;         Examples: Basic token swap contracts, Cross-chain bridge contracts, Oracle data feed contracts
;;
;;      6 = Chaotic Neutral: Contracts allowing high degrees of freedom and unpredictability.
;;         Examples: Experimental DeFi protocol contracts, Permissionless liquidity pool contracts
;;
;;      7 = Lawful Extractive: Contracts that operate within system rules but extract disproportionate value.
;;         Examples: High-fee transaction protocols, Rent-seeking governance contracts
;;
;;      8 = Neutral Extractive: Contracts designed for value extraction without explicit harmful intent.
;;         Examples: Aggressive yield farming contracts, Frontrunning MEV bot contracts
;;
;;      9 = Chaotic Extractive: Contracts designed primarily for exploitation or harm.
;;         Examples: Rug pull contracts, Wallet drainer contracts, Ponzi scheme contracts
;;
;; 2. Quality Score Tracking: Maintains a quality score for each contract or token, ranging from 0 to 10000
;;    (representing 0% to 100.00%). This score represents various aspects of a contract's or token's
;;    characteristics, such as security, efficiency, or other assessments.
;;
;; 3. Circulating Supply Management: Tracks the circulating supply for each token. For non-token
;;    contracts, this value will be 0. This is crucial for accurate market cap calculations and 
;;    other tokenomics analyses when applicable.
;;
;; 4. Metadata URI: A URI (up to 256 characters) can be stored for each contract or token,
;;    providing a link to more detailed off-chain information.
;;
;; Usage:
;; - The contract owner can set and update alignments, quality scores, circulating supplies (for tokens), 
;;   and metadata URIs for contracts and tokens.
;; - Other contracts or users can query the Arcana contract to read these metrics and metadata.
;; - These insights can be used in various calculations or analyses in DeFi protocols
;;   or other blockchain applications.
;;
;; Note: This contract is a professional tool designed to provide critical data for 
;; blockchain ecosystems and applications. The alignment classification is subjective and
;; should be used in conjunction with other metrics and thorough research.

;; Constants
(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_INVALID_ALIGNMENT (err u101))
(define-constant ERR_INVALID_SCORE (err u102))
(define-constant ERR_INVALID_SUPPLY (err u103))

;; Data Variables
(define-data-var contract-owner principal tx-sender)

;; Maps
(define-map contract-alignments principal uint)
(define-map quality-scores principal uint)
(define-map circulating-supplies principal uint)
(define-map metadata-uris principal (string-utf8 256))

;; Read-only functions

(define-read-only (get-contract-owner)
  (ok (var-get contract-owner))
)

(define-read-only (get-alignment (contract principal))
  (default-to u0 (map-get? contract-alignments contract))
)

(define-read-only (get-quality-score (contract principal))
  (default-to u0 (map-get? quality-scores contract))
)

(define-read-only (get-circulating-supply (contract principal))
  (default-to u0 (map-get? circulating-supplies contract))
)

(define-read-only (get-metadata-uri (contract principal))
  (map-get? metadata-uris contract)
)

;; Private functions

(define-private (is-contract-owner)
  (is-eq contract-caller (var-get contract-owner))
)

;; Public functions

(define-public (set-alignment (contract principal) (alignment uint))
  (begin
    (asserts! (is-contract-owner) ERR_UNAUTHORIZED)
    (asserts! (<= alignment u9) ERR_INVALID_ALIGNMENT)
    (ok (map-set contract-alignments contract alignment))
  )
)

(define-public (set-quality-score (contract principal) (score uint))
  (begin
    (asserts! (is-contract-owner) ERR_UNAUTHORIZED)
    (asserts! (<= score u10000) ERR_INVALID_SCORE)
    (ok (map-set quality-scores contract score))
  )
)

(define-public (set-circulating-supply (contract principal) (supply uint))
  (begin
    (asserts! (is-contract-owner) ERR_UNAUTHORIZED)
    (ok (map-set circulating-supplies contract supply))
  )
)

(define-public (set-metadata-uri (contract principal) (uri (string-utf8 256)))
  (begin
    (asserts! (is-contract-owner) ERR_UNAUTHORIZED)
    (ok (map-set metadata-uris contract uri))
  )
)

(define-public (set-all-metrics (contract principal) (alignment uint) (score uint) (supply uint) (uri (string-utf8 256)))
  (begin
    (asserts! (is-contract-owner) ERR_UNAUTHORIZED)
    (asserts! (<= alignment u9) ERR_INVALID_ALIGNMENT)
    (asserts! (<= score u10000) ERR_INVALID_SCORE)
    (map-set contract-alignments contract alignment)
    (map-set quality-scores contract score)
    (map-set circulating-supplies contract supply)
    (map-set metadata-uris contract uri)
    (ok true)
  )
)

(define-public (set-contract-owner (new-owner principal))
  (begin
    (asserts! (is-contract-owner) ERR_UNAUTHORIZED)
    (ok (var-set contract-owner new-owner))
  )
)
```
