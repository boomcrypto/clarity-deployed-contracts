;; title: aibtcdev-dao-traits-v1
;; version: 1.0.0
;; summary: A collection of traits for the aibtcdev DAO

;; IMPORTS

(use-trait ft-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)
(use-trait nft-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

;; CORE DAO TRAITS

(define-trait proposal (
  (execute (principal) (response bool uint))
))

(define-trait extension (
  (callback (principal (buff 34)) (response bool uint))
))

;; EXTENSION TRAITS

(define-trait action (
  ;; @param parameters encoded action parameters
  ;; @returns (response bool uint)
  (run ((buff 2048)) (response bool uint))
))

(define-trait action-proposals (
  ;; set the protocol treasury contract
  ;; @param treasury the treasury contract principal
  ;; @returns (response bool uint)
  (set-protocol-treasury (<treasury>) (response bool uint))
  ;; set the voting token contract
  ;; @param token the token contract principal
  ;; @returns (response bool uint)
  (set-voting-token (<ft-trait>) (response bool uint))
  ;; propose a new action
  ;; @param action the action contract
  ;; @param parameters encoded action parameters
  ;; @param token the voting token contract
  ;; @returns (response bool uint)
  (propose-action (<action> (buff 2048) <ft-trait>) (response bool uint))
  ;; vote on an existing proposal
  ;; @param proposal the proposal id
  ;; @param token the voting token contract
  ;; @param vote true for yes, false for no
  ;; @returns (response bool uint)
  (vote-on-proposal (uint <ft-trait> bool) (response bool uint))
  ;; conclude a proposal after voting period
  ;; @param proposal the proposal id
  ;; @param action the action contract
  ;; @param treasury the treasury contract
  ;; @param token the voting token contract
  ;; @returns (response bool uint)
  (conclude-proposal (uint <action> <treasury> <ft-trait>) (response bool uint))
))

(define-trait bank-account (
  ;; set account holder
  ;; @param principal the new account holder
  ;; @returns (response bool uint)
  (set-account-holder (principal) (response bool uint))
  ;; set withdrawal period
  ;; @param period the new withdrawal period in blocks
  ;; @returns (response bool uint)
  (set-withdrawal-period (uint) (response bool uint))
  ;; set withdrawal amount
  ;; @param amount the new withdrawal amount in microSTX
  ;; @returns (response bool uint)
  (set-withdrawal-amount (uint) (response bool uint))
  ;; override last withdrawal block
  ;; @param block the new last withdrawal block
  ;; @returns (response bool uint)
  (override-last-withdrawal-block (uint) (response bool uint))
  ;; deposit STX to the bank account
  ;; @param amount amount of microSTX to deposit
  ;; @returns (response bool uint)
  (deposit-stx (uint) (response bool uint))
  ;; withdraw STX from the bank account
  ;; @returns (response bool uint) 
  (withdraw-stx () (response bool uint))
))

(define-trait bitflow-pool (
  ;; transfer funds (limited as we're just tagging this)
  ;; all functions are covered between sip-010 and bitflow-xyk
  (transfer (uint principal principal (optional (buff 34))) (response bool uint))
))

(define-trait core-proposals (
  ;; set the protocol treasury contract
  ;; @param treasury the treasury contract principal
  ;; @returns (response bool uint)
  (set-protocol-treasury (<treasury>) (response bool uint))
  ;; set the voting token contract
  ;; @param token the token contract principal
  ;; @returns (response bool uint)
  (set-voting-token (<ft-trait>) (response bool uint))
  ;; create a new proposal
  ;; @param proposal the proposal contract
  ;; @param token the voting token contract
  ;; @returns (response bool uint)
  (create-proposal (<proposal> <ft-trait>) (response bool uint))
  ;; vote on an existing proposal
  ;; @param proposal the proposal contract
  ;; @param token the voting token contract
  ;; @param vote true for yes, false for no
  ;; @returns (response bool uint)
  (vote-on-proposal (<proposal> <ft-trait> bool) (response bool uint))
  ;; conclude a proposal after voting period
  ;; @param proposal the proposal contract
  ;; @param treasury the treasury contract
  ;; @param token the voting token contract
  ;; @returns (response bool uint)
  (conclude-proposal (<proposal> <treasury> <ft-trait>) (response bool uint))
))

(define-trait messaging (
  ;; send a message on-chain (opt from DAO)
  ;; @param msg the message to send (up to 1MB)
  ;; @param isFromDao whether the message is from the DAO
  ;; @returns (response bool uint)
  (send ((string-ascii 1048576) bool) (response bool uint))
))

(define-trait invoices (
  ;; pay an invoice by ID
  ;; @param invoice the ID of the invoice
  ;; @returns (response uint uint)
  (pay-invoice (uint (optional (buff 34))) (response uint uint))
  ;; pay an invoice by resource name
  ;; @param name the name of the resource
  ;; @returns (response uint uint)
  (pay-invoice-by-resource-name ((string-utf8 50) (optional (buff 34))) (response uint uint))
))

(define-trait resources (
  ;; set payment address for resource invoices
  ;; @param principal the new payment address
  ;; @returns (response bool uint)
  (set-payment-address (principal) (response bool uint))
  ;; adds a new resource that users can pay for
  ;; @param name the name of the resource (unique!)
  ;; @param price the price of the resource in microSTX
  ;; @param description a description of the resource
  ;; @returns (response uint uint)
  (add-resource ((string-utf8 50) (string-utf8 255) uint (optional (string-utf8 255))) (response uint uint))
  ;; toggles a resource on or off for payment
  ;; @param resource the ID of the resource
  ;; @returns (response bool uint)
  (toggle-resource (uint) (response bool uint))
  ;; toggles a resource on or off for payment by name
  ;; @param name the name of the resource
  ;; @returns (response bool uint)
  (toggle-resource-by-name ((string-utf8 50)) (response bool uint))
))

(define-trait token-dex (
  ;; buy tokens from the dex
  ;; @param token-trait the token contract
  ;; @param stx-amount the amount of microSTX to spend
  ;; @returns (response uint uint)
  (buy (<ft-trait> uint) (response uint uint))
  ;; sell tokens to the dex
  ;; @param token-trait the token contract
  ;; @param tokens-in the amount of tokens to sell
  ;; @returns (response uint uint)
  (sell (<ft-trait> uint) (response uint uint))
))

(define-trait token-owner (
  ;; set the token URI
  ;; @param value the new token URI
  ;; @returns (response bool uint)
  (set-token-uri ((string-utf8 256)) (response bool uint))
  ;; transfer ownership of the token
  ;; @param new-owner the new owner of the token
  ;; @returns (response bool uint)
  (transfer-ownership (principal) (response bool uint))
))

(define-trait token (
  ;; transfer funds (limited as we're just tagging this)
  (transfer (uint principal principal (optional (buff 34))) (response bool uint))
))

(define-trait treasury (
  ;; allow an asset for deposit/withdrawal
  ;; @param token the asset contract principal
  ;; @param enabled whether the asset is allowed
  ;; @returns (response bool uint)
  (allow-asset (principal bool) (response bool uint))
  ;; allow multiple assets for deposit/withdrawal
  ;; @param allowList a list of asset contracts and enabled status
  ;; @returns (response bool uint)
  ;; TODO: removed due to conflict with contract definition (both are the same?)
  ;; (allow-assets ((list 100 (tuple (token principal) (enabled bool)))) (response bool uint))
  ;; deposit STX to the treasury
  ;; @param amount amount of microSTX to deposit
  ;; @returns (response bool uint)
  (deposit-stx (uint) (response bool uint))
  ;; deposit FT to the treasury
  ;; @param ft the fungible token contract principal
  ;; @param amount amount of tokens to deposit
  ;; @returns (response bool uint)
  (deposit-ft (<ft-trait> uint) (response bool uint))
  ;; deposit NFT to the treasury
  ;; @param nft the non-fungible token contract principal
  ;; @param id the ID of the token to deposit
  ;; @returns (response bool uint)
  (deposit-nft (<nft-trait> uint) (response bool uint))
  ;; withdraw STX from the treasury
  ;; @param amount amount of microSTX to withdraw
  ;; @param recipient the recipient of the STX
  ;; @returns (response bool uint)
  (withdraw-stx (uint principal) (response bool uint))
  ;; withdraw FT from the treasury
  ;; @param ft the fungible token contract principal
  ;; @param amount amount of tokens to withdraw
  ;; @param recipient the recipient of the tokens
  ;; @returns (response bool uint)
  (withdraw-ft (<ft-trait> uint principal) (response bool uint))
  ;; withdraw NFT from the treasury
  ;; @param nft the non-fungible token contract principal
  ;; @param id the ID of the token to withdraw
  ;; @param recipient the recipient of the token
  ;; @returns (response bool uint)
  (withdraw-nft (<nft-trait> uint principal) (response bool uint))
  ;; delegate STX for stacking in PoX
  ;; @param amount max amount of microSTX that can be delegated
  ;; @param to the address to delegate to
  ;; @returns (response bool uint)
  (delegate-stx (uint principal) (response bool uint))
  ;; revoke delegation of STX from stacking in PoX
  ;; @returns (response bool uint)
  (revoke-delegate-stx () (response bool uint))
))
