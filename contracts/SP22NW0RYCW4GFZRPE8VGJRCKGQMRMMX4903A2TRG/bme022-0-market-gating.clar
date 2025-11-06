;; Title: BME021 Market Gating
;; Synopsis:
;; Efficient access control using merkle proofs.
;; Description:
;; Provides gating functionality based on account (can-access-by-account) and
;; ownership (can-access-by-ownership). The map of keys / roots are DAO managed.
;; Keys can by any data hash or a specific contract id hash. For ownership the user
;; must pass either an NFT or FT token and a merkle proof of ownership. For access
;; by account the account principal is passed along with the proof.

;; Define the SIP-009 and SIP-010 traits
(use-trait nft-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
(use-trait ft-trait 'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.sip-010-trait-ft-standard.sip-010-trait)
(impl-trait 'SP3JP0N1ZXGASRJ0F7QAHWFPGTVK9T2XNXDB908Z.extension-trait.extension-trait)

(define-constant err-unauthorised (err u2200))
(define-constant err-either-sip9-or-sip10-required (err u2201))
(define-constant err-token-contract-invalid (err u2202))
(define-constant err-token-ownership-invalid (err u2203))
(define-constant err-expecting-nft-contract (err u2204))
(define-constant err-expecting-ft-contract (err u2205))
(define-constant err-expecting-token-id (err u2206))
(define-constant err-not-nft-owner (err u2207))
(define-constant err-not-ft-owner (err u2208))
(define-constant err-expecting-nft-buffer (err u2209))
(define-constant err-expecting-ft-buffer (err u2210))
(define-constant err-expecting-valid-merkle-proof (err u2211))
(define-constant err-expecting-merkle-root-for-poll (err u2212))
(define-constant err-expecting-an-owner (err u2213))
(define-constant err-account-proof-invalid (err u2214))
(define-constant err-ownership-proof-invalid (err u2215))

;; Merkle roots for gated data
(define-map merkle-roots
  (buff 32)
  {
		merkle-root: (buff 32)
  }
)

(define-public (is-dao-or-extension)
	(ok (asserts! (or (is-eq tx-sender .bigmarket-dao) (contract-call? .bigmarket-dao is-extension contract-caller)) err-unauthorised))
)

(define-public (set-merkle-root (hashed-id (buff 32)) (root (buff 32)))
  (begin
    ;; Ensure only dao can set the root
    (try! (is-dao-or-extension))
    (map-set merkle-roots hashed-id { merkle-root: root})
    (print {event: "merkle-root", hashed-id: hashed-id, merkle-root: (map-get? merkle-roots hashed-id)})
    (ok true)
  )
)

(define-public (set-merkle-root-by-principal (contract-id principal) (root (buff 32)))
  (let
      (
        ;; construct the key from the contract-id
        (principal-contract (unwrap! (principal-destruct? contract-id) (err u1001)))
        (contract-bytes (get hash-bytes principal-contract))
        ;; panics if not contract principal
        (contract-name (unwrap! (to-consensus-buff? (unwrap! (get name principal-contract) err-expecting-an-owner)) err-expecting-an-owner))
        (contract-key (sha256 (concat contract-bytes contract-name )))
    )
      ;; Ensure only dao can set the root
      (try! (is-dao-or-extension))
      (map-set merkle-roots contract-key { merkle-root: root})
      (print {event: "set-merkle-root-by-principal", contract-id: contract-id, contract-name: contract-name, contract-key: contract-key, merkle-root: (map-get? merkle-roots contract-key)})
      (ok true)
))

(define-read-only (get-merkle-root (hashed-id (buff 32)))
    (map-get? merkle-roots hashed-id)
)

;; Verify a Merkle proof
(define-private (calculate-hash (hash1 (buff 32)) (hash2 (buff 32)) (position bool))
  (if position
      (sha256 (concat hash2 hash1))
      (sha256 (concat hash1 hash2))
  )
)

 (define-private (process-proof-step (proof-step (tuple (position bool) (hash (buff 32)))) (current (buff 32)))
  (let ((position (get position proof-step))
        (hash (get hash proof-step)))
    (calculate-hash current hash position)
  )
)

(define-private (verify-merkle-proof
    (leaf (buff 32))               ;; The leaf hash (token hash)
    (proof (list 10 (tuple (position bool) (hash (buff 32))))) 
    (root (buff 32)) 
  )
  (let
      (
        (calculated-root
          (fold process-proof-step proof leaf)
        )
      )
    (ok (is-eq calculated-root root))
  )
)


(define-private (verify-nft-ownership
    (nft-contract <nft-trait>) ;; NFT contract
    (voter principal)          ;; Voter's principal
    (token-id uint)            ;; Token ID
  )
  (let
      (
        (owner (unwrap! (contract-call? nft-contract get-owner token-id) err-not-nft-owner))
      )
    (ok (is-eq (unwrap! owner err-expecting-an-owner) voter))
  ))

(define-private (verify-ft-balance
    (ft-contract <ft-trait>) ;; FT contract
    (voter principal)        ;; Voter's principal
    (quantity uint)          ;; Required token quantity
  )
  (let
      (
        (balance (unwrap! (contract-call? ft-contract get-balance voter) err-not-ft-owner))
      )
    (ok (>= balance quantity))
  ))


;; Validate proof of access
(define-public (can-access-by-ownership
    (market-data-hash (buff 32))                ;; The hashed ID
    (nft-contract (optional <nft-trait>)) ;; Optional NFT contract
    (ft-contract (optional <ft-trait>))   ;; Optional FT contract
    (token-id (optional uint))         ;; Token ID for NFTs
    (proof (list 10 (tuple (position bool) (hash (buff 32)))))       ;; The Merkle proof
    (quantity uint)                    ;; Required token quantity
  )
  (let
      (
        ;; Determine if this is an NFT or FT contract
        (is-nft-contract (is-some nft-contract))

        ;; Fetch the Merkle root for the poll
        (root (unwrap! (map-get? merkle-roots market-data-hash) err-expecting-merkle-root-for-poll))

        ;; Compute the Merkle proof leaf
        (contract-id (if is-nft-contract
                         (unwrap! (to-consensus-buff? (as-contract (unwrap! nft-contract err-expecting-nft-contract))) err-expecting-nft-buffer)
                         (unwrap! (to-consensus-buff? (as-contract (unwrap! ft-contract err-expecting-ft-contract))) err-expecting-ft-buffer)))
        (leaf (sha256 contract-id))

        ;; Verify the Merkle proof
        (proof-valid (unwrap! (verify-merkle-proof leaf proof (get merkle-root root)) err-expecting-valid-merkle-proof))

        ;; Verify ownership or balance
        (ownership-valid
          (if is-nft-contract
              (unwrap! (verify-nft-ownership (unwrap! nft-contract err-expecting-nft-contract) tx-sender (unwrap! token-id err-expecting-token-id)) err-not-nft-owner)
              (unwrap! (verify-ft-balance (unwrap! ft-contract err-expecting-ft-contract) tx-sender quantity) err-not-ft-owner)))
      )
    ;; Ensure both conditions are satisfied
    (asserts! proof-valid err-ownership-proof-invalid)
    (asserts! ownership-valid err-token-ownership-invalid)
    (ok true)
  ))

(define-public (can-access-by-account
    (sender principal)
    (proof (list 10 (tuple (position bool) (hash (buff 32)))))       ;; The Merkle proof
  )
  (let
      (
        ;; Fetch the Merkle root for the poll
        (principal-contract (unwrap! (principal-destruct? tx-sender) (err u1001)))
        (contract-bytes (get hash-bytes principal-contract))
        (contract-name (unwrap! (to-consensus-buff? (unwrap! (get name principal-contract) err-expecting-an-owner)) err-expecting-an-owner))
        (contract-key (sha256 (concat contract-bytes contract-name )))
        (root (unwrap! (map-get? merkle-roots contract-key) err-expecting-merkle-root-for-poll))
    
        ;; Compute the Merkle proof leaf
        (principal-data (unwrap! (principal-destruct? sender) (err u1001)))
        (leaf (sha256 (get hash-bytes principal-data)))

        ;; Verify the Merkle proof
        (proof-valid (unwrap! (verify-merkle-proof leaf proof (get merkle-root root)) err-expecting-valid-merkle-proof))
    )
    ;; Ensure both conditions are satisfied
    (asserts! proof-valid err-account-proof-invalid)
    (print {event: "can-access-by-account", contract-key: contract-key, contract-name: contract-name, root: root, leaf: leaf, sender: sender, txsender: tx-sender, proof-valid: proof-valid})
    (ok true)
  ))


  ;; --- Extension callback
(define-public (callback (sender principal) (memo (buff 34)))
	(ok true)
)

