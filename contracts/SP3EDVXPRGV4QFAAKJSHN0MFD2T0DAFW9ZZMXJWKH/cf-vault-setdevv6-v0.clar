;; This is a vault contract. It is the only contract needed per client per chain & is
;; therefore used as a universal address. It functions by allow a batch of verified
;; signatures to execute a transaction or transfer by checking against a policy.
;; A transaction is a contract call meant for protocol interactions.
;; A transfer is strictly a sip10 token transfer from the vault to a recipient.

;; cons
(define-constant SIP018_MSG_PREFIX 0x534950303138)
(define-constant CLIENT 0x7b2ec266289e8e7012f18d805d012d72b709625eade12699b7f3b66b23b0e4cc)
(use-trait wrapper-trait 'SP3EDVXPRGV4QFAAKJSHN0MFD2T0DAFW9ZZMXJWKH.cf-traits-v0.wrapper-trait)
(use-trait token-trait 'SP3EDVXPRGV4QFAAKJSHN0MFD2T0DAFW9ZZMXJWKH.sip-010-trait-ft-standard.sip-010-trait)

;; errs
(define-constant ERR_UNAUTHORIZED_USER (err u100))
(define-constant ERR_INACTIVE_POLICY (err u101))
(define-constant ERR_INVALID_HELPER (err u102))
(define-constant ERR_THRESHOLD_NOT_MET (err u103))
(define-constant ERR_INVALID_TYPE (err u104))
(define-constant ERR_AMOUNT_EXCEEDS_POLICY (err u105))
(define-constant ERR_INVALID_USER (err u106))
(define-constant ERR_INACTIVE_USER (err u107))
(define-constant ERR_INVALID_POLICY (err u108))
(define-constant ERR_INVALID_SIGNATURE (err u109))
(define-constant ERR_INVALID_SIGNER (err u110))
(define-constant ERR_AUTH_ID_REPLAY (err u111))
(define-constant ERR_INVALID_DEPOSITOR (err u112))
(define-constant ERR_INVALID_TOKEN (err u113))

;; execute-transaction
;; This function executes a transfer out of this contract based on an enforced policy & a list of signatures.
;; If the transaction (not transfer), the serialized tuple/params buff should appended to the message.
(define-public (execute-transaction (user-id (string-ascii 64))
                                    (contract <wrapper-trait>)
                                    (name (string-ascii 32))
                                    (instructions (buff 4096))
                                    (policy-id (string-ascii 64))
                                    (auth-id (string-ascii 64))
                                    (type (string-ascii 32))
                                    (signed-data (list 35 {signer: (buff 33), signature: (buff 65)})))
    (let
        (
            ;; Fetch & check for user
            (user (unwrap! (contract-call? 'SP3EDVXPRGV4QFAAKJSHN0MFD2T0DAFW9ZZMXJWKH.cf-helpers-state-v0 get-user CLIENT user-id) ERR_INVALID_USER))
            ;; Fetch & check for valid policy
            (policy (unwrap! (contract-call? 'SP3EDVXPRGV4QFAAKJSHN0MFD2T0DAFW9ZZMXJWKH.cf-helpers-state-v0 get-policy CLIENT policy-id) ERR_INVALID_POLICY))
            ;; Unwrap transaction properties
            (transaction-policy (unwrap! (get transaction policy) ERR_INVALID_TYPE))
        )
        ;; Check that user is active
        (asserts! (get active user) ERR_INACTIVE_USER)
        ;; Check that policy is active
        (asserts! (get active policy) ERR_INACTIVE_POLICY)
        ;; Check that all signatures are valid & all signers are in the policy
        (try! (verify-transaction-signature policy-id (get signers policy) type (contract-of contract) name auth-id signed-data))
        ;; Check that signing threshold is met
        (asserts! (>= (len signed-data) (get threshold policy)) ERR_THRESHOLD_NOT_MET)
        ;; Cofund wrapper generic contract call
        (try! (contract-call? contract router-wrapper name instructions))
        (print {
            topic: "Transaction Executed",
            policy-id: policy-id,
            type: type,
            function: name,
            wrapper: (contract-of contract),
            auth-id: auth-id
        })
        (ok true)
    )
)

;; execute-transaction
;; This function executes a transfer out of this contract based on an enforced policy & a list of signatures.
(define-public (execute-transfer (user-id (string-ascii 64))
                                    (policy-id (string-ascii 64))
                                    (amount uint)
                                    (token <token-trait>)
                                    (recipient principal)
                                    (auth-id (string-ascii 64))
                                    (signed-data (list 35 {signer: (buff 33), signature: (buff 65)})))
    (let
        (
            ;; Fetch & check for user
            (user (unwrap! (contract-call? 'SP3EDVXPRGV4QFAAKJSHN0MFD2T0DAFW9ZZMXJWKH.cf-helpers-state-v0 get-user CLIENT user-id) ERR_INVALID_USER))
            ;; Fetch & check for valid policy
            (policy (unwrap! (contract-call? 'SP3EDVXPRGV4QFAAKJSHN0MFD2T0DAFW9ZZMXJWKH.cf-helpers-state-v0 get-policy CLIENT policy-id) ERR_INVALID_POLICY))
            ;; Unwrap transfer properties
            (transfer-policy (unwrap! (get transfer policy) ERR_INVALID_TYPE))
        )
        ;; Check that user is active
        (asserts! (get active user) ERR_INACTIVE_USER)
        ;; Check that policy is active
        (asserts! (get active policy) ERR_INACTIVE_POLICY)
        ;; Check that all signatures are valid & all signers are in the policy
        (try! (verify-transfer-signature policy-id (get signers policy)
            (get type policy) amount (contract-of token) recipient auth-id
            signed-data
        ))
        ;; Check that signing threshold is met
        (asserts! (>= (len signed-data) (get threshold policy))
            ERR_THRESHOLD_NOT_MET
        )
        ;; Check that amount is less than max-amount
        (asserts! (<= amount (get max-amount transfer-policy))
            ERR_AMOUNT_EXCEEDS_POLICY
        )
        ;; Transfer tokens from vault to recipient
        (try! (as-contract (contract-call? token transfer amount tx-sender recipient none)))
        (print {
            topic: "Transfer Executed",
            policy-id: policy-id,
            type: (get type policy),
            amount: amount,
            token: token,
            recipient: recipient,
            auth-id: auth-id,
        })
        (ok true)
    )
)

;; execute-deposit
;; This function executes a transfer in (aka deposit | on-ramp) based on an enforced policy & a list of signatures.
(define-public (execute-deposit
        (policy-id (string-ascii 64))
        (amount uint)
        (token <token-trait>)
        (auth-id (string-ascii 64))
        (signed-data (list 35 {
            signer: (buff 33),
            signature: (buff 65),
        }))
    )
    (let (
            ;; Fetch & check for valid policy
            (policy (unwrap!
                (contract-call? 'SP3EDVXPRGV4QFAAKJSHN0MFD2T0DAFW9ZZMXJWKH.cf-helpers-state-v0 get-policy CLIENT policy-id)
                ERR_INVALID_POLICY
            ))
            ;; Unwrap transfer properties
            (transfer-policy (unwrap! (get transfer policy) ERR_INVALID_TYPE))
            (policy-type (get type policy))
            ;; Unwrap receipients
            (recipients-list (unwrap! (get recipients transfer-policy) ERR_INVALID_POLICY))
            ;; Unwrap depositor (address be in position 0)
            (deposit-address (unwrap! (element-at? recipients-list u0) ERR_INVALID_DEPOSITOR))
        )
        ;; Check that the token matches the 'token' field in the policy
        (asserts! (is-eq (contract-of token) (get token transfer-policy))
            ERR_INVALID_TOKEN
        )
        ;; Check that sender (addresss 0 in receipients list) matches the 'recipient' field in the policy
        (asserts! (is-eq tx-sender deposit-address) ERR_UNAUTHORIZED_USER)
        ;; Check that it's an active policy
        (asserts! (get active policy) ERR_INACTIVE_POLICY)
        ;; Check that the amount is equal to or less than the max-amount
        (asserts! (<= amount (get max-amount transfer-policy))
            ERR_AMOUNT_EXCEEDS_POLICY
        )
        ;; Check that all signatures are valid & all signers are in the policy
        (try! (verify-transfer-signature policy-id (get signers policy) policy-type
            amount (contract-of token) (as-contract tx-sender) auth-id
            signed-data
        ))
        ;; Accept deposit | crypto on-ramp
        (try! (contract-call? token transfer amount tx-sender (as-contract tx-sender)
            none
        ))
        (print {
            topic: "Deposit Executed",
            policy-id: policy-id,
            amount: amount,
            token: token,
            sender: tx-sender,
        })
        (ok true)
    )
)

;; verify-transaction
;; The following functions verify batched transaction signatures
;; Meant for interacting with on-chain contracts
;; verify-transaction-signature
(define-private (verify-transaction-signature
        (policy-id (string-ascii 64))
        (policy-signers (list 35 (buff 33)))
        (type (string-ascii 32))
        (wrapper principal)
        (function (string-ascii 32))
        (auth-id (string-ascii 64))
        (signed-data (list 35 {
            signer: (buff 33),
            signature: (buff 65),
        }))
    )
    (begin
        ;; verify fresh auth-id
        (asserts!
            (is-none (contract-call? 'SP3EDVXPRGV4QFAAKJSHN0MFD2T0DAFW9ZZMXJWKH.cf-helpers-state-v0 get-used-auth-ids CLIENT auth-id))
            ERR_AUTH_ID_REPLAY
        )
        ;; Check that all signatures are valid & all signers are in the policy
        (try! (fold verify-transaction-signature-helper signed-data
            (ok {
                type: type,
                wrapper: wrapper,
                function: function,
                auth-id: auth-id,
                policy-id: policy-id,
                policy-signers: policy-signers,
            })
        ))
        ;; update auth-id
        (unwrap!
            (contract-call? 'SP3EDVXPRGV4QFAAKJSHN0MFD2T0DAFW9ZZMXJWKH.cf-helpers-state-v0 set-auth-id CLIENT "users"
                auth-id
            )
            ERR_AUTH_ID_REPLAY
        )
        (ok true)
    )
)

;; verify-transaction-signature-helper
;; This function verifies signature & checks that the signer is in the policy signer set.
(define-private (verify-transaction-signature-helper
        (signed-data {
            signer: (buff 33),
            signature: (buff 65),
        })
        (signed-response (response {
            type: (string-ascii 32),
            wrapper: principal,
            function: (string-ascii 32),
            auth-id: (string-ascii 64),
            policy-id: (string-ascii 64),
            policy-signers: (list 35 (buff 33)),
        }
            uint
        ))
    )
    (match signed-response
        ok-response (begin
            ;; verify signature
            (asserts!
                (read-valid-transaction-signature (get policy-id ok-response)
                    (get type ok-response) (get wrapper ok-response)
                    (get function ok-response) (get auth-id ok-response)
                    (get signature signed-data) (get signer signed-data)
                )
                ERR_INVALID_SIGNATURE
            )
            ;; verify signer in policy signer set
            (unwrap!
                (index-of? (get policy-signers ok-response)
                    (get signer signed-data)
                )
                ERR_INVALID_SIGNER
            )
            (ok ok-response)
        )
        err-response (err err-response)
    )
)

;; read-valid-transaction-signature
;; Verify one signature from the list of signatures for an attempted transaction.
;; See `get-signer-key-message-hash` for details on the message hash.
(define-read-only (read-valid-transaction-signature
        (policy-id (string-ascii 64))
        (type (string-ascii 32))
        (wrapper principal)
        (function (string-ascii 32))
        (auth-id (string-ascii 64))
        (signature (buff 65))
        (signer-key (buff 33))
    )
    (secp256k1-verify
        (get-transaction-signature-message-hash policy-id type wrapper function
            auth-id
        )
        signature signer-key
    )
)

;; get-transaction-signature-message-hash 
;; Generate a transaction message hash following SIP018 for signing structured data.
;; The domain is `{name: "cofund-signer", version: "1.0.0", chain-id: chain-id}`.
(define-read-only (get-transaction-signature-message-hash
        (policy-id (string-ascii 64))
        (type (string-ascii 32))
        (wrapper principal)
        (function (string-ascii 32))
        (auth-id (string-ascii 64))
    )
    (sha256 (concat SIP018_MSG_PREFIX
        (concat
            (sha256 (unwrap-panic (to-consensus-buff? {
                name: "cofund-signer",
                version: "1.0.0",
                chain-id: u1,
            })))
            (sha256 (unwrap-panic (to-consensus-buff? {
                auth-id: auth-id,
                function: function,
                policy-id: policy-id,
                type: type,
                wrapper: wrapper,
            })))
        )))
)

;; verify-transfer
;; the following functions verify batched transfer signatures
;; verify-transfer-signature
(define-private (verify-transfer-signature
        (policy-id (string-ascii 64))
        (policy-signers (list 35 (buff 33)))
        (type (string-ascii 128))
        (amount uint)
        (token principal)
        (recipient principal)
        (auth-id (string-ascii 64))
        (signed-data (list 35 {
            signer: (buff 33),
            signature: (buff 65),
        }))
    )
    (begin
        ;; verify fresh auth-id
        (asserts!
            (is-none (contract-call? 'SP3EDVXPRGV4QFAAKJSHN0MFD2T0DAFW9ZZMXJWKH.cf-helpers-state-v0 get-used-auth-ids CLIENT auth-id))
            ERR_AUTH_ID_REPLAY
        )
        ;; Check that all signatures are valid & all signers are in the policy
        (try! (fold verify-transfer-signature-helper signed-data
            (ok {
                type: type,
                amount: amount,
                token: token,
                recipient: recipient,
                auth-id: auth-id,
                policy-id: policy-id,
                policy-signers: policy-signers,
            })
        ))
        ;; update auth-id
        (unwrap!
            (contract-call? 'SP3EDVXPRGV4QFAAKJSHN0MFD2T0DAFW9ZZMXJWKH.cf-helpers-state-v0 set-auth-id CLIENT "users"
                auth-id
            )
            ERR_AUTH_ID_REPLAY
        )
        (ok true)
    )
)
;; verify-transfer-signature
;; This function verifies signature & checks that the signer is in the policy signer set.
(define-private (verify-transfer-signature-helper
        (signed-data {
            signer: (buff 33),
            signature: (buff 65),
        })
        (signed-response (response {
            type: (string-ascii 128),
            amount: uint,
            token: principal,
            recipient: principal,
            auth-id: (string-ascii 64),
            policy-id: (string-ascii 64),
            policy-signers: (list 35 (buff 33)),
        }
            uint
        ))
    )
    (match signed-response
        ok-response (begin
            ;; verify signature
            (asserts!
                (read-valid-transfer-signature (get policy-id ok-response)
                    (get type ok-response) (get amount ok-response)
                    (get token ok-response) (get recipient ok-response)
                    (get auth-id ok-response) (get signature signed-data)
                    (get signer signed-data)
                )
                ERR_INVALID_SIGNATURE
            )
            ;; verify signer in policy signer set
            (unwrap!
                (index-of? (get policy-signers ok-response)
                    (get signer signed-data)
                )
                ERR_INVALID_SIGNER
            )
            (ok ok-response)
        )
        err-response (err err-response)
    )
)
;; read-valid-transfer-signature
;; Verify one signature from the list of signatures for an attempted transaction.
;; See `get-signer-key-message-hash` for details on the message hash.
(define-read-only (read-valid-transfer-signature
        (policy-id (string-ascii 64))
        (type (string-ascii 128))
        (amount uint)
        (token principal)
        (recipient principal)
        (auth-id (string-ascii 64))
        (signature (buff 65))
        (signer-key (buff 33))
    )
    (secp256k1-verify
        (get-transfer-signature-message-hash policy-id type amount token
            recipient auth-id
        )
        signature signer-key
    )
)
;; get-transfer-signature-message-hash
;; Generate a transfer message hash following SIP018 for signing structured data.
;; The domain is `{name: "cofund-signer", version: "1.0.0", chain-id: chain-id}`.
(define-read-only (get-transfer-signature-message-hash
        (policy-id (string-ascii 64))
        (type (string-ascii 128))
        (amount uint)
        (token principal)
        (recipient principal)
        (auth-id (string-ascii 64))
    )
    (sha256 (concat SIP018_MSG_PREFIX
        (concat
            (sha256 (unwrap-panic (to-consensus-buff? {
                name: "cofund-signer",
                version: "1.0.0",
                chain-id: u1,
            })))
            (sha256 (unwrap-panic (to-consensus-buff? {
                amount: amount,
                auth-id: auth-id,
                policy-id: policy-id,
                recipient: recipient,
                token: token,
                type: type,
            })))
        )))
)

(contract-call? 'SP3EDVXPRGV4QFAAKJSHN0MFD2T0DAFW9ZZMXJWKH.cf-helpers-state-v0 new-client CLIENT 0x35a71d704895987671b9ba11f6b199e7441103ac27d0860e77a9b46302850fdc "41d29cd6-c178-4329-bab2-d2cca72e6f4f")
