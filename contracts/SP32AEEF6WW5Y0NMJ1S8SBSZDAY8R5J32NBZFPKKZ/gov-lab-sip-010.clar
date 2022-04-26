

;; micro-dao
;;
;; Small contract to manage a simple DAO structure for small teams
(impl-trait 'SP32AEEF6WW5Y0NMJ1S8SBSZDAY8R5J32NBZFPKKZ.micro-dao-sip-010-trait.micro-dao-sip-010-trait)

(use-trait sip-010-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

;; constants
;;

;; 5 days before an action could be executed if no dissent was put up

(define-constant ALLOWED-TOKENS (list 
    'SP32AEEF6WW5Y0NMJ1S8SBSZDAY8R5J32NBZFPKKZ.wstx
    'SP32AEEF6WW5Y0NMJ1S8SBSZDAY8R5J32NBZFPKKZ.wrapped-nothing-v8
    'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin
    'SP466FNC0P7JWTNM2R9T199QRZN1MYEDTAR0KP27.miamicoin-token
    'SP2H8PY27SEZ03MWRKS5XABZYQN17ETGQS3527SA5.newyorkcitycoin-token
    'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
    'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token
    'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token
    'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-apower
))

(define-constant DISSENT-EXPIRY u720)


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
(define-constant INVALID-TOKEN u3003)

;; proposal error codes start with 4
(define-constant PROPOSAL-NOT-FOUND u4001)
(define-constant PROPOSAL-DISSENT-EXPIRED u4002)


;; when proposal is no longer proposed and had either passed or failed
;; no further changes should be made

(define-constant PROPOSAL-FROZEN u4003)

(define-constant PROPOSAL-DISSENT-ACTIVE u4004)


;; outside contracts
(define-constant WTF u0)

;; initial members of dao
(define-constant INITIAL-MEMBERS 
    (list 
        {address: tx-sender}
        {address: 'SP2D87B1TF7TBN5WD127EZ5NT7WB51ZVVAMWWAC95}
      ))

;; data maps and vars
;;

;; members of the DAO who could create funding proposals and manage their balances

(define-map members uint {address: principal})
(define-map member-id-by-address principal uint)

(define-map allowed-tokens principal bool)


(define-map funding-proposals uint 
    {
        targets: (list 10 
            {
                address: principal,
                amount: uint
            }), 
        proposer: principal,
        token-contract: principal,
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


(define-private (add-token (token-contract principal))
    (map-set allowed-tokens token-contract true))

(define-private (get-amount (target {address: principal, amount: uint})) 
    (get amount target))

(define-private (is-member (address principal))
    (is-some (map-get? member-id-by-address address)))


(define-private (send-token-to-target (target {address: principal, amount: uint}) (token-contract <sip-010-trait>)) 
    (let (
        (amount (get amount target))
        (address (get address target))
        (token-contract (contract-of token-contract))
    )
    (as-contract (token-transfer token-contract amount (as-contract tx-sender) address none))))



(define-private (check-err (result (response bool uint)) (prior (response bool uint)))
    (match prior ok-value result
        err-value (err err-value)))

(define-private (token-transfer (contract <sip-010-trait>) (amount uint) (from principal) (to principal) (memo (optional (buff 34))))
    (contract-call? contract transfer amount from to memo)
)


(define-private (get-balance (contract <sip-010-trait>) (account principal)) 
    (contract-call? contract get-balance account))

(define-private (repeat-10 (contract <sip-010-trait>)) 
    (list contract contract contract contract contract contract contract contract contract contract))

;; public functions
;;

;; get member data

(define-read-only (get-member-data (id uint)) 
    (ok (unwrap! (map-get? members id) (err MEMBER-NOT-FOUND))))



(define-read-only (get-member-id (member-address principal)) 
    (ok (unwrap! (map-get? member-id-by-address member-address) (err MEMBER-NOT-FOUND))))


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


(define-read-only (is-valid-token (contract principal))
    (is-some (map-get? allowed-tokens contract)))

;; propose a new funding proposal

(define-public (create-funding-proposal (targets (list 10 {address: principal, amount: uint})) (memo (string-utf8 50)) (token-contract <sip-010-trait>))
    (let (
            ;; wtf on error cuz it should nevah
            (balance (unwrap! (get-balance token-contract (as-contract tx-sender)) (err WTF)))
            (total-amount (fold + (map get-amount targets) u0))
            (current-index (var-get funding-proposals-count))
            (data { targets: targets, proposer: tx-sender, created-at: burn-block-height, status: PROPOSED, memo: memo, token-contract: (contract-of token-contract) })
        )       
        (asserts! (is-eq contract-caller tx-sender) (err NOT-DIRECT-CALLER))
        (asserts! (is-valid-token (contract-of token-contract)) (err INVALID-TOKEN))
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
;; send tokens to the targets list 
;; mark proposal as PASSED


(define-public (execute-funding-proposal (proposal-id uint) (token-contract <sip-010-trait>)) 
    (let (
        (proposal (unwrap! (get-proposal-raw proposal-id) (err PROPOSAL-NOT-FOUND)))
        (created-at (get created-at proposal))
        (balance (unwrap! (get-balance token-contract (as-contract tx-sender)) (err WTF)))
        (targets (get targets proposal))
        (total-amount (get total-amount proposal))
        (proposal-contract (get token-contract proposal))
        (status (get status proposal))
    ) 
    (asserts! (is-eq contract-caller tx-sender) (err NOT-DIRECT-CALLER))
    (asserts! (is-valid-token (contract-of token-contract)) (err INVALID-TOKEN))
    (asserts! (is-eq (contract-of token-contract) proposal-contract) (err INVALID-TOKEN))
    (asserts! (is-member tx-sender) (err NOT-MEMBER))
    ;; #[filter(proposal-id)]
    (asserts! (<= total-amount balance) (err NOT-ENOUGH-FUNDS))
    ;; #[filter(proposal-id)]
    (asserts! (is-eq status PROPOSED) (err PROPOSAL-FROZEN))
    ;; #[filter(proposal-id)]
    (asserts! (is-dissent-passed created-at) (err PROPOSAL-DISSENT-ACTIVE))
    (map-set funding-proposals proposal-id (merge proposal {status: PASSED}))
    (fold check-err (map send-token-to-target targets (repeat-10 token-contract)) (ok true))))


(define-public (deposit (token-contract <sip-010-trait>) (amount uint))
    (let (
        (balance (unwrap! (get-balance token-contract  tx-sender) (err WTF)))
    ) 
        (asserts! (is-eq contract-caller tx-sender) (err NOT-DIRECT-CALLER))
        (asserts! (is-valid-token (contract-of token-contract)) (err INVALID-TOKEN))
        (asserts! (>= balance amount) (err NOT-ENOUGH-FUNDS))
        (token-transfer token-contract amount tx-sender (as-contract tx-sender) none)
    ))

;; INIT
;;

(map add-token ALLOWED-TOKENS)

(map add-member INITIAL-MEMBERS)