;; Error codes
(define-constant ERR_INSUFFICIENT_FUND_IN_CONTRACT u5001)
(define-constant ERR_INSUFFICIENT_FUND_IN_WALLET u5002)
(define-constant ERR_NOT_OPERATOR u5003)
(define-constant ERR_NOT_A_MEMBER u5004)
(define-constant ERR_VOTING_RESULT_NOT_MET u5005)

;; Variables
(define-data-var operator principal tx-sender)
(define-data-var vote_members (list 3 principal) (list))
(define-data-var vote_members_wo_operator (list 2 principal) (list))

(define-map vote_map_deposit {member: principal, mode: uint} {decision: bool})
(define-map vote_map_withdraw {member: principal, mode: uint} {decision: bool})

(define-constant MODE_DEPOSIT u1001)
(define-constant MODE_WITHDRAW u1002)

(define-constant VOTE_REQUIRE u2)

(begin
    (var-set
        vote_members
        (list 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275 'SP1MCDGYJ31M8N6944JFR9G39PG49VD1C981FJ56N 'SP3GPQ67G54F0JE6V8SG5F9QW2X12EWC28KCK9QSR)
    )
)

;; Get functions
(define-read-only (get-operator)
  (var-get operator)
)
(define-read-only (get-voters)
  (var-get vote_members)
)

;; Set functions
(define-public (set-operator (address principal))
  (begin
    (asserts! (is-eq contract-caller (var-get operator)) (err ERR_NOT_OPERATOR))

    (var-set operator address)
    (ok (var-set vote_members (unwrap-panic (as-max-len? (append  (var-get vote_members_wo_operator) (var-get operator)) u3))))

  )
)

(define-public (set-voters (new-members (list 2 principal)))
  (begin
        (asserts! (is-eq contract-caller (var-get operator)) (err ERR_NOT_OPERATOR))
        (var-set vote_members_wo_operator new-members)
        (ok (var-set vote_members (unwrap-panic (as-max-len? (append  new-members (var-get operator)) u3))))
  )
)

;; Vote
(define-public (deposit-vote (decision bool))
    (begin
        (asserts! (is-some (index-of (var-get vote_members) contract-caller)) (err ERR_NOT_A_MEMBER))
        (ok (map-set vote_map_deposit {member: contract-caller, mode: MODE_DEPOSIT} {decision: decision}))
    )
)

(define-public (withdraw-vote (decision bool))
    (begin
        (asserts! (is-some (index-of (var-get vote_members) contract-caller)) (err ERR_NOT_A_MEMBER))
        (ok (map-set vote_map_deposit {member: contract-caller, mode: MODE_WITHDRAW} {decision: decision}))
    )
)

(define-read-only (get-vote (member principal) (mode_id uint))
    (default-to false (get decision (map-get? vote_map_deposit {member: member, mode: mode_id})))
)

(define-private (sum_deposit_vote (member principal) (accumulator uint))
    (if (get-vote member MODE_DEPOSIT) (+ accumulator u1) accumulator)
)

(define-private (sum_withdraw_vote (member principal) (accumulator uint))
    (if (get-vote member MODE_WITHDRAW) (+ accumulator u1) accumulator)
)

(define-private (reset_deposit_vote (member principal) )
    (map-set vote_map_deposit {member: member, mode: MODE_DEPOSIT} {decision: false})
)

(define-private (reset_withdraw_vote (member principal) )
    (map-set vote_map_withdraw {member: member, mode: MODE_WITHDRAW} {decision: false})
)

(define-read-only (get-res-deposit)
    (fold sum_deposit_vote (var-get vote_members) u0)
)

(define-read-only (get-res-withdraw)
    (fold sum_withdraw_vote (var-get vote_members) u0)
)

;; Execute by voting result
(define-public (deposit (amountSTSW uint))
    (let
        (
            (total-votes (get-res-deposit))
        )
        (asserts! (is-eq contract-caller (var-get operator)) (err ERR_NOT_OPERATOR))
        (asserts! (>= total-votes VOTE_REQUIRE ) (err ERR_VOTING_RESULT_NOT_MET))

        (asserts! (>= (unwrap-panic (contract-call? .stsw-token-v4a get-balance contract-caller)) amountSTSW ) (err ERR_INSUFFICIENT_FUND_IN_WALLET))
        (try! (contract-call? .stsw-token-v4a transfer amountSTSW (var-get operator) (as-contract tx-sender) none))

        ;; Reset map data
        ;; (map reset_deposit_vote (var-get vote_members))
        (ok total-votes)
    )
)

(define-public (withdraw (to_addr principal) (amountSTSW uint))
    (let
        (
            (total-votes (get-res-withdraw))
        )
        (asserts! (is-eq contract-caller (var-get operator)) (err ERR_NOT_OPERATOR))
        (asserts! (>= total-votes VOTE_REQUIRE ) (err ERR_VOTING_RESULT_NOT_MET))

        (asserts! (>= (unwrap-panic (contract-call? .stsw-token-v4a get-balance (as-contract tx-sender))) amountSTSW ) (err ERR_INSUFFICIENT_FUND_IN_CONTRACT))
        (try! (as-contract (contract-call? .stsw-token-v4a transfer amountSTSW tx-sender to_addr none)))

        ;; Reset map data
        ;; (map reset_withdraw_vote (var-get vote_members))
        (ok total-votes)
    )
)

(define-public (set_vote_default_withdraw)
    (begin  
        (asserts! (is-eq contract-caller (var-get operator)) (err ERR_NOT_OPERATOR))
        (ok (map reset_withdraw_vote (var-get vote_members)))
    )
)

(define-public (set_vote_default_deposit)
    (begin  
        (asserts! (is-eq contract-caller (var-get operator)) (err ERR_NOT_OPERATOR))
        (ok (map reset_deposit_vote (var-get vote_members)))
    )
)