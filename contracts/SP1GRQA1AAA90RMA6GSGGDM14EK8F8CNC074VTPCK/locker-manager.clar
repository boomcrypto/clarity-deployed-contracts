;; title: locker
;; version: V-1
;; summary: Manager contract for the .locker namespace
;; description: All actions that can be taken for names will be made through this contract

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Cons, Vars, & Maps ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;
;;;;;;;;;;;;;;
;;;; Cons ;;;;
;;;;;;;;;;;;;;
;;;;;;;;;;;;;;

(define-constant LOCKER-NAMESPACE 0x6c6f636b6572)

;;;;;;;;;;;;;;
;;;;;;;;;;;;;;
;;;; Errs ;;;;
;;;;;;;;;;;;;;
;;;;;;;;;;;;;;
(define-constant ERR-NOT-AUTH (err u200))
(define-constant ERR-RECOVER (err u201))
(define-constant ERR-INVALID-SIGNER (err u202))
(define-constant ERR-UNWRAP (err u203))
(define-constant ERR-NO-NAME (err u204))
(define-constant ERR-WRONG-TRANSACTION-TYPE (err u205))
(define-constant ERR-SAME-ADMIN (err u206))
(define-constant ERR-NO-MANAGER-PROVIDED (err u207))
(define-constant ERR-NO-ZONEFILE (err u208))

;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;
;;;; Functions ;;;;
;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;
;;;;;;;;;;;;;;
;;;; Read ;;;;
;;;;;;;;;;;;;;
;;;;;;;;;;;;;;

;; Define a read-only function to check if a given principal is an admin
(define-read-only (is-admin (who principal))
    (let 
        (
            (admin-info (contract-call? .locker-registry get-admin who))
        )
        (asserts! (is-ok admin-info) ERR-NOT-AUTH) 
        (ok true)
    )
)

;; Define a read-only function named "hash-reg-data" that takes three parameters:
;; "name" 
;; "transaction type"
(define-read-only (hash-reg-data (name (buff 48)) (transaction-type (string-ascii 100)))
    ;; Compute the SHA-256 hash of the data
    (sha256 
        ;; Unwrap the result of "to-consensus-buff?"
        (unwrap-panic 
            ;; Convert the provided structured data into a consensus buffer
            ;; "to-consensus-buff?" attempts to serialize the given fields into a buffer format that can be used for consensus operations
            (to-consensus-buff? 
                ;; The data to be hashed
                ;; "name": the name
                ;; "transaction-type": transaction being made
                {
                    name: name,
                    transactionType: transaction-type
                }
            )
        )
    )
)

;; Define a read-only function called "validate-signature" that verifies the validity of a transaction's signature
;; This function takes 3 parameters:
;; "name"
;; "signature": a buffer of 65 bytes containing the digital signature
;; "transaction-type"
(define-read-only (validate-signature (name (buff 48)) (signature (buff 65)) (transaction-type (string-ascii 100)))
    (let
        (
            ;; Compute the hash of the registration data by calling "hash-reg-data" function
            (hash (hash-reg-data name transaction-type))
            ;; Attempt to recover the public key from the signature and hash using the "secp256k1-recover?" function
            (pubkey (unwrap! (secp256k1-recover? hash signature) ERR-RECOVER))
            ;; Compute the hash160 of the recovered public key to get the public key hash
            (pubkey-hash (hash160 pubkey))
        )
        ;; Verify that the computed public key hash matches the stored public key hash of the sender
        ;; The public key hash of the sender is retrieved from "admin-principals" map using the transaction sender's address
        ;; If the hashes do not match, trigger "ERR-INVALID-SIGNER" error
        (asserts! (is-eq pubkey-hash (unwrap! (contract-call? .locker-registry get-admin contract-caller) ERR-NOT-AUTH)) ERR-INVALID-SIGNER)
        ;; If all checks pass, return 'ok' and the information from the transaction
        (ok 
            {
                isOperationSuccess: true,
                pubKey: pubkey,
                pubKeyHash: pubkey-hash,
                transactionType: transaction-type,
                burn-block-height: burn-block-height
            }
        )
    )
)

;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;
;;;; Public ;;;;
;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;

;; name-register
;; description: Allows and admin principal to fastclaim a name on the locker namespace
;; inputs: hashed-salted-fqn (buff 20)
(define-public (name-register (name-info {name: (buff 48), zonefile: (buff 8192), send-to: principal, signature: (buff 65), transaction-type: (string-ascii 100)}))
    (let 
        (
            (name-to-register (get name name-info))
            (this-transaction-type (get transaction-type name-info))
            (bns-id-minted (try! (contract-call? 'SP2QEZ06AGJ3RKJPBV14SY1V5BBFNAW33D96YPGZF.BNS-V2 name-claim-fast name-to-register LOCKER-NAMESPACE (get send-to name-info))))
        ) 
        (try! (is-admin contract-caller))
        (try! (validate-signature name-to-register (get signature name-info) this-transaction-type))
        ;; Make sure transaction-type matches
        (asserts! (is-eq "name-register" this-transaction-type) ERR-WRONG-TRANSACTION-TYPE)
        (try! (contract-call? 'SP2QEZ06AGJ3RKJPBV14SY1V5BBFNAW33D96YPGZF.zonefile-resolver update-zonefile name-to-register LOCKER-NAMESPACE (some (get zonefile name-info))))
        (ok bns-id-minted)
    )
)

;; name-lock
;; description: Allows an admin principal to add a name to the suspended map
;; inputs: name being suspended
(define-public (name-lock (name-lock-info {name: (buff 48), signature: (buff 65), transaction-type: (string-ascii 100)}))
    (let 
        (
            (name (get name name-lock-info))
            (name-zonefile (unwrap! (contract-call? 'SP2QEZ06AGJ3RKJPBV14SY1V5BBFNAW33D96YPGZF.zonefile-resolver resolve-name name LOCKER-NAMESPACE) ERR-NO-ZONEFILE))
        ) 
        ;; check that the caller is an admin principal
        (try! (is-admin contract-caller))
        (try! (validate-signature (get name name-lock-info) (get signature name-lock-info) (get transaction-type name-lock-info)))
        ;; Make sure transaction-type matches
        (asserts! (is-eq "name-lock" (get transaction-type name-lock-info)) ERR-WRONG-TRANSACTION-TYPE)
        ;; Make the contract call to suspend the name, sets the zonefile hash to null
        (try! (contract-call? 'SP2QEZ06AGJ3RKJPBV14SY1V5BBFNAW33D96YPGZF.zonefile-resolver update-zonefile name LOCKER-NAMESPACE none))
        ;; map set the new suspended-name, we store the zonefile so when unsuspending we set the zonefile hash to its previous value
        (ok (contract-call? .locker-registry lock-name name (unwrap-panic name-zonefile)))
    )
)

;; name-unlock
;; description: Allows an admin principal to remove a name to the suspended map
;; inputs: name removed suspended
(define-public (name-unlock (name-unlock-info {name: (buff 48), signature: (buff 65), transaction-type: (string-ascii 100)}))
    (let 
        (
            (unlocked-name (get name name-unlock-info))
            (zonefile (unwrap! (contract-call? .locker-registry get-locked-name unlocked-name) ERR-NO-ZONEFILE))
        ) 
        ;; check that the caller is a privileged protocol principal
        (try! (is-admin contract-caller))
        (try! (validate-signature (get name name-unlock-info) (get signature name-unlock-info) (get transaction-type name-unlock-info)))
        ;; Make sure transaction-type matches
        (asserts! (is-eq "name-unlock" (get transaction-type name-unlock-info)) ERR-WRONG-TRANSACTION-TYPE)
        ;; Update the zonefile hash
        (try! (contract-call? 'SP2QEZ06AGJ3RKJPBV14SY1V5BBFNAW33D96YPGZF.zonefile-resolver update-zonefile unlocked-name LOCKER-NAMESPACE (some zonefile)))
        ;; map remove the suspended name
        (ok (contract-call? .locker-registry unlock-name unlocked-name))
    )
)

;; name-purge
;; description: Defines a public function to burn an NFT, identified by its unique ID, under managed namespace authority
(define-public (name-purge (purge-info {name: (buff 48), signature: (buff 65), transaction-type: (string-ascii 100)}))
    (let 
        (
            (id (unwrap! (contract-call? 'SP2QEZ06AGJ3RKJPBV14SY1V5BBFNAW33D96YPGZF.BNS-V2 get-id-from-bns (get name purge-info) LOCKER-NAMESPACE) ERR-NO-NAME))
        ) 
        (try! (is-admin contract-caller))
        (try! (validate-signature (get name purge-info) (get signature purge-info) (get transaction-type purge-info)))
        ;; Make sure transaction-type matches
        (asserts! (is-eq "name-purge" (get transaction-type purge-info)) ERR-WRONG-TRANSACTION-TYPE)
        (contract-call? 'SP2QEZ06AGJ3RKJPBV14SY1V5BBFNAW33D96YPGZF.BNS-V2 mng-burn id)
    )
)

;; update-zonefile
;; description: Allows an admin principal to update the zonefile hash of a name
;; inputs: name and zonefile
(define-public (name-zonefile-update (name-and-zonefile {name: (buff 48), zonefile: (buff 8192), signature: (buff 65), transaction-type: (string-ascii 100)}))
    (begin
        ;; check that the caller is a privileged protocol principal
        (try! (is-admin contract-caller))
        (try! (validate-signature (get name name-and-zonefile) (get signature name-and-zonefile) (get transaction-type name-and-zonefile)))
        ;; Make sure transaction-type matches
        (asserts! (is-eq "name-zonefile-update" (get transaction-type name-and-zonefile)) ERR-WRONG-TRANSACTION-TYPE)
        ;; Update the zonefile hash
        (try! (contract-call? 'SP2QEZ06AGJ3RKJPBV14SY1V5BBFNAW33D96YPGZF.zonefile-resolver update-zonefile (get name name-and-zonefile) LOCKER-NAMESPACE (some (get zonefile name-and-zonefile))))
        ;; map remove the suspended name
        (ok true)
    )
)

;; name-transfer
;; description: Allows an admin principal to transfer a name
;; inputs: name and recipient
(define-public (name-transfer (name-and-recipient {name: (buff 48), recipient: principal, signature: (buff 65), transaction-type: (string-ascii 100)}))
    (let 
        (
            (name (get name name-and-recipient))
            (recipient (get recipient name-and-recipient))
            (id (unwrap! (contract-call? 'SP2QEZ06AGJ3RKJPBV14SY1V5BBFNAW33D96YPGZF.BNS-V2 get-id-from-bns name LOCKER-NAMESPACE) ERR-NO-NAME))
            (owner (unwrap! (contract-call? 'SP2QEZ06AGJ3RKJPBV14SY1V5BBFNAW33D96YPGZF.BNS-V2 get-owner id) ERR-NO-NAME))
        )
        ;; check that the caller is a privileged protocol principal
        (try! (is-admin contract-caller))
        (try! (validate-signature name (get signature name-and-recipient) (get transaction-type name-and-recipient)))
        ;; Make sure transaction-type matches
        (asserts! (is-eq "name-transfer" (get transaction-type name-and-recipient)) ERR-WRONG-TRANSACTION-TYPE)
        ;; Execute the transfer
        (try! (contract-call? 'SP2QEZ06AGJ3RKJPBV14SY1V5BBFNAW33D96YPGZF.BNS-V2 mng-transfer id (unwrap-panic owner) recipient))
        ;; map remove the suspended name
        (ok true)
    )
)

;; bulk-name-transfer
;; description: Allows an admin principal to transfer a list of names
;; inputs: list of 25 name and recipient
(define-public (bulk-name-transfer (name-list (list 25 {name: (buff 48), recipient: principal, signature: (buff 65), transaction-type: (string-ascii 100)})))
    (ok (map name-transfer name-list))
)

;; bulk-name-register
;; description: Allows an admin principal to register a list of names
;; inputs: list of 25 name and its info
(define-public (bulk-name-register (name-list (list 25 {name: (buff 48), zonefile: (buff 8192), send-to: principal, signature: (buff 65), transaction-type: (string-ascii 100)})))
    (ok (map name-register name-list))
)

;; bulk-name-purge
;; description: Allows an admin principal to burn a list of names
;; inputs: list of 25 name 
(define-public (bulk-name-purge (name-list (list 25 {name: (buff 48), signature: (buff 65), transaction-type: (string-ascii 100)})))
    (ok (map name-purge name-list))
)

;; bulk-name-lock
;; description: Allows an admin principal to lock a list of names
;; inputs: list of 25 name 
(define-public (bulk-name-lock (name-list (list 25 {name: (buff 48), signature: (buff 65), transaction-type: (string-ascii 100)})))
    (ok (map name-lock name-list))
)

;; bulk-name-unlock
;; description: Allows an admin principal to unlock a list of names
;; inputs: list of 25 name 
(define-public (bulk-name-unlock (name-list (list 25 {name: (buff 48), signature: (buff 65), transaction-type: (string-ascii 100)})))
    (ok (map name-unlock name-list))
)

;; bulk-name-zonefile-update
;; description: Allows an admin principal to unlock a list of names
;; inputs: list of 25 name 
(define-public (bulk-name-zonefile-update (name-list (list 25 {name: (buff 48), zonefile: (buff 8192), signature: (buff 65), transaction-type: (string-ascii 100)})))
    (ok (map name-zonefile-update name-list))
)

;; add-admin-principal
;; description: Allows an admin principal to add another admin principal
;; inputs: new-admin/principal - The new admin principal
(define-public (add-admin-principal (new-admin-principal principal))
    (begin 
        ;; check that the caller is an admin principal
        (try! (is-admin contract-caller))
        ;; map set the new admin principal
        (ok (contract-call? .locker-registry add-admin new-admin-principal (get-pubkey-hash new-admin-principal)))
    )
)

;; remove-admin-principal
;; description: Allows an admin principal to remove an admin principal
;; inputs: admin-principal/principal - The admin principal to remove
(define-public (remove-admin-principal (admin-principal principal))
    (begin 
        ;; check that the caller is a privileged protocol principal
        (try! (is-admin contract-caller))
        ;; Make sure admin can't remove himself
        (asserts! (not (is-eq contract-caller admin-principal)) ERR-SAME-ADMIN)
        (unwrap! (contract-call? .locker-registry get-admin admin-principal) ERR-UNWRAP)
        ;; map remove the protocol principal
        (ok (contract-call? .locker-registry remove-admin admin-principal))
    )
)

;; change-admin-contract-for-namespace
;; description: Allows the manager contract to update the manager contract in both BNS-V2 and locker-registry
;; inputs: new-namespace-manager
(define-public (change-admin-contract-for-namespace (new-namespace-manager (optional principal)))
    (begin 
        ;; check that the caller is a privileged protocol principal
        (try! (is-admin contract-caller))
        (try! (contract-call? 'SP2QEZ06AGJ3RKJPBV14SY1V5BBFNAW33D96YPGZF.BNS-V2 mng-manager-transfer new-namespace-manager LOCKER-NAMESPACE))
        (try! (contract-call? .locker-registry change-namespace-manager-contract (unwrap! new-namespace-manager ERR-NO-MANAGER-PROVIDED)))
        (ok true)
    )
)

;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;
;;;; Private ;;;;
;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;

(define-private (get-pubkey-hash (addr principal))
  (get hash-bytes (unwrap-panic (principal-destruct? addr)))
)