;; This is a Cofund helper contract that provides a wrapper around the state contract to manage policies.
;; The current version provides the ability to activate & deactivate policies.
;; Only active admins can successfully call these functions.

;; cons
;; errs
(define-constant ERR_INVALID_THRESHOLD (err u400))
(define-constant ERR_SIGNERS_LENGTH (err u401))
(define-constant ERR_INVALID_TYPE (err u402))

;; functions
;; activate-policy-wrapper
;; This function activates a new policy for a given client ID. Each policy is one of two types: transaction or transfer.
;; The governance model is based on a set of signers & provided threshold.
;; @param caller-id; The caller's ID
;; @param client-id; The client's ID
;; @param policy-id; The new policy's ID
;; @param policy-type; The policy's type
;; @param policy-signers; The signer set for this policy
;; @param policy-threshold; The threshold for this policy
;; @param transaction-optional; The transaction optional tuple used for generic transactions
;; @param transfer-optional; The transfer optional tuple used for SIP10 token transfers
(define-public (activate-policy-wrapper (caller-id (string-ascii 64)) 
                                (client-id (buff 32))
                                (policy-id (string-ascii 64))
                                (policy-title (string-ascii 128))
                                (policy-type (string-ascii 128))
                                (policy-signers (list 35 (buff 33)))
                                (policy-threshold uint)
                                (transaction-optional (optional { wrapper: principal, function: (string-ascii 32)}))
                                (transfer-optional (optional { max-amount: uint, token: principal, recipients: (optional (list 50 principal))})))
    (begin
        ;; Check that policy threshold is greater than 1
        (asserts! (> policy-threshold u1) ERR_INVALID_THRESHOLD)
        ;; Check that len of signers is greater or equal to threshold
        (asserts! (>= (len policy-signers) policy-threshold) ERR_SIGNERS_LENGTH)
        ;; Check that either transaction or transfer is-some
        (asserts! (or (is-some transaction-optional) (is-some transfer-optional)) ERR_INVALID_TYPE)
        ;; Call into state contract to activate policy
        (try! (contract-call? .cf-helpers-state-v0 activate-policy client-id caller-id policy-id policy-title policy-type policy-signers policy-threshold transaction-optional transfer-optional))
        (ok true)
    )
)
;; deactivate-policy-wrapper
;; This function deactivates an active policy for a given client ID by calling into the state contract.
;; @param caller-id; The caller's ID
;; @param client-id; The client's ID
;; @param policy-id; The policy's ID
(define-public (deactivate-policy-wrapper (caller-id (string-ascii 64)) (client-id (buff 32)) (policy-id (string-ascii 64)))
    (begin
        ;; Call into state contract to deactivate policy
        (try! (contract-call? .cf-helpers-state-v0 deactivate-policy client-id caller-id policy-id))
        (ok true)
    )
)