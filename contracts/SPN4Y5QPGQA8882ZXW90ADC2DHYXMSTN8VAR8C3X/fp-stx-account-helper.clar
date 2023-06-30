;; Helper contract to see locked amount for each cycle

(define-read-only (amount-locked-at-cycle (user principal) (cycle-id uint))
    (let (
        (last-commit (unwrap! (contract-call? 'SP21YTSM60CAY6D011EZVEVNKXVW8FVZE198XEFFP.pox-fast-pool-v2 get-last-aggregation cycle-id) -1))
        (id-header-hash (unwrap! (get-block-info? id-header-hash last-commit) -2)))
        (to-int (get-user-stacked user id-header-hash))))

(define-read-only (get-user-stacked (user principal) (id-header-hash (buff 32)))
  (get locked (at-block id-header-hash (stx-account user))))
