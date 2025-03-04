
;; title: stackflow
;; version: 0.1.0
;; summary: Stackflow is a payment channel network built on Stacks that enables
;;   off-chain, non-custodial, high-speed payments between users and is
;;   designed to be simple, secure, and efficient. It supports payments in STX
;;   or approved SIP-010 fungible tokens.


(use-trait sip-010 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(define-constant contract-deployer tx-sender)
(define-constant MAX_HEIGHT u340282366920938463463374607431768211455)
(define-constant WAITING_PERIOD u144) ;; 24 hours in blocks

;; Constants for SIP-018 structured data
(define-constant structured-data-prefix 0x534950303138)
(define-constant message-domain-hash (sha256 (unwrap-panic (to-consensus-buff?
	{
		name: "StackFlow",
		version: "0.1.0",
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
(define-constant ERR_INCORRECT_NONCE (err u118))
(define-constant ERR_NOT_EXPIRED (err u119))

;;; List of allowed SIP-010 tokens as set by the owner of the contract.
;;; This is required since SIP-010 tokens are not guaranteed not to have side-
;;; effects other than those defined in the SIP-010 standard. For example, an
;;; untrusted token could transfer funds from the contract when called within
;;; an `as-contract` expression.
(define-map allowed-sip-010s principal bool)

;;; Map tracking the initial balances in channels between two principals for a
;;; given token.
(define-map
  channels
  { token: (optional principal), principal-1: principal, principal-2: principal }
  { balance-1: uint, balance-2: uint, expires-at: uint, nonce: uint, closer: (optional principal) }
)

;; Public Functions
;;

;;; As the owner of this contract, add a SIP-010 token to the list of allowed
;;; tokens.
(define-public (add-allowed-sip-010 (token principal))
  (begin
    (asserts! (is-eq contract-caller contract-deployer) ERR_UNAUTHORIZED)
    (ok (map-set allowed-sip-010s token true))
  )
)

;;; As the owner of this contract, remove a SIP-010 token from the list of
;;; allowed tokens.
(define-public (remove-allowed-sip-010 (token principal))
  (begin
    (asserts! (is-eq contract-caller contract-deployer) ERR_UNAUTHORIZED)
    (ok (map-set allowed-sip-010s token false))
  )
)

;;; Deposit `amount` funds into an unfunded channel between `tx-sender` and
;;; `with` for FT `token` (`none` indicates STX). Create the channel if one
;;; does not already exist.
;;; Returns the channel key on success.
(define-public (fund-channel (token (optional <sip-010>)) (amount uint) (with principal) (nonce uint))
  (begin
    ;; If a SIP-010 token is specified, it must be in the allowed list
    (match token
      t (asserts! (is-allowed-token (contract-of t)) ERR_UNAPPROVED_TOKEN)
      true
    )

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
      (asserts! (>= (get nonce channel) nonce) ERR_INCORRECT_NONCE)

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
      (closer (get closer channel))
      (data (make-channel-data channel-key my-balance their-balance nonce ACTION_CLOSE none none))
      (data-hash (sha256 (unwrap! (to-consensus-buff? data) ERR_CONSENSUS_BUFF)))
      (input (sha256 (concat structured-data-header data-hash)))
      (sender tx-sender)
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
    (asserts! (verify-signature input my-signature tx-sender) ERR_INVALID_SENDER_SIGNATURE)
    (asserts! (verify-signature input their-signature with) ERR_INVALID_OTHER_SIGNATURE)

    ;; Reset the channel in the map.
    (reset-channel channel-key nonce)

    ;; Emit an event
    (print {
      event: "close-channel",
      channel-key: channel-key,
      channel: channel,
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
(define-public (force-close
    (token (optional <sip-010>))
    (with principal)
    (my-balance uint)
    (their-balance uint)
    (my-signature (buff 65))
    (their-signature (buff 65))
    (nonce uint)
    (action uint)
    (actor (optional principal))
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
        (data (make-channel-data channel-key my-balance their-balance nonce action actor secret))
        (data-hash (sha256 (unwrap! (to-consensus-buff? data) ERR_CONSENSUS_BUFF)))
        (input (sha256 (concat structured-data-header data-hash)))
        (new-balances (if (is-eq tx-sender (get principal-1 channel-key))
          { balance-1: my-balance, balance-2: their-balance }
          { balance-1: their-balance, balance-2: my-balance }
        ))
        (new-channel (merge new-balances { expires-at: expires-at, closer: (some tx-sender), nonce: nonce }))
      )

      ;; Verify the signatures of the two parties.
      (asserts! (verify-signature input my-signature tx-sender) ERR_INVALID_SENDER_SIGNATURE)
      (asserts! (verify-signature input their-signature with) ERR_INVALID_OTHER_SIGNATURE)

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
(define-public (dispute-closure
    (token (optional <sip-010>))
    (with principal)
    (my-balance uint)
    (their-balance uint)
    (my-signature (buff 65))
    (their-signature (buff 65))
    (nonce uint)
    (action uint)
    (actor (optional principal))
    (secret (optional (buff 32)))
  )
  (let
    (
      (channel-key (try! (get-channel-key (contract-of-optional token) tx-sender with)))
      (channel (unwrap! (map-get? channels channel-key) ERR_NO_SUCH_CHANNEL))
      (expires-at (get expires-at channel))
      (channel-nonce (get nonce channel))
      (closer (unwrap! (get closer channel) ERR_NO_CLOSE_IN_PROGRESS))
    )
    (asserts! (not (is-eq tx-sender closer)) ERR_SELF_DISPUTE)
    (asserts! (< burn-block-height expires-at) ERR_CHANNEL_EXPIRED)
    (asserts! (> nonce channel-nonce) ERR_NONCE_TOO_LOW)

    (let
      (
        (data (make-channel-data channel-key my-balance their-balance nonce action actor secret))
        (data-hash (sha256 (unwrap! (to-consensus-buff? data) ERR_CONSENSUS_BUFF)))
        (input (sha256 (concat structured-data-header data-hash)))
      )

      ;; Verify the signatures of the two parties.
      (asserts! (verify-signature input my-signature tx-sender) ERR_INVALID_SENDER_SIGNATURE)
      (asserts! (verify-signature input their-signature with) ERR_INVALID_OTHER_SIGNATURE)

      ;; Reset the channel in the map.
      (reset-channel channel-key nonce)

      ;; Emit an event
      (print {
        event: "dispute-closure",
        channel-key: channel-key,
        channel: channel,
        sender: tx-sender,
        sender-balance: my-balance,
        other-balance: their-balance,
      })

      ;; Pay out the balances.
      (payout token tx-sender with my-balance their-balance)
    )
  )
)

;;; Close the channel after a forced cancel or closure, once the required
;;; number of blocks have passed.
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
;;; Returns the channel key on success.
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
      (updated-channel (update-channel-tuple channel-key channel my-balance their-balance nonce))
      (data (make-channel-data channel-key my-balance their-balance nonce ACTION_DEPOSIT (some tx-sender) none))
      (data-hash (sha256 (unwrap! (to-consensus-buff? data) ERR_CONSENSUS_BUFF)))
      (input (sha256 (concat structured-data-header data-hash)))
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
    (asserts! (verify-signature input my-signature tx-sender) ERR_INVALID_SENDER_SIGNATURE)
    (asserts! (verify-signature input their-signature with) ERR_INVALID_OTHER_SIGNATURE)

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
    })
    (ok channel-key)
  )
)

;;; Withdrawal `amount` funds from an existing channel between `tx-sender` and
;;; `with` for FT `token` (`none` indicates STX). Signatures must confirm the
;;; withdrawal and the new balances.
;;; Returns the channel key on success.
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
      (updated-channel (update-channel-tuple channel-key channel my-balance their-balance nonce))
      (data (make-channel-data channel-key my-balance their-balance nonce ACTION_WITHDRAWAL (some tx-sender) none))
      (data-hash (sha256 (unwrap! (to-consensus-buff? data) ERR_CONSENSUS_BUFF)))
      (input (sha256 (concat structured-data-header data-hash)))
    )
    ;; A forced closure must not be in progress
    (asserts! (is-none closer) ERR_CLOSE_IN_PROGRESS)

    ;; Nonce must be greater than the channel nonce
    (asserts! (> nonce channel-nonce) ERR_NONCE_TOO_LOW)

    ;; Withdrawal amount cannot be greater than the total channel balance
    (asserts! (> (+ (get balance-1 channel) (get balance-2 channel)) amount) ERR_INVALID_WITHDRAWAL)

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
    (asserts! (verify-signature input my-signature tx-sender) ERR_INVALID_SENDER_SIGNATURE)
    (asserts! (verify-signature input their-signature with) ERR_INVALID_OTHER_SIGNATURE)

    ;; Perform the withdraw
    (try! (execute-withdraw token amount))

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
    })
    (ok channel-key)
  )
)

;; Read Only Functions
;;

;;; Get the current balances of the channel between `tx-sender` and `with` for
;;; token `token` (`none` indicates STX).
(define-read-only (get-channel (token (optional principal)) (with principal))
  (match (get-channel-key token tx-sender with)
    channel-key (map-get? channels channel-key)
    e none
  )
)

(define-read-only (verify-signature (hash (buff 32)) (signature (buff 65)) (signer principal))
	(is-eq (principal-of? (unwrap! (secp256k1-recover? hash signature) false)) (ok signer))
)

(define-read-only (verify-signed-structured-data (structured-data-hash (buff 32)) (signature (buff 65)) (signer principal))
	(verify-signature (sha256 (concat structured-data-header structured-data-hash)) signature signer)
)

(define-read-only (is-allowed-token (token principal))
  (match (map-get? allowed-sip-010s token)
    allowed allowed
    false
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

;;; Remove a principal from a list of principals.
;;; Note that this method seems strange, but it is more cost efficient than the
;;; alternatives (h/t unknown original creator of this technique).
(define-read-only (remove-principal-from-list (l (list 256 principal)) (to-remove principal))
  (map unwrap-panic_ (filter is-some_ (map cmp l 
    (list to-remove to-remove to-remove to-remove to-remove to-remove to-remove to-remove
          to-remove to-remove to-remove to-remove to-remove to-remove to-remove to-remove
          to-remove to-remove to-remove to-remove to-remove to-remove to-remove to-remove
          to-remove to-remove to-remove to-remove to-remove to-remove to-remove to-remove
          to-remove to-remove to-remove to-remove to-remove to-remove to-remove to-remove
          to-remove to-remove to-remove to-remove to-remove to-remove to-remove to-remove
          to-remove to-remove to-remove to-remove to-remove to-remove to-remove to-remove
          to-remove to-remove to-remove to-remove to-remove to-remove to-remove to-remove
          to-remove to-remove to-remove to-remove to-remove to-remove to-remove to-remove
          to-remove to-remove to-remove to-remove to-remove to-remove to-remove to-remove
          to-remove to-remove to-remove to-remove to-remove to-remove to-remove to-remove
          to-remove to-remove to-remove to-remove to-remove to-remove to-remove to-remove
          to-remove to-remove to-remove to-remove to-remove to-remove to-remove to-remove
          to-remove to-remove to-remove to-remove to-remove to-remove to-remove to-remove
          to-remove to-remove to-remove to-remove to-remove to-remove to-remove to-remove
          to-remove to-remove to-remove to-remove to-remove to-remove to-remove to-remove
          to-remove to-remove to-remove to-remove to-remove to-remove to-remove to-remove
          to-remove to-remove to-remove to-remove to-remove to-remove to-remove to-remove
          to-remove to-remove to-remove to-remove to-remove to-remove to-remove to-remove
          to-remove to-remove to-remove to-remove to-remove to-remove to-remove to-remove
          to-remove to-remove to-remove to-remove to-remove to-remove to-remove to-remove
          to-remove to-remove to-remove to-remove to-remove to-remove to-remove to-remove
          to-remove to-remove to-remove to-remove to-remove to-remove to-remove to-remove
          to-remove to-remove to-remove to-remove to-remove to-remove to-remove to-remove
          to-remove to-remove to-remove to-remove to-remove to-remove to-remove to-remove
          to-remove to-remove to-remove to-remove to-remove to-remove to-remove to-remove
          to-remove to-remove to-remove to-remove to-remove to-remove to-remove to-remove
          to-remove to-remove to-remove to-remove to-remove to-remove to-remove to-remove
          to-remove to-remove to-remove to-remove to-remove to-remove to-remove to-remove
          to-remove to-remove to-remove to-remove to-remove to-remove to-remove to-remove
          to-remove to-remove to-remove to-remove to-remove to-remove to-remove to-remove
          to-remove to-remove to-remove to-remove to-remove to-remove to-remove to-remove
    )
  )))
)
(define-private (unwrap-panic_ (x (optional principal))) (unwrap-panic x))
(define-private (cmp (x principal) (y principal)) (if (is-eq x y) none (some x)))
(define-private (is-some_ (i (optional principal))) (is-some i))

;;; Build up the structured data for a channel operation.
;;; The structured data is a map with the following keys:
;;; - token: the token used in the channel
;;; - principal-1: the first principal in the channel
;;; - principal-2: the second principal in the channel
;;; - balance-1: the balance of the first principal in the channel
;;; - balance-2: the balance of the second principal in the channel
;;; - nonce: the nonce for this channel data
;;; - action: the action being performed (e.g., "close")
;;; - actor: the principal performing the action
;;; - hashed-secret: the optional hashed secret for the channel operation
;;; This function assumes that the channel has already been validated to
;;; include these two principals.
(define-private (make-channel-data
    (channel-key { token: (optional principal), principal-1: principal, principal-2: principal })
    (my-balance uint)
    (their-balance uint)
    (nonce uint)
    (action uint)
    (actor (optional principal))
    (secret (optional (buff 32)))
  )
  (let
    (
      (balances (if (is-eq tx-sender (get principal-1 channel-key))
        { balance-1: my-balance, balance-2: their-balance }
        { balance-1: their-balance, balance-2: my-balance }
      ))
      (hashed-secret (match secret s (some (sha256 s)) none))
    )
    (merge
      (merge channel-key balances)
      {
        nonce: nonce,
        action: action,
        actor: actor,
        hashed-secret: hashed-secret,
      }
    )
  )
)

;;; Build up the channel tuple from its parts.
;;; This function updates the following keys of the tuple:
;;; - balance-1: the balance of the first principal in the channel
;;; - balance-2: the balance of the second principal in the channel
;;; - nonce: the nonce for this channel data
;;; This function assumes that the channel has already been validated to
;;; include these two principals.
(define-private (update-channel-tuple
    (channel-key { token: (optional principal), principal-1: principal, principal-2: principal })
    (existing { balance-1: uint, balance-2: uint, expires-at: uint, nonce: uint, closer: (optional principal) })
    (my-balance uint)
    (their-balance uint)
    (nonce uint)
  )
  (let
    (
      (balances (if (is-eq tx-sender (get principal-1 channel-key))
        { balance-1: my-balance, balance-2: their-balance }
        { balance-1: their-balance, balance-2: my-balance }
      ))
    )
    (merge (merge existing balances) { nonce: nonce })
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
  (match token
    t
    (begin
      (unwrap! (as-contract (contract-call? t transfer balance-1 tx-sender principal-1 none)) ERR_WITHDRAWAL_FAILED)
      (unwrap! (as-contract (contract-call? t transfer balance-2 tx-sender principal-2 none)) ERR_WITHDRAWAL_FAILED)
      (ok true)
    )
    (begin
      (unwrap! (as-contract (stx-transfer? balance-1 tx-sender principal-1)) ERR_WITHDRAWAL_FAILED)
      (unwrap! (as-contract (stx-transfer? balance-2 tx-sender principal-2)) ERR_WITHDRAWAL_FAILED)
      (ok false)
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
