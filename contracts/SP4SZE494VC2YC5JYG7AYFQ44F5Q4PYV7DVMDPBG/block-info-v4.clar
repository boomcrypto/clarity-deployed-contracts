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
    (block-hash (unwrap! (get-block-info? id-header-hash block) (err ERR_BLOCK_INFO)))

    (balance-wallet (at-block block-hash (get-wallet-balance account)))
  )
    (if (< block u132631)
      ;; Wallet only
      (ok {
        ststx-balance: balance-wallet, 
        lp-balance: u0
      })
      
      (if (< block u135640)
        ;; Wallet + BitFlow V1
        (let (
          (balance-bitflow-1 (unwrap-panic (at-block block-hash (get-bitflow-lp-1 account))))
        )
          (ok {
            ststx-balance: balance-wallet, 
            lp-balance: balance-bitflow-1
          })
        )

        (if (< block u140422)
          ;; Wallet + BitFlow V1 + Bitflow V2.1
          (let (
            (balance-bitflow-1 (unwrap-panic (at-block block-hash (get-bitflow-lp-1 account))))
            (balance-bitflow-2-1 (unwrap-panic (at-block block-hash (get-bitflow-lp-2-1 account))))
          )
            (ok {
              ststx-balance: balance-wallet, 
              lp-balance: (+ balance-bitflow-1 balance-bitflow-2-1)
            })
          )

          ;; Wallet + BitFlow V1 + Bitflow V2.2
          (let (
            (balance-bitflow-1 (unwrap-panic (at-block block-hash (get-bitflow-lp-1 account))))
            (balance-bitflow-2-2 (unwrap-panic (at-block block-hash (get-bitflow-lp-2-2 account))))
          )
            (ok {
              ststx-balance: balance-wallet, 
              lp-balance: (+ balance-bitflow-1 balance-bitflow-2-2)
            })
          )

        )
      )
    )
  )
)

;;-------------------------------------
;; Wallet
;;-------------------------------------

(define-read-only (get-wallet-balance (account principal))
  (unwrap-panic (contract-call? .ststx-token get-balance account))
)

;;-------------------------------------
;; Bitflow
;;-------------------------------------

;; V1
(define-read-only (get-bitflow-lp-1 (account principal))
  (let (    
    ;; Wallet
    (balance (unwrap-panic (contract-call? 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stx-ststx-lp-token-v-1-1 get-balance account)))

    ;; Staked
    (user-data (contract-call? 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.earn-stx-ststx-v-1-1 get-user-data
      .ststx-token
      'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stx-ststx-lp-token-v-1-1
      account
    ))

    (staked (if (is-some user-data)
      (get total-currently-staked (unwrap-panic user-data))
      u0
    ))
  )
    (ok (+ balance staked))
  )
)

;; V2
(define-read-only (get-bitflow-lp-2-1 (account principal))
  (let (    
    ;; Wallet
    (balance (unwrap-panic (contract-call? 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stx-ststx-lp-token-v-1-2 get-balance account)))

    ;; Staked
    (user-data (contract-call? 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.earn-stx-ststx-v-1-2 get-user-data
      .ststx-token
      'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stx-ststx-lp-token-v-1-2
      account
    ))

    (staked (if (is-some user-data)
      (get total-currently-staked (unwrap-panic user-data))
      u0
    ))
  )
    (ok (+ balance staked))
  )
)

;; V2 - stSTX only
(define-read-only (get-bitflow-lp-2-2 (account principal))
  (let (    
    ;; Wallet
    (balance (unwrap-panic (contract-call? 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stx-ststx-lp-token-v-1-2 get-balance account)))

    ;; Staked
    (user-data (contract-call? 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.earn-stx-ststx-v-1-2 get-user-data
      .ststx-token
      'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stx-ststx-lp-token-v-1-2
      account
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
