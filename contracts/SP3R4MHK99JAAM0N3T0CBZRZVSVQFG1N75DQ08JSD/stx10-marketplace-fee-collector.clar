(define-data-var m_user_list (list 4 principal) (list 
  'SPM45K10TF1NENMZW1HBWTY1XV5CKFXQMRP4EA9J
  'SP1P3A9XCVKA81XT4DNJP0C6JXNVNB49VZ1C00PXE
  'SP7D05V7M9NRVV3W7T2T1APP008TZZE7HZNTX2XJ
  'SP2DE8GXZVXXJHCBW9DFFMADZ40SKDPDKX5EZ79NT
))

(define-read-only (get_user_list)
  (var-get m_user_list)
)

(define-read-only (get_balance)
  (stx-get-balance (as-contract tx-sender))
)

(define-public (change_address (new_address principal))
  (match (index-of? (var-get m_user_list) tx-sender) user_index
    (ok (var-set m_user_list (unwrap-panic (replace-at? (var-get m_user_list) user_index new_address))))
    (err false)
  )
)

(define-public (withdraw)
  (let
    (
      (amount (/ (stx-get-balance (as-contract tx-sender)) u4))
      (user_list (var-get m_user_list))
    )
    (asserts! (is-some (index-of? user_list tx-sender)) (err u1001))
    (try! (as-contract (stx-transfer? amount tx-sender (unwrap-panic (element-at? user_list u0)))))
    (try! (as-contract (stx-transfer? amount tx-sender (unwrap-panic (element-at? user_list u1)))))
    (try! (as-contract (stx-transfer? amount tx-sender (unwrap-panic (element-at? user_list u2)))))
    (try! (as-contract (stx-transfer? amount tx-sender (unwrap-panic (element-at? user_list u3)))))
    (ok true)
  )
)
