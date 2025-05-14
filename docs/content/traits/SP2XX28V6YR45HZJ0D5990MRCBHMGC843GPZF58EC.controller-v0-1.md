---
title: "Trait controller-v0-1"
draft: true
---
```
;; title: controller-v1-0

(define-constant contract-deployer tx-sender)
(define-constant ERR_NOT_AUTH (err u100))
(define-constant ERR_UNKNOWN_CONTRACT (err u101))

;; Keeper for executing the maintain-vaults function
(define-data-var keeper principal contract-deployer)

;; Admin for maintaining the sensitive elements of the protocol
(define-data-var admin principal contract-deployer)

;; Map of privileged protocol principals
(define-map privileged-protocol-principals principal bool)

;; Map of hot pause principals
(define-map hot-pause-principals principal bool)

;; Map of approved contract/traits for the protocol
(define-map contracts
  { name: (string-ascii 256) }
  {
    address: principal,
    qualified-name: principal
  }
)

;;; Read ;;;

;; Is the caller a privileged protocol principal?
(define-read-only (is-protocol-caller (who principal))
	(ok (asserts! (default-to false (map-get? privileged-protocol-principals who)) ERR_NOT_AUTH))
)

;; Is the caller a hot pause principal?
(define-read-only (is-hot-pause-caller (who principal))
	(ok (asserts! (default-to false (map-get? hot-pause-principals who)) ERR_NOT_AUTH))
)

(define-read-only (check-approved-contract (name (string-ascii 256)) (caller principal))
	(ok (asserts! (is-eq caller (unwrap! (get qualified-name (map-get? contracts { name: name })) ERR_UNKNOWN_CONTRACT)) ERR_NOT_AUTH))
)

;; Is the caller the defined keeper?
(define-read-only (is-keeper (who principal))
	(ok (is-eq who (var-get keeper)))
)

;; Is the caller the admin?
(define-read-only (is-admin (who principal))
	(ok (asserts! (is-eq who (var-get admin)) ERR_NOT_AUTH))
)

;;;; Public ;;;;

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

;; Initialization
(map-set privileged-protocol-principals (var-get admin) true)
(map-set privileged-protocol-principals .registry-v1-0 true)
(map-set privileged-protocol-principals .vault-v1-0 true)
(map-set privileged-protocol-principals .redeem-v1-0 true)
(map-set privileged-protocol-principals .stability-v1-0 true)

(map-set contracts
    { name: "bsd" }
    {
      address: 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM,
      qualified-name: 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.bsd-mock
    }
)

(map-set contracts
    { name: "sbtc" }
    {
      address: 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM,
      qualified-name: 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.sBTC-mock
    }
)

(map-set contracts
    { name: "oracle" }
    {
      address: 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM,
      qualified-name: 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.oracle-v1-0
    }
)

(map-set contracts
    { name: "registry" }
    {
      address: 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM,
      qualified-name: 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.registry-v1-0
    }
)

(map-set contracts
    { name: "vault" }
    {
      address: 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM,
      qualified-name: 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.vault-v1-0
    }
)

(map-set contracts
    { name: "stability" }
    {
      address: 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM,
      qualified-name: 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.stability-v1-0
    }
)

```
