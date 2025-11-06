;; title: timelock-vpv-16
;; version: 0.1.0
;; summary: Simple timelock contract for vault and stability protocol operations
;; description: This contract implements a simple timelock mechanism that stores proposals in a queue
;; and executes them after the timelock period has expired.

;; Use traits
(use-trait sbtc-trait .sip-010-trait-ft-standard-vpv-16.sip-010-trait)
(use-trait vault-trait .vault-trait-vpv-16.vault-trait)
(use-trait stability-trait .stability-trait-vpv-16.stability-trait)
(use-trait bsd-trait .bsd-trait-vpv-16.bsd-trait)

;; Constants
(define-constant ERR_INVALID_DELAY (err u801))
(define-constant ERR_PROPOSAL_NOT_FOUND (err u802))
(define-constant ERR_PROPOSAL_NOT_READY (err u803))
(define-constant ERR_PROPOSAL_ALREADY_EXECUTED (err u804))
(define-constant ERR_INVALID_PROPOSAL_TYPE (err u805))
(define-constant ERR_CANNOT_REMOVE_SELF (err u806))

;; Proposal Types
(define-constant PROPOSAL_TYPE_VAULT_PROTOCOL_TRANSFER "vault-protocol-transfer-sbtc")
(define-constant PROPOSAL_TYPE_STABILITY_PROTOCOL_TRANSFER "stability-protocol-transfer-sbtc")
(define-constant PROPOSAL_TYPE_STABILITY_PROTOCOL_TRANSFER_BSD "stability-protocol-transfer-bsd")
(define-constant PROPOSAL_TYPE_DECAY_PARAMS "decay-params")
(define-constant PROPOSAL_TYPE_VAULT_PARAMS "vault-params")
(define-constant PROPOSAL_TYPE_BORROW_PARAMS "borrow-params")
(define-constant PROPOSAL_TYPE_REDEEM_PARAMS "redeem-params")
(define-constant PROPOSAL_TYPE_GLOBAL_PARAMS "global-params")
(define-constant PROPOSAL_TYPE_ADD_HOT_PAUSE_PRINCIPAL "add-hot-pause-principal")
(define-constant PROPOSAL_TYPE_REMOVE_HOT_PAUSE_PRINCIPAL "remove-hot-pause-principal")
(define-constant PROPOSAL_TYPE_ADD_SUPPORTED_CONTRACT "add-supported-contract")
(define-constant PROPOSAL_TYPE_REMOVE_SUPPORTED_CONTRACT "remove-supported-contract")
(define-constant PROPOSAL_TYPE_SET_KEEPER "set-keeper")
(define-constant PROPOSAL_TYPE_ADD_CONTROLLER_PRIVILEGED_PROTOCOL_PRINCIPAL "add-controller-privileged-protocol-principal")
(define-constant PROPOSAL_TYPE_REMOVE_CONTROLLER_PRIVILEGED_PROTOCOL_PRINCIPAL "remove-controller-privileged-protocol-principal")
(define-constant PROPOSAL_TYPE_PROPOSE_ADMIN "propose-admin")
(define-constant PROPOSAL_TYPE_SET_CONTRACTS_ALLOWED "set-contracts-allowed")
(define-constant PROPOSAL_TYPE_KEEPER_ALLOW_ALL "keeper-allow-all")
(define-constant PROPOSAL_TYPE_BSD_PROTOCOL_TRANSFER "bsd-protocol-transfer")
(define-constant PROPOSAL_TYPE_BSD_ADD_PRIVILEGED_PRINCIPAL "bsd-add-privileged-principal")
(define-constant PROPOSAL_TYPE_BSD_REMOVE_PRIVILEGED_PRINCIPAL "bsd-remove-privileged-principal")
(define-constant PROPOSAL_TYPE_BSD_PROTOCOL_BURN "bsd-protocol-burn")
(define-constant PROPOSAL_TYPE_BSD_PROPOSE_OWNER "bsd-propose-owner")
(define-constant PROPOSAL_TYPE_BSD_PROPOSE_TOKEN_URI "bsd-propose-token-uri")

;; Data variables
(define-data-var proposal-counter uint u0)

;; Queue to store all proposals with embedded arguments
(define-data-var proposal-queue (list 100 {
    id: uint,
    proposal-type: (string-ascii 256),
    eta: uint,
    args: (buff 10000)
}) (list))

;; ****************
;; Read-only functions
;; ****************


(define-read-only (get-proposal-counter)
    (ok (var-get proposal-counter))
)

(define-read-only (get-proposal-queue)
    (ok (var-get proposal-queue))
)

;; Get proposal by ID
(define-read-only (get-proposal (proposal-id uint))
    (find-proposal-by-id proposal-id)
)

;; Check if proposal is ready for execution
(define-read-only (is-proposal-ready (proposal-id uint))
    (let ((proposal (unwrap! (get-proposal proposal-id) ERR_PROPOSAL_NOT_FOUND)))
        (ok (and 
            (>= burn-block-height (unwrap-panic (get eta proposal)))
        ))
    )
)

;; ****************
;; Public functions
;; ****************

;; Propose a vault timelocked operation
(define-public (propose-vault-protocol-transfer-sbtc 
                (to principal) 
                (amount uint))
    (let 
        (
          (proposal-id (var-get proposal-counter))
          (delay (unwrap! (contract-call? .registry-vpv-16 get-timelock-delay) ERR_INVALID_DELAY))
          (eta (+ burn-block-height delay))
          (args-buff (unwrap! (to-consensus-buff? { to: to, amount: amount }) ERR_INVALID_PROPOSAL_TYPE))
          (new-proposal {
            id: proposal-id,
            proposal-type: PROPOSAL_TYPE_VAULT_PROTOCOL_TRANSFER,
            eta: eta,
            args: args-buff
            })
          (current-proposals (var-get proposal-queue))
          (updated-proposals (unwrap-panic (as-max-len? (append current-proposals new-proposal) u100)))
        )

        (try! (contract-call? .controller-vpv-16 is-admin tx-sender))
        
        ;; Add proposal to queue
        (var-set proposal-queue updated-proposals)
        
        ;; Increment counter
        (var-set proposal-counter (+ proposal-id u1))
        
        (print {
            vault-proposal-created: {
                id: proposal-id,
                to: to,
                amount: amount,
                eta: eta
            }
        })
        
        (ok proposal-id)
    )
)

;; Propose a stability timelocked operation
(define-public (propose-stability-protocol-transfer-sbtc 
                (to principal) 
                (amount uint))
    (let ((proposal-id (var-get proposal-counter))
          (delay (unwrap! (contract-call? .registry-vpv-16 get-timelock-delay) ERR_INVALID_DELAY))
          (eta (+ burn-block-height delay))
          (args-buff (unwrap! (to-consensus-buff? { to: to, amount: amount }) ERR_INVALID_PROPOSAL_TYPE))
          (new-proposal {
            id: proposal-id,
            proposal-type: PROPOSAL_TYPE_STABILITY_PROTOCOL_TRANSFER,
            eta: eta,
            args: args-buff
        })
          (current-proposals (var-get proposal-queue))
          (updated-proposals (append current-proposals new-proposal)))
        
        (try! (contract-call? .controller-vpv-16 is-admin tx-sender))
        
        ;; Add proposal to queue
        (var-set proposal-queue (unwrap-panic (as-max-len? updated-proposals u100)))
        
        ;; Increment counter
        (var-set proposal-counter (+ proposal-id u1))
        
        (print {
            stability-proposal-created: {
                id: proposal-id,
                to: to,
                amount: amount,
                eta: eta
            }
        })
        
        (ok proposal-id)
    )
)

;; Propose a stability BSD timelocked operation
(define-public (propose-stability-protocol-transfer-bsd
                (to principal)
                (amount uint))
    (let ((proposal-id (var-get proposal-counter))
          (delay (unwrap! (contract-call? .registry-vpv-16 get-timelock-delay) ERR_INVALID_DELAY))
          (eta (+ burn-block-height delay))
          (args-buff (unwrap! (to-consensus-buff? { to: to, amount: amount }) ERR_INVALID_PROPOSAL_TYPE))
          (new-proposal {
            id: proposal-id,
            proposal-type: PROPOSAL_TYPE_STABILITY_PROTOCOL_TRANSFER_BSD,
            eta: eta,
            args: args-buff
        })
          (current-proposals (var-get proposal-queue))
          (updated-proposals (append current-proposals new-proposal)))
        
        (try! (contract-call? .controller-vpv-16 is-admin tx-sender))
        
        ;; Add proposal to queue
        (var-set proposal-queue (unwrap-panic (as-max-len? updated-proposals u100)))
        
        ;; Increment counter
        (var-set proposal-counter (+ proposal-id u1))
        
        (print {
            stability-bsd-proposal-created: {
                id: proposal-id,
                to: to,
                amount: amount,
                eta: eta
            }
        })
        
        (ok proposal-id)
    )
)

;; Propose decay parameters timelocked operation
(define-public (propose-decay-params
                (new-max-hours-decay uint)
                (new-block-decay-rates (list 500 uint)))
    (let ((proposal-id (var-get proposal-counter))
          (delay (unwrap! (contract-call? .registry-vpv-16 get-timelock-delay) ERR_INVALID_DELAY))
          (eta (+ burn-block-height delay))
          (args-buff (unwrap! (to-consensus-buff? {  
            new-max-hours-decay: new-max-hours-decay, 
            new-block-decay-rates: new-block-decay-rates, 
          }) ERR_INVALID_PROPOSAL_TYPE))
          (new-proposal {
            id: proposal-id,
            proposal-type: PROPOSAL_TYPE_DECAY_PARAMS,
            eta: eta,
            args: args-buff
        })
          (current-proposals (var-get proposal-queue))
          (updated-proposals (unwrap-panic (as-max-len? (append current-proposals new-proposal) u100))))
        
        (try! (contract-call? .controller-vpv-16 is-admin tx-sender))
        
        ;; Add proposal to queue
        (var-set proposal-queue updated-proposals)
        
        ;; Increment counter
        (var-set proposal-counter (+ proposal-id u1))
        
        (print {
            decay-params-proposal-created: {
                id: proposal-id,
                new-max-hours-decay: new-max-hours-decay,
                eta: eta
            }
        })
        
        (ok proposal-id)
    )
)

;; Propose vault parameters timelocked operation
(define-public (propose-vault-params
                (new-interest-minimum (optional uint))
                (new-interest-maximum (optional uint))
                (new-vault-collateral-ratio-threshold (optional uint))
                (new-vault-recovery-ratio-threshold (optional uint)))
    (let ((proposal-id (var-get proposal-counter))
          (delay (unwrap! (contract-call? .registry-vpv-16 get-timelock-delay) ERR_INVALID_DELAY))
          (eta (+ burn-block-height delay))
          (args-buff (unwrap! (to-consensus-buff? { 
            new-interest-minimum: new-interest-minimum, 
            new-interest-maximum: new-interest-maximum, 
            new-vault-collateral-ratio-threshold: new-vault-collateral-ratio-threshold, 
            new-vault-recovery-ratio-threshold: new-vault-recovery-ratio-threshold 
          }) ERR_INVALID_PROPOSAL_TYPE))
          (new-proposal {
            id: proposal-id,
            proposal-type: PROPOSAL_TYPE_VAULT_PARAMS,
            eta: eta,
            args: args-buff
        })
          (current-proposals (var-get proposal-queue))
          (updated-proposals (unwrap-panic (as-max-len? (append current-proposals new-proposal) u100))))
        
        (try! (contract-call? .controller-vpv-16 is-admin tx-sender))
        
        ;; Add proposal to queue
        (var-set proposal-queue updated-proposals)
        
        ;; Increment counter
        (var-set proposal-counter (+ proposal-id u1))
        
        (print {
            vault-params-proposal-created: {
                id: proposal-id,
                new-interest-minimum: new-interest-minimum,
                new-interest-maximum: new-interest-maximum,
                new-vault-collateral-ratio-threshold: new-vault-collateral-ratio-threshold,
                new-vault-recovery-ratio-threshold: new-vault-recovery-ratio-threshold,
                eta: eta
            }
        })
        
        (ok proposal-id)
    )
)

;; Propose borrow parameters timelocked operation
(define-public (propose-borrow-params
                (new-min-borrow-fee (optional uint))
                (new-max-borrow-fee (optional uint))
                (new-loan-minimum (optional uint)))
    (let ((proposal-id (var-get proposal-counter))
          (delay (unwrap! (contract-call? .registry-vpv-16 get-timelock-delay) ERR_INVALID_DELAY))
          (eta (+ burn-block-height delay))
          (args-buff (unwrap! (to-consensus-buff? { 
            new-min-borrow-fee: new-min-borrow-fee, 
            new-max-borrow-fee: new-max-borrow-fee, 
            new-loan-minimum: new-loan-minimum 
          }) ERR_INVALID_PROPOSAL_TYPE))
          (new-proposal {
            id: proposal-id,
            proposal-type: PROPOSAL_TYPE_BORROW_PARAMS,
            eta: eta,
            args: args-buff
        })
          (current-proposals (var-get proposal-queue))
          (updated-proposals (unwrap-panic (as-max-len? (append current-proposals new-proposal) u100))))
        
        (try! (contract-call? .controller-vpv-16 is-admin tx-sender))
        
        ;; Add proposal to queue
        (var-set proposal-queue updated-proposals)
        
        ;; Increment counter
        (var-set proposal-counter (+ proposal-id u1))
        
        (print {
            borrow-params-proposal-created: {
                id: proposal-id,
                new-min-borrow-fee: new-min-borrow-fee,
                new-max-borrow-fee: new-max-borrow-fee,
                new-loan-minimum: new-loan-minimum,
                eta: eta
            }
        })
        
        (ok proposal-id)
    )
)

;; Propose redeem parameters timelocked operation
(define-public (propose-redeem-params
                (new-min-redeem-fee (optional uint))
                (new-max-redeem-fee (optional uint))
                (new-alpha (optional uint))
                (new-min-redeem-amount (optional uint))
                (new-max-vaults-to-redeem (optional uint)))
    (let ((proposal-id (var-get proposal-counter))
          (delay (unwrap! (contract-call? .registry-vpv-16 get-timelock-delay) ERR_INVALID_DELAY))
          (eta (+ burn-block-height delay))
          (args-buff (unwrap! (to-consensus-buff? { 
            new-min-redeem-fee: new-min-redeem-fee, 
            new-max-redeem-fee: new-max-redeem-fee, 
            new-alpha: new-alpha,
            new-min-redeem-amount: new-min-redeem-amount,
            new-max-vaults-to-redeem: new-max-vaults-to-redeem
          }) ERR_INVALID_PROPOSAL_TYPE))
          (new-proposal {
            id: proposal-id,
            proposal-type: PROPOSAL_TYPE_REDEEM_PARAMS,
            eta: eta,
            args: args-buff
        })
          (current-proposals (var-get proposal-queue))
          (updated-proposals (unwrap-panic (as-max-len? (append current-proposals new-proposal) u100))))
        
        (try! (contract-call? .controller-vpv-16 is-admin tx-sender))
        
        ;; Add proposal to queue
        (var-set proposal-queue updated-proposals)
        
        ;; Increment counter
        (var-set proposal-counter (+ proposal-id u1))
        
        (print {
            redeem-params-proposal-created: {
                id: proposal-id,
                new-min-redeem-fee: new-min-redeem-fee,
                new-max-redeem-fee: new-max-redeem-fee,
                new-alpha: new-alpha,
                new-min-redeem-amount: new-min-redeem-amount,
                new-max-vaults-to-redeem: new-max-vaults-to-redeem,
                eta: eta
            }
        })
        
        (ok proposal-id)
    )
)

;; Propose global parameters timelocked operation
(define-public (propose-global-params
                (new-global-collateral-ratio-threshold (optional uint))
                (new-global-collateral-cap (optional uint))
                (new-protocol-fee-destination (optional principal))
                (new-min-stability-provider-balance (optional uint))
                (new-epoch-genesis (optional uint))
                (new-hours-per-epoch (optional uint))
                (new-oracle-stale-threshold-seconds (optional uint))
                (new-oracle-allowable-price-deviation (optional uint))
                (new-timelock-delay (optional uint)))
    (let ((proposal-id (var-get proposal-counter))
          (delay (unwrap! (contract-call? .registry-vpv-16 get-timelock-delay) ERR_INVALID_DELAY))
          (eta (+ burn-block-height delay))
          (args-buff (unwrap! (to-consensus-buff? { 
            new-global-collateral-ratio-threshold: new-global-collateral-ratio-threshold, 
            new-global-collateral-cap: new-global-collateral-cap, 
            new-protocol-fee-destination: new-protocol-fee-destination,
            new-min-stability-provider-balance: new-min-stability-provider-balance,
            new-epoch-genesis: new-epoch-genesis,
            new-hours-per-epoch: new-hours-per-epoch,
            new-oracle-stale-threshold-seconds: new-oracle-stale-threshold-seconds,
            new-oracle-allowable-price-deviation: new-oracle-allowable-price-deviation,
            new-timelock-delay: new-timelock-delay
          }) ERR_INVALID_PROPOSAL_TYPE))
          (new-proposal {
            id: proposal-id,
            proposal-type: PROPOSAL_TYPE_GLOBAL_PARAMS,
            eta: eta,
            args: args-buff
        })
          (current-proposals (var-get proposal-queue))
          (updated-proposals (unwrap-panic (as-max-len? (append current-proposals new-proposal) u100))))
        
        (try! (contract-call? .controller-vpv-16 is-admin tx-sender))
        
        ;; Add proposal to queue
        (var-set proposal-queue updated-proposals)
        
        ;; Increment counter
        (var-set proposal-counter (+ proposal-id u1))
        
        (print {
            global-params-proposal-created: {
                id: proposal-id,
                new-global-collateral-ratio-threshold: new-global-collateral-ratio-threshold,
                new-global-collateral-cap: new-global-collateral-cap,
                new-protocol-fee-destination: new-protocol-fee-destination,
                new-min-stability-provider-balance: new-min-stability-provider-balance,
                new-epoch-genesis: new-epoch-genesis,
                new-hours-per-epoch: new-hours-per-epoch,
                new-oracle-stale-threshold-seconds: new-oracle-stale-threshold-seconds,
                new-oracle-allowable-price-deviation: new-oracle-allowable-price-deviation,
                new-timelock-delay: new-timelock-delay,
                eta: eta
            }
        })
        
        (ok proposal-id)
    )
)

;; Propose add hot pause principal timelocked operation
(define-public (propose-add-hot-pause-principal
                (add-principal principal))
    (let ((proposal-id (var-get proposal-counter))
          (delay (unwrap! (contract-call? .registry-vpv-16 get-timelock-delay) ERR_INVALID_DELAY))
          (eta (+ burn-block-height delay))
          (args-buff (unwrap! (to-consensus-buff? { 
            add-principal: add-principal
          }) ERR_INVALID_PROPOSAL_TYPE))
          (new-proposal {
            id: proposal-id,
            proposal-type: PROPOSAL_TYPE_ADD_HOT_PAUSE_PRINCIPAL,
            eta: eta,
            args: args-buff
        })
          (current-proposals (var-get proposal-queue))
          (updated-proposals (unwrap-panic (as-max-len? (append current-proposals new-proposal) u100))))
        
        (try! (contract-call? .controller-vpv-16 is-admin tx-sender))
        
        ;; Add proposal to queue
        (var-set proposal-queue updated-proposals)
        
        ;; Increment counter
        (var-set proposal-counter (+ proposal-id u1))
        
        (print {
            add-hot-pause-principal-proposal-created: {
                id: proposal-id,
                add-principal: add-principal,
                eta: eta
            }
        })
        
        (ok proposal-id)
    )
)

;; Propose remove hot pause principal timelocked operation
(define-public (propose-remove-hot-pause-principal
                (remove-principal principal))
    (let ((proposal-id (var-get proposal-counter))
          (delay (unwrap! (contract-call? .registry-vpv-16 get-timelock-delay) ERR_INVALID_DELAY))
          (eta (+ burn-block-height delay))
          (args-buff (unwrap! (to-consensus-buff? { 
            remove-principal: remove-principal
          }) ERR_INVALID_PROPOSAL_TYPE))
          (new-proposal {
            id: proposal-id,
            proposal-type: PROPOSAL_TYPE_REMOVE_HOT_PAUSE_PRINCIPAL,
            eta: eta,
            args: args-buff
        })
          (current-proposals (var-get proposal-queue))
          (updated-proposals (unwrap-panic (as-max-len? (append current-proposals new-proposal) u100))))
        
        (try! (contract-call? .controller-vpv-16 is-admin tx-sender))
        
        ;; Add proposal to queue
        (var-set proposal-queue updated-proposals)
        
        ;; Increment counter
        (var-set proposal-counter (+ proposal-id u1))
        
        (print {
            remove-hot-pause-principal-proposal-created: {
                id: proposal-id,
                remove-principal: remove-principal,
                eta: eta
            }
        })
        
        (ok proposal-id)
    )
)

;; Propose add supported contract timelocked operation
(define-public (propose-add-supported-contract
                (contract-key (string-ascii 256))
                (contract-address principal)
                (qualified-contract principal))
    (let ((proposal-id (var-get proposal-counter))
          (delay (unwrap! (contract-call? .registry-vpv-16 get-timelock-delay) ERR_INVALID_DELAY))
          (eta (+ burn-block-height delay))
          (args-buff (unwrap! (to-consensus-buff? { 
            contract-key: contract-key,
            contract-address: contract-address,
            qualified-contract: qualified-contract
          }) ERR_INVALID_PROPOSAL_TYPE))
          (new-proposal {
            id: proposal-id,
            proposal-type: PROPOSAL_TYPE_ADD_SUPPORTED_CONTRACT,
            eta: eta,
            args: args-buff
        })
          (current-proposals (var-get proposal-queue))
          (updated-proposals (unwrap-panic (as-max-len? (append current-proposals new-proposal) u100))))
        
        (try! (contract-call? .controller-vpv-16 is-admin tx-sender))
        
        ;; Add proposal to queue
        (var-set proposal-queue updated-proposals)
        
        ;; Increment counter
        (var-set proposal-counter (+ proposal-id u1))
        
        (print {
            add-supported-contract-proposal-created: {
                id: proposal-id,
                contract-key: contract-key,
                contract-address: contract-address,
                qualified-contract: qualified-contract,
                eta: eta
            }
        })
        
        (ok proposal-id)
    )
)

;; Propose remove supported contract timelocked operation
(define-public (propose-remove-supported-contract
                (contract-key (string-ascii 256)))
    (let ((proposal-id (var-get proposal-counter))
          (delay (unwrap! (contract-call? .registry-vpv-16 get-timelock-delay) ERR_INVALID_DELAY))
          (eta (+ burn-block-height delay))
          (args-buff (unwrap! (to-consensus-buff? { 
            contract-key: contract-key
          }) ERR_INVALID_PROPOSAL_TYPE))
          (new-proposal {
            id: proposal-id,
            proposal-type: PROPOSAL_TYPE_REMOVE_SUPPORTED_CONTRACT,
            eta: eta,
            args: args-buff
        })
          (current-proposals (var-get proposal-queue))
          (updated-proposals (unwrap-panic (as-max-len? (append current-proposals new-proposal) u100))))
        
        (try! (contract-call? .controller-vpv-16 is-admin tx-sender))
        
        ;; Add proposal to queue
        (var-set proposal-queue updated-proposals)
        
        ;; Increment counter
        (var-set proposal-counter (+ proposal-id u1))
        
        (print {
            remove-supported-contract-proposal-created: {
                id: proposal-id,
                contract-key: contract-key,
                eta: eta
            }
        })
        
        (ok proposal-id)
    )
)

;; Propose set keeper timelocked operation
(define-public (propose-set-keeper
                (new-keeper principal))
    (let ((proposal-id (var-get proposal-counter))
          (delay (unwrap! (contract-call? .registry-vpv-16 get-timelock-delay) ERR_INVALID_DELAY))
          (eta (+ burn-block-height delay))
          (args-buff (unwrap! (to-consensus-buff? { 
            new-keeper: new-keeper
          }) ERR_INVALID_PROPOSAL_TYPE))
          (new-proposal {
            id: proposal-id,
            proposal-type: PROPOSAL_TYPE_SET_KEEPER,
            eta: eta,
            args: args-buff
        })
          (current-proposals (var-get proposal-queue))
          (updated-proposals (unwrap-panic (as-max-len? (append current-proposals new-proposal) u100))))
        
        (try! (contract-call? .controller-vpv-16 is-admin tx-sender))
        
        ;; Add proposal to queue
        (var-set proposal-queue updated-proposals)
        
        ;; Increment counter
        (var-set proposal-counter (+ proposal-id u1))
        
        (print {
            set-keeper-proposal-created: {
                id: proposal-id,
                new-keeper: new-keeper,
                eta: eta
            }
        })
        
        (ok proposal-id)
    )
)

;; Propose add controller privileged protocol principal timelocked operation
(define-public (propose-add-controller-privileged-protocol-principal
                (new-protocol-principal principal))
    (let ((proposal-id (var-get proposal-counter))
          (delay (unwrap! (contract-call? .registry-vpv-16 get-timelock-delay) ERR_INVALID_DELAY))
          (eta (+ burn-block-height delay))
          (args-buff (unwrap! (to-consensus-buff? { 
            new-protocol-principal: new-protocol-principal
          }) ERR_INVALID_PROPOSAL_TYPE))
          (new-proposal {
            id: proposal-id,
            proposal-type: PROPOSAL_TYPE_ADD_CONTROLLER_PRIVILEGED_PROTOCOL_PRINCIPAL,
            eta: eta,
            args: args-buff
        })
          (current-proposals (var-get proposal-queue))
          (updated-proposals (unwrap-panic (as-max-len? (append current-proposals new-proposal) u100))))
        
        (try! (contract-call? .controller-vpv-16 is-admin tx-sender))
        
        ;; Add proposal to queue
        (var-set proposal-queue updated-proposals)
        
        ;; Increment counter
        (var-set proposal-counter (+ proposal-id u1))
        
        (print {
            add-controller-privileged-protocol-principal-proposal-created: {
                id: proposal-id,
                new-protocol-principal: new-protocol-principal,
                eta: eta
            }
        })
        
        (ok proposal-id)
    )
)

;; Propose remove controller privileged protocol principal timelocked operation
(define-public (propose-remove-controller-privileged-protocol-principal
                (remove-protocol-principal principal))
    (let ((proposal-id (var-get proposal-counter))
          (delay (unwrap! (contract-call? .registry-vpv-16 get-timelock-delay) ERR_INVALID_DELAY))
          (eta (+ burn-block-height delay))
          (args-buff (unwrap! (to-consensus-buff? { 
            remove-protocol-principal: remove-protocol-principal
          }) ERR_INVALID_PROPOSAL_TYPE))
          (new-proposal {
            id: proposal-id,
            proposal-type: PROPOSAL_TYPE_REMOVE_CONTROLLER_PRIVILEGED_PROTOCOL_PRINCIPAL,
            eta: eta,
            args: args-buff
        })
          (current-proposals (var-get proposal-queue))
          (updated-proposals (unwrap-panic (as-max-len? (append current-proposals new-proposal) u100))))
        
        (try! (contract-call? .controller-vpv-16 is-admin tx-sender))
        
        ;; Prevent removing self as privileged principal
        (asserts! (not (is-eq remove-protocol-principal (as-contract tx-sender))) ERR_CANNOT_REMOVE_SELF)
        
        ;; Add proposal to queue
        (var-set proposal-queue updated-proposals)
        
        ;; Increment counter
        (var-set proposal-counter (+ proposal-id u1))
        
        (print {
            remove-controller-privileged-protocol-principal-proposal-created: {
                id: proposal-id,
                remove-protocol-principal: remove-protocol-principal,
                eta: eta
            }
        })
        
        (ok proposal-id)
    )
)

;; Propose admin timelocked operation
(define-public (propose-admin
                (new-admin principal))
    (let ((proposal-id (var-get proposal-counter))
          (delay (unwrap! (contract-call? .registry-vpv-16 get-timelock-delay) ERR_INVALID_DELAY))
          (eta (+ burn-block-height delay))
          (args-buff (unwrap! (to-consensus-buff? { 
            new-admin: new-admin
          }) ERR_INVALID_PROPOSAL_TYPE))
          (new-proposal {
            id: proposal-id,
            proposal-type: PROPOSAL_TYPE_PROPOSE_ADMIN,
            eta: eta,
            args: args-buff
        })
          (current-proposals (var-get proposal-queue))
          (updated-proposals (unwrap-panic (as-max-len? (append current-proposals new-proposal) u100))))
        
        (try! (contract-call? .controller-vpv-16 is-admin tx-sender))
        
        ;; Add proposal to queue
        (var-set proposal-queue updated-proposals)
        
        ;; Increment counter
        (var-set proposal-counter (+ proposal-id u1))
        
        (print {
            propose-admin-proposal-created: {
                id: proposal-id,
                new-admin: new-admin,
                eta: eta
            }
        })
        
        (ok proposal-id)
    )
)

;; Propose set contracts allowed timelocked operation
(define-public (propose-set-contracts-allowed
                (allowed bool))
    (let ((proposal-id (var-get proposal-counter))
          (delay (unwrap! (contract-call? .registry-vpv-16 get-timelock-delay) ERR_INVALID_DELAY))
          (eta (+ burn-block-height delay))
          (args-buff (unwrap! (to-consensus-buff? { 
            allowed: allowed
          }) ERR_INVALID_PROPOSAL_TYPE))
          (new-proposal {
            id: proposal-id,
            proposal-type: PROPOSAL_TYPE_SET_CONTRACTS_ALLOWED,
            eta: eta,
            args: args-buff
        })
          (current-proposals (var-get proposal-queue))
          (updated-proposals (unwrap-panic (as-max-len? (append current-proposals new-proposal) u100))))
        
        (try! (contract-call? .controller-vpv-16 is-admin tx-sender))
        
        ;; Add proposal to queue
        (var-set proposal-queue updated-proposals)
        
        ;; Increment counter
        (var-set proposal-counter (+ proposal-id u1))
        
        (print {
            set-contracts-allowed-proposal-created: {
                id: proposal-id,
                allowed: allowed,
                eta: eta
            }
        })
        
        (ok proposal-id)
    )
)

;; Propose keeper allow all timelocked operation
(define-public (propose-keeper-allow-all
                (allowed bool))
    (let ((proposal-id (var-get proposal-counter))
          (delay (unwrap! (contract-call? .registry-vpv-16 get-timelock-delay) ERR_INVALID_DELAY))
          (eta (+ burn-block-height delay))
          (args-buff (unwrap! (to-consensus-buff? { 
            allowed: allowed
          }) ERR_INVALID_PROPOSAL_TYPE))
          (new-proposal {
            id: proposal-id,
            proposal-type: PROPOSAL_TYPE_KEEPER_ALLOW_ALL,
            eta: eta,
            args: args-buff
        })
          (current-proposals (var-get proposal-queue))
          (updated-proposals (unwrap-panic (as-max-len? (append current-proposals new-proposal) u100))))
        
        (try! (contract-call? .controller-vpv-16 is-admin tx-sender))
        
        ;; Add proposal to queue
        (var-set proposal-queue updated-proposals)
        
        ;; Increment counter
        (var-set proposal-counter (+ proposal-id u1))
        
        (print {
            keeper-allow-all-proposal-created: {
                id: proposal-id,
                allowed: allowed,
                eta: eta
            }
        })
        
        (ok proposal-id)
    )
)

;; Propose BSD protocol transfer timelocked operation
(define-public (propose-bsd-protocol-transfer
                (bsd-amount uint)
                (sender principal)
                (recipient principal))
    (let ((proposal-id (var-get proposal-counter))
          (delay (unwrap! (contract-call? .registry-vpv-16 get-timelock-delay) ERR_INVALID_DELAY))
          (eta (+ burn-block-height delay))
          (args-buff (unwrap! (to-consensus-buff? { 
            bsd-amount: bsd-amount,
            sender: sender,
            recipient: recipient
          }) ERR_INVALID_PROPOSAL_TYPE))
          (new-proposal {
            id: proposal-id,
            proposal-type: PROPOSAL_TYPE_BSD_PROTOCOL_TRANSFER,
            eta: eta,
            args: args-buff
        })
          (current-proposals (var-get proposal-queue))
          (updated-proposals (unwrap-panic (as-max-len? (append current-proposals new-proposal) u100))))
        
        (try! (contract-call? .controller-vpv-16 is-admin tx-sender))
        
        ;; Add proposal to queue
        (var-set proposal-queue updated-proposals)
        
        ;; Increment counter
        (var-set proposal-counter (+ proposal-id u1))
        
        (print {
            bsd-protocol-transfer-proposal-created: {
                id: proposal-id,
                bsd-amount: bsd-amount,
                sender: sender,
                recipient: recipient,
                eta: eta
            }
        })
        
        (ok proposal-id)
    )
)

;; Propose BSD add privileged principal timelocked operation
(define-public (propose-bsd-add-privileged-principal
                (new-protocol-principal principal))
    (let ((proposal-id (var-get proposal-counter))
          (delay (unwrap! (contract-call? .registry-vpv-16 get-timelock-delay) ERR_INVALID_DELAY))
          (eta (+ burn-block-height delay))
          (args-buff (unwrap! (to-consensus-buff? { 
            new-protocol-principal: new-protocol-principal
          }) ERR_INVALID_PROPOSAL_TYPE))
          (new-proposal {
            id: proposal-id,
            proposal-type: PROPOSAL_TYPE_BSD_ADD_PRIVILEGED_PRINCIPAL,
            eta: eta,
            args: args-buff
        })
          (current-proposals (var-get proposal-queue))
          (updated-proposals (unwrap-panic (as-max-len? (append current-proposals new-proposal) u100))))
        
        (try! (contract-call? .controller-vpv-16 is-admin tx-sender))
        
        ;; Add proposal to queue
        (var-set proposal-queue updated-proposals)
        
        ;; Increment counter
        (var-set proposal-counter (+ proposal-id u1))
        
        (print {
            bsd-add-privileged-principal-proposal-created: {
                id: proposal-id,
                new-protocol-principal: new-protocol-principal,
                eta: eta
            }
        })
        
        (ok proposal-id)
    )
)

;; Propose BSD remove privileged principal timelocked operation
(define-public (propose-bsd-remove-privileged-principal
                (remove-protocol-principal principal))
    (let ((proposal-id (var-get proposal-counter))
          (delay (unwrap! (contract-call? .registry-vpv-16 get-timelock-delay) ERR_INVALID_DELAY))
          (eta (+ burn-block-height delay))
          (args-buff (unwrap! (to-consensus-buff? { 
            remove-protocol-principal: remove-protocol-principal
          }) ERR_INVALID_PROPOSAL_TYPE))
          (new-proposal {
            id: proposal-id,
            proposal-type: PROPOSAL_TYPE_BSD_REMOVE_PRIVILEGED_PRINCIPAL,
            eta: eta,
            args: args-buff
        })
          (current-proposals (var-get proposal-queue))
          (updated-proposals (unwrap-panic (as-max-len? (append current-proposals new-proposal) u100))))
        
        (try! (contract-call? .controller-vpv-16 is-admin tx-sender))
        
        ;; Prevent removing self as privileged principal
        (asserts! (not (is-eq remove-protocol-principal (as-contract tx-sender))) ERR_CANNOT_REMOVE_SELF)
        
        ;; Add proposal to queue
        (var-set proposal-queue updated-proposals)
        
        ;; Increment counter
        (var-set proposal-counter (+ proposal-id u1))
        
        (print {
            bsd-remove-privileged-principal-proposal-created: {
                id: proposal-id,
                remove-protocol-principal: remove-protocol-principal,
                eta: eta
            }
        })
        
        (ok proposal-id)
    )
)

;; Propose BSD protocol burn timelocked operation
(define-public (propose-bsd-protocol-burn
                (user principal)
                (bsd-amount uint))
    (let ((proposal-id (var-get proposal-counter))
          (delay (unwrap! (contract-call? .registry-vpv-16 get-timelock-delay) ERR_INVALID_DELAY))
          (eta (+ burn-block-height delay))
          (args-buff (unwrap! (to-consensus-buff? { 
            user: user,
            bsd-amount: bsd-amount
          }) ERR_INVALID_PROPOSAL_TYPE))
          (new-proposal {
            id: proposal-id,
            proposal-type: PROPOSAL_TYPE_BSD_PROTOCOL_BURN,
            eta: eta,
            args: args-buff
        })
          (current-proposals (var-get proposal-queue))
          (updated-proposals (unwrap-panic (as-max-len? (append current-proposals new-proposal) u100))))
        
        (try! (contract-call? .controller-vpv-16 is-admin tx-sender))
        
        ;; Add proposal to queue
        (var-set proposal-queue updated-proposals)
        
        ;; Increment counter
        (var-set proposal-counter (+ proposal-id u1))
        
        (print {
            bsd-protocol-burn-proposal-created: {
                id: proposal-id,
                user: user,
                bsd-amount: bsd-amount,
                eta: eta
            }
        })
        
        (ok proposal-id)
    )
)

;; Propose BSD propose owner timelocked operation
(define-public (propose-bsd-propose-owner
                (new-owner principal))
    (let ((proposal-id (var-get proposal-counter))
          (delay (unwrap! (contract-call? .registry-vpv-16 get-timelock-delay) ERR_INVALID_DELAY))
          (eta (+ burn-block-height delay))
          (args-buff (unwrap! (to-consensus-buff? { 
            new-owner: new-owner
          }) ERR_INVALID_PROPOSAL_TYPE))
          (new-proposal {
            id: proposal-id,
            proposal-type: PROPOSAL_TYPE_BSD_PROPOSE_OWNER,
            eta: eta,
            args: args-buff
        })
          (current-proposals (var-get proposal-queue))
          (updated-proposals (unwrap-panic (as-max-len? (append current-proposals new-proposal) u100))))
        
        (try! (contract-call? .controller-vpv-16 is-admin tx-sender))
        
        ;; Add proposal to queue
        (var-set proposal-queue updated-proposals)
        
        ;; Increment counter
        (var-set proposal-counter (+ proposal-id u1))
        
        (print {
            bsd-propose-owner-proposal-created: {
                id: proposal-id,
                new-owner: new-owner,
                eta: eta
            }
        })
        
        (ok proposal-id)
    )
)

;; Propose BSD set token URI timelocked operation
(define-public (propose-bsd-token-uri
                (token-uri (string-utf8 256)))
    (let ((proposal-id (var-get proposal-counter))
          (delay (unwrap! (contract-call? .registry-vpv-16 get-timelock-delay) ERR_INVALID_DELAY))
          (eta (+ burn-block-height delay))
          (args-buff (unwrap! (to-consensus-buff? { 
            token-uri: token-uri
          }) ERR_INVALID_PROPOSAL_TYPE))
          (new-proposal {
            id: proposal-id,
            proposal-type: PROPOSAL_TYPE_BSD_PROPOSE_TOKEN_URI,
            eta: eta,
            args: args-buff
        })
          (current-proposals (var-get proposal-queue))
          (updated-proposals (unwrap-panic (as-max-len? (append current-proposals new-proposal) u100))))
        
        (try! (contract-call? .controller-vpv-16 is-admin tx-sender))
        
        ;; Add proposal to queue
        (var-set proposal-queue updated-proposals)
        
        ;; Increment counter
        (var-set proposal-counter (+ proposal-id u1))
        
        (print {
            bsd-set-token-uri-proposal-created: {
                id: proposal-id,
                token-uri: token-uri,
                eta: eta
            }
        })
        
        (ok proposal-id)
    )
)

;; Clear the entire queue (admin only)
(define-public (clear-queue)
    (begin
        (try! (contract-call? .controller-vpv-16 is-admin tx-sender))
        (var-set proposal-queue (list))
        (var-set proposal-counter u0)
        (ok true)
    )
)

;; Execute all ready proposals
(define-public (execute-all-ready-proposals (vault <vault-trait>) (stability <stability-trait>) (sbtc <sbtc-trait>) (bsd <bsd-trait>))
    (begin
        (try! (contract-call? .controller-vpv-16 is-admin tx-sender))
        (fold execute-ready-proposal (var-get proposal-queue) (ok {vault: vault, stability: stability, sbtc: sbtc, bsd: bsd, executed: u0}))
    )
)

;; ****************
;; Private functions
;; ****************

;; Private functions
(define-private (find-proposal-by-id (proposal-id uint))
    (ok (get proposal (unwrap! (fold find-proposal-filter (var-get proposal-queue) (ok { proposal: none, proposal-id: proposal-id })) ERR_PROPOSAL_NOT_FOUND)))
)

(define-private (find-proposal-filter (proposal {id: uint, proposal-type: (string-ascii 256), eta: uint, args: (buff 10000)}) (result (response { proposal: (optional {id: uint, proposal-type: (string-ascii 256), eta: uint, args: (buff 10000)}), proposal-id: uint } uint)))
    (match result
        ok-tuple
        (if (is-eq (get id proposal) (get proposal-id ok-tuple))
            (ok { proposal: (some proposal), proposal-id: (get proposal-id ok-tuple) }) ;; Found the proposal
            (ok { proposal: none, proposal-id: (get proposal-id ok-tuple) })  ;; Keep looking
        )
        err-result
        (err err-result)
    )
)

;; Remove proposal by ID
(define-private (remove-proposal-by-id (proposal-id uint))
    (let ((proposals (var-get proposal-queue)))
        (let ((result (fold remove-proposal-filter proposals (ok { updated-proposals: (list), proposal-id: proposal-id }))))
            (var-set proposal-queue (get updated-proposals (unwrap! result ERR_PROPOSAL_NOT_FOUND)))
            (ok true)
        )
    )
)

(define-private (remove-proposal-filter (proposal {id: uint, proposal-type: (string-ascii 256), eta: uint, args: (buff 10000)}) (result (response { updated-proposals: (list 100 {id: uint, proposal-type: (string-ascii 256), eta: uint, args: (buff 10000)}), proposal-id: uint } uint)))
    (match result
        ok-tuple
        (if (is-eq (get id proposal) (get proposal-id ok-tuple))
            (ok ok-tuple) ;; Keep the accumulator as is (i.e., don't add the proposal to the list)
            (ok { updated-proposals: (unwrap-panic (as-max-len? (append (get updated-proposals ok-tuple) proposal) u100)), proposal-id: (get proposal-id ok-tuple) })
        )
        err-result
        (err err-result)
    )
)

;; Helper function to execute transfer operations
(define-private (execute-transfer (proposal-type (string-ascii 256)) (args-buff (buff 10000)) (vault <vault-trait>) (stability <stability-trait>) (sbtc <sbtc-trait>))
    (let
        (
            (proposal-args (unwrap! (from-consensus-buff? { to: principal, amount: uint } args-buff) ERR_INVALID_PROPOSAL_TYPE))
            (to (get to proposal-args))
            (amount (get amount proposal-args))
        )
        (if (is-eq proposal-type PROPOSAL_TYPE_VAULT_PROTOCOL_TRANSFER)
            (match (contract-call? vault protocol-transfer-sbtc to amount sbtc)
                ok-result
                (begin
                    (print {
                        timelock-vault-protocol-transfer-executed: {
                            to: to,
                            amount: amount
                        }
                    })
                    (ok true)
                )
                err-result
                (err err-result)
            )
            (match (contract-call? stability protocol-transfer-sbtc to amount sbtc)
                ok-result
                (begin
                    (print {
                        timelock-stability-protocol-transfer-sbtc-executed: {
                            to: to,
                            amount: amount
                        }
                    })
                    (ok true)
                )
                err-result
                (err err-result)
            )
        )
    )
)

;; Helper function to execute stability protocol transfer BSD update
(define-private (execute-stability-protocol-transfer-bsd-update (args-buff (buff 10000)) (stability <stability-trait>) (bsd <bsd-trait>))
    (let
        (
            (proposal-args (unwrap! (from-consensus-buff? { 
                to: principal,
                amount: uint
            } args-buff) ERR_INVALID_PROPOSAL_TYPE))
            (to (get to proposal-args))
            (amount (get amount proposal-args))
        )
        (match (contract-call? stability protocol-transfer-bsd to amount bsd)
            ok-result
            (begin
                (print {
                    timelock-stability-protocol-transfer-bsd-executed: {
                        to: to,
                        amount: amount
                    }
                })
                (ok true)
            )
            err-result
            (err err-result)
        )
    )
)

;; Helper function to execute redeem parameters update
(define-private (execute-redeem-params-update (args-buff (buff 10000)))
    (let
        (
            (proposal-args (unwrap! (from-consensus-buff? { 
                new-min-redeem-fee: (optional uint), 
                new-max-redeem-fee: (optional uint), 
                new-alpha: (optional uint),
                new-min-redeem-amount: (optional uint),
                new-max-vaults-to-redeem: (optional uint)
            } args-buff) ERR_INVALID_PROPOSAL_TYPE))
            (new-min-redeem-fee (get new-min-redeem-fee proposal-args))
            (new-max-redeem-fee (get new-max-redeem-fee proposal-args))
            (new-alpha (get new-alpha proposal-args))
            (new-min-redeem-amount (get new-min-redeem-amount proposal-args))
            (new-max-vaults-to-redeem (get new-max-vaults-to-redeem proposal-args))
        )
        (match (contract-call? .registry-vpv-16 set-redeem-parameters 
            new-min-redeem-fee new-max-redeem-fee new-alpha new-min-redeem-amount new-max-vaults-to-redeem)
            ok-result
            (begin
                (print {
                    timelock-redeem-params-executed: {
                        new-min-redeem-fee: new-min-redeem-fee,
                        new-max-redeem-fee: new-max-redeem-fee,
                        new-alpha: new-alpha,
                        new-min-redeem-amount: new-min-redeem-amount,
                        new-max-vaults-to-redeem: new-max-vaults-to-redeem
                    }
                })
                (ok true)
            )
            err-result
            (err err-result)
        )
    )
)

;; Helper function to execute decay parameters update
(define-private (execute-decay-update (args-buff (buff 10000)))
    (let
        (
            (proposal-args (unwrap! (from-consensus-buff? { 
                new-max-hours-decay: uint, 
                new-block-decay-rates: (list 500 uint), 
            } args-buff) ERR_INVALID_PROPOSAL_TYPE))
            (new-max-hours-decay (get new-max-hours-decay proposal-args))
            (new-block-decay-rates (get new-block-decay-rates proposal-args))
        )
        (match (contract-call? .registry-vpv-16 set-decay-parameters 
            new-max-hours-decay 
            new-block-decay-rates)
            ok-result
            (begin
                (print {
                    timelock-decay-params-executed: {
                        new-max-hours-decay: new-max-hours-decay,
                        new-block-decay-rates: new-block-decay-rates
                    }
                })
                (ok true)
            )
            err-result
            (err err-result)
        )
    )
)

;; Helper function to execute vault parameters update
(define-private (execute-vault-params-update (args-buff (buff 10000)))
    (let
        (
            (proposal-args (unwrap! (from-consensus-buff? { 
                new-interest-minimum: (optional uint), 
                new-interest-maximum: (optional uint), 
                new-vault-collateral-ratio-threshold: (optional uint), 
                new-vault-recovery-ratio-threshold: (optional uint) 
            } args-buff) ERR_INVALID_PROPOSAL_TYPE))
            (new-interest-minimum (get new-interest-minimum proposal-args))
            (new-interest-maximum (get new-interest-maximum proposal-args))
            (new-vault-collateral-ratio-threshold (get new-vault-collateral-ratio-threshold proposal-args))
            (new-vault-recovery-ratio-threshold (get new-vault-recovery-ratio-threshold proposal-args))
        )
        (match (contract-call? .registry-vpv-16 set-vault-parameters 
            new-interest-minimum new-interest-maximum 
            new-vault-collateral-ratio-threshold new-vault-recovery-ratio-threshold)
            ok-result
            (begin
                (print {
                    timelock-vault-params-executed: {
                        new-interest-minimum: new-interest-minimum,
                        new-interest-maximum: new-interest-maximum,
                        new-vault-collateral-ratio-threshold: new-vault-collateral-ratio-threshold,
                        new-vault-recovery-ratio-threshold: new-vault-recovery-ratio-threshold
                    }
                })
                (ok true)
            )
            err-result
            (err err-result)
        )
    )
)

;; Helper function to execute borrow parameters update
(define-private (execute-borrow-params-update (args-buff (buff 10000)))
    (let
        (
            (proposal-args (unwrap! (from-consensus-buff? { 
                new-min-borrow-fee: (optional uint), 
                new-max-borrow-fee: (optional uint), 
                new-loan-minimum: (optional uint) 
            } args-buff) ERR_INVALID_PROPOSAL_TYPE))
            (new-min-borrow-fee (get new-min-borrow-fee proposal-args))
            (new-max-borrow-fee (get new-max-borrow-fee proposal-args))
            (new-loan-minimum (get new-loan-minimum proposal-args))
        )
        (match (contract-call? .registry-vpv-16 set-borrow-parameters 
            new-min-borrow-fee new-max-borrow-fee new-loan-minimum)
            ok-result
            (begin
                (print {
                    timelock-borrow-params-executed: {
                        new-min-borrow-fee: new-min-borrow-fee,
                        new-max-borrow-fee: new-max-borrow-fee,
                        new-loan-minimum: new-loan-minimum
                    }
                })
                (ok true)
            )
            err-result
            (err err-result)
        )
    )
)

;; Helper function to execute global parameters update
(define-private (execute-global-params-update (args-buff (buff 10000)))
    (let
        (
            (proposal-args (unwrap! (from-consensus-buff? { 
                new-global-collateral-ratio-threshold: (optional uint), 
                new-global-collateral-cap: (optional uint), 
                new-protocol-fee-destination: (optional principal),
                new-min-stability-provider-balance: (optional uint),
                new-epoch-genesis: (optional uint),
                new-hours-per-epoch: (optional uint),
                new-oracle-stale-threshold-seconds: (optional uint),
                new-oracle-allowable-price-deviation: (optional uint),
                new-timelock-delay: (optional uint)
            } args-buff) ERR_INVALID_PROPOSAL_TYPE))
            (new-global-collateral-ratio-threshold (get new-global-collateral-ratio-threshold proposal-args))
            (new-global-collateral-cap (get new-global-collateral-cap proposal-args))
            (new-protocol-fee-destination (get new-protocol-fee-destination proposal-args))
            (new-min-stability-provider-balance (get new-min-stability-provider-balance proposal-args))
            (new-epoch-genesis (get new-epoch-genesis proposal-args))
            (new-hours-per-epoch (get new-hours-per-epoch proposal-args))
            (new-oracle-stale-threshold-seconds (get new-oracle-stale-threshold-seconds proposal-args))
            (new-oracle-allowable-price-deviation (get new-oracle-allowable-price-deviation proposal-args))
            (new-timelock-delay (get new-timelock-delay proposal-args))
        )
        (match (contract-call? .registry-vpv-16 set-global-parameters 
            new-global-collateral-ratio-threshold new-global-collateral-cap new-protocol-fee-destination 
            new-min-stability-provider-balance new-epoch-genesis new-hours-per-epoch new-oracle-stale-threshold-seconds 
            new-oracle-allowable-price-deviation new-timelock-delay)
            ok-result
            (begin
                (print {
                    timelock-global-params-executed: {
                        new-global-collateral-ratio-threshold: new-global-collateral-ratio-threshold,
                        new-global-collateral-cap: new-global-collateral-cap,
                        new-protocol-fee-destination: new-protocol-fee-destination,
                        new-min-stability-provider-balance: new-min-stability-provider-balance,
                        new-epoch-genesis: new-epoch-genesis,
                        new-oracle-stale-threshold-seconds: new-oracle-stale-threshold-seconds,
                        new-oracle-allowable-price-deviation: new-oracle-allowable-price-deviation,
                        new-timelock-delay: new-timelock-delay
                    }
                })
                (ok true)
            )
            err-result
            (err err-result)
        )
    )
)

;; Helper function to execute add hot pause principal update
(define-private (execute-add-hot-pause-principal-update (args-buff (buff 10000)))
    (let
        (
            (proposal-args (unwrap! (from-consensus-buff? { 
                add-principal: principal
            } args-buff) ERR_INVALID_PROPOSAL_TYPE))
            (add-principal (get add-principal proposal-args))
        )
        (match (contract-call? .controller-vpv-16 add-hot-pause-principal add-principal)
            ok-result
            (begin
                (print {
                    timelock-add-hot-pause-principal-executed: {
                        add-principal: add-principal
                    }
                })
                (ok true)
            )
            err-result
            (err err-result)
        )
    )
)

;; Helper function to execute remove hot pause principal update
(define-private (execute-remove-hot-pause-principal-update (args-buff (buff 10000)))
    (let
        (
            (proposal-args (unwrap! (from-consensus-buff? { 
                remove-principal: principal
            } args-buff) ERR_INVALID_PROPOSAL_TYPE))
            (remove-principal (get remove-principal proposal-args))
        )
        (match (contract-call? .controller-vpv-16 remove-hot-pause-principal remove-principal)
            ok-result
            (begin
                (print {
                    timelock-remove-hot-pause-principal-executed: {
                        remove-principal: remove-principal
                    }
                })
                (ok true)
            )
            err-result
            (err err-result)
        )
    )
)

;; Helper function to execute add supported contract update
(define-private (execute-add-supported-contract-update (args-buff (buff 10000)))
    (let
        (
            (proposal-args (unwrap! (from-consensus-buff? { 
                contract-key: (string-ascii 256),
                contract-address: principal,
                qualified-contract: principal
            } args-buff) ERR_INVALID_PROPOSAL_TYPE))
            (contract-key (get contract-key proposal-args))
            (contract-address (get contract-address proposal-args))
            (qualified-contract (get qualified-contract proposal-args))
        )
        (match (contract-call? .controller-vpv-16 add-supported-contract contract-key contract-address qualified-contract)
            ok-result
            (begin
                (print {
                    timelock-add-supported-contract-executed: {
                        contract-key: contract-key,
                        contract-address: contract-address,
                        qualified-contract: qualified-contract
                    }
                })
                (ok true)
            )
            err-result
            (err err-result)
        )
    )
)

;; Helper function to execute remove supported contract update
(define-private (execute-remove-supported-contract-update (args-buff (buff 10000)))
    (let
        (
            (proposal-args (unwrap! (from-consensus-buff? { 
                contract-key: (string-ascii 256)
            } args-buff) ERR_INVALID_PROPOSAL_TYPE))
            (contract-key (get contract-key proposal-args))
        )
        (match (contract-call? .controller-vpv-16 remove-supported-contract contract-key)
            ok-result
            (begin
                (print {
                    timelock-remove-supported-contract-executed: {
                        contract-key: contract-key
                    }
                })
                (ok true)
            )
            err-result
            (err err-result)
        )
    )
)

;; Helper function to execute set keeper update
(define-private (execute-set-keeper-update (args-buff (buff 10000)))
    (let
        (
            (proposal-args (unwrap! (from-consensus-buff? { 
                new-keeper: principal
            } args-buff) ERR_INVALID_PROPOSAL_TYPE))
            (new-keeper (get new-keeper proposal-args))
        )
        (match (contract-call? .controller-vpv-16 set-keeper new-keeper)
            ok-result
            (begin
                (print {
                    timelock-set-keeper-executed: {
                        new-keeper: new-keeper
                    }
                })
                (ok true)
            )
            err-result
            (err err-result)
        )
    )
)

;; Helper function to execute add privileged protocol principal update
(define-private (execute-add-controller-privileged-protocol-principal-update (args-buff (buff 10000)))
    (let
        (
            (proposal-args (unwrap! (from-consensus-buff? { 
                new-protocol-principal: principal
            } args-buff) ERR_INVALID_PROPOSAL_TYPE))
            (new-protocol-principal (get new-protocol-principal proposal-args))
        )
        (match (contract-call? .controller-vpv-16 add-privileged-protocol-principal new-protocol-principal)
            ok-result
            (begin
                (print {
                    timelock-add-controller-privileged-protocol-principal-executed: {
                        new-protocol-principal: new-protocol-principal
                    }
                })
                (ok true)
            )
            err-result
            (err err-result)
        )
    )
)

;; Helper function to execute remove privileged protocol principal update
(define-private (execute-remove-controller-privileged-protocol-principal-update (args-buff (buff 10000)))
    (let
        (
            (proposal-args (unwrap! (from-consensus-buff? { 
                remove-protocol-principal: principal
            } args-buff) ERR_INVALID_PROPOSAL_TYPE))
            (remove-protocol-principal (get remove-protocol-principal proposal-args))
        )
        (match (contract-call? .controller-vpv-16 remove-privileged-protocol-principal remove-protocol-principal)
            ok-result
            (begin
                (print {
                    timelock-remove-controller-privileged-protocol-principal-executed: {
                        remove-protocol-principal: remove-protocol-principal
                    }
                })
                (ok true)
            )
            err-result
            (err err-result)
        )
    )
)

;; Helper function to execute propose admin update
(define-private (execute-propose-admin-update (args-buff (buff 10000)))
    (let
        (
            (proposal-args (unwrap! (from-consensus-buff? { 
                new-admin: principal
            } args-buff) ERR_INVALID_PROPOSAL_TYPE))
            (new-admin (get new-admin proposal-args))
        )
        (match (contract-call? .controller-vpv-16 propose-admin new-admin)
            ok-result
            (begin
                (print {
                    timelock-propose-admin-executed: {
                        new-admin: new-admin
                    }
                })
                (ok true)
            )
            err-result
            (err err-result)
        )
    )
)

;; Helper function to execute set contracts allowed update
(define-private (execute-set-contracts-allowed-update (args-buff (buff 10000)))
    (let
        (
            (proposal-args (unwrap! (from-consensus-buff? { 
                allowed: bool
            } args-buff) ERR_INVALID_PROPOSAL_TYPE))
            (allowed (get allowed proposal-args))
        )
        (match (contract-call? .controller-vpv-16 set-contracts-allowed allowed)
            ok-result
            (begin
                (print {
                    timelock-set-contracts-allowed-executed: {
                        allowed: allowed
                    }
                })
                (ok true)
            )
            err-result
            (err err-result)
        )
    )
)

;; Helper function to execute keeper allow all update
(define-private (execute-keeper-allow-all-update (args-buff (buff 10000)))
    (let
        (
            (proposal-args (unwrap! (from-consensus-buff? { 
                allowed: bool
            } args-buff) ERR_INVALID_PROPOSAL_TYPE))
            (allowed (get allowed proposal-args))
        )
        (match (contract-call? .controller-vpv-16 keeper-allow-all allowed)
            ok-result
            (begin
                (print {
                    timelock-keeper-allow-all-executed: {
                        allowed: allowed
                    }
                })
                (ok true)
            )
            err-result
            (err err-result)
        )
    )
)

;; Helper function to execute BSD protocol transfer update
(define-private (execute-bsd-protocol-transfer-update (args-buff (buff 10000)) (bsd <bsd-trait>))
    (let
        (
            (proposal-args (unwrap! (from-consensus-buff? { 
                bsd-amount: uint,
                sender: principal,
                recipient: principal
            } args-buff) ERR_INVALID_PROPOSAL_TYPE))
            (bsd-amount (get bsd-amount proposal-args))
            (sender (get sender proposal-args))
            (recipient (get recipient proposal-args))
        )
        (match (contract-call? bsd protocol-transfer bsd-amount sender recipient)
            ok-result
            (begin
                (print {
                    timelock-bsd-protocol-transfer-executed: {
                        bsd-amount: bsd-amount,
                        sender: sender,
                        recipient: recipient
                    }
                })
                (ok true)
            )
            err-result
            (err err-result)
        )
    )
)

;; Helper function to execute BSD add privileged principal update
(define-private (execute-bsd-add-privileged-principal-update (args-buff (buff 10000)) (bsd <bsd-trait>))
    (let
        (
            (proposal-args (unwrap! (from-consensus-buff? { 
                new-protocol-principal: principal
            } args-buff) ERR_INVALID_PROPOSAL_TYPE))
            (new-protocol-principal (get new-protocol-principal proposal-args))
        )
        (match (contract-call? bsd add-privileged-protocol-principal new-protocol-principal)
            ok-result
            (begin
                (print {
                    timelock-bsd-add-privileged-principal-executed: {
                        new-protocol-principal: new-protocol-principal
                    }
                })
                (ok true)
            )
            err-result
            (err err-result)
        )
    )
)

;; Helper function to execute BSD remove privileged principal update
(define-private (execute-bsd-remove-privileged-principal-update (args-buff (buff 10000)) (bsd <bsd-trait>))
    (let
        (
            (proposal-args (unwrap! (from-consensus-buff? { 
                remove-protocol-principal: principal
            } args-buff) ERR_INVALID_PROPOSAL_TYPE))
            (remove-protocol-principal (get remove-protocol-principal proposal-args))
        )
        (match (contract-call? bsd remove-privileged-protocol-principal remove-protocol-principal)
            ok-result
            (begin
                (print {
                    timelock-bsd-remove-privileged-principal-executed: {
                        remove-protocol-principal: remove-protocol-principal
                    }
                })
                (ok true)
            )
            err-result
            (err err-result)
        )
    )
)

;; Helper function to execute BSD protocol burn update
(define-private (execute-bsd-protocol-burn-update (args-buff (buff 10000)) (bsd <bsd-trait>))
    (let
        (
            (proposal-args (unwrap! (from-consensus-buff? { 
                user: principal,
                bsd-amount: uint
            } args-buff) ERR_INVALID_PROPOSAL_TYPE))
            (user (get user proposal-args))
            (bsd-amount (get bsd-amount proposal-args))
        )
        (match (contract-call? bsd protocol-burn user bsd-amount)
            ok-result
            (begin
                (print {
                    timelock-bsd-protocol-burn-executed: {
                        user: user,
                        bsd-amount: bsd-amount
                    }
                })
                (ok true)
            )
            err-result
            (err err-result)
        )
    )
)

;; Helper function to execute BSD propose owner update
(define-private (execute-bsd-propose-owner-update (args-buff (buff 10000)) (bsd <bsd-trait>))
    (let
        (
            (proposal-args (unwrap! (from-consensus-buff? { 
                new-owner: principal
            } args-buff) ERR_INVALID_PROPOSAL_TYPE))
            (new-owner (get new-owner proposal-args))
        )
        (match (contract-call? bsd propose-owner new-owner)
            ok-result
            (begin
                (print {
                    timelock-bsd-propose-owner-executed: {
                        new-owner: new-owner
                    }
                })
                (ok true)
            )
            err-result
            (err err-result)
        )
    )
)

;; Helper function to execute BSD set token URI update
(define-private (execute-bsd-set-token-uri-update (args-buff (buff 10000)) (bsd <bsd-trait>))
    (let
        (
            (proposal-args (unwrap! (from-consensus-buff? { 
                token-uri: (string-utf8 256)
            } args-buff) ERR_INVALID_PROPOSAL_TYPE))
            (token-uri (get token-uri proposal-args))
        )
        (match (contract-call? bsd set-token-uri (some token-uri))
            ok-result
            (begin
                (print {
                    timelock-bsd-set-token-uri-executed: {
                        token-uri: token-uri
                    }
                })
                (ok true)
            )
            err-result
            (err err-result)
        )
    )
)

(define-private (execute-ready-proposal (proposal {id: uint, proposal-type: (string-ascii 256), eta: uint, args: (buff 10000)}) (result (response {vault: <vault-trait>, stability: <stability-trait>, sbtc: <sbtc-trait>, bsd: <bsd-trait>, executed: uint} uint)))
    (match result
        ok-tuple
        (if (and (>= burn-block-height (get eta proposal)))
            ;; Execute this proposal
            (begin
                ;; Remove proposal from queue
                (try! (remove-proposal-by-id (get id proposal)))
                
                ;; Decode arguments from consensus buffer
                (let 
                    (
                      (vault (get vault ok-tuple))
                      (stability (get stability ok-tuple))
                      (sbtc (get sbtc ok-tuple))
                      (bsd (get bsd ok-tuple))
                      (executed (get executed ok-tuple))
                    )
                    ;; Execute based on proposal type
                    (begin
                        (if (is-eq (get proposal-type proposal) PROPOSAL_TYPE_VAULT_PROTOCOL_TRANSFER)
                            (try! (execute-transfer (get proposal-type proposal) (get args proposal) vault stability sbtc))
                            (if (is-eq (get proposal-type proposal) PROPOSAL_TYPE_STABILITY_PROTOCOL_TRANSFER)
                                (try! (execute-transfer (get proposal-type proposal) (get args proposal) vault stability sbtc))
                                (if (is-eq (get proposal-type proposal) PROPOSAL_TYPE_STABILITY_PROTOCOL_TRANSFER_BSD)
                                    (try! (execute-stability-protocol-transfer-bsd-update (get args proposal) stability bsd))
                                    (if (is-eq (get proposal-type proposal) PROPOSAL_TYPE_DECAY_PARAMS)
                                    (try! (execute-decay-update (get args proposal)))
                                    (if (is-eq (get proposal-type proposal) PROPOSAL_TYPE_VAULT_PARAMS)
                                        (try! (execute-vault-params-update (get args proposal)))
                                        (if (is-eq (get proposal-type proposal) PROPOSAL_TYPE_BORROW_PARAMS)
                                            (try! (execute-borrow-params-update (get args proposal)))
                                            (if (is-eq (get proposal-type proposal) PROPOSAL_TYPE_REDEEM_PARAMS)
                                                (try! (execute-redeem-params-update (get args proposal)))
                                                (if (is-eq (get proposal-type proposal) PROPOSAL_TYPE_GLOBAL_PARAMS)
                                                    (try! (execute-global-params-update (get args proposal)))
                                                    (if (is-eq (get proposal-type proposal) PROPOSAL_TYPE_ADD_HOT_PAUSE_PRINCIPAL)
                                                        (try! (execute-add-hot-pause-principal-update (get args proposal)))
                                                        (if (is-eq (get proposal-type proposal) PROPOSAL_TYPE_REMOVE_HOT_PAUSE_PRINCIPAL)
                                                            (try! (execute-remove-hot-pause-principal-update (get args proposal)))
                                                            (if (is-eq (get proposal-type proposal) PROPOSAL_TYPE_ADD_SUPPORTED_CONTRACT)
                                                                (try! (execute-add-supported-contract-update (get args proposal)))
                                                                (if (is-eq (get proposal-type proposal) PROPOSAL_TYPE_REMOVE_SUPPORTED_CONTRACT)
                                                                    (try! (execute-remove-supported-contract-update (get args proposal)))
                                                                    (if (is-eq (get proposal-type proposal) PROPOSAL_TYPE_SET_KEEPER)
                                                                        (try! (execute-set-keeper-update (get args proposal)))
                                                                        (if (is-eq (get proposal-type proposal) PROPOSAL_TYPE_ADD_CONTROLLER_PRIVILEGED_PROTOCOL_PRINCIPAL)
                                                                            (try! (execute-add-controller-privileged-protocol-principal-update (get args proposal)))
                                                                                                                                                         (if (is-eq (get proposal-type proposal) PROPOSAL_TYPE_REMOVE_CONTROLLER_PRIVILEGED_PROTOCOL_PRINCIPAL)
                                                                                 (try! (execute-remove-controller-privileged-protocol-principal-update (get args proposal)))
                                                                                 (if (is-eq (get proposal-type proposal) PROPOSAL_TYPE_PROPOSE_ADMIN)
                                                                                     (try! (execute-propose-admin-update (get args proposal)))
                                                                                     (if (is-eq (get proposal-type proposal) PROPOSAL_TYPE_SET_CONTRACTS_ALLOWED)
                                                                                         (try! (execute-set-contracts-allowed-update (get args proposal)))
                                                                                         (if (is-eq (get proposal-type proposal) PROPOSAL_TYPE_KEEPER_ALLOW_ALL)
                                                                                             (try! (execute-keeper-allow-all-update (get args proposal)))
                                                                                             (if (is-eq (get proposal-type proposal) PROPOSAL_TYPE_BSD_PROTOCOL_TRANSFER)
                                                                                                 (try! (execute-bsd-protocol-transfer-update (get args proposal) bsd))
                                                                                                 (if (is-eq (get proposal-type proposal) PROPOSAL_TYPE_BSD_ADD_PRIVILEGED_PRINCIPAL)
                                                                                                     (try! (execute-bsd-add-privileged-principal-update (get args proposal) bsd))
                                                                                                     (if (is-eq (get proposal-type proposal) PROPOSAL_TYPE_BSD_REMOVE_PRIVILEGED_PRINCIPAL)
                                                                                                         (try! (execute-bsd-remove-privileged-principal-update (get args proposal) bsd))
                                                                                                         (if (is-eq (get proposal-type proposal) PROPOSAL_TYPE_BSD_PROTOCOL_BURN)
                                                                                                             (try! (execute-bsd-protocol-burn-update (get args proposal) bsd))
                                                                                                                    (if (is-eq (get proposal-type proposal) PROPOSAL_TYPE_BSD_PROPOSE_OWNER)
                                                                                                                        (try! (execute-bsd-propose-owner-update (get args proposal) bsd))
                                                                                                                        (if (is-eq (get proposal-type proposal) PROPOSAL_TYPE_BSD_PROPOSE_TOKEN_URI)
                                                                                                                            (try! (execute-bsd-set-token-uri-update (get args proposal) bsd))
                                                                                                                            true
                                                                                                                        )
                                                                                                                )
                                                                                                            )
                                                                                                         )
                                                                                                     )
                                                                                                 )
                                                                                             )
                                                                                         )
                                                                                     )
                                                                                 )
                                                                             )
                                                                        )
                                                                    )
                                                                )
                                                            )
                                                        )
                                                    )
                                                )
                                            )
                                        )
                                    )
                                )
                            )
                        )
                     (ok (merge ok-tuple { executed: (+ executed u1) }))
                    )
                )
            )
            (ok ok-tuple)
        )
        err-result
        (err err-result)
    )
)