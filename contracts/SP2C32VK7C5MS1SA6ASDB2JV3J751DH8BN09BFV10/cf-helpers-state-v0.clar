;; This is a Cofund helper contract that provides state management for all Cofund vaults.
;; It provides the ability to manage users, policies, & assists in executing transactions/transfers.
;; Only specific contracts (such as active helper contracts) & callers (such as ) can call into this contract.

;; cons
;; errs
(define-constant ERR_UNAUTHORIZED_USER (err u200))
(define-constant ERR_USER_EXISTS (err u201))
(define-constant ERR_ADDRESS_EXISTS (err u202))
(define-constant ERR_KEY_EXISTS (err u203))
(define-constant ERR_INVALID_INVITE (err u204))
(define-constant ERR_INVITE_REPLAY (err u205))
(define-constant ERR_INVITE_EXPIRED (err u206))
(define-constant ERR_INVITE_EXISTS (err u207))
(define-constant ERR_INVALID_PREIMAGE (err u208))
(define-constant ERR_INACTIVE_USER (err u209))
(define-constant ERR_INVALID_USER (err u210))
(define-constant ERR_INVALID_POSITION (err u211))
(define-constant ERR_MIN_ADMINS (err u212))
(define-constant ERR_UNAUTHORIZED_CALLER (err u213))
(define-constant ERR_POLICY_REPLAY (err u214))
(define-constant ERR_INVALID_POLICY (err u215))
(define-constant ERR_AUTHID_REPLAY (err u216))

;; data maps
;; helper-contracts
;; active helper contracts
(define-map helper-contracts (string-ascii 128) principal)
(map-set helper-contracts "signatures" .cofund-helpers-signatures-v0)
(map-set helper-contracts "users" .cf-helpers-users-v0)
(map-set helper-contracts "policies" .cf-helpers-policies-v0)
(define-map cofund-admins principal bool)
(define-map cofund-policy-types (string-ascii 128) bool)
(map-set cofund-admins tx-sender true)
(map-set cofund-policy-types "Contractor Stipend" true)
(map-set cofund-policy-types "Crypto Onramp" true)
(define-map client (buff 32) bool)
;; invites
;; predetermined invites for adding users
(define-map invites {client-id: (buff 32), invite-hash: (buff 32)} {
    activated: bool,
    is-admin: bool,
    user-id: (string-ascii 64), 
    user-position: (string-ascii 128), 
    expire-height: uint})
;; policies
;; predetermined policies for vault executions
(define-map policies {client-id: (buff 32), policy: (string-ascii 64)} {
    active: bool,
    title: (string-ascii 128),
    type: (string-ascii 128),
    signers: (list 35 (buff 33)),
    threshold: uint,
    transaction: (optional { wrapper: principal, function: (string-ascii 32)}), 
    transfer: (optional { max-amount: uint, token: principal, recipients: (optional (list 50 principal))}),
})
;; users
;; users registered with a vault
(define-map users {client-id: (buff 32), user-id: (string-ascii 64)} {
    address: principal, 
    key: (buff 33), 
    position: (string-ascii 128), 
    active: bool,
    is-admin: bool
})
;; auth-ids
;; used auth-ids to avoid signature replays
(define-map auth-ids {client-id: (buff 32), contract: principal, auth-id: (string-ascii 64)} bool)
(define-map users-by-address principal {client-id: (buff 32), user-id: (string-ascii 64) })
(define-map users-by-key (buff 33) { client-id: (buff 32), user-id: (string-ascii 64) })
;; active admins per client
(define-map active-admins (buff 32) uint)

;; test data
;; testco policy 0 (transfer)
(map-set policies {client-id: 0x16cbd0716887fd9259f39d403e19eb3436e3bdf3c17a37035cf0f8f0d7851e0b, policy: "0"} {
    active: true, 
    title: "Test Payroll Policy",
    type: "Contractor Stipend", 
    signers: (list 0x0390a5cac7c33fda49f70bc1b0866fa0ba7a9440d9de647fecb8132ceb76a94dfa 0x03cd2cfdbd2ad9332828a7a13ef62cb999e063421c708e863a7ffed71fb61c88c9), 
    threshold: u2, 
    transaction: none, 
    transfer: (some {
        max-amount: u100000000, 
        token: .sbtc-token, 
        recipients: none})
})
;; testco policy 1 (transaction)
(map-set policies {client-id: 0x16cbd0716887fd9259f39d403e19eb3436e3bdf3c17a37035cf0f8f0d7851e0b, policy: "1"} {
    active: true, 
    title: "Add To Balance Sheet",
    type: "Crypto Deposit", 
    signers: (list 0x0390a5cac7c33fda49f70bc1b0866fa0ba7a9440d9de647fecb8132ceb76a94dfa 0x03cd2cfdbd2ad9332828a7a13ef62cb999e063421c708e863a7ffed71fb61c88c9), 
    threshold: u2, 
    transaction: (some { wrapper: .cf-wrappers-foobar-defi, function: "mint-token" }), 
    transfer: none
})
(map-set policies {client-id: 0x16cbd0716887fd9259f39d403e19eb3436e3bdf3c17a37035cf0f8f0d7851e0b, policy: "2"} {
    active: true, 
    title: "Test Crypto Onramp",
    type: "Crypto Onramp", 
    signers: (list 0x0390a5cac7c33fda49f70bc1b0866fa0ba7a9440d9de647fecb8132ceb76a94dfa 0x03cd2cfdbd2ad9332828a7a13ef62cb999e063421c708e863a7ffed71fb61c88c9), 
    threshold: u2, 
    transaction: none, 
    transfer: (some {
        max-amount: u100000000, 
        token: .sbtc-token, 
        recipients: (some (list tx-sender))})
})
;; testco user 0 (admin)
(map-set users {client-id: 0x16cbd0716887fd9259f39d403e19eb3436e3bdf3c17a37035cf0f8f0d7851e0b, user-id: "0"} {address: tx-sender, key: 0x0390a5cac7c33fda49f70bc1b0866fa0ba7a9440d9de647fecb8132ceb76a94dfa, position: "admin", active: true, is-admin: true})
(map-set users-by-address tx-sender {client-id: 0x16cbd0716887fd9259f39d403e19eb3436e3bdf3c17a37035cf0f8f0d7851e0b, user-id: "0"})
(map-set users-by-key 0x0390a5cac7c33fda49f70bc1b0866fa0ba7a9440d9de647fecb8132ceb76a94dfa {client-id: 0x16cbd0716887fd9259f39d403e19eb3436e3bdf3c17a37035cf0f8f0d7851e0b, user-id: "0"})
(map-set active-admins 0x16cbd0716887fd9259f39d403e19eb3436e3bdf3c17a37035cf0f8f0d7851e0b u1)
;; testco user 1 (employee)
(map-set users {client-id: 0x16cbd0716887fd9259f39d403e19eb3436e3bdf3c17a37035cf0f8f0d7851e0b, user-id: "1"} {address: 'ST1SJ3DTE5DN7X54YDH5D64R3BCB6A2AG2ZQ8YPD5, key: 0x03cd2cfdbd2ad9332828a7a13ef62cb999e063421c708e863a7ffed71fb61c88c9, position: "employee", active: true, is-admin: false})
(map-set users-by-address 'ST1SJ3DTE5DN7X54YDH5D64R3BCB6A2AG2ZQ8YPD5 {client-id: 0x16cbd0716887fd9259f39d403e19eb3436e3bdf3c17a37035cf0f8f0d7851e0b, user-id: "1"})
(map-set users-by-key 0x03cd2cfdbd2ad9332828a7a13ef62cb999e063421c708e863a7ffed71fb61c88c9 {client-id: 0x16cbd0716887fd9259f39d403e19eb3436e3bdf3c17a37035cf0f8f0d7851e0b, user-id: "1"})

;; read-only functions
(define-read-only (get-active-helper (type (string-ascii 128))) (map-get? helper-contracts type))
(define-read-only (get-policy (client-id (buff 32)) (policy-id (string-ascii 64))) (map-get? policies {client-id: client-id, policy: policy-id}))
(define-read-only (get-user (client-id (buff 32)) (user-id (string-ascii 64))) (map-get? users {client-id: client-id, user-id: user-id}))
(define-read-only (get-user-id-by-address (address principal)) (map-get? users-by-address address))
(define-read-only (get-user-id-by-key (key (buff 33))) (map-get? users-by-key key))
(define-read-only (get-active-admins (client-id (buff 32))) (map-get? active-admins client-id))
(define-read-only (get-invite (client-id (buff 32)) (invite-hash (buff 32))) (map-get? invites {client-id: client-id, invite-hash: invite-hash}))
(define-read-only (get-policy-type (policy-type (string-ascii 128))) (map-get? cofund-policy-types policy-type))
(define-read-only (get-used-auth-ids (client-id (buff 32)) (auth-id (string-ascii 64))) (map-get? auth-ids {client-id: client-id, contract: contract-caller, auth-id: auth-id}))

;; policy functions
;; activate-policy
;; This function activates a new policy for a given client ID. Each policy is one of two types: transaction or transfer.
;; @param client-id; The client's ID
;; @param caller-id; The caller's ID
;; @param policy-id; The new policy's ID
;; @param policy-type; The policy's type
;; @param policy-signers; The signer set for this policy
;; @param policy-threshold; The threshold for this policy
;; @param policy-transaction; The transaction optional tuple used for generic transactions
;; @param policy-transfer; The transfer optional tuple used for SIP10 token transfers
(define-public (activate-policy (client-id (buff 32)) (caller-id (string-ascii 64)) (policy-id (string-ascii 64)) (policy-title (string-ascii 128)) (policy-type (string-ascii 128)) (policy-signers (list 35 (buff 33))) (policy-threshold uint) (policy-transaction (optional { wrapper: principal, function: (string-ascii 32)})) (policy-transfer (optional { max-amount: uint, token: principal, recipients: (optional (list 50 principal))})))
    (let
        (
            (caller (unwrap! (get-user client-id caller-id) ERR_INVALID_USER))
        )
        ;; Protocol check
        (asserts! (is-eq (some contract-caller) (map-get? helper-contracts "policies")) ERR_UNAUTHORIZED_CALLER)
        ;; Check that caller is active
        (asserts! (get active caller) ERR_INACTIVE_USER)
        ;; Check that tx-sender is user-id & is an admin
        (asserts! (and (is-eq tx-sender (get address caller)) (get is-admin caller)) ERR_UNAUTHORIZED_USER)
        ;; Check that policy is not already active
        (asserts! (is-none (map-get? policies {client-id: client-id, policy: policy-id})) ERR_POLICY_REPLAY)
        ;; Check that policy type is supported
        (asserts! (is-some (map-get? cofund-policy-types policy-type)) ERR_INVALID_POLICY)
        ;; Activate policy
        (map-set policies {client-id: client-id, policy: policy-id} {
            active: true,
            title: policy-title,
            type: policy-type,
            signers: policy-signers,
            threshold: policy-threshold,
            transaction: policy-transaction,
            transfer: policy-transfer
        })
        (print {
            topic: "Policy Activated",
            client-id: client-id,
            policy-id: policy-id})
        (ok true)
    )
)
;; deactivate-policy
;; This function deactivates an active policy for a given client ID.
;; @param client-id; The client's ID
;; @param caller-id; The caller's ID
;; @param policy-id; The policy's ID
(define-public (deactivate-policy (client-id (buff 32)) (caller-id (string-ascii 64)) (policy-id (string-ascii 64)))
    (let
        (
            (caller (unwrap! (get-user client-id caller-id) ERR_INVALID_USER))
            (policy (unwrap! (get-policy client-id policy-id) ERR_INVALID_POLICY))
        )
        ;; Protocol check
        (asserts! (is-eq (some contract-caller) (map-get? helper-contracts "policies")) ERR_UNAUTHORIZED_CALLER)
        ;; Check that caller is active
        (asserts! (get active caller) ERR_INACTIVE_USER)
        ;; Check that tx-sender is user-id & is an admin
        (asserts! (and (is-eq tx-sender (get address caller)) (get is-admin caller)) ERR_UNAUTHORIZED_USER)
        ;; Deactivate policy
        (map-set policies {client-id: client-id, policy: policy-id} (merge policy {active: false}))
        (print {
            topic: "Policy Deactivated",
            client-id: client-id,
            policy-id: policy-id}
        )
        (ok true)
    )
)
;; user functions
;; add-user-invite
;; This function adds a new user invite to the invites map. The invite is used to add a new user to the vault
;; that expires after a certain height (~1 hr).
;; @param client-id; The client's ID
;; @param invite-hash; The invite hash
;; @param new-user-id; The new user's ID
;; @param new-user-position; The new user's position
(define-public (add-user-invite (client-id (buff 32))
                                        (caller-id (string-ascii 64))
                                        (invite-hash (buff 32))
                                        (new-user-id (string-ascii 64))
                                        (new-user-position (string-ascii 128))
                                        (new-user-is-admin bool))
    (let 
        (
            (caller (unwrap! (get-user client-id caller-id) ERR_INVALID_USER))
        )
        ;; Protocol check
        (asserts! (is-eq (some contract-caller) (map-get? helper-contracts "users")) ERR_UNAUTHORIZED_CALLER)
        ;; Check that caller is active
        (asserts! (get active caller) ERR_INACTIVE_USER)
        ;; Check that new user id does not exist
        (asserts! (is-none (get-user client-id new-user-id)) ERR_USER_EXISTS)
        ;; Check that invite hash does not exist
        (asserts! (is-none (get-invite client-id invite-hash)) ERR_INVITE_EXISTS)
        ;; Add invite-hash
        (map-set invites {client-id: client-id, invite-hash: invite-hash} {
            activated: false,
            is-admin: new-user-is-admin,
            user-id: new-user-id,
            user-position: new-user-position,
            expire-height: (+ burn-block-height u144)
        })
        ;; Print outcome
        (print {
            topic: "Invite Added",
            client-id: client-id,
            invite-hash: invite-hash,
            new-user-id: new-user-id,
            new-user-position: new-user-position
        })
        (ok true)
    )
)
;; add-user-invite-complete
;; This function completes the user invite process by adding the new user to the users map.
;; @param client-id; The client's ID
;; @param invite-hash; The invite hash
;; @param invite-preimage-id; The invite preimage ID
;; @param new-user-key; The new user's key
(define-public (add-user-invite-complete (client-id (buff 32)) (invite-hash (buff 32)) (invite-preimage-id uint) (new-user-key (buff 33)))
    (let
        (
            (invite (unwrap! (get-invite client-id invite-hash) ERR_INVALID_INVITE))
        )
        ;; Protocol check
        (asserts! (is-eq (some contract-caller) (map-get? helper-contracts "users")) ERR_UNAUTHORIZED_CALLER)
        ;; Check that invite has not been activated
        (asserts! (not (get activated invite)) ERR_INVITE_REPLAY)
        ;; Check that invite has not expired
        (asserts! (<= burn-block-height (get expire-height invite)) ERR_INVITE_EXPIRED)
        ;; Check hashed preimage against invite-hash
        (asserts! (is-eq 
            (sha256 (concat (sha256 (unwrap-panic (to-consensus-buff? invite-preimage-id))) (sha256 (unwrap-panic (to-consensus-buff? client-id)))))
            invite-hash
        ) ERR_INVALID_PREIMAGE)
        ;; Update users map
        (map-set users {client-id: client-id, user-id: (get user-id invite)} {
            address: tx-sender, 
            key: new-user-key, 
            position: (get user-position invite), 
            active: true,
            is-admin: (get is-admin invite)
        })
        ;; TODO: handle admin case
        ;; Update users-by-address map
        (map-set users-by-address tx-sender {client-id: client-id, user-id: (get user-id invite)})
        ;; Update users-by-key map
        (map-set users-by-key new-user-key {client-id: client-id, user-id: (get user-id invite)})
        ;; Update invites map
        (map-set invites {client-id: client-id, invite-hash: invite-hash} (merge invite {activated: true}))
        (print {
            topic: "Invite Completed",
            client-id: client-id,
            invite-hash: invite-hash,
            new-user-address: tx-sender,
            new-user-key: new-user-key
        })
        (ok true)
    )
)
;; remove-user
;; This function removes a user from the users map. Only admins can remove users.
;; @param client-id; The client's ID
;; @param user-id; The caller's ID
;; @param removed-user-id; The removed user's ID
;; @param valid-signatures; An optional number of valid signatures (only required for removing admins)
(define-public (remove-user (client-id (buff 32)) (user-id (string-ascii 64)) (removed-user-id (string-ascii 64)) (valid-signatures (optional uint)))
    (let
        (
            (caller (unwrap! (get-user client-id user-id) ERR_INVALID_USER))
            (removed-user (unwrap! (get-user client-id removed-user-id) ERR_INVALID_USER))
        )
        ;; Protocol check
        (asserts! (is-eq (some contract-caller) (map-get? helper-contracts "users")) ERR_UNAUTHORIZED_CALLER)
        ;; Check that caller is active
        (asserts! (get active caller) ERR_INACTIVE_USER)
        ;; Check that tx-sender is user-id & is an admin
        (asserts! (and (is-eq tx-sender (get address caller)) (get is-admin caller)) ERR_UNAUTHORIZED_USER)
        ;; Check if attemping to remove admin or user
        (match valid-signatures
            signatures-verified
            (begin 
                ;; Verify that removed-user is an admin
                (asserts! (get is-admin removed-user) ERR_INVALID_POSITION)
                ;; Check active admins greater than 2 (can never be 1 or 0)
                (asserts! (> (unwrap-panic (get-active-admins client-id)) u2) ERR_MIN_ADMINS)

            )
            (asserts! (not (get is-admin removed-user)) ERR_INVALID_POSITION)
        )
        ;; Update users map
        (map-set users {client-id: client-id, user-id: removed-user-id} (merge removed-user {active: false}))
        (print {
            topic: "User Removed",
            client-id: client-id,
            user-id: user-id,
            removed-user-id: removed-user-id
        })
        (ok true)
    )
)
;; rotate-user
;; This function rotates a user's address & key. Only admins can rotate users.
;; @param client-id; The client's ID
;; @param caller-id; The caller's ID
;; @param user-id; The user's ID
;; @param new-address; The new address for the user
;; @param new-key; The new key for the user
;; @param valid-signatures; An optional number of valid signatures (only required for rotating admins)
(define-public (rotate-user (client-id (buff 32)) (caller-id (string-ascii 64)) (user-id (string-ascii 64)) (new-address principal) (new-key (buff 33)) (valid-signatures (optional uint)))
    (let
        (
            (caller (unwrap! (get-user client-id caller-id) ERR_INVALID_USER))
            (rotated-user (unwrap! (get-user client-id user-id) ERR_INVALID_USER))
        )
        ;; Protocol check
        (asserts! (is-eq (some contract-caller) (map-get? helper-contracts "users")) ERR_UNAUTHORIZED_CALLER)
        ;; Check that caller is active
        (asserts! (get active caller) ERR_INACTIVE_USER)
        ;; Check that tx-sender is user-id & is an admin
        (asserts! (and (is-eq tx-sender (get address caller)) (get is-admin caller)) ERR_UNAUTHORIZED_USER)
        ;; Check that new address does not exist
        (asserts! (is-none (get-user-id-by-address new-address)) ERR_ADDRESS_EXISTS)
        ;; Check that new key does not exist
        (asserts! (is-none (get-user-id-by-key new-key)) ERR_KEY_EXISTS)
        ;; Extra check if rotating admin
        (match valid-signatures
            signatures-verified
            ;; Verify that rotated-user is an admin
            (asserts! (get is-admin rotated-user) ERR_INVALID_POSITION)
            (asserts! (not (get is-admin rotated-user)) ERR_INVALID_POSITION)
        )
        ;; Update users-by-key map
        (map-set users-by-key new-key {client-id: client-id, user-id: user-id})
        ;; Update users-by-address map
        (map-set users-by-address new-address {client-id: client-id, user-id: user-id})
        ;; Update users map
        (map-set users {client-id: client-id, user-id: user-id} (merge rotated-user {address: new-address, key: new-key}))
        (print {
            topic: "User Key Rotated",
            client-id: client-id,
            user-id: user-id,
            new-key: new-key
        })
        (ok true)
    )
)
;; set auth-id
;; This function updates the 'auth-ids' map so that signatures can't be replayed
(define-public (set-auth-id (client-id (buff 32)) (contract-name (string-ascii 128)) (auth-id (string-ascii 64)))
    (begin
        ;; update 'auth-ids' map
        (map-insert auth-ids {client-id: client-id, contract: contract-caller, auth-id: auth-id} true)
        (ok true)
    )
)

;; Cofund admin functions
;; new-client
;; This function adds a new client to the helper-contracts map & creates an invite for 
;; the first admin currently registering.
;; @param client-id; The client's ID
;; @param invite-hash; The invite hash
;; @param new-user-id; The new user's ID
(define-public (new-client (client-id (buff 32)) (invite-hash (buff 32)) (admin-id (string-ascii 64)))
    (begin 
        ;; Check that caller is a cofund admin
        (asserts! (is-some (map-get? cofund-admins tx-sender)) ERR_UNAUTHORIZED_CALLER)
        ;; Check that client-id does not exist
        (asserts! (is-none (get-invite client-id invite-hash)) ERR_INVALID_INVITE)
        ;; Create new client
        (map-insert client client-id true)
        ;; Create new invite
        (map-set invites {client-id: client-id, invite-hash: invite-hash} {
            activated: false,
            is-admin: true,
            user-id: admin-id,
            user-position: "admin",
            ;; TODO: Update to correct height (for testing purposes left at 600 bitcoin blocks)
            expire-height: (+ burn-block-height u600)})
        (print {
            topic: "New Client Created",
            client-id: client-id,
            invite-hash: invite-hash,
        })
        (ok true)
    )
)
;; add-policy-type
;; This function adds Cofund-supported policy types
;; @param type-name; The supported type name
(define-public (add-policy-type (type (string-ascii 128)))
    (begin 
        ;; Check that caller is a cofund admin
        (asserts! (is-some (map-get? cofund-admins tx-sender)) ERR_UNAUTHORIZED_CALLER)
        ;; Insert policy type into cofund-policy-types
        (map-set cofund-policy-types type true)
        (print {
            topic: "New Policy Type Created",
            policy-type: type,
        })
        (ok true)
    )
)