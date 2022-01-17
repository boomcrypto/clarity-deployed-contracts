(use-trait ft-trait .sip-010-v1a.sip-010-trait)

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
(define-constant ERR_COUNCIL_TERM_LIMIT u4131)
(define-constant ERR_BLOCK_HEIGHT_REACHED u4132)
(define-constant ERR_NOT_STARTED u4133)
(define-constant ERR_INVALID_ROUTER u4133)


(define-constant BASIC_PRINCIPAL tx-sender)
(define-constant VOTING_CYCLE u288)
(define-constant MIN_PROPOSE_LIMIT u8000000000000)
(define-constant MIN_EXECUTE_LIMIT u20000000000000)
(define-constant COUNCIL_TERM_LENGTH u195763)

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
  }
)

(define-data-var proposal-count uint u0)
(define-data-var proposal-ids (list 100 uint) (list u0))

(define-data-var reward-amount-per-proposal uint u1000000)

(define-map votes-by-member { proposal-id: uint, member: principal } { vote-count: uint, returned: bool })

(define-read-only (get-proposals)
  (ok (map get-proposal-by-id (var-get proposal-ids)))
)

(define-read-only (get-proposal-ids)
  (ok (var-get proposal-ids))
)

(define-read-only (get-votes-by-member-by-id (proposal-id uint) (member principal))
  (default-to 
    { vote-count: u0, returned: false }
    (map-get? votes-by-member { proposal-id: proposal-id, member: member })
  )
)

(define-map governance-council principal bool)

(define-read-only (is-council (user principal))
  (match (map-get? governance-council user)
    value true
    false
  )
)

(define-public (add-governance-council (user principal))
  (begin
    (asserts! (is-eq contract-caller (contract-call? .stackswap-dao-v5k get-dao-owner)) (err ERR_NOT_AUTHORIZED))
    (ok (map-set governance-council 
      user true
    ))
  )
)

(map-set governance-council tx-sender true)

(define-public (remove-governance-council (user principal))
  (begin
    (asserts! (is-eq contract-caller (contract-call? .stackswap-dao-v5k get-dao-owner)) (err ERR_NOT_AUTHORIZED))
    (ok (map-delete governance-council 
      user
    ))
  )
)

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
    }
    (map-get? proposals  proposal-id)
  )
)


(define-public (propose
    (start-block-height uint)
    (title (string-utf8 256))
    (url (string-utf8 256))
    (contract-changes (list 10 (tuple (name (string-ascii 256)) (address principal) (qualified-name principal))))
  )
  (let (
    (proposer-balance (unwrap-panic (contract-call? .vstsw-token-v1k get-balance contract-caller)))
    (proposal-id (+ u1 (var-get proposal-count)))
  )
    (asserts! (contract-call? .stackswap-security-list-v1a is-secure-router-or-user contract-caller) (err ERR_INVALID_ROUTER))
    (asserts! (<= block-height start-block-height) (err ERR_BLOCK_PASSED))
    (asserts! (>= proposer-balance MIN_PROPOSE_LIMIT) (err ERR_NOT_ENOUGH_BALANCE))
    (asserts! (> (len contract-changes) u0) (err ERR_NO_CONTRACT_CHANGES))

    (asserts! (is-eq (unwrap! (contract-call? .stackswap-dao-v5k get-qualified-name-by-name "governance") (err ERR_DAO_GET)) (as-contract tx-sender)) (err ERR_NOT_AUTHORIZED))

    (map-set proposals
      proposal-id
      {
        id: proposal-id,
        proposer: contract-caller,
        title: title,
        url: url,
        is-open: true,
        start-block-height: start-block-height,
        end-block-height: (+ start-block-height VOTING_CYCLE),
        yes-votes: u0,
        no-votes: u0,
        contract-changes: contract-changes,
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
    (user contract-caller)
    (user-data (get-votes-by-member-by-id proposal-id user))
    (vote-count (get vote-count user-data))
  )
    (asserts! (contract-call? .stackswap-security-list-v1a is-secure-router-or-user contract-caller) (err ERR_INVALID_ROUTER))
    (asserts! (is-eq (get is-open proposal) true) (err ERR_PROPOSAL_IS_NOT_OPEN))
    (asserts! (>= block-height (get start-block-height proposal)) (err ERR_NOT_STARTED))
    (asserts! (< block-height (get end-block-height proposal)) (err ERR_BLOCK_HEIGHT_REACHED))
    (unwrap! (contract-call? .vstsw-token-v1k transfer amount user (as-contract tx-sender) none) (err ERR_TRANSFER_FAIL))
    (map-set proposals
      proposal-id 
      (merge proposal { yes-votes: (+ amount (get yes-votes proposal)) }))
    (map-set votes-by-member 
      { proposal-id: proposal-id, member: user }
      (merge user-data { vote-count: (+ vote-count amount)}))
    (ok true)
  )
)

(define-public (vote-against (proposal-id uint) (amount uint))
  (let (
    (proposal (get-proposal-by-id proposal-id))
    (user contract-caller)
    (user-data (get-votes-by-member-by-id proposal-id user))
    (vote-count (get vote-count user-data))
  )
    (asserts! (contract-call? .stackswap-security-list-v1a is-secure-router-or-user contract-caller) (err ERR_INVALID_ROUTER))
    (asserts! (is-eq (get is-open proposal) true) (err ERR_PROPOSAL_IS_NOT_OPEN))
    (asserts! (>= block-height (get start-block-height proposal)) (err ERR_NOT_STARTED))
    (asserts! (< block-height (get end-block-height proposal)) (err ERR_BLOCK_HEIGHT_REACHED))
    (unwrap! (contract-call? .vstsw-token-v1k transfer amount user (as-contract tx-sender) none ) (err ERR_TRANSFER_FAIL))
    (map-set proposals
      proposal-id
      (merge proposal { no-votes: (+ amount (get no-votes proposal)) }))
    (map-set votes-by-member 
      { proposal-id: proposal-id, member: user }
      (merge user-data { vote-count: (+ vote-count amount)}))
    (ok true)
  )
)

(define-public (end-proposal (proposal-id uint))
  (let ((proposal (get-proposal-by-id proposal-id)))

    (asserts! (not (is-eq (get id proposal) u0)) (err ERR_NOT_AUTHORIZED))
    (asserts! (is-eq (get is-open proposal) true) (err ERR_PROPOSAL_IS_NOT_OPEN))
    (asserts! (>= block-height (get end-block-height proposal)) (err ERR_BLOCK_HEIGHT_NOT_REACHED))
    (asserts! (contract-call? .stackswap-security-list-v1a is-secure-router-or-user contract-caller) (err ERR_INVALID_ROUTER))

    (map-set proposals
      proposal-id
      (merge proposal { is-open: false }))
    (ok 
      (if
        (and 
          (> (+ (get yes-votes proposal) (get no-votes proposal)) MIN_EXECUTE_LIMIT)
          (> (get yes-votes proposal) (get no-votes proposal))
        )
        (try! (execute-proposal proposal-id))
        false
      )
    )
  )
)

(define-public (veto-proposal (proposal-id uint))
  (let ((proposal (get-proposal-by-id proposal-id)))
    (asserts! (< block-height COUNCIL_TERM_LENGTH) (err ERR_COUNCIL_TERM_LIMIT))
    (asserts! (not (is-eq (get id proposal) u0)) (err ERR_NOT_AUTHORIZED))
    (asserts! (is-eq (get is-open proposal) true) (err ERR_PROPOSAL_IS_NOT_OPEN))
    (asserts! (>= block-height (get start-block-height proposal)) (err ERR_NOT_STARTED))
    (asserts! (< block-height (get end-block-height proposal)) (err ERR_BLOCK_HEIGHT_REACHED))
    (asserts! (is-council contract-caller) (err ERR_NOT_AUTHORIZED))
    (map-set proposals
      proposal-id
      (merge proposal { is-open: false, end-block-height: (+ block-height u1) }))
    (ok true)
  )
)

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

    (as-contract (contract-call? .vstsw-token-v1k transfer vote-count tx-sender member none))
  )
)

(define-private (execute-proposal (proposal-id uint))
  (let (
    (proposal (get-proposal-by-id proposal-id))
    (contract-changes (get contract-changes proposal))
  )
    (asserts! (> (len contract-changes) u0) (err ERR_NO_CONTRACT_CHANGES))
    (unwrap! (as-contract (contract-call? .stackswap-dao-v5k execute-proposals contract-changes)) (err ERR_NO_CONTRACT_CHANGES))
    (ok true)
  )
)

(define-public (add-contract-address (name (string-ascii 256)) (address principal) (qualified-name principal))
  (begin
    (asserts! (is-eq contract-caller (contract-call? .stackswap-dao-v5k get-dao-owner)) (err ERR_NOT_AUTHORIZED))

    (if (is-some (contract-call? .stackswap-dao-v5k get-contract-address-by-name name))
      (ok false)
      (begin
        (try! (as-contract (contract-call? .stackswap-dao-v5k set-contract-address name address qualified-name)))
        (ok true)
      )
    )
  )
)
