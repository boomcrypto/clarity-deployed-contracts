;; title: aibtc-agent-account
;; version: 3.3.3
;; summary: A special account contract between a user and an agent for managing assets and DAO interactions. Only the user can withdraw funds.

;; traits
(impl-trait 'SP6382W148DH1J3BMEBGWENZ9AK8DXCN5XJPP01C.aibtc-agent-account-traits.aibtc-account)
(impl-trait 'SP6382W148DH1J3BMEBGWENZ9AK8DXCN5XJPP01C.aibtc-agent-account-traits.aibtc-account-proposals)
(impl-trait 'SP6382W148DH1J3BMEBGWENZ9AK8DXCN5XJPP01C.aibtc-agent-account-traits.aibtc-account-config)
(impl-trait 'SP6382W148DH1J3BMEBGWENZ9AK8DXCN5XJPP01C.aibtc-agent-account-traits.aibtc-account-swaps)
(use-trait ft-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)
(use-trait dao-swap-adapter 'SP6382W148DH1J3BMEBGWENZ9AK8DXCN5XJPP01C.aibtc-agent-account-traits.aibtc-dao-swap-adapter)
(use-trait action-trait 'SPW8QZNWKZGVHX012HCBJVJVPS94PXFG578P53TM.aibtc-dao-traits.action)
(use-trait proposal-trait 'SPW8QZNWKZGVHX012HCBJVJVPS94PXFG578P53TM.aibtc-dao-traits.proposal)
(use-trait action-proposal-voting-trait 'SPW8QZNWKZGVHX012HCBJVJVPS94PXFG578P53TM.aibtc-dao-traits.action-proposal-voting)
(use-trait dao-faktory-dex 'SPW8QZNWKZGVHX012HCBJVJVPS94PXFG578P53TM.aibtc-dao-traits.faktory-dex)
(use-trait faktory-token 'SP3XXMS38VTAWTVPE5682XSBFXPTH7XCPEBTX8AN2.faktory-trait-v1.sip-010-trait)

;; constants
(define-constant DEPLOYED_BURN_BLOCK burn-block-height)
(define-constant DEPLOYED_STACKS_BLOCK stacks-block-height)
(define-constant SELF (as-contract tx-sender))

;; owner and agent addresses
(define-constant ACCOUNT_OWNER 'SP1N20DJ263FZ9RGPMSHJ9054D6V9AH0FHDFT89GA) ;; owner (user/creator of account, full access)
(define-constant ACCOUNT_AGENT 'SP3B3DCM61HY77T9B93HWT72575NXT2WJV3EBGY5F) ;; agent (can only take approved actions)

(define-constant SBTC_TOKEN 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token) ;; sBTC token

;; error codes
(define-constant ERR_CALLER_NOT_OWNER (err u1100))
(define-constant ERR_CONTRACT_NOT_APPROVED (err u1101))
(define-constant ERR_OPERATION_NOT_ALLOWED (err u1102))
(define-constant ERR_INVALID_APPROVAL_TYPE (err u1103))

;; permission flags
(define-constant PERMISSION_MANAGE_ASSETS (pow u2 u0))
(define-constant PERMISSION_USE_PROPOSALS (pow u2 u1))
(define-constant PERMISSION_APPROVE_REVOKE_CONTRACTS (pow u2 u2))
(define-constant PERMISSION_BUY_SELL_ASSETS (pow u2 u3))

;; contract approval types
(define-constant APPROVED_CONTRACT_VOTING u1)
(define-constant APPROVED_CONTRACT_SWAP u2)
(define-constant APPROVED_CONTRACT_TOKEN u3)

;; data maps
(define-map ApprovedContracts
  {
    contract: principal,
    type: uint, ;; matches defined constants
  }
  bool
)

;; insert sBTC token into approved contracts
(map-set ApprovedContracts {
  contract: SBTC_TOKEN,
  type: APPROVED_CONTRACT_TOKEN,
}
  true
)

;; data vars
(define-constant DEFAULT_PERMISSIONS (+
  PERMISSION_MANAGE_ASSETS
  PERMISSION_USE_PROPOSALS
  PERMISSION_APPROVE_REVOKE_CONTRACTS
))
(define-data-var agentPermissions uint DEFAULT_PERMISSIONS)

;; public functions

;; the owner or agent can deposit STX to this contract
(define-public (deposit-stx (amount uint))
  (begin
    (asserts! (manage-assets-allowed) ERR_OPERATION_NOT_ALLOWED)
    (print {
      notification: "aibtc-agent-account/deposit-stx",
      payload: {
        contractCaller: contract-caller,
        txSender: tx-sender,
        amount: amount,
        recipient: SELF,
      },
    })
    (stx-transfer? amount contract-caller SELF)
  )
)

;; the owner or agent can deposit FT to this contract
(define-public (deposit-ft
    (ft <ft-trait>)
    (amount uint)
  )
  (begin
    (asserts! (manage-assets-allowed) ERR_OPERATION_NOT_ALLOWED)
    (print {
      notification: "aibtc-agent-account/deposit-ft",
      payload: {
        amount: amount,
        assetContract: (contract-of ft),
        txSender: tx-sender,
        contractCaller: contract-caller,
        recipient: SELF,
      },
    })
    (contract-call? ft transfer amount contract-caller SELF none)
  )
)

;; only the owner or authorized agent can withdraw STX from this contract
;; funds are always sent to the hardcoded ACCOUNT_OWNER
(define-public (withdraw-stx (amount uint))
  (begin
    (asserts! (manage-assets-allowed) ERR_OPERATION_NOT_ALLOWED)
    (print {
      notification: "aibtc-agent-account/withdraw-stx",
      payload: {
        amount: amount,
        sender: SELF,
        caller: contract-caller,
        recipient: ACCOUNT_OWNER,
      },
    })
    (as-contract (stx-transfer? amount SELF ACCOUNT_OWNER))
  )
)

;; only the owner or authorized agent can withdraw FT from this contract if the asset contract is approved
;; funds are always sent to the hardcoded ACCOUNT_OWNER
(define-public (withdraw-ft
    (ft <ft-trait>)
    (amount uint)
  )
  (begin
    (asserts! (manage-assets-allowed) ERR_OPERATION_NOT_ALLOWED)
    (asserts! (is-approved-contract (contract-of ft) APPROVED_CONTRACT_TOKEN)
      ERR_CONTRACT_NOT_APPROVED
    )
    (print {
      notification: "aibtc-agent-account/withdraw-ft",
      payload: {
        amount: amount,
        assetContract: (contract-of ft),
        sender: SELF,
        caller: contract-caller,
        recipient: ACCOUNT_OWNER,
      },
    })
    (as-contract (contract-call? ft transfer amount SELF ACCOUNT_OWNER none))
  )
)

;; DAO Interaction Functions

;; the owner or the agent (if enabled) can create proposals if the proposal voting contract is approved
(define-public (create-action-proposal
    (votingContract <action-proposal-voting-trait>)
    (action <action-trait>)
    (parameters (buff 2048))
    (memo (optional (string-ascii 1024)))
  )
  (begin
    (asserts! (use-proposals-allowed) ERR_OPERATION_NOT_ALLOWED)
    (asserts!
      (is-approved-contract (contract-of votingContract) APPROVED_CONTRACT_VOTING)
      ERR_CONTRACT_NOT_APPROVED
    )
    (print {
      notification: "aibtc-agent-account/create-action-proposal",
      payload: {
        proposalContract: (contract-of votingContract),
        action: (contract-of action),
        parameters: parameters,
        sender: tx-sender,
        caller: contract-caller,
      },
    })
    (as-contract (contract-call? votingContract create-action-proposal action parameters memo))
  )
)

;; the owner or the agent (if enabled) can vote on action proposals if the proposal voting contract is approved
(define-public (vote-on-action-proposal
    (votingContract <action-proposal-voting-trait>)
    (proposalId uint)
    (vote bool)
  )
  (begin
    (asserts! (use-proposals-allowed) ERR_OPERATION_NOT_ALLOWED)
    (asserts!
      (is-approved-contract (contract-of votingContract) APPROVED_CONTRACT_VOTING)
      ERR_CONTRACT_NOT_APPROVED
    )
    (print {
      notification: "aibtc-agent-account/vote-on-action-proposal",
      payload: {
        proposalContract: (contract-of votingContract),
        proposalId: proposalId,
        vote: vote,
        sender: tx-sender,
        caller: contract-caller,
      },
    })
    (as-contract (contract-call? votingContract vote-on-action-proposal proposalId vote))
  )
)

;; the owner or the agent (if enabled) can veto action proposals if the proposal voting contract is approved
(define-public (veto-action-proposal
    (votingContract <action-proposal-voting-trait>)
    (proposalId uint)
  )
  (begin
    (asserts! (use-proposals-allowed) ERR_OPERATION_NOT_ALLOWED)
    (asserts!
      (is-approved-contract (contract-of votingContract) APPROVED_CONTRACT_VOTING)
      ERR_CONTRACT_NOT_APPROVED
    )
    (print {
      notification: "aibtc-agent-account/veto-action-proposal",
      payload: {
        proposalContract: (contract-of votingContract),
        proposalId: proposalId,
        sender: tx-sender,
        caller: contract-caller,
      },
    })
    (as-contract (contract-call? votingContract veto-action-proposal proposalId))
  )
)

;; the owner or the agent (if enabled) can conclude action proposals if the proposal voting contract is approved
(define-public (conclude-action-proposal
    (votingContract <action-proposal-voting-trait>)
    (proposalId uint)
    (action <action-trait>)
  )
  (begin
    (asserts! (use-proposals-allowed) ERR_OPERATION_NOT_ALLOWED)
    (asserts!
      (is-approved-contract (contract-of votingContract) APPROVED_CONTRACT_VOTING)
      ERR_CONTRACT_NOT_APPROVED
    )
    (print {
      notification: "aibtc-agent-account/conclude-action-proposal",
      payload: {
        proposalContract: (contract-of votingContract),
        proposalId: proposalId,
        action: (contract-of action),
        sender: tx-sender,
        caller: contract-caller,
      },
    })
    (as-contract (contract-call? votingContract conclude-action-proposal proposalId action))
  )
)

;; Generalized trading functions, requires adapter for specific routes

;; the owner or the agent (if enabled) can buy DAO tokens
(define-public (buy-dao-token
    (swapAdapter <dao-swap-adapter>)
    (daoToken <ft-trait>)
    (amount uint)
    (minReceive (optional uint))
  )
  (begin
    (asserts! (buy-sell-assets-allowed) ERR_OPERATION_NOT_ALLOWED)
    (asserts!
      (and
        (is-approved-contract (contract-of swapAdapter) APPROVED_CONTRACT_SWAP)
        (is-approved-contract (contract-of daoToken) APPROVED_CONTRACT_TOKEN)
      )
      ERR_CONTRACT_NOT_APPROVED
    )
    (print {
      notification: "aibtc-agent-account/buy-dao-token",
      payload: {
        swapAdapter: (contract-of swapAdapter),
        daoToken: (contract-of daoToken),
        amount: amount,
        minReceive: minReceive,
        sender: tx-sender,
        caller: contract-caller,
      },
    })
    (as-contract (contract-call? swapAdapter buy-dao-token daoToken amount minReceive))
  )
)

;; the owner or the agent (if enabled) can sell DAO tokens
(define-public (sell-dao-token
    (swapAdapter <dao-swap-adapter>)
    (daoToken <ft-trait>)
    (amount uint)
    (minReceive (optional uint))
  )
  (begin
    (asserts! (buy-sell-assets-allowed) ERR_OPERATION_NOT_ALLOWED)
    (asserts!
      (and
        (is-approved-contract (contract-of swapAdapter) APPROVED_CONTRACT_SWAP)
        (is-approved-contract (contract-of daoToken) APPROVED_CONTRACT_TOKEN)
      )
      ERR_CONTRACT_NOT_APPROVED
    )
    (print {
      notification: "aibtc-agent-account/sell-dao-token",
      payload: {
        swapAdapter: (contract-of swapAdapter),
        daoToken: (contract-of daoToken),
        amount: amount,
        minReceive: minReceive,
        sender: tx-sender,
        caller: contract-caller,
      },
    })
    (as-contract (contract-call? swapAdapter sell-dao-token daoToken amount minReceive))
  )
)

;; Agent Account Configuration Functions

;; the owner can set whether the agent can manage assets (deposit/withdraw)
(define-public (set-agent-can-manage-assets (canManage bool))
  (begin
    (asserts! (is-owner) ERR_CALLER_NOT_OWNER)
    (print {
      notification: "aibtc-agent-account/set-agent-can-manage-assets",
      payload: {
        canManageAssets: canManage,
        sender: tx-sender,
        caller: contract-caller,
      },
    })
    (let ((currentPermissions (var-get agentPermissions)))
      (ok (var-set agentPermissions
        (if canManage
          (bit-or currentPermissions PERMISSION_MANAGE_ASSETS)
          (bit-and currentPermissions (bit-not PERMISSION_MANAGE_ASSETS))
        )
      ))
    )
  )
)

;; the owner can set whether the agent can use proposals
(define-public (set-agent-can-use-proposals (canUseProposals bool))
  (begin
    (asserts! (is-owner) ERR_CALLER_NOT_OWNER)
    (print {
      notification: "aibtc-agent-account/set-agent-can-use-proposals",
      payload: {
        canUseProposals: canUseProposals,
        sender: tx-sender,
        caller: contract-caller,
      },
    })
    (let ((currentPermissions (var-get agentPermissions)))
      (ok (var-set agentPermissions
        (if canUseProposals
          (bit-or currentPermissions PERMISSION_USE_PROPOSALS)
          (bit-and currentPermissions (bit-not PERMISSION_USE_PROPOSALS))
        )
      ))
    )
  )
)

;; the owner can set whether the agent can approve/revoke contracts
(define-public (set-agent-can-approve-revoke-contracts (canApproveRevokeContracts bool))
  (begin
    (asserts! (is-owner) ERR_CALLER_NOT_OWNER)
    (print {
      notification: "aibtc-agent-account/set-agent-can-approve-revoke-contracts",
      payload: {
        canApproveRevokeContracts: canApproveRevokeContracts,
        sender: tx-sender,
        caller: contract-caller,
      },
    })
    (let ((currentPermissions (var-get agentPermissions)))
      (ok (var-set agentPermissions
        (if canApproveRevokeContracts
          (bit-or currentPermissions PERMISSION_APPROVE_REVOKE_CONTRACTS)
          (bit-and currentPermissions (bit-not PERMISSION_APPROVE_REVOKE_CONTRACTS))
        )
      ))
    )
  )
)

;; the owner can set whether the agent can buy/sell tokens
(define-public (set-agent-can-buy-sell-assets (canBuySell bool))
  (begin
    (asserts! (is-owner) ERR_CALLER_NOT_OWNER)
    (print {
      notification: "aibtc-agent-account/set-agent-can-buy-sell-assets",
      payload: {
        canBuySell: canBuySell,
        sender: tx-sender,
        caller: contract-caller,
      },
    })
    (let ((currentPermissions (var-get agentPermissions)))
      (ok (var-set agentPermissions
        (if canBuySell
          (bit-or currentPermissions PERMISSION_BUY_SELL_ASSETS)
          (bit-and currentPermissions (bit-not PERMISSION_BUY_SELL_ASSETS))
        )
      ))
    )
  )
)

;; the owner or the agent (if enabled) can approve a contract for use with the agent account
(define-public (approve-contract
    (contract principal)
    (type uint)
  )
  (begin
    (asserts! (is-valid-type type) ERR_INVALID_APPROVAL_TYPE)
    (asserts! (approve-revoke-contract-allowed) ERR_OPERATION_NOT_ALLOWED)
    (print {
      notification: "aibtc-agent-account/approve-contract",
      payload: {
        contract: contract,
        type: type,
        approved: true,
        sender: tx-sender,
        caller: contract-caller,
      },
    })
    (ok (map-set ApprovedContracts {
      contract: contract,
      type: type,
    }
      true
    ))
  )
)

;; the owner or the agent (if enabled) can revoke a contract from use with the agent account
(define-public (revoke-contract
    (contract principal)
    (type uint)
  )
  (begin
    (asserts! (is-valid-type type) ERR_INVALID_APPROVAL_TYPE)
    (asserts! (approve-revoke-contract-allowed) ERR_OPERATION_NOT_ALLOWED)
    (print {
      notification: "aibtc-agent-account/revoke-contract",
      payload: {
        contract: contract,
        type: type,
        approved: false,
        sender: tx-sender,
        caller: contract-caller,
      },
    })
    (ok (map-set ApprovedContracts {
      contract: contract,
      type: type,
    }
      false
    ))
  )
)

;; helper to get config as response via trait
(define-public (get-config)
  (let ((wrappedConfig (some (get-configuration))))
    (ok (unwrap! wrappedConfig ERR_OPERATION_NOT_ALLOWED))
  )
)

;; read only functions

(define-read-only (is-approved-contract
    (contract principal)
    (type uint)
  )
  (default-to false
    (map-get? ApprovedContracts {
      contract: contract,
      type: type,
    })
  )
)

(define-read-only (get-configuration)
  {
    account: SELF,
    agent: ACCOUNT_AGENT,
    owner: ACCOUNT_OWNER,
    sbtc: SBTC_TOKEN,
  }
)

(define-read-only (get-approval-types)
  {
    proposalVoting: APPROVED_CONTRACT_VOTING,
    swap: APPROVED_CONTRACT_SWAP,
    token: APPROVED_CONTRACT_TOKEN,
  }
)

(define-read-only (get-agent-permissions)
  (let ((permissions (var-get agentPermissions)))
    {
      canManageAssets: (not (is-eq u0 (bit-and permissions PERMISSION_MANAGE_ASSETS))),
      canUseProposals: (not (is-eq u0 (bit-and permissions PERMISSION_USE_PROPOSALS))),
      canApproveRevokeContracts: (not (is-eq u0 (bit-and permissions PERMISSION_APPROVE_REVOKE_CONTRACTS))),
      canBuySell: (not (is-eq u0 (bit-and permissions PERMISSION_BUY_SELL_ASSETS))),
    }
  )
)

;; private functions

(define-private (is-owner)
  (is-eq contract-caller ACCOUNT_OWNER)
)

(define-private (is-agent)
  (is-eq contract-caller ACCOUNT_AGENT)
)

(define-private (is-valid-type (type uint))
  (or
    (is-eq type APPROVED_CONTRACT_VOTING)
    (is-eq type APPROVED_CONTRACT_SWAP)
    (is-eq type APPROVED_CONTRACT_TOKEN)
  )
)

(define-private (manage-assets-allowed)
  (or (is-owner) (and (is-agent) (not (is-eq u0 (bit-and (var-get agentPermissions) PERMISSION_MANAGE_ASSETS)))))
)

(define-private (use-proposals-allowed)
  (or (is-owner) (and (is-agent) (not (is-eq u0 (bit-and (var-get agentPermissions) PERMISSION_USE_PROPOSALS)))))
)

(define-private (approve-revoke-contract-allowed)
  (or (is-owner) (and (is-agent) (not (is-eq u0 (bit-and (var-get agentPermissions) PERMISSION_APPROVE_REVOKE_CONTRACTS)))))
)

(define-private (buy-sell-assets-allowed)
  (or (is-owner) (and (is-agent) (not (is-eq u0 (bit-and (var-get agentPermissions) PERMISSION_BUY_SELL_ASSETS)))))
)

(begin
  ;; print creation event
  (print {
    notification: "aibtc-agent-account/user-agent-account-created",
    payload: {
      config: (get-configuration),
      approvalTypes: (get-approval-types),
      agentPermissions: (get-agent-permissions),
    },
  })
  ;; auto-register the agent account
  (contract-call? 'SPV9K21TBFAK4KNRJXF5DFP8N7W46G4V9RCJDC22.agent-account-registry auto-register-agent-account
    ACCOUNT_OWNER ACCOUNT_AGENT
  )
)
