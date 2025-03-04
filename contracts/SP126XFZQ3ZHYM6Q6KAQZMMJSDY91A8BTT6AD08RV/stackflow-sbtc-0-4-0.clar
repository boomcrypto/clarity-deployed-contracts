;; title: stackflow
;; author: brice.btc
;; version: 0.4.0
;; summary: Stackflow is a payment channel network built on Stacks, enabling
;;   off-chain, non-custodial, and high-speed payments between users. Designed
;;   to be simple, secure, and efficient, it supports transactions in STX and
;;   approved SIP-010 fungible tokens.

;; MIT License

;; Copyright (c) 2024-2025 obycode, LLC

;; Permission is hereby granted, free of charge, to any person obtaining a copy
;; of this software and associated documentation files (the "Software"), to deal
;; in the Software without restriction, including without limitation the rights
;; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
;; copies of the Software, and to permit persons to whom the Software is
;; furnished to do so, subject to the following conditions:

;; The above copyright notice and this permission notice shall be included in all
;; copies or substantial portions of the Software.

;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
;; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
;; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
;; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
;; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
;; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
;; SOFTWARE.

(use-trait sip-010 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)
(impl-trait 'SP126XFZQ3ZHYM6Q6KAQZMMJSDY91A8BTT6AD08RV.stackflow-token-0-4-0.stackflow-token)

(define-constant contract-deployer tx-sender)
(define-constant MAX_HEIGHT u340282366920938463463374607431768211455)
(define-constant WAITING_PERIOD u144) ;; 24 hours in blocks

;; Constants for SIP-018 structured data
(define-constant structured-data-prefix 0x534950303138)
(define-constant message-domain-hash (sha256 (unwrap-panic (to-consensus-buff?
	{
		name: "StackFlow",
		version: "0.4.0",
		chain-id: chain-id
	}
))))
(define-constant structured-data-header (concat structured-data-prefix message-domain-hash))

;; Actions
(define-constant ACTION_CLOSE u0)
(define-constant ACTION_TRANSFER u1)
(define-constant ACTION_DEPOSIT u2)
(define-constant ACTION_WITHDRAWAL u3)

;; Error codes
(define-constant ERR_DEPOSIT_FAILED (err u100))
(define-constant ERR_NO_SUCH_CHANNEL (err u101))
(define-constant ERR_INVALID_PRINCIPAL (err u102))
(define-constant ERR_INVALID_SENDER_SIGNATURE (err u103))
(define-constant ERR_INVALID_OTHER_SIGNATURE (err u104))
(define-constant ERR_CONSENSUS_BUFF (err u105))
(define-constant ERR_UNAUTHORIZED (err u106))
(define-constant ERR_MAX_ALLOWED (err u107))
(define-constant ERR_INVALID_TOTAL_BALANCE (err u108))
(define-constant ERR_WITHDRAWAL_FAILED (err u109))
(define-constant ERR_CHANNEL_EXPIRED (err u110))
(define-constant ERR_NONCE_TOO_LOW (err u111))
(define-constant ERR_CLOSE_IN_PROGRESS (err u112))
(define-constant ERR_NO_CLOSE_IN_PROGRESS (err u113))
(define-constant ERR_SELF_DISPUTE (err u114))
(define-constant ERR_ALREADY_FUNDED (err u115))
(define-constant ERR_INVALID_WITHDRAWAL (err u116))
(define-constant ERR_UNAPPROVED_TOKEN (err u117))
(define-constant ERR_NOT_EXPIRED (err u118))
(define-constant ERR_NOT_INITIALIZED (err u119))
(define-constant ERR_ALREADY_INITIALIZED (err u120))

;;; Has this contract been initialized?
(define-data-var initialized bool false)

;;; The token supported by this instance of the Stackflow contract.
;;; If `none`, only STX is supported.
(define-data-var supported-token (optional principal) none)

;;; Map tracking the initial balances in channels between two principals for a
;;; given token.
(define-map
  channels
  { token: (optional principal), principal-1: principal, principal-2: principal }
  { balance-1: uint, balance-2: uint, expires-at: uint, nonce: uint, closer: (optional principal) }
)

;; Mapping of principals to agents registered to act on their behalf
(define-map agents principal principal)

;; Public Functions
;;

;;; Initialize the contract with the supported token.
;;; Returns:
;;; - `(ok true)` on success
;;; - `ERR_ALREADY_INITIALIZED` if the contract has already been initialized
;;; - `ERR_UNAUTHORIZED` if the sender is not the contract deployer
(define-public (init (token (optional <sip-010>)))
  (begin
    (asserts! (not (var-get initialized)) ERR_ALREADY_INITIALIZED)
    (asserts! (is-eq tx-sender contract-deployer) ERR_UNAUTHORIZED)
    (var-set supported-token (contract-of-optional token))
    (ok (var-set initialized true))
  )
)

;;; Register an agent to act on your behalf. Registering an agent allows you to
;;; transfer the responsibility of maintaining an always-on server for managing
;;; your payment channels. The agent can perform all reactive actions on your
;;; behalf, including signing off on incoming transfers, deposit, withdraw, and
;;; closure requests from the other party, and disputing closures initiated by
;;; the other party.
;;; WARNING: An agent, collaborating with the other party, could potentially
;;; steal your funds. Only register agents you trust.
;;; Returns `(ok true)`
(define-public (register-agent (agent principal))
  (ok (map-set agents tx-sender agent))
)

;;; Deregister agent
;;; Returns:
;;; - `(ok true)` if an agent had been registered
;;; - `(ok false)` if there was no agent registered
(define-public (deregister-agent)
  (ok (map-delete agents tx-sender))
)

;;; Deposit `amount` funds into an unfunded channel between `tx-sender` and
;;; `with` for FT `token` (`none` indicates STX). Create the channel if one
;;; does not already exist.
;;; Returns:
;;; - The channel key on success
;;;   ```
;;;   { token: (optional principal), principal-1: principal, principal-2: principal }
;;;   ```
;;; - `ERR_NOT_INITIALIZED` if the contract has not been initialized
;;; - `ERR_UNAPPROVED_TOKEN` if the token is not the correct token
;;; - `ERR_NONCE_TOO_LOW` if the nonce is less than the channel's saved nonce
;;; - `ERR_CLOSE_IN_PROGRESS` if a forced closure is in progress
;;; - `ERR_ALREADY_FUNDED` if the channel has already been funded
(define-public (fund-channel (token (optional <sip-010>)) (amount uint) (with principal) (nonce uint))
  (begin
    (try! (check-token token))

    (let
      (
        (channel-key (try! (get-channel-key (contract-of-optional token) tx-sender with)))
        (existing-channel (map-get? channels channel-key))
        (channel
          (match
            existing-channel
            ch
            ch
            { balance-1: u0, balance-2: u0, expires-at: MAX_HEIGHT, nonce: nonce, closer: none }
          )
        )
        (updated-channel (try! (increase-sender-balance channel-key channel token amount)))
        (closer (get closer channel))
      )

      ;; If there was an existing channel, the new nonce must be equal or greater
      (asserts! (>= (get nonce channel) nonce) ERR_NONCE_TOO_LOW)

      ;; A forced closure must not be in progress
      (asserts! (is-none closer) ERR_CLOSE_IN_PROGRESS)

      ;; Only fund a channel with a 0 balance for the sender can be funded. After
      ;; the channel is initially funded, additional funds must use the `deposit`
      ;; function, which requires signatures from both parties.
      (asserts! (not (is-funded tx-sender channel-key channel)) ERR_ALREADY_FUNDED)

      (map-set channels channel-key updated-channel)

      ;; Emit an event
      (print {
        event: "fund-channel",
        channel-key: channel-key,
        channel: updated-channel,
        sender: tx-sender,
        amount: amount,
      })
      (ok channel-key)
    )
  )
)

;;; Cooperatively close the channel, with authorization from both parties.
;;; Returns:
;;; - `(ok true)` on success
;;; - `ERR_NO_SUCH_CHANNEL` if the channel does not exist
;;; - `ERR_NONCE_TOO_LOW` if the nonce is less than the channel's saved nonce
;;; - `ERR_INVALID_TOTAL_BALANCE` if the total balance of the channel is not
;;;   equal to the sum of the balances provided
;;; - `ERR_INVALID_SENDER_SIGNATURE` if the sender's signature is invalid
;;; - `ERR_INVALID_OTHER_SIGNATURE` if the other party's signature is invalid
(define-public (close-channel
    (token (optional <sip-010>))
    (with principal)
    (my-balance uint)
    (their-balance uint)
    (my-signature (buff 65))
    (their-signature (buff 65))
    (nonce uint)
  )
  (let
    (
      (channel-key (try! (get-channel-key (contract-of-optional token) tx-sender with)))
      (channel (unwrap! (map-get? channels channel-key) ERR_NO_SUCH_CHANNEL))
      (channel-nonce (get nonce channel))
      (principal-1 (get principal-1 channel-key))
      (balance-1 (if (is-eq tx-sender principal-1) my-balance their-balance))
      (balance-2 (if (is-eq tx-sender principal-1) their-balance my-balance))
      (updated-channel {
        balance-1: balance-1,
        balance-2: balance-2,
        expires-at: MAX_HEIGHT,
        nonce: nonce,
        closer: none
      })
    )

    ;; The nonce must be greater than the channel's saved nonce
    (asserts! (> nonce channel-nonce) ERR_NONCE_TOO_LOW)

    ;; If the total balance of the channel is not equal to the sum of the
    ;; balances provided, the channel close is invalid.
    (asserts!
      (is-eq
        (+ my-balance their-balance)
        (+ (get balance-1 channel) (get balance-2 channel))
      )
      ERR_INVALID_TOTAL_BALANCE
    )

    ;; Verify the signatures of the two parties.
    (try!
      (verify-signatures
        my-signature
        tx-sender
        their-signature
        with
        channel-key
        balance-1
        balance-2
        nonce
        ACTION_CLOSE
        tx-sender
        none
      )
    )

    ;; Reset the channel in the map.
    (reset-channel channel-key nonce)

    ;; Emit an event
    (print {
      event: "close-channel",
      channel-key: channel-key,
      channel: updated-channel,
      sender: tx-sender,
    })

    ;; Pay out the balances.
    (payout token tx-sender with my-balance their-balance)
  )
)

;;; Close the channel and return the original balances to both participants.
;;; This initiates a waiting period, giving the other party the opportunity to
;;; dispute the closing of the channel, by calling `dispute-closure` and
;;; providing signatures proving a transfer.
;;; Returns:
;;; - `(ok expires-at)` on success, where `expires-at` is the block height at
;;;   which the channel can be finalized if it has not been disputed.
;;; - `ERR_NO_SUCH_CHANNEL` if the channel does not exist
;;; - `ERR_CLOSE_IN_PROGRESS` if a forced closure is already in progress
(define-public (force-cancel (token (optional <sip-010>)) (with principal))
  (let
    (
      (channel-key (try! (get-channel-key (contract-of-optional token) tx-sender with)))
      (channel (unwrap! (map-get? channels channel-key) ERR_NO_SUCH_CHANNEL))
      (closer (get closer channel))
      (expires-at (+ burn-block-height WAITING_PERIOD))
    )
    ;; A forced closure must not be in progress
    (asserts! (is-none closer) ERR_CLOSE_IN_PROGRESS)

    ;; Set the waiting period for this channel.
    (map-set
      channels
      channel-key
      (merge channel { expires-at: expires-at, closer: (some tx-sender) })
    )

    ;; Emit an event
    (print {
      event: "force-cancel",
      channel-key: channel-key,
      channel: channel,
      sender: tx-sender,
    })

    (ok expires-at)
  )
)

;;; Close the channel using signatures from the most recent transfer.
;;; This initiates a waiting period, giving the other party the opportunity to
;;; dispute the closing of the channel, by calling `dispute-closure` and
;;; providing signatures with a later nonce.
;;; Returns:
;;; - `(ok expires-at)` on success, where `expires-at` is the block height at
;;;   which the channel can be finalized if it has not been disputed.
;;; - `ERR_NO_SUCH_CHANNEL` if the channel does not exist
;;; - `ERR_CLOSE_IN_PROGRESS` if a forced closure is already in progress
;;; - `ERR_NONCE_TOO_LOW` if the nonce is less than the channel's saved nonce
;;; - `ERR_INVALID_TOTAL_BALANCE` if the total balance of the channel is not
;;;   equal to the sum of the balances provided
;;; - `ERR_INVALID_SENDER_SIGNATURE` if the sender's signature is invalid
;;; - `ERR_INVALID_OTHER_SIGNATURE` if the other party's signature is invalid
(define-public (force-close
    (token (optional <sip-010>))
    (with principal)
    (my-balance uint)
    (their-balance uint)
    (my-signature (buff 65))
    (their-signature (buff 65))
    (nonce uint)
    (action uint)
    (actor principal)
    (secret (optional (buff 32)))
  )
  (let
    (
      (channel-key (try! (get-channel-key (contract-of-optional token) tx-sender with)))
      (channel (unwrap! (map-get? channels channel-key) ERR_NO_SUCH_CHANNEL))
      (channel-nonce (get nonce channel))
      (closer (get closer channel))
    )
    ;; Exit early if a forced closure is already in progress.
    (asserts! (is-none closer) ERR_CLOSE_IN_PROGRESS)

    ;; Exit early if the nonce is less than the channel's nonce
    (asserts! (> nonce channel-nonce) ERR_NONCE_TOO_LOW)

    ;; If the total balance of the channel is not equal to the sum of the
    ;; balances provided, the channel close is invalid.
    (asserts!
      (is-eq
        (+ my-balance their-balance)
        (+ (get balance-1 channel) (get balance-2 channel))
      )
      ERR_INVALID_TOTAL_BALANCE
    )

    (let
      (
        (expires-at (+ burn-block-height WAITING_PERIOD))
        (principal-1 (get principal-1 channel-key))
        (balance-1 (if (is-eq tx-sender principal-1) my-balance their-balance))
        (balance-2 (if (is-eq tx-sender principal-1) their-balance my-balance))
        (new-channel {
          balance-1: balance-1,
          balance-2: balance-2,
          expires-at: expires-at,
          closer: (some tx-sender),
          nonce: nonce
        })
      )

      ;; Verify the signatures of the two parties.
      (try!
        (verify-signatures
          my-signature
          tx-sender
          their-signature
          with
          channel-key
          balance-1
          balance-2
          nonce
          action
          actor
          secret
        )
      )

      ;; Set the waiting period for this channel.
      (map-set
        channels
        channel-key
        new-channel
      )

      ;; Emit an event
      (print {
        event: "force-close",
        channel-key: channel-key,
        channel: new-channel,
        sender: tx-sender,
      })

      (ok expires-at)
    )
  )
)

;;; Dispute the closing of a channel that has been closed early by submitting a
;;; dispute within the waiting period. If the dispute is valid, the channel
;;; will be closed and the new balances will be paid out to the appropriate
;;; parties.
;;; Returns:
;;; - `(ok false)` on success if the channel's token was STX
;;; - `(ok true)` on success if the channel's token was a SIP-010 token
;;; - `ERR_NO_SUCH_CHANNEL` if the channel does not exist
;;; - `ERR_NO_CLOSE_IN_PROGRESS` if a forced closure is not in progress
;;; - `ERR_SELF_DISPUTE` if the sender is disputing their own force closure
;;; - `ERR_CHANNEL_EXPIRED` if the channel has already expired
;;; - `ERR_NONCE_TOO_LOW` if the nonce is less than the channel's saved nonce
;;; - `ERR_INVALID_TOTAL_BALANCE` if the total balance of the channel is not
;;;   equal to the sum of the balances provided
;;; - `ERR_INVALID_SENDER_SIGNATURE` if the sender's signature is invalid
;;; - `ERR_INVALID_OTHER_SIGNATURE` if the other party's signature is invalid
;;; - `ERR_WITHDRAWAL_FAILED` if the withdrawal fails
(define-public (dispute-closure
    (token (optional <sip-010>))
    (with principal)
    (my-balance uint)
    (their-balance uint)
    (my-signature (buff 65))
    (their-signature (buff 65))
    (nonce uint)
    (action uint)
    (actor principal)
    (secret (optional (buff 32)))
  )
  (dispute-closure-inner
    tx-sender
    token
    with
    my-balance
    their-balance
    my-signature
    their-signature
    nonce
    action
    actor
    secret
  )
)

;;; As an agent of `for`, dispute the closing of a channel that has been closed
;;; early by submitting a dispute within the waiting period. If the dispute is
;;; valid, the channel will be closed and the new balances will be paid out to
;;; the appropriate parties.
;;; Returns:
;;; - `(ok false)` on success if the channel's token was STX
;;; - `(ok true)` on success if the channel's token was a SIP-010 token
;;; - `ERR_UNAUTHORIZED` if the sender is not an agent of `for`
;;; - `ERR_NO_SUCH_CHANNEL` if the channel does not exist
;;; - `ERR_NO_CLOSE_IN_PROGRESS` if a forced closure is not in progress
;;; - `ERR_SELF_DISPUTE` if the sender is disputing their own force closure
;;; - `ERR_CHANNEL_EXPIRED` if the channel has already expired
;;; - `ERR_NONCE_TOO_LOW` if the nonce is less than the channel's saved nonce
;;; - `ERR_INVALID_TOTAL_BALANCE` if the total balance of the channel is not
;;;   equal to the sum of the balances provided
;;; - `ERR_INVALID_SENDER_SIGNATURE` if the sender's signature is invalid
;;; - `ERR_INVALID_OTHER_SIGNATURE` if the other party's signature is invalid
;;; - `ERR_WITHDRAWAL_FAILED` if the withdrawal fails
(define-public (agent-dispute-closure
    (for principal)
    (token (optional <sip-010>))
    (with principal)
    (my-balance uint)
    (their-balance uint)
    (my-signature (buff 65))
    (their-signature (buff 65))
    (nonce uint)
    (action uint)
    (actor principal)
    (secret (optional (buff 32)))
  )
  (let
    (
      (agent (unwrap! (map-get? agents for) ERR_UNAUTHORIZED))
    )
    (asserts! (is-eq tx-sender agent) ERR_UNAUTHORIZED)
    (dispute-closure-inner
      for
      token
      with
      my-balance
      their-balance
      my-signature
      their-signature
      nonce
      action
      actor
      secret
    )
  )
)

;;; Close the channel after a forced cancel or closure, once the required
;;; number of blocks have passed.
;;; Returns:
;;; - `(ok false)` on success if the channel's token was STX
;;; - `(ok true)` on success if the channel's token was a SIP-010 token
;;; - `ERR_NO_SUCH_CHANNEL` if the channel does not exist
;;; - `ERR_NO_CLOSE_IN_PROGRESS` if a forced closure is not in progress
;;; - `ERR_NOT_EXPIRED` if the waiting period has not passed
;;; - `ERR_WITHDRAWAL_FAILED` if the withdrawal fails
(define-public (finalize  (token (optional <sip-010>)) (with principal))
  (let
    (
      (channel-key (try! (get-channel-key (contract-of-optional token) tx-sender with)))
      (channel (unwrap! (map-get? channels channel-key) ERR_NO_SUCH_CHANNEL))
      (closer (get closer channel))
      (expires-at (get expires-at channel))
    )
    ;; A forced closure must be in progress
    (asserts! (is-some closer) ERR_NO_CLOSE_IN_PROGRESS)

    ;; The waiting period must have passed
    (asserts! (> burn-block-height expires-at) ERR_NOT_EXPIRED)

    ;; Reset the channel in the map.
    (reset-channel channel-key (get nonce channel))

    ;; Emit an event
    (print {
      event: "finalize",
      channel-key: channel-key,
      channel: channel,
      sender: tx-sender,
    })

    (payout
      token
      (get principal-1 channel-key)
      (get principal-2 channel-key)
      (get balance-1 channel)
      (get balance-2 channel)
    )
  )
)

;;; Deposit `amount` additional funds into an existing channel between
;;; `tx-sender` and `with` for FT `token` (`none` indicates STX). Signatures
;;; must confirm the deposit and the new balances.
;;; Returns:
;;; -`(ok channel-key)` on success
;;; - `ERR_NO_SUCH_CHANNEL` if the channel does not exist
;;; - `ERR_CLOSE_IN_PROGRESS` if a forced closure is in progress
;;; - `ERR_NONCE_TOO_LOW` if the nonce is less than the channel's saved nonce
;;; - `ERR_INVALID_TOTAL_BALANCE` if the total balance of the channel is not
;;;   equal to the sum of the balances provided and the deposit amount
;;; - `ERR_INVALID_SENDER_SIGNATURE` if the sender's signature is invalid
;;; - `ERR_INVALID_OTHER_SIGNATURE` if the other party's signature is invalid
;;; - `ERR_DEPOSIT_FAILED` if the deposit fails
(define-public (deposit
    (amount uint)
    (token (optional <sip-010>))
    (with principal)
    (my-balance uint)
    (their-balance uint)
    (my-signature (buff 65))
    (their-signature (buff 65))
    (nonce uint)
  )
  (let
    (
      (channel-key (try! (get-channel-key (contract-of-optional token) tx-sender with)))
      (channel (unwrap! (map-get? channels channel-key) ERR_NO_SUCH_CHANNEL))
      (channel-nonce (get nonce channel))
      (closer (get closer channel))
      (principal-1 (get principal-1 channel-key))
      (balance-1 (if (is-eq tx-sender principal-1) my-balance their-balance))
      (balance-2 (if (is-eq tx-sender principal-1) their-balance my-balance))
      (updated-channel
        (merge
          channel
          {
            balance-1: balance-1,
            balance-2: balance-2,
            nonce: nonce
          }
        )
      )
    )
    ;; A forced closure must not be in progress
    (asserts! (is-none closer) ERR_CLOSE_IN_PROGRESS)

    ;; Nonce must be greater than the channel nonce
    (asserts! (> nonce channel-nonce) ERR_NONCE_TOO_LOW)

    ;; If the new balance of the channel is not equal to the sum of the
    ;; existing balances and the deposit amount, the deposit is invalid.
    (asserts!
      (is-eq
        (+ my-balance their-balance)
        (+ (get balance-1 channel) (get balance-2 channel) amount)
      )
      ERR_INVALID_TOTAL_BALANCE
    )

    ;; Verify the signatures of the two parties.
    (try!
      (verify-signatures
        my-signature
        tx-sender
        their-signature
        with
        channel-key
        balance-1
        balance-2
        nonce
        ACTION_DEPOSIT
        tx-sender
        none
      )
    )

    ;; Perform the deposit
    (try! (increase-sender-balance channel-key channel token amount))

    (map-set
      channels
      channel-key
      updated-channel
    )
    (print {
      event: "deposit",
      channel-key: channel-key,
      channel: updated-channel,
      sender: tx-sender,
      amount: amount,
      my-signature: my-signature,
      their-signature: their-signature,
    })
    (ok channel-key)
  )
)

;;; Withdrawal `amount` funds from an existing channel between `tx-sender` and
;;; `with` for FT `token` (`none` indicates STX). Signatures must confirm the
;;; withdrawal and the new balances.
;;; Returns:
;;; -`(ok channel-key)` on success
;;; - `ERR_NO_SUCH_CHANNEL` if the channel does not exist
;;; - `ERR_CLOSE_IN_PROGRESS` if a forced closure is in progress
;;; - `ERR_NONCE_TOO_LOW` if the nonce is less than the channel's saved nonce
;;; - `ERR_INVALID_TOTAL_BALANCE` if the total balance of the channel is not
;;;   equal to the sum of the balances provided and the deposit amount
;;; - `ERR_INVALID_SENDER_SIGNATURE` if the sender's signature is invalid
;;; - `ERR_INVALID_OTHER_SIGNATURE` if the other party's signature is invalid
;;; - `ERR_WITHDRAWAL_FAILED` if the deposit fails
(define-public (withdraw
    (amount uint)
    (token (optional <sip-010>))
    (with principal)
    (my-balance uint)
    (their-balance uint)
    (my-signature (buff 65))
    (their-signature (buff 65))
    (nonce uint)
  )
  (let
    (
      (channel-key (try! (get-channel-key (contract-of-optional token) tx-sender with)))
      (channel (unwrap! (map-get? channels channel-key) ERR_NO_SUCH_CHANNEL))
      (channel-nonce (get nonce channel))
      (closer (get closer channel))
      (principal-1 (get principal-1 channel-key))
      (balance-1 (if (is-eq tx-sender principal-1) my-balance their-balance))
      (balance-2 (if (is-eq tx-sender principal-1) their-balance my-balance))
      (updated-channel
        (merge
          channel
          {
            balance-1: balance-1,
            balance-2: balance-2,
            nonce: nonce
          }
        )
      )
    )

    ;; A forced closure must not be in progress
    (asserts! (is-none closer) ERR_CLOSE_IN_PROGRESS)

    ;; Nonce must be greater than the channel nonce
    (asserts! (> nonce channel-nonce) ERR_NONCE_TOO_LOW)

    ;; Withdrawal amount cannot be greater than the total channel balance
    (asserts!
      (> (+ (get balance-1 channel) (get balance-2 channel)) amount)
      ERR_INVALID_WITHDRAWAL
    )

    ;; If the new balance of the channel is not equal to the sum of the
    ;; prior balances minus the withdraw amount, the withdrawal is invalid.
    (asserts!
      (is-eq
        (+ my-balance their-balance)
        (- (+ (get balance-1 channel) (get balance-2 channel)) amount)
      )
      ERR_INVALID_TOTAL_BALANCE
    )

    ;; Verify the signatures of the two parties.
    (try!
      (verify-signatures
        my-signature
        tx-sender
        their-signature
        with
        channel-key
        balance-1
        balance-2
        nonce
        ACTION_WITHDRAWAL
        tx-sender
        none
      )
    )

    ;; Perform the withdraw
    (try! (execute-withdraw token amount))

    (map-set
      channels
      channel-key
      updated-channel
    )
    (print {
      event: "withdraw",
      channel-key: channel-key,
      channel: updated-channel,
      sender: tx-sender,
      amount: amount,
      my-signature: my-signature,
      their-signature: their-signature,
    })
    (ok channel-key)
  )
)

;; Read Only Functions
;;

;;; Get the current balances of the channel between `tx-sender` and `with` for
;;; token `token` (`none` indicates STX).
;;; Returns:
;;; - The channel data tuple on success, with type
;;;   ```
;;;   (some {
;;;     balance-1: uint,
;;;     balance-2: uint,
;;;     expires-at: uint,
;;;     nonce: uint,
;;;     closer: (optional principal)
;;;   })
;;;   ```
;;; - `none` if the channel does not exist
(define-read-only (get-channel (token (optional principal)) (with principal))
  (match (get-channel-key token tx-sender with)
    channel-key (map-get? channels channel-key)
    e none
  )
)

;;; Generate a hash of the structured data for a channel.
;;; Returns:
;;; - (ok (buff 32)) with the hash of the structured data on success
;;; - `ERR_CONSENSUS_BUFF` if the structured data cannot be converted to a
;;;   consensus buff
(define-read-only (make-structured-data-hash
    (channel-key { token: (optional principal), principal-1: principal, principal-2: principal })
    (balance-1 uint)
    (balance-2 uint)
    (nonce uint)
    (action uint)
    (actor principal)
    (hashed-secret (optional (buff 32)))
  )
  (let
    (
      (structured-data (merge
        channel-key
        {
          balance-1: balance-1,
          balance-2: balance-2,
          nonce: nonce,
          action: action,
          actor: actor,
          hashed-secret: hashed-secret,
        }
      ))
      (data-hash (sha256 (unwrap! (to-consensus-buff? structured-data) ERR_CONSENSUS_BUFF)))
    )
    (ok (sha256 (concat structured-data-header data-hash)))
  )
)

;;; Validates that `signature` is a valid signature from `signer for the
;;; structured data constructed from the other arguments.
;;; Returns:
;;; - `true` if the signature is valid.
;;; - `false` if the signature is invalid.
(define-read-only (verify-signature
    (signature (buff 65))
    (signer principal)
    (channel-key { token: (optional principal), principal-1: principal, principal-2: principal })
    (balance-1 uint)
    (balance-2 uint)
    (nonce uint)
    (action uint)
    (actor principal)
    (hashed-secret (optional (buff 32)))
  )
  (let ((hash (unwrap! (make-structured-data-hash
      channel-key
      balance-1
      balance-2
      nonce
      action
      actor
      hashed-secret
    ) false)))
    (verify-hash-signature hash signature signer actor)
  )
)

;;; Validates that `signature-1` and `signature-2` are valid signature from
;;; `signer-1` and `signer-2`, respectively, for the structured data
;;; constructed from the other arguments.
;;; Returns:
;;; - `(ok true)` if both signatures are valid.
;;; - `ERR_INVALID_SENDER_SIGNATURE` if the first signature is invalid.
;;; - `ERR_INVALID_OTHER_SIGNATURE` if the second signature is invalid.
(define-read-only (verify-signatures
    (signature-1 (buff 65))
    (signer-1 principal)
    (signature-2 (buff 65))
    (signer-2 principal)
    (channel-key { token: (optional principal), principal-1: principal, principal-2: principal })
    (balance-1 uint)
    (balance-2 uint)
    (nonce uint)
    (action uint)
    (actor principal)
    (secret (optional (buff 32)))
  )
  (let (
    (hashed-secret (match secret s (some (sha256 s)) none))
    (hash (try! (make-structured-data-hash
      channel-key
      balance-1
      balance-2
      nonce
      action
      actor
      hashed-secret
    ))))
    (asserts! (verify-hash-signature hash signature-1 signer-1 actor) ERR_INVALID_SENDER_SIGNATURE)
    (asserts! (verify-hash-signature hash signature-2 signer-2 actor) ERR_INVALID_OTHER_SIGNATURE)
    (ok true)
  )
)

;; Private Functions
;;

;;; Given an optional trait, return an optional principal for the trait.
(define-private (contract-of-optional (trait (optional <sip-010>)))
  (match trait
    t
    (some (contract-of t))
    none
  )
)

;;; Given two principals, return the key for the channel between these two principals.
;;; The key is a map with two keys: principal-1 and principal-2, where principal-1 is the principal
;;; with the lower consensus representation.
(define-private (get-channel-key (token (optional principal)) (principal-1 principal) (principal-2 principal))
  (let
    (
      (p1 (unwrap! (to-consensus-buff? principal-1) ERR_INVALID_PRINCIPAL))
      (p2 (unwrap! (to-consensus-buff? principal-2) ERR_INVALID_PRINCIPAL))
    )
    (ok (if (< p1 p2)
      { token: token, principal-1: principal-1, principal-2: principal-2 }
      { token: token, principal-1: principal-2, principal-2: principal-1 }
    ))
  )
)

;;; Transfer `amount` from `tx-sender` to the contract and update the channel
;;; balances.
(define-private (increase-sender-balance
    (channel-key { token: (optional principal), principal-1: principal, principal-2: principal })
    (channel { balance-1: uint, balance-2: uint, expires-at: uint, nonce: uint, closer: (optional principal) })
    (token (optional <sip-010>))
    (amount uint)
  )
  (begin
    (match token
      t
      (unwrap! (contract-call? t transfer amount tx-sender (as-contract tx-sender) none) ERR_DEPOSIT_FAILED)
      (unwrap! (stx-transfer? amount tx-sender (as-contract tx-sender)) ERR_DEPOSIT_FAILED)
    )
    (ok
      (if (is-eq tx-sender (get principal-1 channel-key))
        (merge channel { balance-1: (+ (get balance-1 channel) amount) })
        (merge channel { balance-2: (+ (get balance-2 channel) amount) })
      )
    )
  )
)

;;; Transfer `amount` from the contract to `tx-sender`.
;;; Note that this function assumes that the token contract has already been
;;; verified (by finding the corresponding channel).
(define-private (execute-withdraw
    (token (optional <sip-010>))
    (amount uint)
  )
  (let ((sender tx-sender))
    (unwrap!
      (match token
        t
        (as-contract (contract-call? t transfer amount tx-sender sender none))
        (as-contract (stx-transfer? amount tx-sender sender))
      )
      ERR_WITHDRAWAL_FAILED
    )
    (ok true)
  )
)

;;; Inner function called by `dispute-closure` and `agent-dispute-closure`.
(define-private (dispute-closure-inner
    (for principal)
    (token (optional <sip-010>))
    (with principal)
    (my-balance uint)
    (their-balance uint)
    (my-signature (buff 65))
    (their-signature (buff 65))
    (nonce uint)
    (action uint)
    (actor principal)
    (secret (optional (buff 32)))
  )
  (let
    (
      (channel-key (try! (get-channel-key (contract-of-optional token) for with)))
      (channel (unwrap! (map-get? channels channel-key) ERR_NO_SUCH_CHANNEL))
      (expires-at (get expires-at channel))
      (channel-nonce (get nonce channel))
      (closer (unwrap! (get closer channel) ERR_NO_CLOSE_IN_PROGRESS))
      (principal-1 (get principal-1 channel-key))
      (balance-1 (if (is-eq for principal-1) my-balance their-balance))
      (balance-2 (if (is-eq for principal-1) their-balance my-balance))
    )
    (asserts! (not (is-eq for closer)) ERR_SELF_DISPUTE)
    (asserts! (< burn-block-height expires-at) ERR_CHANNEL_EXPIRED)
    (asserts! (> nonce channel-nonce) ERR_NONCE_TOO_LOW)

    ;; If the total balance of the channel is not equal to the sum of the
    ;; balances provided, the channel close is invalid.
    (asserts!
      (is-eq
        (+ my-balance their-balance)
        (+ (get balance-1 channel) (get balance-2 channel))
      )
      ERR_INVALID_TOTAL_BALANCE
    )

    (let
      (
        (updated-channel {
          balance-1: balance-1,
          balance-2: balance-2,
          expires-at: MAX_HEIGHT,
          nonce: nonce,
          closer: none
        })
      )

      ;; Verify the signatures of the two parties.
      (try!
        (verify-signatures
          my-signature
          for
          their-signature
          with
          channel-key
          balance-1
          balance-2
          nonce
          action
          actor
          secret
        )
      )

      ;; Reset the channel in the map.
      (reset-channel channel-key nonce)

      ;; Emit an event
      (print {
        event: "dispute-closure",
        channel-key: channel-key,
        channel: updated-channel,
        sender: for,
      })

      ;; Pay out the balances.
      (payout token for with my-balance their-balance)
    )
  )
)

;;; Check if the balance of `account` in the channel is greater than 0.
(define-private (is-funded
    (account principal)
    (channel-key { token: (optional principal), principal-1: principal, principal-2: principal })
    (channel { balance-1: uint, balance-2: uint, expires-at: uint, nonce: uint, closer: (optional principal) })
  )
  (or
    (and (is-eq account (get principal-1 channel-key)) (> (get balance-1 channel) u0))
    (and (is-eq account (get principal-2 channel-key)) (> (get balance-2 channel) u0))
  )
)

;;; Payout the balances. Handles both SIP-010 tokens and STX.
;;; Returns `(ok true)` upons successfully paying out SIP-010 balances and
;;; `(ok false)` upon successfully paying out STX balances.
(define-private (payout
    (token (optional <sip-010>))
    (principal-1 principal)
    (principal-2 principal)
    (balance-1 uint)
    (balance-2 uint)
  )
  (begin
    (try! (transfer token principal-1 balance-1))
    (transfer token principal-2 balance-2)
  )
)

;;; Transfer `amount` of `token` to `addr`. Handles both SIP-010 tokens and STX.
(define-private (transfer (token (optional <sip-010>)) (addr principal) (amount uint))
  (if (is-eq amount u0)
    ;; Don't try to transfer 0, this will cause an error
    (ok (is-some token))
    (begin
      (match token
        t (unwrap! (as-contract (contract-call? t transfer amount tx-sender addr none)) ERR_WITHDRAWAL_FAILED)
        (unwrap! (as-contract (stx-transfer? amount tx-sender addr)) ERR_WITHDRAWAL_FAILED)
      )
      (ok (is-some token))
    )
  )
)

;;; Reset the channel so that it is closed but retains the last nonce.
(define-private (reset-channel
    (channel-key { token: (optional principal), principal-1: principal, principal-2: principal })
    (nonce uint)
  )
  (map-set
    channels
    channel-key
    { balance-1: u0, balance-2: u0, expires-at: MAX_HEIGHT, nonce: nonce, closer: none }
  )
)

;;; Verify a signature for a hash.
;;; Returns `true` if the signature is valid, `false` otherwise.
(define-private (verify-hash-signature
    (hash (buff 32))
    (signature (buff 65))
    (signer principal)
    (actor principal)
  )
  (or
    (is-eq (principal-of? (unwrap! (secp256k1-recover? hash signature) false)) (ok signer))
    ;; If the signer is not the actor, then the agent can sign for the signer.
    (and
      (not (is-eq signer actor))
      (match (map-get? agents signer)
        agent (is-eq (principal-of? (unwrap! (secp256k1-recover? hash signature) false)) (ok agent))
        false
      )
    )
  )
)

;;; Check that the contract has been initialized and `token` is the supported token.
(define-private (check-token (token (optional <sip-010>)))
  (begin
    ;; Ensure that the contract has been initialized
    (asserts! (var-get initialized) ERR_NOT_INITIALIZED)

    ;; Verify that this is the supported token
    (asserts! (is-eq (contract-of-optional token) (var-get supported-token)) ERR_UNAPPROVED_TOKEN)

    (ok true)
  )
)