;; title: aibtc-dao-run-cost
;; version: 1.0.0
;; summary: A contract that holds and manages fees for AIBTC services.

;; traits
;;

(use-trait sip010-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

;; constants
;;

;; error messages
(define-constant ERR_NOT_OWNER (err u1000))
(define-constant ERR_ASSET_NOT_ALLOWED (err u1001))
(define-constant ERR_PROPOSAL_MISMATCH (err u1002))
(define-constant ERR_SAVING_PROPOSAL (err u1003))

;; contract details
(define-constant DEPLOYED_BURN_BLOCK burn-block-height)
(define-constant DEPLOYED_STACKS_BLOCK stacks-block-height)
(define-constant SELF (as-contract tx-sender))

;; possible actions
(define-constant SET_OWNER u1)
(define-constant SET_ASSET u2)
(define-constant TRANSFER u3)
(define-constant SET_CONFIRMATIONS u4)

;; proposal expiration
(define-constant PROPOSAL_EXPIRATION u144) ;; 144 blocks / 24 hours

;; data vars
;;

;; 3 of N confirmations required
(define-data-var confirmationsRequired uint u3)

;; variables to track total proposals, used for nonces
(define-data-var setOwnerProposalsTotal uint u0)
(define-data-var setAssetProposalsTotal uint u0)
(define-data-var transferProposalsTotal uint u0)
(define-data-var setConfirmationsProposalsTotal uint u0)
(define-data-var totalOwners uint u0)

;; data maps
;;

(define-map Owners
  principal ;; owner
  bool ;; enabled
)

(define-map SetOwnerProposals
  uint ;; nonce
  {
    who: principal, ;; owner
    status: bool, ;; enabled
    executed: (optional uint), ;; block height if executed
    created: uint, ;; block height
  }
)

(define-map SetAssetProposals
  uint ;; nonce
  {
    token: principal, ;; asset contract
    enabled: bool, ;; enabled
    executed: (optional uint), ;; block height if executed
    created: uint, ;; block height
  }
)

(define-map TransferProposals
  uint ;; nonce
  {
    ft: principal, ;; asset contract
    amount: uint, ;; amount
    to: principal, ;; recipient
    executed: (optional uint), ;; block height if executed
    created: uint, ;; block height
  }
)

(define-map SetConfirmationsProposals
  uint ;; nonce
  {
    required: uint, ;; new confirmation threshold
    executed: (optional uint), ;; block height if executed
    created: uint, ;; block height
  }
)

(define-map OwnerConfirmations
  {
    id: uint, ;; action id
    nonce: uint, ;; action nonce
    owner: principal, ;; owner
  }
  bool ;; confirmed
)

(define-map TotalConfirmations
  {
    id: uint, ;; action id
    nonce: uint, ;; action nonce
  }
  uint ;; total confirmations
)

(define-map AllowedAssets
  principal ;; asset contract
  bool ;; enabled
)

;; public functions
;;

(define-public (set-owner
    (nonce uint)
    (who principal)
    (status bool)
  )
  (begin
    (asserts! (is-owner contract-caller) ERR_NOT_OWNER)
    (match (map-get? SetOwnerProposals nonce)
      proposal (begin
        (asserts! (is-eq (get who proposal) who) ERR_PROPOSAL_MISMATCH)
        (asserts! (is-eq (get status proposal) status) ERR_PROPOSAL_MISMATCH)
      )
      (begin
        (var-set setOwnerProposalsTotal (+ (var-get setOwnerProposalsTotal) u1))
        (asserts!
          (map-insert SetOwnerProposals nonce {
            who: who,
            status: status,
            executed: none,
            created: burn-block-height,
          })
          ERR_SAVING_PROPOSAL
        )
      )
    )
    (print {
      notification: "dao-run-cost/set-owner",
      payload: {
        nonce: nonce,
        who: who,
        status: status,
        contractCaller: contract-caller,
        txSender: tx-sender,
      },
    })
    (ok (and (is-confirmed SET_OWNER nonce) (execute-set-owner nonce)))
  )
)

(define-public (set-asset
    (nonce uint)
    (token principal)
    (enabled bool)
  )
  (begin
    (asserts! (is-owner contract-caller) ERR_NOT_OWNER)
    (match (map-get? SetAssetProposals nonce)
      proposal (begin
        (asserts! (is-eq (get token proposal) token) ERR_PROPOSAL_MISMATCH)
        (asserts! (is-eq (get enabled proposal) enabled) ERR_PROPOSAL_MISMATCH)
      )
      (begin
        (var-set setAssetProposalsTotal (+ (var-get setAssetProposalsTotal) u1))
        (asserts!
          (map-insert SetAssetProposals nonce {
            token: token,
            enabled: enabled,
            executed: none,
            created: burn-block-height,
          })
          ERR_SAVING_PROPOSAL
        )
      )
    )
    (print {
      notification: "dao-run-cost/set-asset",
      payload: {
        nonce: nonce,
        token: token,
        enabled: enabled,
        contractCaller: contract-caller,
        txSender: tx-sender,
      },
    })
    (ok (and (is-confirmed SET_ASSET nonce) (execute-set-asset nonce)))
  )
)

(define-public (transfer-token
    (nonce uint)
    (ft <sip010-trait>)
    (amount uint)
    (to principal)
  )
  (begin
    (asserts! (is-owner contract-caller) ERR_NOT_OWNER)
    (asserts! (is-allowed-asset (contract-of ft)) ERR_ASSET_NOT_ALLOWED)
    (match (map-get? TransferProposals nonce)
      proposal (begin
        (asserts! (is-eq (get ft proposal) (contract-of ft))
          ERR_PROPOSAL_MISMATCH
        )
        (asserts! (is-eq (get amount proposal) amount) ERR_PROPOSAL_MISMATCH)
        (asserts! (is-eq (get to proposal) to) ERR_PROPOSAL_MISMATCH)
      )
      (begin
        (var-set transferProposalsTotal (+ (var-get transferProposalsTotal) u1))
        (asserts!
          (map-insert TransferProposals nonce {
            ft: (contract-of ft),
            amount: amount,
            to: to,
            executed: none,
            created: burn-block-height,
          })
          ERR_SAVING_PROPOSAL
        )
      )
    )
    (print {
      notification: "dao-run-cost/transfer-token",
      payload: {
        nonce: nonce,
        amount: amount,
        recipient: to,
        assetContract: (contract-of ft),
        contractCaller: contract-caller,
        txSender: tx-sender,
      },
    })
    (ok (and (is-confirmed TRANSFER nonce) (execute-transfer nonce ft)))
  )
)

(define-public (set-confirmations
    (nonce uint)
    (required uint)
  )
  (begin
    (asserts! (is-owner contract-caller) ERR_NOT_OWNER)
    (match (map-get? SetConfirmationsProposals nonce)
      proposal (asserts! (is-eq (get required proposal) required) ERR_PROPOSAL_MISMATCH)
      (begin
        (var-set setConfirmationsProposalsTotal
          (+ (var-get setConfirmationsProposalsTotal) u1)
        )
        (asserts!
          (map-insert SetConfirmationsProposals nonce {
            required: required,
            executed: none,
            created: burn-block-height,
          })
          ERR_SAVING_PROPOSAL
        )
      )
    )
    (print {
      notification: "dao-run-cost/set-confirmations",
      payload: {
        nonce: nonce,
        required: required,
        contractCaller: contract-caller,
        txSender: tx-sender,
      },
    })
    (ok (and (is-confirmed SET_CONFIRMATIONS nonce) (execute-set-confirmations nonce)))
  )
)

;; read only functions
;;

(define-read-only (get-confirmations-required)
  (var-get confirmationsRequired)
)

(define-read-only (get-proposal-totals)
  {
    setOwner: (var-get setOwnerProposalsTotal),
    setAsset: (var-get setAssetProposalsTotal),
    transfer: (var-get transferProposalsTotal),
    setConfirmations: (var-get setConfirmationsProposalsTotal),
  }
)

(define-read-only (get-total-owners)
  (var-get totalOwners)
)

(define-read-only (is-owner (who principal))
  (default-to false (map-get? Owners who))
)

(define-read-only (get-set-owner-proposal (nonce uint))
  (map-get? SetOwnerProposals nonce)
)

(define-read-only (get-set-asset-proposal (nonce uint))
  (map-get? SetAssetProposals nonce)
)

(define-read-only (get-transfer-proposal (nonce uint))
  (map-get? TransferProposals nonce)
)

(define-read-only (get-set-confirmations-proposal (nonce uint))
  (map-get? SetConfirmationsProposals nonce)
)

(define-read-only (get-owner-confirmations
    (id uint)
    (nonce uint)
  )
  (map-get? OwnerConfirmations {
    id: id,
    nonce: nonce,
    owner: contract-caller,
  })
)

(define-read-only (owner-has-confirmed
    (id uint)
    (nonce uint)
    (who principal)
  )
  (default-to false
    (map-get? OwnerConfirmations {
      id: id,
      nonce: nonce,
      owner: who,
    })
  )
)

(define-read-only (get-total-confirmations
    (id uint)
    (nonce uint)
  )
  (default-to u0
    (map-get? TotalConfirmations {
      id: id,
      nonce: nonce,
    })
  )
)

(define-read-only (get-allowed-asset (assetContract principal))
  (map-get? AllowedAssets assetContract)
)

(define-read-only (is-allowed-asset (assetContract principal))
  (default-to false (get-allowed-asset assetContract))
)

(define-read-only (get-contract-info)
  {
    self: SELF,
    deployedBurnBlock: DEPLOYED_BURN_BLOCK,
    deployedStacksBlock: DEPLOYED_STACKS_BLOCK,
  }
)

;; private functions
;;

;; tracks confirmations for a given action
(define-private (is-confirmed
    (id uint)
    (nonce uint)
  )
  (let ((confirmations (+ (get-total-confirmations id nonce)
      (if (owner-has-confirmed id nonce contract-caller)
        u0
        u1
      ))))
    (map-set OwnerConfirmations {
      id: id,
      nonce: nonce,
      owner: contract-caller,
    }
      true
    )
    (map-set TotalConfirmations {
      id: id,
      nonce: nonce,
    }
      confirmations
    )
    (is-eq confirmations (var-get confirmationsRequired))
  )
)

(define-private (can-execute (height uint))
  (< burn-block-height (+ height PROPOSAL_EXPIRATION))
)

(define-private (execute-set-owner (nonce uint))
  (let ((proposal (unwrap! (map-get? SetOwnerProposals nonce) false)))
    (asserts! (can-execute (get created proposal)) false)
    (asserts! (is-none (get executed proposal)) false)
    (if (get status proposal)
      (and (not (is-owner (get who proposal))) (var-set totalOwners (+ (var-get totalOwners) u1)))
      (and (is-owner (get who proposal)) (var-set totalOwners (- (var-get totalOwners) u1)))
    )
    (map-set Owners (get who proposal) (get status proposal))
    (map-set SetOwnerProposals nonce
      (merge proposal { executed: (some burn-block-height) })
    )
    (print {
      notification: "dao-run-cost/execute-set-owner",
      payload: {
        nonce: nonce,
        who: (get who proposal),
        status: (get status proposal),
        executed: (some burn-block-height),
        created: (get created proposal),
        contractCaller: contract-caller,
        txSender: tx-sender,
      },
    })
    true
  )
)

(define-private (execute-set-asset (nonce uint))
  (let ((proposal (unwrap! (map-get? SetAssetProposals nonce) false)))
    (asserts! (can-execute (get created proposal)) false)
    (asserts! (is-none (get executed proposal)) false)
    (map-set AllowedAssets (get token proposal) (get enabled proposal))
    (map-set SetAssetProposals nonce
      (merge proposal { executed: (some burn-block-height) })
    )
    (print {
      notification: "dao-run-cost/execute-set-asset",
      payload: {
        nonce: nonce,
        token: (get token proposal),
        enabled: (get enabled proposal),
        executed: (some burn-block-height),
        created: (get created proposal),
        contractCaller: contract-caller,
        txSender: tx-sender,
      },
    })
    true
  )
)

(define-private (execute-transfer
    (nonce uint)
    (ft <sip010-trait>)
  )
  (let ((proposal (unwrap! (map-get? TransferProposals nonce) false)))
    (asserts! (can-execute (get created proposal)) false)
    (asserts! (is-none (get executed proposal)) false)
    (map-set TransferProposals nonce
      (merge proposal { executed: (some burn-block-height) })
    )
    (print {
      notification: "dao-run-cost/execute-transfer",
      payload: {
        nonce: nonce,
        amount: (get amount proposal),
        recipient: (get to proposal),
        assetContract: (get ft proposal),
        executed: (some burn-block-height),
        created: (get created proposal),
        contractCaller: contract-caller,
        txSender: tx-sender,
      },
    })
    (unwrap!
      (as-contract (contract-call? ft transfer (get amount proposal) SELF (get to proposal)
        none
      ))
      false
    )
  )
)

(define-private (execute-set-confirmations (nonce uint))
  (let ((proposal (unwrap! (map-get? SetConfirmationsProposals nonce) false)))
    (asserts! (can-execute (get created proposal)) false)
    (asserts! (is-none (get executed proposal)) false)
    (var-set confirmationsRequired (get required proposal))
    (map-set SetConfirmationsProposals nonce
      (merge proposal { executed: (some burn-block-height) })
    )
    (print {
      notification: "dao-run-cost/execute-set-confirmations",
      payload: {
        nonce: nonce,
        required: (get required proposal),
        executed: (some burn-block-height),
        created: (get created proposal),
        contractCaller: contract-caller,
        txSender: tx-sender,
      },
    })
    true
  )
)

(begin
  ;; set initial owners
  (map-set Owners 'SP21A72YQGHFXRFMMZHB5F0XBXH4WFD22BYSJT8FD true)
  (map-set Owners 'SP99E4DXJBZV3ZSXF1F1324C08VQ9RPJA1R35RR0 true)
  (map-set Owners 'SP1NTCBRTGWGD2PVT020E7ZK5X2TSYC58HNEBNBYH true)
  (map-set Owners 'SP28DDT2YH6KTMVJ2H4JMNYA6TZH42ZA5KNFKM6DG true)
  (map-set Owners 'SP3GG4GT63YKM4P2TESZ2W1RMFTV3BMWP3H0T3GBD true)
  (var-set totalOwners u5)
  ;; set initial assets
  (map-set AllowedAssets 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token
    true
  )
  (print (get-contract-info))
)
