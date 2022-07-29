
(define-constant ERR_NO_AUTHORITY 10001)
(define-constant ERR_INVALID_ACT_ID 10002)
(define-constant ERR_RESOLVE_PRINCIPLE 10003)
(define-constant ERR_TRANSFER_STX 10004)

(define-data-var m_act_id uint u0)
(define-constant ACCOUNT_LIST (list 'SP1J1YKRP25FBVJT9X297VAGE6MRW0G1NS6PJNWQQ 'SP13VCKDSTQPQCGP5DZ80Z2X2E2PJAXXMPMFSXPDG 'SP3D2MN1QQN3CPPMWF0REWV005C23H8FGB22HWZ9V 'SP636G5RXRJ32E9454Q3X6QWJNMNXHVZG61Z46E9))

(define-map map_vote
  { act_id: uint, account_index: uint }
  bool
)

(define-map map_act_info
  uint      ;; act_id
  principal ;; transfer to whom
)

(define-public (new_vote (to principal))
  (let
    (
      (account_index (unwrap! (index-of ACCOUNT_LIST contract-caller) (err ERR_NO_AUTHORITY)))
      (new_act_id (+ (var-get m_act_id) u1))
    )
    (var-set m_act_id new_act_id)
    (print new_act_id)
    (map-set map_vote
      { act_id: new_act_id, account_index: account_index }
      true
    )
    (ok (map-set map_act_info new_act_id to))
  )
)

(define-public (vote_yes (act_id uint))
  (let
    (
      (account_index (unwrap! (index-of ACCOUNT_LIST contract-caller) (err ERR_NO_AUTHORITY)))
    )
    (asserts! (is-some (map-get? map_act_info act_id)) (err ERR_INVALID_ACT_ID))
    (map-set map_vote
      { act_id: act_id, account_index: account_index }
      true
    )
    ;;
    (and
      (>=
        (+
          (if (default-to false (map-get? map_vote { act_id: act_id, account_index: u0 })) u1 u0)
          (if (default-to false (map-get? map_vote { act_id: act_id, account_index: u1 })) u1 u0)
          (if (default-to false (map-get? map_vote { act_id: act_id, account_index: u2 })) u1 u0)
          (if (default-to false (map-get? map_vote { act_id: act_id, account_index: u3 })) u1 u0)
        )
        u2
      )
      (try! (handle_act act_id))
    )
    ;;
    (ok true)
  )
)

(define-public (renew (stx_to_burn uint) (b_flag bool))
  (let
    (
      (resolve_rsp_p (unwrap! (contract-call? 'SP000000000000000000002Q6VF78.bns resolve-principal (as-contract tx-sender)) (err ERR_RESOLVE_PRINCIPLE)))
      (namespace (get namespace resolve_rsp_p))
      (name (get name resolve_rsp_p))
      (resolve_rsp (try! (contract-call? 'SP000000000000000000002Q6VF78.bns name-resolve namespace name)))
    )
    (asserts! (is-some (index-of ACCOUNT_LIST tx-sender)) (err ERR_NO_AUTHORITY))
    (and b_flag (unwrap! (stx-transfer? stx_to_burn tx-sender (as-contract tx-sender)) (err ERR_TRANSFER_STX)))
    (as-contract (contract-call? 'SP000000000000000000002Q6VF78.bns name-renewal namespace name stx_to_burn none (some (get zonefile-hash resolve_rsp))))
  )
)

(define-private (handle_act (act_id uint))
  (let
    (
      (resolve_rsp_p (unwrap! (contract-call? 'SP000000000000000000002Q6VF78.bns resolve-principal (as-contract tx-sender)) (err ERR_RESOLVE_PRINCIPLE)))
      (namespace (get namespace resolve_rsp_p))
      (name (get name resolve_rsp_p))
      (resolve_rsp (try! (contract-call? 'SP000000000000000000002Q6VF78.bns name-resolve namespace name)))
      (to (unwrap-panic (map-get? map_act_info act_id)))
    )
    (try! (as-contract (contract-call? 'SP000000000000000000002Q6VF78.bns name-transfer namespace name to (some (get zonefile-hash resolve_rsp)))))
    (map-delete map_vote { act_id: act_id, account_index: u0 })
    (map-delete map_vote { act_id: act_id, account_index: u1 })
    (map-delete map_vote { act_id: act_id, account_index: u2 })
    (ok (map-delete map_act_info act_id))
  )
)

(define-read-only (get_act_detail (act_id uint))
  (map-get? map_act_info act_id)
)

(define-read-only (get_vote_detail (act_id uint) (account_index uint))
  (map-get? map_vote { act_id: act_id, account_index: account_index })
)