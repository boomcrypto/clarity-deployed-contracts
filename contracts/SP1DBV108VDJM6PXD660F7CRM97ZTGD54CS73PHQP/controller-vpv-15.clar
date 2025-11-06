;; title: controller-vpv-15

(define-constant contract-deployer tx-sender)
(define-constant ERR_NOT_AUTH (err u100))
(define-constant ERR_UNKNOWN_CONTRACT (err u101))
(define-constant ERR_CONTRACTS_DISABLED (err u102))
(define-constant ERR_UNKNOWN_ADMIN (err u103))
(define-constant ERR_LIST_OVERFLOW (err u104))


;; Keeper for executing the maintain-vaults function
(define-data-var keeper principal 'SP1W0BTVH2TASXZMG219X3Y6C2BE01KMQ6TT880YF)

;; Proposed Admin
(define-data-var proposed-admin principal 'SMXMB6WZDTGHAGQ69J5S5RVHA70SWWPDWBEET01Z)

;; Admin for maintaining the sensitive elements of the protocol
(define-data-var admin principal 'SMXMB6WZDTGHAGQ69J5S5RVHA70SWWPDWBEET01Z)

;; Map of privileged protocol principals
(define-map privileged-protocol-principals principal bool)

;; Map of hot pause principals
(define-map hot-pause-principals principal bool)

;; Lists to track all privileged principals for enumeration
(define-data-var privileged-protocol-principals-list (list 100 principal) (list))
(define-data-var hot-pause-principals-list (list 100 principal) (list))

;; List to track all approved contracts for enumeration
(define-data-var approved-contracts-list (list 100 principal) (list))

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
  (if (and (not (is-eq tx-sender contract-caller)) (is-eq (var-get contracts-allowed) true)) 
    (ok true)
    (if (is-eq tx-sender contract-caller)
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

;; Get contracts allowed status
(define-read-only (get-contracts-allowed)
	(ok (var-get contracts-allowed))
)

;; Get non-keeper allowed status
(define-read-only (get-non-keeper-allowed)
	(ok (var-get non-keeper-allowed))
)

;; Get all privileged protocol principals
(define-read-only (get-all-privileged-protocol-principals)
	(ok (var-get privileged-protocol-principals-list))
)

;; Get all hot pause principals
(define-read-only (get-all-hot-pause-principals)
	(ok (var-get hot-pause-principals-list))
)

;; Get all approved contracts
(define-read-only (get-all-approved-contracts)
	(ok (var-get approved-contracts-list))
)

;;;; Public ;;;;

;; set-contracts-disabled
(define-public (set-contracts-allowed (allowed bool))
  (begin 
    (try! (is-protocol-caller contract-caller))
    (ok (var-set contracts-allowed allowed))
  )
)

;; set-non-keeper-allowed
(define-public (keeper-allow-all (allowed bool))
  (begin 
    (try! (is-protocol-caller contract-caller))
    (ok (var-set non-keeper-allowed allowed))
  )
)

;; add-privileged-protocol-principal
(define-public (add-privileged-protocol-principal (new-protocol-principal principal))
	(begin 
		(try! (is-protocol-caller contract-caller))
		(map-set privileged-protocol-principals new-protocol-principal true)
		(ok (var-set privileged-protocol-principals-list (unwrap! (as-max-len? (append (var-get privileged-protocol-principals-list) new-protocol-principal) u100) (err u1))))
	)
)

;; remove-privileged-protocol-principal
(define-public (remove-privileged-protocol-principal (protocol-principal principal))
	(begin 
		(try! (is-protocol-caller contract-caller))
		(map-delete privileged-protocol-principals protocol-principal)
		;; Remove from the list as well to keep it in sync
		(ok (var-set privileged-protocol-principals-list (get new-list (try! (fold remove-principal-from-list (var-get privileged-protocol-principals-list) (ok {compare-principal: protocol-principal, new-list: (list )}))))))
	)
)

;; add hot pause principal
(define-public (add-hot-pause-principal (add-principal principal))
	(begin 
		(try! (is-protocol-caller contract-caller))
		(map-set hot-pause-principals add-principal true)
		(ok (var-set hot-pause-principals-list (unwrap! (as-max-len? (append (var-get hot-pause-principals-list) add-principal) u100) (err u1))))
	)
)

;; remove hot pause principal
(define-public (remove-hot-pause-principal (remove-principal principal))
	(begin 
		(try! (is-protocol-caller contract-caller))
		(map-delete hot-pause-principals remove-principal)
		;; Remove from the list as well to keep it in sync
		(ok (var-set hot-pause-principals-list (get new-list (try! (fold remove-principal-from-list (var-get hot-pause-principals-list) (ok {compare-principal: remove-principal, new-list: (list )}))))))
	)
)

;; add-supported-contract
(define-public (add-supported-contract (contract-key (string-ascii 256)) (contract-address principal) (qualified-contract principal))
	(begin 
		(try! (is-protocol-caller contract-caller))
		(map-set contracts (tuple (name contract-key)) (tuple (address contract-address) (qualified-name qualified-contract)))
		;; Add to the list as well to keep it in sync
		(ok (var-set approved-contracts-list (unwrap! (as-max-len? (append (var-get approved-contracts-list) qualified-contract) u100) ERR_LIST_OVERFLOW)))
	)
)

;; remove-supported-contract
(define-public (remove-supported-contract (contract-key (string-ascii 256)))
	(begin 
		(try! (is-protocol-caller contract-caller))
		;; Get contract info before deleting it
		(let ((contract-info (map-get? contracts { name: contract-key })))
			(if (is-none contract-info)
				(ok true)
				(begin
					(map-delete contracts (tuple (name contract-key)))
					;; Remove from the list as well to keep it in sync
					(ok (var-set approved-contracts-list (get new-list (try! (fold remove-contract-from-list (var-get approved-contracts-list) (ok {found: false, compare-contract-principal: (get qualified-name (unwrap-panic contract-info)), new-list: (list )}))))))
				)
			)
		)
	)
)

;; set-keeper
(define-public (set-keeper (new-keeper principal))
	(begin 
		(try! (is-protocol-caller contract-caller))
		;; set the new keeper
		(ok (var-set keeper new-keeper))
	)
)

;; propose-admin
(define-public (propose-admin (new-admin principal))
	(begin 
		(try! (is-protocol-caller contract-caller))
		;; set the new admin
		(ok (var-set proposed-admin new-admin))
	)
)

;; claim-admin
(define-public (claim-admin)
	(begin 
		(asserts! (is-eq tx-sender (var-get proposed-admin)) ERR_UNKNOWN_ADMIN)
		;; set the new admin
		(ok (var-set admin tx-sender))
	)
)


;; check if caller is a contract
(define-private (is-standard-principal-call (caller principal))
  (is-none (get name (unwrap! (principal-destruct? caller) false)))
)

;; remove-principal-from-list
;; description: helper function for removing any principal from a list
(define-private (remove-principal-from-list (list-principal principal) (helper-tuple-response (response {compare-principal: principal, new-list: (list 100 principal)} uint)))
    (match helper-tuple-response
        helper-tuple
            (let 
                (
                    (current-compare-principal (get compare-principal helper-tuple))
                    (current-new-list (get new-list helper-tuple))
                )
                ;; Only append if this principal is NOT the one we want to remove
                (if (is-eq list-principal current-compare-principal)
                    ;; Skip this principal (don't append to new-list)
                    (ok helper-tuple)
                    ;; Keep this principal (append to new-list)
                    (ok (merge 
                        helper-tuple
                        {new-list: (unwrap! (as-max-len? (append current-new-list list-principal) u100) ERR_LIST_OVERFLOW)}
                    ))
                )
            )
        err-response
            ERR_LIST_OVERFLOW
    )
)

;; remove-contract-from-list
;; description: helper function for removing any contract principal from a list
(define-private (remove-contract-from-list (list-contract-principal principal) (helper-tuple-response (response {found: bool, compare-contract-principal: principal, new-list: (list 100 principal)} uint)))
    (match helper-tuple-response
        helper-tuple
            (let 
                (
                    (current-found (get found helper-tuple))
                    (current-compare-contract-principal (get compare-contract-principal helper-tuple))
                    (current-new-list (get new-list helper-tuple))
                )
                ;; check if contract principal was found
                (if current-found
                    ;; contract principal was found & skipped, continue appending existing list-contract-principal to new-list
                    (ok (merge 
                        helper-tuple
                        {new-list: (unwrap! (as-max-len? (append current-new-list list-contract-principal) u100) ERR_LIST_OVERFLOW)}
                    ))
                    ;; contract principal was not found, continue searching for compare-contract-principal
                    (if (is-eq list-contract-principal current-compare-contract-principal)
                        ;; contract principal was found, skip appending to new-list & set found to true
                        (ok (merge 
                            helper-tuple
                            {found: true, new-list: current-new-list}
                        ))
                        ;; contract principal was not found, continue appending existing list-contract-principal to new-list
                        (ok (merge 
                            helper-tuple
                            {new-list: (unwrap! (as-max-len? (append current-new-list list-contract-principal) u100) ERR_LIST_OVERFLOW)}
                        ))
                    )
                )
            )
        err-response
            ERR_LIST_OVERFLOW
    )
)

;; Initialization
(map-set privileged-protocol-principals .registry-vpv-15 true)
(map-set privileged-protocol-principals .vault-vpv-15 true)
(map-set privileged-protocol-principals .redeem-vpv-15 true)
(map-set privileged-protocol-principals .stability-vpv-15 true)
(map-set privileged-protocol-principals .timelock-vpv-15 true)

;; Initialize the privileged principals lists
(var-set privileged-protocol-principals-list (list .registry-vpv-15 .vault-vpv-15 .redeem-vpv-15 .stability-vpv-15 .timelock-vpv-15))

;; Initialize the hot pause principals list
(map-set hot-pause-principals 'SP1JM4Q9FSSDPKNZHKY0E8SKRCD67JBCG43V8B216 true)
(map-set hot-pause-principals 'SP25APMWN5J7AXK16BKW9ESWR3S07AG2Z4W70KSQP true)
(map-set hot-pause-principals 'SP3QKP2BPDQANNB6T5WGVD37C36YKW0FJT70PY8HB true)
(var-set hot-pause-principals-list (list 'SP1JM4Q9FSSDPKNZHKY0E8SKRCD67JBCG43V8B216 'SP25APMWN5J7AXK16BKW9ESWR3S07AG2Z4W70KSQP 'SP3QKP2BPDQANNB6T5WGVD37C36YKW0FJT70PY8HB))

;; Initialize the approved contracts list
(var-set approved-contracts-list (list 
	'SP1DBV108VDJM6PXD660F7CRM97ZTGD54CS73PHQP.bsd-mock-vpv-15
	'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token
	'SP1DBV108VDJM6PXD660F7CRM97ZTGD54CS73PHQP.oracle-vpv-15
	'SP1DBV108VDJM6PXD660F7CRM97ZTGD54CS73PHQP.registry-vpv-15
	'SP1DBV108VDJM6PXD660F7CRM97ZTGD54CS73PHQP.vault-vpv-15
	'SP1DBV108VDJM6PXD660F7CRM97ZTGD54CS73PHQP.stability-vpv-15
	'SP1DBV108VDJM6PXD660F7CRM97ZTGD54CS73PHQP.sorted-vaults-vpv-15
))

(map-set contracts
    { name: "bsd" }
    {
      address: 'SP1DBV108VDJM6PXD660F7CRM97ZTGD54CS73PHQP,
      qualified-name: 'SP1DBV108VDJM6PXD660F7CRM97ZTGD54CS73PHQP.bsd-mock-vpv-15
    }
)

(map-set contracts
    { name: "sbtc" }
    {
      address: 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4,
      qualified-name: 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token
    }
)

(map-set contracts
    { name: "oracle" }
    {
      address: 'SP1DBV108VDJM6PXD660F7CRM97ZTGD54CS73PHQP,
      qualified-name: 'SP1DBV108VDJM6PXD660F7CRM97ZTGD54CS73PHQP.oracle-vpv-15
    }
)

(map-set contracts
    { name: "registry" }
    {
      address: 'SP1DBV108VDJM6PXD660F7CRM97ZTGD54CS73PHQP,
      qualified-name: 'SP1DBV108VDJM6PXD660F7CRM97ZTGD54CS73PHQP.registry-vpv-15
    }
)

(map-set contracts
    { name: "vault" }
    {
      address: 'SP1DBV108VDJM6PXD660F7CRM97ZTGD54CS73PHQP,
      qualified-name: 'SP1DBV108VDJM6PXD660F7CRM97ZTGD54CS73PHQP.vault-vpv-15
    }
)

(map-set contracts
    { name: "stability" }
    {
      address: 'SP1DBV108VDJM6PXD660F7CRM97ZTGD54CS73PHQP,
      qualified-name: 'SP1DBV108VDJM6PXD660F7CRM97ZTGD54CS73PHQP.stability-vpv-15
    }
)

(map-set contracts
    { name: "sorted-vaults" }
    {
      address: 'SP1DBV108VDJM6PXD660F7CRM97ZTGD54CS73PHQP,
      qualified-name: 'SP1DBV108VDJM6PXD660F7CRM97ZTGD54CS73PHQP.sorted-vaults-vpv-15
    }
)
