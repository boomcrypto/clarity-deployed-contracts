;; title: aibtc-dao-traits
;; version: 3.3.3
;; summary: A collection of traits for aibtc cohort 0.

;; IMPORTS
(use-trait faktory-token 'SP3XXMS38VTAWTVPE5682XSBFXPTH7XCPEBTX8AN2.faktory-trait-v1.sip-010-trait)
(use-trait ft-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)
(use-trait nft-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

;; CORE DAO TRAITS

;; a one-time action proposed by token holders
(define-trait proposal (
  (execute
    (principal)
    (response bool uint)
  )
))

;; a standing feature of the dao implemented in Clarity
(define-trait extension (
  (callback
    (principal (buff 34))
    (response bool uint)
  )
))

;; TOKEN TRAITS

;; the decentralized Bitflow trading pool following their xyk formula
(define-trait bitflow-pool (
  (transfer
    (uint principal principal (optional (buff 34)))
    (response bool uint)
  )
))

;; the decentralized exchange and initial bonding curve for a token
;; can be used to buy and sell tokens until the target is reached
;; liquidity is provided by the initial minting of tokens
;; reaching the target will trigger migration to the Bitflow pool
(define-trait faktory-dex (
  (buy
    (<faktory-token> uint)
    (response bool uint)
  )
  (sell
    (<faktory-token> uint)
    (response bool uint)
  )
))

;; the token contract for the dao, with no pre-mine or initial allocation
(define-trait token (
  (transfer
    (uint principal principal (optional (buff 34)))
    (response bool uint)
  )
))

;; EXTENSION TRAITS

;; a pre-defined action that token holders can propose
(define-trait action (
  (run
    ((buff 2048))
    (response bool uint)
  )
  (check-parameters
    ((buff 2048))
    (response bool uint)
  )
))

;; a voting contract to vote on whitelisted pre-defined actions
(define-trait action-proposal-voting (
  (create-action-proposal
    (<action> (buff 2048) (optional (string-ascii 1024)))
    (response bool uint)
  )
  (vote-on-action-proposal
    (uint bool)
    (response bool uint)
  )
  (veto-action-proposal
    (uint)
    (response bool uint)
  )
  (conclude-action-proposal
    (uint <action>)
    (response bool uint)
  )
))

;; an extension to manage the dao charter and mission
;; allows the dao to define its mission and values on-chain
;; used to guide decision-making and proposals
(define-trait dao-charter (
  (set-dao-charter
    ((string-utf8 16384))
    (response bool uint)
  )
))

;; an extension that tracks the current epoch of the DAO
(define-trait dao-epoch (
  (get-current-dao-epoch
    ()
    (response uint uint)
  )
  (get-dao-epoch-length
    ()
    (response uint uint)
  )
))

;; an extension that tracks the current users and their reputation in the DAO
(define-trait dao-users (
  (get-or-create-user-index
    (principal)
    (response uint uint)
  )
  (increase-user-reputation
    (principal uint)
    (response bool uint)
  )
  (decrease-user-reputation
    (principal uint)
    (response bool uint)
  )
))

;; a messaging contract used by the dao to send verified messages
(define-trait messaging (
  (send
    ((string-utf8 10000))
    (response bool uint)
  )
))

;; an extension that holds funds from the DAO treasury and allows
;; the DAO to transfer rewards to users for successful proposals.
(define-trait rewards-account (
  (transfer-reward
    (principal uint)
    (response bool uint)
  )
))

;; an extension that manages the token on behalf of the dao
;; allows for same functionality normally used by deployer through proposals
(define-trait token-owner (
  (set-token-uri
    ((string-utf8 256))
    (response bool uint)
  )
  (transfer-ownership
    (principal)
    (response bool uint)
  )
))

;; an extension that manages the DAO treasury
;; restricted to operate with the rewards-account and proposal flows
(define-trait treasury (
  (allow-asset
    (principal bool)
    (response bool uint)
  )
  (deposit-ft
    (<ft-trait> uint)
    (response bool uint)
  )
  (withdraw-ft
    (<ft-trait> uint principal)
    (response bool uint)
  )
))
