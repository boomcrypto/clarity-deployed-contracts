(use-trait ft-trait 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.sip-010-v1a.sip-010-trait)

;; stackswap governance
;; 
;; Can see, vote and submit a new proposal
;; A proposal will just update the DAO with new contracts.

;; GOVERNANCE ERRORS 4120~4139
(define-constant ERR_NOT_ENOUGH_BALANCE u4121)
(define-constant ERR_NO_CONTRACT_CHANGES u4122)
(define-constant ERR_CONTRACT_CHANGE_CALL u4123)
(define-constant ERR_BLOCK_HEIGHT_NOT_REACHED u4124)
(define-constant ERR_NOT_AUTHORIZED u4125)
(define-constant ERR_PROPOSAL_IS_NOT_OPEN u4126)
(define-constant ERR_BLOCK_PASSED u4127)
(define-constant ERR_DAO_GET u4128)
(define-constant ERR_ALREADY_RETURNED u4129)
(define-constant ERR_TRANSFER_FAIL u4130)
;; (define-constant ERR_REWARD_FAIL u4131)
(define-constant ERR_BLOCK_HEIGHT_REACHED u4132)
(define-constant ERR_NOT_STARTED u4133)


;; Constants
(define-constant BASIC_PRINCIPAL tx-sender)
(define-constant VOTING_CYCLE u864)


;; Proposal variables
(define-map proposals
  uint
  {
    id: uint,
    proposer: principal,
    title: (string-utf8 256),
    url: (string-utf8 256),
    is-open: bool,
    start-block-height: uint,
    end-block-height: uint,
    yes-votes: uint,
    no-votes: uint,
    contract-changes: (list 10 (tuple (name (string-ascii 256)) (address principal) (qualified-name principal))),
    ;; rewards: uint
  }
)

(define-data-var proposal-count uint u0)
(define-data-var proposal-ids (list 100 uint) (list u0))

(define-data-var reward-amount-per-proposal uint u1000000)

(define-map votes-by-member { proposal-id: uint, member: principal } { vote-count: uint, returned: bool })

;; Get all proposals
(define-read-only (get-proposals)
  (ok (map get-proposal-by-id (var-get proposal-ids)))
)

;; Get all proposal IDs
(define-read-only (get-proposal-ids)
  (ok (var-get proposal-ids))
)

;; Get votes for a member on proposal
(define-read-only (get-votes-by-member-by-id (proposal-id uint) (member principal))
  (default-to 
    { vote-count: u0, returned: false }
    (map-get? votes-by-member { proposal-id: proposal-id, member: member })
  )
)

(define-map exit-controller principal bool)

(define-read-only (is-exitable (user principal))
  (match (map-get? exit-controller user)
    value true
    false
  )
)

(define-public (add-exit-controller (user principal))
  (begin
    (asserts! (is-eq tx-sender (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-dao-v5d get-dao-owner)) (err ERR_NOT_AUTHORIZED))
    (ok (map-set exit-controller 
      user true
    ))
  )
)

(map-set exit-controller tx-sender true)

(define-public (remove-exit-controller (user principal))
  (begin
    (asserts! (is-eq tx-sender (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-dao-v5d get-dao-owner)) (err ERR_NOT_AUTHORIZED))
    (ok (map-delete exit-controller 
      user
    ))
  )
)

;; Get proposal
(define-read-only (get-proposal-by-id (proposal-id uint))
  (default-to
    {
      id: u0,
      proposer: BASIC_PRINCIPAL,
      title: u"",
      url: u"",
      is-open: false,
      start-block-height: u0,
      end-block-height: u0,
      yes-votes: u0,
      no-votes: u0,
      contract-changes: (list { name: "", address: BASIC_PRINCIPAL, qualified-name: BASIC_PRINCIPAL} ),
      ;; rewards: (var-get reward-amount-per-proposal)
    }
    (map-get? proposals  proposal-id)
  )
)


;; Start a proposal
;; Requires 1% of the supply in your wallet
;; Default voting period is 5 days (144 * 5 blocks) // templory 4 blocks
(define-public (propose
    (start-block-height uint)
    (title (string-utf8 256))
    (url (string-utf8 256))
    (contract-changes (list 10 (tuple (name (string-ascii 256)) (address principal) (qualified-name principal))))
  )
  (let (
    ;; (proposer-balance-stsw (unwrap-panic (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a get-balance tx-sender)))
    (proposer-balance (unwrap-panic (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.vstsw-token-v1d get-balance tx-sender)))
    ;; (proposer-balance (+ proposer-balance-stsw proposer-balance-vstsw))
    ;; (supply (- (unwrap-panic (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a get-total-supply)) u200000000))
    (proposal-id (+ u1 (var-get proposal-count)))
  )
    (asserts! (<= block-height start-block-height) (err ERR_BLOCK_PASSED))
    ;; Requires 1% of the supply 
    (asserts! (>= proposer-balance u10000000000000) (err ERR_NOT_ENOUGH_BALANCE))
    ;; Mutate
    (asserts! (> (len contract-changes) u0) (err ERR_NO_CONTRACT_CHANGES))

    (asserts! (is-eq (unwrap! (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-dao-v5d get-qualified-name-by-name "governance") (err ERR_DAO_GET)) (as-contract tx-sender)) (err ERR_NOT_AUTHORIZED))

    (map-set proposals
      proposal-id
      {
        id: proposal-id,
        proposer: tx-sender,
        title: title,
        url: url,
        is-open: true,
        start-block-height: start-block-height,
        end-block-height: (+ start-block-height VOTING_CYCLE),
        yes-votes: u0,
        no-votes: u0,
        contract-changes: contract-changes,
        ;; rewards: (var-get reward-amount-per-proposal)
      }
    )
    (var-set proposal-count proposal-id)
    (var-set proposal-ids (unwrap-panic (as-max-len? (append (var-get proposal-ids) proposal-id) u100)))
    (ok true)
  )
)

(define-public (vote-for (proposal-id uint) (amount uint))
  (let (
    (proposal (get-proposal-by-id proposal-id))
    (user-data (get-votes-by-member-by-id proposal-id tx-sender))
    (vote-count (get vote-count user-data))
  )
    ;; Proposal should be open for voting
    (asserts! (is-eq (get is-open proposal) true) (err ERR_PROPOSAL_IS_NOT_OPEN))
    ;; Vote should be casted after the start-block-height
    (asserts! (>= block-height (get start-block-height proposal)) (err ERR_NOT_STARTED))
    (asserts! (< block-height (get end-block-height proposal)) (err ERR_BLOCK_HEIGHT_REACHED))
    ;; Voter should be able to stake
    (unwrap! (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.vstsw-token-v1d transfer amount tx-sender (as-contract tx-sender) none) (err ERR_TRANSFER_FAIL))
    ;; Mutate
    (map-set proposals
      proposal-id 
      (merge proposal { yes-votes: (+ amount (get yes-votes proposal)) }))
    (map-set votes-by-member 
      { proposal-id: proposal-id, member: tx-sender }
      (merge user-data { vote-count: (+ vote-count amount)}))
    (ok true)
  )
)

(define-public (vote-against (proposal-id uint) (amount uint))
  (let (
    (proposal (get-proposal-by-id proposal-id))
    (user-data (get-votes-by-member-by-id proposal-id tx-sender))
    (vote-count (get vote-count user-data))
  )
    ;; Proposal should be open for voting
    (asserts! (is-eq (get is-open proposal) true) (err ERR_PROPOSAL_IS_NOT_OPEN))
    ;; Vote should be casted after the start-block-height
    (asserts! (>= block-height (get start-block-height proposal)) (err ERR_NOT_STARTED))
    (asserts! (< block-height (get end-block-height proposal)) (err ERR_BLOCK_HEIGHT_REACHED))
    ;; Voter should be able to stake
    (unwrap! (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.vstsw-token-v1d transfer amount tx-sender (as-contract tx-sender) none ) (err ERR_TRANSFER_FAIL))
    ;; Mutate
    (map-set proposals
      proposal-id
      (merge proposal { no-votes: (+ amount (get no-votes proposal)) }))
    (map-set votes-by-member 
      { proposal-id: proposal-id, member: tx-sender }
      (merge user-data { vote-count: (+ vote-count amount)}))
    (ok true)
  )
)

(define-public (end-proposal (proposal-id uint))
  (let ((proposal (get-proposal-by-id proposal-id)))

    (asserts! (not (is-eq (get id proposal) u0)) (err ERR_NOT_AUTHORIZED))
    (asserts! (is-eq (get is-open proposal) true) (err ERR_PROPOSAL_IS_NOT_OPEN))
    (asserts! (>= block-height (get end-block-height proposal)) (err ERR_BLOCK_HEIGHT_NOT_REACHED))

    (map-set proposals
      proposal-id
      (merge proposal { is-open: false }))
    (and
      (> (get yes-votes proposal) (get no-votes proposal))
      (try! (execute-proposal proposal-id))
    )
    (ok true)
  )
)

(define-public (exit-proposal (proposal-id uint))
  (let ((proposal (get-proposal-by-id proposal-id)))

    (asserts! (not (is-eq (get id proposal) u0)) (err ERR_NOT_AUTHORIZED))
    (asserts! (is-eq (get is-open proposal) true) (err ERR_PROPOSAL_IS_NOT_OPEN))
    (asserts! (>= block-height (get start-block-height proposal)) (err ERR_NOT_STARTED))
    (asserts! (< block-height (get end-block-height proposal)) (err ERR_BLOCK_HEIGHT_REACHED))
    (asserts! (is-exitable tx-sender) (err ERR_NOT_AUTHORIZED))
    (map-set proposals
      proposal-id
      (merge proposal { is-open: false, end-block-height: (+ block-height u1) }))
    (ok true)
  )
)

;; Return votes to voter
(define-public (return-votes-to-member (proposal-id uint) (member principal))
  (let (
    (user-data (get-votes-by-member-by-id proposal-id member))
    (vote-count (get vote-count user-data))
    (returned (get returned user-data))
    (proposal (get-proposal-by-id proposal-id))
  )
    (asserts! (is-eq (get is-open proposal) false) (err ERR_PROPOSAL_IS_NOT_OPEN))
    (asserts! (>= block-height (get end-block-height proposal)) (err ERR_NOT_AUTHORIZED))
    (asserts! (not returned) (err ERR_ALREADY_RETURNED))
    (map-set votes-by-member 
      { proposal-id: proposal-id, member: member }
      (merge user-data { returned : true}))

    (as-contract (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.vstsw-token-v1d transfer vote-count (as-contract tx-sender) member none))
  )
)

;; Make needed contract changes on DAO
(define-private (execute-proposal (proposal-id uint))
  (let (
    (proposal (get-proposal-by-id proposal-id))
    (contract-changes (get contract-changes proposal))
  )
    (asserts! (> (len contract-changes) u0) (err ERR_NO_CONTRACT_CHANGES))
    (unwrap! (as-contract (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-dao-v5d execute-proposals contract-changes)) (err ERR_NO_CONTRACT_CHANGES))
    (ok true)
  )
)

;; adds a new contract, only new ones allowed
(define-public (add-contract-address (name (string-ascii 256)) (address principal) (qualified-name principal))
  (begin
    (asserts! (is-eq tx-sender (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-dao-v5d get-dao-owner)) (err ERR_NOT_AUTHORIZED))

    (if (is-some (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-dao-v5d get-contract-address-by-name name))
      (ok false)
      (begin
        (try! (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-dao-v5d set-contract-address name address qualified-name))
        (ok true)
      )
    )
  )
)
