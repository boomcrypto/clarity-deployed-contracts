;; title: aibtcdev-action-proposals
;; version: 1.0.0
;; summary: An extension that manages voting on predefined actions using a SIP-010 Stacks token.
;; description: This contract allows voting on specific extension actions with a lower threshold than core proposals.

;; traits
;;
(impl-trait 'SPTWD9SPRQVD3P733V89SV0P8RZRZNQADJHHPME1.aibtcdev-dao-traits-v1.extension)
(impl-trait 'SPTWD9SPRQVD3P733V89SV0P8RZRZNQADJHHPME1.aibtcdev-dao-traits-v1.action-proposals)

(use-trait ft-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)
(use-trait treasury-trait 'SPTWD9SPRQVD3P733V89SV0P8RZRZNQADJHHPME1.aibtcdev-dao-traits-v1.treasury)
(use-trait action-trait 'SPTWD9SPRQVD3P733V89SV0P8RZRZNQADJHHPME1.aibtcdev-dao-traits-v1.action)

;; constants
;;
(define-constant SELF (as-contract tx-sender))
(define-constant VOTING_PERIOD u144) ;; 144 Bitcoin blocks, ~1 day
(define-constant VOTING_QUORUM u66) ;; 66% of liquid supply (total supply - treasury)

;; error messages - authorization
(define-constant ERR_NOT_DAO_OR_EXTENSION (err u1000))

;; error messages - initialization
(define-constant ERR_NOT_INITIALIZED (err u1100))

;; error messages - treasury
(define-constant ERR_TREASURY_CANNOT_BE_SELF (err u1200))
(define-constant ERR_TREASURY_MISMATCH (err u1201))
(define-constant ERR_TREASURY_CANNOT_BE_SAME (err u1202))

;; error messages - voting token
(define-constant ERR_TOKEN_ALREADY_INITIALIZED (err u1300))
(define-constant ERR_TOKEN_MISMATCH (err u1301))
(define-constant ERR_INSUFFICIENT_BALANCE (err u1302))
(define-constant ERR_TOKEN_CANNOT_BE_SELF (err u1303))
(define-constant ERR_TOKEN_CANNOT_BE_SAME (err u1304))

;; error messages - proposals
(define-constant ERR_PROPOSAL_NOT_FOUND (err u1400))
(define-constant ERR_PROPOSAL_STILL_ACTIVE (err u1401))
(define-constant ERR_SAVING_PROPOSAL (err u1402))
(define-constant ERR_PROPOSAL_ALREADY_CONCLUDED (err u1403))

;; error messages - voting
(define-constant ERR_VOTE_TOO_SOON (err u1500))
(define-constant ERR_VOTE_TOO_LATE (err u1501))
(define-constant ERR_ALREADY_VOTED (err u1502))
(define-constant ERR_ZERO_VOTING_POWER (err u1503))
(define-constant ERR_QUORUM_NOT_REACHED (err u1504))

;; error messages - actions
(define-constant ERR_INVALID_ACTION (err u1600))

;; data vars
;;
(define-data-var protocolTreasury principal SELF) ;; the treasury contract for protocol funds
(define-data-var votingToken principal SELF) ;; the FT contract used for voting
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
    startBlock: uint, ;; block height
    endBlock: uint, ;; block height
    votesFor: uint, ;; total votes for
    votesAgainst: uint, ;; total votes against
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

(define-public (set-protocol-treasury (treasury <treasury-trait>))
  (let
    (
      (treasuryContract (contract-of treasury))
    )
    (try! (is-dao-or-extension))
    ;; cannot set treasury to self
    (asserts! (not (is-eq treasuryContract SELF)) ERR_TREASURY_CANNOT_BE_SELF)
    ;; cannot set treasury to same value
    (asserts! (not (is-eq treasuryContract (var-get protocolTreasury))) ERR_TREASURY_CANNOT_BE_SAME)
    (print {
      notification: "set-protocol-treasury",
      payload: {
        treasury: treasuryContract
      }
    })
    (ok (var-set protocolTreasury treasuryContract))
  )
)

(define-public (set-voting-token (token <ft-trait>))
  (let
    (
      (tokenContract (contract-of token))
    )
    (try! (is-dao-or-extension))
    ;; cannot set token to self
    (asserts! (not (is-eq tokenContract SELF)) ERR_TOKEN_CANNOT_BE_SELF)
    ;; cannot set token to same value
    (asserts! (not (is-eq tokenContract (var-get votingToken))) ERR_TOKEN_CANNOT_BE_SAME)
    ;; cannot set token if already set once
    (asserts! (is-eq (var-get votingToken) SELF) ERR_TOKEN_ALREADY_INITIALIZED)
    (print {
      notification: "set-voting-token",
      payload: {
        token: tokenContract
      }
    })
    (ok (var-set votingToken tokenContract))
  )
)

(define-public (propose-action (action <action-trait>) (parameters (buff 2048)) (token <ft-trait>))
  (let
    (
      (tokenContract (contract-of token))
      (newId (+ (var-get proposalCount) u1))
    )
    ;; required variables must be set
    (asserts! (is-initialized) ERR_NOT_INITIALIZED)
    ;; token matches set voting token
    (asserts! (is-eq tokenContract (var-get votingToken)) ERR_TOKEN_MISMATCH)
    ;; caller has the required balance
    (asserts! (> (try! (contract-call? token get-balance tx-sender)) u0) ERR_INSUFFICIENT_BALANCE)
    ;; print proposal creation event
    (print {
      notification: "propose-action",
      payload: {
        proposalId: newId,
        action: action,
        parameters: parameters,
        creator: tx-sender,
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
      startBlock: burn-block-height,
      endBlock: (+ burn-block-height VOTING_PERIOD),
      votesFor: u0,
      votesAgainst: u0,
      concluded: false,
      passed: false,
    }) ERR_SAVING_PROPOSAL)
    ;; increment proposal count
    (ok (var-set proposalCount newId))
  )
)

(define-public (vote-on-proposal (proposalId uint) (token <ft-trait>) (vote bool))
  (let
    (
      (tokenContract (contract-of token))
      (senderBalance (try! (contract-call? token get-balance tx-sender)))
    )
    ;; required variables must be set
    (asserts! (is-initialized) ERR_NOT_INITIALIZED)
    ;; token matches set voting token
    (asserts! (is-eq tokenContract (var-get votingToken)) ERR_TOKEN_MISMATCH)
    ;; caller has the required balance
    (asserts! (> senderBalance u0) ERR_INSUFFICIENT_BALANCE)
    ;; get proposal record
    (let
      (
        (proposalRecord (unwrap! (map-get? Proposals proposalId) ERR_PROPOSAL_NOT_FOUND))
      )
      ;; proposal is still active
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
)

(define-public (conclude-proposal (proposalId uint) (action <action-trait>) (treasury <treasury-trait>) (token <ft-trait>))
  (let
    (
      (proposalRecord (unwrap! (map-get? Proposals proposalId) ERR_PROPOSAL_NOT_FOUND))
      (tokenContract (contract-of token))
      (tokenTotalSupply (try! (contract-call? token get-total-supply)))
      (treasuryContract (contract-of treasury))
      (treasuryBalance (try! (contract-call? token get-balance treasuryContract)))
      (votePassed (> (get votesFor proposalRecord) (* tokenTotalSupply (- u100 treasuryBalance) VOTING_QUORUM)))
    )
    ;; required variables must be set
    (asserts! (is-initialized) ERR_NOT_INITIALIZED)
    ;; verify treasury matches protocol treasury
    (asserts! (is-eq treasuryContract (var-get protocolTreasury)) ERR_TREASURY_MISMATCH)
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

(define-read-only (get-protocol-treasury)
  (if (is-eq (var-get protocolTreasury) SELF)
    none
    (some (var-get protocolTreasury))
  )
)

(define-read-only (get-voting-token)
  (if (is-eq (var-get votingToken) SELF)
    none
    (some (var-get votingToken))
  )
)

(define-read-only (get-proposal (proposalId uint))
  (map-get? Proposals proposalId)
)

(define-read-only (get-total-votes (proposalId uint) (voter principal))
  (default-to u0 (map-get? VotingRecords {proposalId: proposalId, voter: voter}))
)

(define-read-only (is-initialized)
  ;; check if the required variables are set
  (not (or
    (is-eq (var-get votingToken) SELF)
    (is-eq (var-get protocolTreasury) SELF)
  ))
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
  (ok (asserts! (or (is-eq tx-sender 'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.aimkt-base-dao)
    (contract-call? 'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.aimkt-base-dao is-extension contract-caller)) ERR_NOT_DAO_OR_EXTENSION
  ))
)

