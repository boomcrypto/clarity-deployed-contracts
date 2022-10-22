(define-constant ERR_NO_AUTHORITY 10001)
(define-constant ERR_INVALID_ACT_ID 10002)
(define-constant ERR_RESOLVE_PRINCIPLE 10003)
(define-constant ERR_TRANSFER_STX 10004)

(define-data-var m_act_id uint u0)
(define-constant ACCOUNT_LIST (list 'SP2K75B2HAM9CX7JDDCPJSP74KHSWD01MENSYXCRB 'SPWPQKDJ9ZTN1XE3HCPXNAPQAATBYA4HYNECBS1Y 'SP1MHSZ3NE3322XBJBK2KVJVMTM4ME42NYT0Y1TXP 'SP2A61JRWGKPN9WFS8D8R5K5YDWNY5X6ZCS47S7DG 'SP3EA8M74WB08K8R56YNY611734ATP2NSKRZQKJVQ))

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
    (print { tip: "Attention: Verify!", act_id: new_act_id, to: to })
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
    (and
      (>=
        (+
          (if (default-to false (map-get? map_vote { act_id: act_id, account_index: u0 })) u1 u0)
          (if (default-to false (map-get? map_vote { act_id: act_id, account_index: u1 })) u1 u0)
          (if (default-to false (map-get? map_vote { act_id: act_id, account_index: u2 })) u1 u0)
          (if (default-to false (map-get? map_vote { act_id: act_id, account_index: u3 })) u1 u0)
          (if (default-to false (map-get? map_vote { act_id: act_id, account_index: u4 })) u1 u0)
        )
        u4
      )
      (try! (handle_act act_id))
    )
    (ok true)
  )
)

(define-public (renew (stx_to_burn uint) (b_flag bool))
  (let
    (
      (resolve_rsp (unwrap! (contract-call? 'SP000000000000000000002Q6VF78.bns resolve-principal (as-contract tx-sender)) (err ERR_RESOLVE_PRINCIPLE)))
      (namespace (get namespace resolve_rsp))
      (name (get name resolve_rsp))
    )
    (asserts! (is-some (index-of ACCOUNT_LIST tx-sender)) (err ERR_NO_AUTHORITY))
    (and b_flag (unwrap! (stx-transfer? stx_to_burn tx-sender (as-contract tx-sender)) (err ERR_TRANSFER_STX)))
    (as-contract (contract-call? 'SP000000000000000000002Q6VF78.bns name-renewal namespace name stx_to_burn none none))
  )
)

(define-private (handle_act (act_id uint))
  (let
    (
      (resolve_rsp (unwrap! (contract-call? 'SP000000000000000000002Q6VF78.bns resolve-principal (as-contract tx-sender)) (err ERR_RESOLVE_PRINCIPLE)))
      (namespace (get namespace resolve_rsp))
      (name (get name resolve_rsp))
      (to (unwrap! (map-get? map_act_info act_id) (err ERR_INVALID_ACT_ID)))
    )
    (try! (as-contract (contract-call? 'SP000000000000000000002Q6VF78.bns name-transfer namespace name to none)))
    (map-delete map_vote { act_id: act_id, account_index: u0 })
    (map-delete map_vote { act_id: act_id, account_index: u1 })
    (map-delete map_vote { act_id: act_id, account_index: u2 })
    (map-delete map_vote { act_id: act_id, account_index: u3 })
    (map-delete map_vote { act_id: act_id, account_index: u4 })
    (ok (map-delete map_act_info act_id))
  )
)

(define-read-only (get_act_detail (act_id uint))
  (map-get? map_act_info act_id)
)

(define-read-only (get_vote_detail (act_id uint) (account_index uint))
  (map-get? map_vote { act_id: act_id, account_index: account_index })
)
