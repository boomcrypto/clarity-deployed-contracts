;; @contract Supported Protocol - BitFlow
;; @version 1

(impl-trait .protocol-trait-v1.protocol-trait)

;;-------------------------------------
;; BitFlow 
;;-------------------------------------

(define-read-only (get-balance (user principal))
  (let (    
    ;; Wallet
    (balance (unwrap-panic (contract-call? 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stx-ststx-lp-token-v-1-2 get-balance user)))

    ;; Staked
    (user-data (contract-call? 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.earn-stx-ststx-v-1-2 get-user-data
      .ststx-token
      'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stx-ststx-lp-token-v-1-2
      user
    ))
    (staked (if (is-some user-data)
      (get total-currently-staked (unwrap-panic user-data))
      u0
    ))

    ;; Total user
    (user-total (+ balance staked))

    ;; Total LP tokens
    (lp-total-supply (unwrap-panic (contract-call? 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stx-ststx-lp-token-v-1-2 get-total-supply)))

    ;; Pool balance stSTX
    (lp-balance-ststx (unwrap-panic (contract-call? .ststx-token get-balance 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stableswap-stx-ststx-v-1-2)))

    ;; User share
    (user-lp-share (/ (* user-total u1000000000000) lp-total-supply))
  )
    (ok (/ (* user-lp-share lp-balance-ststx) u1000000000000))
  )
)
