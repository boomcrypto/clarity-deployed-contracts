

;; micro-dao
;;
;; Small contract to manage a simple DAO structure for small teams
(impl-trait 'SP32AEEF6WW5Y0NMJ1S8SBSZDAY8R5J32NBZFPKKZ.micro-dao-trait.micro-dao)

;; constants
;;

;; 5 days before an action could be executed if no dissent was put up


(define-constant DISSENT-EXPIRY u144)


;; proposal statuses

(define-constant PROPOSED u0)
(define-constant PASSED u1)
(define-constant FAILED u2)

;; membership errors codes start with 1
(define-constant MEMBER-EXISTS u1001)
(define-constant MEMBER-NOT-FOUND u1002)

;; balance error codes start with 2
(define-constant NOT-ENOUGH-FUNDS u2001)

;; auth error codes start with 3
(define-constant NOT-DIRECT-CALLER u3001)
(define-constant NOT-MEMBER u3002)

;; proposal error codes start with 4
(define-constant PROPOSAL-NOT-FOUND u4001)
(define-constant PROPOSAL-DISSENT-EXPIRED u4002)
;; when proposal is no longer proposed and had either passed or failed
;; no further changes should be made

(define-constant PROPOSAL-FROZEN u4003)

(define-constant PROPOSAL-DISSENT-ACTIVE u4004)

;; initial members of dao
(define-constant INITIAL-MEMBERS 
    (list 
        {address: tx-sender}
        {address: 'SP2M63YGBZCTWBWBCG77RET0RMP42C08T73MKAPNP}
        {address: 'SP2P8QYQX5PMKVBXQ9FWK8F96J8DJXXW7NB7AA5DT}
      ))

;; data maps and vars
;;

;; members of the DAO who could create funding proposals and manage their balances

(define-map members uint {address: principal})
(define-map member-id-by-address principal uint)
(define-map funding-proposals uint 
    {
        targets: (list 10 
            {
                address: principal,
                amount: uint
            }), 
        proposer: principal,
        created-at: uint,
        status: uint,
        total-amount: uint,
        memo: (string-utf8 50)
    })


(define-data-var members-count uint u0)
(define-data-var funding-proposals-count uint u0)

;; Funding proposals where we store funding proposals

;; vouch proposals

;; private functions
;;

(define-private (add-member (data {address: principal})) 
    (let
        (
            (current-index (var-get members-count))
        )
        (if (map-insert members current-index data) 
            (begin 
                (map-insert member-id-by-address (get address data) current-index)
                (ok (var-set members-count (+ u1 current-index))))
            (err MEMBER-EXISTS))))

(define-private (get-amount (target {address: principal, amount: uint})) 
    (get amount target))

(define-private (is-member (address principal))
    (is-some (map-get? member-id-by-address address)))

(define-private (send-stx-to-target (target {address: principal, amount: uint})) 
    (let (
        (amount (get amount target))
        (address (get address target))
    ) 
    (as-contract (stx-transfer? amount tx-sender address))))


(define-private (check-err (result (response bool uint)) (prior (response bool uint)))
    (match prior ok-value result
        err-value (err err-value)))

;; public functions
;;

;; get member data

(define-read-only (get-member-data (id uint)) 
    (ok (unwrap! (map-get? members id) (err MEMBER-NOT-FOUND))))



(define-read-only (get-member-id (member-address principal)) 
    (ok (unwrap! (map-get? member-id-by-address member-address) (err MEMBER-NOT-FOUND))))

(define-read-only (get-member-balance (member-id uint)) 
    (ok (/ (get-balance-raw) (var-get members-count))))

;; get balance


(define-read-only (get-balance-raw) 
    (stx-get-balance (as-contract tx-sender)))

(define-read-only (get-balance) 
    (ok (get-balance-raw)))



(define-read-only (is-dissent-passed (created-at uint)) 
    (let (
        (difference (- burn-block-height created-at))
    )
    (>= difference DISSENT-EXPIRY)))
;; propose to add new member


(define-read-only (get-proposal-raw (proposal-id uint)) 
    (map-get? funding-proposals proposal-id))

(define-read-only (get-proposal (proposal-id uint))
    (ok (unwrap! (get-proposal-raw proposal-id) (err PROPOSAL-NOT-FOUND))))

(define-read-only (get-proposal-status (proposal-id uint)) 
    (ok (unwrap! (get status (get-proposal-raw proposal-id)) (err PROPOSAL-NOT-FOUND))))


;; propose a new funding proposal

(define-public (create-funding-proposal (targets (list 10 {address: principal, amount: uint})) (memo (string-utf8 50)))
    (let (
            (balance (get-balance-raw))
            (total-amount (fold + (map get-amount targets) u0))
            (current-index (var-get funding-proposals-count))
            (data { targets: targets, proposer: tx-sender, created-at: burn-block-height, status: PROPOSED, memo: memo })
        )
        (asserts! (is-eq contract-caller tx-sender) (err NOT-DIRECT-CALLER))
        (asserts! (is-member tx-sender) (err NOT-MEMBER))
        (asserts! (<= total-amount balance) (err NOT-ENOUGH-FUNDS))
        (map-insert funding-proposals current-index (merge data { total-amount: total-amount }))
        (var-set funding-proposals-count (+ u1 current-index))
        ;; add to funding proposal list
        (ok true)))


;; dissent on funding proposal

(define-public (dissent (proposal-id uint)) 
    (let (
            (proposal (unwrap! (get-proposal-raw proposal-id) (err PROPOSAL-NOT-FOUND)))
            (created-at (get created-at proposal))
            (status (get status proposal))
        ) 
        (asserts! (is-eq contract-caller tx-sender) (err NOT-DIRECT-CALLER))
        (asserts! (is-member tx-sender) (err NOT-MEMBER))
        ;; #[filter(proposal-id)]
        (asserts! (not (is-dissent-passed created-at)) (err PROPOSAL-DISSENT-EXPIRED))
        ;; #[filter(proposal-id)]
        (asserts! (is-eq status PROPOSED) (err PROPOSAL-FROZEN))
        (map-set funding-proposals proposal-id (merge proposal {status: FAILED}))
        
        (ok true)))


;; execute proposal
;; take a proposal-id 
;; check that:
;; get the list of targets to pay off
;; send stx to the targets list 
;; mark proposal as PASSED


(define-public (execute-funding-proposal (proposal-id uint)) 
    (let (
        (proposal (unwrap! (get-proposal-raw proposal-id) (err PROPOSAL-NOT-FOUND)))
        (created-at (get created-at proposal))
        (balance (get-balance-raw))
        (targets (get targets proposal))
        (total-amount (get total-amount proposal))
        (status (get status proposal))
    ) 
    (asserts! (is-eq contract-caller tx-sender) (err NOT-DIRECT-CALLER))
    (asserts! (is-member tx-sender) (err NOT-MEMBER))
    ;; #[filter(proposal-id)]
    (asserts! (<= total-amount balance) (err NOT-ENOUGH-FUNDS))
    ;; #[filter(proposal-id)]
    (asserts! (is-eq status PROPOSED) (err PROPOSAL-FROZEN))
    ;; #[filter(proposal-id)]
    (asserts! (is-dissent-passed created-at) (err PROPOSAL-DISSENT-ACTIVE))
    (map-set funding-proposals proposal-id (merge proposal {status: PASSED}))
    (fold check-err (map send-stx-to-target targets) (ok true))))

(define-public (deposit (amount uint)) 
    (begin 
        (asserts! (is-eq contract-caller tx-sender) (err NOT-DIRECT-CALLER))
        (stx-transfer? amount tx-sender (as-contract tx-sender))
    ))


;; vote to support funding proposal


;; vote to support adding a new member

;; exit dao


;; INIT
;;


(map add-member INITIAL-MEMBERS)