;; @contract Block Info
;; @version 1
;;
;; Contract to get info at given block

;;-------------------------------------
;; Constants
;;-------------------------------------

(define-constant ERR_BLOCK_INFO u42001)

;;-------------------------------------
;; Stacking Info
;;-------------------------------------

(define-read-only (get-reserve-stacking-at-block (block uint))
  (let (
    (block-hash (unwrap! (get-block-info? id-header-hash block) (err ERR_BLOCK_INFO)))
  )
    (at-block block-hash (contract-call? .reserve-v1 get-stx-stacking))
  )
)

(define-read-only (get-stx-account-at-block (account principal) (block uint))
  (let (
    (block-hash (unwrap! (get-block-info? id-header-hash block) (err ERR_BLOCK_INFO)))
  )
    (ok (at-block block-hash (stx-account account)))
  )
)

;;-------------------------------------
;; User Info - Points
;;-------------------------------------

(define-read-only (get-user-ststx-at-block (account principal) (block uint))
  (let (
    (ststx-balance (get-ststx-balance-at-block account block))
    (lp-balance (get-lp-balance-at-block account block))
  )
    {
      ststx-balance: (unwrap-panic ststx-balance), 
      lp-balance: (unwrap-panic lp-balance)
    }
  )
)

;;-------------------------------------
;; User Info - Points - Helpers
;;-------------------------------------

(define-read-only (get-ststx-balance-at-block (account principal) (block uint))
  (let (
    (block-hash (unwrap! (get-block-info? id-header-hash block) (err ERR_BLOCK_INFO)))
  )
    (at-block block-hash (contract-call? .ststx-token get-balance account))
  )
)

(define-read-only (get-lp-balance-at-block (account principal) (block uint))
  (let (
    (block-hash (unwrap! (get-block-info? id-header-hash block) (err ERR_BLOCK_INFO)))
    
    ;; Wallet
    (balance-1 (at-block block-hash (contract-call? 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stx-ststx-lp-token-v-1-1 get-balance account)))
    (balance-2 (at-block block-hash (contract-call? 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stx-ststx-lp-token-v-1-2 get-balance account)))

    ;; Staked
    (user-data-1 (at-block block-hash (contract-call? 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.earn-stx-ststx-v-1-1 get-user-data
      .ststx-token
      'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stx-ststx-lp-token-v-1-1
      account
    )))
    (user-data-2 (at-block block-hash (contract-call? 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.earn-stx-ststx-v-1-2 get-user-data
      .ststx-token
      'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stx-ststx-lp-token-v-1-2
      account
    )))

    (staked-1 (if (is-some user-data-1)
      (get total-currently-staked (unwrap-panic user-data-1))
      u0
    ))
    (staked-2 (if (is-some user-data-2)
      (get total-currently-staked (unwrap-panic user-data-2))
      u0
    ))
  )
    (ok (+ 
      (unwrap-panic balance-1) 
      (unwrap-panic balance-2) 
      staked-1
      staked-2
    ))
  )
)
