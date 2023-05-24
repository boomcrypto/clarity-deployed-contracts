(define-constant ERR_NOT_LOTTERY_CONTRACT 10001)
(define-constant ERR_NO_WINNER_YET 10002)
(define-constant ERR_NOT_WINNER 10003)
(define-constant ERR_SINGLE_WINNER 10004)
(define-constant ERR_MULTI_WINNERS 10005)
(define-constant ERR_NO_SUCH_WINNER 10006)
(define-constant ERR_BNS_RESOLVE_FAIL 10007)
(define-constant ERR_VOTE_NOT_EXIST 10008)
(define-constant ERR_LOTTERY_CONTRACT_SET 10009)
(define-constant ERR_LOTTERY_CONTRACT_NOT_SET 10010)

(define-data-var m_lottery_contract (optional principal) none)
(define-data-var m_winners (list 3 principal) (list))
(define-data-var m_vote_id uint u0)

(define-map map_vote_action
  uint  ;; vote id
  principal ;; claim to whom
)

(define-map map_vote_note
  uint
  uint  ;; bit-or
)

(define-public (set_winners (winners (list 3 principal)))
  (let
    (
      (winner0 (element-at? winners u0))
      (winner1 (element-at? winners u1))
      (winner2 (element-at? winners u2))
    )
    (asserts! (is-eq contract-caller (unwrap! (var-get m_lottery_contract) (err ERR_LOTTERY_CONTRACT_NOT_SET))) (err ERR_NOT_LOTTERY_CONTRACT))
    ;; make sure no duplicate
    (if (is-eq (len winners) u1)
      (var-set m_winners winners)
      (if (is-eq (len winners) u2)
        (if (is-eq winner0 winner1)
          (var-set m_winners (list (unwrap-panic winner0)))
          (var-set m_winners winners)
        )
        (if (is-eq winner0 winner1 winner2)
          (var-set m_winners (list (unwrap-panic winner0)))
          (if (or (is-eq winner0 winner1) (is-eq winner1 winner2))  ;; not need check winner0==winner2, one account can only bet once per round
            (var-set m_winners (list (unwrap-panic winner0) (unwrap-panic winner2)))
            (var-set m_winners winners)
          )
        )
      )
    )
    (print {
      title: "set winners",
      winners: winners,
      m_winners: (var-get m_winners),
    })
    (ok true)
  )
)

;; When only 1 winner, he can call this function to receive the award
(define-public (claim_name (receiver principal))
  (let
    (
      (resolve_info (unwrap! (contract-call? 'SP000000000000000000002Q6VF78.bns resolve-principal (as-contract tx-sender)) (err ERR_BNS_RESOLVE_FAIL)))
      (winners (var-get m_winners))
      (winner0 (element-at? winners u0))
    )
    (asserts! (is-some winner0) (err ERR_NO_WINNER_YET))
    (asserts! (or (is-none (element-at? winners u1)) (is-eq winner0 (element-at? winners u1))) (err ERR_MULTI_WINNERS))
    (asserts! (or (is-none (element-at? winners u2)) (is-eq winner0 (element-at? winners u2))) (err ERR_MULTI_WINNERS))
    (asserts! (is-eq (unwrap-panic winner0) contract-caller) (err ERR_NOT_WINNER))
    (print {
      title: "Winner withdraw name",
      receiver: receiver,
    })
    (var-set m_winners (list))
    (as-contract (contract-call? 'SP000000000000000000002Q6VF78.bns name-transfer (get namespace resolve_info) (get name resolve_info) receiver none))
  )
)

;; When multi winners, they can vote to transfer away the name
(define-public (new_vote (whom principal))
  (let
    (
      (winners (var-get m_winners))
      (win_index_opt (index-of? winners contract-caller))
      (vote_id (+ (var-get m_vote_id) u1))
    )
    (asserts! (is-some win_index_opt) (err ERR_NO_SUCH_WINNER))
    (asserts! (is-some (element-at? winners u1)) (err ERR_SINGLE_WINNER))
    (print {
      title: "New vote",
      vote_id: vote_id,
      to-whom: whom
    })
    (var-set m_vote_id vote_id)
    (map-set map_vote_action vote_id whom)
    (map-set map_vote_note vote_id (bit-shift-left u1 (unwrap-panic win_index_opt)))
    (ok true)
  )
)

(define-public (vote_yes (vote_id uint))
  (let
    (
      (winners (var-get m_winners))
      (win_index (unwrap! (index-of? winners contract-caller) (err ERR_NO_SUCH_WINNER)))
      (vote_value (unwrap! (map-get? map_vote_note vote_id) (err ERR_VOTE_NOT_EXIST)))
      (new_value (bit-or vote_value (bit-shift-left u1 win_index)))
    )
    (asserts! (is-some (element-at? winners u1)) (err ERR_SINGLE_WINNER))
    (print {
      title: "Vote yes",
      vote_id: vote_id,
      new_value: new_value,
    })
    (map-set map_vote_note vote_id new_value)
    (and 
      (> (bit-and new_value (bit-shift-left u1 u0)) u0)
      (> (bit-and new_value (bit-shift-left u1 u1)) u0)
      (or
        (is-eq (len winners) u2)
        (> (bit-and new_value (bit-shift-left u1 u2)) u0)
      )
      (try! (handle_action vote_id))
    )
    (ok true)
  )
)

(define-public (set_lottery_contract (lottery_contract principal))
  (begin
    (asserts! (is-none (var-get m_lottery_contract)) (err ERR_LOTTERY_CONTRACT_SET))
    (ok (var-set m_lottery_contract (some lottery_contract)))
  )
)

(define-private (handle_action (vote_id uint))
  (let
    (
      (vote_receiver (unwrap! (map-get? map_vote_action vote_id) (err ERR_VOTE_NOT_EXIST)))
      (resolve_info (unwrap! (contract-call? 'SP000000000000000000002Q6VF78.bns resolve-principal (as-contract tx-sender)) (err ERR_BNS_RESOLVE_FAIL)))
    )
    (as-contract (contract-call? 'SP000000000000000000002Q6VF78.bns name-transfer (get namespace resolve_info) (get name resolve_info) vote_receiver none))
  )
)

(define-public (return_name (receiver principal))
  (let
    (
      (resolve_info (unwrap! (contract-call? 'SP000000000000000000002Q6VF78.bns resolve-principal (as-contract tx-sender)) (err ERR_BNS_RESOLVE_FAIL)))
    )
    (asserts! (is-eq contract-caller (unwrap! (var-get m_lottery_contract) (err ERR_LOTTERY_CONTRACT_NOT_SET))) (err ERR_NOT_LOTTERY_CONTRACT))
    (as-contract (contract-call? 'SP000000000000000000002Q6VF78.bns name-transfer (get namespace resolve_info) (get name resolve_info) receiver none))
  )
)

(define-read-only (get_summary)
  {
    winners: (var-get m_winners),
    lottery_contract: (var-get m_lottery_contract),
    vote_id: (var-get m_vote_id),
  }
)

(define-read-only (get_summary_with_vote (vote_id uint))
  {
    summary: (get_summary),
    action: (map-get? map_vote_action vote_id),
    value: (map-get? map_vote_note vote_id),
  }
)
