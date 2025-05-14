---
title: "Trait controller-vpv-2"
draft: true
---
```
;; title: controller-vpv-2

(define-constant contract-deployer tx-sender)
(define-constant ERR_NOT_AUTH (err u100))
(define-constant ERR_UNKNOWN_CONTRACT (err u101))
(define-constant ERR_CONTRACTS_DISABLED (err u102))


;; Keeper for executing the maintain-vaults function
(define-data-var keeper principal contract-deployer)

;; Admin for maintaining the sensitive elements of the protocol
(define-data-var admin principal contract-deployer)

;; Map of privileged protocol principals
(define-map privileged-protocol-principals principal bool)

;; Map of hot pause principals
(define-map hot-pause-principals principal bool)

;; Flag to enable/disable contracts from interacting with the protocol
(define-data-var contracts-allowed bool true)

;; Flag to enable non-keeper to run keeper methods
(define-data-var non-keeper-allowed bool false)

;; Map of approved contract/traits for the protocol
(define-map contracts
  { name: (string-ascii 256) }
  {
    address: principal,
    qualified-name: principal
  }
)

;;; Read ;;;

;; Verify if principal is a contract and if contracts are allowed
(define-read-only (verify-principal (caller principal))
  (if (and (is-eq (is-standard-principal-call caller) false) (is-eq (var-get contracts-allowed) true)) 
    (ok true)
    (if (is-eq (is-standard-principal-call caller) true)
      (ok true)
      ERR_CONTRACTS_DISABLED
    )
  )
)


;; Is the caller a privileged protocol principal?
(define-read-only (is-protocol-caller (who principal))
	(ok (asserts! (default-to false (map-get? privileged-protocol-principals who)) ERR_NOT_AUTH))
)

;; Is the caller a hot pause principal?
(define-read-only (is-hot-pause-caller (who principal))
	(ok (asserts! (default-to false (map-get? hot-pause-principals who)) ERR_NOT_AUTH))
)

(define-read-only (check-approved-contract (name (string-ascii 256)) (caller principal))
	(ok (asserts! (is-eq caller (unwrap! (get qualified-name (map-get? contracts { name: name })) ERR_UNKNOWN_CONTRACT)) ERR_UNKNOWN_CONTRACT))
)

;; Is the caller the defined keeper or are all principals allowed
(define-read-only (is-keeper (who principal))
	(ok (or (is-eq who (var-get keeper)) (var-get non-keeper-allowed)))
)

;; Is the caller the admin?
(define-read-only (is-admin (who principal))
	(ok (asserts! (is-eq who (var-get admin)) ERR_NOT_AUTH))
)

;;;; Public ;;;;

;; set-contracts-disabled
(define-public (set-contracts-allowed (allowed bool))
  (begin 
    (try! (is-admin tx-sender))
    (ok (var-set contracts-allowed allowed))
  )
)

;; set-non-keeper-allowed
(define-public (keeper-allow-all (allowed bool))
  (begin 
    (try! (is-admin tx-sender))
    (ok (var-set non-keeper-allowed allowed))
  )
)

;; add-privileged-protocol-principal
(define-public (add-privileged-protocol-principal (new-protocol-principal principal))
	(begin 
		(try! (is-admin tx-sender))
		(ok (map-set privileged-protocol-principals new-protocol-principal true))
	)
)

;; remove-privileged-protocol-principal
(define-public (remove-privileged-protocol-principal (protocol-principal principal))
	(begin 
		(try! (is-admin tx-sender))
		(ok (map-delete privileged-protocol-principals protocol-principal))
	)
)

;; add hot pause principal
(define-public (add-hot-pause-principal (add-principal principal))
	(begin 
		(try! (is-admin tx-sender))
		(ok (map-set hot-pause-principals add-principal true))
	)
)

;; remove hot pause principal
(define-public (remove-hot-pause-principal (remove-principal principal))
	(begin 
		(try! (is-admin tx-sender))
		(ok (map-delete hot-pause-principals remove-principal))
	)
)

;; add-supported-contract
(define-public (add-supported-contract (contract-key (string-ascii 256)) (contract-address principal) (qualified-contract principal))
	(begin 
		(try! (is-admin tx-sender))
		(ok (map-set contracts (tuple (name contract-key)) (tuple (address contract-address) (qualified-name qualified-contract))))
	)
)

;; remove-supported-contract
(define-public (remove-supported-contract (contract-key (string-ascii 256)))
	(begin 
		(try! (is-admin tx-sender))
		(ok (map-delete contracts (tuple (name contract-key))))
	)
)

;; set-keeper
(define-public (set-keeper (new-keeper principal))
	(begin 
		(try! (is-admin tx-sender))
		;; set the new keeper
		(ok (var-set keeper new-keeper))
	)
)

;; set-admin
(define-public (set-admin (new-admin principal))
	(begin 
		(try! (is-admin tx-sender))
		;; set the new admin
		(ok (var-set admin new-admin))
	)
)

;; check if caller is a contract
(define-private (is-standard-principal-call (caller principal))
  (is-none (get name (unwrap! (principal-destruct? caller) false)))
)

;; Initialization
(map-set privileged-protocol-principals (var-get admin) true)
(map-set privileged-protocol-principals .registry-vpv-2 true)
(map-set privileged-protocol-principals .vault-vpv-2 true)
(map-set privileged-protocol-principals .redeem-vpv-2 true)
(map-set privileged-protocol-principals .stability-vpv-2 true)

(map-set contracts
    { name: "bsd" }
    {
      address: 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM,
      qualified-name: 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.bsd-mock-vpv-2
    }
)

(map-set contracts
    { name: "sbtc" }
    {
      address: 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM,
      qualified-name: 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.sBTC-mock-vpv-2
    }
)

(map-set contracts
    { name: "oracle" }
    {
      address: 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM,
      qualified-name: 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.oracle-vpv-2
    }
)

(map-set contracts
    { name: "registry" }
    {
      address: 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM,
      qualified-name: 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.registry-vpv-2
    }
)

(map-set contracts
    { name: "vault" }
    {
      address: 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM,
      qualified-name: 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.vault-vpv-2
    }
)

(map-set contracts
    { name: "stability" }
    {
      address: 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM,
      qualified-name: 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.stability-vpv-2
    }
)

(map-set contracts
    { name: "sorted-vaults" }
    {
      address: 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM,
      qualified-name: 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.sorted-vaults-vpv-2
    }
)

```
