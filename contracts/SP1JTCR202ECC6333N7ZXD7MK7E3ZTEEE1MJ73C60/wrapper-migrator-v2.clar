;; The wrapper migrator contract provides a way for users to upgrade a
;; BNS legacy name to BNSx.
;; 
;; The high-level flow for using this migrator is:
;; 
;; - Deploy a wrapper contract (see [`.name-wrapper`](`./name-wrapper.md`))
;; - Verify the wrapper contract
;; - Finalize the migration
;; 
;; Because Stacks contracts don't have a way to verify the source code of
;; another contract, each wrapper contract must be verified by requesting a
;; signature off-chain. This prevents malicious users from deploying "fact" wrapper
;; contracts without the same guarantees.
;; 
;; For more detail on how each wrapper is verified, see [`verify-wrapper`](#verify-wrapper)
;; 
;; Authorization for valid wrapper verifiers is only allowed through extensions with the
;; "mig-signer" role. By default, the contract deployer is a valid signer.
;; 
;; During migration, the legacy name is transferred to the wrapper contract. Then,
;; this contract interfaces with the [`.bnsx-registry`](`./core/name-registry.md`)
;; contract to mint a new BNSx name.

(define-constant ROLE "mig-signer")

(define-constant ERR_NO_NAME (err u6000))
(define-constant ERR_UNAUTHORIZED (err u6001))
(define-constant ERR_RECOVER (err u6002))
(define-constant ERR_INVALID_CONTRACT_NAME (err u6003))
(define-constant ERR_NAME_TRANSFER (err u6004))
(define-constant ERR_WRAPPER_USED (err u6005))

(define-map migrator-signers-map (buff 20) bool)

(define-map name-wrapper-map uint principal)
(define-map wrapper-name-map principal uint)

(define-data-var wrapped-id-var uint u0)
(define-data-var wrapper-deployer (buff 20) (get hash-bytes (unwrap-panic (principal-destruct? tx-sender))))

(define-constant network-addr-version (if is-in-mainnet 0x16 0x1a))

;; CONSTRUCTOR

(set-signers-iter { signer: tx-sender, enabled: true })

;; DAO operations

;; Authorization check - only extensions with the role "mig-signer" can add/remove
;; wrapper verifiers.
(define-public (is-dao-or-extension)
  ;; (ok (asserts! (or (is-eq tx-sender .bnsx-extensions) (contract-call? .bnsx-extensions has-role-or-extension contract-caller ROLE)) ERR_UNAUTHORIZED))
  (ok (asserts! (contract-call? .bnsx-extensions has-role-or-extension contract-caller ROLE) ERR_UNAUTHORIZED))
)

;; #[allow(unchecked_data)]
(define-private (set-signers-iter (item { signer: principal, enabled: bool }))
  (let
    (
      (pubkey (get hash-bytes (unwrap-panic (principal-destruct? (get signer item)))))
    )
    (print pubkey)
    (map-set migrator-signers-map pubkey (get enabled item))
    pubkey
  )
)

;; Set valid wrapper verifiers
;; 
;; @param signers; a list of { signer: principal, enabled: bool } tuples.
;; Existing verifiers can be removed by setting `enabled` to false.
(define-public (set-signers (signers (list 50 { signer: principal, enabled: bool })))
  (begin
    (try! (is-dao-or-extension))
    (ok (map set-signers-iter signers))
  )
)

;; Migration

;; Migrate a name to BNSx
;; 
;; This function has three main steps:
;; 
;; - Verify the wrapper ([`verify-wrapper`](#verify-wrapper))
;; - Transfer the BNS legacy name to the wrapper ([`resolve-and-transfer`](#resolve-and-transfer))
;; - Register the name in the BNSx name registry ([`.bnsx-registry#register`](`./core/name-registry#register.md`))
;; 
;; @param wrapper; the principal of the wrapper contract that will be used
;; @param signature; a signature attesting to the validity of the wrapper contract
;; @param recipient; a principal that will receive the BNSx name. Useful for consolidating
;; names into one wallet.
(define-public (migrate (wrapper principal) (signature (buff 65)) (recipient principal))
  (let
    (
      ;; #[filter(wrapper)]
      (wrapper-ok (try! (verify-wrapper wrapper tx-sender signature)))
      (properties (try! (resolve-and-transfer wrapper)))
      (name (get name properties))
      (namespace (get namespace properties))
      (id (try! (contract-call? .bnsx-registry register
        {
          name: name,
          namespace: namespace,
        }
        recipient
      )))
      (meta (merge { id: id } properties))
    )
    (print {
      topic: "migrate",
      wrapper: wrapper,
      id: id,
    })
    (asserts! (map-insert name-wrapper-map id wrapper) ERR_WRAPPER_USED)
    (asserts! (map-insert wrapper-name-map wrapper id) ERR_WRAPPER_USED)

    (ok meta)
  )
)


;; Signature validation

;; Verify a wrapper principal.
;; 
;; The message being signed is the Clarity-serialized representation of a tuple with: 
;; - `wrapper`: the principal of the wrapper contract
;; - `sender`: the sender of this migration
;; 
;; The pubkey is recovered from the signature. The `hash160` of this pubkey is then checked
;; to ensure that pubkey hash is stored as a valid signer.
;; 
;; @throws if the signature is invalid (cannot be recovered)
;; 
;; @throws if the pubkey is not a valid verifier
;; 
;; #[filter(wrapper)]
(define-read-only (verify-wrapper (wrapper principal) (sender principal) (signature (buff 65)))
  (let
    (
      (msg (hash-migration-data wrapper sender))
      (pubkey (unwrap! (secp256k1-recover? msg signature) ERR_RECOVER))
      (pubkey-hash (hash160 pubkey))
    )
    (asserts! (default-to false (map-get? migrator-signers-map pubkey-hash)) ERR_UNAUTHORIZED)
    (ok true)
  )
)

;; Helper method to check if a given principal is a valid verifier
(define-read-only (is-valid-signer (signer principal))
  (let
    (
      (pubkey (get hash-bytes (unwrap-panic (principal-destruct? signer))))
    )
    (default-to false (map-get? migrator-signers-map pubkey))
  )
)

(define-read-only (hash-principal (wrapper principal))
  (sha256 (unwrap-panic (to-consensus-buff? wrapper)))
)

(define-read-only (hash-migration-data (wrapper principal) (sender principal))
  (sha256 (unwrap-panic (to-consensus-buff? {
    wrapper: wrapper,
    sender: sender,
  })))
)

(define-read-only (construct (hash-bytes (buff 20)))
  (principal-construct? network-addr-version hash-bytes)
)

;; Transfer to a new contract

;; Fetch the BNS legacy name and name properties owned by a given account.
;; 
;; @throws if the account does not own a valid name
;; 
;; @throws if the name owned by the account is expired
(define-read-only (get-legacy-name (account principal))
  (match (contract-call? 'SP000000000000000000002Q6VF78.bns resolve-principal account)
    name (let
      (
        (properties (unwrap-panic (contract-call? 'SP000000000000000000002Q6VF78.bns name-resolve (get namespace name) (get name name))))
      )
      (ok (merge name properties))
    )
    e ERR_NO_NAME
  )
)

;; Transfer an account's BNS legacy name to a wrapper contract.
;; #[allow(unchecked_data)]
(define-private (resolve-and-transfer (wrapper principal))
  (let
    (
      (name (try! (get-legacy-name tx-sender)))
    )
    (match (contract-call? 'SP000000000000000000002Q6VF78.bns name-transfer (get namespace name) (get name name) wrapper (some (get zonefile-hash name)))
      success (begin
        (print (merge name {
          topic: "v1-name-transfer",
          wrapper: wrapper,
        }))
        (ok name)
      )
      err-code (begin
        (print {
          topic: "name-transfer-error",
          bns-error: err-code,
          sender: tx-sender,
          name: name,
        })
        ERR_NAME_TRANSFER
      )
    )
  )
)

;; Getters

;; Helper method to fetch the BNS legacy name that was previously transferred to
;; a given wrapper contract.
(define-read-only (get-wrapper-name (wrapper principal)) (map-get? wrapper-name-map wrapper))

;; Helper method to fetch the wrapper contract that was used during migration of a
;; given name
;; 
;; @param name; the name ID of a BNSx name
(define-read-only (get-name-wrapper (name uint)) (map-get? name-wrapper-map name))
