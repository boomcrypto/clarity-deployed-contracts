---
title: "Trait launch-action-proposals"
draft: true
---
```
;; title: aibtcdev-action-proposals
;; version: 1.0.0
;; summary: An extension that manages voting on predefined actions using a SIP-010 Stacks token.
;; description: This contract allows voting on specific extension actions with a lower threshold than core proposals.

;; traits
;;
(impl-trait 'SP29CK9990DQGE9RGTT1VEQTTYH8KY4E3JE5XP4EC.aibtcdev-dao-traits-v1.extension)
(impl-trait 'SP29CK9990DQGE9RGTT1VEQTTYH8KY4E3JE5XP4EC.aibtcdev-dao-traits-v1.action-proposals)

(use-trait ft-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)
(use-trait treasury-trait 'SP29CK9990DQGE9RGTT1VEQTTYH8KY4E3JE5XP4EC.aibtcdev-dao-traits-v1.treasury)
(use-trait action-trait 'SP29CK9990DQGE9RGTT1VEQTTYH8KY4E3JE5XP4EC.aibtcdev-dao-traits-v1.action)

;; constants
;;
(define-constant SELF (as-contract tx-sender))
(define-constant VOTING_PERIOD u144) ;; 144 Bitcoin blocks, ~1 day
(define-constant VOTING_QUORUM u66) ;; 66% of liquid supply

;; error messages
(define-constant ERR_NOT_DAO_OR_EXTENSION (err u1000))
(define-constant ERR_INSUFFICIENT_BALANCE (err u1001))
(define-constant ERR_FETCHING_TOKEN_DATA (err u1002))
(define-constant ERR_PROPOSAL_NOT_FOUND (err u1003))
(define-constant ERR_PROPOSAL_STILL_ACTIVE (err u1004))
(define-constant ERR_SAVING_PROPOSAL (err u1005))
(define-constant ERR_PROPOSAL_ALREADY_CONCLUDED (err u1006))
(define-constant ERR_RETRIEVING_START_BLOCK_HASH (err u1007))
(define-constant ERR_VOTE_TOO_SOON (err u1008))
(define-constant ERR_VOTE_TOO_LATE (err u1009))
(define-constant ERR_ALREADY_VOTED (err u1010))
(define-constant ERR_INVALID_ACTION (err u1011))

;; contracts used for voting calculations
(define-constant VOTING_TOKEN_DEX 'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.launch-stxcity-dex)
(define-constant VOTING_TOKEN_POOL 'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.xyk-pool-stx-launch-v-1-1)
(define-constant VOTING_TREASURY 'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.launch-treasury)

;; data vars
;;
(define-data-var proposalCount uint u0) ;; total number of proposals

;; data maps
;;
(define-map Proposals
  uint ;; proposal id
  {
    action: principal, ;; action contract
    parameters: (buff 2048), ;; action parameters
    createdAt: uint, ;; block height
    caller: principal, ;; contract caller
    creator: principal, ;; proposal creator (tx-sender)
    startBlockStx: uint, ;; block height for at-block calls
    startBlock: uint, ;; burn block height
    endBlock: uint, ;; burn block height
    votesFor: uint, ;; total votes for
    votesAgainst: uint, ;; total votes against
    liquidTokens: uint, ;; liquid tokens
    concluded: bool, ;; has the proposal concluded
    passed: bool, ;; did the proposal pass
  }
)

(define-map VotingRecords
  {
    proposalId: uint, ;; proposal id
    voter: principal ;; voter address
  }
  uint ;; total votes
)

;; public functions
;;

(define-public (callback (sender principal) (memo (buff 34)))
  (ok true)
)

(define-public (propose-action (action <action-trait>) (parameters (buff 2048)))
  (let
    (
      (newId (+ (var-get proposalCount) u1))
      (voterBalance (unwrap! (contract-call? 'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.launch-stxcity get-balance tx-sender) ERR_FETCHING_TOKEN_DATA))
      (liquidTokens (try! (get-liquid-supply block-height)))
    )
    ;; caller has the required balance
    (asserts! (> voterBalance u0) ERR_INSUFFICIENT_BALANCE)
    ;; print proposal creation event
    (print {
      notification: "propose-action",
      payload: {
        proposalId: newId,
        action: action,
        parameters: parameters,
        creator: tx-sender,
        liquidTokens: liquidTokens,
        startBlockStx: block-height,
        startBlock: burn-block-height,
        endBlock: (+ burn-block-height VOTING_PERIOD)
      }
    })
    ;; create the proposal
    (asserts! (map-insert Proposals newId {
      action: (contract-of action),
      parameters: parameters,
      createdAt: burn-block-height,
      caller: contract-caller,
      creator: tx-sender,
      startBlockStx: block-height,
      startBlock: burn-block-height,
      endBlock: (+ burn-block-height VOTING_PERIOD),
      votesFor: u0,
      votesAgainst: u0,
      liquidTokens: liquidTokens,
      concluded: false,
      passed: false,
    }) ERR_SAVING_PROPOSAL)
    ;; increment proposal count
    (ok (var-set proposalCount newId))
  )
)

(define-public (vote-on-proposal (proposalId uint) (vote bool))
  (let
    (
      (proposalRecord (unwrap! (map-get? Proposals proposalId) ERR_PROPOSAL_NOT_FOUND))
      (proposalBlock (get startBlockStx proposalRecord))
      (proposalBlockHash (unwrap! (get-block-hash proposalBlock) ERR_RETRIEVING_START_BLOCK_HASH))
      (senderBalance (unwrap! (at-block proposalBlockHash (contract-call? 'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.launch-stxcity get-balance tx-sender)) ERR_FETCHING_TOKEN_DATA))
    )
    ;; caller has the required balance
    (asserts! (> senderBalance u0) ERR_INSUFFICIENT_BALANCE)
    ;; proposal not still active
    (asserts! (>= burn-block-height (get startBlock proposalRecord)) ERR_VOTE_TOO_SOON)
    (asserts! (< burn-block-height (get endBlock proposalRecord)) ERR_VOTE_TOO_LATE)
    ;; proposal not already concluded
    (asserts! (not (get concluded proposalRecord)) ERR_PROPOSAL_ALREADY_CONCLUDED)
    ;; vote not already cast
    (asserts! (is-none (map-get? VotingRecords {proposalId: proposalId, voter: tx-sender})) ERR_ALREADY_VOTED)
    ;; print vote event
    (print {
      notification: "vote-on-proposal",
      payload: {
        proposalId: proposalId,
        voter: tx-sender,
        amount: senderBalance
      }
    })
    ;; update the proposal record
    (map-set Proposals proposalId
      (if vote
        (merge proposalRecord {votesFor: (+ (get votesFor proposalRecord) senderBalance)})
        (merge proposalRecord {votesAgainst: (+ (get votesAgainst proposalRecord) senderBalance)})
      )
    )
    ;; record the vote for the sender
    (ok (map-set VotingRecords {proposalId: proposalId, voter: tx-sender} senderBalance))
  )
)

(define-public (conclude-proposal (proposalId uint) (action <action-trait>))
  (let
    (
      (proposalRecord (unwrap! (map-get? Proposals proposalId) ERR_PROPOSAL_NOT_FOUND))
      ;; if VOTING_QUORUM <= ((votesFor * 100) / liquidTokens)
      (votePassed (<= VOTING_QUORUM (/ (* (get votesFor proposalRecord) u100) (get liquidTokens proposalRecord))))
    )
    ;; verify extension still active in dao
    (try! (as-contract (is-dao-or-extension)))
    ;; proposal past end block height
    (asserts! (>= burn-block-height (get endBlock proposalRecord)) ERR_PROPOSAL_STILL_ACTIVE)
    ;; proposal not already concluded
    (asserts! (not (get concluded proposalRecord)) ERR_PROPOSAL_ALREADY_CONCLUDED)
    ;; action must be the same as the one in proposal
    (asserts! (is-eq (get action proposalRecord) (contract-of action)) ERR_INVALID_ACTION)
    ;; print conclusion event
    (print {
      notification: "conclude-proposal",
      payload: {
        proposalId: proposalId,
        passed: votePassed
      }
    })
    ;; update the proposal record
    (map-set Proposals proposalId
      (merge proposalRecord {
        concluded: true,
        passed: votePassed
      })
    )
    ;; execute the action only if it passed
    (ok (if votePassed
      (match (contract-call? action run (get parameters proposalRecord)) ok_ true err_ (begin (print {err:err_}) false))
      false
    ))
  )
)

;; read only functions
;;

(define-read-only (get-voting-power (who principal) (proposalId uint))
  (let
    (
      (proposalRecord (unwrap! (map-get? Proposals proposalId) ERR_PROPOSAL_NOT_FOUND))
      (proposalBlockHash (unwrap! (get-block-hash (get startBlockStx proposalRecord)) ERR_RETRIEVING_START_BLOCK_HASH))
    )
    (at-block proposalBlockHash (contract-call? 'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.launch-stxcity get-balance who))
  )
)

(define-read-only (get-linked-voting-contracts)
  {
    treasury: VOTING_TREASURY,
    token-dex: VOTING_TOKEN_DEX,
    token-pool: VOTING_TOKEN_POOL
  }
)

(define-read-only (get-proposal (proposalId uint))
  (map-get? Proposals proposalId)
)

(define-read-only (get-total-votes (proposalId uint) (voter principal))
  (default-to u0 (map-get? VotingRecords {proposalId: proposalId, voter: voter}))
)

(define-read-only (get-voting-period)
  VOTING_PERIOD
)

(define-read-only (get-voting-quorum)
  VOTING_QUORUM
)

(define-read-only (get-total-proposals)
  (var-get proposalCount)
)

;; private functions
;;

(define-private (is-dao-or-extension)
  (ok (asserts! (or (is-eq tx-sender 'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.launch-base-dao)
    (contract-call? 'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.launch-base-dao is-extension contract-caller)) ERR_NOT_DAO_OR_EXTENSION
  ))
)

(define-private (get-block-hash (blockHeight uint))
  (get-block-info? id-header-hash blockHeight)
)

(define-private (get-liquid-supply (blockHeight uint))
  (let
    (
      (blockHash (unwrap! (get-block-hash blockHeight) ERR_RETRIEVING_START_BLOCK_HASH))
      (totalSupply (unwrap! (at-block blockHash (contract-call? 'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.launch-stxcity get-total-supply)) ERR_FETCHING_TOKEN_DATA))
      (dexBalance (unwrap! (at-block blockHash (contract-call? 'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.launch-stxcity get-balance VOTING_TOKEN_DEX)) ERR_FETCHING_TOKEN_DATA))
      (poolBalance (unwrap! (at-block blockHash (contract-call? 'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.launch-stxcity get-balance VOTING_TOKEN_POOL)) ERR_FETCHING_TOKEN_DATA))
      (treasuryBalance (unwrap! (at-block blockHash (contract-call? 'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.launch-stxcity get-balance VOTING_TREASURY)) ERR_FETCHING_TOKEN_DATA))
    )
    (ok (- totalSupply (+ dexBalance poolBalance treasuryBalance)))
  )
)


```
